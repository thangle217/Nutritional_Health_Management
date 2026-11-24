package com.nhom12.nutrition.mealplan;

import java.sql.Date;
import java.time.LocalDate;
import java.util.Objects;
import java.util.UUID;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

/**
 * Cầu nối gọi trực tiếp 2 stored functions trọng yếu trong schema {@code nutrition}.
 * Mọi lỗi nghiệp vụ/phân quyền (SQLSTATE 42501 / 23505 / 23514) sẽ được {@code GlobalExceptionHandler}
 * ánh xạ sang JSON error contract thống nhất.
 */
@Service
public class PrescriptionProcedureService {

    private final JdbcTemplate jdbcTemplate;

    public PrescriptionProcedureService(JdbcTemplate jdbcTemplate) {
        this.jdbcTemplate = jdbcTemplate;
    }

    @Transactional
    public void publishPrescription(UUID versionId, UUID actorId) {
        Objects.requireNonNull(versionId, "versionId must not be null");
        Objects.requireNonNull(actorId, "actorId must not be null");
        jdbcTemplate.execute(
                "SELECT nutrition.publish_prescription(?::uuid, ?::uuid)",
                (java.sql.PreparedStatement ps) -> {
                    ps.setObject(1, versionId);
                    ps.setObject(2, actorId);
                    ps.execute();
                    return null;
                }
        );
    }

    @Transactional
    public void closeOrStopPrescription(
            UUID prescriptionId,
            UUID actorId,
            PrescriptionStatus targetStatus,
            String reason,
            LocalDate actualEndDate
    ) {
        Objects.requireNonNull(prescriptionId, "prescriptionId must not be null");
        Objects.requireNonNull(actorId, "actorId must not be null");
        Objects.requireNonNull(targetStatus, "targetStatus must not be null");
        jdbcTemplate.execute(
                "SELECT nutrition.close_or_stop_prescription(?::uuid, ?::uuid, ?::text, ?::text, ?::date)",
                (java.sql.PreparedStatement ps) -> {
                    ps.setObject(1, prescriptionId);
                    ps.setObject(2, actorId);
                    ps.setString(3, targetStatus.name());
                    ps.setString(4, reason);
                    ps.setDate(5, actualEndDate != null ? Date.valueOf(actualEndDate) : null);
                    ps.execute();
                    return null;
                }
        );
    }
}
