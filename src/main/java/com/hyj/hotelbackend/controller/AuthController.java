package com.hyj.hotelbackend.controller;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.hyj.hotelbackend.auth.AuthUser;
import com.hyj.hotelbackend.auth.CurrentUserHolder;
import com.hyj.hotelbackend.auth.JwtUtil;
import com.hyj.hotelbackend.entity.User;
import com.hyj.hotelbackend.mapper.UserMapper;
import lombok.Data;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.server.ResponseStatusException;

import java.util.Map;

@RestController
@RequestMapping("/api/auth")
public class AuthController {

    @Autowired
    private UserMapper userMapper;

    @Autowired
    private JwtUtil jwtUtil;

    @PostMapping("/login")
    public Map<String, Object> login(@RequestBody LoginRequest req) {
        if (req == null || req.getUsername() == null || req.getPassword() == null) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "用户名和密码必填");
        }
        User u = userMapper.selectOne(new LambdaQueryWrapper<User>()
                .eq(User::getUsername, req.getUsername())
                .eq(User::getPassword, req.getPassword()));
        if (u == null) {
            throw new ResponseStatusException(HttpStatus.UNAUTHORIZED, "用户名或密码错误");
        }
        String token = jwtUtil.generateToken(u.getId(), u.getUsername(), u.getRole(), u.getVipLevel());
        return Map.of(
                "token", token,
                "user", Map.of(
                        "id", u.getId(),
                        "username", u.getUsername(),
                        "role", u.getRole(),
                        "vipLevel", u.getVipLevel()
                )
        );
    }

    @GetMapping("/me")
    public AuthUser me() {
        AuthUser u = CurrentUserHolder.get();
        if (u == null) throw new ResponseStatusException(HttpStatus.UNAUTHORIZED, "未登录");
        return u;
    }

    @Data
    public static class LoginRequest {
        private String username;
        private String password;
    }
}
