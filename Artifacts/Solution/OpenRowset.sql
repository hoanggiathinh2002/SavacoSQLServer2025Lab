-- Disable non-clustered indexes and constraints
ALTER INDEX idx_JobCandidate_City ON HumanResources.dbo.JobCandidate
DISABLE;
GO

ALTER INDEX idx_JobCandidate_CountryRegion ON HumanResources.dbo.JobCandidate
DISABLE;
GO

ALTER TABLE HumanResources.dbo.JobCandidate
NOCHECK CONSTRAINT ALL;
GO

-- Load data
INSERT INTO HumanResources.dbo.JobCandidate
SELECT * FROM OPENROWSET (BULK 'C:\JobCandidates2.txt',
FORMATFILE = 'C:\JobCandidateFmt.xml') AS rows
WHERE EmailAddress IS NOT NULL;

-- Rebuild indexes and re-enable constraints
ALTER INDEX idx_JobCandidate_City ON HumanResources.dbo.JobCandidate
REBUILD;
GO

ALTER INDEX idx_JobCandidate_CountryRegion ON HumanResources.dbo.JobCandidate
REBUILD;
GO

ALTER TABLE HumanResources.dbo.JobCandidate
CHECK CONSTRAINT ALL;
GO
