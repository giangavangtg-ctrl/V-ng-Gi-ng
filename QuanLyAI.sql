-- KHỞI TẠO CƠ SỞ DỮ LIỆU
DROP DATABASE IF EXISTS healthsync_db;
CREATE DATABASE healthsync_db;
USE healthsync_db;

-- TẠO BẢNG DANH MỤC BỆNH NHÂN VÀ BÁC SĨ
CREATE TABLE Patients (
    patient_id INT AUTO_INCREMENT PRIMARY KEY,
    full_name VARCHAR(100) NOT NULL,
    phone VARCHAR(15) NOT NULL
);

CREATE TABLE Doctors (
    doctor_id INT AUTO_INCREMENT PRIMARY KEY,
    full_name VARCHAR(100) NOT NULL,
    specialty VARCHAR(50)
);

-- TẠO BẢNG LỊCH HẸN (ĐÃ TỐI ƯU CẤU TRÚC)
CREATE TABLE Appointments (
    appointment_id INT AUTO_INCREMENT PRIMARY KEY,
    patient_id INT,
    doctor_id INT,
    appointment_date DATETIME NOT NULL,
    
    -- Thay thế is_active bằng ENUM để quản lý 5 trạng thái
    status ENUM('PENDING', 'CONFIRMED', 'CHECKED_IN', 'COMPLETED', 'CANCELLED') DEFAULT 'PENDING',
    
    -- Bổ sung các cột tài chính (DECIMAL) và lý do hủy
    deposit_amount DECIMAL(10,2) DEFAULT 0.00,
    penalty_fee DECIMAL(10,2) DEFAULT 0.00,
    cancel_reason VARCHAR(255),
    
    FOREIGN KEY (patient_id) REFERENCES Patients(patient_id) ON DELETE RESTRICT,
    FOREIGN KEY (doctor_id) REFERENCES Doctors(doctor_id) ON DELETE RESTRICT
);

-- TẠO BẢNG ĐƠN THUỐC
CREATE TABLE Prescriptions (
    prescription_id INT AUTO_INCREMENT PRIMARY KEY,
    appointment_id INT,
    medication_details TEXT NOT NULL,
    issued_date DATETIME NOT NULL,
    FOREIGN KEY (appointment_id) REFERENCES Appointments(appointment_id) ON DELETE CASCADE
);

-- ==========================================
-- VẬN HÀNH VÀ CHÉP LIỆU THỰC TẾ (DML)
-- ==========================================

-- Chèn dữ liệu danh mục
INSERT INTO Patients (full_name, phone) VALUES ('Nguyen Van A', '0901234567'), ('Tran Thi B', '0912345678');
INSERT INTO Doctors (full_name, specialty) VALUES ('Dr. John Smith', 'Cardiology'), ('Dr. Jane Doe', 'Dermatology');

-- KỊCH BẢN 1 (Thành công): Lịch hẹn -> Hoàn tất -> Kê đơn
INSERT INTO Appointments (patient_id, doctor_id, appointment_date, status, deposit_amount) 
VALUES (1, 1, '2026-10-05 09:00:00', 'PENDING', 500000.00);

UPDATE Appointments SET status = 'CHECKED_IN' WHERE appointment_id = 1;
UPDATE Appointments SET status = 'COMPLETED' WHERE appointment_id = 1;

INSERT INTO Prescriptions (appointment_id, medication_details, issued_date)
VALUES (1, 'Paracetamol 500mg x 10', '2026-10-05 09:30:00');

-- KỊCH BẢN 2 (Hủy và Phạt): Lịch hẹn -> Hủy -> Phạt
INSERT INTO Appointments (patient_id, doctor_id, appointment_date, status, deposit_amount) 
VALUES (2, 2, '2026-10-06 14:00:00', 'CONFIRMED', 300000.00);

UPDATE Appointments 
SET status = 'CANCELLED', penalty_fee = 150000.00, cancel_reason = 'Bận việc đột xuất' 
WHERE appointment_id = 2;

-- TRUY VẤN KIỂM TRA HỆ THỐNG
SELECT 
    p.full_name AS Patient_Name,
    d.full_name AS Doctor_Name,
    a.appointment_date,
    a.status,
    pr.medication_details
FROM Appointments a
JOIN Patients p ON a.patient_id = p.patient_id
JOIN Doctors d ON a.doctor_id = d.doctor_id
JOIN Prescriptions pr ON a.appointment_id = pr.appointment_id
WHERE a.status = 'COMPLETED';