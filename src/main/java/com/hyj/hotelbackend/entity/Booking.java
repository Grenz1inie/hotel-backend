package com.hyj.hotelbackend.entity;

import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;

import java.time.LocalDateTime;

@Data
@TableName("bookings")
public class Booking {
    @TableId
    private Long id;
    private Long roomId;
    private Long userId;
    private LocalDateTime startTime;
    private LocalDateTime endTime;
    private String status; // PENDING, CONFIRMED, CHECKED_OUT
    private java.math.BigDecimal amount;
}
