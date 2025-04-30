
--SELECT *
--FROM SalesLT.Address
--SELECT * 
--FROM SalesLT.CustomerAddress
--SELECT * 
--FROM SalesLT.Customer
-- 1.1
SELECT C.CompanyName, A.AddressLine1, A.City, CA.AddressType
FROM SalesLT.Customer AS C
inner JOIN SalesLT.CustomerAddress AS CA ON C.CustomerID = CA.CustomerID
inner JOIN SalesLT.Address AS A ON CA.AddressID = A.AddressID
WHERE CA.AddressType = 'Main Office' OR CA.AddressType = 'Billing';

--1.2
SELECT C.CompanyName, A.AddressLine1, A.City, CA.AddressType
FROM SalesLT.Customer AS C
inner JOIN SalesLT.CustomerAddress AS CA ON C.CustomerID = CA.CustomerID
inner JOIN SalesLT.Address AS A ON CA.AddressID = A.AddressID
WHERE CA.AddressType = 'Shipping';

----1.3
SELECT C.CompanyName, A.AddressLine1, A.City, CA.AddressType
FROM SalesLT.Customer AS C
inner JOIN SalesLT.CustomerAddress AS CA ON C.CustomerID = CA.CustomerID
inner JOIN SalesLT.Address AS A ON CA.AddressID = A.AddressID
WHERE CA.AddressType = 'Main Office'
UNION
SELECT C.CompanyName, A.AddressLine1, A.City, CA.AddressType
FROM SalesLT.Customer AS C
inner JOIN SalesLT.CustomerAddress as CA ON C.CustomerID = CA.CustomerID
inner JOIN SalesLT.Address as A ON CA.AddressID = A.AddressID
WHERE CA.AddressType = 'Shipping'
ORDER BY CompanyName, AddressType;

----2.1
SELECT C.CompanyName
FROM SalesLT.Customer AS C
INNER JOIN SalesLT.CustomerAddress AS CA1 ON C.CustomerID = CA1.CustomerID
WHERE CA1.AddressType = 'Main Office'
EXCEPT
SELECT C.CompanyName
FROM SalesLT.Customer AS C
INNER JOIN SalesLT.CustomerAddress AS CA2 ON C.CustomerID = CA2.CustomerID
WHERE CA2.AddressType = 'Shipping';

----2.2
SELECT C.CompanyName
FROM SalesLT.Customer AS C
INNER JOIN SalesLT.CustomerAddress AS CA1 ON C.CustomerID = CA1.CustomerID
WHERE CA1.AddressType = 'Main Office'
INTERSECT
SELECT C.CompanyName
FROM SalesLT.Customer AS C
INNER JOIN SalesLT.CustomerAddress AS CA2 ON C.CustomerID = CA2.CustomerID
WHERE CA2.AddressType = 'Shipping';
