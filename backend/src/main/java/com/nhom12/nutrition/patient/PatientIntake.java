package com.nhom12.nutrition.patient;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import java.time.Instant;
import java.util.UUID;

@Entity
@Table(name = "patient_intake", schema = "nutrition")
public class PatientIntake {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    @Column(name = "id", nullable = false, updatable = false)
    private UUID id;

    @Column(name = "patient_id", nullable = false)
    private UUID patientId;

    @Column(name = "previously_examined_here", nullable = false)
    private boolean previouslyExaminedHere;

    @Column(name = "requested_doctor_id")
    private UUID requestedDoctorId;

    @Column(name = "facility_visit_ref")
    private String facilityVisitRef;

    @Column(name = "declaration_notes")
    private String declarationNotes;

    @Enumerated(EnumType.STRING)
    @Column(name = "status", nullable = false)
    private IntakeStatus status = IntakeStatus.DRAFT;

    @Column(name = "submitted_at")
    private Instant submittedAt;

    @Column(name = "reviewed_by")
    private UUID reviewedBy;

    @Column(name = "reviewed_at")
    private Instant reviewedAt;

    @Column(name = "response")
    private String response;

    protected PatientIntake() {
    }

    public UUID getId() {
        return id;
    }

    public UUID getPatientId() {
        return patientId;
    }

    public void setPatientId(UUID patientId) {
        this.patientId = patientId;
    }

    public boolean isPreviouslyExaminedHere() {
        return previouslyExaminedHere;
    }

    public void setPreviouslyExaminedHere(boolean previouslyExaminedHere) {
        this.previouslyExaminedHere = previouslyExaminedHere;
    }

    public UUID getRequestedDoctorId() {
        return requestedDoctorId;
    }

    public void setRequestedDoctorId(UUID requestedDoctorId) {
        this.requestedDoctorId = requestedDoctorId;
    }

    public String getFacilityVisitRef() {
        return facilityVisitRef;
    }

    public void setFacilityVisitRef(String facilityVisitRef) {
        this.facilityVisitRef = facilityVisitRef;
    }

    public String getDeclarationNotes() {
        return declarationNotes;
    }

    public void setDeclarationNotes(String declarationNotes) {
        this.declarationNotes = declarationNotes;
    }

    public IntakeStatus getStatus() {
        return status;
    }

    public void setStatus(IntakeStatus status) {
        this.status = status;
    }

    public Instant getSubmittedAt() {
        return submittedAt;
    }

    public void setSubmittedAt(Instant submittedAt) {
        this.submittedAt = submittedAt;
    }

    public UUID getReviewedBy() {
        return reviewedBy;
    }

    public void setReviewedBy(UUID reviewedBy) {
        this.reviewedBy = reviewedBy;
    }

    public Instant getReviewedAt() {
        return reviewedAt;
    }

    public void setReviewedAt(Instant reviewedAt) {
        this.reviewedAt = reviewedAt;
    }

    public String getResponse() {
        return response;
    }

    public void setResponse(String response) {
        this.response = response;
    }
}
