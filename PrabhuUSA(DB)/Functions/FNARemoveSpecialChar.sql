DROP FUNCTION dbo.FNARemoveSpecialChar
GO
CREATE FUNCTION [dbo].[FNARemoveSpecialChar] (@str as Varchar(500))  
RETURNS varchar(500) AS  
BEGIN 
set @str=replace(@str,'  ',' ') --- Remove Tab
set @str=replace(@str,CHAR(9),' ') --- Remove Tab
set @str=REPLACE(REPLACE(@str, CHAR(13), ''), CHAR(10), '') --- Remove Enter

return (@str)
end

