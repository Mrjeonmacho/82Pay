package com.palipay.palipay_backend.global.config;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.client.RestClient;

@Configuration
public class ExternalFinanceClientConfig {

    @Bean
    public RestClient externalFinanceRestClient(
            @Value("${external.finance.base-url:http://localhost}") String baseUrl
    ) {
        return RestClient.builder()
                .baseUrl(baseUrl)
                .build();
    }
}