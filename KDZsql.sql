DROP VIEW IF EXISTS v_PhoneDetails;
DROP VIEW IF EXISTS v_CustomerPurchases;
DROP VIEW IF EXISTS v_WarehouseStock;
DROP TABLE IF EXISTS shipment;
DROP TABLE IF EXISTS provide;
DROP TABLE IF EXISTS salesDetail;
DROP TABLE IF EXISTS salesHeader;
DROP TABLE IF EXISTS shops;
DROP TABLE IF EXISTS warehouse;
DROP TABLE IF EXISTS сustomers;
DROP TABLE IF EXISTS addresses;
DROP TABLE IF EXISTS phones;
DROP TABLE IF EXISTS phonesCategory;
GO

CREATE TABLE phonesCategory (
    id INT PRIMARY KEY IDENTITY,
	parentcategoryId INT,
    maker VARCHAR(50) NOT NULL,
);
CREATE TABLE phones (
	id INT PRIMARY KEY IDENTITY,
	name VARCHAR(50) NOT NULL,
	serialNumber VARCHAR(100) NOT NULL,
	cost money NOT NULL,
	categoryId INT REFERENCES phonesCategory(id) on delete cascade,
);
CREATE TABLE addresses (
    id INT PRIMARY KEY IDENTITY,
	flat VARCHAR(255),
    street VARCHAR(255) NOT NULL,
	city VARCHAR(255) NOT NULL,
);
CREATE TABLE сustomers (
    id INT PRIMARY KEY IDENTITY,
    firstName NVARCHAR(50),
	midleName NVARCHAR(50),
    lastName NVARCHAR(50),
    email NVARCHAR(100),
);
CREATE TABLE warehouse (
    id INT PRIMARY KEY IDENTITY,
    phoneId INT NOT NULL REFERENCES phones(id) ON DELETE CASCADE,
    quantity INT NOT NULL CHECK (quantity >= 0),
	addressLine varchar(100),
);
CREATE TABLE shops (
    id INT PRIMARY KEY IDENTITY,
    name VARCHAR(255) NOT NULL,
	warehouseId INT REFERENCES warehouse(id) ON DELETE CASCADE,
	addresId INT FOREIGN KEY REFERENCES addresses(id) ON DELETE CASCADE,
);
CREATE TABLE salesHeader (
    id INT PRIMARY KEY IDENTITY,
	totalPrice money,
    shopsId INT FOREIGN KEY REFERENCES shops(id) ON DELETE CASCADE,
    customerId INT FOREIGN KEY REFERENCES сustomers(id) ON DELETE CASCADE,
    saleDate DATETIME DEFAULT GETDATE(),
);
CREATE TABLE salesDetail (
    saleID INT PRIMARY KEY REFERENCES salesHeader(id) ON DELETE CASCADE,
	unitPrice money DEFAULT 0,
    phoneId INT FOREIGN KEY REFERENCES phones(id),
	qty INT NOT NULL,
);
CREATE TABLE provide (
    id INT PRIMARY KEY IDENTITY,
	name VARCHAR(255) NOT NULL,
	PostalCode NVARCHAR(20),
	p_number VARCHAR(50),
);
CREATE TABLE shipment (
    id INT PRIMARY KEY IDENTITY,
    warehouseId INT FOREIGN KEY REFERENCES warehouse(id) ON DELETE CASCADE,
	phoneId INT FOREIGN KEY REFERENCES phones(id),
	provideId INT FOREIGN KEY REFERENCES provide(id),
	qty INT NOT NULL CHECK (qty >= 0),
	checker BIT DEFAULT 0
);
GO
--Тригеры
--Заполнение totalPrice при изменении salesDetail
CREATE TRIGGER trg_UpdateTotalPrice
ON salesDetail
AFTER INSERT, UPDATE
AS
BEGIN
    DECLARE @SaleID INT;

    -- Получаем SaleID из вставленной или обновленной строки
    SELECT @SaleID = i.saleID
    FROM inserted i;

    -- Обновляем totalPrice в таблице salesHeader
    UPDATE salesHeader
    SET totalPrice = (
        SELECT SUM(sd.unitPrice * sd.qty)
        FROM salesDetail sd
        WHERE sd.saleID = @SaleID
    )
    WHERE id = @SaleID;
END;
GO

--Создание записис в shipment если количество товаров на складе становится меньше 10.
CREATE TRIGGER trg_OrderIfStockLow
ON warehouse
AFTER INSERT, UPDATE
AS
BEGIN
    DECLARE @PhoneID INT, @WarehouseID INT, @Quantity INT;

    SELECT @PhoneID = inserted.phoneId, 
           @WarehouseID = inserted.id,
           @Quantity = inserted.quantity
    FROM inserted
    WHERE inserted.quantity < 10;

    IF @Quantity < 10
    BEGIN
        -- Вставляем новую запись в таблицу shipment для заказа товаров
        INSERT INTO shipment (warehouseId, phoneId, provideId, qty, checker)
        VALUES (@WarehouseID, @PhoneID, 
                -- Допустим, provideId = 1 для всех новых заказов
                1, 
                -- Количество заказываемых товаров, например 100
                100,
                -- Устанавливаем checker в 0 (не проверено)
                0);
    END;
