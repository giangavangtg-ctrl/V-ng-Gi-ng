-- Bước 1: Tạo và sử dụng cơ sở dữ liệu demo
CREATE DATABASE IF NOT EXISTS demo_db;
USE demo_db;

-- Bước 2: Tạo bảng Products
CREATE TABLE IF NOT EXISTS Products (
    Id INT AUTO_INCREMENT PRIMARY KEY,
    productCode VARCHAR(20) NOT NULL,
    productName VARCHAR(100) NOT NULL,
    productPrice DECIMAL(10,2) NOT NULL,
    productAmount INT NOT NULL,
    productDescription TEXT,
    productStatus BOOLEAN
);

-- Chèn dữ liệu mẫu
INSERT INTO Products (productCode, productName, productPrice, productAmount, productDescription, productStatus)
VALUES
('P01', 'Iphone 15 Pro Max', 1200.00, 50, 'Smartphone Apple', 1),
('P02', 'Samsung Galaxy S24', 1100.00, 40, 'Smartphone Samsung', 1),
('P03', 'MacBook Pro M3', 2500.00, 20, 'Laptop Apple', 1),
('P04', 'Dell XPS 15', 2000.00, 15, 'Laptop Dell', 1),
('P05', 'AirPods Pro 2', 250.00, 100, 'Tai nghe không dây', 1);
-- A. KIỂM TRA TRƯỚC KHI TẠO INDEX
-- Kết quả ở cột "type" sẽ là "ALL" (Full Table Scan) và cột "rows" quét toàn bộ số dòng trong bảng.
EXPLAIN SELECT * FROM Products WHERE productCode = 'P03';
EXPLAIN SELECT * FROM Products WHERE productName = 'MacBook Pro M3' AND productPrice = 2500.00;

-- B. TẠO INDEX
-- 1. Tạo Unique Index trên cột productCode (vì mã sản phẩm là duy nhất)
CREATE UNIQUE INDEX idx_productCode ON Products(productCode);

-- 2. Tạo Composite Index trên 2 cột productName và productPrice
CREATE INDEX idx_name_price ON Products(productName, productPrice);

-- C. KIỂM TRA LẠI SAU KHI TẠO INDEX
-- Lúc này, cột "type" sẽ chuyển thành "const" hoặc "ref", cột "possible_keys" nhận diện được Index vừa tạo, và số "rows" quét giảm xuống mức tối thiểu.
EXPLAIN SELECT * FROM Products WHERE productCode = 'P03';
EXPLAIN SELECT * FROM Products WHERE productName = 'MacBook Pro M3' AND productPrice = 2500.00;
-- 1. Tạo View lấy ra một số thông tin cơ bản
CREATE VIEW view_products AS
SELECT productCode, productName, productPrice, productStatus
FROM Products;

-- Truy vấn để xem thử View
SELECT * FROM view_products;

-- 2. Sửa đổi View (Thêm cột productAmount và chỉ lấy sản phẩm có Status = 1)
CREATE OR REPLACE VIEW view_products AS
SELECT productCode, productName, productPrice, productAmount, productStatus
FROM Products
WHERE productStatus = 1;

-- 3. Xóa View
DROP VIEW view_products;
-- 1. Tạo SP lấy tất cả thông tin
DELIMITER //
CREATE PROCEDURE GetAllProducts()
BEGIN
    SELECT * FROM Products;
END //
DELIMITER ;

-- Gọi thử: CALL GetAllProducts();

-- 2. Tạo SP thêm một sản phẩm mới (Dùng tham số IN truyền vào)
DELIMITER //
CREATE PROCEDURE AddProduct(
    IN p_code VARCHAR(20),
    IN p_name VARCHAR(100),
    IN p_price DECIMAL(10,2),
    IN p_amount INT,
    IN p_desc TEXT,
    IN p_status BOOLEAN
)
BEGIN
    INSERT INTO Products (productCode, productName, productPrice, productAmount, productDescription, productStatus)
    VALUES (p_code, p_name, p_price, p_amount, p_desc, p_status);
END //
DELIMITER ;

-- Gọi thử: CALL AddProduct('P06', 'Chuột Logitech', 50.00, 200, 'Chuột không dây', 1);

-- 3. Tạo SP sửa thông tin sản phẩm theo Id
DELIMITER //
CREATE PROCEDURE UpdateProduct(
    IN p_id INT,
    IN p_code VARCHAR(20),
    IN p_name VARCHAR(100),
    IN p_price DECIMAL(10,2),
    IN p_amount INT,
    IN p_desc TEXT,
    IN p_status BOOLEAN
)
BEGIN
    UPDATE Products
    SET productCode = p_code,
        productName = p_name,
        productPrice = p_price,
        productAmount = p_amount,
        productDescription = p_desc,
        productStatus = p_status
    WHERE Id = p_id;
END //
DELIMITER ;

-- Gọi thử: CALL UpdateProduct(1, 'P01-Pro', 'Iphone 15 Pro Max 1TB', 1500.00, 30, 'Bản nâng cấp', 1);

-- 4. Tạo SP xoá sản phẩm theo Id
DELIMITER //
CREATE PROCEDURE DeleteProduct(IN p_id INT)
BEGIN
    DELETE FROM Products WHERE Id = p_id;
END //
DELIMITER ;

-- Gọi thử: CALL DeleteProduct(2);