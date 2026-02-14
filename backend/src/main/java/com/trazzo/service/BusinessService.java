package com.trazzo.service;

import com.trazzo.model.User;
import com.trazzo.repository.UserRepository;
import org.locationtech.jts.geom.GeometryFactory;
import org.locationtech.jts.geom.PrecisionModel;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

import java.util.List;

@Slf4j
@Service
@RequiredArgsConstructor
public class BusinessService {

    private final UserRepository userRepository;

    @Value("${trazzo.default-search-radius}")
    private double defaultSearchRadius;

    private final GeometryFactory geometryFactory = new GeometryFactory(new PrecisionModel(), 4326);

    public List<User> findNearbyBusinesses(double latitude, double longitude, Double radius) {
        try {
            double searchRadiusMeters = radius != null ? radius : defaultSearchRadius;
            
            // Use native SQL query with PostGIS ST_Distance (more reliable)
            List<User> businesses = userRepository.findNearbyBusinessesNative(latitude, longitude, searchRadiusMeters);
            log.info("Found {} businesses within {} meters of ({}, {})", businesses.size(), searchRadiusMeters, latitude, longitude);
            return businesses;
        } catch (Exception e) {
            // Fallback: return all businesses if query fails
            // This prevents the app from getting stuck
            log.warn("Error finding nearby businesses, falling back to all businesses: {}", e.getMessage());
            List<User> allBusinesses = userRepository.findByRole(com.trazzo.model.enums.UserRole.BUSINESS)
                    .stream()
                    .filter(u -> u.getLocation() != null)
                    .toList();
            log.info("Fallback: Returning {} businesses", allBusinesses.size());
            return allBusinesses;
        }
    }

    public User getBusinessById(Long id) {
        return userRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Business not found"));
    }

    public User updateBusiness(User business) {
        return userRepository.save(business);
    }
}
