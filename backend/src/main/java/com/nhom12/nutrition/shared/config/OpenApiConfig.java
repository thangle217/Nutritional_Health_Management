package com.nhom12.nutrition.shared.config;

import io.swagger.v3.oas.models.OpenAPI;
import io.swagger.v3.oas.models.info.Info;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

@Configuration
public class OpenApiConfig {

    @Bean
    public OpenAPI nutritionOpenApi() {
        return new OpenAPI()
                .info(new Info()
                        .title("Nhóm 12 - Hệ thống quản lý dinh dưỡng và thực đơn cá nhân API")
                        .description("Backend Modular Monolith (Spring Boot 3 + Flyway + PostgreSQL schema nutrition)")
                        .version("v1"));
    }
}
