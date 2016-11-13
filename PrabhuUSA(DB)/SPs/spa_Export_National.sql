DROP proc spa_Export_National
GO  
--spa_Export_National '20100029','Cash Pay','anoop','30106362','dc','2345333345345555','National'  
CREATE proc [dbo].[spa_Export_National]  
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
@GMT_Date=dateadd(mi,isNUll(gmt_value,345),getutcdate()),@cover_fund=a.currentBalance-isNull(Account_No_IB,0),@payout_fund_limit=payout_fund_limit  
from agentdetail a join agentbranchdetail b on a.agentcode=b.agentcode where agent_branch_code=@branch_id  
  
begin transaction  
  
set @ledger_tabl=dbo.FNAProcessTbl(@batch_id,@login_user_id,@process_id)  
set @sql='  
CREATE TABLE '+ @ledger_tabl+'(  
 Ext_Code varchar(2),  
 Bank_Code varchar(50),  
 Remittance_No varchar(50) ,  
 Remittance_Date varchar(100) NULL ,  
 Amount money NULL ,  
 NBL_or_Other_Bank_Branch_Code varchar(50) NULL,  
 Other_Bank_Information [varchar] (50)  NULL ,  
 Beneficiary_Name varchar(150) NULL ,  
 ID_AccountNo varchar(150) NULL ,  
 Remitter varchar(50) NULL ,  
 Beneficiary_MobileNo varchar(50),  
 Payment_Type varchar(50)   
) ON [PRIMARY]'  
print (@sql)  
exec (@sql)  
declare @total_row int  
set @sql=' insert '+ @ledger_tabl+'(Ext_Code,Bank_Code,Remittance_No,Remittance_Date,Amount,  
NBL_or_Other_Bank_Branch_Code,Other_Bank_Information,Beneficiary_Name,ID_AccountNo,Remitter,Beneficiary_MobileNo,Payment_Type)  
select ''75'', case when paymentType in (''Cash Pay'',''Bank Transfer'') then ''100'' else ''99'' end,  
dbo.decryptdb(refno),convert(varchar,cast(confirmDate as datetime),101), totalRoundAmt,  
case when paymentType in (''Cash Pay'',''Bank Transfer'') then b.ext_branch_code else ''888'' end,  
case when paymentType in (''Cash Pay'',''Bank Transfer'') then ''NBL, ''+isNULL(rBankBranch,'''')+'' Branch'' else ben_bank_name+'', ''+rBankAcType+'' Branch'' end,  
ReceiverName,case when paymentType=''Cash Pay'' then ReceiverIDDescription+'': ''+ReceiverID else rBankACNo END ,  
senderName,receiver_mobile,paymentType   
from moneysend m  WITH ( NOLOCK ) left outer join agentbranchdetail b  WITH ( NOLOCK ) on m.rBankID=b.agent_branch_code 
JOIN agentdetail a WITH(NOLOCK) ON a.agentCode=m.agentid  
where ISNULL(a.disable_payout,''n'')<>''y'' AND expected_payoutagentid='''+ @agent_id +''' and status=''Un-Paid'' and Transstatus = ''Payment'' and is_downloaded is null '  
if @paymentType is not null  
 set @sql=@sql+' and paymentType = '''+@paymentType+''''  
set @sql=@sql+' order by confirmDate'  
print(@sql)  
exec(@sql)  
set @total_row=@@rowcount  
  
declare @total_row_pending int,@total_amount_pending money  
  
create table #temp_cover_fund(  
 sno int identity(1,1),  
 refno varchar(20),  
 totalroundamt money)  
  
create table #total_row_pending(  
 total_row int,  
 totalroundamt money  
 )  
  
create table #total_row_apply(  
 total_row int  
)  
  
if @payout_fund_limit='y'  
begin  
  
set @sql='  
 insert #temp_cover_fund(refno,totalroundamt)  
 select Remittance_No,Amount from '+ @ledger_tabl+'   
 order by Remittance_Date,Amount'  
exec(@sql)  
  
 select refno into #temp_TXN_apply  
 from #temp_cover_fund t  
 where (select sum(totalroundamt) from #temp_cover_fund where sno<=t.sno) <= @cover_fund  
  
set @sql='   
 insert #total_row_pending(total_row,totalroundamt)  
 select count(*),sum(Amount)  
 from '+ @ledger_tabl+'  t left outer join #temp_TXN_apply a  
 on t.Remittance_No=a.refno  
 where a.refno is NULL'  
exec(@sql)  
 select @total_row_pending=total_row,@total_amount_pending=totalroundamt from #total_row_pending  
set @sql='  
 delete  '+ @ledger_tabl+'  
 from  '+ @ledger_tabl+'  t left outer join #temp_TXN_apply a  
 on t.Remittance_No=a.refno  
 where a.refno is NULL'  
exec(@sql)  
set @sql='  
 insert #total_row_apply(total_row)  
 select count(*) from '+ @ledger_tabl+''  
exec(@sql)  
 select @total_row=total_row from #total_row_apply  
end  
--set @total_row=@@rowcount  
delete [temp_trn_csv_pay] where digital_id_payout=@ditital_id  
  
set @sql='INSERT INTO [temp_trn_csv_pay]  
([tranno],[refno],[ReceiverName],[TotalRoundAmt],[paidDate],[paidBy],[expected_payoutagentid],  
[rBankID],[rBankName],[rBankBranch],[digital_id_payout])  
select tranno,refno,receiverName,totalRoundAmt,'''+convert(varchar,@GMT_Date,120)+''','''+@login_user_id+''',  
'''+@agent_id+''','''+@rBankID+''','''+@rBankName+''','''+@rBankBranch+''','''+@ditital_id+'''   
from '+ @ledger_tabl +' t join moneysend m with (nolock) on dbo.encryptDB(t.Remittance_No)=m.refno JOIN agentdetail a WITH(NOLOCK) ON a.agentCode=m.agentid WHERE ISNULL(a.disable_payout,''n'')<>''y'''  
print @sql  
exec(@sql)  
  
print ('spa_make_bulk_payment_csv '''+@ditital_id+''',NULL,''y''')  
exec ('spa_make_bulk_payment_csv '''+@ditital_id+''',NULL,''y''')  
declare @url_desc varchar(500)  
set @url_desc='paymentType='+isNUll(@paymentType,'')  
 set @desc ='National Bank Download <u>'+ isNUll(@paymentType,'ALL') +'</u> is completed.  TXN Found:' + cast(isNUll(@total_row,0) as varchar)  
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
 select -1,@desc,'export_National','SQL',@desc,'SQL','SP',@ditital_id,getdate()  
 select 'ERROR','1050','Error Please try again'  
  
end catch  
  
  