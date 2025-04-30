DROP FUNCTION IF EXISTS fn_GetPhoneDetails;
DROP FUNCTION IF EXISTS fn_GetCustomerSales;
DROP FUNCTION IF EXISTS fn_GetTotalSalesByStore;
DROP PROCEDURE IF EXISTS AddSale;
DROP PROCEDURE IF EXISTS AcceptShipment;
DROP PROCEDURE IF EXISTS GetMoneyColumnsByTable;
GO
CREATE FUNCTION dbo.fn_GetPhoneDetails (@PhoneID INT)
RETURNS TABLE
AS
RETURN
(
    SELECT 
        p.id AS PhoneID,
        p.name AS PhoneName,
        p.serialNumber AS SerialNumber,
        p.cost AS Cost,
        pc.maker AS Maker
    FROM phones p
    JOIN phonesCategory pc ON p.categoryId = pc.id
    WHERE p.id = @PhoneID
);
GO
CREATE FUNCTION dbo.fn_GetCustomerSales (@CustomerID INT)
RETURNS TABLE
AS
RETURN
(
    SELECT 
        c.id AS CustomerID,
        c.firstName AS FirstName,
        c.lastName AS LastName,
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
    JOIN phones p ON sd.phoneId = p.id
    WHERE c.id = @CustomerID
);
GO
CREATE FUNCTION dbo.fn_GetTotalSalesByStore (@StartDate DATETIME, @EndDate DATETIME)
RETURNS TABLE
AS
RETURN
(
    SELECT 
        s.name AS StoreName,
        sh.saleDate AS SaleDateTime,
        SUM(sd.unitPrice * sd.qty) AS TotalSales
    FROM salesHeader sh
    JOIN shops s ON sh.shopsId = s.id
    JOIN salesDetail sd ON sh.id = sd.saleID
    WHERE sh.saleDate BETWEEN @StartDate AND @EndDate
    GROUP BY s.name, sh.saleDate
);
GO



--тест
-- Получить информацию о телефоне с ID = 2
SELECT * FROM dbo.fn_GetPhoneDetails(2);

-- Получить информацию о покупках клиента с ID = 2
SELECT * FROM dbo.fn_GetCustomerSales(2);

-- Получить общую стоимость продаж по магазинам с 1 1 2023 года по 31 12 2023 года
SELECT * FROM dbo.fn_GetTotalSalesByStore('2024-01-01', '2026-12-31');
GO

--процедуры
--получить столбцы с деньгами по таблице
CREATE PROCEDURE GetMoneyColumnsByTable
    @TableName NVARCHAR(255)
AS
BEGIN
    SET NOCOUNT ON;

    SELECT 
        COLUMN_NAME AS ColumnName, 
        DATA_TYPE AS [Type]
    FROM INFORMATION_SCHEMA.COLUMNS
    WHERE TABLE_CATALOG = DB_NAME()
    AND TABLE_SCHEMA = 'dbo'
    AND TABLE_NAME = @TableName
    AND DATA_TYPE IN ('money');
END;
GO

CREATE PROCEDURE AcceptShipment
    @WarehouseID INT
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE shipment
    SET checker = 1
    WHERE warehouseId = @WarehouseID AND checker = 0;
END;
GO

CREATE PROCEDURE AddSale
    @CustomerID INT,
    @ShopID INT,
    @SaleDate DATETIME,
    @PhoneIDs NVARCHAR(MAX),  -- Список ID телефонов через запятую
    @Quantities NVARCHAR(MAX)  -- Соответствующий список количеств через запятую
AS
BEGIN
    DECLARE @SaleID INT;
    DECLARE @TotalPrice MONEY = 0;

    -- Создание новой записи в salesHeader
    INSERT INTO salesHeader (customerId, shopsId, saleDate, totalPrice)
    VALUES (@CustomerID, @ShopID, @SaleDate, @TotalPrice);

    -- Получение идентификатора новой записи
    SET @SaleID = SCOPE_IDENTITY();

    -- Разделение списка ID телефонов и количеств
    DECLARE @PhoneID NVARCHAR(50);
    DECLARE @Quantity NVARCHAR(50);
    DECLARE @Index INT = 1;

    DECLARE @PhoneIDTable TABLE (PhoneID INT, Quantity INT);

    WHILE CHARINDEX(',', @PhoneIDs, @Index) > 0
    BEGIN
        SET @PhoneID = SUBSTRING(@PhoneIDs, @Index, CHARINDEX(',', @PhoneIDs + ',', @Index) - @Index);
        SET @Quantity = SUBSTRING(@Quantities, @Index, CHARINDEX(',', @Quantities + ',', @Index) - @Index);

        INSERT INTO @PhoneIDTable (PhoneID, Quantity)
        VALUES (CAST(@PhoneID AS INT), CAST(@Quantity AS INT));

        SET @Index = CHARINDEX(',', @PhoneIDs + ',', @Index) + 1;
    END

    -- Обработка каждой позиции товара
    DECLARE CursorPhoneIDs CURSOR FOR
    SELECT PhoneID, Quantity
    FROM @PhoneIDTable;

    OPEN CursorPhoneIDs;	
    FETCH NEXT FROM CursorPhoneIDs INTO @PhoneID, @Quantity;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        DECLARE @UnitPrice MONEY;
        SELECT @UnitPrice = cost FROM phones WHERE id = @PhoneID;

        -- Вставка деталей продажи
        INSERT INTO salesDetail (saleID, phoneId, qty, unitPrice)
        VALUES (@SaleID, @PhoneID, @Quantity, @UnitPrice);

        -- Обновление общего итога
        SET @TotalPrice = @TotalPrice + (@UnitPrice * @Quantity);

        -- Обновление количества на складе
        UPDATE warehouse
        SET quantity = quantity - @Quantity
        WHERE phoneId = @PhoneID;

        FETCH NEXT FROM CursorPhoneIDs INTO @PhoneID, @Quantity;
    END;

    CLOSE CursorPhoneIDs;
    DEALLOCATE CursorPhoneIDs;

    -- Обновление общего итога в salesHeader
    UPDATE salesHeader
    SET totalPrice = @TotalPrice
    WHERE id = @SaleID;
END;
GO


--тест
EXEC GetMoneyColumnsByTable @TableName = 'phones';

EXEC AcceptShipment @WarehouseID = 1;

EXEC AddSale 
    @CustomerID = 1, 
    @ShopID = 1, 
    @SaleDate = '2023-11-3', 
    @PhoneIDs = '1,2', 
    @Quantities = '2';

SELECT * FROM salesHeader
SELECT * FROM salesDetail