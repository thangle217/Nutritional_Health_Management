package com.nhom12.nutrition.shared.error;

import java.sql.SQLException;
import java.time.Instant;
import java.util.LinkedHashMap;
import java.util.Map;
import java.util.UUID;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.dao.DataIntegrityViolationException;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.AccessDeniedException;
import org.springframework.validation.FieldError;
import org.springframework.web.bind.MethodArgumentNotValidException;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RestControllerAdvice;

@RestControllerAdvice
public class GlobalExceptionHandler {

    private static final Logger log = LoggerFactory.getLogger(GlobalExceptionHandler.class);

    @ExceptionHandler(MethodArgumentNotValidException.class)
    public ResponseEntity<ApiErrorResponse> handleValidation(MethodArgumentNotValidException ex) {
        Map<String, String> fieldErrors = new LinkedHashMap<>();
        for (FieldError err : ex.getBindingResult().getFieldErrors()) {
            fieldErrors.putIfAbsent(err.getField(), err.getDefaultMessage());
        }
        return build(HttpStatus.BAD_REQUEST, "VALIDATION_ERROR", "Dữ liệu không hợp lệ", fieldErrors);
    }

    @ExceptionHandler(BusinessException.class)
    public ResponseEntity<ApiErrorResponse> handleBusiness(BusinessException ex) {
        return build(ex.getStatus(), ex.getCode(), ex.getMessage(), null);
    }

    @ExceptionHandler(AccessDeniedException.class)
    public ResponseEntity<ApiErrorResponse> handleAccessDenied(AccessDeniedException ex) {
        return build(HttpStatus.FORBIDDEN, "FORBIDDEN", "Bạn không có quyền thực hiện thao tác này", null);
    }

    @ExceptionHandler(DataIntegrityViolationException.class)
    public ResponseEntity<ApiErrorResponse> handleDataIntegrity(DataIntegrityViolationException ex) {
        String sqlState = extractSqlState(ex);
        if ("42501".equals(sqlState)) {
            return build(HttpStatus.FORBIDDEN, "FORBIDDEN", "Không đủ quyền thực hiện thao tác trên dữ liệu y khoa", null);
        }
        if ("23505".equals(sqlState)) {
            return build(HttpStatus.CONFLICT, "CONFLICT", "Dữ liệu bị trùng hoặc xung đột lịch hiệu lực", null);
        }
        if ("23514".equals(sqlState) || "23503".equals(sqlState) || "23502".equals(sqlState)) {
            return build(HttpStatus.BAD_REQUEST, "BUSINESS_RULE_VIOLATION", "Dữ liệu vi phạm ràng buộc nghiệp vụ", null);
        }
        log.warn("Data integrity error (sqlState={})", sqlState);
        return build(HttpStatus.BAD_REQUEST, "DATA_INTEGRITY_ERROR", "Yêu cầu không hợp lệ đối với ràng buộc dữ liệu", null);
    }

    @ExceptionHandler(Exception.class)
    public ResponseEntity<ApiErrorResponse> handleUnexpected(Exception ex) {
        String traceId = UUID.randomUUID().toString();
        log.error("Unhandled exception [traceId={}]", traceId, ex);
        return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(
                new ApiErrorResponse(Instant.now(), 500, "INTERNAL_ERROR", "Đã xảy ra lỗi hệ thống", null, traceId)
        );
    }

    private ResponseEntity<ApiErrorResponse> build(HttpStatus status, String code, String message, Map<String, String> fieldErrors) {
        return ResponseEntity.status(status).body(
                new ApiErrorResponse(Instant.now(), status.value(), code, message, fieldErrors, UUID.randomUUID().toString())
        );
    }

    private String extractSqlState(Throwable ex) {
        Throwable cur = ex;
        while (cur != null) {
            if (cur instanceof SQLException sqlEx && sqlEx.getSQLState() != null) {
                return sqlEx.getSQLState();
            }
            cur = cur.getCause();
        }
        return null;
    }
}
