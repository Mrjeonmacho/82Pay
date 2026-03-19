package com.palipay.palipay_backend.user.infrastructure.redis;

import com.palipay.palipay_backend.user.domain.RefreshToken;
import org.springframework.data.repository.CrudRepository;

public interface RefreshTokenRepository extends CrudRepository<RefreshToken, Long> {

}
