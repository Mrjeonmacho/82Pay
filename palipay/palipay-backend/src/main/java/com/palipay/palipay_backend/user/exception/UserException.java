package com.palipay.palipay_backend.user.exception;

import org.springframework.http.HttpStatus;

import lombok.Getter;

@Getter
public class UserException extends RuntimeException {

    private final HttpStatus httpStatus;

    // 메시지만 받는 생성자 (기본 400 에러로 세팅)
    public UserException(String message) {
        super(message);
        this.httpStatus = HttpStatus.BAD_REQUEST;
    }

    // 상태 코드까지 세밀하게 조절하고 싶을 때 쓰는 생성자
    public UserException(String message, HttpStatus httpStatus) {
        super(message);
        this.httpStatus = httpStatus;
    }
}
