# Nhật ký tiến độ — 24521666 – Phan Viết Thiện

- **Phạm vi phụ trách:** `UC-JOUR-01..03`, `UC-METR-01`, `UC-ALRT-01..02`, `UC-REPO-01..02`, `UC-AUDT-01`, Job `BR-06` & `BR-07`
- **Package Backend:** `com.nhom12.nutrition.journal`, `.healthmetric`, `.alert`, `.report`, `.audit`
- **Màn hình UI:** `SCR-PAT-01, 03, 03B, 04, 05`, `SCR-DOC-01, 05, 06, 08`, `SCR-HD-05, 06`, `SCR-ADM-00, 03, 04`
- **Tài liệu chi tiết:** [Phan_Viết_Thiện_tasks.docx](../tasks/Phan_Viết_Thiện_tasks.docx)

## Checklist giai đoạn

### Phase A — Nhật ký 48h & Cảnh báo Vàng Calo (`BR-03`, `BR-04`, `UC-JOUR-03`)
- [ ] Ghi 6 bữa (`AS_PLANNED/DIFFERENT/SKIPPED`) & `journal_water` + lưu snapshot dinh dưỡng lúc ghi
- [ ] Nút `Gửi nhật ký ngày` (cảnh báo bữa thiếu, gửi 1 bản/ngày, tạo thẻ Chat & thông báo Bác sĩ)
- [ ] Tự sửa trong 48h (`Asia/Ho_Chi_Minh`) ghi `journal_revision`; quá 48h tạo `journal_correction_request` cho bác sĩ duyệt
- [ ] Đánh giá Calo: đúng 15% không báo, `> 15%` hai chiều tạo/cập nhật 1 Cảnh báo Vàng/ngày

### Phase B — Chỉ số, Ngưỡng Đỏ SLA & Job nền Idempotent (`BR-05`, `BR-06`, `BR-07`)
- [ ] Nhập cân nặng/BMI, HA theo cặp (`>=`), đường huyết kèm bối cảnh + `replaces_id` giữ nguồn cũ
- [ ] Cấu hình `threshold_rule` (`condition_priority` cá nhân -> bệnh lý -> chung) & `Alert RED` SLA `60p/2h` (tách Đọc != Tiếp nhận != Giải quyết)
- [ ] Spring Scheduler `BR-06` (ngày thứ 2 báo cáo, thứ 3 nhắc, thứ 6 tự tạm ngưng trừ ngày `PAUSED APPROVED`) & `BR-07` (nhắc trước `end_date` 3 ngày) dùng `dedupe_key`

### Phase C — 7 Nhóm Báo cáo CSV, Biểu đồ & Vận hành Admin
- [ ] 4 nhóm biểu đồ tiến độ (`SCR-PAT-05`) & 6 báo cáo chuyên môn + xuất CSV giữ đúng bác sĩ tại thời điểm phát sinh (`SCR-HD-06`)
- [ ] Quản lý `system_setting` (+ `system_setting_history` bắt buộc lý do), `operation_run`, Audit Log che lâm sàng mặc định & báo cáo thứ 7
- [ ] Pass test `E2E-4`, `E2E-5`, `E2E-6`, `E2E-8`

## Lịch sử Commit & Push

> Dùng `.\scripts\log-commit.ps1 -MemberFile "Phan_Viết_Thiện.md" -Tested "..."` sau mỗi lần commit để tự động thêm dòng mới vào bảng bên dưới.

| Ngày | Branch | Commit | Nội dung đã làm | Kết quả Test | Ghi chú |
| --- | --- | --- | --- | --- | --- |
| _(mẫu)_ | `feature/journal-alerts` | `abcd123` | `feat(journal): enforce 48h window and >15% calorie alert` | `mvn test PASS` | Xóa dòng mẫu khi bắt đầu |
