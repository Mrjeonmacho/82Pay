package com.worldbank.worldbank_backend.finance.domain.router;

import com.worldbank.worldbank_backend.finance.domain.strategy.BankStrategy;
import org.springframework.stereotype.Component;

import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@Component
public class BankRouter {
    private final Map<String, BankStrategy> strategyMap;

    public BankRouter(List<BankStrategy> strategies) {

        strategyMap = strategies.stream()
                .collect(Collectors.toMap(
                        BankStrategy::getBankCurrency,
                        s -> s
                ));
    }

    public BankStrategy route(String bankCurrency) {

        BankStrategy strategy = strategyMap.get(bankCurrency);

        if(strategy == null){
            throw new RuntimeException("지원하지 않는 은행");
        }

        return strategy;
    }
}