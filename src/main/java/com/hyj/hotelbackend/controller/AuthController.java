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
import org.springframework.util.StringUtils;
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
        if (req == null || !StringUtils.hasText(req.getUsername()) || !StringUtils.hasText(req.getPassword())) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "账号和密码必填");
        }
        String credential = req.getUsername().trim();
        String password = req.getPassword();
        User u = userMapper.selectOne(new LambdaQueryWrapper<User>()
                .eq(User::getPassword, password)
                .and(wrapper -> wrapper
                        .eq(User::getUsername, credential)
                        .or()
                        .eq(User::getPhone, credential)
                        .or()
                        .eq(User::getEmail, credential)));
        if (u == null) {
            throw new ResponseStatusException(HttpStatus.UNAUTHORIZED, "账号或密码错误");
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

    @PostMapping("/register")
    public Map<String, Object> register(@RequestBody RegisterRequest req) {
        if (req == null || !StringUtils.hasText(req.getUsername()) || !StringUtils.hasText(req.getPassword())) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "用户名和密码必填");
        }
        String username = req.getUsername().trim();
        if (username.length() < 3) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "用户名至少 3 个字符");
        }
        if (req.getPassword().length() < 6) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "密码至少 6 位");
        }
        if (req.getConfirmPassword() != null && !req.getPassword().equals(req.getConfirmPassword())) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "两次输入的密码不一致");
        }
        if (!StringUtils.hasText(req.getPhone())) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "联系电话必填");
        }
        String phone = req.getPhone().trim();
        if (phone.length() < 3 || phone.length() > 20) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "联系电话长度需在 3-20 位之间");
        }
        User existed = userMapper.selectOne(new LambdaQueryWrapper<User>().eq(User::getUsername, username));
        if (existed != null) {
            throw new ResponseStatusException(HttpStatus.CONFLICT, "用户名已存在");
        }
        User existedPhone = userMapper.selectOne(new LambdaQueryWrapper<User>().eq(User::getPhone, phone));
        if (existedPhone != null) {
            throw new ResponseStatusException(HttpStatus.CONFLICT, "该联系电话已注册");
        }
        String email = null;
        if (StringUtils.hasText(req.getEmail())) {
            email = req.getEmail().trim();
            User existedEmail = userMapper.selectOne(new LambdaQueryWrapper<User>().eq(User::getEmail, email));
            if (existedEmail != null) {
                throw new ResponseStatusException(HttpStatus.CONFLICT, "该邮箱已注册");
            }
        }
        User u = new User();
        u.setUsername(username);
        u.setPassword(req.getPassword());
        u.setRole("USER");
        u.setVipLevel(0);
        u.setPhone(phone);
        if (email != null) {
            u.setEmail(email);
        }
        u.setStatus("ACTIVE");
        userMapper.insert(u);
        if (u.getId() == null) {
            throw new ResponseStatusException(HttpStatus.INTERNAL_SERVER_ERROR, "注册失败，请稍后再试");
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

    @Data
    public static class RegisterRequest {
        private String username;
        private String password;
        private String confirmPassword;
        private String phone;
        private String email;
    }
}
