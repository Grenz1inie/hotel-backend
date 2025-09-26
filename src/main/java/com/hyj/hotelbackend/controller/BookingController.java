package com.hyj.hotelbackend.controller;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.hyj.hotelbackend.auth.AuthUser;
import com.hyj.hotelbackend.auth.CurrentUserHolder;
import com.hyj.hotelbackend.common.PageResponse;
import com.hyj.hotelbackend.entity.Booking;
import com.hyj.hotelbackend.entity.Room;
import com.hyj.hotelbackend.service.BookingService;
import com.hyj.hotelbackend.service.RoomService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.server.ResponseStatusException;
import org.springframework.format.annotation.DateTimeFormat;

import java.time.LocalDateTime;
import java.util.Objects;

@RestController
@RequestMapping("/api")
public class BookingController {

    @Autowired
    private BookingService bookingService;

    @Autowired
    private RoomService roomService;

    // GET /api/users/{userId}/bookings?status=&page=&size=
    @GetMapping("/users/{userId}/bookings")
    public PageResponse<Booking> userBookings(@PathVariable Long userId,
                                              @RequestParam(defaultValue = "1") long page,
                                              @RequestParam(defaultValue = "10") long size,
                                              @RequestParam(required = false) String status) {
        AuthUser me = CurrentUserHolder.get();
        if (me == null) throw new ResponseStatusException(HttpStatus.UNAUTHORIZED, "未登录");
        boolean isOwner = Objects.equals(me.getId(), userId);
        boolean isAdmin = me.getRole() != null && me.getRole().equals("ADMIN");
        if (!isOwner && !isAdmin) {
            throw new ResponseStatusException(HttpStatus.FORBIDDEN, "无权限查看他人订单");
        }
        LambdaQueryWrapper<Booking> qw = new LambdaQueryWrapper<Booking>()
                .eq(Booking::getUserId, userId)
                .orderByDesc(Booking::getStartTime);
        if (status != null && !status.isBlank()) {
            qw.eq(Booking::getStatus, status);
        }
        Page<Booking> p = bookingService.page(new Page<>(page, size), qw);
        return PageResponse.of(p.getRecords(), p.getCurrent(), p.getSize(), p.getTotal());
    }

    // PUT /api/bookings/{id}/cancel
    @PutMapping("/bookings/{id}/cancel")
    public Booking cancel(@PathVariable Long id) {
        AuthUser me = CurrentUserHolder.get();
        if (me == null) throw new ResponseStatusException(HttpStatus.UNAUTHORIZED, "未登录");
        Booking b = bookingService.getById(id);
        if (b == null) throw new ResponseStatusException(HttpStatus.NOT_FOUND, "预订不存在");
        boolean isOwner = Objects.equals(me.getId(), b.getUserId());
        boolean isAdmin = me.getRole() != null && me.getRole().equals("ADMIN");
        if (!isOwner && !isAdmin) {
            throw new ResponseStatusException(HttpStatus.FORBIDDEN, "无权取消该订单");
        }
        if ("CHECKED_IN".equals(b.getStatus()) || "CHECKED_OUT".equals(b.getStatus())) {
            throw new ResponseStatusException(HttpStatus.CONFLICT, "该状态不允许取消");
        }
        if (!"CANCELLED".equals(b.getStatus())) {
            b.setStatus("CANCELLED");
            bookingService.updateById(b);
            Room r = roomService.getById(b.getRoomId());
            if (r != null) {
                r.setAvailableCount(r.getAvailableCount() + 1);
                roomService.updateById(r);
            }
        }
        return b;
    }

    // 获取订单详情（本人或管理员）
    @GetMapping("/bookings/{id}")
    public Booking detail(@PathVariable Long id) {
        AuthUser me = CurrentUserHolder.get();
        if (me == null) throw new ResponseStatusException(HttpStatus.UNAUTHORIZED, "未登录");
        Booking b = bookingService.getById(id);
        if (b == null) throw new ResponseStatusException(HttpStatus.NOT_FOUND, "预订不存在");
        boolean isOwner = Objects.equals(me.getId(), b.getUserId());
        boolean isAdmin = me.getRole() != null && me.getRole().equals("ADMIN");
        if (!isOwner && !isAdmin) throw new ResponseStatusException(HttpStatus.FORBIDDEN, "无权限查看该订单");
        return b;
    }

