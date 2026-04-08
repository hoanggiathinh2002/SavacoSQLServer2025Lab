USE InternetSales;
GO
CREATE TRIGGER Customers.Customer_Update ON Customers.Customer
FOR UPDATE
AS
BEGIN
	IF UPDATE(EmailAddress)
	BEGIN
		DECLARE @msg NVARCHAR(4000);
		SET @msg = (SELECT i.CustomerID, d.EmailAddress OldEmail, i.EmailAddress NewEmail
					FROM inserted i
					JOIN deleted d ON i.CustomerID = d.CustomerID
					FOR XML PATH('EmailChange'))
		EXEC sp_audit_write @user_defined_event_id= 12, @succeeded = 1, @user_defined_information = @msg;
	END;
END;
GO