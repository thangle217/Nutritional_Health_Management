package com.nhom12.nutrition.audit;

import com.fasterxml.jackson.databind.JsonNode;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import java.time.Instant;
import java.util.UUID;
import org.hibernate.annotations.JdbcTypeCode;
import org.hibernate.type.SqlTypes;

@Entity
@Table(name = "system_setting", schema = "nutrition")
public class SystemSetting {

    @Id
    @Column(name = "setting_key", nullable = false)
    private String settingKey;

    @JdbcTypeCode(SqlTypes.JSON)
    @Column(name = "value_json", nullable = false, columnDefinition = "jsonb")
    private JsonNode valueJson;

    @Column(name = "description")
    private String description;

    @Column(name = "version_no", nullable = false)
    private int versionNo = 1;

    @Column(name = "updated_by")
    private UUID updatedBy;

    @Column(name = "updated_at", nullable = false, insertable = false, updatable = false)
    private Instant updatedAt;

    protected SystemSetting() {
    }

    public String getSettingKey() {
        return settingKey;
    }

    public JsonNode getValueJson() {
        return valueJson;
    }

    public void setValueJson(JsonNode valueJson) {
        this.valueJson = valueJson;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public int getVersionNo() {
        return versionNo;
    }

    public void setVersionNo(int versionNo) {
        this.versionNo = versionNo;
    }

    public UUID getUpdatedBy() {
        return updatedBy;
    }

    public void setUpdatedBy(UUID updatedBy) {
        this.updatedBy = updatedBy;
    }

    public Instant getUpdatedAt() {
        return updatedAt;
    }
}
