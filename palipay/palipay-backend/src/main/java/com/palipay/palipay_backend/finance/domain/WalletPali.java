package com.palipay.palipay_backend.finance.domain;

import jakarta.persistence.*;
import lombok.*;

import java.math.BigDecimal;
import java.time.LocalDateTime;

@Entity
@Table(name = "wallet_pali")
@Getter
@NoArgsConstructor(access = AccessLevel.PROTECTED)
@AllArgsConstructor
@Builder
@ToString
public class WalletPali {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "wallet_id")
    private Long walletId;

    @Column(name = "user_id", nullable = false)
    private Long userId;

    @Column(name = "account_number", length = 30)
    private String accountNumber;

    @Column(name = "money_code", length = 20)
    private String moneyCode;

    @Column(name = "account_username", length = 30)
    private String accountUsername;

    @Column(name = "bank_code", length = 20)
    private String bankCode;

    @Column(name = "amount", precision = 16, scale = 4)
    private BigDecimal amount;

    @Column(name = "pin_number", length = 30)
    private String pinNumber;

    @Column(name = "created_at")
    private LocalDateTime createdAt;

    @Column(name = "updated_at")
    private LocalDateTime updatedAt;
}