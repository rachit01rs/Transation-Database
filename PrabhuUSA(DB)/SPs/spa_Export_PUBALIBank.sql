DROP proc [dbo].[spa_Export_PUBALIBank]    
go
--spa_Export_PUBALIBank '20100001','Bank Transfer','deepen',NULL,':','1234555','PBBL'    
CREATE proc [dbo].[spa_Export_PUBALIBank]    
@agent_id varchar(50),    
@paymentType varchar(50)=NULL,    
@login_user_id varchar(50),    
@branch_id varchar(50),    
@ditital_id varchar(200)=NULL,    
@process_id varchar(150),    
@batch_Id varchar(100)=null    
as     
SET XACT_ABORT ON;    
BEGIN TRY    
    
declare @desc varchar(1000)    
declare @ledger_tabl varchar(100), @sql varchar(5000)    
    
declare @expected_payoutagentid varchar(50),@rBankID varchar(50),    
@rBankName varchar(200), @rBankBranch varchar(200), @GMT_Date datetime,@cover_fund money,@payout_fund_limit char(1)    
select @expected_payoutagentid=a.agentcode,@rBankID=b.agent_branch_code,@rBankName=a.companyName, @rBankBranch=b.Branch,    
@GMT_Date=dateadd(mi,isNUll(gmt_value,345),getutcdate()),@cover_fund=a.currentBalance-isNull(Account_No_IB,0)    
from agentdetail a join agentbranchdetail b on a.agentcode=b.agentcode where agent_branch_code=@branch_id    
    
begin transaction    
    
set @ledger_tabl=dbo.FNAProcessTbl(@batch_id,@login_user_id,@process_id)    
--set @sql='    
--CREATE TABLE '+ @ledger_tabl+'(    
-- [remittance_no] varchar(20),    
-- [remitter_name] varchar(100),    
-- [benifi_name] [varchar] (100),    
-- [benifi_acc_type] [varchar](10),    
-- [benifi_acc_no] varchar (50) NULL,    
-- [bank_code] varchar(10) NULL ,    
-- [bank_name] varchar(100) NULL,    
-- [branch_code] varchar(10) NULL,     
-- [branch_name_address] varchar(150) NULL,    
-- [benifi_phone] varchar(100) NULL,    
-- [issue_date] varchar(40) NULL,    
-- [amount] money NULL,    
-- [remark] varchar(300) NULL    
--) ON [PRIMARY]'    
set @sql='    
CREATE TABLE '+ @ledger_tabl+'(     
 [SL No.] int identity(1,1),    
 [Ref No.] varchar(50),    
 [BNAM] varchar(200),    
 [PBL BR. Code] varchar(50),    
 [A/C TYPE] varchar(200),    
 [A/C No.] varchar(200),    
 [BBNKNAME] varchar(200),    
 [BBRNAM] varchar(200),    
 [BBRDIST] varchar(200),    
 [TTAMT] money,    
 [RNAM] varchar(200)    
)'    
print (@sql)    
exec (@sql)    
declare @total_row int    
set @sql=' INSERT '+ @ledger_tabl+'([Ref No.],[BNAM],[PBL BR. Code],[A/C TYPE],    
[A/C No.],[BBNKNAME],[BBRNAM],[BBRDIST],[TTAMT],[RNAM])    
    
 SELECT dbo.decryptdb(refno),receiverName,b.ext_branch_code,''SB'',rBankACNo,  
 CASE WHEN paymentType=''Bank Transfer'' THEN ''PUBALI Bank Limited'' ELSE ben_bank_name END [bank name],
 CASE WHEN paymentType=''Bank Transfer'' THEN b.branch ELSE rBankAcType END [branch],    
 b.city,totalRoundAmt,senderName    
 FROM moneysend m with (nolock) LEFT OUTER JOIN agentbranchdetail b with (nolock) on m.rBankID=b.agent_branch_code JOIN agentdetail a WITH(NOLOCK) ON a.agentCode=m.agentid     
 WHERE ISNULL(a.disable_payout,''n'')<>''y'' AND expected_payoutagentid='''+ @agent_id +''' and status=''Un-Paid'' and (lock_status=''unlocked'' or lock_status is NULL)     
 and Transstatus = ''Payment'' and is_downloaded IS NULL     
