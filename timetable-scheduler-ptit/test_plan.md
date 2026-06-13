# Kế hoạch & Kết quả Unit Test

Kết quả chạy thực tế: **11/11 Test cases Passed.** (100% Success).

## Bảng Kế hoạch (Test Plan)

| ID | Tên | Mô tả | Điều kiện tiên quyết | Các bước kiểm thử | Expected Output | Đường dẫn file / thư mục | Test Results | Mã nguồn |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| **Unit Testing cho Tính năng Quản lý phòng học** | | | | | | | | |
| UT_RM_01 | Lấy danh sách tất cả phòng học | Kiểm tra API lấy toàn bộ danh sách phòng học. | Không có | 1. Gọi API `GET /api/rooms`<br>2. Kiểm tra status code<br>3. Kiểm tra dữ liệu trả về | Status code 200, trả về danh sách các phòng học trong hệ thống cùng message thành công. | `src/test/java/.../RoomControllerTest.java` | **Pass** | [Xem chi tiết](#ut_rm_01) |
| UT_RM_02 | Lấy thông tin chi tiết một phòng | Kiểm tra API lấy thông tin phòng theo ID hợp lệ. | Có phòng với ID = 1 tồn tại | 1. Gọi API `GET /api/rooms/1`<br>2. Kiểm tra status code<br>3. Kiểm tra body response | Status code 200, trả về đúng object phòng có ID = 1. | `src/test/java/.../RoomControllerTest.java` | **Pass** | [Xem chi tiết](#ut_rm_02) |
| UT_RM_03 | Tạo mới phòng học hợp lệ | Kiểm tra API tạo mới phòng với dữ liệu đầu vào đúng. | Dữ liệu đúng định dạng | 1. Gọi API `POST /api/rooms` kèm payload hợp lệ<br>2. Kiểm tra status code<br>3. Kiểm tra dữ liệu được tạo | Status code 201 Created, trả về object phòng vừa được tạo kèm ID. | `src/test/java/.../RoomControllerTest.java` | **Pass** | [Xem chi tiết](#ut_rm_03) |
| UT_RM_04 | Tạo mới phòng học thiếu dữ liệu | Kiểm tra API tạo mới phòng với dữ liệu đầu vào thiếu trường bắt buộc. | Dữ liệu Request bị thiếu tên | 1. Gọi API `POST /api/rooms` kèm payload thiếu tên phòng<br>2. Kiểm tra status code | Status code 400 Bad Request, báo lỗi validation. | `src/test/java/.../RoomControllerTest.java` | **Pass** | [Xem chi tiết](#ut_rm_04) |
| UT_RM_05 | Xóa phòng học | Kiểm tra API xóa một phòng học hiện có. | Phòng ID = 1 tồn tại | 1. Gọi API `DELETE /api/rooms/1`<br>2. Kiểm tra status code | Status code 200, message xóa thành công. | `src/test/java/.../RoomControllerTest.java` | **Pass** | [Xem chi tiết](#ut_rm_05) |
| **Unit Testing cho Tính năng Hậu kiểm (Schedule Validation)** | | | | | | | | |
| UT_SV_01 | Validate định dạng Excel thành công | Kiểm tra API validate file Excel khi upload file đúng định dạng TKB. | File Excel đầu vào đúng form mẫu | 1. Gửi request multipart file lên `POST /api/schedule-validation/validate-format`<br>2. Đánh giá response | Status code 200, success = true, message báo hợp lệ. | `src/test/java/.../ScheduleValidationControllerTest.java` | **Pass** | [Xem chi tiết](#ut_sv_01) |
| UT_SV_02 | Validate định dạng Excel thất bại | Kiểm tra API validate file Excel khi upload file sai định dạng hoặc rỗng. | File rỗng hoặc sai đuôi, cấu trúc | 1. Gửi request multipart rỗng lên `POST /api/schedule-validation/validate-format`<br>2. Đánh giá response | Status code 200, success = false, status nội bộ 400. | `src/test/java/.../ScheduleValidationControllerTest.java` | **Pass** | [Xem chi tiết](#ut_sv_02) |
| UT_SV_03 | Phân tích xung đột TKB thành công | Kiểm tra API phân tích file lịch trình hợp lệ và phát hiện xung đột. | File Excel TKB hợp lệ có chứa các bản ghi | 1. Upload file lên `POST /api/schedule-validation/analyze`<br>2. Mock trả về danh sách ScheduleEntry | Status code 200, trả về danh sách entry và số lượng xung đột. | `src/test/java/.../ScheduleValidationControllerTest.java` | **Pass** | [Xem chi tiết](#ut_sv_03) |
| UT_SV_04 | Phân tích TKB với file rỗng dữ liệu | Kiểm tra API phân tích khi file Excel không chứa dòng dữ liệu nào. | File Excel đúng định dạng nhưng không có record | 1. Upload file lên `POST /api/schedule-validation/analyze`<br>2. Mock reader trả về list rỗng | Status code 200 OK, success = false, message báo không tìm thấy dữ liệu. | `src/test/java/.../ScheduleValidationControllerTest.java` | **Pass** | [Xem chi tiết](#ut_sv_04) |
| UT_SV_05 | Lấy chi tiết loại xung đột | Kiểm tra API lấy chi tiết của 1 loại xung đột cụ thể. | Hệ thống đang hoạt động | 1. Gọi `GET /api/schedule-validation/conflicts/room`<br>2. Kiểm tra response | Status code 200, trả về dữ liệu thành công. | `src/test/java/.../ScheduleValidationControllerTest.java` | **Pass** | [Xem chi tiết](#ut_sv_05) |

---

## Chi tiết Mã nguồn Test (Source Code)

### UT_RM_01
```java
@Test
void getAllRooms_ShouldReturnRoomList() throws Exception {
    List<RoomResponse> rooms = Arrays.asList(roomResponse);
    when(roomService.getAllRooms()).thenReturn(rooms);

    mockMvc.perform(get("/api/rooms")
                    .contentType(MediaType.APPLICATION_JSON))
            .andExpect(status().isOk())
            .andExpect(jsonPath("$.success").value(true))
            .andExpect(jsonPath("$.data[0].id").value(1L))
            .andExpect(jsonPath("$.data[0].name").value("A2-301"));
}
```

### UT_RM_02
```java
@Test
void getRoomById_ShouldReturnRoom() throws Exception {
    when(roomService.getRoomById(1L)).thenReturn(roomResponse);

    mockMvc.perform(get("/api/rooms/1")
                    .contentType(MediaType.APPLICATION_JSON))
            .andExpect(status().isOk())
            .andExpect(jsonPath("$.success").value(true))
            .andExpect(jsonPath("$.data.id").value(1L))
            .andExpect(jsonPath("$.data.name").value("A2-301"));
}
```

### UT_RM_03
```java
@Test
void createRoom_ShouldReturnCreatedRoom() throws Exception {
    when(roomService.createRoom(any(RoomRequest.class))).thenReturn(roomResponse);

    mockMvc.perform(post("/api/rooms")
                    .contentType(MediaType.APPLICATION_JSON)
                    .content(objectMapper.writeValueAsString(roomRequest)))
            .andExpect(status().isCreated())
            .andExpect(jsonPath("$.success").value(true))
            .andExpect(jsonPath("$.data.id").value(1L))
            .andExpect(jsonPath("$.data.name").value("A2-301"));
}
```

### UT_RM_04
```java
@Test
void createRoom_WithInvalidData_ShouldReturnBadRequest() throws Exception {
    RoomRequest invalidRequest = RoomRequest.builder()
            .name("") // Invalid blank name
            .capacity(0) // Invalid capacity
            .build();

    mockMvc.perform(post("/api/rooms")
                    .contentType(MediaType.APPLICATION_JSON)
                    .content(objectMapper.writeValueAsString(invalidRequest)))
            .andExpect(status().isBadRequest());
}
```

### UT_RM_05
```java
@Test
void deleteRoom_ShouldReturnSuccess() throws Exception {
    doNothing().when(roomService).deleteRoom(1L);

    mockMvc.perform(delete("/api/rooms/1")
                    .contentType(MediaType.APPLICATION_JSON))
            .andExpect(status().isOk())
            .andExpect(jsonPath("$.success").value(true));
}
```

### UT_SV_01
```java
@Test
void validateExcelFormat_WithValidFile_ShouldReturnSuccess() throws Exception {
    when(excelReaderService.validateScheduleExcelFormat(any())).thenReturn(true);

    mockMvc.perform(multipart("/api/schedule-validation/validate-format")
                    .file(validFile))
            .andExpect(status().isOk())
            .andExpect(jsonPath("$.success").value(true));
}
```

### UT_SV_02
```java
@Test
void validateExcelFormat_WithEmptyFile_ShouldReturnBadRequest() throws Exception {
    mockMvc.perform(multipart("/api/schedule-validation/validate-format")
                    .file(emptyFile))
            .andExpect(status().isOk())
            .andExpect(jsonPath("$.success").value(false))
            .andExpect(jsonPath("$.status").value(400));
}
```

### UT_SV_03
```java
@Test
void analyzeSchedule_WithValidFile_ShouldReturnResult() throws Exception {
    when(excelReaderService.validateScheduleExcelFormat(any())).thenReturn(true);

    List<ScheduleEntry> entries = new ArrayList<>();
    entries.add(new ScheduleEntry()); // Add dummy entry
    when(excelReaderService.readScheduleFromExcel(any())).thenReturn(entries);

    ConflictResult conflictResult = new ConflictResult(); // Dummy conflict result
    when(conflictDetectionService.detectConflicts(any())).thenReturn(conflictResult);

    mockMvc.perform(multipart("/api/schedule-validation/analyze")
                    .file(validFile))
            .andExpect(status().isOk())
            .andExpect(jsonPath("$.success").value(true))
            .andExpect(jsonPath("$.data.fileName").value("schedule.xlsx"));
}
```

### UT_SV_04
```java
@Test
void analyzeSchedule_WithEmptyData_ShouldReturnBadRequest() throws Exception {
    when(excelReaderService.validateScheduleExcelFormat(any())).thenReturn(true);
    when(excelReaderService.readScheduleFromExcel(any())).thenReturn(new ArrayList<>());

    mockMvc.perform(multipart("/api/schedule-validation/analyze")
                    .file(validFile))
            .andExpect(status().isOk())
            .andExpect(jsonPath("$.success").value(false))
            .andExpect(jsonPath("$.status").value(400))
            .andExpect(jsonPath("$.message").value("Không tìm thấy dữ liệu thời khóa biểu trong file. Vui lòng kiểm tra lại."));
}
```

### UT_SV_05
```java
@Test
void getConflictDetails_ShouldReturnSuccess() throws Exception {
    mockMvc.perform(get("/api/schedule-validation/conflicts/room")
                    .contentType(MediaType.APPLICATION_JSON))
            .andExpect(status().isOk())
            .andExpect(jsonPath("$.success").value(true));
}
```
