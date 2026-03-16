package com.worldbank.worldbank_backend.finance.domain.entity.kr;

import jakarta.persistence.*;
import lombok.*;

import java.time.LocalDateTime;

@Entity
@Table(name = "business") // DB 테이블명 명시
@Getter
@Builder
@AllArgsConstructor
@NoArgsConstructor(access = AccessLevel.PROTECTED)
public class Business {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "business_id")
    private Long businessId;

    @OneToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(
            name = "account_number",           // 내 테이블(business)에 생길 컬럼명
            referencedColumnName = "account_number" // 참조할 상대 테이블(bank_kr)의 컬럼명
    )// DB 테이블의 FK 컬럼명 (BankKR의 PK인 bank_id와 매핑)
    private BankKR account;       // 실제 객체 참조

    @Column(name = "business_person", nullable = false)
    private String businessPerson;

    @Column(name = "business_number", unique = true, nullable = false)
    private String businessNumber;


    @Column(name = "company_name")
    private String companyName;

    @Column(name = "business_address")
    private String businessAddress; // 사업장 주소

    @Column(name = "created_at")
    private LocalDateTime createdAt;

    @Column(name = "updated_at")
    private LocalDateTime updatedAt;

    // 비즈니스 로직: 정보 수정
    public void updateInfo(String businessPerson, String businessAddress) {
        this.businessPerson = businessPerson;
        this.businessAddress = businessAddress;
        this.updatedAt = LocalDateTime.now();
    }

    // 엔티티가 처음 저장될 때 시간 자동 설정 (Auditing을 사용하지 않을 경우)
    @PrePersist
    public void prePersist() {
        this.createdAt = LocalDateTime.now();
        this.updatedAt = LocalDateTime.now();
    }
}