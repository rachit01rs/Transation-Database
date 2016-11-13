drop procedure  [dbo].[spa_import_data_csv_pay_data_job]  
go  
CREATE procedure  [dbo].[spa_import_data_csv_pay_data_job]  
 @PathFileName varchar(500),  
 @tablename varchar(100),  
 @job_name varchar(100),  
 @process_id varchar(100),  
 @user_login_id varchar(50),  
 @branch_id varchar(20),  
 @ip_address varchar(50)=NULL,  
 @digital_id_payout varchar(200)=null  
   
 as  
 Declare @sql varchar(4000)  
 Declare @sql1 varchar(4000)  
 Declare @temptablename varchar(100)  
 declare @detail_errorMsg varchar(500)  
  
 declare @payout_branch_id varchar(100)  
 declare @expected_payoutagentid varchar(100)  
 declare @payout_branch_name varchar(100)  
 declare @payout_agent_name varchar(100)  
 set @payout_branch_id=@branch_id  
   
 select @expected_payoutagentid=a.agentcode,@payout_branch_name=branch,@payout_agent_name=companyName  
 from agentdetail a join agentbranchdetail b on a.agentcode=b.agentcode where agent_branch_code=@payout_branch_id  
   
 declare @today_time varchar(20)  
 set @today_time=dbo.CTGetTime(getdate())  
 --Create temporary table to log import status  
 CREATE TABLE #import_status  
  (  
  temp_id int,  
  process_id varchar(100),  
  ErrorCode varchar(50),  
  Module varchar(100),  
  Source varchar(100),  
  type varchar(100),  
  [description] varchar(250),  
  [nextstep] varchar(250)  
  )  
   
 --create temporary table to store count  
 create table #temp_tot_count (  
  totcount int)  
   
   
 --Check for table_code and select table_name  
   
 set @temptablename=dbo.FNAProcessTbl(@tablename, @user_login_id, @process_id)  
 print @temptablename  
 --create temporary table to store data from external file  
   
  set @sql='create table '+@temptablename+'(  
   [PAY_DATE] [varchar] (500),  
   [REFNO] [varchar] (500) ,     
   [AMOUNT] [money]  
   )'  
 SET @sql1 = dbo.FNAProcessDeleteTbl(@temptablename)  
 exec (@sql1)  
   
 exec(@sql)  
 --Bulk Insert from external file to temporay table  
   
 SET @SQL = ' BULK INSERT '+@temptablename+'  FROM '''+@PathFileName+''' WITH (FIELDTERMINATOR = '','', FIRSTROW  = 2) '  
 exec (@sql)  
-- Add identity column in the temporary table to track data in temporary table  
 exec('alter table '+ @temptablename+' add TEMP_ID int identity')  
 exec('alter table '+ @temptablename+' add PAYOUT_BRANCH_ID varchar(50)')  
 exec('update '+ @temptablename+' set PAYOUT_BRANCH_ID='+@payout_branch_id)  
   
 --if any error found while doing bulk insert then return with error  
   if @@ERROR<>0  
   Begin  
   insert into #import_status select 1,@process_id,'Error','Import Data',@tablename,'Data Error',  
    'It is possible that the file format may be incorrect' ,'Please Check your file format'   
      
   GOTO FinalStep  
   return  
   End  
   
 --cehck for tablename  
   
 --EXEC('select * from '+@temptablename)  
    
  exec('insert into #import_status select  min(a.TEMP_ID),'''+@process_id+''',''Error'',''Import Data'',''test'',''Data Error'',  
    ''Duplicate data found in Excel File Refno :''+ isnull(ltrim(rtrim(a.REFNO)),''NULL''),  
    ''Please check your data''   
    from '+@temptablename+' a group by a.REFNO  
    having count(*)>1')  
    
  if @@rowcount > 0   
  begin  
   GOTO FinalStep  
   return   
  end  
  --Delete from temp table if all the fields are null      
   exec('delete from '+@temptablename+' where AMOUNT is null ')  
   -- insert into #temp_tot_count tot count from temp table  
   exec (' insert into #temp_tot_count select count(*) as totcount  from '+@temptablename)  
     
   exec('insert into #import_status select a.TEMP_ID,'''+ @process_id+''',''Error'',''Import Data'','''+@tablename+''',''Data Error'',  
   ''Data error for Refno :''+ isnull(ltrim(rtrim(a.REFNO)),''NULL'')+'', AMOUNT :''+ isnull(cast(a.AMOUNT as varchar),''NULL'')+''.  
    '', ''Please check your data''   
    from '+@temptablename + ' a where a.AMOUNT=0   
     or len(ltrim(rtrim(a.REFNO)))=0') 
     
   --Check for Date Validation  
    EXEC('insert into #import_status select a.TEMP_ID,'''+ @process_id+''',''Error'',''Import Data'','''+@tablename+''',''Data Error'',  
    ''Ref No :''+ isnull(ltrim(rtrim(a.REFNO)),''NULL'')+'', AMOUNT :''+ isnull(cast(a.AMOUNT as varchar),''NULL'')+  
    ''. Invalid Date Format. Please use standard date format (mm/dd/yyyy)'', ''Invalid Date Format ''   
    from '+@temptablename + ' a where ISDATE(a.[PAY_DATE])=0')  

   --Check validate Paid Date (new 2012-10-01 by Ranesh)
   exec('insert into #import_status select a.TEMP_ID,'''+ @process_id+''',''Error'',''Import Data'','''+@tablename+''',''Data Error'',  
   ''Data error for Refno :''+ isnull(ltrim(rtrim(a.REFNO)),''NULL'')+'', Paid Date :''+ isnull(cast(a.[PAY_DATE] as varchar),''NULL'')+''.  
    Paid Date should not be used future date'', ''Paid Date should not be used future date''   
    from '+@temptablename + ' a where DATEDIFF(dd,GETDATE(),a.[PAY_DATE])<0 ')
    
   --Check for TRN in MoneySend Comfirm date 
   exec('insert into #import_status select a.TEMP_ID,'''+ @process_id+''',''Error'',''Import Data'','''+@tablename+''',''Data Error'',  
   ''Ref No :''+ isnull(ltrim(rtrim(a.REFNO)),''NULL'')+'', AMOUNT :''+ isnull(cast(a.AMOUNT as varchar),''NULL'')+  
   ''. Trasaction Not Found for Payment'', ''Trasaction Not Found for Payment''   
    FROM '+@temptablename + ' a LEFT OUTER JOIN moneysend m with(nolock) on dbo.encryptdb(ltrim(rtrim(a.REFNO)))=m.refno  
    where DATEDIFF(dd,m.confirmdate,a.[PAY_DATE])>=0')
      
   --Check for TRN in MoneySend  
   exec('insert into #import_status select a.TEMP_ID,'''+ @process_id+''',''Error'',''Import Data'','''+@tablename+''',''Data Error'',  
   ''Ref No :''+ isnull(ltrim(rtrim(a.REFNO)),''NULL'')+'', AMOUNT :''+ isnull(cast(a.AMOUNT as varchar),''NULL'')+  
   ''. Trasaction Not Found for Payment'', ''Trasaction Not Found for Payment''   
    from '+@temptablename + ' a left outer join moneysend m with(nolock) on dbo.encryptdb(ltrim(rtrim(a.REFNO)))=m.refno  
    where m.refno is NULL')  
  
   --Check for TRN PaymentStatus in MoneySend   
   exec('insert into #import_status select a.TEMP_ID,'''+ @process_id+''',''Error'',''Import Data'','''+@tablename+''',''Data Error'',  
   ''Ref No :''+ isnull(ltrim(rtrim(a.REFNO)),''NULL'')+'', AMOUNT :''+ isnull(cast(a.AMOUNT as varchar),''NULL'')+  
   ''. Trasaction Is in ''+m.TransStatus+'' Not Valid for Payment'', ''Trasaction Is in ''+m.TransStatus+'' Not Valid for Payment''   
    from '+@temptablename + ' a join moneysend m with(nolock) on dbo.encryptdb(ltrim(rtrim(a.REFNO)))=m.refno  
    where m.TransStatus<>''Payment''')  
  
   --Check for TRN STATUS in MoneySend   
   exec('insert into #import_status select a.TEMP_ID,'''+ @process_id+''',''Error'',''Import Data'','''+@tablename+''',''Data Error'',  
   ''Ref No :''+ isnull(ltrim(rtrim(a.REFNO)),''NULL'')+'', AMOUNT :''+ isnull(cast(a.AMOUNT as varchar),''NULL'')+  
   ''. Trasaction Is Already Paid'', ''Trasaction Is Already Paid''   
    from '+@temptablename + ' a join moneysend m with(nolock) on dbo.encryptdb(ltrim(rtrim(a.REFNO)))=m.refno  
    where m.status=''Paid''')  
  
   --Check for AMOUNT in MoneySend   
   exec('insert into #import_status select a.TEMP_ID,'''+ @process_id+''',''Error'',''Import Data'','''+@tablename+''',''Data Error'',  
   ''Ref No :''+ isnull(ltrim(rtrim(a.REFNO)),''NULL'')+'', AMOUNT :''+ isnull(cast(a.AMOUNT as varchar),''NULL'')+  
   ''. Payout Amount Did not Match; Not Valid for Payment'', ''Payout Amount Did not Match; Not Valid for Payment''   
    from '+@temptablename + ' a join moneysend m with(nolock) on dbo.encryptdb(ltrim(rtrim(a.REFNO)))=m.refno  
    where m.TotalRoundAmt<>a.AMOUNT')  
   --Check for EXPECTED_PAYOUTAGENTID in MoneySend   
   exec('insert into #import_status select a.TEMP_ID,'''+ @process_id+''',''Error'',''Import Data'','''+@tablename+''',''Data Error'',  
   ''Ref No :''+ isnull(ltrim(rtrim(a.REFNO)),''NULL'')+'', AMOUNT :''+ isnull(cast(a.AMOUNT as varchar),''NULL'')+  
   ''. Payout Agent Did not Match; Not Valid for Payment'', ''Payout agent Did not Match; Not Valid for Payment''   
    from '+@temptablename + ' a join moneysend m with(nolock) on dbo.encryptdb(ltrim(rtrim(a.REFNO)))=m.refno  
    where m.expected_payoutagentid<>'+@expected_payoutagentid)  
     
   -- delete from temp table all the invalid data  
   exec('delete '+@temptablename + ' from #import_status inner join '+@temptablename + ' a on  
   #import_status.temp_id=a.temp_id')  
  
   PRINT @sql  
   set @sql1='insert into temp_trn_csv_pay(tranno,refno,ReceiverName,TotalRoundAmt,  
   paidDate,paidBy,expected_payoutagentid,rBankID,rBankName,rBankBranch,digital_id_payout)  
   select tranno,m.refno,receiverName,TotalRoundAmt,PAY_DATE,'''+  
   @user_login_id+''','''+@expected_payoutagentid+''','''+@payout_branch_id+''','''+  
   @payout_agent_name+''','''+@payout_branch_name+''','''+@digital_id_payout+'''  
   from '+@temptablename + ' a join moneysend m with(nolock) on dbo.encryptdb(ltrim(rtrim(a.REFNO)))=m.refno'  
  
-- --Delete All Previous Entries  
 delete temp_trn_csv_pay where digital_id_payout=@digital_id_payout  
 print @sql1  
 exec(@sql1)   
  
 FinalStep:  
 declare @sql3 varchar(1000)  
 SET @sql3 = dbo.FNAProcessDeleteTbl(@temptablename)  
 --exec (@sql3)  
  declare @count int,@totalcount int  
  set @count=(select count(distinct temp_id) from #import_status)  
  set @totalcount=(select totcount from #temp_tot_count)  
  if @count>0  
  begin  
   if @totalcount>0  
    select @detail_errorMsg = cast(@totalcount-@count as varchar(100))+' Data imported Successfully out of '+cast(@totalcount as varchar(100))+'. Some Error found while importing. Please review Errors'  
   else  
    select @detail_errorMsg = cast(isNull(@totalcount,0) as varchar(100))+' Data imported Successfully. Some Error found while importing. Please review Errors'  
     
    insert into data_import_status(process_id,code,module,source,  
    type,[description],recommendation)   
    select @process_id,'Error','Import Data',@tablename,'Data Error',@detail_errorMsg,'Please Check your data'  
      
    insert into data_import_status_detail(process_id,source,  
    type,[description])   
    select @process_id,@tablename,type,[description]  from #import_status where process_id=@process_id  
     
  end  
  else  
  begin  
   select @detail_errorMsg = cast(@totalcount-@count as varchar(100))+' Data imported Successfully out of '+cast(@totalcount as varchar(100))  
     
   insert into data_import_status(process_id,code,module,source,  
    type,[description],recommendation)   
    select @process_id,'Success','Import Data',@tablename,'Data Error',@detail_errorMsg,''  
  end  
  
  
  
  