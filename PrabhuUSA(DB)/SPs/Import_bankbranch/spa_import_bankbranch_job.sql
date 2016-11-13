IF OBJECT_ID('[spa_import_bankbranch_job]', 'p') IS NOT NULL 
    DROP PROC [dbo].[spa_import_bankbranch_job]  
GO
      
CREATE PROC  [dbo].[spa_import_bankbranch_job]              
@PathFileName VARCHAR(500),                                      
@tablename  VARCHAR(100),                                      
@job_name  VARCHAR(100),                                      
@process_id  VARCHAR(100),                                      
@user_login_id VARCHAR(50),                                      
@ip_address  VARCHAR(50)=NULL,                                      
@digital_id_sENDer VARCHAR(200)=null,      
@agentid varchar(100)=NULL ,      
@user varchar(100)=NULL    
                                 
AS                                      
                                      
DECLARE @sql VARCHAR(4000), @sql1 VARCHAR(4000),@temptablename VARCHAR(100),@detail_errorMsg VARCHAR(500)                                      
DECLARE @agent_id VARCHAR(50),@agent_name VARCHAR(150),@branch_name VARCHAR(150)                                      
DECLARE @rBankId VARCHAR(50), @rBankBranch VARCHAR(100),@rBankName VARCHAR(100),@receiveAgentID  VARCHAR(100)                                      
DECLARE @ERR_DESC VARCHAR(1000),@gmtdate DATETIME                           
              
-- CREATE TEMPORARY TABLE TO LOG IMPORT STATUS                                      
 CREATE TABLE #import_status(                                      
  temp_id   INT,                                      
  process_id  VARCHAR(100),                                      
  ErrorCode  VARCHAR(50),                                      
  Module   VARCHAR(100),                                      
  Source   VARCHAR(100),                                      
  [type]   VARCHAR(100),                                      
  description  VARCHAR(250)                                   
 )                                      
                                       
-- CREATE TEMPORYARY TABLE TO STORE COUNT                                      
 CREATE TABLE #temp_tot_count (totcount INT)                                      
                                       
                                       
-- CHECK FOR table_code AND SELECT table_name                                      
 SET @temptablename=dbo.FNAProcessTbl(@tablename, @user_login_id, @process_id)                                      
   --PRINT(@temptablename)                                    
-- CREATE TEMPORARY TABLE TO STORE DATA FROM EXTERNAL FILE                                      
                                     
SET @sql='CREATE TABLE '+@temptablename+'(               
                                            
  BranchName VARCHAR(200),Country VARCHAR(100),District VARCHAR(50),City VARCHAR(200),[Address] VARCHAR(500),Contact VARCHAR(500),EXTCODE VARCHAR(200),EXTCODE1 VARCHAR(200),[state] VARCHAR(50)                
 )'                                      
 --PRINT(@sql)                                      
 SET @sql1 = dbo.FNAProcessDeleteTbl(@temptablename)                                      
 EXEC(@sql1)                                      
 EXEC(@sql)                                      
         --if required agentCode VARCHAR(50),                              
