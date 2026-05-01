CREATE DATABASE IF NOT EXISTS `schedule`
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;
USE `schedule`;

-- Ensure client/connection uses UTF-8 during import
SET NAMES utf8mb4 COLLATE utf8mb4_unicode_ci;

-- 1. Create Tables
CREATE TABLE IF NOT EXISTS faculties (
    id VARCHAR(255) PRIMARY KEY,
    faculty_name VARCHAR(255)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS rooms (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(10) NOT NULL,
    capacity INT NOT NULL,
    building VARCHAR(10) NOT NULL,
    type VARCHAR(255) NOT NULL,
    status VARCHAR(255) NOT NULL,
    note VARCHAR(1000)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS users (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) NOT NULL UNIQUE,
    email VARCHAR(100) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL,
    full_name VARCHAR(100),
    role VARCHAR(20) NOT NULL,
    enabled BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMP NOT NULL,
    updated_at TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS majors (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    major_code VARCHAR(50) NOT NULL,
    class_year VARCHAR(10) NOT NULL,
    major_name VARCHAR(255),
    number_of_students INT NOT NULL,
    faculty_id VARCHAR(255) NOT NULL,
    FOREIGN KEY (faculty_id) REFERENCES faculties(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS semesters (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    semester_name VARCHAR(255) NOT NULL,
    academic_year VARCHAR(255) NOT NULL,
    start_date DATE,
    end_date DATE,
    is_active BOOLEAN,
    description VARCHAR(255),
    UNIQUE (semester_name, academic_year)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS subjects (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    subject_code VARCHAR(255),
    subject_name VARCHAR(255),
    students_per_class INT,
    number_of_classes INT,
    credits INT,
    theory_hours INT,
    exercise_hours INT,
    project_hours INT,
    lab_hours INT,
    self_study_hours INT,
    department VARCHAR(255),
    exam_format VARCHAR(255),
    program_type VARCHAR(255),
    major_id BIGINT,
    semester_id BIGINT,
    is_common BOOLEAN,
    FOREIGN KEY (major_id) REFERENCES majors(id),
    FOREIGN KEY (semester_id) REFERENCES semesters(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS tkb_templates (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    template_id VARCHAR(50) NOT NULL,
    total_periods INT NOT NULL,
    day_of_week INT,
    kip INT NOT NULL,
    start_period INT NOT NULL,
    period_length INT NOT NULL,
    week_schedule JSON NOT NULL,
    total_used INT DEFAULT 0,
    semester_id BIGINT NOT NULL,
    row_order INT NOT NULL,
    FOREIGN KEY (semester_id) REFERENCES semesters(id),
    UNIQUE (template_id, semester_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS room_occupancies (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    room_id BIGINT NOT NULL,
    semester_id BIGINT NOT NULL,
    day_of_week INT NOT NULL,
    period INT NOT NULL,
    unique_key VARCHAR(50) NOT NULL,
    note VARCHAR(500),
    FOREIGN KEY (room_id) REFERENCES rooms(id),
    FOREIGN KEY (semester_id) REFERENCES semesters(id),
    UNIQUE uk_room_semester_time (room_id, semester_id, day_of_week, period)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS schedules (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    subject_id BIGINT NOT NULL,
    class_number INT,
    student_year VARCHAR(255),
    major VARCHAR(255),
    special_system VARCHAR(255),
    si_so_mot_lop INT,
    room_id BIGINT,
    user_id BIGINT,
    template_id BIGINT NOT NULL,
    FOREIGN KEY (subject_id) REFERENCES subjects(id),
    FOREIGN KEY (room_id) REFERENCES rooms(id),
    FOREIGN KEY (user_id) REFERENCES users(id),
    FOREIGN KEY (template_id) REFERENCES tkb_templates(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS major_building_preferences (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    nganh VARCHAR(255) NOT NULL,
    preferred_building VARCHAR(255) NOT NULL,
    priority_level INT NOT NULL,
    is_active BOOLEAN DEFAULT TRUE,
    notes VARCHAR(255),
    created_at TIMESTAMP,
    updated_at TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =============================================
-- 2. Insert Data
-- =============================================

-- Insert dữ liệu faculties
INSERT INTO faculties (id, faculty_name) VALUES
('AT1', 'An toàn thông tin'),
('CB1', 'Cơ bản'),
('CN1', 'Công nghệ thông tin'),
('DT1', 'Điện tử'),
('KT1', 'Kinh tế'),
('PT1', 'Phát thanh truyền hình'),
('QT1', 'Quản trị'),
('TTQT', 'Thông tin quản trị'),
('VKH', 'Viễn thông khoa học'),
('VKT', 'Viễn thông kỹ thuật'),
('VT1', 'Viễn thông')
ON DUPLICATE KEY UPDATE 
id = VALUES(id),
faculty_name = VALUES(faculty_name);

-- Insert dữ liệu phòng học với id cụ thể
INSERT IGNORE INTO rooms (id, name, capacity, building, type, status, note) VALUES
(1, '301', 36, 'A1', 'CLC', 'AVAILABLE', 'Lớp CLC 2024'),
(2, '302', 36, 'A1', 'CLC', 'AVAILABLE', 'Lớp CLC 2024'),
(3, '303', 36, 'A1', 'CLC', 'AVAILABLE', 'Lớp CLC 2024'),
(4, '502', 45, 'A1', 'CLC', 'AVAILABLE', 'Lớp CLC'),
(5, '503', 40, 'A1', 'CLC', 'AVAILABLE', 'Lớp CLC'),
(6, '504', 50, 'A1', 'CLC', 'AVAILABLE', 'Lớp CLC'),
(7, '505', 50, 'A1', 'CLC', 'AVAILABLE', 'Lớp CLC'),
(8, '506', 50, 'A1', 'CLC', 'AVAILABLE', 'Lớp CLC'),
(9, 'G01', 48, 'A2', 'ENGLISH_CLASS', 'AVAILABLE', 'Phòng học TA 1.0'),
(10, 'G02', 64, 'A2', 'GENERAL', 'AVAILABLE', ''),
(11, 'G03', 80, 'A2', 'GENERAL', 'AVAILABLE', '1.0'),
(12, 'G04', 48, 'A2', 'ENGLISH_CLASS', 'AVAILABLE', 'Phòng học TA 1.0'),
(13, 'G05', 48, 'A2', 'ENGLISH_CLASS', 'AVAILABLE', 'Phòng học TA 1.0'),
(14, 'G06', 48, 'A2', 'ENGLISH_CLASS', 'AVAILABLE', 'Phòng học TA'),
(15, '101', 140, 'A2', 'KHOA_2024', 'AVAILABLE', '2024'),
(16, '102', 72, 'A2', 'GENERAL', 'AVAILABLE', ''),
(17, '104', 48, 'A2', 'GENERAL', 'AVAILABLE', ''),
(18, '105', 48, 'A2', 'GENERAL', 'AVAILABLE', ''),
(19, '201', 140, 'A2', 'KHOA_2024', 'AVAILABLE', '2024'),
(20, '204', 48, 'A2', 'CLC', 'AVAILABLE', 'Lớp CLC'),
(21, '205', 48, 'A2', 'CLC', 'AVAILABLE', 'Lớp CLC'),
(22, '206', 48, 'A2', 'CLC', 'AVAILABLE', 'Lớp CLC'),
(23, '301', 100, 'A2', 'GENERAL', 'AVAILABLE', '1.0'),
(24, '302', 112, 'A2', 'GENERAL', 'AVAILABLE', ''),
(25, '303', 48, 'A2', 'ENGLISH_CLASS', 'AVAILABLE', 'Phòng học TA 1.0'),
(26, '304', 80, 'A2', 'GENERAL', 'AVAILABLE', '1.0'),
(27, '305', 72, 'A2', 'GENERAL', 'AVAILABLE', '1.0'),
(28, '401', 100, 'A2', 'GENERAL', 'AVAILABLE', '1.0'),
(29, '402', 72, 'A2', 'GENERAL', 'AVAILABLE', ''),
(30, '403', 134, 'A2', 'KHOA_2024', 'AVAILABLE', '2024'),
(31, '404', 48, 'A2', 'ENGLISH_CLASS', 'AVAILABLE', 'Phòng học TA 1.0'),
(32, '405', 80, 'A2', 'GENERAL', 'AVAILABLE', '1.0'),
(33, '501', 110, 'A2', 'GENERAL', 'AVAILABLE', '1.0'),
(34, '502', 80, 'A2', 'GENERAL', 'AVAILABLE', ''),
(35, '503', 150, 'A2', 'KHOA_2024', 'AVAILABLE', '2024'),
(36, '504', 48, 'A2', 'ENGLISH_CLASS', 'AVAILABLE', 'Phòng học TA 1.0'),
(37, '505', 72, 'A2', 'GENERAL', 'AVAILABLE', ''),
(38, '601', 110, 'A2', 'GENERAL', 'AVAILABLE', '1.0'),
(39, '602', 80, 'A2', 'GENERAL', 'AVAILABLE', ''),
(40, '603', 130, 'A2', 'KHOA_2024', 'AVAILABLE', '2024'),
(41, '604', 48, 'A2', 'ENGLISH_CLASS', 'AVAILABLE', 'Phòng học TA 1.0'),
(42, '605', 72, 'A2', 'GENERAL', 'AVAILABLE', ''),
(43, '701', 100, 'A2', 'GENERAL', 'AVAILABLE', '1.0'),
(44, '702', 80, 'A2', 'KHOA_2024', 'AVAILABLE', '2024'),
(45, '703', 120, 'A2', 'KHOA_2024', 'AVAILABLE', '2024'),
(46, '704', 48, 'A2', 'ENGLISH_CLASS', 'AVAILABLE', 'Phòng học TA 1.0'),
(47, '705', 72, 'A2', 'KHOA_2024', 'AVAILABLE', '2024'),
(48, '801', 100, 'A2', 'KHOA_2024', 'AVAILABLE', '2024'),
(49, '802', 80, 'A2', 'KHOA_2024', 'AVAILABLE', '2024'),
(50, '101', 50, 'A3', 'GENERAL', 'AVAILABLE', NULL),
(51, '201A', 72, 'A3', 'GENERAL', 'AVAILABLE', '1.0'),
(52, '201B', 80, 'A3', 'GENERAL', 'AVAILABLE', ''),
(53, '202', 56, 'A3', 'GENERAL', 'AVAILABLE', ''),
(54, '204', 56, 'A3', 'GENERAL', 'AVAILABLE', '1.0'),
(55, '205', 110, 'A3', 'KHOA_2024', 'AVAILABLE', '2024'),
(56, '206', 56, 'A3', 'GENERAL', 'AVAILABLE', '1.0'),
(57, '207', 120, 'A3', 'KHOA_2024', 'AVAILABLE', '2024'),
(58, '208', 56, 'A3', 'GENERAL', 'AVAILABLE', '1.0'),
(59, '302', 56, 'A3', 'GENERAL', 'AVAILABLE', ''),
(60, '303', 110, 'A3', 'KHOA_2024', 'AVAILABLE', '2024'),
(61, '304', 56, 'A3', 'GENERAL', 'AVAILABLE', '1.0'),
(62, '305', 70, 'A3', 'GENERAL', 'AVAILABLE', ''),
(63, '306', 56, 'A3', 'GENERAL', 'AVAILABLE', '1.0'),
(64, '308', 56, 'A3', 'GENERAL', 'AVAILABLE', ''),
(65, '309', 110, 'A3', 'KHOA_2024', 'AVAILABLE', '2024'),
(66, '311', 140, 'A3', 'KHOA_2024', 'AVAILABLE', '2024'),
(67, '403', 120, 'A3', 'KHOA_2024', 'AVAILABLE', '2024'),
(68, '405', 70, 'A3', 'GENERAL', 'AVAILABLE', '1.0'),
(69, '409', 120, 'A3', 'KHOA_2024', 'AVAILABLE', '2024'),
(70, '411', 70, 'A3', 'GENERAL', 'AVAILABLE', '1.0'),
(71, '413', 70, 'A3', 'GENERAL', 'AVAILABLE', '1.0'),
(72, '101', 75, 'NT', 'NGOC_TRUC', 'AVAILABLE', 'NT'),
(73, '102', 60, 'NT', 'NGOC_TRUC', 'AVAILABLE', 'NT'),
(74, '201', 64, 'NT', 'NGOC_TRUC', 'AVAILABLE', 'NT'),
(75, '202', 64, 'NT', 'NGOC_TRUC', 'AVAILABLE', 'NT'),
(76, '301', 40, 'NT', 'NGOC_TRUC', 'AVAILABLE', 'NT'),
(77, '302', 64, 'NT', 'NGOC_TRUC', 'AVAILABLE', 'NT'),
(78, '303', 40, 'NT', 'NGOC_TRUC', 'AVAILABLE', 'NT'),
(79, '304', 64, 'NT', 'NGOC_TRUC', 'AVAILABLE', 'NT'),
(80, '305', 64, 'NT', 'NGOC_TRUC', 'AVAILABLE', 'NT'),
(81, '401', 40, 'NT', 'NGOC_TRUC', 'AVAILABLE', 'NT'),
(82, '402', 64, 'NT', 'NGOC_TRUC', 'AVAILABLE', 'NT'),
(83, '403', 40, 'NT', 'NGOC_TRUC', 'AVAILABLE', 'NT'),
(84, '404', 64, 'NT', 'NGOC_TRUC', 'AVAILABLE', 'NT'),
(85, '405', 75, 'NT', 'NGOC_TRUC', 'AVAILABLE', 'NT'),
(86, '501', 75, 'NT', 'NGOC_TRUC', 'AVAILABLE', 'NT'),
(87, '502', 75, 'NT', 'NGOC_TRUC', 'AVAILABLE', 'NT'),
(88, '503', 40, 'NT', 'NGOC_TRUC', 'AVAILABLE', 'NT'),
(89, '504', 60, 'NT', 'NGOC_TRUC', 'AVAILABLE', 'NT'),
(90, '505', 90, 'NT', 'NGOC_TRUC', 'AVAILABLE', 'NT'),
(91, '601', 75, 'NT', 'NGOC_TRUC', 'AVAILABLE', 'NT'),
(92, '602', 75, 'NT', 'NGOC_TRUC', 'AVAILABLE', 'NT'),
(93, '603', 40, 'NT', 'NGOC_TRUC', 'AVAILABLE', 'NT'),
(94, '604', 75, 'NT', 'NGOC_TRUC', 'AVAILABLE', 'NT'),
(95, '605', 75, 'NT', 'NGOC_TRUC', 'AVAILABLE', 'NT'),
(96, '701', 75, 'NT', 'NGOC_TRUC', 'AVAILABLE', 'NT'),
(97, '702', 75, 'NT', 'NGOC_TRUC', 'AVAILABLE', 'NT'),
(98, '703', 40, 'NT', 'NGOC_TRUC', 'AVAILABLE', 'NT');

-- Insert dữ liệu users
-- Password: '$2a$12$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8lE9lBOsl7iKTVKIUi' tương ứng với '123456'
INSERT IGNORE INTO users (id, username, email, password, full_name, role, enabled, created_at, updated_at) VALUES 
(1, 'admin', 'admin@ptit.edu.vn', '$2a$12$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8lE9lBOsl7iKTVKIUi', 'Quản trị viên', 'ADMIN', true, NOW(), NOW()),
(2, 'teacher1', 'teacher1@ptit.edu.vn', '$2a$12$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8lE9lBOsl7iKTVKIUi', 'Giảng viên 1', 'TEACHER', true, NOW(), NOW());

-- Insert dữ liệu majors
INSERT IGNORE INTO majors (id, major_code, class_year, major_name, number_of_students, faculty_id) VALUES
(1, 'CNTT', 'D21', 'Công nghệ thông tin', 500, 'CN1'),
(2, 'ATTT', 'D21', 'An toàn thông tin', 300, 'AT1'),
(3, 'DTVT', 'D21', 'Điện tử viễn thông', 400, 'VT1');

-- Insert dữ liệu semesters
INSERT IGNORE INTO semesters (id, semester_name, academic_year, start_date, end_date, is_active, description) VALUES
(1, 'Học kỳ 1', '2024-2025', '2024-08-15', '2024-12-31', true, 'HK1 năm học 24-25'),
(2, 'Học kỳ 2', '2024-2025', '2025-01-15', '2025-05-31', false, 'HK2 năm học 24-25');

-- Insert dữ liệu subjects
INSERT IGNORE INTO subjects (id, subject_code, subject_name, students_per_class, number_of_classes, credits, theory_hours, exercise_hours, project_hours, lab_hours, self_study_hours, department, exam_format, program_type, major_id, semester_id, is_common) VALUES
(1, 'INT1408', 'Cơ sở dữ liệu', 60, 5, 3, 30, 15, 0, 0, 90, 'Hệ thống thông tin', 'Thi viết', 'Chính quy', 1, 1, false),
(2, 'INT1416', 'Lập trình Web', 60, 4, 3, 30, 0, 15, 0, 90, 'Công nghệ phần mềm', 'Thực hành', 'Chính quy', 1, 1, false),
(3, 'BAS1203', 'Giải tích 1', 80, 10, 3, 30, 15, 0, 0, 90, 'Toán học', 'Thi viết', 'Chính quy', null, 1, true);

-- Insert dữ liệu tkb_templates
INSERT IGNORE INTO tkb_templates (id, template_id, total_periods, day_of_week, kip, start_period, period_length, week_schedule, total_used, semester_id, row_order) VALUES
(1, 'TPL01', 45, 2, 1, 1, 3, '[1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,0,0,0]', 0, 1, 1),
(2, 'TPL02', 45, 3, 2, 4, 3, '[1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,0,0,0]', 0, 1, 2);

-- Insert dữ liệu room_occupancies
INSERT IGNORE INTO room_occupancies (id, room_id, semester_id, day_of_week, period, unique_key, note) VALUES
(1, 1, 1, 2, 1, '301-A1|2|1', 'Đã đặt'),
(2, 1, 1, 2, 2, '301-A1|2|2', 'Đã đặt'),
(3, 1, 1, 2, 3, '301-A1|2|3', 'Đã đặt');

-- Insert dữ liệu schedules
INSERT IGNORE INTO schedules (id, subject_id, class_number, student_year, major, special_system, si_so_mot_lop, room_id, user_id, template_id) VALUES
(1, 1, 1, 'D21', 'CNTT', 'Chính quy', 60, 1, 1, 1),
(2, 2, 1, 'D21', 'CNTT', 'Chính quy', 60, 2, 1, 2);

-- Insert dữ liệu major_building_preferences
INSERT IGNORE INTO major_building_preferences (id, nganh, preferred_building, priority_level, is_active, notes, created_at, updated_at) VALUES
(1, 'CNTT', 'A2', 1, true, 'Ưu tiên xếp tòa A2 cho CNTT', NOW(), NOW()),
(2, 'ATTT', 'A3', 1, true, 'Ưu tiên tòa A3 cho ATTT', NOW(), NOW());
