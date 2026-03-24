package com.palipay.palipay_backend.external.service;

import com.palipay.palipay_backend.external.dto.ExchangeRateCacheDto;
import com.palipay.palipay_backend.external.dto.response.ExchangeQuoteResponse;
import com.palipay.palipay_backend.global.redis.RedisService;
import lombok.RequiredArgsConstructor;
import org.springframework.data.redis.core.StringRedisTemplate;
import org.springframework.stereotype.Service;

import java.math.BigDecimal;
import java.time.Duration;
import java.time.LocalDateTime;
import java.time.ZoneOffset;
import java.time.format.DateTimeFormatter;
import java.util.Map;

@Service
@RequiredArgsConstructor
public class ExchangeRateRedisService {
    private static final String FX_KEY_PREFIX = "fx:";

    private final StringRedisTemplate redisTemplate;

    public ExchangeQuoteResponse createExchangeQuote(String currency) {
        validateCurrency(currency);

        ExchangeRateCacheDto exchangeRate = getExchangeRate(currency+"KRW");

        return new ExchangeQuoteResponse(
                "환율 견적이 생성되었습니다.",
                new ExchangeQuoteResponse.Data(
                        exchangeRate.rate(),
                        exchangeRate.fetchedAt().atOffset(ZoneOffset.ofHours(9)).toLocalDateTime()
                )
        );
    }

    public ExchangeRateCacheDto getUsdKrwRate() {
        return getExchangeRate("USDKRW");
    }

    public ExchangeRateCacheDto getJpyKrwRate() {
        return getExchangeRate("JPYKRW");
    }

    public ExchangeRateCacheDto getCnyKrwRate() {
        return getExchangeRate("CNYKRW");
    }
    public ExchangeRateCacheDto getExchangeRate(String currencyPair) {

        /// //////////////////////////////////////////////////////////////////////
        // FIXME 하드 코딩 삭제하기
        //setExchangeRate();
        /// /////////////////////////////////////////////////////////////////////

        String key = FX_KEY_PREFIX + currencyPair;

        Map<Object, Object> values = redisTemplate.opsForHash().entries(key);

        if (values == null || values.isEmpty()) {
            throw new IllegalArgumentException("Redis에 환율 정보가 없습니다. key=" + key);
        }

        String date = (String) values.get("date");
        String rateValue = (String) values.get("rate");
        String fetchedAtValue = (String) values.get("fetched_at");

        if (rateValue == null) {
            throw new IllegalArgumentException("환율(rate) 값이 없습니다. key=" + key);
        }

        if (fetchedAtValue == null) {
            throw new IllegalArgumentException("fetched_at 값이 없습니다. key=" + key);
        }

        return new ExchangeRateCacheDto(
                currencyPair,
                date,
                new BigDecimal(rateValue),
                LocalDateTime.parse(fetchedAtValue.replace(" ", "T"))
        );
    }

    public void setExchangeRate(){
        /*
        *2026-03-18 05:57:30 USDKRW 2026.03.18 1485.80 JPYKRW 2026.03.18 936.03 CNYKRW 2026.03.18 216.06
        * */

        String fetchedAt = LocalDateTime.now()
                .format(DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss"));

        // USDKRW
        String usdKey = "fx:USDKRW";
        redisTemplate.opsForHash().put(usdKey, "date", "2026.03.18");
        redisTemplate.opsForHash().put(usdKey, "rate", "1485.80");
        redisTemplate.opsForHash().put(usdKey, "fetched_at", fetchedAt);

        // JPYKRW
        String jpyKey = "fx:JPYKRW";
        redisTemplate.opsForHash().put(jpyKey, "date", "2026.03.18");
        redisTemplate.opsForHash().put(jpyKey, "rate", "936.03");
        redisTemplate.opsForHash().put(jpyKey, "fetched_at", fetchedAt);

        // CNYKRW
        String cnyKey = "fx:CNYKRW";
        redisTemplate.opsForHash().put(cnyKey, "date", "2026.03.18");
        redisTemplate.opsForHash().put(cnyKey, "rate", "216.06");
        redisTemplate.opsForHash().put(cnyKey, "fetched_at", fetchedAt);

        // (선택) TTL 설정
        redisTemplate.expire(usdKey, Duration.ofMinutes(10));
        redisTemplate.expire(jpyKey, Duration.ofMinutes(10));
        redisTemplate.expire(cnyKey, Duration.ofMinutes(10));
    }

    private String validateCurrency(String currency) {
        if (currency == null || currency.isBlank()) {
            throw new IllegalArgumentException("통화 코드는 필수입니다.");
        }

        String normalizedCurrency = currency.trim().toUpperCase();

        if (!normalizedCurrency.equals("USD")
                && !normalizedCurrency.equals("JPY")
                && !normalizedCurrency.equals("CNY")) {
            throw new IllegalArgumentException("지원하지 않는 통화 코드입니다. currency=" + currency);
        }

        return normalizedCurrency;
    }
}
