package com.nhom12.nutrition.shared.web;

import com.fasterxml.jackson.databind.JsonNode;
import com.nhom12.nutrition.audit.SystemSettingRepository;
import com.nhom12.nutrition.food.FoodGroupRepository;
import java.time.Instant;
import java.util.List;
import java.util.UUID;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

/**
 * Endpoint mẫu (chỉ đọc) dùng DTO để các thành viên tham khảo khi triển khai các module nghiệp vụ.
 */
@RestController
@RequestMapping("/api/v1/reference")
public class ReferenceController {

    private final FoodGroupRepository foodGroupRepository;
    private final SystemSettingRepository systemSettingRepository;

    public ReferenceController(
            FoodGroupRepository foodGroupRepository,
            SystemSettingRepository systemSettingRepository
    ) {
        this.foodGroupRepository = foodGroupRepository;
        this.systemSettingRepository = systemSettingRepository;
    }

    @GetMapping("/food-groups")
    public List<FoodGroupDto> listFoodGroups() {
        return foodGroupRepository.findAllByOrderByNameAsc().stream()
                .map(fg -> new FoodGroupDto(fg.getId(), fg.getName(), fg.isActive()))
                .toList();
    }

    @GetMapping("/system-settings")
    public List<SystemSettingDto> listSystemSettings() {
        return systemSettingRepository.findAllByOrderBySettingKeyAsc().stream()
                .map(s -> new SystemSettingDto(
                        s.getSettingKey(),
                        s.getValueJson(),
                        s.getDescription(),
                        s.getVersionNo(),
                        s.getUpdatedAt()
                ))
                .toList();
    }

    public record FoodGroupDto(UUID id, String name, boolean active) {
    }

    public record SystemSettingDto(
            String key,
            JsonNode value,
            String description,
            int versionNo,
            Instant updatedAt
    ) {
    }
}
