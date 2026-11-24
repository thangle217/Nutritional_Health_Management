package com.nhom12.nutrition;

import static org.hamcrest.Matchers.containsString;
import static org.hamcrest.Matchers.not;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.content;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import com.nhom12.nutrition.shared.config.SecurityConfig;
import com.nhom12.nutrition.shared.error.BusinessException;
import com.nhom12.nutrition.shared.error.GlobalExceptionHandler;
import jakarta.validation.Valid;
import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import java.sql.SQLException;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.WebMvcTest;
import org.springframework.context.annotation.Import;
import org.springframework.dao.DataIntegrityViolationException;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.security.test.context.support.WithMockUser;
import org.springframework.test.context.ActiveProfiles;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

@WebMvcTest(controllers = GlobalExceptionHandlerTest.DummyErrorController.class)
@Import({GlobalExceptionHandler.class, SecurityConfig.class, GlobalExceptionHandlerTest.DummyErrorController.class})
@ActiveProfiles("test")
class GlobalExceptionHandlerTest {

    @Autowired
    private MockMvc mockMvc;

    @RestController
    @RequestMapping("/api/test/errors")
    static class DummyErrorController {

        record SampleInput(@NotBlank @Email String email) {
        }

        @PostMapping("/validate")
        String validate(@Valid @RequestBody SampleInput input) {
            return "ok";
        }

        @GetMapping("/pg")
        String pgError(@RequestParam("state") String state) {
            SQLException sqlEx = new SQLException("SELECT sensitive FROM nutrition.app_user WHERE secret='x'", state);
            throw new DataIntegrityViolationException("constraint failed", sqlEx);
        }

        @GetMapping("/business")
        String business() {
            throw new BusinessException(HttpStatus.UNPROCESSABLE_ENTITY, "PRESCRIPTION_WINDOW_INVALID", "Kỳ chỉ định phải từ 7 đến 30 ngày");
        }
    }

    @Test
    void unauthenticatedProtectedEndpointReturnsJson401Contract() throws Exception {
        mockMvc.perform(get("/api/test/errors/business"))
                .andExpect(status().isUnauthorized())
                .andExpect(jsonPath("$.status").value(401))
                .andExpect(jsonPath("$.code").value("UNAUTHORIZED"))
                .andExpect(jsonPath("$.traceId").isNotEmpty());
    }

    @Test
    @WithMockUser
    void validationErrorReturns400WithFieldErrors() throws Exception {
        mockMvc.perform(post("/api/test/errors/validate")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("{\"email\":\"not-an-email\"}"))
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.status").value(400))
                .andExpect(jsonPath("$.code").value("VALIDATION_ERROR"))
                .andExpect(jsonPath("$.fieldErrors.email").isNotEmpty());
    }

    @Test
    @WithMockUser
    void postgresSqlStatesMapCleanlyWithoutLeakingSql() throws Exception {
        mockMvc.perform(get("/api/test/errors/pg").param("state", "42501"))
                .andExpect(status().isForbidden())
                .andExpect(jsonPath("$.code").value("FORBIDDEN"))
                .andExpect(content().string(not(containsString("SELECT"))));

        mockMvc.perform(get("/api/test/errors/pg").param("state", "23505"))
                .andExpect(status().isConflict())
                .andExpect(jsonPath("$.code").value("CONFLICT"));

        mockMvc.perform(get("/api/test/errors/pg").param("state", "23514"))
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.code").value("BUSINESS_RULE_VIOLATION"));
    }

    @Test
    @WithMockUser
    void businessExceptionMapsToExpectedStatusAndCode() throws Exception {
        mockMvc.perform(get("/api/test/errors/business"))
                .andExpect(status().isUnprocessableEntity())
                .andExpect(jsonPath("$.status").value(422))
                .andExpect(jsonPath("$.code").value("PRESCRIPTION_WINDOW_INVALID"))
                .andExpect(jsonPath("$.message").value("Kỳ chỉ định phải từ 7 đến 30 ngày"));
    }
}
