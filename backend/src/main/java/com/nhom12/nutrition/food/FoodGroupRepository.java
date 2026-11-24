package com.nhom12.nutrition.food;

import java.util.List;
import java.util.UUID;
import org.springframework.data.jpa.repository.JpaRepository;

public interface FoodGroupRepository extends JpaRepository<FoodGroup, UUID> {

    List<FoodGroup> findAllByOrderByNameAsc();
}
