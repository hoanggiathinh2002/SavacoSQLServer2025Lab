
-- Stop the trace
DECLARE @TraceID int = 2; --Replace with correct TraceID if necessary
EXEC sp_trace_setstatus @TraceID, 0;
EXEC sp_trace_setstatus @TraceID, 2;
GO

-- View the trace
SELECT TextData, StartTime, Duration
FROM fn_trace_gettable('C:\SQLServerAdminLabs\Labfiles\Lab08\Starter\InternetSales.trc', default)
WHERE EventClass = 41;