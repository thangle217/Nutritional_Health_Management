package com.nhom12.nutrition.doctor;

import java.util.Optional;
import java.util.UUID;
import org.springframework.data.jpa.repository.JpaRepository;

public interface AssignmentRepository extends JpaRepository<Assignment, UUID> {

    Optional<Assignment> findByPatientIdAndEndedAtIsNull(UUID patientId);
}
