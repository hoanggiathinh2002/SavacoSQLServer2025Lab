SELECT YEAR(o.OrderDate) AS [Year], c.Name AS [Category], s.Name AS [Subcategory], p.Name As [Product], SUM(od.OrderQty) As UnitsSold
FROM dbo.SalesOrderHeader o
JOIN dbo.SalesOrderDetail od ON od.SalesOrderID = o.SalesOrderID
JOIN dbo.Product p ON od.ProductID = p.ProductID
JOIN dbo.ProductSubcategory s ON p.ProductSubcategoryID = s.ProductSubcategoryID
JOIN dbo.ProductCategory c ON s.ProductCategoryID = c.ProductCategoryID
GROUP BY YEAR(o.OrderDate) , c.Name, s.Name, p.Name