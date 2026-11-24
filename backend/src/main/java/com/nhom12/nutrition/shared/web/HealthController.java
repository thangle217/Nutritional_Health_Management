package com.nhom12.nutrition.shared.web;

import java.time.Instant;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/v1/health")
public class HealthController {

    private final JdbcTemplate jdbcTemplate;

    public HealthController(JdbcTemplate jdbcTemplate) {
        this.jdbcTemplate = jdbcTemplate;
    }

    @GetMapping
    public HealthResponse health() {
        String pgVersion = jdbcTemplate.queryForObject("SELECT version()", String.class);
        Integer tableCount = jdbcTemplate.queryForObject(
                "SELECT count(*)::int FROM information_schema.tables WHERE table_schema = 'nutrition' AND table_type = 'BASE TABLE'",
                Integer.class
        );
        return new HealthResponse("UP", "nutrition", tableCount != null ? tableCount : 0, pgVersion, Instant.now());
    }

    public record HealthResponse(
            String status,
            String schema,
            int nutritionTableCount,
            String databaseVersion,
            Instant checkedAt
    ) {
    }
}
