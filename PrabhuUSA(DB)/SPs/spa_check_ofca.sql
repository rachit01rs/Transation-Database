DROP proc [dbo].[spa_check_ofca]  
go
--spa_check_ofca '2342432','Brilliant Intervest ' ,'SAMAD'    
  
-- spa_check_ofca NULL,'Osama'  
CREATE proc [dbo].[spa_check_ofca]  
@sender_passport varchar(50)=NULL,  
@sender_name varchar(100)=NULL,  
@beneficiary_name varchar(100)=NULL  
AS  
  
  
set @sender_passport=rtrim(ltrim(@sender_passport))    
set @sender_name=rtrim(ltrim(@sender_name))    
set @beneficiary_name=rtrim(ltrim(@beneficiary_name))   
  
--Removal of extra space on sender name and beneficiary name    
declare @count int, @i int    
set @i=1    
set @count=0    
SELECT @count = LEN(@sender_name) - LEN(REPLACE(@sender_name,' ',''))    
--print @count    
while @i<@count    
begin    
set @sender_name=replace(@sender_name,'  ',' ')    
--print @sender_name    
set @i=@i*2    
end    
--print 'Final sendername:' +@sender_name    
set @i=1    
set @count=0    
SELECT @count = LEN(@beneficiary_name) - LEN(REPLACE(@beneficiary_name,' ',''))    
--print @count    
while @i<@count    
begin    
set @beneficiary_name=replace(@beneficiary_name,'  ',' ')    
--print @beneficiary_name    
set @i=@i*2    
end    
--    
--print 'Final ben name:' + @beneficiary_name    
--End of Removal of extra space on sender name and beneficiary name    
  
CREATE TABLE #temp_result(  
 ent_num INT,  
 NAME VARCHAR(1000),  
 typeV VARCHAR(100),  
 address VARCHAR(2000),  
 city VARCHAR(200),  
 country VARCHAR(200),  
 remarks VARCHAR(3000),  
 source VARCHAR(200),  
 type_sort int,    
 matched_with varchar(50)   
)  
if CHARINDEX(' ',@sender_name)=0   
set @sender_name='-1111'  
  
if CHARINDEX(' ',@beneficiary_name)=0   
set @beneficiary_name=NULL  
  
INSERT #temp_result(ent_num,NAME,typeV,address,city,country,remarks,source,type_sort,matched_with)  
EXEC spa_ofac_search @sender_name,@beneficiary_name  
  
--SELECT NAME AS ofca_name,'SDN ID:'+ CAST(ent_num AS VARCHAR) AS ofca_passport,  
--remarks AS ofca_desc  
-- FROM #temp_result  
  
if exists (select name from #temp_result where replace(NAME,'  ',' ')=REPLACE(@sender_name,'  ',' ')  
 or replace(NAME,'  ',' ')=REPLACE(@beneficiary_name,'  ',' '))    
begin    
SELECT NAME AS ofca_name,'SDN ID:'+ CAST(ent_num AS VARCHAR) AS ofca_passport,    
remarks AS ofca_desc, 'MATCHED'  Status,matched_with matched_with     
FROM #temp_result where replace(NAME,'  ',' ')=REPLACE(@sender_name,'  ',' ')  
 or replace(NAME,'  ',' ')=REPLACE(@beneficiary_name,'  ',' ')  
end    
else    
SELECT NAME AS ofca_name,'SDN ID:'+ CAST(ent_num AS VARCHAR) AS ofca_passport,    
remarks AS ofca_desc, NULL  Status,matched_with matched_with    
FROM #temp_result    
  
--select top 10 * from ofca_list   
--where ofca_name in (@sender_name,@beneficiary_name)   
--or ofca_passport in (@sender_passport)  