package com.palipay.palipay_backend.finance.domain;

import ch.qos.logback.core.util.Loader;
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

    public void debit(BigDecimal amount){
        validateAmount(amount);

        //TODO 예외 처리
        //감소할 amount가 현재 amount보다 큰 경우
        //출금 불가 상황
        if(this.amount.compareTo(amount) < 0){
            throw new IllegalArgumentException("출금 불가 상황");
        }

        this.amount = this.amount.subtract(amount);
        this.updatedAt = LocalDateTime.now();
    }

    public void credit(BigDecimal amount){
        validateAmount(amount);

        this.amount = this.amount.add(amount);
        this.updatedAt = LocalDateTime.now();
    }

    public void validateAmount(BigDecimal amount){
        //TODO 예외 처리
        //amount value가 null, 음수 인 경우
        if(amount == null || amount.compareTo(BigDecimal.ZERO) <= 0){
            throw new IllegalArgumentException("amount value가 null, 음수 인 경우");
        }
        if(this.amount == null){
            this.amount = BigDecimal.ZERO;
        }
    }

    public boolean isOwnedBy(Long userId){
        return this.userId.equals(userId);
    }

    public boolean matchesPin(String pinNumber){
        return this.pinNumber != null && this.pinNumber.equals(pinNumber);
    }

    public void updateAccount(
            String bankCode,
            String accountNumber,
            String accountUsername,
            String moneyCode
    ) {
        this.bankCode = bankCode;
        this.accountNumber = accountNumber;
        this.accountUsername = accountUsername;
        this.moneyCode = moneyCode;
        this.updatedAt = LocalDateTime.now();
    }

    public void updatePin(
            String pinNumber
    ){
        this.pinNumber = pinNumber;
        this.updatedAt = LocalDateTime.now();
    }

    @PrePersist
    public void prePersist() {
        this.createdAt = LocalDateTime.now();
        this.updatedAt = LocalDateTime.now();

        if (this.amount == null) {
            this.amount = BigDecimal.ZERO;
        }
    }

    @PreUpdate
    public void preUpdate() {
        this.updatedAt = LocalDateTime.now();
    }
}