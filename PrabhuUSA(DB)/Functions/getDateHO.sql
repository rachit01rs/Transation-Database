
/****** Object:  UserDefinedFunction [dbo].[getDateHO]    Script Date: 03/12/2014 01:09:09 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[getDateHO]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[getDateHO]
GO


/****** Object:  UserDefinedFunction [dbo].[getDateHO]    Script Date: 03/12/2014 01:09:09 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

--getDateHO(getutcdate())
CREATE FUNCTION [dbo].[getDateHO](@utc_date datetime)  
RETURNS datetime AS  
BEGIN 
declare @x as datetime,@y varchar(50), @diff int
select @diff=GMT_value from tbl_setup
set @x=dbo.FNADateUTC(@diff,@utc_date)
return @x
END



GO


