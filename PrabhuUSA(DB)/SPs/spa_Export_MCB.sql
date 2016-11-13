DROP PROC [dbo].[spa_Export_MCB]  
go
   
--spa_Export_National '20100029','Cash Pay','anoop','30106362','dc','2345333345345555','National'  
CREATE proc [dbo].[spa_Export_MCB]  
@agent_id varchar(50)=null,  
@paymentType varchar(50)=NULL,  
@login_user_id varchar(50),  
@branch_id varchar(50)=NULL,  
@ditital_id varchar(200)=NULL,  
@process_id varchar(150),  
@batch_Id varchar(100)=null  
as   
SET XACT_ABORT ON;  
BEGIN TRY  
  
declare @desc varchar(1000)  
declare @ledger_tabl varchar(100), @sql varchar(5000)  
 
declare  @expected_payoutagentid VARCHAR(50)
SET @expected_payoutagentid = '20100159'--Local--'20100135'--UAT--'20100270'--LIVE
set @agent_id=@expected_payoutagentid
 
  
declare @rBankID varchar(50),  
@rBankName varchar(200), @rBankBranch varchar(200), @GMT_Date datetime,@cover_fund money,@payout_fund_limit char(1)  
select top 1  @expected_payoutagentid=a.agentcode,@rBankID=b.agent_branch_code,@rBankName=a.companyName, @rBankBranch=b.Branch,  
@GMT_Date=dateadd(mi,isNUll(gmt_value,345),getutcdate()),@cover_fund=a.currentBalance-isNull(Account_No_IB,0)  
from agentdetail a join agentbranchdetail b on a.agentcode=b.agentcode where a.agentcode=@expected_payoutagentid ORDER BY b.isheadoffice desc
  
declare @alt_label varchar(50)  
if @paymentType='Cash Pay'  
 set @alt_label='XPIN Code'  
else  
 set @alt_label='Beneficiary Account Number'  
begin transaction  
  
set @ledger_tabl=dbo.FNAProcessTbl(@batch_id,@login_user_id,@process_id)  
set @sql='  
CREATE TABLE '+ @ledger_tabl+'(  
 [Unique Reference Number] varchar(20),  
 [Transaction Date] varchar(50),  
 [Remitter Name] varchar(100) ,  
 [Beneficiary Bank] varchar(200) NULL ,  
 [Beneficiary Name] varchar(200),  
 ['+@alt_label+'] varchar(200) NULL,  
 [Beneficiary Branch Code] [varchar] (200)  NULL ,  
 [Benficiary Branch Name] varchar(200) NULL,  
 [Beneficiary Address] varchar(200) NULL ,  
 [Amount] money,  
 [Beneficiary Contact No] varchar(200) NULL ,  
 [Remitter Address] varchar(500) NULL ,  
 [Remitter ID] varchar(200) NULL ,   
 [Payment Type] varchar(200)  
) ON [PRIMARY]'  
print (@sql)  
exec (@sql)  
declare @total_row int  
set @sql=' insert '+ @ledger_tabl+'([Unique Reference Number],[Transaction Date],[Remitter Name],  
[Beneficiary Bank],[Beneficiary Name],['+@alt_label+'],[Beneficiary Branch Code],[Benficiary Branch Name],  
[Beneficiary Address],[Amount],[Beneficiary Contact No],[Remitter Address],[Remitter ID],[Payment Type])  
  
select dbo.decryptdb(refno),convert(varchar,cast(confirmDate as datetime),101),senderName,  
case when paymentType in (''Cash Pay'',''Bank Transfer'') then ''MCB'' else ben_bank_name end,  
ReceiverName,case when paymentType in (''Cash Pay'') then dbo.decryptdb(refno) else rBankACNo end  
,b.ext_branch_code,b.Branch,isNULL(receiverAddress,'''')+'', ''+isNULL(receiverCity,''''),totalRoundAmt,  
isNULL(ReceiverPhone,'''')+'', ''+isNULL(receiver_mobile,''''),SenderAddress,senderPassport,paymentType   
from moneysend m WITH(NOLOCK) left outer join agentbranchdetail b WITH(NOLOCK) on m.rBankID=b.agent_branch_code 
  JOIN agentdetail a WITH(NOLOCK) ON a.agentCode=m.agentid 
where expected_payoutagentid='''+ @agent_id +''' and status=''Un-Paid'' and Transstatus = ''Payment'' and is_downloaded is null  AND ISNULL(a.disable_payout,''n'')<>''y'''  
if @paymentType is not null  
 set @sql=@sql+' and paymentType = '''+@paymentType+''''  
set @sql=@sql+' order by confirmDate'  
print(@sql)  
exec(@sql)  
set @total_row=@@rowcount  
  
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
delete [temp_trn_csv_pay] where digital_id_payout=@ditital_id  
  
set @sql='INSERT INTO [temp_trn_csv_pay]  
([tranno],[refno],[ReceiverName],[TotalRoundAmt],[paidDate],[paidBy],[expected_payoutagentid],  
[rBankID],[rBankName],[rBankBranch],[digital_id_payout])  
select tranno,refno,receiverName,totalRoundAmt,'''+convert(varchar,@GMT_Date,120)+''','''+@login_user_id+''',  
'''+@agent_id+''','''+@rBankID+''','''+@rBankName+''','''+@rBankBranch+''','''+@ditital_id+'''   
from '+ @ledger_tabl +' t join moneysend m with (nolock) on dbo.encryptDB(t.[Unique Reference Number])=m.refno
  JOIN agentdetail a WITH(NOLOCK) ON a.agentCode=m.agentid WHERE ISNULL(a.disable_payout,''n'')<>''y'''  
print @sql  
exec(@sql)  
  
print ('spa_make_bulk_payment_csv '''+@ditital_id+''',NULL,''y''')  
exec ('spa_make_bulk_payment_csv '''+@ditital_id+''',NULL,''y''')  
declare @url_desc varchar(500)  
set @url_desc='paymentType='+isNUll(@paymentType,'')  
 set @desc ='MCB Download <u>'+ isNUll(@paymentType,'ALL') +'</u> is completed.  TXN Found:' + cast(isNUll(@total_row,0) as varchar)  
 set @desc=@desc +' Local Time:'+ convert(varchar,@GMT_Date,120)  
  
if @total_row_pending is not null and @total_amount_pending is not null  
 set @desc=@desc +'<br><i>Cover fund not enough(Pending:'+ cast(@total_row_pending as varchar) +' AMT:'+ cast(@total_amount_pending as varchar) +')</i>'  
  
print @desc  
 EXEC  spa_message_board 'u', @login_user_id,  
    NULL, @batch_id,  
    @desc, 'c', @process_id,null,@url_desc  
  
COMMIT transaction  
end try  
begin catch  
  
if @@trancount>0   
 rollback transaction  
 ------------------------------------------------------------------------ 
  set @desc= '<font color=red>Issues arised while exporting Please Try again after a while !!</font>'  
   EXEC  spa_message_board 'u', @login_user_id,  
    NULL, @batch_id,  
    @desc, 'p', @process_id,null,@url_desc
   ---------------------------------------------------------------------  
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
 select -1,@desc,'export_MCB','SQL',@desc,'SQL','SP',@ditital_id,getdate()  
 select 'ERROR','1050','Error Please try again'  
  
end catch  
  
  
  