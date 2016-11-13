CREATE FUNCTION [dbo].[FNAGMTDateValue](@as_of_date DATETIME,@agentid VARCHAR(50))  
RETURNS varchar(50) AS  
BEGIN 
declare @gmt_value INT,@GMT VARCHAR(50)
SELECT @gmt_value=ad.GMT_Value
 FROM agentDetail ad WHERE ad.agentCode=@agentid

SET @GMT=[dbo].FNAZero(CAST((@gmt_value/60) AS VARCHAR))+':'+  [dbo].FNAZero(CAST ((abs( @gmt_value - ((@gmt_value/60)* 60 )) ) AS VARCHAR))
return convert(varchar,@as_of_date,121) +' (' + @GMT +' GMT)'
END