

/*  
** Database    : PrabhuUSA
** Object      : FUNCTION FNAIsNULL
** Purpose     : Create function FNAIsNULL
** Author      : Puja Ghaju 
** Date        : 12 September 2013 
*/ 


IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[FNAIsNULL]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[FNAIsNULL]
GO

--select  [dbo].[FNAIsNULL](@var,ReceiverCountry)
CREATE FUNCTION [dbo].[FNAIsNULL] (@param VARCHAR(100),@fieldName VARCHAR(100))    
RETURNS varchar(500) 
AS    
BEGIN   
DECLARE @ret VARCHAR(500)
SET @ret=CASE WHEN @param IS NULL THEN '1' ELSE @fieldName END
return @ret
END  
  



GO

