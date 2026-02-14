package com.trazzo.service;

import com.trazzo.model.User;
import com.trazzo.model.enums.UserRole;
import com.trazzo.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Service;

import java.util.Optional;

@Service
@RequiredArgsConstructor
public class CurrentUserService {

    private final UserRepository userRepository;

    public Optional<User> getCurrentUser() {
        var auth = SecurityContextHolder.getContext().getAuthentication();
        if (auth == null || !auth.isAuthenticated() || auth.getPrincipal() == null) {
            return Optional.empty();
        }
        String email = auth.getName();
        return userRepository.findByEmail(email);
    }

    public User getCurrentUserOrThrow() {
        return getCurrentUser().orElseThrow(() -> new RuntimeException("User not authenticated"));
    }

    public Optional<User> getCurrentCustomer() {
        return getCurrentUser().filter(u -> u.getRole() == UserRole.CUSTOMER);
    }
}
