--spa_check_ofca_V1 '1111','Rabin','Test'
IF OBJECT_ID('spa_check_ofca_V1','P') IS NOT NULL
DROP PROCEDURE spa_check_ofca_V1
GO
-- spa_check_ofca NULL,'deepen kumar'      
CREATE PROC [dbo].[spa_check_ofca_V1]         
@sender_passport varchar(50)=NULL,    
@sender_name varchar(100)=NULL,    
@beneficiary_name varchar(100)=NULL    
AS    
    
--select * from ofca_list where 1=2    
--return    
    
CREATE TABLE #temp_result(    
 ent_num INT,    
 NAME VARCHAR(1000),    
 typeV VARCHAR(100),    
 address VARCHAR(2000),    
 city VARCHAR(200),    
 country VARCHAR(200),    
 remarks VARCHAR(3000),    
 source VARCHAR(200),    
 type_sort int ,  
 matched_type VARCHAR(50),  
 key_rank VARCHAR(50)  
)    
if CHARINDEX(' ',@sender_name)=0     
set @sender_name='-1111'    
    
if CHARINDEX(' ',@beneficiary_name)=0     
set @beneficiary_name=NULL    
       
INSERT #temp_result(ent_num,NAME,typeV,address,city,country,remarks,source,type_sort,matched_type,key_rank)  
EXEC spa_ofac_search_V1 @sender_name,@beneficiary_name    
   
if exists (select name from #temp_result where NAME=@sender_name or NAME=@beneficiary_name)    
begin    
SELECT NAME AS ofca_name,'SDN ID:'+ CAST(ent_num AS VARCHAR) AS ofca_passport,    
remarks AS ofca_desc, 'MATCHED'  Status    
FROM #temp_result where NAME=@sender_name or NAME=@beneficiary_name    
end    
else    
SELECT NAME AS ofca_name,'SDN ID:'+ CAST(ent_num AS VARCHAR) AS ofca_passport,    
remarks AS ofca_desc, NULL  Status  ,NULL matched_with  
FROM #temp_result where name <> '' 