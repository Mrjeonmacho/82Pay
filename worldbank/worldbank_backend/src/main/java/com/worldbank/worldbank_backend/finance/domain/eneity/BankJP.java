package com.worldbank.worldbank_backend.finance.domain.eneity;

import jakarta.persistence.*;
import lombok.Getter;

import java.math.BigDecimal;

@Entity
@Table(name = "bank_jp")
@Getter
public class BankJP {

    @Id
    private Long bankId;

    private Long userId;

    private String accountNumber;

    private BigDecimal amount;

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