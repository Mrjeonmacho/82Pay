package com.palipay.palipay_backend.finance.dto.response;

public record PinValidateResponse(
        Boolean isValid
) {
    public static PinValidateResponse valid(){
        return new PinValidateResponse(Boolean.TRUE);
    }

    public static PinValidateResponse inValid(){
        return new PinValidateResponse(Boolean.FALSE);
    }
}
