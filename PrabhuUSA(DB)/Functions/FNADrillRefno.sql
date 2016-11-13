



/*  
** Database    : PrabhuUSA
** Object      : FUNCTION FNADrillRefno
** Purpose     : Create function FNADrillRefno
** Author      : Puja Ghaju 
** Date        : 12 September 2013 
*/ 



IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[FNADrillRefno]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[FNADrillRefno]
GO



--print dbo.FNADrillRefno('r','1233333') 
CREATE FUNCTION [dbo].[FNADrillRefno](@refOrtxn char(1),@label varchar(50))
returns VARCHAR(1000)
AS
BEGIN
DECLARE @ret_val VARCHAR(1000)
IF @refOrtxn='t'
	SET @ret_val='<a href=''../headoffice/tranDetail.asp?tranNo='+@label +'''>'+ @label +'</a>'
ELSE
	SET @ret_val='<a href=''../headoffice/tranDetail.asp?refno='+@label +'''>'+ @label +'</a>'
	 
RETURN @ret_val
END 
GO


