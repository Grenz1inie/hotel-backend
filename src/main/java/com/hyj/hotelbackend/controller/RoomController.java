package com.hyj.hotelbackend.controller;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.hyj.hotelbackend.auth.AuthUser;
import com.hyj.hotelbackend.auth.CurrentUserHolder;
import com.hyj.hotelbackend.entity.Booking;
import com.hyj.hotelbackend.entity.Room;
import com.hyj.hotelbackend.service.BookingService;
import com.hyj.hotelbackend.service.RoomService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.server.ResponseStatusException;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Map;
import java.util.Objects;

@RestController
@RequestMapping("/api/rooms")
public class RoomController {

    @Autowired
    private RoomService roomService;

    @Autowired
    private BookingService bookingService;

    @GetMapping
    public List<Room> list() {
        return roomService.list();
    }

    @GetMapping("/{id}")
    public Room get(@PathVariable Long id) {
        Room r = roomService.getById(id);
        if (r == null) throw new ResponseStatusException(HttpStatus.NOT_FOUND, "房型不存在");
        return r;
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
        r.setAvailableCount(totalCount); // naive
        roomService.updateById(r);
        return r;
    }

    // create booking (user must be authenticated)
    @PostMapping("/{id}/book")
    public Booking book(@PathVariable Long id,
                        @RequestParam(required = false) Long userId,
                        @RequestParam(required = false) Long hotelId,
                        @RequestParam(required = false) Integer guests,
                        @RequestParam(required = false) String contactName,
                        @RequestParam(required = false) String contactPhone,
                        @RequestParam(required = false) String remark,
                        @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE_TIME) LocalDateTime start,
                        @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE_TIME) LocalDateTime end) {
        AuthUser me = CurrentUserHolder.get();
        if (me == null) throw new ResponseStatusException(HttpStatus.UNAUTHORIZED, "未登录");
        Long actualUserId = me.getId();
        if (userId != null && !Objects.equals(userId, me.getId())) {
            if (me.getRole() != null && me.getRole().equals("ADMIN")) {
                actualUserId = userId; // admin can book for others
            } else {
                throw new ResponseStatusException(HttpStatus.FORBIDDEN, "不能为他人创建预订");
            }
        }
        if (start == null || end == null) throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "start/end 必填");
        if (!start.isBefore(end)) throw new ResponseStatusException(HttpStatus.UNPROCESSABLE_ENTITY, "开始时间必须早于结束时间");
        Room r = roomService.getById(id);
        if (r == null) throw new ResponseStatusException(HttpStatus.NOT_FOUND, "房型不存在");
        Long resolvedHotelId = r.getHotelId();
        if (hotelId != null && resolvedHotelId != null && !Objects.equals(hotelId, resolvedHotelId)) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "酒店信息不匹配");
        }
        if (resolvedHotelId == null) {
            resolvedHotelId = hotelId;
        }
        if (resolvedHotelId == null) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "无法确定酒店信息");
        }
        // check inventory by overlapping bookings
        long overlapping = bookingService.count(new LambdaQueryWrapper<Booking>()
                .eq(Booking::getRoomId, id)
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
        Booking b = new Booking();
        b.setHotelId(resolvedHotelId);
        b.setRoomTypeId(r.getId());
        b.setRoomId(id);
        b.setUserId(actualUserId);
        b.setStartTime(start);
        b.setEndTime(end);
        b.setStatus("PENDING");
        int guestCount = guests != null && guests > 0 ? guests : 1;
        b.setGuests(guestCount);
        long days = java.time.Duration.between(start.toLocalDate().atStartOfDay(), end.toLocalDate().atStartOfDay()).toDays();
        if (days <= 0) days = 1;
        b.setAmount(r.getPricePerNight().multiply(java.math.BigDecimal.valueOf(days)));
        b.setCurrency("CNY");
        if (contactName != null) {
            b.setContactName(contactName.trim());
        }
        if (contactPhone != null) {
            b.setContactPhone(contactPhone.trim());
        }
        if (remark != null) {
            b.setRemark(remark.trim());
        }
        bookingService.save(b);
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
}
