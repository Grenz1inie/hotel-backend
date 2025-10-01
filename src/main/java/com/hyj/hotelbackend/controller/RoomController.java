package com.hyj.hotelbackend.controller;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.hyj.hotelbackend.auth.AuthUser;
import com.hyj.hotelbackend.auth.CurrentUserHolder;
import com.hyj.hotelbackend.entity.Booking;
import com.hyj.hotelbackend.dto.RoomOccupancyOverviewResponse;
import com.hyj.hotelbackend.entity.Room;
import com.hyj.hotelbackend.entity.User;
import com.hyj.hotelbackend.entity.RoomInstance;
import com.hyj.hotelbackend.entity.WalletTransaction;
import com.hyj.hotelbackend.entity.PaymentRecord;
import com.hyj.hotelbackend.mapper.UserMapper;
import com.hyj.hotelbackend.service.BookingService;
import com.hyj.hotelbackend.service.RoomService;
import com.hyj.hotelbackend.service.RoomInstanceService;
import com.hyj.hotelbackend.service.WalletService;
import com.hyj.hotelbackend.service.PaymentService;
import com.hyj.hotelbackend.service.VipPricingService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.server.ResponseStatusException;
import org.springframework.transaction.annotation.Transactional;

import com.fasterxml.jackson.annotation.JsonFormat;
import java.math.BigDecimal;
import java.math.RoundingMode;
import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Objects;
import java.util.Set;
import java.util.stream.Collectors;

@RestController
@RequestMapping("/api/rooms")
public class RoomController {

    @Autowired
    private RoomService roomService;

    @Autowired
    private BookingService bookingService;

    @Autowired
    private RoomInstanceService roomInstanceService;

    @Autowired
    private UserMapper userMapper;

    @Autowired
    private WalletService walletService;

    @Autowired
    private PaymentService paymentService;

    @Autowired
    private VipPricingService vipPricingService;

    @GetMapping
    public List<Room> list() {
        List<Room> rooms = roomService.list();
        if (rooms.isEmpty()) {
            return rooms;
        }
        Map<Long, InventoryMetrics> inventory = aggregateInventoryByRoomType(
                rooms.stream()
                        .map(Room::getId)
                        .filter(Objects::nonNull)
                        .collect(Collectors.toSet())
        );
        rooms.forEach(room -> {
            InventoryMetrics metrics = room.getId() == null ? null : inventory.get(room.getId());
            if (metrics != null) {
                room.setTotalCount(metrics.totalRooms());
                room.setAvailableCount(metrics.availableRooms());
            }
        });
        return rooms;
    }

    @GetMapping("/{id}")
    public Room get(@PathVariable Long id) {
        Room r = roomService.getById(id);
        if (r == null) throw new ResponseStatusException(HttpStatus.NOT_FOUND, "房型不存在");
        return r;
    }

    @GetMapping("/instances")
    public List<RoomInstance> listInstances(@RequestParam(required = false) Long hotelId,
                                            @RequestParam(required = false) Long roomTypeId,
                                            @RequestParam(required = false) Integer status) {
        AuthUser me = CurrentUserHolder.get();
        if (me == null || me.getRole() == null || !"ADMIN".equals(me.getRole())) {
            throw new ResponseStatusException(HttpStatus.FORBIDDEN, "仅管理员可查看房间详情");
        }
        LambdaQueryWrapper<RoomInstance> qw = new LambdaQueryWrapper<>();
        if (hotelId != null) {
            qw.eq(RoomInstance::getHotelId, hotelId);
        }
        if (roomTypeId != null) {
            qw.eq(RoomInstance::getRoomTypeId, roomTypeId);
        }
        if (status != null) {
            qw.eq(RoomInstance::getStatus, status);
        }
        qw.orderByAsc(RoomInstance::getRoomTypeId).orderByAsc(RoomInstance::getRoomNumber);
        return roomInstanceService.list(qw);
    }

