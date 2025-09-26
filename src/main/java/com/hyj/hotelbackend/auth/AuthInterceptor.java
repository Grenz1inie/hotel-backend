package com.hyj.hotelbackend.auth;

import com.hyj.hotelbackend.common.ApiExceptions;
import io.jsonwebtoken.Claims;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.springframework.http.HttpMethod;
import org.springframework.stereotype.Component;
import org.springframework.web.servlet.HandlerInterceptor;

@Component
public class AuthInterceptor implements HandlerInterceptor {

    private final JwtUtil jwtUtil;

    public AuthInterceptor(JwtUtil jwtUtil) {
        this.jwtUtil = jwtUtil;
    }

    @Override
    public boolean preHandle(HttpServletRequest request, HttpServletResponse response, Object handler) {
        String path = request.getRequestURI();
        // Public endpoints
        if (path.startsWith("/api/auth/login") || path.startsWith("/api/health")) {
            return true;
        }
        // Allow preflight
        if (HttpMethod.OPTIONS.matches(request.getMethod())) {
            return true;
        }
        String auth = request.getHeader("Authorization");
        if (auth == null || !auth.startsWith("Bearer ")) {
            throw new ApiExceptions.Unauthorized("缺少或非法的 Authorization 头");
        }
        String token = auth.substring(7);
        try {
            Claims claims = jwtUtil.parse(token);
            Long userId = Long.valueOf(claims.getSubject());
            String username = (String) claims.get("username");
            String role = (String) claims.get("role");
            Integer vipLevel = claims.get("vipLevel", Integer.class);
            CurrentUserHolder.set(new AuthUser(userId, username, role, vipLevel));
            return true;
        } catch (Exception e) {
            throw new ApiExceptions.Unauthorized("Token 无效或已过期");
        }
    }

    @Override
    public void afterCompletion(HttpServletRequest request, HttpServletResponse response, Object handler, Exception ex) {
        CurrentUserHolder.clear();
    }
}

