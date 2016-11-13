drop proc spa_Export_NIB
go 
--spa_Export_NIB '20100029','Cash Pay','anoop','30106362','dc','2343333455555','NIB'  
CREATE proc [dbo].[spa_Export_NIB]  
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
declare @correspond_company_nick varchar(50)  
  
------------------------------------------------------------------------------------------------ 
	set @correspond_company_nick='PRABHU'   
	set @agent_id='20100203'    
------------------------------------------------------------------------------------------------
  
declare @desc varchar(1000)  
declare @ledger_tabl varchar(100), @sql varchar(5000)  
  
declare @expected_payoutagentid varchar(50),@rBankID varchar(50),        
@rBankName varchar(200), @rBankBranch varchar(200), @GMT_Date datetime,@cover_fund money,@payout_fund_limit char(1)        
select top 1 @expected_payoutagentid=a.agentcode,@rBankID=b.agent_branch_code,@rBankName=a.companyName, @rBankBranch=b.Branch,        
@GMT_Date=dateadd(mi,isNUll(gmt_value,345),getutcdate()),@cover_fund=a.currentBalance-isNull(Account_No_IB,0)        
from agentdetail a WITH(NOLOCK) join agentbranchdetail b WITH(NOLOCK) on a.agentcode=b.agentcode 
where b.agentcode=@agent_id    
 --and case when @branch_id is not null then agent_branch_code else '1' end = isnull(@branch_id,'1')      
order by isHeadOffice    
  
declare @alt_label varchar(50)  
  
begin transaction  
  
set @ledger_tabl=dbo.FNAProcessTbl(@batch_id,@login_user_id,@process_id)  
set @sql='  
CREATE TABLE '+ @ledger_tabl+'(  
 [File Name] varchar(50),  
 [Header] varchar(50),  
 [Data Charecter] char(1),  
 [Transaction Reference] varchar(16),  
 [Transaction Date] varchar(50),  
 [Transaction Amount] money ,  
 [Transfer Currency] varchar(5),  
 [Remitter Name] varchar(100) NULL,  
 [Remittance Option] [varchar] (100)  NULL ,  
 [Beneficiary Name] varchar(100) NULL,  
 [Beneficiary Bank Code] varchar(100) NULL ,  
 [Beneficiary Branch Name] varchar(100) NULL ,  
 [Beneficiary Account No.] varchar(100) NULL ,  
 [Beneficiary Address] varchar(105) NULL ,  
 [Beneficiary City] varchar(100) NULL ,   
 [Beneficiary Phone No.] varchar(100),  
 [Beneficiary ID] varchar(100),  
 [Remarks] varchar(105),  
 [Footer] varchar(100)  
) ON [PRIMARY]'  
print (@sql)  
exec (@sql)  
declare @total_row int  
set @sql=' insert '+ @ledger_tabl+'([Data Charecter],[Transaction Reference],[Transaction Date],[Transaction Amount],  
[Transfer Currency],[Remitter Name],[Remittance Option],[Beneficiary Name],  
[Beneficiary Bank Code],[Beneficiary Branch Name],[Beneficiary Account No.],  
[Beneficiary Address],[Beneficiary City],[Beneficiary Phone No.],[Beneficiary ID],[Remarks])

