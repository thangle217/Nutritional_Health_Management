# Nhật ký tiến độ — 24521657 – Đặng Trần Thiện

- **Phạm vi phụ trách:** `UC-AUTH-01..04`, `UC-USER-01`, `UC-PROF-01`, `UC-PROF-04`, `UC-PROF-05`
- **Package Backend:** `com.nhom12.nutrition.auth`, `.user`, `.patient`, `.intake`
- **Màn hình UI:** `SCR-PUB-01..05`, `SCR-PAT-06`, `SCR-PAT-07A`, `SCR-DOC-02` (tab Dị ứng/Bệnh lý), `SCR-HD-01B`, `SCR-ADM-01`
- **Tài liệu chi tiết:** [Đặng_Trần_Thiện_tasks.docx](../tasks/Đặng_Trần_Thiện_tasks.docx)

## Checklist giai đoạn

### Phase A — Xác thực & Phân quyền nền
- [ ] JWT Access/Refresh Token + rotation (`auth_session`) & BCrypt
- [ ] Đăng ký bệnh nhân mới + cấp `patient_code`, `joined_on` + OTP Email (`UC-AUTH-04`)
- [ ] Rate-limit & khóa tạm đăng nhập sai (`UC-AUTH-01`), Đổi mật khẩu (`UC-AUTH-02`), Đăng xuất thu hồi session (`UC-AUTH-03`)
- [ ] Màn hình UI `SCR-PUB-01..04`

### Phase B — Hồ sơ, Onboarding & Tiếp nhận
- [ ] Bảng hỏi ban đầu (`Lưu nháp`, tự tính BMI, lựa chọn `Chưa rõ`) + Verify SĐT (`SCR-PUB-05`)
- [ ] Nộp `patient_intake` + upload/download `attachment` có kiểm tra quyền (`SCR-PAT-07A`)
- [ ] Hàng đợi Trưởng khoa duyệt `VERIFIED / NEEDS_INFORMATION / DECLINED` (`SCR-HD-01B`)
- [ ] Quản trị tài khoản Admin + cascade role `DOCTOR <-> HEAD_DOCTOR` (`SCR-ADM-01`)

### Phase C — Khai báo bệnh lý/dị ứng & Kiểm thử tích hợp
- [ ] `ClinicalClaim` + `ClaimReview` (`UC-PROF-05`)
- [ ] Tự tạo `food_safety_review` khi `CONFIRMED` dị ứng trùng `applied_prescription_day`
- [ ] Hoàn tất test IDOR & E2E-1 trong đặc tả

## Lịch sử Commit & Push

> Dùng `.\scripts\log-commit.ps1 -MemberFile "Đặng_Trần_Thiện.md" -Tested "..."` sau mỗi lần commit để tự động thêm dòng mới vào bảng bên dưới.

| Ngày | Branch | Commit | Nội dung đã làm | Kết quả Test | Ghi chú |
| --- | --- | --- | --- | --- | --- |
| _(mẫu)_ | `feature/auth-intake` | `abcd123` | `feat(auth): implement register and email OTP` | `mvn test PASS` | Xóa dòng mẫu khi bắt đầu |
