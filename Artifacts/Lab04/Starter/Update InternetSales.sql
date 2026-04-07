-- Modify the database (1)
UPDATE InternetSales.dbo.Product
SET ListPrice = ListPrice * 1.1
WHERE ProductSubcategoryID = 1;

-- Modify the database (2)
UPDATE InternetSales.dbo.Product
SET ListPrice = ListPrice * 1.1
WHERE ProductSubcategoryID = 2;


-- Modify the database (3)
UPDATE InternetSales.dbo.Product
SET ListPrice = ListPrice * 1.1
WHERE ProductSubcategoryID = 3;

