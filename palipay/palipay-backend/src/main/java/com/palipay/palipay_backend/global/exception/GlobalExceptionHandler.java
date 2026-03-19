package com.palipay.palipay_backend.global.exception;

import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RestControllerAdvice;

import com.palipay.palipay_backend.user.exception.UserException;

@RestControllerAdvice
public class GlobalExceptionHandler {

    // 우리가 만든 UserException 처리
    @ExceptionHandler(UserException.class)
    public ResponseEntity<ErrorResponse> handleUserException(UserException e) {
        // 기본적으로 400(Bad Request)으로 통일해서 던집니다.
        return ResponseEntity
                .status(HttpStatus.BAD_REQUEST)
                .body(ErrorResponse.of(HttpStatus.BAD_REQUEST, e.getMessage()));
    }

}
