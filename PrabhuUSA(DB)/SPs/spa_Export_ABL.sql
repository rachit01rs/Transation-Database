DROP proc [dbo].[spa_Export_ABL]  
go
--spa_Export_ABL '20100023',NULL,'shiva',NULL,':','755071247','ABL'  
  
CREATE proc [dbo].[spa_Export_ABL]  
@agent_id varchar(50),  
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
declare @partnerCode varchar(5)  
set @partnerCode='0352'  
  
declare @expected_payoutagentid varchar(50),@rBankID varchar(50),  
@rBankName varchar(200), @rBankBranch varchar(200), @GMT_Date datetime,@cover_fund money,@payout_fund_limit char(1) 
SET @expected_payoutagentid = '20100023'--Local--'20100135'--UAT--'20100270'--LIVE
set @agent_id=@expected_payoutagentid 
select @expected_payoutagentid=a.agentcode,@rBankID=b.agent_branch_code,@rBankName=a.companyName, @rBankBranch=b.Branch,  
@GMT_Date=dateadd(mi,isNUll(gmt_value,345),getutcdate()),@cover_fund=a.currentBalance-isNull(Account_No_IB,0)  
from agentdetail a join agentbranchdetail b on a.agentcode=b.agentcode where a.agentcode=@expected_payoutagentid 
ORDER BY b.isheadoffice desc
    
  
begin transaction  
  
set @ledger_tabl=dbo.FNAProcessTbl(@batch_id,@login_user_id,@process_id)  
set @sql='  
CREATE TABLE '+ @ledger_tabl+'(  
 [Header] varchar(26),  
 [Reference No] varchar(25),  
 [Payment Mode] char(1),  
 [Local Currency Amount] bigint,  
 [Remitter Name] varchar(100),  
 [Currency Id] char(3),  
 [Transaction Type] char(2),  
 [Beneficiary Name] [varchar] (100),  
 [Remittance Purpose Id] char(2),  
 [Beneficiary Bank] varchar(15),  
 [Beneficiary A/C No] varchar (50) NULL,  
 [Beneficiary Branch Code] varchar(10) NULL ,  
 [Beneficiary Address] varchar(90) NULL,  
 [Beneficiary City Code] varchar(3) NULL,   
 [Beneficiary CNIC No] varchar(20) NULL,  
 [Beneficiary Branch Name] varchar(30) NULL,  
 [Beneficiary Branch Address] varchar(100) NULL,  
 [Beneficiary Postal Code] varchar(10) NULL,  
 [Beneficiary Country] varchar(5) NULL,  
 [Beneficiary Phone] varchar(20) NULL,  
 [Beneficiary Mobile] varchar(11) NULL,  
 [Beneficiary Email] varchar(50) NULL,  
 [Beneficiary Message] varchar(300) NULL,  
 [Secret Key] varchar(10) NULL,  
 [Remitter City Code] varchar(10) NULL,  
 [Remitter Country] varchar(10) NULL,  
 [Remitter Address] varchar(200) NULL,  
 [Remitter Phone] varchar(50) NULL,  
 [Remitter Mobile] varchar(50) NULL,  
 [Remitter Email] varchar(50) NULL,  
 [Remittance Charges] varchar(10) NULL,  
 [Remittance Remarks] varchar(300) NULL,  
 [Beneficiary Branch City] varchar(100) NULL,  
 [Beneficiary Account Title] varchar(100) NULL  
) ON [PRIMARY]'  
print (@sql)  
exec (@sql)  
declare @total_row int  
set @sql=' insert '+ @ledger_tabl+'([Reference No],[Payment Mode],[Local Currency Amount],[Remitter Name]  
,[Currency Id],[Transaction Type],[Beneficiary Name],[Remittance Purpose Id],[Beneficiary Bank]  
,[Beneficiary A/C No],[Beneficiary Branch Code],[Beneficiary Address],[Beneficiary City Code],[Beneficiary CNIC No]  
,[Beneficiary Branch Name],[Beneficiary Branch Address],[Beneficiary Postal Code],[Beneficiary Country],[Beneficiary Phone]  
,[Beneficiary Mobile],[Beneficiary Email],[Beneficiary Message],[Secret Key],[Remitter City Code],[Remitter Country]  
,[Remitter Address],[Remitter Phone],[Remitter Mobile],[Remitter Email],[Remittance Charges],[Remittance Remarks]  
,[Beneficiary Branch City],[Beneficiary Account Title])  
  
