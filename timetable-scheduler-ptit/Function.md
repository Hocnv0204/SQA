# Các chức năng chính của project (Backend + Frontend)

Tài liệu này tổng hợp **các chức năng nghiệp vụ chính (core)** của hệ thống xếp thời khóa biểu/phòng học dựa trên:
- Backend Spring Boot: `timetable-scheduler-ptit/src`
- Frontend React (Vite): `tkb-ptit-react/src`

> Ghi chú phạm vi: project có phần **đăng nhập/đăng ký** (frontend `LoginPage`, `RegisterPage` + backend `/api/auth/...`) nhưng **nhóm có thể loại khỏi phạm vi kiểm thử** nếu giảng viên yêu cầu “bỏ qua auth”.

## 1) Dashboard (tổng quan dữ liệu)

- **Frontend**
  - Trang tổng quan: `Dashboard` (`/`)
  - Hiển thị thống kê: tổng số môn học, phòng học, học kỳ.
- **Backend liên quan**
  - `GET /api/subjects` (lấy `totalElements`)
  - `GET /api/rooms`
  - `GET /api/semesters`

## 2) Quản lý dữ liệu nền (master data)

- **Học kỳ (Semester)**
  - `GET /api/semesters` (và các API lấy theo id/name/active)
  - `POST /api/semesters`, `PUT /api/semesters/{id}`, `DELETE /api/semesters/{id}`, `PATCH /api/semesters/{id}/activate`
  - **Frontend**: `SemestersPage` (`/semesters`)
    - Thêm/sửa/xóa học kỳ, kích hoạt học kỳ
    - (UI có luồng) xóa học kỳ kèm xóa dữ liệu môn học theo học kỳ/năm học

- **Môn học (Subject)**
  - `GET /api/subjects` (phân trang/filter/search)
  - `POST /api/subjects`, `PUT /api/subjects/{id}`, `DELETE /api/subjects/{id}`
  - `POST /api/subjects/upload-excel` (import môn học từ Excel)
  - Các API phục vụ chọn lọc trên FE: `program-types`, `class-years`, `majors`, `group-majors`, `common-subjects`
  - **Frontend**: `SubjectsPage` (`/subjects`)
    - Danh sách + lọc theo năm học/học kỳ/khóa/ngành/hệ đào tạo, xem chi tiết
    - Thêm/sửa/xóa (hỗ trợ xóa nhiều)
    - Import danh sách môn học từ Excel

- **Phòng học (Room)**
  - `GET /api/rooms` (lọc theo tòa, loại, trạng thái, sức chứa)
  - `POST /api/rooms`, `PUT /api/rooms/{id}`, `DELETE /api/rooms/{id}`
  - `PATCH /api/rooms/{id}/status`, `PATCH /api/rooms/bulk-status`
  - **Frontend**: `RoomsPage` (`/rooms`)
    - Tab danh sách phòng: search + lọc + phân trang, thêm/sửa/xóa
    - Tab “trạng thái theo kỳ”: xem mức độ sử dụng phòng theo học kỳ (tích hợp room occupancy)

- **Ưu tiên tòa nhà theo ngành (Major–Building preference)**
  - `GET /api/major-building-preferences`
  - `GET /api/major-building-preferences/major/{nganh}`
  - `POST /api/major-building-preferences` (+ bulk)
  - `DELETE /api/major-building-preferences/major/{nganh}/building/{building}`
  - **Frontend**: hiện chưa thấy page quản trị riêng; được dùng gián tiếp trong logic gán phòng (backend).

## 3) Nhập dữ liệu lịch mẫu (template) cho từng học kỳ

- **Import lịch mẫu từ Excel vào DB**
  - `POST /api/schedules/import-data` (multipart, kèm `semester`)
  - Vai trò: tạo nguồn template để hệ thống **sinh TKB**.
  - **Frontend**: nằm trong `SchedulePage` (`/tkb`) qua modal “Upload dữ liệu lịch mẫu”

## 4) Lập lịch (Sinh TKB) → Gán phòng → Lưu TKB

