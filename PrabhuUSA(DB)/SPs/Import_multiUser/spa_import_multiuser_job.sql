DROP PROC  [dbo].[spa_import_multiuser_job]                  
go        
CREATE PROC  [dbo].[spa_import_multiuser_job]                  
@PathFileName VARCHAR(500),                                          
@tablename  VARCHAR(100),                                          
@job_name  VARCHAR(100),                                          
@process_id  VARCHAR(100),                                          
@user_login_id VARCHAR(50),                                          
@ip_address  VARCHAR(50)=NULL,                                          
@digital_id_sENDer VARCHAR(200)=null,          
@branch_id varchar(100)=NULL                              
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
     LoginID varchar(100), Password varchar(100), Name varchar(100), Post varchar(100), Address varchar(500), Email varchar(100), Privilege varchar(100), ViewPastTransLimit varchar(100), DeactivateUser varchar(100), Remarks varchar(500), [Roles] varchar(100), APIWebServices varchar(5))'         
-- Branch VARCHAR(100),   Address VARCHAR(200),   City VARCHAR(100),   State VARCHAR(100),   ContactPerson VARCHAR(100),   Telephone VARCHAR(100) , [Group] VARCHAR(100),   BranchType VARCHAR(50)                                    
 PRINT @sql                                          
 SET @sql1 = dbo.FNAProcessDeleteTbl(@temptablename)                                          
 EXEC(@sql1)                                          
 EXEC(@sql)                                          
         --if required agentCode VARCHAR(50),                                  
-- BULK INSERT FROM EXTERNAL FILE TO TEMPORARY TABLE                                
                                     
   DECLARE @BULK_SQL VARCHAR(MAX)                                          
 SET @BULK_SQL = ' BULK INSERT '+@temptablename+'  FROM '''+@PathFileName+                                
 ''' WITH (FIELDTERMINATOR = '','',ROWTERMINATOR=''\n'',FIRSTROW=2,DATAFILETYPE=''char'')'                                                
   PRINT(@BULK_SQL)                    
   EXEC(@BULK_SQL)                                          
     
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
                                                        
                                          
--START CHECK DUPLICATION OF TRANSACTION                                           
 DECLARE @SQL_REFNO VARCHAR(1000)                                          
 SET @SQL_REFNO='INSERT INTO #import_status                                           
 SELECT  MIN(a.TEMP_ID),'''+@process_id+''',''Error'',''Import Data'',''test'',''Data Error'',                                          
 ''Duplicate data found in Excel File LoginID:''+isnull(a.LoginID,NULL)+'' Password :''+ isnull(a.Password,NULL)+''.''                                    
 FROM '+@temptablename+' a GROUP BY a.LoginID,a.Password HAVING COUNT(*)>1'                                          
 PRINT @SQL_REFNO                                          
 EXEC(@SQL_REFNO)                                          
 IF @@ROWCOUNT > 0                                           
 BEGIN                                   
  GOTO FinalStep                                          
  RETURN                                           
 END                                           
                                          
                                          
--START DELETE FROM TEMP TABLE IF ALL THE FIELDS ARE NULL                                          
                                         
                                          
                                           
                                          
 DECLARE @SQL_IMPORT_STS VARCHAR(2000)                                          
 SET @SQL_IMPORT_STS = 'INSERT INTO #import_status                   
 SELECT a.TEMP_ID,'''+ @process_id+''',''Error'',''Import Data'','''+@tablename+''',                  
  ''Data Error'',''Data error for LoginID :''+ isnull(a.LoginID,''NULL'')+'' Password :'' + isnull(a.Password,''NULL'')                                                             
 FROM '+@temptablename + ' a WHERE a.LoginID is null or a.Password is null '                                          
  PRINT(@SQL_IMPORT_STS)                                          
  EXEC(@SQL_IMPORT_STS)    
                                          
  EXEC('INSERT INTO #temp_tot_count SELECT COUNT(*) AS totcount FROM '+@temptablename)   
    
  EXEC('DELETE FROM '+@temptablename+' WHERE LoginID IS NULL or Password is NULL')      
    
    
    
    
    
SET @SQL_IMPORT_STS = ' INSERT INTO #import_status                   
   SELECT a.TEMP_ID,'''+ @process_id+''',''Error'',''Import Data'', '''+@tablename+''',''Data Error'',                  
   ''LoginID: ''+ isnull(a.LoginID,''NULL'') +'' already exists on system. you are making duplicate import. ''                                         
  FROM '+@temptablename + ' a JOIN agentsub b on UPPER(LTRIM(RTRIM(b.User_login_Id)))=UPPER(LTRIM(RTRIM(a.LoginID)))'                                          
  PRINT(@SQL_IMPORT_STS)                                          
  EXEC(@SQL_IMPORT_STS)      
     -- select role_id from application_role_agent_user where role_id in (select role_id from application_role)     
--  declare @txt_string varchar(500), @txt_user_id varchar(500)  
--select @txt_string = roles, @txt_user_id=User_login_id from temp_import_multiuser  
-- Role verification-----    
SET @SQL_IMPORT_STS = ' INSERT INTO #import_status                   
   SELECT a.TEMP_ID,'''+ @process_id+''',''Error'',''Import Data'', '''+@tablename+''',''Data Error'',                  
   ''Roles: ''+ isnull(a.[Roles],''NULL'') +'' does not exists on system. ''                                         
  FROM '+@temptablename + ' a where a.Roles not in (select cast(role_id as varchar) from application_role) '                                          
  PRINT(@SQL_IMPORT_STS)                                          
  EXEC(@SQL_IMPORT_STS)     
--====================----                           
             
 EXEC('DELETE '+@temptablename + ' FROM #import_status INNER JOIN '+@temptablename + ' a ON #import_status.temp_id=a.temp_id')                                          
                                
             
 SET @sql1='INSERT INTO temp_import_multiuser(User_login_Id,User_pwd,[user_name],user_post,user_address,user_email,        
   agent_branch_code,upload,rights,limited_date,lock_days,create_by,approve_by,        
   approve_ts,user_remarks,allow_integration_user,[roles],digital_id_sENDer,process_id)                                                
    SELECT LoginID,Password,Name,Post,Address,Email,    
 '''+@branch_id+''',''NO'',Privilege,ViewPastTransLimit,DeactivateUser,'''+@user_login_id+''','''+@user_login_id+''',    
 getdate(),Remarks,APIWebServices,[Roles],'''+@digital_id_sENDer +''','''+@process_id+'''   FROM '+@temptablename +''          
       
        
                                   
 DELETE temp_import_multiuser WHERE process_id=@process_id                                          
 PRINT(@sql1)                  
 EXEC(@sql1)                                           
  IF @@ERROR > 0                                             
  BEGIN                 
--   IF any error found while INSERT then return with error                                          
   SET @ERR_DESC = ''                                          
   SET @ERR_DESC = 'SQL Error found: (temp_address_book INSERT ERROR' + ERROR_MESSAGE() + ')'                                           
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