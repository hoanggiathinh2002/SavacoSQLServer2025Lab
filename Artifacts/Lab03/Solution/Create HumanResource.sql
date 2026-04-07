CREATE DATABASE HumanResources
 ON  PRIMARY 
(NAME = 'HumanResources', FILENAME = 'C:\Data\HumanResources.mdf', SIZE = 50MB, FILEGROWTH = 5MB)
 LOG ON 
(NAME = 'HumanResources_log', FILENAME = 'C:\Logs\HumanResources.ldf', SIZE = 5MB, FILEGROWTH = 1MB);
GO
