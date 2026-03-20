package com.palipay.palipay_backend.external.dto.response;

public record ExternalWorkplaceResponse(
        String companyName,
        String businessPerson,
        String businessNumber,
        String businessAddress
) {
}