package com.trazzo.repository;

import com.trazzo.model.User;
import com.trazzo.model.enums.RiderStatus;
import com.trazzo.model.enums.UserRole;
import org.locationtech.jts.geom.Point;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface UserRepository extends JpaRepository<User, Long> {

        Optional<User> findByEmail(String email);

        Optional<User> findByPhone(String phone);

        Optional<User> findByEmailOrPhone(String email, String phone);

        boolean existsByEmail(String email);

        boolean existsByPhone(String phone);

        List<User> findByRole(UserRole role);

        /**
         * Find businesses within a given distance (in meters).
         * Uses native SQL with PostGIS ST_DWithin with geography casting.
         * ST_DWithin is more efficient than ST_Distance for proximity queries.
         * Using CAST syntax instead of :: to avoid Hibernate parameter parsing issues.
         */
        @Query(value = "SELECT u.* FROM users u " +
                        "WHERE u.role = 'BUSINESS' " +
                        "AND u.location IS NOT NULL " +
                        "AND ST_DWithin(CAST(u.location AS geography), CAST(ST_SetSRID(ST_MakePoint(:longitude, :latitude), 4326) AS geography), :distanceMeters) " +
                        "ORDER BY ST_Distance(CAST(u.location AS geography), CAST(ST_SetSRID(ST_MakePoint(:longitude, :latitude), 4326) AS geography))",
                nativeQuery = true)
        List<User> findNearbyBusinessesNative(
                        @Param("latitude") double latitude,
                        @Param("longitude") double longitude,
                        @Param("distanceMeters") double distanceMeters);

        /**
         * Find nearest available rider within distance.
         */
        @Query("SELECT u FROM User u WHERE u.role = 'RIDER' " +
                        "AND u.riderStatus = 'AVAILABLE' " +
                        "AND u.currentLocation IS NOT NULL " +
                        "AND distance(u.currentLocation, :point) < :distance " +
                        "ORDER BY distance(u.currentLocation, :point)")
        List<User> findNearestAvailableRiderList(
                        @Param("point") Point point,
                        @Param("distance") double distance);

        default Optional<User> findNearestAvailableRider(Point point, double distance) {
                List<User> riders = findNearestAvailableRiderList(point, distance);
                return riders.isEmpty() ? Optional.empty() : Optional.of(riders.get(0));
        }

        /**
         * Find available riders within distance.
         */
        @Query("SELECT u FROM User u WHERE u.role = 'RIDER' " +
                        "AND u.riderStatus = :status " +
                        "AND u.currentLocation IS NOT NULL " +
                        "AND distance(u.currentLocation, :point) < :distance")
        List<User> findRidersByStatusAndLocation(
                        @Param("status") RiderStatus status,
                        @Param("point") Point point,
                        @Param("distance") double distance);
}
