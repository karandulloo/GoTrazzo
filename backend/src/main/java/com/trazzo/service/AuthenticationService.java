package com.trazzo.service;

import com.trazzo.dto.request.LoginRequest;
import com.trazzo.dto.request.RegisterRequest;
import com.trazzo.dto.response.AuthenticationResponse;
import com.trazzo.model.User;
import com.trazzo.model.enums.RiderStatus;
import com.trazzo.model.enums.UserRole;
import com.trazzo.model.enums.UserStatus;
import com.trazzo.repository.UserRepository;
import com.trazzo.security.JwtService;
import lombok.RequiredArgsConstructor;
import org.locationtech.jts.geom.Coordinate;
import org.locationtech.jts.geom.GeometryFactory;
import org.locationtech.jts.geom.Point;
import org.locationtech.jts.geom.PrecisionModel;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class AuthenticationService {

    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;
    private final JwtService jwtService;
    private final AuthenticationManager authenticationManager;
    private final GeometryFactory geometryFactory = new GeometryFactory(new PrecisionModel(), 4326);

    public AuthenticationResponse register(RegisterRequest request) {
        // Check if user already exists
        if (userRepository.existsByEmail(request.getEmail())) {
            throw new RuntimeException("Email already registered");
        }
        if (userRepository.existsByPhone(request.getPhone())) {
            throw new RuntimeException("Phone already registered");
        }

        // Build user based on role
        User.UserBuilder userBuilder = User.builder()
                .name(request.getName())
                .email(request.getEmail())
                .phone(request.getPhone())
                .passwordHash(passwordEncoder.encode(request.getPassword()))
                .role(request.getRole())
                .status(UserStatus.ACTIVE)
                .phoneVerified(false);

        // Add role-specific fields
        if (request.getRole() == UserRole.CUSTOMER) {
            userBuilder.deliveryAddress(request.getDeliveryAddress());
        } else if (request.getRole() == UserRole.BUSINESS) {
            userBuilder
                    .businessName(request.getBusinessName())
                    .businessDescription(request.getBusinessDescription());

            if (request.getLatitude() != null && request.getLongitude() != null) {
                Point location = geometryFactory.createPoint(
                        new Coordinate(request.getLongitude(), request.getLatitude()));
                userBuilder.location(location);
            }
        } else if (request.getRole() == UserRole.RIDER) {
            userBuilder
                    .vehicleType(request.getVehicleType())
                    .vehicleNumber(request.getVehicleNumber())
                    .riderStatus(RiderStatus.OFFLINE);
        }

        User user = userRepository.save(userBuilder.build());

        String accessToken = jwtService.generateAccessToken(user);
        String refreshToken = jwtService.generateRefreshToken(user);

        return AuthenticationResponse.builder()
                .accessToken(accessToken)
                .refreshToken(refreshToken)
                .userId(user.getId())
                .name(user.getName())
                .email(user.getEmail())
                .role(user.getRole())
                .build();
    }

    public AuthenticationResponse login(LoginRequest request) {
        // Find user by email or phone
        User user = userRepository.findByEmailOrPhone(request.getEmailOrPhone(), request.getEmailOrPhone())
                .orElseThrow(() -> new org.springframework.security.authentication.BadCredentialsException(
                        "Invalid credentials"));

        // Authenticate
        authenticationManager.authenticate(
                new UsernamePasswordAuthenticationToken(
                        user.getEmail(),
                        request.getPassword()));

        String accessToken = jwtService.generateAccessToken(user);
        String refreshToken = jwtService.generateRefreshToken(user);

        return AuthenticationResponse.builder()
                .accessToken(accessToken)
                .refreshToken(refreshToken)
                .userId(user.getId())
                .name(user.getName())
                .email(user.getEmail())
                .role(user.getRole())
                .build();
    }

    public User getUserByEmail(String email) {
        return userRepository.findByEmail(email)
                .orElseThrow(() -> new RuntimeException("User not found"));
    }
}
