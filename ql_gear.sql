use ql_gear_computer;

CREATE TABLE users (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    username VARCHAR(100) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL,
    full_name VARCHAR(150),
    email VARCHAR(150),
    phone VARCHAR(20),
    role VARCHAR(20)
);
CREATE TABLE categories (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    category_name VARCHAR(100) NOT NULL,
    description TEXT
);
CREATE TABLE products (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    product_name VARCHAR(200) NOT NULL,
    brand VARCHAR(100),
    description TEXT,
    price DOUBLE,
    image_url VARCHAR(255),
    status VARCHAR(30),

    category_id BIGINT,
    FOREIGN KEY (category_id)
    REFERENCES categories(id)
);
CREATE TABLE inventories (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    quantity INT DEFAULT 0,
    import_date DATE,
    
    product_id BIGINT UNIQUE,
    FOREIGN KEY (product_id)
    REFERENCES products(id)
);
CREATE TABLE orders (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    order_date DATETIME,
    total_price DOUBLE,
    status VARCHAR(30),

    user_id BIGINT,
    FOREIGN KEY (user_id)
    REFERENCES users(id)
);
CREATE TABLE order_items (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    quantity INT,
    unit_price DOUBLE,
    subtotal DOUBLE,
    
    order_id BIGINT,
    product_id BIGINT,
    FOREIGN KEY (order_id)
    REFERENCES orders(id),
    FOREIGN KEY (product_id)
    REFERENCES products(id)
);

-- Trigger cập nhật tồn kho
DELIMITER $$

CREATE TRIGGER trg_reduce_inventory
AFTER INSERT ON order_items
FOR EACH ROW
BEGIN

    UPDATE inventories
    SET quantity = quantity - NEW.quantity
    WHERE product_id = NEW.product_id;

END $$
DELIMITER ;

-- trigger kiểm tra tồn kho
DELIMITER $$
CREATE TRIGGER trg_check_inventory
BEFORE INSERT ON order_items
FOR EACH ROW
BEGIN

    DECLARE current_stock INT;
    SELECT quantity
    INTO current_stock
    FROM inventories
    WHERE product_id = NEW.product_id;

    IF current_stock < NEW.quantity THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Not enough stock';
    END IF;
END $$
DELIMITER ;


-- procedure tạo đơn hàng
DELIMITER $$
CREATE PROCEDURE GetAllProducts()
BEGIN
    SELECT * FROM products;
END $$
DELIMITER ;
CALL GetAllProducts();


-- Procedure tính doanh thu
DELIMITER $$
CREATE PROCEDURE CalculateRevenue()
BEGIN
    SELECT SUM(total_price) AS total_revenue
    FROM orders
    WHERE status = 'COMPLETED';
END $$
-- func tính subtotal
DELIMITER $$

CREATE FUNCTION CalculateSubtotal(
    qty INT,
    price DOUBLE
)
RETURNS DOUBLE
DETERMINISTIC
BEGIN
    RETURN qty * price;
END $$
DELIMITER;
-- test
SELECT CalculateSubtotal(2, 450000);
DELIMITER ;


-- view xem chi tiết sp
CREATE VIEW product_detail_view AS

SELECT
    p.product_name,
    c.category_name,
    i.quantity

FROM products p
JOIN categories c
ON p.category_id = c.id
JOIN inventories i
ON p.id = i.product_id;




-- -----------------------------------
-- Thêm dữ liệu
INSERT INTO users(username,password,full_name,email,phone,role) VALUES
('admin','123','Administrator','admin@gmail.com','0900000001','ADMIN'),
('staff01','123','Nguyen Van A','staff01@gmail.com','0900000002','STAFF'),
('customer01','123','Tran Van B','customer01@gmail.com','0900000003','CUSTOMER');

INSERT INTO categories(category_name,description) VALUES
('Gaming Mouse','Chuột gaming'),
('Keyboard','Bàn phím cơ'),
('Headphone','Tai nghe gaming'),
('Monitor','Màn hình máy tính');

INSERT INTO products(product_name,brand,description,price,image_url,status,category_id) VALUES
('Logitech G102','Logitech','Gaming mouse RGB',450000,'g102.jpg','AVAILABLE',1),
('Razer Viper Mini','Razer','Lightweight gaming mouse',790000, 'viper-mini.jpg','AVAILABLE',1),
('AKKO 3084','AKKO','Mechanical keyboard', 1500000,'akko3084.jpg','AVAILABLE',2),
('HyperX Cloud II','HyperX','Gaming headset',1990000,'cloud2.jpg','AVAILABLE',3),
('LG UltraGear 24','LG','144Hz Gaming Monitor',4500000,'lgultragear.jpg','AVAILABLE',4);

INSERT INTO inventories(quantity,import_date,product_id) VALUES
(20,'2026-05-01',1),
(15,'2026-05-01',2),
(10,'2026-05-01',3),
(8,'2026-05-01',4),
(5,'2026-05-01',5);
-- bo sung
ALTER TABLE products
ADD CONSTRAINT chk_price
CHECK(price > 0);

ALTER TABLE inventories
ADD CONSTRAINT chk_quantity
CHECK(quantity >= 0);

select * from users;
select * from categories;
select * from products;
select * from inventories;
select * from orders;
select * from order_items;
