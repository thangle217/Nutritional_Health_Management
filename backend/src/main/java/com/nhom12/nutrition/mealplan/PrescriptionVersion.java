package com.nhom12.nutrition.mealplan;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import java.math.BigDecimal;
import java.time.Instant;
import java.time.LocalDate;
import java.util.UUID;

@Entity
@Table(name = "prescription_version", schema = "nutrition")
public class PrescriptionVersion {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    @Column(name = "id", nullable = false, updatable = false)
    private UUID id;

    @Column(name = "prescription_id", nullable = false)
    private UUID prescriptionId;

    @Column(name = "patient_id", nullable = false)
    private UUID patientId;

    @Column(name = "version_no", nullable = false)
    private int versionNo;

    @Column(name = "effective_on", nullable = false)
    private LocalDate effectiveOn;

    @Column(name = "through_date", nullable = false)
    private LocalDate throughDate;

    @Column(name = "target_kcal", nullable = false, precision = 8, scale = 2)
    private BigDecimal targetKcal;

    @Column(name = "protein_percent", nullable = false, precision = 5, scale = 2)
    private BigDecimal proteinPercent;

    @Column(name = "carb_percent", nullable = false, precision = 5, scale = 2)
    private BigDecimal carbPercent;

    @Column(name = "fat_percent", nullable = false, precision = 5, scale = 2)
    private BigDecimal fatPercent;

    @Column(name = "water_ml", nullable = false)
    private int waterMl;

    @Column(name = "avoid_food_notes")
    private String avoidFoodNotes;

    @Column(name = "patient_instruction")
    private String patientInstruction;

    @Column(name = "change_reason")
    private String changeReason;

    @Column(name = "copied_from")
    private UUID copiedFrom;

    @Column(name = "status", nullable = false)
    private String status = "DRAFT";

    @Column(name = "created_by", nullable = false)
    private UUID createdBy;

    @Column(name = "published_by")
    private UUID publishedBy;

    @Column(name = "published_at")
    private Instant publishedAt;

    protected PrescriptionVersion() {
    }

    public UUID getId() {
        return id;
    }

    public UUID getPrescriptionId() {
        return prescriptionId;
    }

    public UUID getPatientId() {
        return patientId;
    }

    public int getVersionNo() {
        return versionNo;
    }

    public LocalDate getEffectiveOn() {
        return effectiveOn;
    }

    public LocalDate getThroughDate() {
        return throughDate;
    }

    public BigDecimal getTargetKcal() {
        return targetKcal;
    }

    public BigDecimal getProteinPercent() {
        return proteinPercent;
    }

    public BigDecimal getCarbPercent() {
        return carbPercent;
    }

    public BigDecimal getFatPercent() {
        return fatPercent;
    }

    public int getWaterMl() {
        return waterMl;
    }

    public String getAvoidFoodNotes() {
        return avoidFoodNotes;
    }

    public String getPatientInstruction() {
        return patientInstruction;
    }

    public String getChangeReason() {
        return changeReason;
    }

    public UUID getCopiedFrom() {
        return copiedFrom;
    }

    public String getStatus() {
        return status;
    }

    public UUID getCreatedBy() {
        return createdBy;
    }

    public UUID getPublishedBy() {
        return publishedBy;
    }

    public Instant getPublishedAt() {
        return publishedAt;
    }
}
