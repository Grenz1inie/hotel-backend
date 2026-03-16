package com.hyj.hotelbackend.entity;

import com.baomidou.mybatisplus.annotation.TableField;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;

import java.math.BigDecimal;

@Data
@TableName("room_type")
public class Room {
    @TableId
    private Long id;
    private String name;
    private String type;
    @TableField("theme_color")
    private String themeColor;
    private Integer totalCount;
    private Integer availableCount;
    private BigDecimal pricePerNight;
    private String images; // comma separated URLs
    private String description;
    private String amenities;
    private BigDecimal areaSqm;
    private String bedType;
    private Integer maxGuests;
    private Integer isActive;
    private Long hotelId;
}