- **Lập lịch / Sinh TKB theo lịch mẫu (batch)**
  - **Frontend**: `SchedulePage` (`/tkb`)
    - Chọn năm học/học kỳ/hệ đào tạo/khóa/nhóm ngành
    - Tải danh sách môn theo tổ hợp ngành; hỗ trợ “gộp ngành” và “đăng ký chung” (gộp khóa cho môn chung)
    - Sinh TKB
  - **Backend**: `POST /api/schedules/generate-batch`

- **Gán phòng cho kết quả TKB**
  - **Frontend**: nút “Gán phòng” trong `SchedulePage`
  - **Backend**: `POST /api/rooms/assign-rooms?academicYear=&semester=`

- **Lưu TKB vào database & cập nhật trạng thái phòng**
  - **Frontend**: nút “Lưu thời khóa biểu” trong `SchedulePage`
    - Gọi `POST /api/schedules/save-batch` để lưu lịch theo batch
    - Cập nhật trạng thái phòng sang `OCCUPIED` (gọi bulk-status)
    - (Có gọi) `POST /api/rooms/save-results` để commit kết quả sử dụng phòng
  - **Backend**:
    - `POST /api/schedules/save-batch`
    - `PATCH /api/rooms/bulk-status`
    - `POST /api/rooms/save-results` (commit kết quả)

- **Lưu trạng thái phiên sinh TKB (Redis lastSlotIdx)**
  - Backend: `POST /api/schedules/save-last-slot-idx`, `DELETE /api/schedules/reset-last-slot-idx-redis`
  - Frontend: sử dụng khi xóa dữ liệu TKB theo học kỳ/năm học trong `SavedSchedulesPage` (reset sau khi xóa).

## 5) Xem/Quản lý thời khóa biểu đã lưu + Xuất Excel + Xóa theo điều kiện

- **Frontend**: `SavedSchedulesPage` (`/saved-schedules`)
  - Xem danh sách TKB đã lưu, lọc theo năm học/học kỳ/khóa/ngành
  - Xóa theo lớp, xóa theo ngành, xóa toàn bộ theo học kỳ/năm học
  - Xuất Excel thời khóa biểu đã lưu (dùng thư viện `xlsx`)
- **Backend liên quan**
  - `GET /api/schedules`
  - `DELETE /api/schedules/{id}`, `DELETE /api/schedules`
  - `DELETE /api/v1/room-occupancies/semester/{semesterId}` (xóa occupancy theo học kỳ khi xóa TKB)
  - `PATCH /api/rooms/bulk-status` (giải phóng phòng về `AVAILABLE`)
  - `DELETE /api/schedules/reset-last-slot-idx-redis` (reset trạng thái phiên)

## 6) Theo dõi tình trạng sử dụng phòng theo học kỳ (Room occupancy)

- **Tra cứu/Thống kê/Check trống**
  - `GET /api/v1/room-occupancies/...` (theo phòng/theo học kỳ, statistics)
  - `GET /api/v1/room-occupancies/check-availability`
  - `GET /api/v1/room-occupancies/rooms-status/semester/{semesterId}` (bảng trạng thái + filter/search/pagination)
  - `GET /api/v1/room-occupancies/available-rooms` (tìm phòng trống theo thứ/tiết)
  - **Frontend**
    - `RoomsPage` tab “trạng thái theo kỳ” (gọi `rooms-status/semester/{semesterId}`)
    - `RoomSchedulePage` (grid lịch phòng theo slot; hiện có page trong source, có thể dùng như màn “lịch phòng” tùy menu triển khai)

- **Đồng bộ occupancy từ TKB**
  - `POST /api/v1/room-occupancies/bulk-create`
  - `DELETE /api/v1/room-occupancies/semester/{semesterId}`

## 7) Kiểm định/Phân tích xung đột từ file Excel TKB thực tế

- **Upload & phân tích xung đột (phòng/giảng viên)**
  - `POST /api/schedule-validation/validate-format`
  - `POST /api/schedule-validation/analyze`
  - **Frontend**: `ScheduleValidationPage` (`/schedule-validation`)
    - Upload file `.xlsx`, hiển thị thống kê xung đột (phòng/giảng viên) và chi tiết từng xung đột

