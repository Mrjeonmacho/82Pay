package com.palipay.palipay_backend.user.repository;

import com.palipay.palipay_backend.user.domain.UserPali;
import com.palipay.palipay_backend.user.domain.UserStatus;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;

public interface UserPaliRepository extends JpaRepository<UserPali, Long> {

    Optional<UserPali> findByEmail(String email);

    List<UserPali> findByStatus(UserStatus status);

    boolean existsByEmail(String email);
}