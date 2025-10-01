package com.hyj.hotelbackend.controller;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.hyj.hotelbackend.auth.AuthUser;
import com.hyj.hotelbackend.auth.CurrentUserHolder;
import com.hyj.hotelbackend.entity.User;
import com.hyj.hotelbackend.mapper.UserMapper;
import lombok.Data;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.util.StringUtils;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.server.ResponseStatusException;

import java.util.Map;

@RestController
@RequestMapping("/api/users/me")
public class UserProfileController {

    @Autowired
    private UserMapper userMapper;

    @GetMapping("/profile")
    public Map<String, Object> profile() {
        AuthUser me = CurrentUserHolder.get();
        if (me == null) {
            throw new ResponseStatusException(HttpStatus.UNAUTHORIZED, "未登录");
        }
        User user = userMapper.selectById(me.getId());
        if (user == null) {
            throw new ResponseStatusException(HttpStatus.NOT_FOUND, "用户不存在");
        }
        return Map.of(
                "id", user.getId(),
                "username", user.getUsername(),
                "phone", user.getPhone(),
                "email", user.getEmail(),
                "role", user.getRole(),
                "vipLevel", user.getVipLevel(),
                "status", user.getStatus(),
                "createdAt", user.getCreatedAt(),
                "updatedAt", user.getUpdatedAt()
        );
    }

    @PutMapping("/profile")
    public Map<String, Object> update(@RequestBody UpdateProfileRequest request) {
        AuthUser me = CurrentUserHolder.get();
        if (me == null) {
            throw new ResponseStatusException(HttpStatus.UNAUTHORIZED, "未登录");
        }
        if (request == null) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "请求体不能为空");
        }
        User user = userMapper.selectById(me.getId());
        if (user == null) {
            throw new ResponseStatusException(HttpStatus.NOT_FOUND, "用户不存在");
        }
        String username = normalize(request.getUsername());
        String phone = normalize(request.getPhone());
        String email = normalize(request.getEmail());
        if (username != null) {
            if (username.length() < 3) {
                throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "用户名至少 3 个字符");
            }
            User existed = userMapper.selectOne(new LambdaQueryWrapper<User>()
                    .eq(User::getUsername, username)
                    .ne(User::getId, user.getId()));
            if (existed != null) {
                throw new ResponseStatusException(HttpStatus.CONFLICT, "用户名已被占用");
            }
            user.setUsername(username);
        }
        if (phone != null) {
            if (phone.length() < 3 || phone.length() > 20) {
                throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "联系电话长度需在 3-20 位之间");
            }
            User existedPhone = userMapper.selectOne(new LambdaQueryWrapper<User>()
                    .eq(User::getPhone, phone)
                    .ne(User::getId, user.getId()));
            if (existedPhone != null) {
                throw new ResponseStatusException(HttpStatus.CONFLICT, "联系电话已被占用");
            }
            user.setPhone(phone);
        }
        if (StringUtils.hasText(email)) {
            User existedEmail = userMapper.selectOne(new LambdaQueryWrapper<User>()
                    .eq(User::getEmail, email)
                    .ne(User::getId, user.getId()));
            if (existedEmail != null) {
                throw new ResponseStatusException(HttpStatus.CONFLICT, "邮箱已被占用");
            }
            user.setEmail(email);
        } else {
            user.setEmail(null);
        }
        userMapper.updateById(user);
        return Map.of(
                "id", user.getId(),
                "username", user.getUsername(),
                "phone", user.getPhone(),
                "email", user.getEmail(),
                "role", user.getRole(),
                "vipLevel", user.getVipLevel(),
                "status", user.getStatus(),
                "createdAt", user.getCreatedAt(),
                "updatedAt", user.getUpdatedAt()
        );
    }

    private String normalize(String value) {
        if (!StringUtils.hasText(value)) {
            return null;
        }
        return value.trim();
    }

    @Data
    public static class UpdateProfileRequest {
        private String username;
        private String phone;
        private String email;
    }
}
