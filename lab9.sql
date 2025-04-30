--1.1
DELETE FROM SalesLT.Product WHERE Name = 'LED Lights'
DECLARE @Sub TABLE (ProductID INT)
INSERT INTO SalesLT.Product(Name, ProductNumber, StandardCost, ListPrice, ProductCategoryID, SellStartDate)
OUTPUT INSERTED.ProductID INTO @Sub
VALUES ('LED Lights', 'LT-L123', 2.56, 12.99, 37, GETDATE())
SELECT * FROM @Sub
SELECT * FROM SalesLT.Product WHERE ProductID = (SELECT * FROM @Sub)

 --1.2
DELETE FROM SalesLT.ProductCategory WHERE Name = 'Bells and Horns'
DECLARE @InsertP TABLE (ProductCategoryID INT);
INSERT INTO SalesLT.ProductCategory (Name)
OUTPUT INSERTED.ProductCategoryID INTO @InsertP
VALUES ('Bells and Horns');
DELETE FROM SalesLT.Product WHERE ProductCategoryID = (SELECT ProductCategoryID FROM @InsertP)
SELECT ProductCategoryID 
FROM @InsertP;
INSERT INTO SalesLT.Product(Name, ProductCategoryID, ProductNumber, StandardCost, ListPrice, SellStartDate) VALUES 
('Bell', (SELECT ProductCategoryID FROM @InsertP), '1.22', 1000, 1000, GETDATE()),
('Horn', (SELECT ProductCategoryID FROM @InsertP), '1.43', 1001, 1001, GETDATE())

SELECT * FROM SalesLT.Product 
WHERE ProductCategoryID = (SELECT ProductCategoryID FROM @InsertP)

--2.1
UPDATE SalesLT.Product SET ListPrice = ListPrice * 1.1

--2.2
SELECT Name, DiscontinuedDate 
FROM SalesLT.Product WHERE ProductCategoryID = 37
UPDATE SalesLT.Product SET DiscontinuedDate = GETDATE() 
WHERE ProductCategoryID = 37 AND ProductNumber != 'LT-L123'
SELECT Name, DiscontinuedDate 
FROM SalesLT.Product WHERE ProductCategoryID = 37

--3.1
DELETE FROM SalesLT.Product WHERE ProductCategoryID = (SELECT ProductCategoryID FROM SalesLT.ProductCategory WHERE Name = 'Bells and Horns')
DELETE FROM SalesLT.ProductCategory WHERE Name = 'Bells and Horns'