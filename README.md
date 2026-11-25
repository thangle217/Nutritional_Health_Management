# Nhóm 12 — Hệ thống quản lý dinh dưỡng và thực đơn cá nhân

Khung dự án Monorepo (**Backend Spring Boot 3 + Flyway + PostgreSQL 17** và **Frontend React + TypeScript + Vite**) được chuẩn hóa đồng bộ từ:
- **Quy chuẩn cho AI Agent:** [AGENTS.md](./AGENTS.md) (và [CLAUDE.md](./CLAUDE.md))
- **Hướng dẫn chia nhánh Git, quy trình PR & Prompt mẫu cho AI:** [CONTRIBUTING.md](./CONTRIBUTING.md)
- **Tóm tắt phân công v1.1 dạng Markdown (AI đọc trực tiếp):** [AI_TASKS_OVERVIEW.md](./docs/tasks/AI_TASKS_OVERVIEW.md)
- Đặc tả công nghệ & quy ước: [PROJECT_TECH_STACK_AND_CONVENTIONS.docx](./docs/specs/PROJECT_TECH_STACK_AND_CONVENTIONS.docx)
- Tài liệu phân tích hệ thống (v1.4): [Nhom12_Analysis.doc](./docs/specs/Nhom12_Analysis.doc)
- Mô hình Use Case: [Nhóm12_Mô_Hình_Usecase.doc](./docs/specs/Nhóm12_Mô_Hình_Usecase.doc)
- **Đặc tả giao diện UI & luồng màn hình (kèm wireframe & checklist test):** [Nhom12_Dac_Ta_UI_va_Luong_Man_Hinh.docx](./docs/specs/Nhom12_Dac_Ta_UI_va_Luong_Man_Hinh.docx)
- Bộ SQL chuẩn PostgreSQL 17: [docs/database/README.md](./docs/database/README.md)

## 1. Cấu trúc Repository

```text
nutrition-management/
├── AGENTS.md                    # Luật sở hữu thư mục, Sprint 0 & quy chuẩn cứng cho AI Coding Agents
├── CLAUDE.md                    # Điểm vào cho Claude Code (trỏ sang AGENTS.md & CONTRIBUTING.md)
├── CONTRIBUTING.md              # Chiến lược chia nhánh GitHub, checklist PR & prompt mẫu cho 4 thành viên
├── .env.example                 # Biến môi trường mẫu (sao chép thành .env khi chạy local; KHÔNG commit .env)
├── .gitignore                   # Bỏ qua target/, node_modules/, dist/, .env, data/, uploads/, ~$*
├── .gitmessage                  # Mẫu commit chuẩn (<type>(<scope>): <mô tả>)
├── .github/
│   ├── PULL_REQUEST_TEMPLATE.md # Mẫu Pull Request đối chiếu UC, màn hình UI, BE/FE test & checklist
│   └── workflows/backend-ci.yml # GitHub Actions tự động chạy mvn -B test khi push/PR
├── docker-compose.yml           # Tùy chọn chạy PostgreSQL 17 bằng Docker
├── scripts/
│   ├── init-db.ps1              # Script PowerShell tạo DB nhom12_dev (tự dò service PostgreSQL Windows)
│   └── log-commit.ps1           # Script tự động ghi lịch sử commit vào docs/progress/<Họ_Tên>.md
├── docs/
│   ├── specs/                   # Các tài liệu đặc tả chính thức (Usecase, Analysis, Tech Stack, UI Spec)
│   ├── tasks/                   # AI_TASKS_OVERVIEW.md + 4 file Word giao việc riêng (*_tasks.docx, bản v1.1)
│   ├── progress/                # Nhật ký tiến độ & lịch sử commit riêng từng thành viên (chống conflict)
│   ├── diagrams/                # Toàn bộ sơ đồ Draw.io nguồn (.drawio) & ảnh xuất (.png) theo 7 nhóm
│   └── database/                # 001_schema.sql, 002_publish_prescription.sql, 003_seed_dev.sql, 090_verify.sql
├── frontend/                    # (Khởi tạo ở Sprint 0 bởi Đặng Trần Thiện: React + TS + Vite + Tailwind + shadcn/ui)
└── backend/
    ├── pom.xml                  # Spring Boot 3.5.16, Java 17 (tương thích JDK 21), Flyway + PostgreSQL
    └── src/
        ├── main/resources/
        │   ├── application.yml
        │   ├── application-dev.yml
        │   ├── db/migration/    # V1__init_schema.sql, V2__publish_prescription_and_views.sql
        │   └── db/seed/         # V3__dev_seed.sql (tự nạp khi chạy profile dev)
        ├── main/java/com/nhom12/nutrition/
        │   ├── shared/          # Security, CORS, OpenAPI, ExceptionHandler, Health & Reference endpoints
        │   ├── auth/            # Role, UserStatus, AppUser, AppUserRepository
        │   ├── user/            # UC-USER-01 (chờ triển khai chi tiết)
        │   ├── patient/         # Patient, PatientIntake, IntakeStatus, PatientRepository
        │   ├── intake/          # UC-PROF-04 Tiếp nhận bệnh nhân (Hồ Đình Phước Thịnh)
        │   ├── clinical/        # UC-PROF-05 Bệnh lý/Dị ứng & FoodSafetyReview (Phạm Đình Thịnh)
        │   ├── doctor/          # Clinician, Assignment, AssignmentStatus, AssignmentRepository
        │   ├── communication/   # UC-APPT-01, UC-COMM-01, Notification Outbox (Hồ Đình Phước Thịnh)
        │   ├── food/            # Food, FoodVersion, FoodGroup, FoodStatus, FoodGroupRepository
        │   ├── mealplan/        # Prescription, PrescriptionVersion, PrescriptionProcedureService
        │   ├── journal/         # UC-JOUR-01..03 (chờ triển khai chi tiết)
        │   ├── healthmetric/    # VitalKind + chỉ số sức khỏe (chờ triển khai chi tiết)
        │   ├── alert/           # AlertStatus + cảnh báo vàng/đỏ (chờ triển khai chi tiết)
        │   ├── report/          # 7 nhóm báo cáo & tác vụ nền BR-06/BR-07 (chờ triển khai chi tiết)
        │   └── audit/           # AuditEvent, SystemSetting, SystemSettingRepository
        └── test/java/com/nhom12/nutrition/
            └── MigrationFilesConsistencyTest.java # Kiểm tra đồng bộ Flyway <-> docs/database & BCrypt demo
```