    // 管理员分页筛选订单：status、userId、roomId、时间段重叠过滤
    @GetMapping("/bookings")
    public PageResponse<Booking> adminList(@RequestParam(defaultValue = "1") long page,
                                           @RequestParam(defaultValue = "10") long size,
                                           @RequestParam(required = false) String status,
                                           @RequestParam(required = false) Long userId,
                                           @RequestParam(required = false) Long roomId,
                                           @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE_TIME) LocalDateTime start,
                                           @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE_TIME) LocalDateTime end) {
        AuthUser me = CurrentUserHolder.get();
        if (me == null) throw new ResponseStatusException(HttpStatus.UNAUTHORIZED, "未登录");
        if (me.getRole() == null || !me.getRole().equals("ADMIN")) {
            throw new ResponseStatusException(HttpStatus.FORBIDDEN, "仅管理员可查看全部订单");
        }
        LambdaQueryWrapper<Booking> qw = new LambdaQueryWrapper<>();
        if (status != null && !status.isBlank()) qw.eq(Booking::getStatus, status);
        if (userId != null) qw.eq(Booking::getUserId, userId);
        if (roomId != null) qw.eq(Booking::getRoomId, roomId);
        if (start != null && end != null) {
            if (!start.isBefore(end)) throw new ResponseStatusException(HttpStatus.UNPROCESSABLE_ENTITY, "开始时间必须早于结束时间");
            qw.lt(Booking::getStartTime, end).gt(Booking::getEndTime, start);
        }
        qw.orderByDesc(Booking::getStartTime);
        Page<Booking> p = bookingService.page(new Page<>(page, size), qw);
        return PageResponse.of(p.getRecords(), p.getCurrent(), p.getSize(), p.getTotal());
    }

    // 改期（本人或管理员）：校验状态与重叠，重算金额
    @PutMapping("/bookings/{id}/reschedule")
    public Booking reschedule(@PathVariable Long id,
                              @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE_TIME) LocalDateTime start,
                              @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE_TIME) LocalDateTime end) {
        AuthUser me = CurrentUserHolder.get();
        if (me == null) throw new ResponseStatusException(HttpStatus.UNAUTHORIZED, "未登录");
        if (start == null || end == null) throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "start/end 必填");
        if (!start.isBefore(end)) throw new ResponseStatusException(HttpStatus.UNPROCESSABLE_ENTITY, "开始时间必须早于结束时间");
        Booking b = bookingService.getById(id);
        if (b == null) throw new ResponseStatusException(HttpStatus.NOT_FOUND, "预订不存在");
        boolean isOwner = Objects.equals(me.getId(), b.getUserId());
        boolean isAdmin = me.getRole() != null && me.getRole().equals("ADMIN");
        if (!isOwner && !isAdmin) throw new ResponseStatusException(HttpStatus.FORBIDDEN, "无权修改该订单");
        if ("CANCELLED".equals(b.getStatus()) || "CHECKED_OUT".equals(b.getStatus())) {
            throw new ResponseStatusException(HttpStatus.CONFLICT, "该状态不允许改期");
        }
        // 重叠校验：排除自身
        long overlapping = bookingService.count(new LambdaQueryWrapper<Booking>()
                .eq(Booking::getRoomId, b.getRoomId())
                .ne(Booking::getStatus, "CHECKED_OUT")
                .ne(Booking::getStatus, "CANCELLED")
                .ne(Booking::getId, id)
                .lt(Booking::getStartTime, end)
                .gt(Booking::getEndTime, start)
        );
        Room r = roomService.getById(b.getRoomId());
        if (r == null) throw new ResponseStatusException(HttpStatus.NOT_FOUND, "房型不存在");
        if (overlapping >= r.getTotalCount()) {
            throw new ResponseStatusException(HttpStatus.CONFLICT, "库存不足或时间段冲突");
        }
        // 更新时间与金额
        b.setStartTime(start);
        b.setEndTime(end);
        long days = java.time.Duration.between(start.toLocalDate().atStartOfDay(), end.toLocalDate().atStartOfDay()).toDays();
        if (days <= 0) days = 1;
        b.setAmount(r.getPricePerNight().multiply(java.math.BigDecimal.valueOf(days)));
        bookingService.updateById(b);
        return b;
    }

    // 管理员确认入住（与 /api/rooms/bookings/{id}/confirm 一致）
    @PutMapping("/bookings/{id}/confirm")
    public Booking confirmByAdmin(@PathVariable Long id) {
        AuthUser me = CurrentUserHolder.get();
        if (me == null || me.getRole() == null || !me.getRole().equals("ADMIN")) {
            throw new ResponseStatusException(HttpStatus.FORBIDDEN, "仅管理员可操作");
        }
        Booking b = bookingService.getById(id);
        if (b == null) throw new ResponseStatusException(HttpStatus.NOT_FOUND, "预订不存在");
        b.setStatus("CONFIRMED");
        bookingService.updateById(b);
        return b;
    }

    // 管理员退房（与 /api/rooms/bookings/{id}/checkout 一致）
    @PutMapping("/bookings/{id}/checkout")
    public Booking checkoutByAdmin(@PathVariable Long id) {
        AuthUser me = CurrentUserHolder.get();
        if (me == null || me.getRole() == null || !me.getRole().equals("ADMIN")) {
            throw new ResponseStatusException(HttpStatus.FORBIDDEN, "仅管理员可操作");
        }
        Booking b = bookingService.getById(id);
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
}
