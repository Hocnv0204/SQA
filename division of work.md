# Phân chia công việc kiểm thử (nhóm 4 người)

Tài liệu này phân chia công việc kiểm thử theo yêu cầu trong file PDF `docs/Yeu cau bai tap nhom - Kiem dinh (1.2026).pdf`.

## A) Công việc làm chung của cả nhóm

- **Chọn/chốt chủ đề & phạm vi**: hệ thống gồm **backend** `timetable-scheduler-ptit` và **frontend** `tkb-ptit-react`. Chỉ kiểm thử các chức năng chính (nhóm có thể **loại khỏi phạm vi** phần xác thực/ủy quyền nếu được yêu cầu).
- **Xây dựng Kế hoạch kiểm thử (Test Plan)**:
  - Mục tiêu, phạm vi, môi trường, chiến lược test (UI/Unit/Black-box), tiêu chí vào/ra, tiêu chí pass/fail, quản lý rủi ro.
- **Review theo checklist tài liệu**:
  - Rà soát các tài liệu hiện có (nếu thiếu thì bổ sung mô tả use-case/luồng nghiệp vụ tối thiểu để làm đầu vào test).
- **Ghép báo cáo cuối**:
  - Phần chung của nhóm + 4 phần cá nhân (review + test case + kết quả thực thi + đánh giá).

## B) Công việc từng cá nhân (4 người)

Mỗi người chọn **1 chức năng/chuỗi nghiệp vụ đủ phức tạp** và thực hiện:
- Review code phần chức năng phụ trách
- Xây dựng test case + thực thi test:
  - Kiểm thử giao diện (nếu có FE)
  - Kiểm thử đơn vị (Unit) – có thể chỉ cần một phần
  - Kiểm thử hộp đen (Black-box)
- Đánh giá kết quả và viết báo cáo cá nhân để ghép vào báo cáo chung

---

### Người 1 — Nhập lịch mẫu (template) + Sinh thời khóa biểu (TKB)

- **Phạm vi chức năng chính**
  - Import lịch mẫu từ Excel: `POST /api/schedules/import-data`
  - Sinh TKB theo lịch mẫu (batch): `POST /api/schedules/generate-batch`
  - Quản lý trạng thái phiên sinh TKB (Redis lastSlotIdx):
    - `POST /api/schedules/save-last-slot-idx`
    - `DELETE /api/schedules/reset-last-slot-idx-redis`
- **Nhiệm vụ kiểm thử**
  - **Review code**
    - **Backend**: `DataLoaderService`, `ScheduleServiceImpl` (load/import template, cache, generate batch, lastSlotIdx).
    - **Frontend**: `SchedulePage` (phần upload lịch mẫu + sinh TKB + xử lý “gộp ngành/đăng ký chung”).
  - **Test case & thực thi**
    - **UI**: `SchedulePage` (`/tkb`) – upload lịch mẫu, chọn năm/học kỳ/hệ/khóa/ngành, tải môn, sinh TKB.
    - **Unit**: normalize semester, xử lý pool template, mapping slot 60 tiết, cập nhật lastSlotIdx.
    - **Black-box API**: import file đúng/sai định dạng; sinh TKB khi chưa có template; sinh nhiều môn/đa ngành; dữ liệu biên (số lớp, số tiết).
  - **Báo cáo cá nhân**: bảng test case + kết quả + lỗi/issue + đề xuất.

---

### Người 2 — Gán phòng cho TKB (Room assignment) theo ràng buộc & ưu tiên

- **Phạm vi chức năng chính**
  - Gán phòng cho TKB đã sinh: `POST /api/rooms/assign-rooms?academicYear=&semester=`
  - Ưu tiên tòa theo ngành (đầu vào để test rule):
    - `GET/POST/DELETE /api/major-building-preferences/...`
  - **Lưu TKB sau khi gán phòng + cập nhật trạng thái phòng (luồng “gán phòng → lưu”)**:
    - `POST /api/schedules/save-batch` (lưu kết quả TKB; controller có auto-commit lastSlotIdx vào Redis sau khi lưu)
    - `PATCH /api/rooms/bulk-status` (cập nhật trạng thái phòng hàng loạt; dùng để đưa phòng sang `OCCUPIED` sau khi lưu)
    - `POST /api/rooms/save-results` *(thực tế gọi `commitSessionToRedis(userId, academicYear, semester)` — “commit” session/Redis, không phải API ghi nhận occupancy)*
    - *(Không cover luồng xóa TKB đã lưu / giải phóng phòng — phần đó thuộc Người 3)*
