package com.worldbank.worldbank_backend.user.entity.jp;

import jakarta.persistence.*;
import lombok.*;
import java.time.LocalDateTime;

import com.worldbank.worldbank_backend.user.entity.BaseUser;
import com.worldbank.worldbank_backend.user.entity.UserStatus;

@Entity
@Table(name = "user_bank_jp")
@Getter
@Builder
@AllArgsConstructor
@NoArgsConstructor(access = AccessLevel.PROTECTED)
public class UserBankJP implements BaseUser {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "user_id")
    private Long userId;

    @Column(unique = true, nullable = false)
    private String email;

    @Column(nullable = false)
    private String password;

    @Enumerated(EnumType.STRING)
    private UserStatus status; // ACTIVE, INACTIVE 등의 Enum

    @Column
    private String currency;

    @Column(name = "created_at")
    private LocalDateTime createdAt;

    @Column(name = "updated_at")
    private LocalDateTime updatedAt;

    @PrePersist
    public void prePersist() {
        this.status = UserStatus.ACTIVE; // 기본값 설정
        this.createdAt = LocalDateTime.now();
        this.updatedAt = LocalDateTime.now();
    }
}
