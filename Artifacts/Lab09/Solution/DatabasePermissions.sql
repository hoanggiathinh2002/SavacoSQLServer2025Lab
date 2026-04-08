USE InternetSales;


GRANT SELECT ON SCHEMA::Sales TO sales_reader;
GRANT INSERT, UPDATE, EXECUTE ON SCHEMA::Sales TO sales_writer;
GRANT SELECT, INSERT, UPDATE, DELETE, EXECUTE ON Schema::Sales TO sales_admin;
GRANT SELECT ON SCHEMA::Customers TO customers_reader;
GRANT SELECT ON SCHEMA::Products TO products_reader;
GRANT EXECUTE ON Schema::Products TO InternetSales_Managers;
GRANT INSERT ON Sales.SalesOrderHeader TO web_application;
GRANT INSERT ON Sales.SalesOrderDetail TO web_application;
GRANT SELECT ON Products.vProductCatalog TO web_application;




