# Hướng dẫn Chia nhánh Git, Cộng tác & Prompt mẫu cho AI Agent — Nhóm 12

Tài liệu này giúp 5 thành viên làm việc song song **ít xung đột nhất** trên cùng monorepo (Backend Spring Boot + Frontend React) và hỗ trợ làm việc chung với các AI coding agent.

---

## 1. Chiến lược chia nhánh GitHub (Trunk-Based nhẹ)

Nhóm chỉ dùng **1 nhánh gốc duy nhất là `main`** (không tạo `develop` để tránh lệch code) và các **nhánh chức năng ngắn hạn**:

- **`main`:** Nhánh ổn định, luôn build xanh CI (`backend-ci.yml` và `frontend-ci.yml` sau Sprint 0). **Cấm push trực tiếp lên `main`**, mọi thay đổi phải đi qua Pull Request.
- **Nhánh cá nhân theo tính năng:**
  - Quy ước đặt tên: `feat/<mã-thành-viên>/<phạm-vi-ngắn>` (hoặc `fix/<mã-thành-viên>/<mô-tả-lỗi>`).
  - Bảng mã thành viên cố định & ví dụ nhánh cụ thể:

| Thành viên | Mã nhánh | Ví dụ nhánh theo từng giai đoạn (làm xong 1 phase -> PR -> merge -> tạo nhánh mới) |
| --- | --- | --- |
| **24521657 – Đặng Trần Thiện** | `dt-thien` | `feat/dt-thien/sprint0-fe-core-auth` **(ưu tiên PR #1)**, `feat/dt-thien/onboarding-profile`, `feat/dt-thien/admin-users` |
| **24521679 – Hồ Đình Phước Thịnh** | `hdp-thinh` | `feat/hdp-thinh/intake-30slots`, `feat/hdp-thinh/pause-appointments`, `feat/hdp-thinh/chat-notifications` |
| **24521702 – Phạm Đình Thịnh** | `pd-thinh` | `feat/pd-thinh/foods-templates`, `feat/pd-thinh/prescriptions-publish`, `feat/pd-thinh/clinical-declarations` |
| **24521666 – Phan Viết Thiện** | `pv-thien` | `feat/pv-thien/journal-yellow-alert`, `feat/pv-thien/metrics-alerts-jobs`, `feat/pv-thien/reports-admin-ops` |

---

## 2. Thứ tự triển khai để không bị chặn nhau (Sprint 0 -> Sprint 2)

```text
Tuần 1 (Sprint 0 + Song song Backend Phase A):
  [Đặng Trần Thiện]  feat/dt-thien/sprint0-fe-core-auth  ──► PR #1 lên main (FE Core + Auth/JWT + CurrentUser)
  [3 bạn còn lại]    Code Backend Phase A trên nhánh riêng (test Controller bằng @WithMockUser)
                                    │
                                    ▼ (Sau khi PR #1 đã merge lên main)
Tuần 1–2 (Sprint 1):
  Cả nhóm: git pull origin main về nhánh của mình -> Gắn @AuthenticationPrincipal/CurrentUser + Code UI features/*
  Mỗi xong 1 module (BE + FE) -> Mở PR vào main -> Nhóm trưởng review + CI xanh -> Merge -> Nhóm pull main
```

---

## 3. Quy trình làm việc hằng ngày (5 bước)

### Bước 1: Thiết lập 1 lần sau khi clone repo
```powershell
git config commit.template .gitmessage
git config core.quotepath false
```

### Bước 2: Cập nhật `main` mới nhất và tạo nhánh task mới
```powershell
git checkout main
git pull origin main
git checkout -b feat/hdp-thinh/intake-30slots
```
*(Nếu nhánh đang code cần lấy thêm code mới từ `main`: `git fetch origin && git merge origin/main` hoặc `git rebase origin/main` rồi chạy lại test.)*

### Bước 3: Code đúng phạm vi & kiểm thử trước khi commit
- Đọc kỹ `AGENTS.md` và `docs/tasks/AI_TASKS_OVERVIEW.md` để không chạm chéo thư mục của bạn khác.
- Chạy kiểm thử:
  ```powershell
  cd backend
  mvn -B test
  ```
  *(Khi `frontend/` đã có từ Sprint 0, chạy thêm trong `frontend/`: `npm run lint`, `npm test`, `npm run build`.)*

### Bước 4: Commit & tự động ghi nhật ký tiến độ (`Zero Merge Conflict`)
```powershell
git status
git commit -m "feat(intake): implement intake submission and HEAD_DOCTOR review"
.\scripts\log-commit.ps1 -MemberFile "Hồ_Đình_Phước_Thịnh.md" -Tested "mvn test PASS" -Notes "Hoàn tất UC-PROF-04"
git add docs/progress/Hồ_Đình_Phước_Thịnh.md
git commit --amend --no-edit
git push -u origin feat/hdp-thinh/intake-30slots
```
> **Lưu ý bảo mật:** Luôn kiểm tra `git status` để chắc chắn **KHÔNG** có `.env`, `backend/target/`, `frontend/node_modules/`, hoặc file lock Word `~$*`.

### Bước 5: Tạo Pull Request vào `main`
- GitHub tự điền mẫu [.github/PULL_REQUEST_TEMPLATE.md](./.github/PULL_REQUEST_TEMPLATE.md).
- Điền rõ Use Case, màn hình `SCR-*`, endpoint và cách kiểm thử (đính kèm ảnh chụp màn hình nếu có thay đổi React UI).
- Chờ CI pass và Nhóm trưởng (`24521605 – Lê Trần Quang Thắng`) duyệt merge.

---

## 4. Cài đặt Branch Protection trên GitHub (Dành cho Nhóm trưởng)

Trên GitHub repo -> **Settings -> Branches -> Add branch protection rule**:
- **Branch name pattern:** `main`
- Bật **Require a pull request before merging** (`Require approvals: 1`)
- Bật **Require status checks to pass before merging** -> chọn check `Run Maven Unit & Consistency Tests` (và thêm check Frontend CI sau khi PR #1 merge)
- Bật **Do not allow bypassing the above settings** (hoặc nhắc cả nhóm không push trực tiếp lên `main`).

---

## 5. Prompt mẫu gửi cho AI Agent khi bắt đầu code

Mỗi thành viên chỉ cần mở repo trong IDE/AI tool (Antigravity, Claude Code, Cursor, Copilot...), **chuyển đúng sang nhánh task của mình**, rồi copy-paste prompt tương ứng bên dưới:

### Prompt cho 24521657 – Đặng Trần Thiện (Sprint 0 FE Core + Auth + Onboarding + Admin Users)
```text
Tôi là Đặng Trần Thiện (MSSV 24521657). Hãy đọc kỹ AGENTS.md, CONTRIBUTING.md, docs/tasks/AI_TASKS_OVERVIEW.md, docs/progress/Đặng_Trần_Thiện.md, docs/specs/PROJECT_TECH_STACK_AND_CONVENTIONS.docx (mục 4-5, 9-11) và docs/database/README.md.
Kiểm tra git branch hiện tại (tạo nhánh feat/dt-thien/<scope> nếu đang ở main).
Nhiệm vụ của tôi trong đợt này là: [MÔ TẢ PHASE/TASK CỤ THỂ, VD: Sprint 0 — Dựng khung frontend React+TS+Vite+Tailwind+shadcn/ui với 5 layout vai trò, RoleGuard, apiClient + Hoàn thiện Backend JWT Auth UC-AUTH-01..04 và CurrentUser helper].
Quy tắc bắt buộc: chỉ tạo/sửa file trong phạm vi sở hữu của tôi, KHÔNG sửa V1..V3 SQL hoặc package của thành viên khác, giữ đúng error contract ApiErrorResponse và đơn vị/múi giờ. Lập kế hoạch ngắn gọn để tôi duyệt trước khi viết code.
```

### Prompt cho 24521679 – Hồ Đình Phước Thịnh (Tiếp nhận, 30 ca, Tạm dừng, Lịch khám & Chat)
```text
Tôi là Hồ Đình Phước Thịnh (MSSV 24521679). Hãy đọc kỹ AGENTS.md, CONTRIBUTING.md, docs/tasks/AI_TASKS_OVERVIEW.md, docs/progress/Hồ_Đình_Phước_Thịnh.md và docs/database/README.md.
Kiểm tra git branch hiện tại (tạo nhánh feat/hdp-thinh/<scope> nếu đang ở main).
Nhiệm vụ của tôi trong đợt này là: [MÔ TẢ PHASE/TASK CỤ THỂ, VD: Phase A — API Tiếp nhận patient_intake (UC-PROF-04) + Quản lý tải 30 ca TRACKING có khóa hàng chống đồng thời (BR-01)].
Quy tắc bắt buộc: chỉ sửa trong com.nhom12.nutrition.{intake,doctor,communication}, frontend/src/features/{intake,assignments,tracking-pauses,appointments,chat,notifications} và docs/progress/Hồ_Đình_Phước_Thịnh.md; không di chuyển PatientIntake.java, không sửa V1..V3 SQL, kiểm tra Role/IDOR ở Backend và chạy mvn -B test pass trước khi báo xong. Lập kế hoạch ngắn gọn để tôi duyệt trước khi viết code.
```

### Prompt cho 24521702 – Phạm Đình Thịnh (Bệnh lý/Dị ứng, Món ăn, Thực đơn mẫu & Phiếu chỉ định)
```text
Tôi là Phạm Đình Thịnh (MSSV 24521702). Hãy đọc kỹ AGENTS.md, CONTRIBUTING.md, docs/tasks/AI_TASKS_OVERVIEW.md, docs/progress/Phạm_Đình_Thịnh.md và docs/database/README.md.
Kiểm tra git branch hiện tại (tạo nhánh feat/pd-thinh/<scope> nếu đang ở main).
Nhiệm vụ của tôi trong đợt này là: [MÔ TẢ PHASE/TASK CỤ THỂ, VD: Phase A — Danh mục Món ăn (Food/FoodVersion IN_REVIEW->PUBLISHED), Thực đơn mẫu và Khai báo Bệnh lý/Dị ứng (UC-PROF-05)].
Quy tắc bắt buộc: chỉ sửa trong com.nhom12.nutrition.{clinical,food,mealplan}, frontend/src/features/{declarations,foods,templates,prescriptions} và docs/progress/Phạm_Đình_Thịnh.md; ban hành/đóng phiếu bắt buộc gọi PrescriptionProcedureService, không sửa V1..V3 SQL, kiểm tra Role/IDOR ở Backend và chạy mvn -B test pass. Lập kế hoạch ngắn gọn để tôi duyệt trước khi viết code.
```

### Prompt cho 24521666 – Phan Viết Thiện (Nhật ký 48h, Chỉ số, Cảnh báo Đỏ/Vàng, Job BR-06/07 & Báo cáo)
```text
Tôi là Phan Viết Thiện (MSSV 24521666). Hãy đọc kỹ AGENTS.md, CONTRIBUTING.md, docs/tasks/AI_TASKS_OVERVIEW.md, docs/progress/Phan_Viết_Thiện.md và docs/database/README.md.
Kiểm tra git branch hiện tại (tạo nhánh feat/pv-thien/<scope> nếu đang ở main).
Nhiệm vụ của tôi trong đợt này là: [MÔ TẢ PHASE/TASK CỤ THỂ, VD: Phase A — Nhật ký 6 bữa + snapshot dinh dưỡng, hạn sửa 48h Asia/Ho_Chi_Minh và Cảnh báo vàng Calo >15%].
Quy tắc bắt buộc: chỉ sửa trong com.nhom12.nutrition.{journal,healthmetric,alert,report,audit}, frontend/src/features/{journals,metrics,alerts,reports,admin-ops} và docs/progress/Phan_Viết_Thiện.md; không sửa V1..V3 SQL, đảm bảo idempotency cho Alert Đỏ & Job BR-06/BR-07, chạy mvn -B test pass trước khi báo xong. Lập kế hoạch ngắn gọn để tôi duyệt trước khi viết code.
```
