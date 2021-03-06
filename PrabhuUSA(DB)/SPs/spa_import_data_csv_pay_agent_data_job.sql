IF OBJECT_ID('spa_import_data_csv_pay_agent_data_job', 'P') IS NOT NULL 
    DROP PROCEDURE [dbo].[spa_import_data_csv_pay_agent_data_job]  
GO
CREATE PROCEDURE [dbo].[spa_import_data_csv_pay_agent_data_job]
    @PathFileName VARCHAR(500) ,
    @tablename VARCHAR(100) ,
    @job_name VARCHAR(100) ,
    @process_id VARCHAR(100) ,
    @user_login_id VARCHAR(50) ,
    @branch_id VARCHAR(20) ,
    @ip_address VARCHAR(50) = NULL ,
    @digital_id_payout VARCHAR(200) = NULL
AS 
    DECLARE @sql VARCHAR(4000)  
    DECLARE @sql1 VARCHAR(4000)  
    DECLARE @temptablename VARCHAR(100)  
    DECLARE @detail_errorMsg VARCHAR(500)  
  
    DECLARE @payout_branch_id VARCHAR(100)  
    DECLARE @expected_payoutagentid VARCHAR(100)  
    DECLARE @payout_branch_name VARCHAR(100)  
    DECLARE @payout_agent_name VARCHAR(100)  
    SET @payout_branch_id = @branch_id  
   
    SELECT  @expected_payoutagentid = a.agentcode ,
            @payout_branch_name = branch ,
            @payout_agent_name = companyName
    FROM    agentdetail a
            JOIN agentbranchdetail b ON a.agentcode = b.agentcode
    WHERE   agent_branch_code = @payout_branch_id  
   
    DECLARE @today_time VARCHAR(20)  
    SET @today_time = dbo.CTGetTime(GETDATE())  
 --Create temporary table to log import status  
    CREATE TABLE #import_status
        (
          temp_id INT ,
          process_id VARCHAR(100) ,
          ErrorCode VARCHAR(50) ,
          Module VARCHAR(100) ,
          Source VARCHAR(100) ,
          type VARCHAR(100) ,
          [description] VARCHAR(250) ,
          [nextstep] VARCHAR(250)
        )  
   
 --create temporary table to store count  
    CREATE TABLE #temp_tot_count ( totcount INT )  
   
   
 --Check for table_code and select table_name  
   
    SET @temptablename = dbo.FNAProcessTbl(@tablename, @user_login_id,
                                           @process_id)  
    PRINT @temptablename  
 --create temporary table to store data from external file  
   
    SET @sql = 'create table ' + @temptablename + '(  
   [REFNO] [varchar] (500) ,
   [PAY_DATE] [varchar] (500),     
   [AMOUNT] [money]  
   )'  
    SET @sql1 = dbo.FNAProcessDeleteTbl(@temptablename)  
    EXEC (@sql1)  
   
    EXEC(@sql)  
 --Bulk Insert from external file to temporay table  
   
    SET @SQL = ' BULK INSERT ' + @temptablename + '  FROM ''' + @PathFileName
        + ''' WITH (FIELDTERMINATOR = '','', FIRSTROW  = 2) '  
    EXEC (@sql)  
-- Add identity column in the temporary table to track data in temporary table  
    EXEC('alter table '+ @temptablename+' add TEMP_ID int identity')  
    EXEC('alter table '+ @temptablename+' add PAYOUT_BRANCH_ID varchar(50)')  
    EXEC('update '+ @temptablename+' set PAYOUT_BRANCH_ID='+@payout_branch_id)  
   
 --if any error found while doing bulk insert then return with error  
    IF @@ERROR <> 0 
        BEGIN  
            INSERT  INTO #import_status
                    SELECT  1 ,
                            @process_id ,
                            'Error' ,
                            'Import Data' ,
                            @tablename ,
                            'Data Error' ,
                            'It is possible that the file format may be incorrect' ,
                            'Please Check your file format'   
      
            GOTO FinalStep  
            RETURN  
        END  
   
 --cehck for tablename  
   
    EXEC('select * from '+@temptablename)  
    
    EXEC('insert into #import_status select  min(a.TEMP_ID),'''+@process_id+''',''Error'',''Import Data'',''test'',''Data Error'',  
    ''Duplicate data found in Excel File Refno :''+ isnull(ltrim(rtrim(a.REFNO)),''NULL''),  
    ''Please check your data''   
    from '+@temptablename+' a group by a.REFNO  
    having count(*)>1')  
    
    IF @@rowcount > 0 
        BEGIN  
            GOTO FinalStep  
            RETURN   
        END  
  --Delete from temp table if all the fields are null      
    EXEC('delete from '+@temptablename+' where AMOUNT is null ')  
   -- insert into #temp_tot_count tot count from temp table  
    EXEC (' insert into #temp_tot_count select count(*) as totcount  from '+@temptablename)  
     
    EXEC('insert into #import_status select a.TEMP_ID,'''+ @process_id+''',''Error'',''Import Data'','''+@tablename+''',''Data Error'',  
    ''Data error for Refno :''+ isnull(ltrim(rtrim(a.REFNO)),''NULL'')+'', AMOUNT :''+ isnull(cast(a.AMOUNT as varchar),''NULL'')+''.  
    '', ''Please check your data''   
    from '+@temptablename + ' a where a.AMOUNT=0   
    or len(ltrim(rtrim(a.REFNO)))=0')  
    
    --Check for Date Validation  
    EXEC('insert into #import_status select a.TEMP_ID,'''+ @process_id+''',''Error'',''Import Data'','''+@tablename+''',''Data Error'',  
    ''Ref No :''+ isnull(ltrim(rtrim(a.REFNO)),''NULL'')+'', AMOUNT :''+ isnull(cast(a.AMOUNT as varchar),''NULL'')+  
    ''. Invalid Date Format. Please use standard date format (mm/dd/yyyy)'', ''Invalid Date Format ''   
    from '+@temptablename + ' a where ISDATE(a.[PAY_DATE])=0')
    
    --Check for TRN in MoneySend Comfirm date 
   exec('insert into #import_status select a.TEMP_ID,'''+ @process_id+''',''Error'',''Import Data'','''+@tablename+''',''Data Error'',  
   ''Ref No :''+ isnull(ltrim(rtrim(a.REFNO)),''NULL'')+'', AMOUNT :''+ isnull(cast(a.AMOUNT as varchar),''NULL'')+  
   ''. Trasaction Not Found for Payment'', ''Trasaction Not Found for Payment''   
    FROM '+@temptablename + ' a LEFT OUTER JOIN moneysend m with(nolock) on dbo.encryptdb(ltrim(rtrim(a.REFNO)))=m.refno  
    where DATEDIFF(dd,m.confirmdate,a.[PAY_DATE])>=0')  
    
   --Check for TRN in MoneySend  
    EXEC('insert into #import_status select a.TEMP_ID,'''+ @process_id+''',''Error'',''Import Data'','''+@tablename+''',''Data Error'',  
    ''Ref No :''+ isnull(ltrim(rtrim(a.REFNO)),''NULL'')+'', AMOUNT :''+ isnull(cast(a.AMOUNT as varchar),''NULL'')+  
    ''. Trasaction Not Found for Payment'', ''Trasaction Not Found for Payment''   
    from '+@temptablename + ' a left outer join moneysend m with(nolock) on dbo.encryptdb(ltrim(rtrim(a.REFNO)))=m.refno  
    where m.refno is NULL')  
  
   --Check for TRN PaymentStatus in MoneySend   
    EXEC('insert into #import_status select a.TEMP_ID,'''+ @process_id+''',''Error'',''Import Data'','''+@tablename+''',''Data Error'',  
    ''Ref No :''+ isnull(ltrim(rtrim(a.REFNO)),''NULL'')+'', AMOUNT :''+ isnull(cast(a.AMOUNT as varchar),''NULL'')+  
    ''. Trasaction Is in ''+m.TransStatus+'' Not Valid for Payment'', ''Trasaction Is in ''+m.TransStatus+'' Not Valid for Payment''   
    from '+@temptablename + ' a join moneysend m with(nolock) on dbo.encryptdb(ltrim(rtrim(a.REFNO)))=m.refno  
    where m.TransStatus<>''Payment''')  
  
   --Check for TRN STATUS in MoneySend   
    EXEC('insert into #import_status select a.TEMP_ID,'''+ @process_id+''',''Error'',''Import Data'','''+@tablename+''',''Data Error'',  
    ''Ref No :''+ isnull(ltrim(rtrim(a.REFNO)),''NULL'')+'', AMOUNT :''+ isnull(cast(a.AMOUNT as varchar),''NULL'')+  
    ''. Trasaction Is Already Paid'', ''Trasaction Is Already Paid''   
    from '+@temptablename + ' a join moneysend m with(nolock) on dbo.encryptdb(ltrim(rtrim(a.REFNO)))=m.refno  
    where m.status=''Paid''')  
  
   --Check for AMOUNT in MoneySend   
    EXEC('insert into #import_status select a.TEMP_ID,'''+ @process_id+''',''Error'',''Import Data'','''+@tablename+''',''Data Error'',  
    ''Ref No :''+ isnull(ltrim(rtrim(a.REFNO)),''NULL'')+'', AMOUNT :''+ isnull(cast(a.AMOUNT as varchar),''NULL'')+  
    ''. Payout Amount Did not Match; Not Valid for Payment'', ''Payout Amount Did not Match; Not Valid for Payment''   
    from '+@temptablename + ' a join moneysend m with(nolock) on dbo.encryptdb(ltrim(rtrim(a.REFNO)))=m.refno  
    where m.TotalRoundAmt<>a.AMOUNT')  
   --Check for EXPECTED_PAYOUTAGENTID in MoneySend   
    EXEC('insert into #import_status select a.TEMP_ID,'''+ @process_id+''',''Error'',''Import Data'','''+@tablename+''',''Data Error'',  
    ''Ref No :''+ isnull(ltrim(rtrim(a.REFNO)),''NULL'')+'', AMOUNT :''+ isnull(cast(a.AMOUNT as varchar),''NULL'')+  
    ''. Payout Agent Did not Match; Not Valid for Payment'', ''Payout agent Did not Match; Not Valid for Payment''   
    from '+@temptablename + ' a join moneysend m with(nolock) on dbo.encryptdb(ltrim(rtrim(a.REFNO)))=m.refno  
    where m.expected_payoutagentid<>'+@expected_payoutagentid)  
     
   -- delete from temp table all the invalid data  
    EXEC('delete '+@temptablename + ' from #import_status inner join '+@temptablename + ' a on  
    #import_status.temp_id=a.temp_id')  
  
    PRINT @sql  
    SET @sql1 = 'insert into temp_trn_csv_pay(tranno,refno,ReceiverName,TotalRoundAmt,  
   paidDate,paidBy,expected_payoutagentid,rBankID,rBankName,rBankBranch,digital_id_payout)  
   select tranno,m.refno,receiverName,TotalRoundAmt,PAY_DATE,'''
        + @user_login_id + ''',''' + @expected_payoutagentid + ''','''
        + @payout_branch_id + ''',''' + @payout_agent_name + ''','''
        + @payout_branch_name + ''',''' + @digital_id_payout + '''  
   from ' + @temptablename
        + ' a join moneysend m with(nolock) on dbo.encryptdb(ltrim(rtrim(a.REFNO)))=m.refno'  
  
-- --Delete All Previous Entries  
    DELETE  temp_trn_csv_pay
    WHERE   digital_id_payout = @digital_id_payout  
    PRINT @sql1  
    EXEC(@sql1)   
  
    FinalStep:  
    DECLARE @sql3 VARCHAR(1000)  
    SET @sql3 = dbo.FNAProcessDeleteTbl(@temptablename)  
 --exec (@sql3)  
    DECLARE @count INT ,
        @totalcount INT  
    SET @count = ( SELECT   COUNT(DISTINCT temp_id)
                   FROM     #import_status
                 )  
    SET @totalcount = ( SELECT  totcount
                        FROM    #temp_tot_count
                      )  
    IF @count > 0 
        BEGIN  
            IF @totalcount > 0 
                SELECT  @detail_errorMsg = CAST(@totalcount - @count AS VARCHAR(100))
                        + ' Data imported Successfully out of '
                        + CAST(@totalcount AS VARCHAR(100))
                        + '. Some Error found while importing. Please review Errors'  
            ELSE 
                SELECT  @detail_errorMsg = CAST(@totalcount AS VARCHAR(100))
                        + ' Data imported Successfully. Some Error found while importing. Please review Errors'  
     
            INSERT  INTO data_import_status
                    ( process_id ,
                      code ,
                      module ,
                      source ,
                      type ,
                      [description] ,
                      recommendation
                    )
                    SELECT  @process_id ,
                            'Error' ,
                            'Import Data' ,
                            @tablename ,
                            'Data Error' ,
                            @detail_errorMsg ,
                            'Please Check your data'  
      
            INSERT  INTO data_import_status_detail
                    ( process_id ,
                      source ,
                      type ,
                      [description]
                    )
                    SELECT  @process_id ,
                            @tablename ,
                            type ,
                            [description]
                    FROM    #import_status
                    WHERE   process_id = @process_id  
     
        END  
    ELSE 
        BEGIN  
            SELECT  @detail_errorMsg = CAST(@totalcount - @count AS VARCHAR(100))
                    + ' Data imported Successfully out of '
                    + CAST(@totalcount AS VARCHAR(100))  
     
            INSERT  INTO data_import_status
                    ( process_id ,
                      code ,
                      module ,
                      source ,
                      type ,
                      [description] ,
                      recommendation
                    )
                    SELECT  @process_id ,
                            'Success' ,
                            'Import Data' ,
                            @tablename ,
                            'Data Error' ,
                            @detail_errorMsg ,
                            ''  
        END  
  
  
  
