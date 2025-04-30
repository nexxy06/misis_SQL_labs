--1.1
--CREATE FUNCTION ISOweek (@CustomerID INT)
--RETURNS DECIMAL(18, 2)
--AS
--BEGIN
--    DECLARE @TotalDue DECIMAL(18, 2);

--	SELECT @TotalDue = COALESCE(SUM(TotalDue), 0) 
--	FROM SalesLT.SalesOrderHeader 
--	WHERE CustomerID = @CustomerID;

--    RETURN @TotalDue;
--END;
--GO
----проверка
--SELECT dbo.ISOweek(29485) AS id1;
--SELECT dbo.ISOweek(30113) AS id2;

--SELECT * FROM SalesLT.SalesOrderHeader WHERE CustomerID = 29485;

--1.2
--CREATE VIEW vAllAddresses AS
--SELECT 
--    C.CustomerID,
--    A.AddressID,
--    A.AddressLine1,
--    A.AddressLine2,
--    A.City,
--    A.StateProvince,
--    A.CountryRegion,
--    A.PostalCode
--FROM SalesLT.CustomerAddress CA
--JOIN SalesLT.Customer C ON CA.CustomerID = C.CustomerID
--JOIN SalesLT.Address A ON CA.AddressID = A.AddressID
--GO
----проверка
--SELECT * FROM vAllAddresses;
--SELECT * FROM SalesLT.Address;

--1.3
--CREATE FUNCTION dbo.fn_GetAddressesForCust (@CustomerID INT)
--RETURNS TABLE
--AS
--RETURN
--(
--    SELECT 
--        CustomerID,
--        AddressID,
--        AddressLine1,
--        AddressLine2,
--        City,
--        StateProvince,
--        CountryRegion,
--        PostalCode
--    FROM vAllAddresses
--    WHERE CustomerID = @CustomerID
--);
--GO
----проверка
--SELECT * FROM dbo.fn_GetAddressesForCust(0)
--UNION ALL
--SELECT * FROM dbo.fn_GetAddressesForCust(29502)
--UNION ALL
--SELECT * FROM dbo.fn_GetAddressesForCust(29503);

--1.4
--CREATE FUNCTION dbo.fn_GetMinMaxOrderPricesForProduct (@ProductID INT)
--RETURNS TABLE
--AS
--RETURN
--(
--    SELECT 
--        MIN(UnitPrice) AS MinUnitPrice,
--        MAX(UnitPrice) AS MaxUnitPrice
--    FROM SalesLT.SalesOrderDetail
--    WHERE ProductID = @ProductID
--);
--GO
----проверка
--SELECT * FROM dbo.fn_GetMinMaxOrderPricesForProduct(0);
--SELECT * FROM dbo.fn_GetMinMaxOrderPricesForProduct(711);

--1.5
--ALTER VIEW vProductAndDescription AS
--SELECT 
--    P.ProductID,
--    P.Name AS ProductName,
--    P.ListPrice,
--    PM.ProductModelID,
--    PM.Name AS ProductModelName,
--    PMPD.Culture,
--    PD.Description
--FROM SalesLT.Product P
--JOIN SalesLT.ProductModel PM ON P.ProductModelID = PM.ProductModelID
--JOIN SalesLT.ProductModelProductDescription PMPD ON PM.ProductModelID = PMPD.ProductModelID
--JOIN SalesLT.ProductDescription PD ON PMPD.ProductDescriptionID = PD.ProductDescriptionID;
--GO
--ALTER FUNCTION dbo.fn_GetAllDescriptionsForProduct (@ProductID INT)
--RETURNS TABLE
--AS
--RETURN
--(
--    SELECT 
--        P.ProductID,
--        P.ProductName AS Name,
--        MinMax.MinUnitPrice,
--        MinMax.MaxUnitPrice,
--        P.ListPrice,
--        P.ProductModelName AS ProductModel,
--        P.Culture,
--        P.Description
--    FROM vProductAndDescription P
--    CROSS APPLY dbo.fn_GetMinMaxOrderPricesForProduct(@ProductID) MinMax
--    WHERE P.ProductID = @ProductID
--);
--GO
--SELECT * FROM dbo.fn_GetAllDescriptionsForProduct(0);
--SELECT * FROM dbo.fn_GetAllDescriptionsForProduct(711);

--2.1
ALTER VIEW vAllAddresses 
WITH SCHEMABINDING AS
SELECT 
    C.CustomerID,
    A.AddressID,
    A.AddressLine1,
    A.AddressLine2,
    A.City,
    A.StateProvince,
    A.CountryRegion,
    A.PostalCode
FROM SalesLT.CustomerAddress CA
JOIN SalesLT.Customer C ON CA.CustomerID = C.CustomerID
JOIN SalesLT.Address A ON CA.AddressID = A.AddressID
GO
CREATE UNIQUE CLUSTERED INDEX UIX_vAllAddresses
ON dbo.vAllAddresses (CustomerID, AddressID, AddressLine1, AddressLine2, City, StateProvince, CountryRegion, PostalCode);
GO
SELECT * FROM dbo.vAllAddresses WITH (NOEXPAND);
GO



