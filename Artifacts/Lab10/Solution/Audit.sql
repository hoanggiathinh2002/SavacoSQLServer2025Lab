

-- Create an audit
USE master;

CREATE SERVER AUDIT AW_Audit
TO FILE 
(	FILEPATH = 'C:\SQLServerAdminLabs\Labfiles\Lab10\Starter\Audits\'
	,MAXSIZE = 0 MB
	,MAX_ROLLOVER_FILES = 2147483647
	,RESERVE_DISK_SPACE = OFF
)
WITH
(	QUEUE_DELAY = 1000
	,ON_FAILURE = FAIL_OPERATION
)
GO

ALTER SERVER AUDIT AW_Audit
WITH (STATE = ON);
GO

--Create a server audit specification
CREATE SERVER AUDIT SPECIFICATION AW_ServerAuditSpec
FOR SERVER AUDIT AW_Audit
ADD (FAILED_LOGIN_GROUP),
ADD (SUCCESSFUL_LOGIN_GROUP)
WITH (STATE = ON);
GO

-- Create a database audit specification
USE InternetSales;
CREATE DATABASE AUDIT SPECIFICATION AW_DatabaseAuditSpec
FOR SERVER AUDIT AW_Audit
ADD (USER_DEFINED_AUDIT_GROUP),
ADD (SELECT ON SCHEMA::Customers BY customers_reader),
ADD (SELECT ON SCHEMA::Customers BY sales_admin),
ADD (INSERT ON SCHEMA::Customers BY sales_admin),
ADD (UPDATE ON SCHEMA::Customers BY sales_admin),
ADD (DELETE ON SCHEMA::Customers BY sales_admin)
WITH (STATE = ON);
GO

--Create a trigger for a user-defined action
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

-- Grant permission on sp_audit_write 
USE master;
GRANT EXECUTE ON sys.sp_audit_write TO public;
GO

-- View audited events
SELECT event_time, action_id, succeeded, statement, user_defined_information, server_principal_name, database_name, schema_name, object_name
FROM sys.fn_get_audit_file ('C:\SQLServerAdminLabs\Labfiles\Lab10\Starter\Audits\*',default,default)
WHERE server_principal_name NOT IN ('ADVENTUREWORKS\u2uadmin', 'ADVENTUREWORKS\ServiceAcct');