select top 9999 dbo.decryptdb(refno),  
case when paymentType=''Cash Pay'' then ''P'' when paymentType=''Bank Transfer'' then ''D'' else ''C'' end,floor(totalRoundAmt),senderName  
,receiveCType,''CR'',receiverName,''01'',case when paymentType=''Account Deposit to Other Bank'' then ben_bank_id else ''ABL'' end  
,rBankACNo,case when paymentType=''Account Deposit to Other Bank'' then NULL else b.ext_branch_code end,  
case when paymentType=''Account Deposit to Other Bank'' then NULL else left(receiverAddress,90) end  
,NULL,case when paymentType=''Account Deposit to Other Bank'' then NULL else ''0000000000000'' end ,  
left(case when paymentType=''Account Deposit to Other Bank'' then rBankACType else b.branch end,30),  
case when paymentType=''Account Deposit to Other Bank'' then left(receiverAddress,100) else left(b.address,100) end,  
NULL,''PAK'',left(receiverPhone,20),left(receiver_mobile,11),ISNULL(senderfax+'':''+LTRIM(RTRIM(senderPassport)),''''),NULL,NULL,NULL,case when senderCountry=''Malaysia'' then  
''MAL'' when senderCountry=''Qatar'' then ''QAT'' else ''USA'' end,NULL,NULL,NULL,NULL,NULL,NULL,  
NULL,receiverName  
from moneysend m WITH ( NOLOCK )  left outer join agentbranchdetail b WITH ( NOLOCK ) on m.rBankID=b.agent_branch_code
JOIN agentdetail a WITH(NOLOCK) ON a.agentCode=m.agentid   
where ISNULL(a.disable_payout,''n'')<>''y'' AND expected_payoutagentid='''+ @agent_id +''' and status=''Un-Paid'' and (lock_status=''unlocked'' or lock_status is NULL)   
and Transstatus = ''Payment'' and is_downloaded is null  
'  
  
if @paymentType is not null  
 set @sql=@sql+' and paymentType = '''+@paymentType+''''  
set @sql=@sql+' order by confirmDate'  
print(@sql)  
exec(@sql)  
  
set @total_row=@@rowcount  
  
if @total_row>0  
begin  
  
declare @header varchar(30)  
declare @total_amount varchar(50)  
declare @row_count_var varchar(5)  
set @row_count_var=cast(@total_row as varchar)  
print @row_count_var  
create table #temp(  
total_amount varchar(15)  
)  
  
exec('insert into #temp(total_amount)  
select cast(floor(sum([Local Currency Amount])) as varchar) from '+@ledger_tabl)  
  
select @total_amount=total_amount from #temp  
  
set @header=right(convert(varchar,getdate(),112),6)+left('0000',4-len(@row_count_var))+@row_count_var  
   +left('000000000000',12-len(@total_amount))+@total_amount+@partnerCode  
  
exec('update '+ @ledger_tabl+' set Header='''+@header+'''')  
  
end  
  
  
  
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
from '+ @ledger_tabl +' t join moneysend m with (nolock) on dbo.encryptDB(t.[Reference No])=m.refno JOIN agentdetail a WITH(NOLOCK) ON a.agentCode=m.agentid WHERE ISNULL(a.disable_payout,''n'')<>''y'''  
print @sql  
exec(@sql)  
COMMIT transaction  
print ('spa_make_bulk_payment_csv '''+@ditital_id+''',NULL,''y''')  
exec ('spa_make_bulk_payment_csv '''+@ditital_id+''',NULL,''y''')  
  
declare @url_desc varchar(500)  
set @url_desc='paymentType='+isNUll(@paymentType,'')  
 set @desc ='ALLIED BANK LIMITED  Download <u>'+ isNUll(@paymentType,'ALL') +'</u> is completed.  TXN Found:' + cast(isNUll(@total_row,0) as varchar)  
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
 select -1,@desc,'export_ALLIED_BANK','SQL',@desc,'SQL','SP',@ditital_id,getdate()  
 select 'ERROR','1050','Error Please try again'  
  
end catch