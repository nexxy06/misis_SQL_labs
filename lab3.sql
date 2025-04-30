/*
-- 1.1
SELECT SalesLT.Customer.CompanyName, SalesOrderID, TotalDue
FROM SalesLT.SalesOrderHeader
INNER JOIN SalesLT.Customer ON SalesLT.SalesOrderHeader.CustomerID = SalesLT.Customer.CustomerID

--1.2
SELECT c.CompanyName, s.SalesOrderID, s.TotalDue, a.AddressLine1, a.AddressLine2, a.City, a.StateProvince, a.PostalCode, a.CountryRegion
FROM SalesLT.SalesOrderHeader AS s
INNER JOIN SalesLT.Customer AS c ON s.CustomerID = c.CustomerID
INNER JOIN SalesLT.CustomerAddress AS cid ON s.CustomerID = cid.CustomerID
INNER JOIN SalesLT.Address AS a ON cid.AddressID = a.AddressID

--2.1
SELECT c.CompanyName, c.FirstName, c.LastName, s.SalesOrderID, s.TotalDue
FROM SalesLT.SalesOrderHeader AS s
FULL OUTER JOIN SalesLT.Customer AS c ON c.CustomerID = s.CustomerID
ORDER BY CASE WHEN s.SalesOrderID IS NULL THEN 1 ELSE 0 END, s.SalesOrderID

--2.2
SELECT c.CustomerID, c.CompanyName, COALESCE(c.FirstName, c.LastName) AS Name, c.Phone -- , ca.AddressID
FROM SalesLT.Customer AS c
FULL OUTER JOIN SalesLT.CustomerAddress AS ca ON c.CustomerID = ca.CustomerID
WHERE ca.AddressID IS NULL
*/
--2.3
SELECT c.CustomerID
FROM SalesLT.Customer AS c
FULL OUTER JOIN SalesLT.SalesOrderHeader AS s ON c.CustomerID = s.CustomerID
WHERE s.SalesOrderID IS NULL

SELECT p.ProductID
FROM SalesLT.Product AS p
FULL OUTER JOIN SalesLT.SalesOrderDetail AS sd ON sd.ProductID = p.ProductID 
FULL OUTER JOIN SalesLT.SalesOrderHeader AS s ON sd.SalesOrderID = s.SalesOrderID
WHERE CustomerID IS NULL

