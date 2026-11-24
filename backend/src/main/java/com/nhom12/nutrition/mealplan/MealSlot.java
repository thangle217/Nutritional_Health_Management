package com.nhom12.nutrition.mealplan;

/**
 * Maps to PostgreSQL custom ENUM type {@code nutrition.meal_slot}.
 * When mapping an entity field to {@code slot}, annotate with {@code @JdbcTypeCode(SqlTypes.NAMED_ENUM)}.
 */
public enum MealSlot {
    BREAKFAST,
    AM_SNACK,
    LUNCH,
    PM_SNACK,
    DINNER,
    EVENING_SNACK
}