> Lưu ý: `pom.xml` đặt `java.version = 17` để chạy ngay trên **JDK 17 LTS** và hoàn toàn tương thích **JDK 21 LTS**.

## 2. Hướng dẫn cài đặt PostgreSQL 17 & khởi chạy lần đầu

### Bước 1: Cài PostgreSQL 17 trên Windows
- Tải bộ cài tại https://www.postgresql.org/download/windows/ (chọn **PostgreSQL 17.x** Windows x86-64, giữ nguyên Port mặc định **`5432`**) hoặc mở PowerShell (Administrator):
  ```powershell
  winget install --id PostgreSQL.PostgreSQL.17 -e
  ```
- Ghi nhớ mật khẩu bạn đặt cho user `postgres`.

### Bước 2: Tạo file `.env` và database `nhom12_dev`
1. Sao chép `.env.example` thành `.env` tại gốc repo `nutrition-management\` và điền `DATABASE_PASSWORD=<mật khẩu postgres của bạn>`.
2. Chạy script khởi tạo DB (script tự tìm `psql.exe` qua `PATH` hoặc dịch vụ Windows `postgresql*`):
   ```powershell
   .\scripts\init-db.ps1
   ```
   *(Nếu muốn nạp thẳng SQL chuẩn thay vì chờ Flyway, thêm `-RunSqlDirect`, hoặc `-RunSqlDirect -RunVerify` để chạy thêm `docs/database/090_verify.sql`.)*

### Bước 3: Chạy Spring Boot Backend (tự động migrate Flyway + seed dữ liệu demo)
```powershell
cd backend
mvn spring-boot:run
```

Khi khởi động ở profile mặc định `dev`:
1. Flyway tự tạo schema `nutrition` và chạy `V1__init_schema.sql`, `V2__publish_prescription_and_views.sql`, `V3__dev_seed.sql`.
2. Hibernate chạy `ddl-auto: validate` đối chiếu toàn bộ Entity Java với 54 bảng + 3 view PostgreSQL thật.
3. Mở trình duyệt kiểm tra:
   - Health check + PostgreSQL version + số bảng schema `nutrition`: `http://localhost:8080/api/v1/health`
   - Tham chiếu danh mục món ăn: `http://localhost:8080/api/v1/reference/food-groups`
   - Tham số vận hành hệ thống: `http://localhost:8080/api/v1/reference/system-settings`
   - Tài liệu Swagger UI: `http://localhost:8080/swagger-ui.html`

## 3. Tài khoản demo được seed sẵn (`V3__dev_seed.sql`)

Mật khẩu chung cho toàn bộ tài khoản demo dev (đã băm bằng `BCrypt`): **`Demo@123456`**

