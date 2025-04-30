--1.1
SELECT p.ProductID, p.Name AS ProductName, v.Name AS ProductModel, v.Summary 
FROM SalesLT.Product AS p
JOIN SalesLT.vProductModelCatalogDescription AS v ON p.ProductModelID = v.ProductModelID 
ORDER BY p.ProductID

--1.2
DECLARE @ColorsT TABLE (Color NVARCHAR(30))

INSERT INTO @ColorsT (Color)
SELECT DISTINCT Color 
FROM SalesLT.Product 
WHERE Color IS NOT NULL 

SELECT p.ProductID, p.Name AS ProductName, p.Color 
FROM SalesLT.Product AS p 
WHERE p.Color IN (SELECT Color FROM @ColorsT)
ORDER BY p.Color

--1.3
CREATE TABLE #SizeT (Size NVARCHAR(30))
INSERT INTO #SizeT (Size)
SELECT DISTINCT Size 
FROM SalesLT.Product 
WHERE Size IS NOT NULL
SELECT p.ProductID, p.Name AS ProductName, p.Size 
FROM SalesLT.Product AS p 
WHERE p.Size IN (SELECT Size FROM #SizeT)
ORDER BY p.Size DESC
DROP TABLE #SizeT

--1.4
SELECT p.ProductID, p.Name AS ProductName, c.ParentProductCategoryName AS ParentCategory, c.ProductCategoryName AS Category 
FROM SalesLT.Product AS p
JOIN dbo.ufnGetAllCategories() AS c ON p.ProductCategoryID = c.ProductCategoryID
ORDER BY c.ParentProductCategoryName + ' ' + c.ProductCategoryName, p.Name

--2.1
SELECT c.CompanyName + ' (' + c.FirstName + ' ' + c.LastName + ')' AS CompanyContact, SUM(s.TotalDue) AS Revenue 
FROM (SELECT CustomerID, TotalDue FROM SalesLT.SalesOrderHeader) AS s
JOIN SalesLT.Customer AS c ON s.CustomerID = c.CustomerID
GROUP BY c.CompanyName, c.FirstName, c.LastName
ORDER BY CompanyContact

--2.2
WITH CustomerSales AS (SELECT c.CustomerID, c.CompanyName, c.FirstName, c.LastName, s.TotalDue 
FROM SalesLT.Customer AS c
JOIN SalesLT.SalesOrderHeader AS s ON c.CustomerID = s.CustomerID)

SELECT CompanyName + ' (' + FirstName + ' ' + LastName + ')' AS CompanyContact, SUM(TotalDue) AS Revenue 
FROM CustomerSales
GROUP BY CompanyName, FirstName, LastName
ORDER BY CompanyContact