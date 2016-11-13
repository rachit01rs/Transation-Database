--USE prabhuusa
--select [dbo].[FNAZero](14)
CREATE FUNCTION [dbo].[FNAZero](@x int)
RETURNS varchar(50) AS  
BEGIN 
	DECLARE @ret VARCHAR(50)
	IF  @x>0 and @x<10
		SET @ret='0'+ CAST(@x AS VARCHAR)
	ELSE IF @x>-10 and @x<0
		SET @ret='-0'+ CAST(abs(@x) AS VARCHAR)
	ELSE
		SET @ret=CAST(@x AS VARCHAR)
		
	RETURN @ret
end  

GO