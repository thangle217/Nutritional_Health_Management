# AGENTS.md — Quy chuẩn bắt buộc cho AI Coding Agents (Nhóm 12)

Tài liệu này là **luật chung** cho mọi AI agent (Antigravity, Claude Code, Cursor, GitHub Copilot, Codex, Windsurf) khi làm việc trong repository `Nutritional_Health_Management`.

---

## 1. Kiến trúc & Tech Stack đã khóa (KHÔNG tự ý đổi)

| Thành phần | Công nghệ & Quy ước |
| --- | --- |
| **Backend** | Java 17 LTS (tương thích JDK 21 LTS) + Spring Boot `3.5.16` + Spring Data JPA + Spring Security + Flyway + Spring Scheduler |
| **Database** | PostgreSQL 17 (`port 5432`), 1 schema duy nhất `nutrition` (`54` bảng + `3` view đã tạo sẵn trong `V1..V3`) |
| **Frontend** | **React + TypeScript + Vite** đặt tại `frontend/` (cùng monorepo), Node.js LTS (`.nvmrc`, commit `package-lock.json`) |
| **UI Library** | **Tailwind CSS + shadcn/ui ONLY** — tuyệt đối KHÔNG trộn thêm MUI, Ant Design, Chakra hay Bootstrap |
| **FE State/Form/Chart** | **React Router** + **TanStack Query** + **React Hook Form + Zod** + **Recharts** + **Vitest / React Testing Library** |
| **API & CORS** | Base path `/api/v1`; dev backend `:8080`, Vite dev `:5173` (CORS đã mở `http://localhost:5173`) |

> Chi tiết nghiệp vụ & quy ước sâu đọc thêm tại `docs/specs/PROJECT_TECH_STACK_AND_CONVENTIONS.docx`, `docs/specs/Nhom12_Dac_Ta_UI_va_Luong_Man_Hinh.docx`, và `docs/database/README.md`.

---

## 2. Quy trình Pre-Flight bắt buộc TRƯỚC khi sửa code

Mỗi lần bắt đầu một task mới, AI agent PHẢI làm đủ 4 bước sau trước khi viết bất kỳ dòng code nào:
1. Đọc theo thứ tự: `AGENTS.md` -> `CONTRIBUTING.md` -> `docs/tasks/AI_TASKS_OVERVIEW.md` -> file `docs/progress/<Họ_Tên>.md` của thành viên đang giao việc -> `docs/database/README.md`.
2. Kiểm tra nhánh Git hiện tại bằng `git branch --show-current`: **KHÔNG bao giờ sửa/commit trực tiếp trên `main`**. Nếu đang ở `main`, tạo hoặc chuyển sang nhánh `feat/<mã-tên>/<phạm-vi>` (xem `CONTRIBUTING.md`).
3. Đối chiếu đúng phạm vi bảng DB, endpoint `/api/v1/...`, màn hình `SCR-*` và **thư mục được phép sửa** ở Mục 3 bên dưới.
4. Trình bày ngắn gọn kế hoạch thay đổi (file sẽ sửa/tạo, test sẽ chạy) cho thành viên xác nhận rồi mới chỉnh sửa.

---

## 3. Ma trận sở hữu thư mục & Quy tắc chống Merge Conflict (v1.1)

| Thành viên (Mã nhánh) | Backend Packages sở hữu (`backend/src/main/java/com/nhom12/nutrition/`) | Frontend Folders sở hữu (`frontend/src/`) | Nhật ký tiến độ |
| --- | --- | --- | --- |
| **Đặng Trần Thiện** (`dt-thien`) | `auth/`, `user/`, `patient/` (hồ sơ cơ bản & onboarding) | **Sprint 0 Core:** `app/`, `components/`, `layouts/`, `routes/`, `services/`, `types/`, `utils/`, `.nvmrc` <br>+ `features/auth/`, `features/onboarding/`, `features/profile/`, `features/admin-users/` | `docs/progress/Đặng_Trần_Thiện.md` |
| **Hồ Đình Phước Thịnh** (`hdp-thinh`) | `intake/` (dùng `PatientIntake` trong `patient/`), `doctor/`, `communication/` | `features/intake/`, `features/assignments/`, `features/tracking-pauses/`, `features/appointments/`, `features/chat/`, `features/notifications/` | `docs/progress/Hồ_Đình_Phước_Thịnh.md` |
| **Phạm Đình Thịnh** (`pd-thinh`) | `clinical/`, `food/`, `mealplan/` | `features/declarations/`, `features/foods/`, `features/templates/`, `features/prescriptions/` | `docs/progress/Phạm_Đình_Thịnh.md` |
| **Phan Viết Thiện** (`pv-thien`) | `journal/`, `healthmetric/`, `alert/`, `report/`, `audit/` | `features/journals/`, `features/metrics/`, `features/alerts/`, `features/reports/`, `features/admin-ops/` | `docs/progress/Phan_Viết_Thiện.md` |

