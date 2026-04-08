
-- Get top 5 queries by average reads
SELECT TOP (5) qt.[text] SQLText, (qs.total_logical_reads/qs.execution_count) AS AvgReads, qs.execution_count, qs.last_execution_time, qs.last_elapsed_time, qs.max_elapsed_time, qs.total_elapsed_time
FROM sys.dm_exec_query_stats qs CROSS APPLY sys.dm_exec_sql_text(qs.sql_handle) qt
WHERE qs.execution_count > 1
ORDER BY (qs.total_logical_reads/qs.execution_count) DESC



-- View IO Stats
SELECT DB_NAME(fs.database_id) AS DatabaseName,
       mf.name AS FileName,
	   mf.type_desc,       
	   fs.*
FROM sys.dm_io_virtual_file_stats(NULL,NULL) AS fs
INNER JOIN sys.master_files AS mf
ON fs.database_id = mf.database_id
AND fs.file_id = mf.file_id
WHERE DB_NAME(fs.database_id) = 'InternetSales'
ORDER BY fs.file_id DESC;
GO


