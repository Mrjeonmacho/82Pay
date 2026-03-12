package com.palipay.palipay_backend.finance.domain;

import jakarta.persistence.*;
import lombok.*;

import java.math.BigDecimal;
import java.time.LocalDateTime;

@Entity
@Table(name = "account_histories")
@Getter
@NoArgsConstructor(access = AccessLevel.PROTECTED)
@AllArgsConstructor
@Builder
@ToString
public class AccountHistory {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "history_id")
    private Long historyId;

    @Column(name = "wallet_id", nullable = false)
    private Long walletId;

    @Column(name = "user_id", nullable = false)
    private Long userId;

    @Column(name = "workplace_id", nullable = false)
    private Long workplaceId;

    @Enumerated(EnumType.STRING)
    @Column(name = "category")
    private TransactionCategory category;

    @Column(name = "amount", precision = 16, scale = 4)
    private BigDecimal amount;

    @Column(name = "exchange_after_amount")
    private BigDecimal exchangeAfterAmount;

    @Column(name = "exchange_rate", precision = 10, scale = 4)
    private BigDecimal exchangeRate;

    @Column(name = "other_account_number", length = 30)
    private String otherAccountNumber;

    @Column(name = "other_account_name", length = 30)
    private String otherAccountName;

    @Column(name = "other_bank_code", length = 30)
    private String otherBankCode;

    @Column(name = "description", columnDefinition = "TEXT")
    private String description;

    @Column(name = "created_at")
    private LocalDateTime createdAt;

    //FIXME 주의 BankCode는 String으로 변환하고 있다
    public static AccountHistory createAccountHistory(
            Long userId,
            WalletPali wallet,
            Long workplaceId,
            TransactionCategory category,
            BigDecimal amount,
            String description,
            String otherAccountNumber,
            String otherAccountName,
            String otherBankCode
    ){
        return AccountHistory.builder()
                .walletId(wallet.getWalletId())
                .userId(userId)
                .workplaceId(workplaceId)
                .category(category)
                .amount(amount)
                .exchangeAfterAmount(wallet.getAmount())
                .exchangeRate(null)
                .otherAccountNumber(otherAccountNumber)
                .otherAccountName(otherAccountName)
                .otherBankCode(otherBankCode)
                .description(description)
                .createdAt(LocalDateTime.now())
                .build();
    }
}