-- BULK INSERT FROM EXTERNAL FILE TO TEMPORARY TABLE                            
                                 
   DECLARE @BULK_SQL VARCHAR(MAX)                                      
 SET @BULK_SQL = ' BULK INSERT '+@temptablename+'  FROM '''+@PathFileName+                            
 ''' WITH (FIELDTERMINATOR = ''|'',ROWTERMINATOR=''\n'',FIRSTROW=2,DATAFILETYPE=''char'')'                                            
  PRINT(@BULK_SQL)                                    
   EXEC(@BULK_SQL)                                      
  ---print(@BULK_SQL)
  --RETURN                  
  IF @@ERROR > 0                                         
  BEGIN                                      
--   IF any error found while doing bulk INSERT then return with error                                      
                                       
   SET @ERR_DESC = 'SQL Error found: (BULK INSERT ERROR' + ERROR_MESSAGE() + ')'                                     
   INSERT INTO #import_status            
   SELECT 1,@process_id,'ERROR','Import Data',@tablename,'Data Error',                                      
    'It is possible that the file format may be incorrect'                        
   GOTO FinalStep                                      
  END                                       
   EXEC('ALTER TABLE '+ @temptablename+' ADD TEMP_ID INT IDENTITY')                                     
                                                    
       create table #temp_ins  
(id int identity(1,1),  
BranchName VARCHAR(100),   
Country VARCHAR(200),
District VARCHAR(100),   
City VARCHAR(200) ,
[Address] VARCHAR(100),   
Contact VARCHAR(200) ,
EXTCODE VARCHAR(100),   
EXTCODE1 VARCHAR(200),
state VARCHAR(50)
)         
declare @sql_ins varchar(1000)  
set @sql_ins='insert into #temp_ins   
select a.BranchName,a.Country, a.District,a.City, a.Address,a.Contact, a.EXTCODE,a.EXTCODE1,a.State from '+@temptablename+' a group by a.BranchName,a.Country, a.District,a.City, a.Address,a.Contact, a.EXTCODE,a.EXTCODE1,a.state having count(*)>0'  
--print @sql_ins  
exec (@sql_ins)               
--RETURN    
--START CHECK DUPLICATION OF TRANSACTION                                       
 DECLARE @SQL_REFNO VARCHAR(1000)                                      
 SET @SQL_REFNO='INSERT INTO #import_status                                       
 SELECT  MIN(a.TEMP_ID),'''+@process_id+''',''Error'',''Import Data'',''test'',''Data Error'',                                      
 ''Duplicate data found in Excel File Branch Name:''+isnull(a.BranchName,NULL)+''.''                                
 FROM '+@temptablename+' a GROUP BY a.BranchName HAVING COUNT(*)>1'                                      
 --PRINT @SQL_REFNO                                      
 EXEC(@SQL_REFNO)                                      
 IF @@ROWCOUNT > 0                                       
 BEGIN                               
  GOTO FinalStep                                      
  RETURN                                       
 END                                       
                                      
                                      
--START DELETE FROM TEMP TABLE IF ALL THE FIELDS ARE NULL                                      
                                      
                                      
 EXEC('INSERT INTO #temp_tot_count SELECT COUNT(*) AS totcount FROM '+@temptablename)                                      
                                      
 DECLARE @SQL_IMPORT_STS VARCHAR(2000)                                      
 SET @SQL_IMPORT_STS = 'INSERT INTO #import_status               
 SELECT a.TEMP_ID,'''+ @process_id+''',''Error'',''Import Data'','''+@tablename+''',              
  ''Data Error'',''Data error for Branch Name :''+ isnull(a.BranchName,''NULL'')                                                            
 FROM '+@temptablename + ' a WHERE a.BranchName is null'                                      
  --PRINT(@SQL_IMPORT_STS)                                      
  EXEC(@SQL_IMPORT_STS)  
                                        
  EXEC('DELETE FROM '+@temptablename+' WHERE BranchName IS NULL') 
                                 
 EXEC(' INSERT INTO #import_status               
   SELECT a.TEMP_ID,'''+ @process_id+''',''Error'',''Import Data'', '''+@tablename+''',''Data Error'',              
   ''Branch name: ''+ isnull(a.BranchName,''NULL'') +'' already exists on system. you are making duplicate import. ''                                     
  FROM '+@temptablename + ' a JOIN commercial_bank_branch b on UPPER(LTRIM(RTRIM(b.BranchName)))=UPPER(LTRIM(RTRIM(a.BranchName)))              
   AND b.Commercial_id='''+@agentid+'''')                                       
        -- print @temptablename    
 EXEC('DELETE '+@temptablename + ' FROM #import_status INNER JOIN '+@temptablename + ' a ON #import_status.temp_id=a.temp_id')                                      
                   
           
           
 SET @sql1='INSERT INTO temp_import_bankbranchDetail(BranchName, Country,  District,  City, Address ,Contact, EXTCODE,  EXTCODE1,state,digital_id_sENDer,process_id)                                            
    SELECT BranchName, Country,  District,  City, Address ,Contact, EXTCODE,  EXTCODE1,state,'''+@digital_id_sENDer +''','''+@process_id+''' FROM '+@temptablename +''      
 --declare @sql2 varchar(max)  
 ----RETURN
 -- set @sql2='INSERT INTO temp_import_bankbranchDetail(BranchName, Country,  District,  City, Address ,Contact, EXTCODE,  EXTCODE1,state,digital_id_sENDer,process_id )                                            
 --   SELECT BranchName, Country,  District,  City, [Address] ,Contact, EXTCODE,  EXTCODE1,state,'''+@digital_id_sENDer +''','''+@process_id+''' FROM #temp_ins'  
              
  --SET @sql1='INSERT INTO temp_import_bankDetail(agentCode,Branch,Address,City,State,ContactPerson,Telephone,[Group],BranchType,digital_id_sENDer,process_id)                                            
  --SELECT '''+@agentid+''',Branch,Address,City,State,ContactPerson,Telephone,[Group],BranchType,'''+@digital_id_sENDer +''','''+@process_id+''' FROM '+@temptablename +''      
    
    --RETURN
                               
 DELETE temp_import_bankbranchDetail   WHERE process_id=@process_id                                   
 --PRINT(@sql1)              
 EXEC(@sql1)  
 --print @sql2  
--exec (@sql2)                                       
  IF @@ERROR > 0                                         
  BEGIN             
--   IF any error found while INSERT then return with error                                      
   SET @ERR_DESC = ''                                      
   SET @ERR_DESC = 'SQL Error found: (temp_bank_book INSERT ERROR' + ERROR_MESSAGE() + ')'                                       
   INSERT INTO #import_status                                     
   SELECT 1,@process_id,'ERROR','Import Data',@tablename,'Data Error',                                      
    'It is possible that the file format may be incorrect' ,'Please Check your file format',ISNULL(@ERR_DESC,'')                                      
   GOTO FinalStep                                      
  END             
  --  RETURN                                  
 FinalStep:                                      
 BEGIN                                      
  DECLARE @count INT,@totalcount INT                                      
  SET @count  = (SELECT COUNT(DISTINCT temp_id) FROM #import_status)                                      
  SET @totalcount = (SELECT totcount FROM #temp_tot_count)                                      
                                        
  IF @count>0                                      
   BEGIN                                      
  IF @totalcount>0                                      
     BEGIN                       
     SELECT @detail_errorMsg = cast((@totalcount-@count) AS VARCHAR(100))                                      
     +' Data imported Successfully out of '+cast(@totalcount as VARCHAR(100))                                      
     +'. Some Error found while importing. Please review Errors'                              
     END                                      
    ELSE                                      
     BEGIN                                      
     SELECT @detail_errorMsg = cast(@count AS VARCHAR(100))                                      
     +' Data imported Successfully out of '+cast(@totalcount as VARCHAR(100))                                      
     +'. Some Error found while importing. Please review Errors'                   END                                      
                                          
    INSERT INTO data_import_status(process_id,code,module,source,[type],[description],recommendation)                                       
    SELECT @process_id,'Error','Import Data',@tablename,'Data Error',@detail_errorMsg,'Please Check your data'                                      
                                          
    INSERT INTO data_import_status_detail(process_id,source,[type],[description])                                       
    SELECT @process_id,source,[type],[description] FROM #import_status WHERE process_id=@process_id                                      
   END                                      
  ELSE                                      
   BEGIN                                      
    SELECT @detail_errorMsg = CAST((@totalcount-@count) as VARCHAR(100))+' Data imported Successfully out of '+cast(@totalcount as VARCHAR(100))                                      
                                          
    INSERT INTO data_import_status(process_id,code,module,source,[TYPE],[description],recommendation)                                       
    SELECT @process_id,'Success','Import Data',@tablename,'Data import success',@detail_errorMsg,''              
   END                                      
 END               
GO
