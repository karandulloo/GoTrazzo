package com.trazzo.service;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.redis.core.StringRedisTemplate;
import org.springframework.stereotype.Service;

import java.time.Duration;
import java.util.Random;

@Service
@RequiredArgsConstructor
@Slf4j
public class OtpService {

    private final StringRedisTemplate redisTemplate;

    private static final long OTP_EXPIRATION_MINUTES = 5;
    private static final String OTP_PREFIX = "otp:";

    public void generateAndSendOtp(String phoneNumber) {
        String otp = generateOtp();
        storeOtp(phoneNumber, otp);

        // In a real application, integration with SMS provider (Twilio, SNS) would act
        // here.
        // For development, we log it.
        log.info("OTP generated for {}: {}", phoneNumber, otp);
    }

    public void storeOtp(String key, String otp) {
        String redisKey = OTP_PREFIX + key;
        redisTemplate.opsForValue().set(redisKey, otp, Duration.ofMinutes(OTP_EXPIRATION_MINUTES));
    }

    public boolean validateOtp(String key, String otp) {
        String redisKey = OTP_PREFIX + key;
        String storedOtp = redisTemplate.opsForValue().get(redisKey);

        if (storedOtp != null && storedOtp.equals(otp)) {
            // Remove OTP after usage
            redisTemplate.delete(redisKey);
            return true;
        }
        return false;
    }

    // Alias for compatibility if needed, or simply use validateOtp
    public boolean verifyOtp(String key, String otp) {
        return validateOtp(key, otp);
    }

    public String generateOtp() {
        Random random = new Random();
        int otp = 100000 + random.nextInt(900000);
        return String.valueOf(otp);
    }
}
