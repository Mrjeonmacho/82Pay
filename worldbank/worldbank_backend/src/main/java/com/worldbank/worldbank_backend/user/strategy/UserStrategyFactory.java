package com.worldbank.worldbank_backend.user.strategy;

import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

import org.springframework.stereotype.Component;

@Component
public class UserStrategyFactory {
    private final Map<String, UserStrategy> strategies;

    // 스프링이 UserStrategy를 구현한 모든 빈을 Map에 담아줍니다.
    public UserStrategyFactory(List<UserStrategy> strategyList) {
        this.strategies = strategyList.stream()
                .collect(Collectors.toMap(UserStrategy::getCountryCode, s -> s));
    }

    public UserStrategy getStrategy(String countryCode) {
        UserStrategy strategy = strategies.get(countryCode.toUpperCase());
        if (strategy == null)
            throw new RuntimeException("지원하지 않는 국가");
        return strategy;
    }
}