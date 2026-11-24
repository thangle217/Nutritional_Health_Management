## Thông tin Pull Request

- **Thành viên thực hiện:** <!-- VD: Đặng Trần Thiện -->
- **Use Case & Màn hình (`SCR-*`):** <!-- VD: UC-AUTH-04, SCR-PUB-02..05 -->
- **Tóm tắt thay đổi:**
  - 
  - 

## Bảng DB / API liên quan

- **Database:** <!-- VD: patient_intake, không đổi migration hay có thêm V4__... -->
- **API Endpoints:** <!-- VD: POST /api/v1/intake-requests -->

## Checklist bắt buộc trước khi Merge

- [ ] Đúng phạm vi Use Case được giao trong `docs/tasks/<Tên>_tasks.docx`
- [ ] Đã kiểm tra phân quyền Role & Ownership (`403` khi truy cập ca/hồ sơ không được giao)
- [ ] Validation rõ ràng, đúng đơn vị (`cm/kg/kcal/g/mg/ml/mmHg/mmol/L`) và múi giờ `Asia/Ho_Chi_Minh`
- [ ] `mvn test` pass hoàn toàn (không sửa/xóa test sẵn có trừ khi cập nhật hợp lệ)
- [ ] Không commit `.env`, mật khẩu, secret hoặc thư mục `target/`
- [ ] Đã cập nhật nhật ký tiến độ cá nhân tại `docs/progress/<Họ_Tên>.md`
