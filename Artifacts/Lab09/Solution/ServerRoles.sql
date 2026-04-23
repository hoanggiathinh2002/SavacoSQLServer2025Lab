USE master;
GO

-- Create a user-defined server role
CREATE SERVER ROLE application_admin;
GO

-- Add a login to the role
ALTER SERVER ROLE application_admin
ADD MEMBER [SQLServerSSMS\Database_Managers];
GO

-- Grant permission to manage application logins
GRANT ALTER ANY LOGIN TO application_admin;
GRANT VIEW ANY DATABASE TO application_admin;