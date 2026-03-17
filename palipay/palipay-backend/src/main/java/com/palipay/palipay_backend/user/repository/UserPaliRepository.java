package com.palipay.palipay_backend.user.repository;

import com.palipay.palipay_backend.user.domain.UserPali;
import com.palipay.palipay_backend.user.domain.UserStatus;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;

public interface UserPaliRepository extends JpaRepository<UserPali, Long> {

    // 회원가입 시 이메일 중복 확인
    boolean existsByEmail(String email);

    // 로그인 시 사용자 찾기
    Optional<UserPali> findByEmail(String email);

    // 활동 중인 유저 인지 확인
    List<UserPali> findByStatus(UserStatus status);

}
