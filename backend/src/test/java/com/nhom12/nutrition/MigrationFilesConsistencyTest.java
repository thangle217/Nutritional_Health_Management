package com.nhom12.nutrition;

import static org.assertj.core.api.Assertions.assertThat;

import java.io.IOException;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.ArrayList;
import java.util.List;
import java.util.regex.Matcher;
import java.util.regex.Pattern;
import org.junit.jupiter.api.Test;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;

class MigrationFilesConsistencyTest {

    private static final Pattern BCRYPT_PATTERN = Pattern.compile("\\$2[aby]\\$\\d{2}\\$[./A-Za-z0-9]{53}");

    @Test
    void flywayMigrationsMatchCanonicalSqlWithoutTopLevelTransactions() throws IOException {
        Path resourcesDir = Path.of("src/main/resources");
        Path canonicalDir = Path.of("../docs/database").normalize();

        assertSynced(
                canonicalDir.resolve("001_schema.sql"),
                resourcesDir.resolve("db/migration/V1__init_schema.sql")
        );
        assertSynced(
                canonicalDir.resolve("002_publish_prescription.sql"),
                resourcesDir.resolve("db/migration/V2__publish_prescription_and_views.sql")
        );
        assertSynced(
                canonicalDir.resolve("003_seed_dev.sql"),
                resourcesDir.resolve("db/seed/V3__dev_seed.sql")
        );
    }

    @Test
    void devSeedContainsRealBcryptHashesMatchingDemoPassword() throws IOException {
        String seedSql = Files.readString(Path.of("src/main/resources/db/seed/V3__dev_seed.sql"), StandardCharsets.UTF_8);
        Matcher m = BCRYPT_PATTERN.matcher(seedSql);
        List<String> hashes = new ArrayList<>();
        while (m.find()) {
            hashes.add(m.group());
        }
        assertThat(hashes).hasSize(7);
        BCryptPasswordEncoder encoder = new BCryptPasswordEncoder();
        for (String hash : hashes) {
            assertThat(encoder.matches("Demo@123456", hash))
                    .as("BCrypt hash %s must match Demo@123456", hash)
                    .isTrue();
        }
    }

    private void assertSynced(Path canonicalSql, Path flywaySql) throws IOException {
        assertThat(Files.exists(canonicalSql)).as("Missing %s", canonicalSql).isTrue();
        assertThat(Files.exists(flywaySql)).as("Missing %s", flywaySql).isTrue();

        String canonicalBody = stripTxWrapper(Files.readString(canonicalSql, StandardCharsets.UTF_8));
        String flywayBody = normalize(Files.readString(flywaySql, StandardCharsets.UTF_8));

        assertThat(flywayBody)
                .doesNotStartWith("BEGIN;")
                .doesNotEndWith("COMMIT;\n");
        assertThat(flywayBody).isEqualTo(canonicalBody);
    }

    private String stripTxWrapper(String text) {
        String norm = normalize(text).trim();
        if (norm.startsWith("BEGIN;")) {
            norm = norm.substring("BEGIN;".length()).stripLeading();
        }
        if (norm.endsWith("COMMIT;")) {
            norm = norm.substring(0, norm.length() - "COMMIT;".length()).stripTrailing();
        }
        return norm + "\n";
    }

    private String normalize(String text) {
        return text.replace("\r\n", "\n");
    }
}
