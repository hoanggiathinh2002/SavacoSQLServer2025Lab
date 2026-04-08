USE master
GO


IF EXISTS(SELECT * FROM sys.sysdatabases WHERE name = 'HumanResources')
BEGIN
	DROP DATABASE HumanResources
END
GO

RESTORE DATABASE HumanResources FROM  DISK = N'$(SUBDIR)SetupFiles\HumanResources.bak' 
WITH  
	MOVE N'HumanResources' TO N'C:\Data\HumanResources.mdf', 
	MOVE N'HumanResources_log' TO N'C:\Logs\HumanResources.ldf',  
	REPLACE;
GO

ALTER AUTHORIZATION ON DATABASE::HumanResources TO [AdventureWorks\u2uadmin];
GO

EXEC  msdb.dbo.sp_delete_database_backuphistory @database_name = 'HumanResources';
GO

IF EXISTS(SELECT * FROM sys.sysdatabases WHERE name = 'InternetSales')
BEGIN
	DROP DATABASE InternetSales
END
GO

RESTORE DATABASE InternetSales FROM  DISK = N'$(SUBDIR)SetupFiles\InternetSales.bak'
WITH 
	MOVE N'InternetSales' TO N'C:\Data\InternetSales.mdf',  
	MOVE N'InternetSales_data1' TO N'C:\Data\InternetSales_data1.ndf',  
	MOVE N'InternetSales_data2' TO N'C:\Data\InternetSales_data2.ndf',  
	MOVE N'InternetSales_log' TO N'C:\Logs\InternetSales.ldf',  
	REPLACE;
GO

ALTER AUTHORIZATION ON DATABASE::InternetSales TO [AdventureWorks\u2uadmin];
GO

EXEC  msdb.dbo.sp_delete_database_backuphistory @database_name = 'InternetSales';
GO

IF EXISTS(SELECT * FROM sys.sysdatabases WHERE name = 'AWDataWarehouse')
BEGIN
	DROP DATABASE AWDataWarehouse
END
GO

RESTORE DATABASE AWDataWarehouse FROM  DISK = N'$(SUBDIR)SetupFiles\AWDataWarehouse.bak'
WITH 
	MOVE N'AWDataWarehouse' TO N'C:\Data\AWDataWarehouse.mdf',  
	MOVE N'AWDataWarehouse_archive' TO N'C:\Data\AWDataWarehouse_archive.ndf',  
	MOVE N'AWDataWarehouse_current' TO N'C:\Data\AWDataWarehouse_current.ndf',  
	MOVE N'AWDataWarehouse_log' TO N'C:\Logs\AWDataWarehouse.ldf',  
	REPLACE;
GO

ALTER AUTHORIZATION ON DATABASE::AWDataWarehouse TO [AdventureWorks\u2uadmin];
GO

EXEC  msdb.dbo.sp_delete_database_backuphistory @database_name = 'AWDataWarehouse';
GO


-- Set recovery model for HumanResources
ALTER DATABASE HumanResources SET RECOVERY SIMPLE WITH NO_WAIT;
GO


GO

-- Set the recovery model for InternetSales
ALTER DATABASE InternetSales SET RECOVERY FULL WITH NO_WAIT;
GO


-- Set the recovery model for AWDataWarehouse
ALTER DATABASE AWDataWarehouse SET RECOVERY SIMPLE WITH NO_WAIT;
GO


CREATE TABLE  HumanResources.dbo.JobCandidate
(JobCandidateRef INTEGER PRIMARY KEY,
 FirstName nvarchar(30),
 LastName nvarchar(30),
 Skills nvarchar(max),
 City nvarchar(25),
 StateProvince nvarchar(50),
 CountryRegion nvarchar(50),
 EmailAddress nvarchar(100)
 );
 GO