END;
GO

--При изменении cheker в поставках на 1, выполняет поставку
CREATE TRIGGER trg_AddToWarehouseOnShipmentChecker
ON shipment
AFTER UPDATE
AS
BEGIN
    DECLARE @ShipmentID INT, @WarehouseID INT, @PhoneID INT, @Quantity INT, @Checker BIT;

    -- Получаем данные об обновленных строках
    SELECT @ShipmentID = inserted.id, 
           @WarehouseID = inserted.warehouseId,
           @PhoneID = inserted.phoneId,
           @Quantity = inserted.qty,
           @Checker = inserted.checker
    FROM inserted
    WHERE inserted.checker = 1;

    IF @Checker = 1
    BEGIN
        -- Проверка, существует ли запись в таблице warehouse
        IF EXISTS (SELECT 1 FROM warehouse WHERE phoneId = @PhoneID AND id = @WarehouseID)
        BEGIN
            -- Обновление количества на складе (если запись существует)
            UPDATE warehouse
            SET quantity = quantity + @Quantity
            WHERE phoneId = @PhoneID AND id = @WarehouseID;
        END
        ELSE
        BEGIN
            -- Вставка новой записи в таблицу warehouse (если запись не существует)
            INSERT INTO warehouse (phoneId, quantity, addressLine)
            VALUES (@PhoneID, @Quantity, 'Default Address');
        END
    END;
END;
GO







--заполнение
INSERT INTO phonesCategory (parentcategoryId, maker) VALUES (NULL, 'Apple');
INSERT INTO phonesCategory (parentcategoryId, maker) VALUES (NULL, 'Samsung');
INSERT INTO phonesCategory (parentcategoryId, maker) VALUES (NULL, 'Samsung');
INSERT INTO phonesCategory (parentcategoryId, maker) VALUES (1, 'Apple 10');
INSERT INTO phonesCategory (parentcategoryId, maker) VALUES (2, 'Samsung 12');

INSERT INTO phones (name, serialNumber, cost, categoryId) VALUES ('iPhone 13', 'SN123456', 999.99, 1);
INSERT INTO phones (name, serialNumber, cost, categoryId) VALUES ('Galaxy S21', 'SN654321', 799.99, 2);
INSERT INTO phones (name, serialNumber, cost, categoryId) VALUES ('Pixel 6', 'SN789012', 699.99, 3);

INSERT INTO addresses (flat, street, city) VALUES ('93', '123 Main St', 'New York');
INSERT INTO addresses (flat, street, city) VALUES ('75', '456 Elm St', 'Los Angeles');
INSERT INTO addresses (flat, street, city) VALUES ('36', '789 Oak St', 'Chicago');

INSERT INTO сustomers (firstName, midleName, lastName, email) VALUES ('John', 'Elizabeth', 'Doe', 'john.doe@example.com');
INSERT INTO сustomers (firstName, midleName, lastName, email) VALUES ('Jane', 'Barbara', 'Smith', 'jane.smith@example.com');
INSERT INTO сustomers (firstName, midleName, lastName, email) VALUES ('Alice', 'Ellen', 'Johnson', 'alice.johnson@example.com');


INSERT INTO provide (name, p_number, PostalCode) VALUES ('Provider 1', '123-456-7890', '123456');
INSERT INTO provide (name, p_number, PostalCode) VALUES ('Provider 2', '098-765-4321', '974334');
INSERT INTO provide (name, p_number, PostalCode) VALUES ('Provider 3', '555-555-5555', '238953');

INSERT INTO warehouse (phoneId, quantity, addressLine) VALUES (1, 50, '8713 Yosemite Ct.');
INSERT INTO warehouse (phoneId, quantity, addressLine) VALUES (2, 30, '1318 Lasalle Street');
INSERT INTO warehouse (phoneId, quantity, addressLine) VALUES (3, 9, '9178 Jumping St.');

INSERT INTO shops (name, warehouseId, addresId) VALUES ('Tech Store 1', 1, 1);
INSERT INTO shops (name, warehouseId, addresId) VALUES ('Tech Store 2', 2, 2);
INSERT INTO shops (name, warehouseId, addresId) VALUES ('Tech Store 3', 3, 3);

INSERT INTO salesHeader (shopsId, customerId, saleDate) VALUES (1, 1, '2023-01-01');
INSERT INTO salesHeader (shopsId, customerId, saleDate) VALUES (2, 2, '2024-01-01');
INSERT INTO salesHeader (shopsId, customerId, saleDate) VALUES (3, 3, '2025-01-01');

