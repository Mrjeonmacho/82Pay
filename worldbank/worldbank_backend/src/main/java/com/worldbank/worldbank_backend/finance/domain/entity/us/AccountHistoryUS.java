package com.worldbank.worldbank_backend.finance.domain.entity.us;

import jakarta.persistence.*;
import lombok.AccessLevel;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;
import java.time.LocalDateTime;

@Entity
@Table(name = "account_histories_us")
@Getter
@NoArgsConstructor(access = AccessLevel.PROTECTED) // JPA용 기본 생성자
public class AccountHistoryUS {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "history_id")
    private Long historyId;

    @Column(name = "bank_id")
    private Long bankId;

    @Column(name = "user_id")
    private Long userId;

    @Enumerated(EnumType.STRING)
    @Column(name = "category")
    private Category category;

    @Column(name = "amount")
    private BigDecimal amount;

    @Column(name = "other_account_number")
    private String otherAccountNumber;

    @Column(name = "other_account_name")
    private String otherAccountName;

    @Column(name = "other_bank_code")
    private String otherBankCode;

    @Column(name = "created_at")
    private LocalDateTime createdAt;

    public enum Category {
        INPUT,
        OUTPUT
    }

    @Builder // 필요한 필드만 담은 생성자에 Builder 적용
    public AccountHistoryUS(Long bankId,
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
