package com.worldbank.worldbank_backend.finance.domain.entity.kr;

import jakarta.persistence.*;
import lombok.*;

import java.math.BigDecimal;
import java.time.LocalDateTime;

@Entity
@Table(name = "bank_kr")
@Getter
@Builder
@AllArgsConstructor
@NoArgsConstructor(access = AccessLevel.PROTECTED)
public class BankKR {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "bank_id") // DB의 bank_id 컬럼과 매핑
    private Long bankId;

    @Column(name = "user_id")
    private Long userId;

    @Column(name = "user_name")
    private String userName;

    @Column(name = "account_number", unique = true, nullable = false)
    private String accountNumber;

    @Column(name = "amount")
    private BigDecimal amount;

    @Column(name = "bank_code")
    private String bankCode;

    @Column(name = "bank_name")
    private String bankName;

    @Column(name = "account_password")
    private String accountPassword;

    @Column(name = "created_at")
    private LocalDateTime createdAt;

    @Column(name = "updated_at")
    private LocalDateTime updatedAt;


    public void withdraw(BigDecimal money) {
        if (amount.compareTo(money) < 0) {
            throw new RuntimeException("잔액 부족");
        }
        amount = amount.subtract(money);
    }

    public void deposit(BigDecimal money) {
        amount = amount.add(money);
    }
}
