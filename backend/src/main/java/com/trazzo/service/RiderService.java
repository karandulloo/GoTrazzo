package com.trazzo.service;

import com.trazzo.model.User;
import com.trazzo.model.enums.RiderStatus;
import com.trazzo.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.locationtech.jts.geom.Coordinate;
import org.locationtech.jts.geom.GeometryFactory;
import org.locationtech.jts.geom.Point;
import org.locationtech.jts.geom.PrecisionModel;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
public class RiderService {

    private final UserRepository userRepository;
    private final GeometryFactory geometryFactory = new GeometryFactory(new PrecisionModel(), 4326);

    @Transactional
    public User updateRiderStatus(Long riderId, RiderStatus status) {
        User rider = userRepository.findById(riderId)
                .orElseThrow(() -> new RuntimeException("Rider not found"));

        rider.setRiderStatus(status);
        return userRepository.save(rider);
    }

    @Transactional
    public User updateRiderLocation(Long riderId, double latitude, double longitude) {
        User rider = userRepository.findById(riderId)
                .orElseThrow(() -> new RuntimeException("Rider not found"));

        Point location = geometryFactory.createPoint(new Coordinate(longitude, latitude));
        rider.setCurrentLocation(location);

        return userRepository.save(rider);
    }
}