### Các file BẢO VỆ (AI KHÔNG ĐƯỢC tự ý sửa khi đang làm feature cá nhân)
- `backend/pom.xml`, `backend/src/main/resources/application*.yml`, `GlobalExceptionHandler.java`, `OpenApiConfig.java`
- `SecurityConfig.java` (chỉ **Đặng Trần Thiện** cập nhật trong PR Sprint 0 Auth/JWT; sau đó các thành viên khác dùng `@PreAuthorize` / annotation chuẩn, không tự nới `permitAll()`)
- `backend/src/main/resources/db/migration/V1__init_schema.sql`, `V2__publish_prescription_and_views.sql`, `V3__dev_seed.sql` và `docs/database/*` (sửa trực tiếp sẽ làm rớt `MigrationFilesConsistencyTest` và hỏng Flyway checksum; nếu thật sự cần đổi schema phải báo Nhóm trưởng tạo `V4__...sql` + đồng bộ `docs/database/`)
- File `docs/progress/<Tên_bạn_khác>.md` và thư mục code của thành viên khác (`patient/PatientIntake.java`, `patient/IntakeStatus.java` giữ nguyên tại package `patient/` để bảo toàn `JpaMetamodelMappingTest`)
- Sau khi `frontend/` được merge ở Sprint 0: `frontend/package.json`, `frontend/package-lock.json`, `frontend/src/components/ui/*`, `frontend/src/layouts/*`, `frontend/src/services/apiClient.ts` không tự ý đổi hoặc cài thêm thư viện ngoài khi chưa thống nhất nhóm. *(Chỉ đăng ký route feature hoặc plug widget dashboard vào đúng slot đã quy ước trong PR.)*

---

## 4. Thứ tự phối hợp Sprint 0 (React Frontend + Auth không chặn nhau)

1. **PR #1 ưu tiên merge sớm vào `main` (Đặng Trần Thiện — `feat/dt-thien/sprint0-fe-core-auth`):**
   - Khởi tạo `frontend/` (Vite + React + TypeScript + Tailwind + shadcn/ui + React Router + TanStack Query + RHF + Zod + Recharts + Vitest), commit `package-lock.json`, `.nvmrc`, và CI `.github/workflows/frontend-ci.yml` (`npm ci`, `lint`, `test`, `build`).
   - Dựng 5 layout vai trò (`Public`, `Patient`, `Doctor`, `HeadDoctor`, `Admin`), `RoleGuard`, 5 token màu trạng thái, `apiClient` (`/api/v1`, JWT + refresh rotation, parser `ApiErrorResponse`), Vite proxy `/api -> http://localhost:8080`, slot widget Dashboard (`SCR-PAT-01`, `SCR-DOC-01`, `SCR-ADM-00`).
   - Hoàn thiện Backend Auth (`UC-AUTH-01..04`: `/api/v1/auth/**` + `CurrentUser` helper để mọi module lấy được `userId`, `role`, `patientId`/`clinicianId`).
2. **Song song trong tuần đầu (3 thành viên còn lại):**
   - Triển khai **Backend Phase A** (Entities/DTO/Service/Repository/Controller + JUnit/MockMvc dùng `@WithMockUser` hoặc mock user) trong đúng package của mình — **không chờ Frontend mới bắt đầu**.
   - Ngay khi PR #1 được merge lên `main`, cả 3 pull `main` về nhánh của mình rồi triển khai UI trong `frontend/src/features/<folder>/`.

