USE [PrabhuUSA]
GO
/****** Object:  UserDefinedFunction [dbo].[FNAFristMiddleLastName]    Script Date: 01/25/2013 06:20:48 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[FNAFristMiddleLastName](@ret_type varchar(1),@str varchar(100))
RETURNs varchar(100) as
Begin
DECLARE @first_space int,@ret_value varchar(100),@last_name_len INT,@second_space INT,@result VARCHAR(100),@sql VARCHAR(100)

SET @str=ltrim(RTRIM(@str))
SET @first_space=CHARINDEX(' ',@str)
SET @sql = SUBSTRING(@str,@first_space+1,LEN(@str))
SET @second_space=CHARINDEX(' ',@sql)
SET @last_name_len=len(@str)-@first_space

IF @ret_type='f'
		SET @result=substring(@str,0,len(@str)-@last_name_len)
ELSE IF @ret_type='m'
		SET @result=substring(@sql,0,@second_space)
ELSE IF @ret_type='l'
		SET @result=substring(@sql,@second_space+1,len(@sql))
RETURN @result
end


