# Nhật ký tiến độ — 24521702 – Phạm Đình Thịnh

- **Phạm vi phụ trách:** `UC-FOOD-01`, `UC-PLAN-01`, `UC-PRES-01`, `UC-PRES-02` (`BR-02`, `BR-08`)
- **Package Backend:** `com.nhom12.nutrition.food`, `com.nhom12.nutrition.mealplan`
- **Màn hình UI:** `SCR-DOC-03`, `SCR-DOC-04`, `SCR-HD-04`, `SCR-ADM-02`, `SCR-PAT-02`
- **Tài liệu chi tiết:** [Phạm_Đình_Thịnh_tasks.docx](../tasks/Phạm_Đình_Thịnh_tasks.docx)

## Checklist giai đoạn

### Phase A — Danh mục Món ăn & Thực đơn mẫu
- [ ] CRUD `food_group` (Admin) + Tìm kiếm/Lọc danh mục `food_version` `PUBLISHED` (nhóm, kcal, dị ứng, trạng thái)
- [ ] Luồng đề xuất thêm/sửa món & thực đơn mẫu (`IN_REVIEW -> PUBLISHED/REJECTED`, bản cũ -> `SUPERSEDED`)
- [ ] Quy đổi đơn vị gia dụng (`food_unit_conversion`) & quản lý hạn chế (`food_restriction`)

### Phase B — Soạn, Ban hành & Đóng sớm Phiếu chỉ định
- [ ] Soạn phiếu 7–30 ngày (`target_kcal > 0`, `P + C + L = 100%`), 6 khung bữa (`@JdbcTypeCode(SqlTypes.NAMED_ENUM)` cho `meal_slot`)
- [ ] Sao chép ngày thành bản độc lập (`prescription_day`) & sao chép cả phiếu sang bản nháp mới
- [ ] Tích hợp `PrescriptionProcedureService.publishPrescription()` và `closeOrStopPrescription()` + `treatment_review`
- [ ] Phiên bản điều chỉnh (`version_no + 1`) từ ngày tương lai không sửa lịch sử ngày cũ

### Phase C — Giao diện & Kiểm thử tích hợp
- [ ] UI `SCR-DOC-04` (chặn `SUSPENDED`/dị ứng `CRITICAL`, bắt buộc lý do + hướng dẫn với `RESTRICTED`)
- [ ] UI `SCR-PAT-02` (xem theo ngày/tuần, ẩn `DRAFT`, hiển thị nhãn `RESTRICTED`) & `SCR-HD-04`
- [ ] Pass test `E2E-3` (ban hành transaction & dừng sớm `STOPPED_EARLY`)

## Lịch sử Commit & Push

> Dùng `.\scripts\log-commit.ps1 -MemberFile "Phạm_Đình_Thịnh.md" -Tested "..."` sau mỗi lần commit để tự động thêm dòng mới vào bảng bên dưới.

| Ngày | Branch | Commit | Nội dung đã làm | Kết quả Test | Ghi chú |
| --- | --- | --- | --- | --- | --- |
| _(mẫu)_ | `feature/prescriptions` | `abcd123` | `feat(mealplan): add prescription copy-day and publish API` | `mvn test PASS` | Xóa dòng mẫu khi bắt đầu |