    @GetMapping("/occupancy-overview")
    public RoomOccupancyOverviewResponse occupancyOverview(@RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE_TIME) LocalDateTime start,
                                                            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE_TIME) LocalDateTime end,
                                                            @RequestParam(required = false) Long hotelId,
                                                            @RequestParam(required = false) Long roomTypeId) {
        AuthUser me = CurrentUserHolder.get();
        if (me == null || me.getRole() == null || !"ADMIN".equals(me.getRole())) {
            throw new ResponseStatusException(HttpStatus.FORBIDDEN, "仅管理员可查看入住规划");
        }
        if (start == null) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "start 参数不能为空");
        }
        LocalDateTime windowStart = start;
        LocalDateTime windowEnd = end != null ? end : windowStart.plusDays(7);
        if (!windowStart.isBefore(windowEnd)) {
            throw new ResponseStatusException(HttpStatus.UNPROCESSABLE_ENTITY, "时间范围无效");
        }

        LambdaQueryWrapper<Booking> bookingQuery = new LambdaQueryWrapper<>();
        if (hotelId != null) {
            bookingQuery.eq(Booking::getHotelId, hotelId);
        }
        if (roomTypeId != null) {
            bookingQuery.eq(Booking::getRoomTypeId, roomTypeId);
        }
    bookingQuery.lt(Booking::getStartTime, windowEnd).gt(Booking::getEndTime, windowStart);
    bookingQuery
        .orderByAsc(Booking::getRoomTypeId)
        .orderByAsc(Booking::getRoomId)
        .orderByAsc(Booking::getStartTime)
        .orderByAsc(Booking::getId);
        List<Booking> bookings = bookingService.list(bookingQuery);

        LambdaQueryWrapper<RoomInstance> roomQuery = new LambdaQueryWrapper<>();
        if (hotelId != null) {
            roomQuery.eq(RoomInstance::getHotelId, hotelId);
        }
        if (roomTypeId != null) {
            roomQuery.eq(RoomInstance::getRoomTypeId, roomTypeId);
        }
        roomQuery.orderByAsc(RoomInstance::getRoomTypeId).orderByAsc(RoomInstance::getRoomNumber);
        List<RoomInstance> instances = roomInstanceService.list(roomQuery);

        RoomOccupancyOverviewResponse resp = new RoomOccupancyOverviewResponse();
        resp.setWindowStart(windowStart);
        resp.setWindowEnd(windowEnd);
        resp.setBookings(bookings);
        resp.setRoomInstances(instances);
        return resp;
    }

    // admin endpoint to update available count
    @PutMapping("/{id}/adjust")
    public Room adjust(@PathVariable Long id, @RequestParam int totalCount) {
        AuthUser me = CurrentUserHolder.get();
        if (me == null || me.getRole() == null || !me.getRole().equals("ADMIN")) {
            throw new ResponseStatusException(HttpStatus.FORBIDDEN, "仅管理员可调整库存");
        }
        if (totalCount < 0) throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "totalCount 不能为负数");
    Room r = roomService.getById(id);
        if (r == null) throw new ResponseStatusException(HttpStatus.NOT_FOUND, "房型不存在");
        r.setTotalCount(totalCount);
    long actualAvailable = roomInstanceService.count(new LambdaQueryWrapper<RoomInstance>()
        .eq(RoomInstance::getRoomTypeId, id)
        .eq(RoomInstance::getStatus, 1));
    int available = (int) Math.min((long) totalCount, actualAvailable);
    r.setAvailableCount(available);
        roomService.updateById(r);
        return r;
    }

    // create booking (user must be authenticated)
    @PostMapping("/{id}/book")
    @Transactional
    public Booking book(@PathVariable Long id, @RequestBody BookRoomRequest request) {
        AuthUser me = CurrentUserHolder.get();
        if (me == null) throw new ResponseStatusException(HttpStatus.UNAUTHORIZED, "未登录");
        boolean isAdmin = me.getRole() != null && me.getRole().equals("ADMIN");
        if (request == null) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "请求体不能为空");
        }
        Long actualUserId = me.getId();
        if (request.userId != null && !Objects.equals(request.userId, me.getId())) {
            if (isAdmin) {
                actualUserId = request.userId; // admin can book for others
            } else {
                throw new ResponseStatusException(HttpStatus.FORBIDDEN, "不能为他人创建预订");
            }
        } else if (isAdmin && request.userId == null) {
            actualUserId = resolveOrCreateUser(request.contactPhone, request.contactName);
        }
        LocalDateTime start = request.start;
        LocalDateTime end = request.end;
        if (start == null || end == null) throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "start/end 必填");
        if (!start.isBefore(end)) throw new ResponseStatusException(HttpStatus.UNPROCESSABLE_ENTITY, "开始时间必须早于结束时间");
        Room r = roomService.getById(id);
        if (r == null) throw new ResponseStatusException(HttpStatus.NOT_FOUND, "房型不存在");
        Long resolvedHotelId = r.getHotelId();
        if (request.hotelId != null && resolvedHotelId != null && !Objects.equals(request.hotelId, resolvedHotelId)) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "酒店信息不匹配");
        }
        if (resolvedHotelId == null) {
            resolvedHotelId = request.hotelId;
        }
        if (resolvedHotelId == null) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "无法确定酒店信息");
        }
        // check inventory by overlapping bookings
    long overlapping = bookingService.count(new LambdaQueryWrapper<Booking>()
        .eq(Booking::getRoomTypeId, id)
                .ne(Booking::getStatus, "CHECKED_OUT")
                .ne(Booking::getStatus, "CANCELLED")
                .lt(Booking::getStartTime, end)
                .gt(Booking::getEndTime, start)
        );
        if (overlapping >= r.getTotalCount()) {
            throw new ResponseStatusException(HttpStatus.CONFLICT, "库存不足或时间段冲突");
        }
        if (r.getAvailableCount() <= 0) {
            throw new ResponseStatusException(HttpStatus.CONFLICT, "暂无可用房间");
        }
        RoomInstance allocated = roomInstanceService.lambdaQuery()
                .eq(RoomInstance::getRoomTypeId, r.getId())
                .eq(RoomInstance::getHotelId, resolvedHotelId)
                .eq(RoomInstance::getStatus, 1)
                .orderByAsc(RoomInstance::getRoomNumber)
                .last("LIMIT 1")
                .one();
        if (allocated == null) {
            throw new ResponseStatusException(HttpStatus.CONFLICT, "房间正在整理，请稍后再试");
        }
        User chargeUser = userMapper.selectById(actualUserId);
        if (chargeUser == null) {
            throw new ResponseStatusException(HttpStatus.NOT_FOUND, "用户不存在");
        }
    Booking b = new Booking();
        b.setHotelId(resolvedHotelId);
        b.setRoomTypeId(r.getId());
        b.setRoomId(allocated.getId());
        b.setUserId(actualUserId);
    b.setStartTime(start);
    b.setEndTime(end);
        int guestCount = request.guests != null && request.guests > 0 ? request.guests : 1;
        b.setGuests(guestCount);
        int checkoutHour = vipPricingService.getCheckoutBoundaryHour(chargeUser.getVipLevel());
        long days = computeChargeableDays(start, end, checkoutHour);
        BigDecimal basePrice = r.getPricePerNight() == null ? BigDecimal.ZERO : r.getPricePerNight();
        BigDecimal originalAmount = basePrice.multiply(BigDecimal.valueOf(days));
    BigDecimal discountRate = vipPricingService.getDiscountRateForRoom(r.getId(), chargeUser.getVipLevel());
        BigDecimal payableAmount = originalAmount.multiply(discountRate).setScale(2, RoundingMode.HALF_UP);
        if (payableAmount.compareTo(BigDecimal.ZERO) <= 0) {
            payableAmount = originalAmount.setScale(2, RoundingMode.HALF_UP);
        }
        BigDecimal discountAmount = originalAmount.subtract(payableAmount).setScale(2, RoundingMode.HALF_UP);
        b.setOriginalAmount(originalAmount.setScale(2, RoundingMode.HALF_UP));
        b.setDiscountAmount(discountAmount);
        b.setPayableAmount(payableAmount);
        b.setAmount(payableAmount);
        b.setPaidAmount(BigDecimal.ZERO);
    b.setDiscountRate(discountRate);
    String normalizedMethod = normalizePaymentMethod(request.paymentMethod);
    if ("ADMIN".equals(normalizedMethod) && !isAdmin) {
        throw new ResponseStatusException(HttpStatus.FORBIDDEN, "仅管理员可创建免支付预订");
    }
    boolean adminDirect = isAdmin && "ADMIN".equals(normalizedMethod);
    String paymentMethod = adminDirect ? "ADMIN" : normalizedMethod;
    String paymentChannel = adminDirect ? "ADMIN" : resolvePaymentChannel(paymentMethod, request.paymentChannel);
    boolean payNow = adminDirect ? false : shouldPayImmediately(paymentMethod, request.payNow);
    b.setPaymentMethod(paymentMethod);
    b.setPaymentChannel(paymentChannel);
    b.setStatus(resolveInitialStatus(paymentMethod));
    b.setPaymentStatus(adminDirect ? "WAIVED" : "UNPAID");
        b.setCurrency("CNY");
        if (request.contactName != null) {
            b.setContactName(request.contactName.trim());
        }
        if (request.contactPhone != null) {
            b.setContactPhone(request.contactPhone.trim());
        }
        if (request.remark != null) {
            b.setRemark(request.remark.trim());
        }
    bookingService.save(b);
    allocated.setStatus(2);
    allocated.setUpdatedTime(LocalDateTime.now());
    roomInstanceService.updateById(allocated);
        // payment handling
        if (payNow) {
            if ("WALLET".equals(paymentMethod)) {
                try {
                    WalletTransaction tx = walletService.consume(actualUserId, payableAmount, paymentChannel, b.getId(), "酒店预订扣款");
                    b.setWalletTransactionId(tx.getId());
                    b.setPaidAmount(payableAmount);
                    b.setPaymentStatus("PAID");
                    b.setStatus("PENDING_CONFIRMATION");
                } catch (IllegalStateException ex) {
                    throw new ResponseStatusException(HttpStatus.PAYMENT_REQUIRED, ex.getMessage());
                } catch (IllegalArgumentException ex) {
                    throw new ResponseStatusException(HttpStatus.BAD_REQUEST, ex.getMessage());
                }
            } else if ("ONLINE".equals(paymentMethod) || "DIRECT".equals(paymentMethod) || "POS".equals(paymentMethod)) {
                PaymentRecord record = paymentService.recordDirectPayment(b.getId(), actualUserId, payableAmount, paymentMethod, paymentChannel, request.referenceNo);
                b.setPaymentRecordId(record.getId());
                b.setPaidAmount(payableAmount);
                b.setPaymentStatus("PAID");
                b.setStatus("PENDING_CONFIRMATION");
            } else {
                // default treat as direct payment but keep unpaid to be confirmed later
                b.setPaymentStatus("UNPAID");
            }
        } else if ("ARRIVAL".equals(paymentMethod)) {
            b.setStatus("PENDING_PAYMENT");
        } else if (adminDirect) {
            b.setPaymentStatus("WAIVED");
            b.setStatus("CONFIRMED");
            b.setPaidAmount(BigDecimal.ZERO);
        }
        bookingService.updateById(b);
        // decrement availableCount (simplified, not handling overlapping bookings)
        r.setAvailableCount(Math.max(0, r.getAvailableCount() - 1));
        roomService.updateById(r);
        return b;
    }

    // availability for a room within time range
    @GetMapping("/{id}/availability")
    public Map<String, Object> availability(@PathVariable Long id,
                                            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE_TIME) LocalDateTime start,
                                            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE_TIME) LocalDateTime end) {
        if (!start.isBefore(end)) throw new ResponseStatusException(HttpStatus.UNPROCESSABLE_ENTITY, "开始时间必须早于结束时间");
        Room r = roomService.getById(id);
        if (r == null) throw new ResponseStatusException(HttpStatus.NOT_FOUND, "房型不存在");
        long overlapping = bookingService.count(new LambdaQueryWrapper<Booking>()
                .eq(Booking::getRoomId, id)
                .ne(Booking::getStatus, "CHECKED_OUT")
                .ne(Booking::getStatus, "CANCELLED")
                .lt(Booking::getStartTime, end)
                .gt(Booking::getEndTime, start)
        );
        long availableCount = Math.max(0, r.getTotalCount() - overlapping);
        return Map.of(
                "available", availableCount > 0,
                "availableCount", availableCount
        );
    }

    // admin confirms check-in
    @PutMapping("/bookings/{bookingId}/confirm")
    public Booking confirm(@PathVariable Long bookingId) {
        AuthUser me = CurrentUserHolder.get();
        if (me == null || me.getRole() == null || !me.getRole().equals("ADMIN")) {
            throw new ResponseStatusException(HttpStatus.FORBIDDEN, "仅管理员可操作");
        }
        Booking b = bookingService.getById(bookingId);
        if (b == null) throw new ResponseStatusException(HttpStatus.NOT_FOUND, "预订不存在");
        b.setStatus("CONFIRMED");
        bookingService.updateById(b);
        return b;
    }

    // admin checkout
    @PutMapping("/bookings/{bookingId}/checkout")
    public Booking checkout(@PathVariable Long bookingId) {
        AuthUser me = CurrentUserHolder.get();
        if (me == null || me.getRole() == null || !me.getRole().equals("ADMIN")) {
            throw new ResponseStatusException(HttpStatus.FORBIDDEN, "仅管理员可操作");
        }
        Booking b = bookingService.getById(bookingId);
        if (b == null) throw new ResponseStatusException(HttpStatus.NOT_FOUND, "预订不存在");
        b.setStatus("CHECKED_OUT");
        bookingService.updateById(b);
        Room r = roomService.getById(b.getRoomId());
        if (r != null) {
            r.setAvailableCount(r.getAvailableCount() + 1);
            roomService.updateById(r);
        }
        return b;
    }

    private Long resolveOrCreateUser(String contactPhone, String contactName) {
        if (contactPhone == null || contactPhone.trim().isEmpty()) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "管理员代客预约需提供客户联系电话");
        }
        String usernameCandidate = contactPhone.trim();
        User existing = userMapper.selectOne(new LambdaQueryWrapper<User>().eq(User::getUsername, usernameCandidate));
        if (existing != null) {
            return existing.getId();
        }
        User u = new User();
        u.setUsername(usernameCandidate);
        u.setPassword("123456");
        u.setRole("USER");
        u.setVipLevel(0);
        if (contactPhone != null) {
            u.setPhone(contactPhone.trim());
        }
        u.setStatus("ACTIVE");
        userMapper.insert(u);
        if (u.getId() == null) {
            throw new ResponseStatusException(HttpStatus.INTERNAL_SERVER_ERROR, "创建用户失败");
        }
        return u.getId();
    }

    private long computeChargeableDays(LocalDateTime start, LocalDateTime end, Integer checkoutHour) {
        if (start == null || end == null) {
            return 1L;
        }
        if (!start.isBefore(end)) {
            return 1L;
        }
        long days = 1L;
        int rawHour = checkoutHour == null ? 12 : checkoutHour;
        int normalizedHour = Math.floorMod(rawHour, 24);
        int extraDays = rawHour / 24;
        LocalDateTime boundary = start.toLocalDate().atStartOfDay().plusHours(normalizedHour).plusDays(extraDays);
        if (!start.isBefore(boundary)) {
            boundary = boundary.plusDays(1);
        }
        while (end.isAfter(boundary)) {
            days++;
            boundary = boundary.plusDays(1);
        }
        return days;
    }

    private String normalizePaymentMethod(String raw) {
        if (raw == null || raw.isBlank()) {
            return "WALLET";
        }
        String method = raw.trim().toUpperCase();
        if ("ONLINE".equals(method) || "ARRIVAL".equals(method) || "WALLET".equals(method) || "ADMIN".equals(method)) {
            return method;
        }
        if ("DIRECT".equals(method) || "POS".equals(method)) {
            return "ARRIVAL";
        }
        return "WALLET";
    }

    private String resolvePaymentChannel(String paymentMethod, String rawChannel) {
        if ("WALLET".equals(paymentMethod)) {
            return "WALLET";
        }
        if ("ARRIVAL".equals(paymentMethod)) {
            return "ARRIVAL";
        }
        if ("ADMIN".equals(paymentMethod)) {
            return "ADMIN";
        }
        String candidate = rawChannel == null ? "ONLINE" : rawChannel.trim().toUpperCase();
        switch (candidate) {
            case "WECHAT":
            case "ALIPAY":
            case "PAYPAL":
            case "VISA":
            case "MASTERCARD":
            case "UNIONPAY":
                return candidate;
            default:
                return "ONLINE";
        }
    }

    private boolean shouldPayImmediately(String paymentMethod, Boolean payNowFlag) {
        if ("ARRIVAL".equals(paymentMethod) || "ADMIN".equals(paymentMethod)) {
            return false;
        }
        if (payNowFlag == null) {
            return true;
        }
        return Boolean.TRUE.equals(payNowFlag);
    }

    private String resolveInitialStatus(String paymentMethod) {
        if ("ARRIVAL".equals(paymentMethod)) {
            return "PENDING_PAYMENT";
        }
        if ("ADMIN".equals(paymentMethod)) {
            return "CONFIRMED";
        }
        return "PENDING_CONFIRMATION";
    }

    public static class BookRoomRequest {
        public Long userId;
        public Long hotelId;
        public Integer guests;
        public String contactName;
        public String contactPhone;
        public String remark;
        @JsonFormat(pattern = "yyyy-MM-dd'T'HH:mm:ss", timezone = "Asia/Shanghai")
        public LocalDateTime start;
        @JsonFormat(pattern = "yyyy-MM-dd'T'HH:mm:ss", timezone = "Asia/Shanghai")
        public LocalDateTime end;
        public String paymentMethod;
        public String paymentChannel;
        public Boolean payNow;
        public String referenceNo;
    }

    private Map<Long, InventoryMetrics> aggregateInventoryByRoomType(Set<Long> roomTypeIds) {
        if (roomTypeIds == null || roomTypeIds.isEmpty()) {
            return java.util.Collections.emptyMap();
        }
        List<RoomInstance> instances = roomInstanceService.lambdaQuery()
                .in(RoomInstance::getRoomTypeId, roomTypeIds)
                .select(RoomInstance::getRoomTypeId, RoomInstance::getStatus)
                .list();
        Map<Long, InventoryAccumulator> accumulatorMap = new HashMap<>();
        for (RoomInstance instance : instances) {
            if (instance == null || instance.getRoomTypeId() == null) {
                continue;
            }
            InventoryAccumulator acc = accumulatorMap.computeIfAbsent(instance.getRoomTypeId(), key -> new InventoryAccumulator());
            acc.totalRooms++;
            int status = instance.getStatus() == null ? 0 : instance.getStatus();
            if (status == 1) {
                acc.availableRooms++;
            }
        }
        Map<Long, InventoryMetrics> result = new HashMap<>();
        accumulatorMap.forEach((roomTypeId, acc) -> result.put(roomTypeId, acc.toMetrics()));
        return result;
    }

    private static final class InventoryAccumulator {
        private int totalRooms;
        private int availableRooms;

        private InventoryMetrics toMetrics() {
            int total = Math.max(0, totalRooms);
            int available = Math.max(0, Math.min(availableRooms, total));
            return new InventoryMetrics(total, available);
        }
    }

    private record InventoryMetrics(int totalRooms, int availableRooms) {
    }
}
