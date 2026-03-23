package com.palipay.palipay_backend.global.security;

import lombok.RequiredArgsConstructor;

import java.io.IOException;

import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.util.StringUtils;
import org.springframework.web.filter.OncePerRequestFilter;

import com.palipay.palipay_backend.global.redis.RedisService;

import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@RequiredArgsConstructor
public class JwtAuthenticationFilter extends OncePerRequestFilter {

    private final JwtProvider jwtProvider;
    private final RedisService redisService;

    @Override
    protected void doFilterInternal(HttpServletRequest request, HttpServletResponse response, FilterChain filterChain)
            throws ServletException, IOException {

        // 1. 헤더에서 토큰 추출
        String token = resolveToken(request);

        // 2. 유효성 검사
        if (StringUtils.hasText(token) && jwtProvider.validateToken(token)) {

            // 2-1 레디스 블랙리스트 체크
            String isLogout = redisService.getData(token);

            if (isLogout == null) {

                // 3. 토큰에서 userId 추출
                Long userId = jwtProvider.getUserId(token);

                // 4. SecurityContext에 인증 정보 저장
                UsernamePasswordAuthenticationToken authentication = new UsernamePasswordAuthenticationToken(userId,
                        null, null);
                SecurityContextHolder.getContext().setAuthentication(authentication);
            }
        }
        // 5. 다음 필터로 진행
        filterChain.doFilter(request, response);
    }

    // 헤더에서 "Bearer "를 제거하고 토큰값만 가져오는 메서드
    private String resolveToken(HttpServletRequest request) {
        String bearerToken = request.getHeader("Authorization");
        if (StringUtils.hasText(bearerToken) && bearerToken.startsWith("Bearer ")) {
            return bearerToken.substring(7);
        }
        return null;
    }
}
