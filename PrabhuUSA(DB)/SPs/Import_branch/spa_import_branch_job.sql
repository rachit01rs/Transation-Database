DROP PROC  [dbo].[spa_import_branch_job]            
GO   
CREATE PROC  [dbo].[spa_import_branch_job]            
@PathFileName VARCHAR(500),                                    
@tablename  VARCHAR(100),                                    
@job_name  VARCHAR(100),                                    
@process_id  VARCHAR(100),                                    
@user_login_id VARCHAR(50),                                    
@ip_address  VARCHAR(50)=NULL,                                    
@digital_id_sENDer VARCHAR(200)=null,    
@agentid varchar(100)=NULL ,    
@user varchar(100)=NULL,  
@autouser VARCHAR(50)=NULL,      
@BranchType VARCHAR(50)=NULL,      
@userRole VARCHAR(50)=NULL                                   
AS                                    
                                    
DECLARE @sql VARCHAR(4000), @sql1 VARCHAR(4000),@temptablename VARCHAR(100),@detail_errorMsg VARCHAR(500)                                    
DECLARE @agent_id VARCHAR(50),@agent_name VARCHAR(150),@branch_name VARCHAR(150)                                    
DECLARE @rBankId VARCHAR(50), @rBankBranch VARCHAR(100),@rBankName VARCHAR(100),@receiveAgentID  VARCHAR(100)                                    
DECLARE @ERR_DESC VARCHAR(1000),@gmtdate DATETIME                         

--IF @userRole='0'
--	SET @userRole=NULL
            
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
		                                       
		  Branch VARCHAR(100),   Address VARCHAR(200),   City VARCHAR(100),   State VARCHAR(100),
		  ContactPerson VARCHAR(100), EmailID varchar(100),  Telephone VARCHAR(100) ,
		  Fax varchar(100), BranchCode varchar(100),
		  ExtBranchCode varchar(100),User_login_Id varchar(50)       
	)'                                
-- PRINT @sql                                    
 SET @sql1 = dbo.FNAProcessDeleteTbl(@temptablename)                                    
 EXEC(@sql1)                                    
 EXEC(@sql)                                    
         --if required agentCode VARCHAR(50),                            
-- BULK INSERT FROM EXTERNAL FILE TO TEMPORARY TABLE                          
                               
   DECLARE @BULK_SQL VARCHAR(MAX)                                    
 SET @BULK_SQL = ' BULK INSERT '+@temptablename+'  FROM '''+@PathFileName+                          
 ''' WITH (FIELDTERMINATOR = ''|'',ROWTERMINATOR=''\n'',FIRSTROW=2,DATAFILETYPE=''char'')'                                          
  -- PRINT(@BULK_SQL)                                  
   EXEC(@BULK_SQL)                                    
--   print(@BULK_SQL)                
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
 ''Duplicate data found in Excel File Branch Name:''+isnull(a.Branch,NULL)+'' Address :''+ isnull(a.Address,NULL)+'' City:''+ isnull(a.City, Null)+'' BranchCode:''+isnull(a.BranchCode, Null)+''.''                              
 FROM '+@temptablename+' a GROUP BY a.Branch,a.Address, a.CITY,a.BranchCode HAVING COUNT(*)>1'                                    
-- PRINT @SQL_REFNO                                    
 EXEC(@SQL_REFNO)                                    
 IF @@ROWCOUNT > 0                                     
 BEGIN                             
  GOTO FinalStep                                    
  RETURN                                     
 END                                     
                                    
  EXEC('INSERT INTO #temp_tot_count SELECT COUNT(*) AS totcount FROM '+@temptablename)                                  
--START DELETE FROM TEMP TABLE IF ALL THE FIELDS ARE NULL                                    
                                     
                                    
                                     
                                    
 DECLARE @SQL_IMPORT_STS VARCHAR(2000)                                    
 SET @SQL_IMPORT_STS = 'INSERT INTO #import_status             
 SELECT a.TEMP_ID,'''+ @process_id+''',''Error'',''Import Data'','''+@tablename+''',            
  ''Data Error'',''Data error for Branch Name :''+ isnull(a.branch,''null'')+'' Address:''+isnull(a.address,''null'')+ '' BranchCode:''+isnull(a.BranchCode,''null'')                                                        
 FROM '+@temptablename + ' a WHERE a.branch is null or a.address is null or a.branchcode is null'                                    
  --PRINT(@SQL_IMPORT_STS)                                    
  EXEC(@SQL_IMPORT_STS)                                      
   
EXEC('DELETE FROM '+@temptablename+' WHERE Branch IS NULL or Address is null or branchcode is null')
SET @SQL_IMPORT_STS = ' INSERT INTO #import_status             
   SELECT a.TEMP_ID,'''+ @process_id+''',''Error'',''Import Data'', '''+@tablename+''',''Data Error'',            
   ''Branch name: ''+ isnull(a.branch,''NULL'') +'' already exists on system. you are making duplicate import. ''                                   
  FROM '+@temptablename + ' a JOIN agentbranchdetail b on UPPER(LTRIM(RTRIM(b.branch)))=UPPER(LTRIM(RTRIM(a.branch)))            
   AND b.agentCode='''+@agentid+''' AND b.address=a.address and b.Branch_Type='''+@BranchType+''' and b.branchCodeChar=a.branchcode'                                    
  --PRINT(@SQL_IMPORT_STS)                                    
  EXEC(@SQL_IMPORT_STS)
                            
            
 EXEC('DELETE '+@temptablename + ' FROM #import_status INNER JOIN '+@temptablename + ' a ON #import_status.temp_id=a.temp_id')                                    
 
 SET @SQL_IMPORT_STS = ' INSERT INTO #import_status             
   SELECT t.TEMP_ID,'''+ @process_id+''',''Error'',''Import Data'', '''+@tablename+''',''Data Error'',            
   ''User name: ''+ isnull(a.User_login_Id,''NULL'') +'' already exists on system. User cannot be created but the branch( ''+ isnull(t.branch,''NULL'') +'') is created. ''                                   
  FROM '+ @temptablename + ' t JOIN dbo.agentsub a ON T.user_login_id=a.user_login_id WHERE a.User_login_Id IS NOT NULL
  
  Update ' +@temptablename + ' SET user_login_id=NULL    FROM '+@temptablename + ' t JOIN dbo.agentsub a ON T.user_login_id=a.user_login_id WHERE a.User_login_Id IS NOT NULL'                                    
  --PRINT(@SQL_IMPORT_STS)                                    
  EXEC(@SQL_IMPORT_STS)
                  
 SET @sql1='INSERT INTO temp_import_branchDetail(agentCode,Branch,Address,City,State,ContactPerson,Telephone,BranchType,emailid,fax,branchcode,extbranchcode,digital_id_sENDer,process_id,    
   User_login_Id,create_by,approve_by,approve_ts,user_role)                                          
    SELECT '''+@agentid+''',Branch,Address,City,State,ContactPerson,Telephone,'''+@BranchType+''',emailid,left(fax,50),branchcode,extbranchcode,'''+@digital_id_sENDer +''','''+@process_id+''',    
    LTRIM(RTRIM(User_login_Id)),'''+@user+''','''+@user+''',getdate(),'''+@userRole+'''   FROM '+@temptablename +''    
  
                             
 DELETE temp_import_branchDetail  WHERE  process_id=@process_id                                
 --PRINT(@sql1)            
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
    
  
GO
