package com.palipay.palipay_backend.global.config;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.config.Customizer;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.web.SecurityFilterChain;

@Configuration
public class SecurityConfig {

    @Bean
    public BCryptPasswordEncoder passwordEncoder() {
        return new BCryptPasswordEncoder();
    }

    @Bean
    public SecurityFilterChain securityFilterChain(HttpSecurity http) throws Exception {
        http
                .csrf(csrf -> csrf.disable())
                // FIXME security 비로그인 상태로 설정
                // .authorizeHttpRequests(auth -> auth
                // .requestMatchers(
                // "/swagger-ui.html",
                // "/swagger-ui/**",
                // "/v3/api-docs/**"
                // ).permitAll()
                // .anyRequest().authenticated()
                // )
                // .httpBasic(Customizer.withDefaults());
                .headers(headers -> headers
                        .frameOptions(frame -> frame.sameOrigin()) // 이 줄이 없으면 브라우저에서 화면이 거부됨!
                )
                .authorizeHttpRequests(auth -> auth
                        .anyRequest().permitAll())
                .formLogin(form -> form.disable());

        return http.build();
    }
}