select ''D'' [Data Charecter],dbo.decryptdb(refno) [Transaction Reference],replace(convert(varchar,cast(confirmDate as datetime),102),''.'','''') [Transaction Date],
totalRoundAmt [Transaction Amount],receiveCType [Transfer Currency],senderName [Remitter Name],
case when paymentType=''Cash Pay'' then ''Cash Remittance'' when paymentType=''Bank Transfer'' then ''Remittance To Account'' 
else ''IBFT'' end [Remittance Option],ReceiverName [Beneficiary Name],
CASE WHEN paymentType in (''Cash Pay'',''Bank Transfer'') then ''59'' else isNULL(ben_bank_id,'''') end [Beneficiary Bank Code],  
CASE WHEN paymentType in (''Cash Pay'',''Bank Transfer'') then b.branch else rbankACType end [Beneficiary Branch Name],  
rBankACNo [Beneficiary Account No.],case when paymentType=''Cash Pay'' then NULL else left(b.address,104) end [Beneficiary Address],
b.city [Beneficiary City],isNULL(receiver_mobile,'''') [Beneficiary Phone No.],NULL [Beneficiary ID],NULL [Remarks]  
from moneysend m WITH(NOLOCK) LEFT OUTER JOIN agentbranchdetail b WITH(NOLOCK) on m.rBankID=b.agent_branch_code  
where expected_payoutagentid='''+ @agent_id +''' and status=''Un-Paid'' and Transstatus = ''Payment'' and is_downloaded is null '  
if @paymentType is not null  
 set @sql=@sql+' and paymentType = '''+@paymentType+''''  
set @sql=@sql+' order by confirmDate'  
print(@sql)  
exec(@sql)  
set @total_row=@@rowcount 
------------------------------------------------------------------------------------------------------------------------------------------------------
SET @sql = '
			UPDATE moneysend set is_downloaded=''y'',
								 downloaded_by='''+ @login_user_id + ''',
								 downloaded_ts=dbo.getDateHO(GETUTCDATE())
			FROM moneysend m with(nolock) 
			JOIN ' + @ledger_tabl+ ' t on dbo.encryptdb(t.[Transaction Reference])=m.refno 
			where m.expected_payoutagentid='''+ @agent_id +''''
EXEC (@sql) 
------------------------------------------------------------------------------------------------------------------------------------------------------
  
if @total_row>0  
begin  
declare @file_name varchar(100)  
declare @header varchar(100)  
declare @footer varchar(100)  
declare @total_amount varchar(50)  
declare @row_count_var varchar(5)  
set @row_count_var=cast(@total_row as varchar)  
--print @row_count_var  
create table #temp(  
total_amount varchar(15)  
)  
  
exec('insert into #temp(total_amount)  
select cast(sum([Transaction Amount]) as varchar) from '+@ledger_tabl)  
  
select @total_amount=total_amount from #temp  
  
declare @file_count varchar(50)  
SET @file_count=dbo.FNAExportSequenceNumber(@agent_id)
  
set @file_name=@correspond_company_nick+'_'+replace(convert(varchar,cast(getdate() as datetime),102),'.','')+'_'+left('000000000000',5-len(@file_count))+@file_count  
set @header='H|'+@row_count_var+'|'+@total_amount+'|'+replace(convert(varchar,cast(getdate() as datetime),102),'.','')+'|NIB Bank'  
set @footer='F|'+@row_count_var+'|'+@total_amount+'|'+replace(convert(varchar,cast(getdate() as datetime),102),'.','')+'|'+@correspond_company_nick  
  
exec('update '+ @ledger_tabl+' set [File Name]='''+@file_name+''',Header='''+@header+''',[Footer]='''+@footer+'''')  
  
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
delete [temp_trn_csv_pay] where digital_id_payout=@ditital_id  
  
set @sql='INSERT INTO [temp_trn_csv_pay]  
([tranno],[refno],[ReceiverName],[TotalRoundAmt],[paidDate],[paidBy],[expected_payoutagentid],  
[rBankID],[rBankName],[rBankBranch],[digital_id_payout])  
select tranno,refno,receiverName,totalRoundAmt,'''+convert(varchar,@GMT_Date,120)+''','''+@login_user_id+''',  
'''+@agent_id+''','''+@rBankID+''','''+@rBankName+''','''+@rBankBranch+''','''+@ditital_id+'''   
from '+ @ledger_tabl +' t join moneysend m with (nolock) on dbo.encryptDB(t.[Transaction Reference])=m.refno'  
print @sql  
exec(@sql)  
COMMIT transaction  
--print ('spa_make_bulk_payment_csv '''+@ditital_id+''',NULL,''y''')  
exec ('spa_make_bulk_payment_csv '''+@ditital_id+''',NULL,''y''')  
declare @url_desc varchar(500)  
set @url_desc='paymentType='+isNUll(@paymentType,'')  
 set @desc ='NIB BANK LTD Download <u>'+ isNUll(@paymentType,'ALL') +'</u> is completed.  TXN Found:' + cast(isNUll(@total_row,0) as varchar)  
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
 select -1,@desc,'export_NIB','SQL',@desc,'SQL','SP',@ditital_id,getdate()  
 select 'ERROR','1050','Error Please try again'  
  
end catch 