---

## 5. Luật kỹ thuật cứng (Hard Guardrails)

### Backend & Database
1. **Bảo mật & Chống IDOR:** 100% kiểm tra Role và Ownership thực hiện tại Backend (ẩn nút ở React KHÔNG phải bảo mật). Bệnh nhân chỉ xem/sửa ca của mình; Bác sĩ chỉ xem/sửa bệnh nhân có `assignment` đang hiệu lực do mình phụ trách; Admin xem hỗ trợ nhưng KHÔNG được sửa chỉ định y khoa.
2. **DTO & Hợp đồng API:** URL dạng `/api/v1/<danh-tu-so-nhieu>`, JSON `camelCase`, phân trang `page`/`size` (`<= 100`)/`sort`. **Không trả trực tiếp Entity JPA** ra Controller. Mọi lỗi nghiệp vụ ném `BusinessException` theo format `ApiErrorResponse` (không lộ SQL/stacktrace).
3. **Stored Functions:** Ban hành và đóng/dừng sớm phiếu chỉ định **bắt buộc** gọi qua `PrescriptionProcedureService` (`publish_prescription`, `close_or_stop_prescription`), không tự viết lại transaction lẻ làm lệch snapshot `applied_prescription_day`.
4. **Múi giờ & Đơn vị:** DB lưu `timestamptz` (UTC), mọi ranh giới "ngày" (`48h` sửa nhật ký, `BR-02` 7–30 ngày, `BR-06` 2/3/6 ngày, `BR-07` trước `end_date` 3 ngày) tính theo `Asia/Ho_Chi_Minh`. Giữ chính xác đơn vị: chiều cao `cm`, cân nặng `kg`, năng lượng `kcal`, macro `g`, sodium/cholesterol `mg` (`sodium_mg` — không quy thành "muối"), nước `ml`, huyết áp `mmHg` (cặp `systolic >= diastolic`), đường huyết `mmol/L`.
5. **Bất biến lịch sử & Idempotency:** Không xóa cứng hồ sơ lâm sàng; sửa món ăn không làm đổi `kcal` nhật ký đã ghi; Job nền `BR-06`/`BR-07` và Alert Đỏ phải chống trùng bằng `dedupe_key`.

### Frontend (React)
1. **UI nhất quán:** Nội dung giao diện tiếng Việt có dấu đúng ngữ cảnh y khoa nhưng hiển thị rõ disclaimer *"Cảnh báo theo ngưỡng cấu hình, không phải chẩn đoán y khoa"*. Dùng 5 semantic token (`success`, `warning`, `danger`, `info`, `muted`) kèm **icon + nhãn chữ**, không chỉ dùng màu sắc.
2. **Đủ trạng thái UX:** Mọi trang gọi API phải xử lý rõ 4 trạng thái: `loading`, `empty`, `error` (giữ nguyên dữ liệu đang nhập khi lỗi submit), và `403 permission denied`. Hành động nguy hiểm/đóng sớm/khóa tài khoản phải có hộp thoại xác nhận + nhập lý do khi quy định yêu cầu.
3. **Kiểm soát kiểu dữ liệu:** Toàn bộ request/response type định nghĩa bằng TypeScript khớp Swagger OpenAPI (`/v3/api-docs`), schema form dùng Zod.

### Git & Kiểm thử trước Commit
- Không bao giờ stage `.env`, `.env.*`, `backend/target/`, `frontend/node_modules/`, `frontend/dist/`, hay file lock `~$*`.
- Chạy `mvn -B test` trong `backend/` (và khi đã có `frontend/`: `npm run lint`, `npm test`, `npm run build` trong `frontend/`) và chắc chắn PASS 100% trước khi commit/mở PR.
- Sau khi commit code, chạy `.\scripts\log-commit.ps1 -MemberFile "<Họ_Tên>.md" -Tested "..." -Notes "..."` và amend/commit bổ sung **duy nhất file `.md` mang tên mình** trong `docs/progress/`.
