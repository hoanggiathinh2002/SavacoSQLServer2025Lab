-- disable indexes 
ALTER INDEX ALL ON InternetSales.dbo.CurrencyRate
DISABLE;
GO


-- Insert data
BULK INSERT InternetSales.dbo.CurrencyRate
FROM 'C:\CurrencyRates.csv'
WITH
    (
	     FIELDTERMINATOR =',',
		 ROWTERMINATOR ='\n'
	);

--Rebuild indexes
ALTER INDEX ALL ON InternetSales.dbo.CurrencyRate
REBUILD;
GO
