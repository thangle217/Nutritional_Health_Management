package com.nhom12.nutrition;

import static org.assertj.core.api.Assertions.assertThat;

import com.nhom12.nutrition.audit.AuditEvent;
import com.nhom12.nutrition.audit.SystemSetting;
import com.nhom12.nutrition.auth.AppUser;
import com.nhom12.nutrition.doctor.Assignment;
import com.nhom12.nutrition.doctor.Clinician;
import com.nhom12.nutrition.food.Food;
import com.nhom12.nutrition.food.FoodGroup;
import com.nhom12.nutrition.food.FoodVersion;
import com.nhom12.nutrition.mealplan.Prescription;
import com.nhom12.nutrition.mealplan.PrescriptionVersion;
import com.nhom12.nutrition.patient.Patient;
import com.nhom12.nutrition.patient.PatientIntake;
import jakarta.persistence.Column;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Table;
import java.lang.reflect.Field;
import java.util.List;
import org.hibernate.annotations.JdbcTypeCode;
import org.hibernate.type.SqlTypes;
import org.junit.jupiter.api.Test;

class JpaMetamodelMappingTest {

    @Test
    void allCoreEntitiesMapToNutritionSchema() {
        List<Class<?>> entities = List.of(
                AppUser.class,
                Patient.class,
                PatientIntake.class,
                Clinician.class,
                Assignment.class,
                FoodGroup.class,
                Food.class,
                FoodVersion.class,
                Prescription.class,
                PrescriptionVersion.class,
                SystemSetting.class,
                AuditEvent.class
        );
        for (Class<?> entity : entities) {
            Table tbl = entity.getAnnotation(Table.class);
            assertThat(tbl).as("@Table missing on %s", entity.getSimpleName()).isNotNull();
            assertThat(tbl.schema()).isEqualTo("nutrition");
        }
    }

    @Test
    void generatedAndDatabaseDefaultColumnsAreReadOnlyInJpa() throws NoSuchFieldException {
        assertReadOnly(Patient.class.getDeclaredField("role"));
        assertReadOnly(Patient.class.getDeclaredField("patientCode"));
        assertReadOnly(Patient.class.getDeclaredField("baselineBmi"));
        assertReadOnly(Patient.class.getDeclaredField("joinedOn"));
        assertReadOnly(AppUser.class.getDeclaredField("createdAt"));
        assertReadOnly(Assignment.class.getDeclaredField("startedAt"));
        assertReadOnly(Prescription.class.getDeclaredField("createdAt"));
        assertReadOnly(SystemSetting.class.getDeclaredField("updatedAt"));
        assertReadOnly(AuditEvent.class.getDeclaredField("occurredAt"));

        Field auditId = AuditEvent.class.getDeclaredField("id");
        GeneratedValue gen = auditId.getAnnotation(GeneratedValue.class);
        assertThat(gen).isNotNull();
        assertThat(gen.strategy()).isEqualTo(GenerationType.IDENTITY);
        assertThat(auditId.getAnnotation(Column.class).updatable()).isFalse();
    }

    @Test
    void postgresSpecificColumnTypesUseMatchingHibernateJdbcTypes() throws NoSuchFieldException {
        assertThat(Assignment.class.getDeclaredField("activeSlot").getType()).isEqualTo(Short.class);

        JdbcTypeCode jsonSetting = SystemSetting.class.getDeclaredField("valueJson").getAnnotation(JdbcTypeCode.class);
        assertThat(jsonSetting).isNotNull();
        assertThat(jsonSetting.value()).isEqualTo(SqlTypes.JSON);

        JdbcTypeCode jsonAudit = AuditEvent.class.getDeclaredField("metadata").getAnnotation(JdbcTypeCode.class);
        assertThat(jsonAudit).isNotNull();
        assertThat(jsonAudit.value()).isEqualTo(SqlTypes.JSON);

        JdbcTypeCode inetAudit = AuditEvent.class.getDeclaredField("sourceIp").getAnnotation(JdbcTypeCode.class);
        assertThat(inetAudit).isNotNull();
        assertThat(inetAudit.value()).isEqualTo(SqlTypes.INET);
    }

    private void assertReadOnly(Field f) {
        Column col = f.getAnnotation(Column.class);
        assertThat(col).isNotNull();
        assertThat(col.insertable()).as("%s.insertable", f.getName()).isFalse();
        assertThat(col.updatable()).as("%s.updatable", f.getName()).isFalse();
    }
}
