package com.palipay.palipay_backend.user.infrastructure.mail;

import jakarta.mail.internet.InternetAddress;
import jakarta.mail.internet.MimeMessage;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.mail.javamail.JavaMailSender;
import org.springframework.mail.javamail.MimeMessageHelper;
import org.springframework.stereotype.Component;

@Component
@RequiredArgsConstructor
public class EmailSender {

    private final JavaMailSender javaMailSender;

    @Value("${PALIPAY_ADMIN_EMAIL}")
    private String fromEmail;

    public void sendEmail(String to, String authCode) {
        MimeMessage message = javaMailSender.createMimeMessage();

        try {
            // MimeMessageHelper를 쓰면 설정이 훨씬 편합니다. (true는 멀티파트/HTML 사용 의미)
            MimeMessageHelper helper = new MimeMessageHelper(message, true, "UTF-8");

            String content = """
                    <div style="margin:20px; padding:20px; border:1px solid #ddd;">
                        <h2>안녕하세요 PaliPay입니다.</h2>
                        <p>아래의 인증코드를 회원가입 화면에 입력해주세요.</p>
                        <div style="background:#f4f4f4; padding:10px; font-size:20px; font-weight:bold;">
                            인증코드 : <span style="color:#e74c3c;">${authCode}</span>
                        </div>
                    </div>
                    """;

            // 님께서 원하신 대로 replace 방식 사용!
            content = content.replace("${authCode}", authCode);

            helper.setFrom(new InternetAddress(fromEmail, "PaliPay", "UTF-8"));
            helper.setTo(to);
            helper.setSubject("PaliPay 회원가입 인증코드");
            helper.setText(content, true); // true를 넣어야 HTML로 렌더링됩니다.

            javaMailSender.send(message);

        } catch (Exception e) {
            throw new RuntimeException("메일 발송 실패: " + e.getMessage());
        }
    }

}
