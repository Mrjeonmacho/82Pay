package com.worldbank.worldbank_backend.finance.domain.entity;

import com.worldbank.worldbank_backend.finance.domain.enums.JPBankCode;
import jakarta.persistence.*;
import lombok.*;

import java.math.BigDecimal;

@Entity
@Table(name = "bank_jp")
@Getter
@Builder
@AllArgsConstructor
@NoArgsConstructor(access = AccessLevel.PROTECTED)
public class BankJP {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long bankId;

//    @OneToOne
//    @JoinColumn(name = "user_id")
//    private UserBankJP userId;

    private Long userId;

    private String userName;

    private String accountNumber;

    private BigDecimal amount;

    @Enumerated(EnumType.STRING)
    private JPBankCode bankCode;

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