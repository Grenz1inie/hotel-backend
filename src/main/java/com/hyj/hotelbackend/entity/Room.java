package com.hyj.hotelbackend.entity;

import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;

import java.math.BigDecimal;

@Data
@TableName("rooms")
public class Room {
    @TableId
    private Long id;
    private String name;
    private String type;
    private Integer totalCount;
    private Integer availableCount;
    private BigDecimal pricePerNight;
    private String images; // comma separated URLs
    private String description;
}
