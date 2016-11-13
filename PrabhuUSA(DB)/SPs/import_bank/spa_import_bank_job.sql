DROP PROC  [dbo].[spa_import_bank_job]
go       
CREATE PROC  [dbo].[spa_import_bank_job]                
@PathFileName VARCHAR(500),                                        
@tablename  VARCHAR(100),                                        
@job_name  VARCHAR(100),                                        
@process_id  VARCHAR(100),                                        
@user_login_id VARCHAR(50),                                        
@ip_address  VARCHAR(50)=NULL,                                        
@digital_id_sENDer VARCHAR(200)=null,        
@agent_country varchar(100)=NULL ,        
@user varchar(100)=NULL,      
@payingOutAgent VARCHAR(50)=NULL                                     
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
                                         
-- CREATE TEMPORARY TABLE TO STORE DATA FROM EXTERNAL FILE                                        
                                       
SET @sql='CREATE TABLE '+@temptablename+'(                 
                                              
  Bank VARCHAR(100),   ExtBankID VARCHAR(200)                 
 )'                                        
 PRINT @sql                                        
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
   print(@BULK_SQL)                    
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
bank varchar(200),    
extbankid varchar(200)    
)           
declare @sql_ins varchar(1000)    
set @sql_ins='insert into #temp_ins     
select a.bank,a.extbankid from '+@temptablename+' a group by a.bank,a.extbankid having count(*)>1'    
print @sql_ins    
exec (@sql_ins)                     
--START CHECK DUPLICATION OF TRANSACTION                                         
 DECLARE @SQL_REFNO VARCHAR(1000)                                        
 SET @SQL_REFNO='INSERT INTO #import_status                                         
 SELECT  MIN(a.TEMP_ID),'''+@process_id+''',''Error'',''Import Data'',''test'',''Data Error'',                                        
 ''Duplicate data found in Excel File Bank Name:''+isnull(a.Bank,NULL)+'' ExtBankID :''+ isnull(a.ExtBankID,NULL)+''. Data merged.''                                  
 FROM '+@temptablename+' a GROUP BY a.bank,a.extbankid HAVING COUNT(*)>1'                                        
 PRINT @SQL_REFNO                                        
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
  ''Data Error'',''Data error for Bank Name :''+ isnull(a.Bank,''NULL'')+'' ExtBankID :''+ isnull(a.ExtBankID,''NULL'')                                                             
 FROM '+@temptablename + ' a WHERE a.Bank is null or a.ExtBankID is null'                                        
  PRINT(@SQL_IMPORT_STS)                                        
  EXEC(@SQL_IMPORT_STS)                                          
 EXEC('DELETE FROM '+@temptablename+' WHERE Bank IS NULL or ExtBankID is null')                                        
 EXEC(' INSERT INTO #import_status                 
   SELECT a.TEMP_ID,'''+ @process_id+''',''Error'',''Import Data'', '''+@tablename+''',''Data Error'',                
   ''Bank name: ''+ isnull(a.Bank,''NULL'') +'' already exists on system. you are making duplicate import. ''                                       
  FROM '+@temptablename + ' a JOIN Commercial_bank b on UPPER(LTRIM(RTRIM(b.Bank_name)))=UPPER(LTRIM(RTRIM(a.Bank)))                
   AND b.external_bank_id=a.ExtBankID where UPPER(LTRIM(RTRIM(b.Bank_name)))=UPPER(LTRIM(RTRIM(a.Bank))) and b.external_bank_id=a.ExtBankID and b.country='''+@agent_country+''' and b.payout_agent_id='''+@payingOutAgent+'''')                               
          
                
 EXEC('DELETE '+@temptablename + ' FROM #import_status INNER JOIN '+@temptablename + ' a ON #import_status.temp_id=a.temp_id')                           
                              
             
 SET @sql1='INSERT INTO temp_import_bankDetail(Bank,ExtBankID,agent_country,payingOutAgent,digital_id_sENDer,process_id        
   )                                              
    SELECT Bank,ExtBankID,'''+@agent_country+''','''+@payingOutAgent+''','''+@digital_id_sENDer +''','''+@process_id+''' FROM '+@temptablename +''        
 declare @sql2 varchar(max)    
  set @sql2='INSERT INTO temp_import_bankDetail(Bank,ExtBankID,agent_country,payingOutAgent,digital_id_sENDer,process_id        
   )                                              
    SELECT Bank,ExtBankID,'''+@agent_country+''','''+@payingOutAgent+''','''+@digital_id_sENDer +''','''+@process_id+''' FROM #temp_ins '    
                
--  SET @sql1='INSERT INTO temp_import_bankDetail(agentCode,Branch,Address,City,State,ContactPerson,Telephone,[Group],BranchType,digital_id_sENDer,process_id)                                              
--  SELECT '''+@agentid+''',Branch,Address,City,State,ContactPerson,Telephone,[Group],BranchType,'''+@digital_id_sENDer +''','''+@process_id+''' FROM '+@temptablename +''        
--      
      
                                 
 DELETE temp_import_bankDetail WHERE process_id=@process_id                                       
 PRINT(@sql1)                
 EXEC(@sql1)    
print @sql2    
exec (@sql2)                                         
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