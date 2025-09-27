package com.hyj.hotelbackend.auth;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.springframework.http.HttpMethod;
import org.springframework.http.HttpStatus;
import org.springframework.lang.NonNull;
import org.springframework.lang.Nullable;
import org.springframework.stereotype.Component;
import org.springframework.web.server.ResponseStatusException;
import org.springframework.web.servlet.HandlerInterceptor;

@Component
public class AuthInterceptor implements HandlerInterceptor {

    private final JwtUtil jwtUtil;

    public AuthInterceptor(JwtUtil jwtUtil) {
        this.jwtUtil = jwtUtil;
    }

    @Override
    public boolean preHandle(@NonNull HttpServletRequest request, @NonNull HttpServletResponse response,
                             @NonNull Object handler) {
        String path = request.getRequestURI();
        // Public endpoints
        if (path.startsWith("/api/auth/login") || path.startsWith("/api/health")) {
            return true;
        }
        // Allow public browsing of rooms related resources
        if (HttpMethod.GET.matches(request.getMethod()) && (path.startsWith("/api/rooms") || path.startsWith("/api/hotel"))) {
            return true;
        }
        // Allow preflight
        if (HttpMethod.OPTIONS.matches(request.getMethod())) {
            return true;
        }
        String auth = request.getHeader("Authorization");
        if (auth == null || !auth.startsWith("Bearer ")) {
            throw new ResponseStatusException(HttpStatus.UNAUTHORIZED, "缺少或非法的 Authorization 头");
        }
        String token = auth.substring(7);
        try {
            JwtUtil.JwtPayload payload = jwtUtil.parse(token);
            Long userId = Long.valueOf(payload.sub);
            String username = payload.username;
            String role = payload.role;
            Integer vipLevel = payload.vipLevel;
            CurrentUserHolder.set(new AuthUser(userId, username, role, vipLevel));
            return true;
        } catch (Exception e) {
            throw new ResponseStatusException(HttpStatus.UNAUTHORIZED, "Token 无效或已过期");
        }
    }

    @Override
    public void afterCompletion(@NonNull HttpServletRequest request, @NonNull HttpServletResponse response,
                                @NonNull Object handler, @Nullable Exception ex) {
        CurrentUserHolder.clear();
    }
}
