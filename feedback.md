先说约定（强烈建议统一）

Base URL: /api
鉴权方式: Bearer JWT（除登录、公开配置/健康检查外，其余接口均需要）
请求头: Authorization: Bearer <token>
错误响应统一格式（4xx/5xx）
{ code: string, message: string, details?: any }
常见状态码: 400 参数错误、401 未登录/Token 失效、403 无权限、404 资源不存在、409 业务冲突（如库存不足/时间重叠）、422
语义错误（如日期顺序）、500 服务异常
分页统一格式
请求: page=1&size=10&sort=field,asc
响应: { items: T[], page: number, size: number, total: number }
日期时间: ISO 8601 字符串（示例 2025-10-01T14:00:00+08:00）
货币: 字符串十进制，单位 CNY（示例 "299.00"）
一、认证与用户（Auth & Users）

登录（必需，当前前端已依赖）
POST /api/auth/login
Body: { username: string, password: string }
200: { token: string, user: { id: number, username: string, role: "ADMIN" | "USER", vipLevel: number } }
401: { code: "UNAUTHORIZED", message: "用户名或密码错误" }
刷新令牌（建议，有效期管理）
POST /api/auth/refresh
Body: { refreshToken: string }
200: { token: string, expiresIn: number }
获取当前登录用户信息（建议，前端初始化重载）
GET /api/auth/me
200: { id, username, role, vipLevel }
登出（建议，如需服务端失效 refreshToken）
POST /api/auth/logout
204
用户详情（建议）
GET /api/users/{id}
200: { id, username, role, vipLevel, ... }
更新用户资料（建议）
PUT /api/users/{id}
Body: { nickname?, mobile?, email? }
200: { ...updatedUser }
管理员查询用户列表（建议，后台管理）
GET /api/users?page=&size=&keyword=&role=
200: { items: User[], page, size, total }
管理员设置用户角色/VIP（建议）
PUT /api/users/{id}/role
Body: { role: "ADMIN"|"USER", vipLevel?: number }
200: { ...user }
二、房型与房间（Rooms & Inventory） 现有接口保留，同时建议补充检索与上传能力。

已存在（保持）

GET /api/rooms（已有，建议补充分页/筛选见下）
GET /api/rooms/{id}
PUT /api/rooms/{id}/adjust?totalCount=（管理员）
POST /api/rooms/{id}/book（创建预订，现有实现用 query/form）
建议新增

检索房型（必需，支撑前端搜索与分页体验）
GET /api/rooms?keyword=&type=&minPrice=&maxPrice=&start=&end=&page=&size=&sort=
说明: start/end 传入则只返回该时段“可售”的房型（需后端检查重叠与库存）
200: { items: Room[], page, size, total }
创建房型（管理员，建议）
POST /api/rooms
Body: { name, type, totalCount, pricePerNight, description }
201: { ...room }
更新房型（管理员，建议）
PUT /api/rooms/{id}
Body: { name?, type?, totalCount?, pricePerNight?, description? }
200: { ...room }
删除房型/下架（管理员，建议软删）
DELETE /api/rooms/{id}
204
查询房型在时段的可用量（建议，详情页预检）
GET /api/rooms/{id}/availability?start=&end=
200: { available: boolean, availableCount: number }
房型图片上传/管理（建议）
POST /api/rooms/{id}/images（multipart/form-data，字段 file）
201: { id: number, url: string }
DELETE /api/rooms/{id}/images/{imageId} → 204
三、预订/订单（Bookings） 保留现有 confirm/checkout，补充“我的订单/取消/修改/支付”等常见动作。

已存在（保持）

POST /api/rooms/{id}/book（创建预订，状态 PENDING；建议新增更规范的替代见下）
PUT /api/rooms/bookings/{bookingId}/confirm（管理员）
PUT /api/rooms/bookings/{bookingId}/checkout（管理员）
必需（当前前端“我的订单”页面）

查询用户的订单（必需）
GET /api/users/{userId}/bookings?status=&page=&size=
200: { items: Booking[], page, size, total }
推荐的更规范新建预订接口（不替代老接口前，前端仍用老接口） 2) 创建预订（建议，用更语义化路径）

POST /api/bookings
Body: { userId, roomId, start, end, guests?: number, contactName?: string, contactPhone?: string, note?: string }
201: { ...booking }
409: 可用量不足或与已存在订单重叠
获取预订详情（建议）
GET /api/bookings/{id}
200: { ...booking }
取消预订（用户）（强烈建议，常见需求）
PUT /api/bookings/{id}/cancel
200: { ...booking, status: "CANCELLED" }
409: 状态不允许取消（如已 CHECKED_IN/OUT）
修改预订（用户）（建议）
PUT /api/bookings/{id}
Body: { start?, end?, guests? }
200: { ...booking }（需要可用性检查与金额重算）
409: 库存不足/与其他预订重叠
管理员列表订单（建议，后台管理）
GET /api/bookings?status=&roomId=&userId=&dateStart=&dateEnd=&page=&size=&sort=
200: { items: Booking[], page, size, total }
区分入住与确认（可选增强）
PUT /api/bookings/{id}/checkin
200: { status: "CHECKED_IN" }
四、支付与价格（Payments & Pricing）（按需开启）

