package com.nhom12.nutrition.audit;

import java.util.List;
import org.springframework.data.jpa.repository.JpaRepository;

public interface SystemSettingRepository extends JpaRepository<SystemSetting, String> {

    List<SystemSetting> findAllByOrderBySettingKeyAsc();
}
