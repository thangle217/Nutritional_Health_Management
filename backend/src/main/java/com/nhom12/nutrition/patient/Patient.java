package com.nhom12.nutrition.patient;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.UUID;

@Entity
@Table(name = "patient", schema = "nutrition")
public class Patient {

    @Id
    @Column(name = "id", nullable = false, updatable = false)
    private UUID id;

    @Column(name = "role", insertable = false, updatable = false)
    private String role;

    @Column(name = "patient_code", insertable = false, updatable = false)
    private Long patientCode;

    @Column(name = "joined_on", nullable = false, insertable = false, updatable = false)
    private LocalDate joinedOn;

    @Column(name = "date_of_birth")
    private LocalDate dateOfBirth;

    @Column(name = "sex")
    private String sex;

    @Column(name = "address")
    private String address;

    @Column(name = "baseline_height_cm", precision = 5, scale = 2)
    private BigDecimal baselineHeightCm;

    @Column(name = "baseline_weight_kg", precision = 6, scale = 2)
    private BigDecimal baselineWeightKg;

    @Column(name = "baseline_bmi", insertable = false, updatable = false)
    private BigDecimal baselineBmi;

    @Column(name = "activity_level")
    private String activityLevel;

    @Column(name = "goals")
    private String goals;

    @Column(name = "medical_history")
    private String medicalHistory;

    protected Patient() {
    }

    public UUID getId() {
        return id;
    }

    public void setId(UUID id) {
        this.id = id;
    }

    public String getRole() {
        return role;
    }

    public Long getPatientCode() {
        return patientCode;
    }

    public LocalDate getJoinedOn() {
        return joinedOn;
    }

    public LocalDate getDateOfBirth() {
        return dateOfBirth;
    }

    public void setDateOfBirth(LocalDate dateOfBirth) {
        this.dateOfBirth = dateOfBirth;
    }

    public String getSex() {
        return sex;
    }

    public void setSex(String sex) {
        this.sex = sex;
    }

    public String getAddress() {
        return address;
    }

    public void setAddress(String address) {
        this.address = address;
    }

    public BigDecimal getBaselineHeightCm() {
        return baselineHeightCm;
    }

    public void setBaselineHeightCm(BigDecimal baselineHeightCm) {
        this.baselineHeightCm = baselineHeightCm;
    }

    public BigDecimal getBaselineWeightKg() {
        return baselineWeightKg;
    }

    public void setBaselineWeightKg(BigDecimal baselineWeightKg) {
        this.baselineWeightKg = baselineWeightKg;
    }

    public BigDecimal getBaselineBmi() {
        return baselineBmi;
    }

    public String getActivityLevel() {
        return activityLevel;
    }

    public void setActivityLevel(String activityLevel) {
        this.activityLevel = activityLevel;
    }

    public String getGoals() {
        return goals;
    }

    public void setGoals(String goals) {
        this.goals = goals;
    }

    public String getMedicalHistory() {
        return medicalHistory;
    }

    public void setMedicalHistory(String medicalHistory) {
        this.medicalHistory = medicalHistory;
    }
}
