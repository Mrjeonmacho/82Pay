package com.worldbank.worldbank_backend.finance.domain.entity;

import jakarta.persistence.*;
import lombok.AccessLevel;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;
import java.time.LocalDateTime;

@Entity
@Table(name = "account_histories_jp")
@Getter
@NoArgsConstructor(access = AccessLevel.PROTECTED) // JPA용 기본 생성자
public class AccountHistoryJP {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long historyId;

    private Long bankId;
    private Long userId;

    @Enumerated(EnumType.STRING)
    private Category category;

    private BigDecimal amount;

    private String otherAccountNumber;

    private String otherAccountName;

    private String otherBankCode;

    private LocalDateTime createdAt;

    public enum Category {
        INPUT,
        OUTPUT
    }

    @Builder // 필요한 필드만 담은 생성자에 Builder 적용
    public AccountHistoryJP(Long bankId,
                            Long userId,
                            Category category,
                            BigDecimal amount, String otherAccountNumber,
                            String otherAccountName, String otherBankCode) {
        this.bankId = bankId;
        this.userId = userId;
        this.category = category;
        this.amount = amount;
        this.otherAccountNumber = otherAccountNumber;
        this.otherAccountName = otherAccountName;
        this.otherBankCode = otherBankCode;
        this.createdAt = LocalDateTime.now(); // 생성 시점에 자동 설정
    }
}
