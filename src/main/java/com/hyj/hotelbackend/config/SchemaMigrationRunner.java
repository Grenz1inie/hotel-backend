package com.hyj.hotelbackend.config;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.InitializingBean;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Component;

@Component
public class SchemaMigrationRunner implements InitializingBean {

    private static final Logger log = LoggerFactory.getLogger(SchemaMigrationRunner.class);

    private final JdbcTemplate jdbcTemplate;

    public SchemaMigrationRunner(JdbcTemplate jdbcTemplate) {
        this.jdbcTemplate = jdbcTemplate;
    }

    @Override
    public void afterPropertiesSet() {
        try {
            String columnType = jdbcTemplate.queryForObject(
                    "SELECT COLUMN_TYPE FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'bookings' AND COLUMN_NAME = 'payment_status'",
                    String.class
            );
            if (columnType != null && !columnType.contains("WAIVED")) {
                jdbcTemplate.execute(
                        "ALTER TABLE bookings MODIFY payment_status ENUM('UNPAID','PAID','PARTIAL_REFUND','REFUNDED','WAIVED') NOT NULL DEFAULT 'UNPAID'"
                );
                log.info("Extended payment_status enum to include WAIVED");
            }
        } catch (Exception ex) {
            log.warn("Failed to ensure payment_status enum includes WAIVED", ex);
        }
    }
}
