# Nhật ký tiến độ — 24521657 – Đặng Trần Thiện

- **Mã nhánh:** `dt-thien` (ví dụ: `feat/dt-thien/sprint0-fe-core-auth`, `feat/dt-thien/onboarding-profile`, `feat/dt-thien/admin-users`)
- **Phạm vi phụ trách (v1.1):** **Sprint 0 Khung React Frontend + CI Frontend** + `UC-AUTH-01..04`, `UC-USER-01`, `UC-PROF-01`
- **Package Backend:** `com.nhom12.nutrition.auth`, `.user`, `.patient` (hồ sơ cơ bản & onboarding; giữ nguyên `PatientIntake`)
- **Thư mục Frontend:** `frontend/src/{app,components,layouts,routes,services,types,utils}`, `.nvmrc`, `.github/workflows/frontend-ci.yml`, `frontend/src/features/{auth,onboarding,profile,admin-users}`
- **Màn hình UI:** 5 Layout dùng chung + `SCR-PUB-01..05, 05B`, `SCR-PAT-06` (hồ sơ cơ bản), `SCR-ADM-00` (khung dashboard), `SCR-ADM-01`
- **Tài liệu chi tiết:** [Đặng_Trần_Thiện_tasks.docx](../tasks/Đặng_Trần_Thiện_tasks.docx) | [AI_TASKS_OVERVIEW.md](../tasks/AI_TASKS_OVERVIEW.md)

> **Lưu ý phân công v1.1:** Bạn làm xong **Sprint 0 (Khung React Frontend + Auth/JWT + `CurrentUser`)** và mở **PR #1** merge sớm lên `main` để 3 bạn còn lại gắn màn hình vào. Để cân bằng tải, `UC-PROF-04` (Tiếp nhận) đã chuyển sang Hồ Đình Phước Thịnh và `UC-PROF-05` (Bệnh lý/Dị ứng) đã chuyển sang Phạm Đình Thịnh.

## Checklist giai đoạn

### Phase A — Sprint 0: Khung React Frontend + Xác thực JWT (**Ưu tiên PR #1**)
- [ ] Khởi tạo `frontend/` (React + TypeScript + Vite + Tailwind CSS + shadcn/ui + React Router + TanStack Query + React Hook Form + Zod + Recharts + Vitest), `.nvmrc`, `package-lock.json` & `.github/workflows/frontend-ci.yml`
- [ ] Dựng 5 layout vai trò (`Public`, `Patient` với banner Cổng hạn chế/Đầy đủ, `Doctor`, `HeadDoctor`, `Admin`), `RoleGuard`, 5 semantic status tokens, `apiClient` (`/api/v1`, JWT + refresh rotation, Vite proxy `:5173 -> :8080`) & slot widget dashboard (`SCR-PAT-01`, `SCR-DOC-01`, `SCR-ADM-00`)
- [ ] Backend Auth: JWT Access/Refresh rotation (`auth_session`), BCrypt, đăng ký `PATIENT` (`patient_code`, `joined_on`), OTP Email (`UC-AUTH-04`), `CurrentUser` helper cho 3 bạn kia dùng chung
- [ ] Rate-limit & khóa tạm đăng nhập sai (`UC-AUTH-01`), Đổi mật khẩu (`UC-AUTH-02`), Đăng xuất (`UC-AUTH-03`), giao diện `SCR-PUB-01..04`

### Phase B — Bảng hỏi Onboarding BMI & Xác minh SĐT
- [ ] Backend + UI Bảng hỏi ban đầu (`Lưu nháp`, tự tính BMI, lựa chọn `Chưa rõ`) & Verify SĐT OTP (`SCR-PUB-05`, `SCR-PUB-05B`)
- [ ] Màn hình Hồ sơ cá nhân cơ bản `SCR-PAT-06` (tab Thông tin cá nhân)

### Phase C — Quản trị tài khoản Admin & Kiểm thử tích hợp
- [ ] API + UI `SCR-ADM-01` (`/admin/users`) tạo nhân sự (+ `clinician`), khóa/mở, đổi role cascade `DOCTOR <-> HEAD_DOCTOR` kèm lý do bắt buộc & ghi `audit_event`
- [ ] Khung `SCR-ADM-00` kết nối số liệu/widget tổng quan + hoàn tất test IDOR & cổng hạn chế `E2E-1`

## Lịch sử Commit & Push

> Dùng `.\scripts\log-commit.ps1 -MemberFile "Đặng_Trần_Thiện.md" -Tested "..."` sau mỗi lần commit để tự động thêm dòng mới vào bảng bên dưới.

| Ngày | Branch | Commit | Nội dung đã làm | Kết quả Test | Ghi chú |
| --- | --- | --- | --- | --- | --- |
| _(mẫu)_ | `feat/dt-thien/sprint0-fe-core-auth` | `abcd123` | `feat(fe-core): init React Vite shell and JWT auth` | `mvn test PASS; npm run build PASS` | Xóa dòng mẫu khi bắt đầu |
