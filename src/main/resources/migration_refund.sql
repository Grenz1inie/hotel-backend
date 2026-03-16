-- 数据库迁移脚本：添加退款申请功能
-- 执行日期：2025-01-XX
-- 说明：为bookings表添加退款申请相关字段和状态

-- 1. 修改status枚举，添加REFUND_REQUESTED状态
ALTER TABLE bookings 
MODIFY COLUMN status ENUM('PENDING','PENDING_CONFIRMATION','PENDING_PAYMENT','CONFIRMED','CHECKED_IN','CHECKED_OUT','CANCELLED','REFUND_REQUESTED','REFUNDED') 
NOT NULL DEFAULT 'PENDING';

-- 2. 添加退款申请相关字段
ALTER TABLE bookings 
ADD COLUMN refund_reason VARCHAR(500) COMMENT '退款原因' AFTER remark,
ADD COLUMN refund_requested_at TIMESTAMP NULL COMMENT '退款申请时间' AFTER refund_reason,
ADD COLUMN refund_approved_at TIMESTAMP NULL COMMENT '退款批准时间' AFTER refund_requested_at,
ADD COLUMN refund_rejected_at TIMESTAMP NULL COMMENT '退款拒绝时间' AFTER refund_approved_at,
ADD COLUMN refund_approved_by BIGINT COMMENT '退款审批人ID' AFTER refund_rejected_at;

-- 3. 添加索引以提高查询性能
ALTER TABLE bookings 
ADD INDEX idx_bookings_refund_status (status, refund_requested_at);

-- 验证修改
SHOW COLUMNS FROM bookings LIKE 'status';
SHOW COLUMNS FROM bookings LIKE 'refund%';

SELECT 'Migration completed successfully' AS result;
