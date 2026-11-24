package com.nhom12.nutrition.healthmetric;

/**
 * Maps to PostgreSQL custom ENUM type {@code nutrition.vital_kind}.
 * When mapping an entity field to {@code kind}, annotate with {@code @JdbcTypeCode(SqlTypes.NAMED_ENUM)}.
 */
public enum VitalKind {
    WEIGHT,
    BP,
    GLUCOSE
}
