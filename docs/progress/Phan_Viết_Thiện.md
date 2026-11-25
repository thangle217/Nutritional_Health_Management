# Nhật ký tiến độ — 24521666 – Phan Viết Thiện

- **Mã nhánh:** `pv-thien` (ví dụ: `feat/pv-thien/journal-yellow-alert`, `feat/pv-thien/metrics-alerts-jobs`, `feat/pv-thien/reports-admin-ops`)
- **Phạm vi phụ trách (v1.1):** `UC-JOUR-01..03`, `UC-METR-01`, `UC-ALRT-01..02`, `UC-REPO-01..02`, `UC-AUDT-01`, Job `BR-06` & `BR-07` (BE + FE)
- **Package Backend:** `com.nhom12.nutrition.journal`, `.healthmetric`, `.alert`, `.report`, `.audit`
- **Thư mục Frontend:** `frontend/src/features/{journals,metrics,alerts,reports,admin-ops}`
- **Màn hình UI:** `SCR-PAT-01` (widget theo dõi), `SCR-PAT-03`, `SCR-PAT-03B`, `SCR-PAT-04`, `SCR-PAT-05`, `SCR-DOC-01` (widget theo dõi/cảnh báo), `SCR-DOC-05` (hiệu chỉnh 48h), `SCR-DOC-06`, `SCR-DOC-08`, `SCR-HD-05`, `SCR-HD-06`, `SCR-ADM-03`, `SCR-ADM-04`
- **Tài liệu chi tiết:** [Phan_Viết_Thiện_tasks.docx](../tasks/Phan_Viết_Thiện_tasks.docx) | [AI_TASKS_OVERVIEW.md](../tasks/AI_TASKS_OVERVIEW.md)

> **Lưu ý phân công v1.1:** Khung layout tổng và `SCR-ADM-00` do Đặng Trần Thiện dựng sẵn ở Sprint 0; bạn tập trung các màn hình nghiệp vụ bên dưới và cắm widget KPI vào slot của `SCR-PAT-01`, `SCR-DOC-01`. Trong tuần đầu chưa có `frontend/`, bạn code Backend Phase A dùng `@WithMockUser` bình thường, rồi pull `main` sau PR #1.

## Checklist giai đoạn

### Phase A — Nhật ký 48h & Cảnh báo Vàng Calo (`BR-03`, `BR-04`, `UC-JOUR-03`)
- [ ] Ghi 6 bữa (`AS_PLANNED/DIFFERENT/SKIPPED`) & `journal_water` + lưu snapshot dinh dưỡng lúc ghi
- [ ] Nút `Gửi nhật ký ngày` (cảnh báo bữa thiếu, gửi 1 bản/ngày, tạo thẻ Chat & thông báo Bác sĩ)
- [ ] Tự sửa trong 48h (`Asia/Ho_Chi_Minh`) ghi `journal_revision`; quá 48h tạo `journal_correction_request` cho bác sĩ duyệt (`SCR-DOC-05`)
- [ ] Đánh giá Calo: đúng `15.0%` không báo, `> 15%` hai chiều tạo/cập nhật 1 Cảnh báo Vàng/ngày (`SCR-PAT-03`, `SCR-PAT-03B`)

### Phase B — Chỉ số, Ngưỡng Đỏ SLA & Job nền Idempotent (`BR-05`, `BR-06`, `BR-07`)
- [ ] Nhập cân nặng/BMI, HA theo cặp (`Systolic >= Diastolic`), đường huyết kèm bối cảnh + `replaces_id` giữ nguồn cũ (`SCR-PAT-04`)
- [ ] Cấu hình `threshold_rule` (`condition_priority` cá nhân -> bệnh lý -> chung) tại `SCR-HD-05` & `Alert RED` SLA `60p/2h` tại `SCR-DOC-06` (tách Đọc != Tiếp nhận != Giải quyết)
- [ ] Spring Scheduler `BR-06` (ngày thứ 2 báo cáo, thứ 3 nhắc, thứ 6 tự tạm ngưng trừ ngày `PAUSED APPROVED`) & `BR-07` (nhắc trước `end_date` 3 ngày) dùng `dedupe_key`

### Phase C — 7 Nhóm Báo cáo CSV, Biểu đồ & Vận hành Admin
- [ ] 4 nhóm biểu đồ tiến độ Recharts (`SCR-PAT-05`) & widget `SCR-PAT-01`, `SCR-DOC-01`
- [ ] 6 báo cáo chuyên môn + xuất CSV giữ đúng bác sĩ tại thời điểm phát sinh (`SCR-DOC-08`, `SCR-HD-06`)
- [ ] Quản lý `system_setting` (+ `system_setting_history` bắt buộc lý do), `operation_run`, Audit Log che lâm sàng mặc định & báo cáo thứ 7 (`SCR-ADM-03`, `SCR-ADM-04`)
- [ ] Pass test `E2E-4`, `E2E-5`, `E2E-6`, `E2E-8`

## Lịch sử Commit & Push

> Dùng `.\scripts\log-commit.ps1 -MemberFile "Phan_Viết_Thiện.md" -Tested "..."` sau mỗi lần commit để tự động thêm dòng mới vào bảng bên dưới.

| Ngày | Branch | Commit | Nội dung đã làm | Kết quả Test | Ghi chú |
| --- | --- | --- | --- | --- | --- |
| _(mẫu)_ | `feat/pv-thien/journal-yellow-alert` | `abcd123` | `feat(journal): enforce 48h window and >15% calorie alert` | `mvn test PASS` | Xóa dòng mẫu khi bắt đầu |
