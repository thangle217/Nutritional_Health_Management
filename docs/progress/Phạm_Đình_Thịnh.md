# Nhật ký tiến độ — 24521702 – Phạm Đình Thịnh

- **Mã nhánh:** `pd-thinh` (ví dụ: `feat/pd-thinh/foods-templates`, `feat/pd-thinh/prescriptions-publish`, `feat/pd-thinh/clinical-declarations`)
- **Phạm vi phụ trách (v1.1):** `UC-PROF-05`, `UC-FOOD-01`, `UC-PLAN-01`, `UC-PRES-01`, `UC-PRES-02` (`BR-02`, `BR-08`) (BE + FE)
- **Package Backend:** `com.nhom12.nutrition.clinical`, `.food`, `.mealplan` (`PrescriptionProcedureService` đã dựng sẵn)
- **Thư mục Frontend:** `frontend/src/features/{declarations,foods,templates,prescriptions}`
- **Màn hình UI:** `SCR-PAT-02`, `SCR-PAT-06` (tab Bệnh lý/Dị ứng), `SCR-DOC-02` (tab Duyệt dị ứng & `FoodSafetyReview`), `SCR-DOC-03`, `SCR-DOC-04`, `SCR-HD-04`, `SCR-ADM-02`
- **Tài liệu chi tiết:** [Phạm_Đình_Thịnh_tasks.docx](../tasks/Phạm_Đình_Thịnh_tasks.docx) | [AI_TASKS_OVERVIEW.md](../tasks/AI_TASKS_OVERVIEW.md)

> **Lưu ý phân công v1.1:** Nhận thêm `UC-PROF-05` (khai báo/duyệt bệnh lý & dị ứng + tự động sinh `food_safety_review` khi `CONFIRMED` dị ứng trùng `applied_prescription_day`) vì gắn trực tiếp với đơn chỉ định bạn phụ trách. Trong tuần đầu chưa có `frontend/`, bạn code Backend Phase A dùng `@WithMockUser` bình thường, rồi pull `main` sau PR #1 của Đặng Trần Thiện.

## Checklist giai đoạn

### Phase A — Danh mục Món ăn & Thực đơn mẫu
- [ ] CRUD `food_group` (Admin `SCR-ADM-02`) + Tìm kiếm/Lọc danh mục `food_version` `PUBLISHED` (nhóm, kcal, dị ứng, trạng thái)
- [ ] Luồng đề xuất thêm/sửa món & thực đơn mẫu (`IN_REVIEW -> PUBLISHED/REJECTED`, bản cũ -> `SUPERSEDED`) tại `SCR-DOC-03` & `SCR-HD-04`
- [ ] Quy đổi đơn vị gia dụng (`food_unit_conversion`) & quản lý hạn chế (`food_restriction`)

### Phase B — Soạn, Ban hành & Đóng sớm Phiếu chỉ định
- [ ] Soạn phiếu 7–30 ngày (`target_kcal > 0`, `P + C + L = 100%`), 6 khung bữa (`@JdbcTypeCode(SqlTypes.NAMED_ENUM)` cho `meal_slot`)
- [ ] Sao chép ngày thành bản độc lập (`prescription_day`) & sao chép cả phiếu sang bản nháp mới
- [ ] Tích hợp `PrescriptionProcedureService.publishPrescription()` và `closeOrStopPrescription()` + `treatment_review`
- [ ] Phiên bản điều chỉnh (`version_no + 1`) từ ngày tương lai không sửa lịch sử ngày cũ

### Phase C — Khai báo Bệnh lý/Dị ứng (`UC-PROF-05`), UI & Kiểm thử tích hợp
- [ ] `HealthDeclaration` + `DeclarationReview` (`SCR-PAT-06` tab Bệnh lý/Dị ứng & `SCR-DOC-02` tab Duyệt dị ứng)
- [ ] Tự sinh `food_safety_review` khi `CONFIRMED` dị ứng mới trùng món trong `applied_prescription_day` + UI xử lý cho bác sĩ
- [ ] UI `SCR-DOC-04` (chặn `SUSPENDED`/dị ứng `CRITICAL`, bắt buộc lý do + hướng dẫn với `RESTRICTED`) & `SCR-PAT-02` (ẩn `DRAFT`, nhãn `RESTRICTED`)
- [ ] Pass test `E2E-3` (ban hành transaction, dừng sớm `STOPPED_EARLY` & xung đột dị ứng `FoodSafetyReview`)

## Lịch sử Commit & Push

> Dùng `.\scripts\log-commit.ps1 -MemberFile "Phạm_Đình_Thịnh.md" -Tested "..."` sau mỗi lần commit để tự động thêm dòng mới vào bảng bên dưới.

| Ngày | Branch | Commit | Nội dung đã làm | Kết quả Test | Ghi chú |
| --- | --- | --- | --- | --- | --- |
| _(mẫu)_ | `feat/pd-thinh/prescriptions-publish` | `abcd123` | `feat(mealplan): add prescription copy-day and publish API` | `mvn test PASS` | Xóa dòng mẫu khi bắt đầu |
