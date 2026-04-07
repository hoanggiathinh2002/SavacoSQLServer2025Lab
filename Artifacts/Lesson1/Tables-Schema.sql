/* MS-SQL Server 2025 Training: Lesson 1
   Focus: Structuring, Data Types, and Constraints
*/

-- 1. Create a clean workspace
SET NOCOUNT ON;
GO

-- 2. Create the Sales Schema (Best practice for organization)
IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'Sales')
BEGIN
    EXEC('CREATE SCHEMA Sales');
END
GO

-- 3. Create Tables with Constraints
-- Product Categories (Parent Table)
CREATE TABLE Sales.Categories (
    CategoryID INT IDENTITY(1,1) PRIMARY KEY,
    CategoryName NVARCHAR(50) NOT NULL,
    Description NVARCHAR(MAX),
    CreatedAt DATETIME2 DEFAULT SYSUTCDATETIME()
);

-- Products (Foreign Key relationship)
CREATE TABLE Sales.Products (
    ProductID INT IDENTITY(1,1) PRIMARY KEY,
    CategoryID INT NOT NULL,
    ProductName NVARCHAR(100) NOT NULL,
    UnitPrice DECIMAL(10, 2) CHECK (UnitPrice > 0),
    IsActive BIT DEFAULT 1,
    CONSTRAINT FK_Product_Category FOREIGN KEY (CategoryID) 
        REFERENCES Sales.Categories(CategoryID)
);

-- Customers
CREATE TABLE Sales.Customers (
    CustomerID INT IDENTITY(1,1) PRIMARY KEY,
    FirstName NVARCHAR(50) NOT NULL,
    LastName NVARCHAR(50) NOT NULL,
    Email NVARCHAR(100) UNIQUE, -- Unique Constraint
    SignupDate DATE DEFAULT CAST(GETDATE() AS DATE)
);

-- Orders (Header table)
CREATE TABLE Sales.Orders (
    OrderID INT IDENTITY(1,1) PRIMARY KEY,
    CustomerID INT NOT NULL,
    OrderDate DATETIME2 DEFAULT SYSUTCDATETIME(),
    TotalAmount DECIMAL(18, 2) DEFAULT 0,
    CONSTRAINT FK_Order_Customer FOREIGN KEY (CustomerID) 
        REFERENCES Sales.Customers(CustomerID)
);

-- Order Items (Detail table for many-to-many relationship)
CREATE TABLE Sales.OrderItems (
    OrderItemID INT IDENTITY(1,1) PRIMARY KEY,
    OrderID INT NOT NULL,
    ProductID INT NOT NULL,
    Quantity INT CHECK (Quantity > 0),
    LinePrice DECIMAL(10, 2),
    CONSTRAINT FK_Item_Order FOREIGN KEY (OrderID) REFERENCES Sales.Orders(OrderID),
    CONSTRAINT FK_Item_Product FOREIGN KEY (ProductID) REFERENCES Sales.Products(ProductID)
);
GO

-- 4. Seed Data (So students have something to query)
INSERT INTO Sales.Categories (CategoryName, Description) VALUES 
('Electronics', 'Gadgets and hardware'),
('Training', 'Software and educational licenses');

INSERT INTO Sales.Products (CategoryID, ProductName, UnitPrice) VALUES 
(1, 'SQL 2025 Workstation', 1200.00),
(2, 'Mastering T-SQL Course', 250.00);

INSERT INTO Sales.Customers (FirstName, LastName, Email) VALUES 
('John', 'Doe', 'john.doe@example.com'),
('Jane', 'Smith', 'jane.smith@training.local');
GO
