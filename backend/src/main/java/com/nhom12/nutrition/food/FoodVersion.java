package com.nhom12.nutrition.food;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import java.math.BigDecimal;
import java.time.Instant;
import java.util.UUID;

@Entity
@Table(name = "food_version", schema = "nutrition")
public class FoodVersion {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    @Column(name = "id", nullable = false, updatable = false)
    private UUID id;

    @Column(name = "food_id", nullable = false)
    private UUID foodId;

    @Column(name = "version_no", nullable = false)
    private int versionNo;

    @Column(name = "food_group_id", nullable = false)
    private UUID foodGroupId;

    @Column(name = "name", nullable = false)
    private String name;

    @Column(name = "preparation")
    private String preparation;

    @Column(name = "image_object_key")
    private String imageObjectKey;

    @Column(name = "base_unit", nullable = false)
    private String baseUnit;

    @Column(name = "base_quantity", nullable = false, precision = 10, scale = 3)
    private BigDecimal baseQuantity;

    @Column(name = "kcal", nullable = false, precision = 9, scale = 3)
    private BigDecimal kcal;

    @Column(name = "protein_g", nullable = false, precision = 9, scale = 3)
    private BigDecimal proteinG;

    @Column(name = "carb_g", nullable = false, precision = 9, scale = 3)
    private BigDecimal carbG;

    @Column(name = "fat_g", nullable = false, precision = 9, scale = 3)
    private BigDecimal fatG;

    @Column(name = "fiber_g", precision = 9, scale = 3)
    private BigDecimal fiberG;

    @Column(name = "sugar_g", precision = 9, scale = 3)
    private BigDecimal sugarG;

    @Column(name = "sodium_mg", nullable = false, precision = 9, scale = 3)
    private BigDecimal sodiumMg;

    @Column(name = "cholesterol_mg", precision = 9, scale = 3)
    private BigDecimal cholesterolMg;

    @Column(name = "glycemic_index", precision = 7, scale = 2)
    private BigDecimal glycemicIndex;

    @Column(name = "proposed_by", nullable = false)
    private UUID proposedBy;

    @Column(name = "reviewed_by")
    private UUID reviewedBy;

    @Column(name = "reviewed_at")
    private Instant reviewedAt;

    @Column(name = "status", nullable = false)
    private String status = "DRAFT";

    @Column(name = "review_note")
    private String reviewNote;

    protected FoodVersion() {
    }

    public UUID getId() {
        return id;
    }

    public UUID getFoodId() {
        return foodId;
    }

    public int getVersionNo() {
        return versionNo;
    }

    public UUID getFoodGroupId() {
        return foodGroupId;
    }

    public String getName() {
        return name;
    }

    public String getPreparation() {
        return preparation;
    }

    public String getImageObjectKey() {
        return imageObjectKey;
    }

    public String getBaseUnit() {
        return baseUnit;
    }

    public BigDecimal getBaseQuantity() {
        return baseQuantity;
    }

    public BigDecimal getKcal() {
        return kcal;
    }

    public BigDecimal getProteinG() {
        return proteinG;
    }

    public BigDecimal getCarbG() {
        return carbG;
    }

    public BigDecimal getFatG() {
        return fatG;
    }

    public BigDecimal getFiberG() {
        return fiberG;
    }

    public BigDecimal getSugarG() {
        return sugarG;
    }

    public BigDecimal getSodiumMg() {
        return sodiumMg;
    }

    public BigDecimal getCholesterolMg() {
        return cholesterolMg;
    }

    public BigDecimal getGlycemicIndex() {
        return glycemicIndex;
    }

    public UUID getProposedBy() {
        return proposedBy;
    }

    public UUID getReviewedBy() {
        return reviewedBy;
    }

    public Instant getReviewedAt() {
        return reviewedAt;
    }

    public String getStatus() {
        return status;
    }

    public String getReviewNote() {
        return reviewNote;
    }
}