- **Nhiệm vụ kiểm thử**
  - **Review code**
    - **Backend**: `RoomServiceImpl` (pickRoom, rule theo subjectType/khóa/hệ, ưu tiên tòa, tránh trùng, warnings).
    - **Frontend**: `SchedulePage` (nút “Gán phòng”, hiển thị warnings). *(Không cover CRUD phòng / room occupancy / saved schedules)*.
  - **Test case & thực thi**
    - **UI**: `SchedulePage` (`/tkb`) – gán phòng cho kết quả; kiểm tra hiển thị phòng & cảnh báo.
    - **UI (mở rộng)**: sau khi gán phòng, thực hiện “Lưu thời khóa biểu” và kiểm tra:
      - lưu thành công/thất bại (toast/message)
      - trạng thái phòng chuyển sang `OCCUPIED` (nếu UI có hiển thị/hoặc kiểm chứng bằng gọi API)
    - **Unit**: rule chọn phòng (english/general/CLC/khóa...), tính điểm ưu tiên tòa, tránh trùng slot.
    - **Black-box API**: gán phòng khi thiếu phòng/sĩ số lớn/phòng bận; thay đổi ưu tiên tòa; tham số học kỳ sai; dữ liệu biên.
    - **Black-box API (mở rộng luồng “gán phòng → lưu”)**:
      - `POST /api/schedules/save-batch`: payload thiếu/invalid; lưu trùng; lưu khi chưa gán phòng; dataset lớn.
      - `PATCH /api/rooms/bulk-status`: cập nhật `OCCUPIED` đúng danh sách phòng; id không tồn tại/trùng; gọi lặp lại (idempotent).
      - `POST /api/rooms/save-results` (request params `userId`, `academicYear`, `semester`): thiếu tham số/null, commit thành công/thất bại; thông báo lỗi rõ ràng.
  - **Báo cáo cá nhân**: bảng test case + kết quả + lỗi/issue + đề xuất.

---

### Người 3 — Theo dõi tình trạng sử dụng phòng (Room occupancy)

- **Phạm vi chức năng chính**
  - **Quản lý phòng học (Room master data)**:
    - CRUD phòng: `GET /api/rooms`, `GET /api/rooms/{id}`, `POST /api/rooms`, `PUT /api/rooms/{id}`, `DELETE /api/rooms/{id}`
    - Cập nhật trạng thái phòng:
      - `PATCH /api/rooms/{id}/status`
      - `PATCH /api/rooms/bulk-status`
    - Lọc/tra cứu theo thuộc tính:
      - `GET /api/rooms/building/{building}`
      - `GET /api/rooms/type/{type}`
      - `GET /api/rooms/status/{status}`
      - `GET /api/rooms/available?capacity=`
      - `GET /api/rooms/building/{building}/status/{status}`
      - `GET /api/rooms/type/{type}/status/{status}`
  - **Mapping môn–phòng (phục vụ rule/đối sánh dữ liệu phòng)**:
    - `GET /api/rooms/subject-room-mappings`
    - `DELETE /api/rooms/subject-room-mappings`
    - `DELETE /api/rooms/subject-room-mappings/{maMon}`
  - Tra cứu/Thống kê/Check trống (Room occupancy):
    - `GET /api/v1/room-occupancies/...`
    - `GET /api/v1/room-occupancies/check-availability`
    - `GET /api/v1/room-occupancies/rooms-status/semester/{semesterId}`
    - `GET /api/v1/room-occupancies/available-rooms`
  - Đồng bộ occupancy từ TKB:
    - `POST /api/v1/room-occupancies/bulk-create`
    - `DELETE /api/v1/room-occupancies/semester/{semesterId}`
  - **Xem/Quản lý thời khóa biểu đã lưu + Xuất Excel + Xóa theo điều kiện (liên quan giải phóng phòng/occupancy)**:
    - **Frontend**: `SavedSchedulesPage` (`/saved-schedules`)
      - Xem danh sách TKB đã lưu + lọc theo năm học/học kỳ/khóa/ngành
      - Xóa theo lớp / theo ngành / xóa toàn bộ *(UI có thể lọc danh sách rồi xóa; backend chỉ hỗ trợ xóa theo `id` hoặc xóa toàn bộ)*
      - Xuất Excel TKB đã lưu (thư viện `xlsx`)
    - **Backend liên quan**:
      - `GET /api/schedules`
      - `GET /api/schedules/major/{major}` (lọc theo ngành)
      - `GET /api/schedules/student-year/{studentYear}` (lọc theo khóa)
      - `DELETE /api/schedules/{id}`, `DELETE /api/schedules`
      - `DELETE /api/v1/room-occupancies/semester/{semesterId}` (xóa occupancy khi xóa TKB theo học kỳ)
      - `PATCH /api/rooms/bulk-status` (giải phóng phòng về `AVAILABLE`)
      - `DELETE /api/schedules/reset-last-slot-idx-redis` *(chỉ kiểm tra side-effect sau xóa; phần Redis lastSlotIdx thuộc Người 1)*
