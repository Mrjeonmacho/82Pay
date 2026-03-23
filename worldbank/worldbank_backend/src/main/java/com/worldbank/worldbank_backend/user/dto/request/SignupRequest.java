package com.worldbank.worldbank_backend.user.dto.request;

import lombok.*;

@Getter
@Setter
@Builder
@AllArgsConstructor
@NoArgsConstructor
public class SignupRequest {
    private String email;
    private String password;
    private String countryCode;

    // 2. 계좌 생성을 위한 정보
    private String name;
    private String bankCode;
    private String bankName;
    private String accountPassword;
}