INSERT INTO salesDetail (saleID, unitPrice, phoneId, qty) VALUES (1, 999.99, 1, 2);
INSERT INTO salesDetail (saleID, unitPrice, phoneId, qty) VALUES (2, 799.99, 2, 1);
INSERT INTO salesDetail (saleID, unitPrice, phoneId, qty) VALUES (3, 699.99, 3, 4);

INSERT INTO shipment (warehouseId, phoneId, provideId, qty, checker) VALUES (1, 1, 1, 10, 1);
INSERT INTO shipment (warehouseId, phoneId, provideId, qty, checker) VALUES (2, 2, 2, 15, 1);
INSERT INTO shipment (warehouseId, phoneId, provideId, qty, checker) VALUES (3, 3, 3, 20, 1);


--тест
--select *from shipment
--select *from provide
select *from salesDetail
select *from salesHeader
select *from shops
select *from warehouse
select *from сustomers
select *from addresses
select *from phones
select *from phonesCategory
--представления
--Общий список телефонов с категориями
GO
DROP VIEW IF EXISTS v_PhoneDetails;
go
CREATE VIEW v_PhoneDetails AS
SELECT 
    p.id AS PhoneID,
    p.name AS PhoneName,
    p.serialNumber AS SerialNumber,
    p.cost AS Cost,
    pc.id AS CategoryID,
    pc.maker AS Maker,
    pc.parentcategoryId AS ParentCategoryID
FROM phones p
JOIN phonesCategory pc ON p.categoryId = pc.id;
GO
--Информация о клиентах и их покупках
CREATE VIEW v_CustomerPurchases AS
SELECT 
    c.id AS CustomerID,
    c.firstName AS FirstName,
    c.lastName AS LastName,
    c.email AS Email,
    sh.id AS SaleID,
    sh.saleDate AS SaleDate,
    sd.phoneId AS PhoneID,
    p.name AS PhoneName,
    sd.unitPrice AS UnitPrice,
    sd.qty AS Quantity,
    (sd.unitPrice * sd.qty) AS TotalPrice
FROM сustomers c
JOIN salesHeader sh ON c.id = sh.customerId
JOIN salesDetail sd ON sh.id = sd.saleID
JOIN phones p ON sd.phoneId = p.id;
GO
--Запасы на складе
CREATE VIEW v_WarehouseStock AS
SELECT 
    w.id AS WarehouseID,
    w.phoneId AS PhoneID,
    p.name AS PhoneName,
    p.serialNumber AS SerialNumber,
    p.cost AS Cost,
    w.quantity AS Quantity
FROM warehouse w
JOIN phones p ON w.phoneId = p.id;
GO
--тест
--select * from v_PhoneDetails
--select * from v_CustomerPurchases
--select * from v_WarehouseStock
GO



--возможность изменения, добавления и удаления записей
--добавить
CREATE TRIGGER trg_Insert_v_PhoneDetails
ON v_PhoneDetails
INSTEAD OF INSERT
AS
BEGIN
    INSERT INTO phones (name, serialNumber, cost, categoryId)
    SELECT PhoneName, SerialNumber, Cost, CategoryID
    FROM inserted;
END;
GO
--изменить
CREATE TRIGGER trg_Update_v_PhoneDetails
ON v_PhoneDetails
INSTEAD OF UPDATE
AS
BEGIN
    UPDATE phones
    SET name = i.PhoneName,
        serialNumber = i.SerialNumber,
        cost = i.Cost,
        categoryId = i.CategoryID
    FROM phones p
    JOIN inserted i ON p.id = i.PhoneID;

    UPDATE phonesCategory
    SET maker = i.Maker,
        parentcategoryId = i.ParentCategoryID
    FROM phonesCategory pc
    JOIN inserted i ON pc.id = i.CategoryID;
END;
GO
--удалить
CREATE TRIGGER trg_Delete_v_PhoneDetails
ON v_PhoneDetails
INSTEAD OF DELETE
AS
BEGIN
    DELETE FROM phones
    WHERE id IN (SELECT PhoneID FROM deleted);
END;
GO


--тест view
--INSERT INTO v_PhoneDetails (PhoneName, SerialNumber, Cost, CategoryID, Maker, ParentCategoryID)
--VALUES ('New Phone', 'SN123456', 500, 1, 'New Maker', 0);

--UPDATE v_PhoneDetails
--SET PhoneName = 'Updated Phone', Cost = 550
--WHERE PhoneID = 1;

--DELETE FROM v_PhoneDetails
--WHERE PhoneID = 1;

--тест триггера
select * from shipment
select * from warehouse
UPDATE shipment set checker = 1 where id = 1
select * from shipment
select * from warehouse
UPDATE warehouse set quantity = 1 where id = 1
select * from shipment