- **Nhiệm vụ kiểm thử**
  - **Review code**
    - **Backend**:
      - `RoomController` + phần service phục vụ **CRUD phòng / filter / update status / bulk-status**. *(Không review thuật toán `assign-rooms` — phần đó thuộc Người 2).*
      - `SubjectRoomMappingService` (subject-room-mappings).
      - `RoomOccupancyServiceImpl` (statistics, status, filter/search/paging, bulk-create).
      - Luồng xóa/lưu TKB & giải phóng phòng:
        - `ScheduleController/Service` (list/delete schedules)
        - gọi tích hợp `RoomOccupancyService` + `RoomService.bulkUpdateRoomStatus` + reset Redis lastSlotIdx *(verify side-effect; logic lastSlotIdx chính thuộc Người 1)*
    - **Frontend**:
      - `RoomsPage`:
        - Tab danh sách phòng (CRUD + search/filter nếu UI có)
        - Tab “trạng thái theo kì”
      - `SavedSchedulesPage` (`/saved-schedules`) (lọc/xóa/xuất Excel)
      - `RoomSchedulePage` (grid lịch phòng theo slot – nếu nhóm dùng màn này).
  - **Test case & thực thi**
    - **UI**:
      - `RoomsPage` (`/rooms`) – tab “trạng thái theo kì”: lọc/search/sort/pagination + modal xem chi tiết slot đã dùng.
      - `RoomsPage` (`/rooms`) – tab danh sách phòng (nếu có trong UI): thêm/sửa/xóa; validate dữ liệu; search theo tên phòng/tòa; lọc theo trạng thái/loại/sức chứa.
      - `RoomSchedulePage` (nếu có dùng) – kiểm tra grid theo **ngày/ca/tuần** hiển thị đúng; chuyển tuần/kỳ; click slot xem danh sách lớp/môn chiếm phòng.
      - Kiểm thử hành vi UI khi **API trả rỗng**, **loading**, **lỗi 4xx/5xx** (thông báo lỗi, retry).
      - `SavedSchedulesPage` (`/saved-schedules`):
        - Lọc theo năm học/học kỳ/khóa/ngành; phân trang (nếu có); trạng thái rỗng/loading/error.
        - Xóa theo lớp / theo ngành / theo bộ lọc hiện tại: confirm modal, thông báo thành công/thất bại. *(Backend xóa theo `id` hoặc xóa toàn bộ; “xóa theo điều kiện” nếu có là do UI lọc rồi gọi xóa nhiều lần.)*
        - Sau khi xóa: kiểm tra UI refresh đúng; phòng được “giải phóng” phản ánh ở `RoomsPage`/tab trạng thái theo kỳ (nếu có dữ liệu).
        - Xuất Excel: kiểm tra file tải xuống, số dòng/cột cơ bản, encoding tiếng Việt, trường hợp dataset lớn.
    - **Unit**:
      - Tính `occupancyRate`/status (đúng công thức, làm tròn, ngưỡng cảnh báo nếu có).
      - Mapping slot (tiết/ca) → trạng thái (trống/đang dùng) và tổng hợp theo ngày/tuần.
      - Rule validate cho phòng (nếu có): tên phòng unique/format tòa nhà, sức chứa > 0, loại phòng hợp lệ, trạng thái hợp lệ.
      - Lọc + phân trang: validate tham số `page/size/sort`, keyword rỗng/ký tự đặc biệt, sort nhiều cột (nếu hỗ trợ).
      - Tính đúng khi dữ liệu biên: phòng không có lịch, phòng có lịch full tuần, số slot = 0, học kỳ không tồn tại.
    - **Black-box API**:
      - **Room CRUD & filter**:
        - Tạo phòng: thiếu field bắt buộc, capacity âm/0, type/status không hợp lệ, tên phòng trùng (nếu ràng buộc).
        - Cập nhật/xóa phòng: id không tồn tại, phòng đang OCCUPIED (nếu có chặn), xóa nhiều liên kết (nếu cascade).
        - Filter: building/type/status/capacity biên; kết hợp building+status, type+status; kiểm tra kết quả rỗng.
      - **Room status & bulk-status**:
        - Update trạng thái 1 phòng và hàng loạt: danh sách id rỗng, có id không tồn tại, trùng id, mix trạng thái.
        - Kiểm tra tác động: sau bulk-status, các API room list/filter phản ánh đúng trạng thái mới.
      - **Subject–room mappings**:
        - GET mapping trả đúng format; clear toàn bộ/clear theo `maMon`; gọi lặp lại (idempotent).
        - Dữ liệu `maMon` không tồn tại/ký tự đặc biệt (kỳ vọng 404/400 theo implement).
      - **check-availability**: phòng trống/đang bận; biên slot đầu/cuối ngày; tham số thiếu/sai kiểu (roomId/semesterId/slot); kiểm tra kết quả khi nhiều occupancy trùng slot.
      - **rooms-status/semester/{semesterId}** & **available-rooms**: đúng filter theo học kỳ, theo loại phòng/sức chứa (nếu có); kiểm tra với dataset lớn (nhiều phòng).
      - **bulk-create**:
        - Idempotency: gọi 2 lần không tạo trùng (hoặc tạo trùng → ghi defect).
        - Đồng bộ từ TKB: tạo đúng số bản ghi theo slot; validate dữ liệu bắt buộc; xử lý bản ghi lỗi (skip/rollback) theo logic hiện có.
        - Trường hợp cạnh tranh: bulk-create chạy song song với truy vấn status/check-availability (không lỗi, dữ liệu nhất quán).
      - **delete theo học kỳ**: xóa đúng phạm vi semesterId; xóa khi không có dữ liệu; gọi lại lần 2; kết hợp với bulk-create để test “reset & sync”.
      - **Filter/search/paging** cho các endpoint liên quan: keyword có dấu/ký tự đặc biệt, page vượt quá tổng trang, size cực lớn/0/âm.
      - **Schedules list/delete + side-effects**:
        - `GET /api/schedules`: lấy danh sách theo user; dữ liệu rỗng.
        - `GET /api/schedules/major/{major}`, `GET /api/schedules/student-year/{studentYear}`: lọc theo ngành/khóa.
        - `DELETE /api/schedules/{id}`: id không tồn tại; xóa 1 bản ghi và kiểm tra tác động.
        - `DELETE /api/schedules`: xóa toàn bộ; gọi lặp lại (idempotent).
        - Sau khi xóa (đặc biệt theo học kỳ ở luồng UI): `DELETE /api/v1/room-occupancies/semester/{semesterId}` được gọi/áp dụng đúng (không còn occupancy).
        - Trạng thái phòng sau xóa: `PATCH /api/rooms/bulk-status` đưa về `AVAILABLE` đúng số phòng; gọi lặp lại (idempotent).
        - `DELETE /api/schedules/reset-last-slot-idx-redis`: gọi sau khi xóa; gọi lại lần 2; kiểm tra không làm hỏng luồng khác.
  - **Báo cáo cá nhân**: bảng test case + kết quả + lỗi/issue + đề xuất.

