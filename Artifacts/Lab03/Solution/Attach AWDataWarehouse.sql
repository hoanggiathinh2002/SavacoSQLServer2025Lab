USE master
GO
CREATE DATABASE AWDataWarehouse ON 
( FILENAME = 'C:\Data\AWDataWarehouse.mdf' ),
( FILENAME = 'C:\Logs\AWDataWarehouse.ldf' ),
( FILENAME = 'C:\Data\AWDataWarehouse_archive.ndf' ),
( FILENAME = 'C:\Data\AWDataWarehouse_current.ndf' )
 FOR ATTACH
GO
