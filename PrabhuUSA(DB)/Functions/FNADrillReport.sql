

/*  
** Database    : PrabhuUSA
** Object      : FUNCTION FNADrillReport
** Purpose     : Create function FNADrillReport
** Author      : Puja Ghaju 
** Date        : 12 September 2013 
*/ 


IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[FNADrillReport]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[FNADrillReport]
GO


--PRINT dbo.FNADrillReport('asss',12,'assss')
CREATE FUNCTION [dbo].[FNADrillReport](@label varchar(50),@report_id VARCHAR(50),@parameter VARCHAR(500))
returns VARCHAR(1000)
AS
BEGIN
DECLARE @ret_val VARCHAR(1000)
SET @parameter=REPLACE(@parameter,'##','@')
SET @parameter=REPLACE(@parameter,';','-!-')
SET @ret_val='<span style=cursor:pointer onClick="openReportWriterWindow('+@report_id+','''+@parameter+''')"><font color=#0000ff><u>'+ @label +'</u></font></span>' 
RETURN @ret_val
END 

GO


