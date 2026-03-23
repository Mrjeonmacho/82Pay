package com.worldbank.worldbank_backend.user.controller;

import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import com.worldbank.worldbank_backend.user.dto.request.SignupRequest;
import com.worldbank.worldbank_backend.user.service.UserService;

import lombok.RequiredArgsConstructor;

@RestController
@RequestMapping("/api/user")
@RequiredArgsConstructor
public class UserController {

    private final UserService userService;

    @PostMapping("/signup")
    public ResponseEntity<String> signup(@RequestBody SignupRequest request) {
        userService.signUp(request);
        return ResponseEntity.ok("회원가입 성공");
    }

    @GetMapping("/check")
    public ResponseEntity<Boolean> checkDuplication(
            @RequestParam("type") String type,
            @RequestParam("value") String value) {

        boolean isDuplicate = userService.isEmailDuplicate(value);
        if (isDuplicate) {
            return ResponseEntity.status(HttpStatus.CONFLICT).body(false);
        }

        return ResponseEntity.ok(true);
    }
}