| Vai trò | Email | Trạng thái / Ghi chú |
| --- | --- | --- |
| `ADMIN` | `admin@nhom12.local` | Quản trị hệ thống |
| `HEAD_DOCTOR` | `truongkhoa@nhom12.local` | BS.CKII Trần Minh Khôi — Trưởng khoa |
| `DOCTOR` | `bacsi1@nhom12.local` | BS. Nguyễn Lan Anh — đang theo dõi 1 ca `TRACKING` |
| `DOCTOR` | `bacsi2@nhom12.local` | BS. Phạm Quốc Huy — 1 ca đang `PAUSED` |
| `PATIENT` | `benhnhan1@nhom12.local` | Lê Văn An — đã xác minh, đang `TRACKING` |
| `PATIENT` | `benhnhan2@nhom12.local` | Nguyễn Thị Bình — hồ sơ tiếp nhận `SUBMITTED` chờ Trưởng khoa duyệt |
| `PATIENT` | `benhnhan3@nhom12.local` | Trần Hoàng Cường — đang `PAUSED` hợp lệ (4 ngày) |

## 4. Phân công công việc Nhóm 12 (v1.1 — Kèm React Frontend)

- **24521605 – Lê Trần Quang Thắng (Nhóm trưởng):** Thiết kế hệ thống, Database PostgreSQL 17, UML, UI Spec ([Nhom12_Dac_Ta_UI_va_Luong_Man_Hinh.docx](./docs/specs/Nhom12_Dac_Ta_UI_va_Luong_Man_Hinh.docx)), khung Spring Boot Backend, quy chuẩn AI agent & review Pull Request.
- **24521657 – Đặng Trần Thiện (`dt-thien`):** **Sprint 0 Khung React Frontend + CI Frontend** (5 layout vai trò, `RoleGuard`, `apiClient`) + Auth/JWT (`UC-AUTH-01..04`), Onboarding BMI (`UC-PROF-01`) & Quản trị tài khoản (`UC-USER-01`, `SCR-ADM-00..01`) — xem [Đặng_Trần_Thiện_tasks.docx](./docs/tasks/Đặng_Trần_Thiện_tasks.docx).
- **24521679 – Hồ Đình Phước Thịnh (`hdp-thinh`):** Tiếp nhận bệnh nhân (`UC-PROF-04`), Phân công 30 ca (`BR-01`), Tạm dừng (`UC-PROF-03`), Lịch khám (`UC-APPT-01`), Chat & Notification Outbox (BE + FE) — xem [Hồ_Đình_Phước_Thịnh_tasks.docx](./docs/tasks/Hồ_Đình_Phước_Thịnh_tasks.docx).
- **24521702 – Phạm Đình Thịnh (`pd-thinh`):** Bệnh lý/Dị ứng & `FoodSafetyReview` (`UC-PROF-05`), Món ăn (`UC-FOOD-01`), Thực đơn mẫu (`UC-PLAN-01`), Phiếu chỉ định (`UC-PRES-01..02`, `BR-02/08`) (BE + FE) — xem [Phạm_Đình_Thịnh_tasks.docx](./docs/tasks/Phạm_Đình_Thịnh_tasks.docx).
- **24521666 – Phan Viết Thiện (`pv-thien`):** Nhật ký 48h, Chỉ số sức khỏe, Cảnh báo Đỏ/Vàng (`SLA 60p/2h`), Job `BR-06/07`, 7 Báo cáo CSV & Audit (BE + FE widget/screens) — xem [Phan_Viết_Thiện_tasks.docx](./docs/tasks/Phan_Viết_Thiện_tasks.docx).

## 5. Bắt đầu nhanh cho Thành viên & AI Agent

Đọc đầy đủ quy trình chia nhánh và prompt mẫu cho AI tại [AGENTS.md](./AGENTS.md), [CONTRIBUTING.md](./CONTRIBUTING.md) và [docs/progress/README.md](./docs/progress/README.md). Tóm tắt hằng ngày:
1. Thiết lập 1 lần sau khi clone repo:
   ```powershell
   git config commit.template .gitmessage
   git config core.quotepath false
   ```
2. Tạo nhánh ngắn từ `main` theo mã của bạn (`feat/dt-thien/...`, `feat/hdp-thinh/...`, `feat/pd-thinh/...`, `feat/pv-thien/...`):
   ```powershell
   git checkout main
   git pull origin main
   git checkout -b feat/hdp-thinh/intake-30slots
   ```
3. Sau khi test PASS và `git commit`, ghi nhật ký tiến độ riêng của bạn (**chỉ sửa file mang tên mình** trong `docs/progress/`):
   ```powershell
   .\scripts\log-commit.ps1 -MemberFile "Hồ_Đình_Phước_Thịnh.md" -Tested "mvn test PASS" -Notes "Hoàn tất ..."
   git add docs/progress/Hồ_Đình_Phước_Thịnh.md
   git commit --amend --no-edit
   git push -u origin feat/hdp-thinh/intake-30slots
   ```
4. Tạo Pull Request vào `main` theo mẫu [.github/PULL_REQUEST_TEMPLATE.md](./.github/PULL_REQUEST_TEMPLATE.md).
