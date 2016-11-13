--spa_ofac_search 'said','lama'  
IF OBJECT_ID('spa_ofac_search_V1','P') IS NOT NULL
DROP PROCEDURE spa_ofac_search_V1
GO

CREATE PROC [dbo].[spa_ofac_search_V1]       
@name VARCHAR(200),    
@remarks VARCHAR(200)=NULL    
AS    
CREATE TABLE #temp_name(    
 ent_num INT,    
 key_rank int    
)    
CREATE TABLE #temp_output(    
 ent_num INT,    
 NAME VARCHAR(1000),    
 typeV VARCHAR(100),    
 address VARCHAR(2000),    
 city VARCHAR(200),    
 country VARCHAR(200),    
 remarks VARCHAR(3000),    
 source VARCHAR(200),    
 type_sort int,    
 matched_type varchar(50),    
 key_rank int    
)    
    
CREATE TABLE #temp_individual(    
 ent_num INT,    
 NAME VARCHAR(1000),    
 typeV VARCHAR(100),    
 address VARCHAR(2000),    
 city VARCHAR(200),    
 country VARCHAR(200),    
 remarks VARCHAR(3000),    
 source VARCHAR(200),    
 type_sort int,    
 matched_type varchar(50),    
 key_rank int    
)    
    
INSERT #temp_name(ent_num,key_rank)    
SELECT DISTINCT ent_num,KEY_TBL.[rank]    
FROM ofac_combined    
INNER JOIN FREETEXTTABLE(ofac_combined, [name], @name) AS KEY_TBL    
ON ofac_combined.sno = KEY_TBL.[KEY]     
WHERE KEY_TBL.[rank] >100     
UNION     
SELECT DISTINCT ent_num,KEY_TBL.[rank]    
FROM ofac_combined    
INNER JOIN FREETEXTTABLE(ofac_combined, [remarks], @name) AS KEY_TBL    
ON ofac_combined.sno = KEY_TBL.[KEY]     
WHERE KEY_TBL.[rank] >150    
    
 INSERT #temp_output(ent_num,NAME,typeV,address,city,country,remarks,source,type_sort,matched_type,key_rank)    
 SELECT o.ent_num,o.NAME,o.typeV,o.address,o.city,o.country,o.remarks,o.source,o.type_sort,'Sender Name',key_rank     
 FROM dbo.ofac_combined o JOIN #temp_name t    
 ON o.ent_num=t.ent_num    
 WHERE o.typeV='individual'    
    
 IF NOT EXISTS (SELECT * FROM #temp_output)    
 BEGIN    
  INSERT #temp_output(ent_num,NAME,typeV,address,city,country,remarks,source,type_sort,matched_type,key_rank)    
  SELECT DISTINCT o.ent_num,o.NAME,o.typeV,o.address,o.city,o.country,o.remarks,o.source,o.type_sort,'Sender Name',key_rank    
  FROM dbo.ofac_combined o JOIN #temp_name t    
  ON o.ent_num=t.ent_num    
 END    
    
IF @remarks IS NOT NULL    
BEGIN    
 DELETE #temp_name    
     
 INSERT #temp_name(ent_num,key_rank)    
 SELECT DISTINCT ent_num, KEY_TBL.[rank]     
 FROM ofac_combined    
 INNER JOIN FREETEXTTABLE(ofac_combined, [name], @remarks) AS KEY_TBL    
 ON ofac_combined.sno = KEY_TBL.[KEY]     
 WHERE KEY_TBL.[rank] >100   
 UNION     
 SELECT DISTINCT ent_num, KEY_TBL.[rank]     
 FROM ofac_combined    
 INNER JOIN FREETEXTTABLE(ofac_combined, [remarks], @remarks) AS KEY_TBL    
 ON ofac_combined.sno = KEY_TBL.[KEY]     
 WHERE KEY_TBL.[rank] >150    
    
  INSERT #temp_individual(ent_num,NAME,typeV,address,city,country,remarks,source,type_sort,matched_type,key_rank)    
  SELECT o.ent_num,o.NAME,o.typeV,o.address,o.city,o.country,o.remarks,o.source,o.type_sort,'Beneficiary Name',key_rank    
  FROM dbo.ofac_combined o JOIN #temp_name t    
  ON o.ent_num=t.ent_num    
  WHERE o.typeV='individual'    
    
  IF NOT EXISTS (SELECT * FROM #temp_individual)    
  BEGIN    
   INSERT #temp_output(ent_num,NAME,typeV,address,city,country,remarks,source,type_sort,matched_type,key_rank)    
   SELECT DISTINCT o.ent_num,o.NAME,o.typeV,o.address,o.city,o.country,o.remarks,o.source,o.type_sort,'Beneficiary Name' ,key_rank    
   FROM dbo.ofac_combined o JOIN #temp_name t    
   ON o.ent_num=t.ent_num    
  END    
  ELSE    
  BEGIN    
   INSERT #temp_output(ent_num,NAME,typeV,address,city,country,remarks,source,type_sort,matched_type,key_rank)    
   SELECT ent_num,NAME,typeV,address,city,country,remarks,source,type_sort,matched_type,key_rank    
   FROM #temp_individual     
  END    
    
end    
     
    
 SELECT * FROM #temp_output ORDER BY key_rank,ent_num,type_sort    
    