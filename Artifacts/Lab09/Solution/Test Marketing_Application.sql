-- change execution context to test login permissions
EXECUTE AS LOGIN = 'Marketing_Application'
GO
SELECT suser_name();

-- View effective permissions on Customers.Customer
USE InternetSales;
SELECT * FROM sys.fn_my_permissions('Customers.Customer', 'object');
GO

-- verify SELECT permission on Customers.Customer
USE InternetSales;
SELECT * FROM Customers.Customer;

-- verify no UPADTE permission on Customer.Customer
UPDATE Customers.Customer
SET EmailAddress = NULL
WHERE CustomerID = 1;

-- verify SELECT permission on Products.Product
SELECT * FROM Products.Product;

-- verify no SELECT permission on Sales.SalesOrderHeader
SELECT * FROM Sales.SalesOrderHeader;

-- revert the security context
REVERT
GO
SELECT suser_name();