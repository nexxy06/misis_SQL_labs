-- 1.1
SELECT a.CountryRegion, a.StateProvince, SUM(soh.TotalDue) AS Revenue
FROM SalesLT.Address AS a
JOIN SalesLT.CustomerAddress AS ca ON a.AddressID = ca.AddressID
JOIN SalesLT.Customer AS c ON ca.CustomerID = c.CustomerID
JOIN SalesLT.SalesOrderHeader as soh ON c.CustomerID = soh.CustomerID
GROUP BY ROLLUP(a.CountryRegion, a.StateProvince)
ORDER BY a.CountryRegion, a.StateProvince;

-- 1.2
SELECT a.CountryRegion, a.StateProvince, SUM(soh.TotalDue) AS Revenue,
    CASE 
        WHEN GROUPING_ID(a.CountryRegion, a.StateProvince) = 0 THEN a.StateProvince + ' US subTotal'
        WHEN GROUPING_ID(a.CountryRegion, a.StateProvince) = 1 THEN a.CountryRegion + ' US subTotal'
        WHEN GROUPING_ID(a.CountryRegion, a.StateProvince) = 3 THEN 'Total'
    END AS Level
FROM SalesLT.Address AS a
JOIN SalesLT.CustomerAddress AS ca ON a.AddressID = ca.AddressID
JOIN SalesLT.Customer AS c ON ca.CustomerID = c.CustomerID
JOIN SalesLT.SalesOrderHeader as soh ON c.CustomerID = soh.CustomerID
GROUP BY ROLLUP(a.CountryRegion, a.StateProvince)
ORDER BY a.CountryRegion, a.StateProvince;

-- 1.3
SELECT 
    a.CountryRegion,
    a.StateProvince,
    a.City,
    SUM(soh.TotalDue) AS Revenue,
    GROUPING_ID (a.CountryRegion, a.StateProvince, a.City),
    CASE 
        WHEN GROUPING_ID(a.CountryRegion, a.StateProvince, a.City) = 0 THEN a.City + ' US subTotal'
        WHEN GROUPING_ID(a.CountryRegion, a.StateProvince, a.City) = 1 THEN a.StateProvince + ' US subTotal'
        WHEN GROUPING_ID(a.CountryRegion, a.StateProvince, a.City) = 3 THEN a.CountryRegion + ' US subTotal'
        WHEN GROUPING_ID(a.CountryRegion, a.StateProvince, a.City) = 7 THEN 'Total'
    END AS Level
FROM SalesLT.Address AS a
JOIN SalesLT.CustomerAddress AS ca ON a.AddressID = ca.AddressID
JOIN SalesLT.Customer AS c ON ca.CustomerID = c.CustomerID
JOIN SalesLT.SalesOrderHeader as soh ON c.CustomerID = soh.CustomerID
GROUP BY ROLLUP(a.CountryRegion, a.StateProvince, a.City)
ORDER BY a.CountryRegion, a.StateProvince, a.City;

-- 2.1
SELECT CompanyName, 
       ISNULL([Bikes], 0) AS Bikes, 
       ISNULL([Components], 0) AS Components, 
       ISNULL([Clothing], 0) AS Clothing, 
       ISNULL([Accessories], 0) AS Accessories
FROM (
    SELECT c.CompanyName, sod.LineTotal AS Revenue, gac.ParentProductCategoryName
    FROM SalesLT.Customer AS c
    JOIN SalesLT.SalesOrderHeader AS soh ON c.CustomerID = soh.CustomerID
    JOIN SalesLT.SalesOrderDetail AS sod ON soh.SalesOrderID = sod.SalesOrderID
    FULL OUTER JOIN SalesLT.Product AS p ON sod.ProductID = p.ProductID
    JOIN SalesLT.vGetAllCategories AS gac ON p.ProductCategoryID = gac.ProductCategoryID) AS SourceTable
PIVOT (
    SUM(Revenue)
    FOR ParentProductCategoryName IN ([Bikes], [Components], [Clothing], [Accessories])
) AS PivotTable
ORDER BY CompanyName;


