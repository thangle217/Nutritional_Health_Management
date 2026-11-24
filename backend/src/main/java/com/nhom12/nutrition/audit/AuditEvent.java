package com.nhom12.nutrition.audit;

import com.fasterxml.jackson.databind.JsonNode;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import java.net.InetAddress;
import java.time.Instant;
import java.util.UUID;
import org.hibernate.annotations.JdbcTypeCode;
import org.hibernate.type.SqlTypes;

@Entity
@Table(name = "audit_event", schema = "nutrition")
public class AuditEvent {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "id", nullable = false, updatable = false)
    private Long id;

    @Column(name = "actor_id")
    private UUID actorId;

    @Column(name = "action", nullable = false)
    private String action;

    @Column(name = "object_type", nullable = false)
    private String objectType;

    @Column(name = "object_id")
    private UUID objectId;

    @Column(name = "patient_id")
    private UUID patientId;

    @Column(name = "reason")
    private String reason;

    @JdbcTypeCode(SqlTypes.INET)
    @Column(name = "source_ip", columnDefinition = "inet")
    private InetAddress sourceIp;

    @JdbcTypeCode(SqlTypes.JSON)
    @Column(name = "metadata", nullable = false, columnDefinition = "jsonb")
    private JsonNode metadata;

    @Column(name = "occurred_at", nullable = false, insertable = false, updatable = false)
    private Instant occurredAt;

    protected AuditEvent() {
    }

    public Long getId() {
        return id;
    }

    public UUID getActorId() {
        return actorId;
    }

    public String getAction() {
        return action;
    }

    public String getObjectType() {
        return objectType;
    }

    public UUID getObjectId() {
        return objectId;
    }

    public UUID getPatientId() {
        return patientId;
    }

    public String getReason() {
        return reason;
    }

    public InetAddress getSourceIp() {
        return sourceIp;
    }

    public JsonNode getMetadata() {
        return metadata;
    }

    public Instant getOccurredAt() {
        return occurredAt;
    }
}
