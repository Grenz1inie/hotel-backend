package com.hyj.hotelbackend.entity;

import com.baomidou.mybatisplus.annotation.TableField;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;

import java.time.LocalDateTime;

@Data
@TableName("bookings")
public class Booking {
    @TableId
    private Long id;

    @TableField("hotel_id")
    private Long hotelId;

    @TableField("room_type_id")
    private Long roomTypeId;

    @TableField("room_id")
    private Long roomId;

    @TableField("user_id")
    private Long userId;

    @TableField("start_time")
    private LocalDateTime startTime;

    @TableField("end_time")
    private LocalDateTime endTime;
    private String status; // PENDING, CONFIRMED, CHECKED_OUT

    @TableField("guests")
    private Integer guests;

    @TableField("amount")
    private java.math.BigDecimal amount;

    @TableField("currency")
    private String currency;

    @TableField("contact_name")
    private String contactName;

    @TableField("contact_phone")
    private String contactPhone;

    private String remark;

    @TableField("created_at")
    private LocalDateTime createdAt;

    @TableField("updated_at")
    private LocalDateTime updatedAt;
}