INSERT [HumanResources].[dbo].[JobCandidate] ([JobCandidateRef], [FirstName], [LastName], [Skills], [City], [StateProvince], [CountryRegion], [EmailAddress]) VALUES (1, N'Max', N'Benson', N'3 years recent experience as a go-cart production line manager. Responsibilities included planning the production line budget, ordering parts, and overseeing all quality assurance procedures.
Prior to production management, worked 5 years on go-cart production lines (3 years while in college and for 2 years after), with increasing responsibilities over time. Responsibilities started with basic assembly and grew to quality assurance lead for brake systems.
Led an ISO 9000 certification process. Passed state exams for chemical and industrial safety. Recently recertified in basic first aid.
Avid cycler, placing in the top five in two Orlando-area races.
    ', N'Orlando', N'FL ', N'US ', N'Max@Wingtiptoys.com')
GO
INSERT [HumanResources].[dbo].[JobCandidate] ([JobCandidateRef], [FirstName], [LastName], [Skills], [City], [StateProvince], [CountryRegion], [EmailAddress]) VALUES (2, N'Krishna', N'Sunkammurali', N' Expert in C# and Visual Basic 6.0. 7 years experience in object-oriented programming. Familiar with ASP.Net and the .NET Framework. Design experience with both Windows and Web user interfaces.
5 years experience in programming against MS SQL Server 7.0 and 2000. Familiar with ODBC, OLE DB, ADO, and ADO.NET. Conversant with T-SQL, skilled at writing stored procedures.
Excellent organizational, interpersonal, written and verbal communication skills.
    ', N'Issaquah', N'WA ', N'US ', N'Krishna@TreyResearch.net')
GO
INSERT [HumanResources].[dbo].[JobCandidate] ([JobCandidateRef], [FirstName], [LastName], [Skills], [City], [StateProvince], [CountryRegion], [EmailAddress]) VALUES (3, N'Lionel', N'Penuchot', N'Mécanicien expérimenté et polyvalent qui peut utiliser diverses machines ou superviser le travail d''autres mécaniciens. Je suis spécialisé dans les diagnostics et l''inspection de précision. Je sais lire des plans et peux faire appel à mes compétences en matière de communication pour guider le travail d''autres mécaniciens de production dont je suis amené à inspecter le travail. 
Mon diplôme en ingénierie mécanique me confère des connaissances théoriques et mathématiques particulièrement utiles dans mon travail.
    ', N'Bandol', N'Var', N'France', N'')
GO
INSERT [HumanResources].[dbo].[JobCandidate] ([JobCandidateRef], [FirstName], [LastName], [Skills], [City], [StateProvince], [CountryRegion], [EmailAddress]) VALUES (4, N'Peng', N'Wu', N'熟悉所有销售环节，专业知识丰富。13 年来，为提高公司收入成绩卓著。在计划和预测销售、发展客户以及运用多种销售技巧方面具有一定经验。
具有五年的销售管理经验，包括客户线索生成、销售人员管理以及销售区域管理。在管理由现场销售代表、产品演示人员和供应商组成的分布式销售网络过程中，能够利用各种管理风格和专业技能来进行有效管理和沟通。
极佳的沟通和表达能力
    ', N'Federal Way', N'WA ', N'US ', N'')
GO
INSERT [HumanResources].[dbo].[JobCandidate] ([JobCandidateRef], [FirstName], [LastName], [Skills], [City], [StateProvince], [CountryRegion], [EmailAddress]) VALUES (5, N'สามารถ', N'เบญจศร', N'ประสบการณ์ล่าสุดกว่า 3 ปีในตำแหน่งผู้จัดการสายการผลิตรถโกคาร์ท  ความรับผิดชอบ ประกอบด้วยการวางแผนงบประมาณของสายการผลิต การสั่งซื้ออะไหล่ และควบคุมกระบวนการประกันคุณภาพ 
ก่อนรับตำแหน่งบริหารการผลิต ได้ทำงานในสายการผลิตรถโกคาร์ทกว่า 5 ปี (3 ปีขณะศึกษา และ 2 ปี หลังจบการศึกษา) โดยมีความรับผิดชอบเพิ่มขึ้นตามลำดับ  เริ่มต้นจากการรับผิดชอบงานประกอบขั้นพื้นฐาน และต่อมาเป็นผู้นำกระบวนการประกันคุณภาพสำหรับระบบเบรค 
เป็นผู้นำการรับรองตามมาตรฐาน ISO 9000 
ผ่านการสอบประเมินผลด้านความปลอดภัยทางเคมีและอุตสาหกรรม จากกระทรวงอุตสาหกรรม  ได้รับใบประกาศนียบัตรด้านการปฐมพยาบาลจากกระทรวงแรงงานและสวัสดิการสังคม 
เป็นนักปั่นจักรยาน อยู่ในห้าอันดับแรกของการแข่งในกรุงเทพมหานครสองครั้ง  
    ', N'ดุสิต ', N'กรุงเทพมหานคร', N'ประเทศไทย ', N'')
GO
INSERT [HumanResources].[dbo].[JobCandidate] ([JobCandidateRef], [FirstName], [LastName], [Skills], [City], [StateProvince], [CountryRegion], [EmailAddress]) VALUES (6, N'ชาย ', N'บางสุขศรี ', N'', N'ตลิ่งชัน ', N'กรุงเทพมหานคร', N'ประเทศไทย ', N'')
GO

ALTER TABLE [HumanResources].[dbo].[JobCandidate]
ADD CONSTRAINT CK_JobCandidate_FirstName CHECK (LEN(FirstName) > 0);
GO
ALTER TABLE [HumanResources].[dbo].[JobCandidate]
ADD CONSTRAINT CK_JobCandidate_LastName CHECK (LEN(LastName) > 0);
GO

CREATE NONCLUSTERED INDEX idx_JobCandidate_City
ON [HumanResources].[dbo].[JobCandidate](City);
GO

CREATE NONCLUSTERED INDEX idx_JobCandidate_CountryRegion
ON [HumanResources].[dbo].[JobCandidate](CountryRegion);
GO

CREATE TABLE [InternetSales].[dbo].[CurrencyRate](
	[CurrencyRateID] [int] IDENTITY(1,1) NOT NULL,
	[CurrencyRateDate] [datetime] NOT NULL,
	[FromCurrencyCode] [nchar](3) NOT NULL,
	[ToCurrencyCode] [nchar](3) NOT NULL,
	[AverageRate] [money] NOT NULL,
	[EndOfDayRate] [money] NOT NULL);
GO


ALTER TABLE InternetSales.dbo.CurrencyRate ADD CONSTRAINT
	CK_CurrencyRate_EndOfDayRate CHECK (EndOfDayRate > 0);
GO
ALTER TABLE InternetSales.dbo.CurrencyRate ADD CONSTRAINT
	CK_CurrencyRate_AverageRate CHECK (AverageRate > 0);
GO

CREATE NONCLUSTERED INDEX idx_CurrencyRate_FromCurrencyCode
ON InternetSales.dbo.CurrencyRate(FromCurrencyCode);
GO

CREATE NONCLUSTERED INDEX idx_CurrencyRate_ToCurrencyCode
ON InternetSales.dbo.CurrencyRate(ToCurrencyCode);
GO