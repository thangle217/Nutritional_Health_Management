## Thông tin Pull Request

- **Thành viên thực hiện:** <!-- VD: Đặng Trần Thiện (`dt-thien`) -->
- **Use Case & Màn hình (`SCR-*`):** <!-- VD: UC-AUTH-04, SCR-PUB-02..05 -->
- **Tài liệu đối chiếu:** `AGENTS.md` và `docs/tasks/AI_TASKS_OVERVIEW.md`
- **Tóm tắt thay đổi:**
  - 
  - 

## Bảng DB / API / Frontend liên quan

- **Database:** <!-- VD: patient_intake, không đổi migration V1..V3 (hoặc nêu V4__...) -->
- **Backend API Endpoints:** <!-- VD: POST /api/v1/intake-requests -->
- **Frontend Modules (`frontend/src/`):** <!-- VD: features/intake, đính kèm ảnh/video nếu đổi UI -->

## Checklist bắt buộc trước khi Merge

- [ ] Đúng phạm vi Use Case & thư mục sở hữu trong `AGENTS.md` và `docs/tasks/AI_TASKS_OVERVIEW.md`
- [ ] Đã kiểm tra phân quyền Role & Ownership ở Backend (`403` khi truy cập ca/hồ sơ không được giao)
- [ ] Validation rõ ràng, đúng đơn vị (`cm/kg/kcal/g/mg/ml/mmHg/mmol/L`) và múi giờ `Asia/Ho_Chi_Minh`
- [ ] Backend: `mvn -B test` pass hoàn toàn (không sửa/xóa test sẵn có trừ khi cập nhật hợp lệ)
- [ ] Frontend (nếu có thay đổi trong `frontend/`): `npm run lint`, `npm test`, `npm run build` pass; có trạng thái `loading`/`empty`/`error`; dùng Tailwind + shadcn/ui và token màu kèm icon/nhãn
- [ ] Không commit `.env`, mật khẩu, secret, `target/`, `node_modules/`, hoặc file lock `~$*`
- [ ] Đã cập nhật nhật ký tiến độ cá nhân tại `docs/progress/<Họ_Tên>.md`