价格试算（建议，创建预订前的报价/展示）
GET /api/pricing/quote?roomId=&start=&end=&vipLevel=&couponCode=
200: { days: number, baseAmount: "598.00", discountAmount: "50.00", payAmount: "548.00" }
提交支付（可选）
POST /api/bookings/{id}/pay
Body: { channel: "alipay"|"wechat"|"card", amount: "548.00", returnUrl?: string }
200: { paymentId, status: "PENDING"|"SUCCEEDED"|"FAILED", payUrl?: string }
查询支付记录（可选）
GET /api/payments?bookingId=
200: Payment[]
支付回调 Webhook（可选）
POST /api/payments/webhook/{channel}
五、评价/反馈（Reviews）（可选，但常见）

提交评价（入住完成的订单）
POST /api/rooms/{id}/reviews
Body: { bookingId, rating: 1..5, content?: string, images?: string[] }
201: { id, ... }
查看评价
GET /api/rooms/{id}/reviews?page=&size=
200: { items: Review[], page, size, total }
管理员审核/隐藏评价（可选）
PUT /api/reviews/{id}/moderate
Body: { visible: boolean }
六、优惠券/VIP（可选，与定价挂钩）

校验优惠券
POST /api/coupons/validate
Body: { code, userId, roomId, start, end }
200: { valid: boolean, discountAmount?: "50.00", reason?: string }
VIP 等级列表
GET /api/vip/levels
200: [ { level: number, name: string, discountRate: number } ]
七、运营/报表（Admin）（可选）

经营概览
GET /api/admin/metrics/overview?range=last7d|last30d|custom&from=&to=
200: { totalRevenue: "xxx", totalBookings: number, occupancyRate: number, topRooms: [{roomId, name, bookings}] }
低库存预警
GET /api/admin/rooms/low-availability?threshold=3
200: Room[]
八、系统与配置（System）

健康检查（建议，前端错误页/运维探活可用）
GET /api/health
200: { status: "UP", time: "..." }
前端公开配置（建议）
GET /api/config/public
200: { enableRegister: boolean, paymentChannels: string[], ... }
与现有前端的直接映射（最小集，优先实现）

登录页：POST /api/auth/login（必需）
列表与详情：GET /api/rooms、GET /api/rooms/{id}（已存在；建议升级检索支持分页/筛选）
创建预订：沿用 POST /api/rooms/{id}/book（现状），后续可迁移到 POST /api/bookings
我的订单：GET /api/users/{userId}/bookings（必需）
管理员操作：PUT /api/rooms/{id}/adjust、PUT /api/rooms/bookings/{bid}/confirm、PUT /api/rooms/bookings/{bid}/checkout（已存在）
错误码：请将当前“返回 200 且 body 为 null”的情况改为合适的 404/400/409，并用统一错误响应格式
数据模型（简版，对齐前端使用）

Room: { id, name, type, totalCount, availableCount, pricePerNight, images: string[] | string, description }
Booking: { id, roomId, userId, startTime, endTime, status: "PENDING"|"PAID"|"CONFIRMED"|"CHECKED_IN"|"CHECKED_OUT"|"
CANCELLED", amount }
User: { id, username, role: "ADMIN"|"USER", vipLevel }
Error: { code, message, details? }
Pagination<T>: { items: T[], page, size, total }
建议的状态流（供后端校验/前端展示）

PENDING →（支付成功）→ PAID →（管理员审核）→ CONFIRMED →（到店）→ CHECKED_IN →（离店）→ CHECKED_OUT
任意允许取消的阶段 → CANCELLED（按规则限制：如已 CHECKED_IN 不可取消）
最后的小结（行动清单）

现在必须补的接口（确保前端可跑通并符合“无后端则跳错误页”的要求）
POST /api/auth/login
GET /api/users/{userId}/bookings
将已有接口的“未找到/业务失败”调整为合理的 4xx/409，并返回统一错误体
强烈建议的近期补充（显著改善体验与稳定性）
GET /api/rooms 带分页/筛选（含按时段可售）
GET /api/rooms/{id}/availability
PUT /api/bookings/{id}/cancel
GET /api/auth/me（用于刷新页面后自动恢复会话）
其余建议项可按优先级逐步实现（CRUD、支付、评价、报表、上传等）