'    
--select * from agentbranchdetail where agentcode='20100119'    
--select * from agentdetail where companyName like 'PUBALI%'    
if @paymentType is not null    
 set @sql=@sql+' and paymentType = '''+@paymentType+''''    
set @sql=@sql+' order by confirmDate'    
print(@sql)    
exec(@sql)    
    
set @total_row=@@rowcount    
    
declare @total_amount money    
create table #temp_total_amount    
(    
total_amount money    
)    
    
set @sql='    
insert #temp_total_amount(total_amount)    
select sum([TTAMT]) from '+ @ledger_tabl+''    
    
exec(@sql)    
    
select @total_amount= total_amount from #temp_total_amount    
    
declare @total_row_pending int,@total_amount_pending money    
--    
--create table #temp_cover_fund(    
-- sno int identity(1,1),    
-- refno varchar(20),    
-- totalroundamt money)    
--    
--create table #total_row_pending(    
-- total_row int,    
-- totalroundamt money    
-- )    
--    
--create table #total_row_apply(    
-- total_row int    
--)    
--    
--if @payout_fund_limit='y'    
--begin    
--    
--set @sql='    
-- insert #temp_cover_fund(refno,totalroundamt)    
-- select [Unique Reference Number],Amount from '+ @ledger_tabl+'     
-- order by Remittance_Date,Amount'    
--exec(@sql)    
--    
-- select refno into #temp_TXN_apply    
-- from #temp_cover_fund t    
-- where (select sum(totalroundamt) from #temp_cover_fund where sno<=t.sno) <= @cover_fund    
--    
--set @sql='     
-- insert #total_row_pending(total_row,totalroundamt)    
-- select count(*),sum(Amount)    
-- from '+ @ledger_tabl+'  t left outer join #temp_TXN_apply a    
-- on t.[Unique Reference Number]=a.refno    
-- where a.refno is NULL'    
--exec(@sql)    
-- select @total_row_pending=total_row,@total_amount_pending=totalroundamt from #total_row_pending    
--set @sql='    
-- delete  '+ @ledger_tabl+'    
-- from  '+ @ledger_tabl+'  t left outer join #temp_TXN_apply a    
-- on t.[Unique Reference Number]=a.refno    
-- where a.refno is NULL'    
--exec(@sql)    
--set @sql='    
-- insert #total_row_apply(total_row)    
-- select count(*) from '+ @ledger_tabl+''    
--exec(@sql)    
-- select @total_row=total_row from #total_row_apply    
--end    
----set @total_row=@@rowcount    
    
----############    
    
delete [temp_trn_csv_pay] where digital_id_payout=@ditital_id    
    
set @sql='INSERT INTO [temp_trn_csv_pay]    
([tranno],[refno],[ReceiverName],[TotalRoundAmt],[paidDate],[paidBy],[expected_payoutagentid],    
[rBankID],[rBankName],[rBankBranch],[digital_id_payout])    
select tranno,refno,receiverName,totalRoundAmt,'''+convert(varchar,@GMT_Date,120)+''','''+@login_user_id+''',    
'''+@agent_id+''','''+@rBankID+''','''+@rBankName+''','''+@rBankBranch+''','''+@ditital_id+'''     
from '+ @ledger_tabl +' t with (nolock) join moneysend m with (nolock) on dbo.encryptDB(t.[Ref No.])=m.refno JOIN agentdetail a WITH(NOLOCK) ON a.agentCode=m.agentid WHERE ISNULL(a.disable_payout,''n'')<>''y'''    
print @sql    
exec(@sql)    
COMMIT transaction    
print ('spa_make_bulk_payment_csv '''+@ditital_id+''',NULL,''y''')    
exec ('spa_make_bulk_payment_csv '''+@ditital_id+''',NULL,''y''')    
    
declare @url_desc varchar(500)    
set @url_desc='paymentType='+isNUll(@paymentType,'')    
 set @desc ='PUBALI BANAK LIMITED  Download <u>'+ isNUll(@paymentType,'ALL') +'</u> is completed.  TXN Found:' + cast(isNUll(@total_row,0) as varchar) +'  Total Amount: '+cast(isNUll(@total_amount,0) as varchar)    
 set @desc=@desc +' Local Time:'+ convert(varchar,@GMT_Date,120)    
    
if @total_row_pending is not null and @total_amount_pending is not null    
 set @desc=@desc +'<br><i>Cover fund not enough(Pending:'+ cast(@total_row_pending as varchar) +' AMT:'+ cast(@total_amount_pending as varchar) +')</i>'    
    
print @desc    
 EXEC  spa_message_board 'u', @login_user_id,    
    NULL, @batch_id,    
    @desc, 'c', @process_id,null,@url_desc    
    
end try    
begin catch    
    
if @@trancount>0     
 rollback transaction    
    
     
 set @desc='SQL Error found:  (' + ERROR_MESSAGE() + ')'    
     
     
 INSERT INTO [error_info]    
   ([ErrorNumber]    
           ,[ErrorDesc]    
           ,[Script]    
           ,[ErrorScript]    
           ,[QueryString]    
           ,[ErrorCategory]    
           ,[ErrorSource]    
           ,[IP]    
           ,[error_date])    
 select -1,@desc,'spa_Export_PUBALIBank','SQL',@desc,'SQL','SP',@ditital_id,getdate()    
 select 'ERROR','1050','Error Please try again'    
    
end catch 