---

### Người 4 — Quản lý môn học + Import môn từ Excel + Phân tích xung đột từ Excel TKB thực tế

- **Phạm vi chức năng chính**
  - Quản lý môn học + filter/search/paging:
    - `GET /api/subjects`
    - `POST/PUT/DELETE /api/subjects...`
    - Các API phục vụ chọn lọc FE: `program-types`, `class-years`, `majors`, `group-majors`, `common-subjects`
  - Import môn học từ Excel: `POST /api/subjects/upload-excel`
  - Phân tích xung đột từ Excel TKB:
    - `POST /api/schedule-validation/validate-format`
    - `POST /api/schedule-validation/analyze`
- **Nhiệm vụ kiểm thử**
  - **Review code**
    - **Backend**: `SubjectController/Service` (paging/filter/import), `ScheduleExcelReaderServiceImpl` + conflict detection.
    - **Frontend**: `SubjectsPage` (`/subjects`) + `ScheduleValidationPage` (`/schedule-validation`).
  - **Test case & thực thi**
    - **UI**: `SubjectsPage` – CRUD + lọc + import Excel; `ScheduleValidationPage` – upload Excel và xem kết quả xung đột.
    - **Unit**: validate format Excel, parse tuần, dữ liệu môn học bị trùng/thiếu, ràng buộc dữ liệu cơ bản.
    - **Black-box API**: file sai/cột thiếu; dữ liệu trùng/thiếu; kiểm tra output phân tích xung đột.
  - **Báo cáo cá nhân**: bảng test case + kết quả + lỗi/issue + đề xuất.

---

## C) Sản phẩm nộp (gợi ý theo PDF)

- **Test Plan (cả nhóm)**: 01 file doc hoặc excel.
- **Kết quả Review (cả nhóm)**: 01 file doc hoặc excel (theo checklist).
- **Kết quả kiểm thử (4 cá nhân ghép chung)**: 01 file excel (mỗi người 1 sheet: test cases + execution + defect).
- **Minh chứng**: link Git/mã nguồn, ảnh chụp màn hình, log, file Excel input dùng để test.

