--1.1
DECLARE @OrderDate DATE = GETDATE(), @DueDate DATE = DATEADD(DAY, 7, GETDATE()), @CustomerID INT = (SELECT TOP 1 CustomerID FROM SalesLT.Customer), @SalesOrderID INT

INSERT INTO SalesLT.SalesOrderHeader (OrderDate, DueDate, CustomerID, ShipMethod, Status, OnlineOrderFlag, RevisionNumber, SubTotal, TaxAmt, Freight)
VALUES (@OrderDate, @DueDate, @CustomerID, 'CARGO TRANSPORT 5', 1, 1, 0, 0, 0, 0)

SET @SalesOrderID = SCOPE_IDENTITY()

PRINT 'SalesOrderID: ' + CAST(@SalesOrderID AS NVARCHAR(10))

--1.2
DECLARE @SalesOrderID INT = 71955, @ProductID INT = 760, @OrderQty INT = 1, @UnitPrice MONEY = 782.99

IF EXISTS (SELECT 1 FROM SalesLT.SalesOrderHeader WHERE SalesOrderID = @SalesOrderID)
BEGIN
	INSERT INTO SalesLT.SalesOrderDetail (SalesOrderID, ProductID, OrderQty, UnitPrice, UnitPriceDiscount, rowguid)
	VALUES (@SalesOrderID, @ProductID, @OrderQty, @UnitPrice, 0, NEWID())
END

ELSE
BEGIN
	PRINT '«аказ не существует'
END

--2.1
DECLARE @AvgMarketPrice MONEY = 2000.00, @MaxAcceptablePrice MONEY = 5000.00, @CurrentAvgPrice MONEY, @CurrentMaxPrice MONEY

SELECT @CurrentAvgPrice = AVG(ListPrice), @CurrentMaxPrice = MAX(ListPrice)
FROM SalesLT.Product
WHERE ProductCategoryID IN (SELECT ProductCategoryID FROM SalesLT.vGetAllCategories WHERE ParentProductCategoryName = 'Bikes')

WHILE (@CurrentAvgPrice < @AvgMarketPrice AND @CurrentMaxPrice < @MaxAcceptablePrice)
BEGIN
	UPDATE SalesLT.Product
	SET ListPrice = ListPrice * 1.10
	WHERE ProductCategoryID IN (SELECT ProductCategoryID FROM SalesLT.vGetAllCategories WHERE ParentProductCategoryName = 'Bikes')

	SELECT @CurrentAvgPrice = AVG(ListPrice), @CurrentMaxPrice = MAX(ListPrice)
	FROM SalesLT.Product
	WHERE ProductCategoryID IN (SELECT ProductCategoryID FROM SalesLT.vGetAllCategories WHERE ParentProductCategoryName = 'Bikes')

	IF @CurrentMaxPrice >= @MaxAcceptablePrice
	BREAK
END

PRINT 'нова€ средн€€: ' + CAST(@CurrentAvgPrice AS NVARCHAR(20))
PRINT 'нова€ максимальна€: ' + CAST(@CurrentMaxPrice AS NVARCHAR(20))