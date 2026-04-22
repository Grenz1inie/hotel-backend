package com.hyj.hotelbackend.controller;

import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import javax.sql.DataSource;
import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.Statement;
import java.time.OffsetDateTime;
import java.util.Map;

@RestController
@RequestMapping("/api/health")
public class HealthController {

    private final DataSource dataSource;

    public HealthController(DataSource dataSource) {
        this.dataSource = dataSource;
    }

    @GetMapping
    public Map<String, Object> health() {
        return Map.of(
                "status", "UP",
                "time", OffsetDateTime.now().toString()
        );
    }

    @GetMapping("/ready")
    public ResponseEntity<Map<String, Object>> readiness() {
        try (Connection connection = dataSource.getConnection();
             Statement statement = connection.createStatement();
             ResultSet resultSet = statement.executeQuery("SELECT 1 FROM DUAL")) {
            if (resultSet.next()) {
                return ResponseEntity.ok(Map.of(
                        "status", "UP",
                        "db", "UP",
                        "time", OffsetDateTime.now().toString()
                ));
            }
            return ResponseEntity.status(HttpStatus.SERVICE_UNAVAILABLE).body(Map.of(
                    "status", "DOWN",
                    "db", "DOWN",
                    "reason", "database probe returned empty result",
                    "time", OffsetDateTime.now().toString()
            ));
        } catch (Exception ex) {
            return ResponseEntity.status(HttpStatus.SERVICE_UNAVAILABLE).body(Map.of(
                    "status", "DOWN",
                    "db", "DOWN",
                    "reason", ex.getClass().getSimpleName(),
                    "time", OffsetDateTime.now().toString()
            ));
        }
    }
}

