package com.hyj.hotelbackend.entity;

import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;

@Data
@TableName("users")
public class User {
    @TableId
    private Long id;
    private String username;
    private String password;
    private String role; // ADMIN, USER
    private Integer vipLevel; // 0 normal, 1 vip, 2 svip...
}
