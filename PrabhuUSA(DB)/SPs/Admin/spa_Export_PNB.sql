
/****** Object:  StoredProcedure [dbo].[spa_Export_PNB]    Script Date: 11/24/2014 13:15:36 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spa_Export_PNB]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[spa_Export_PNB]
GO

/****** Object:  StoredProcedure [dbo].[spa_Export_PNB]    Script Date: 11/24/2014 13:15:36 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


--spa_Export_NIB '20100029','Cash Pay','anoop','30106362','dc','2343333455555','NIB'  
CREATE proc [dbo].[spa_Export_PNB]  
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
	set @agent_id='20100064'    
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
 [drAcct] char(16),  
 [tranAmt] char(20),  
 [ifscCode] char(12),  
 [tranParticular] char(20),  
 [benCustAcctId] char(35),  
 [benCustNamet] char(40) ,  
 [benCustAddr1] char(35),  
 [sendRecvInfo1] char(20),  
 [sendRecvInfo2] char(20),
 [file Name] varchar(50)
 
) ON [PRIMARY]'  
print (@sql)  
exec (@sql)  
declare @total_row int  
set @sql=' insert '+ @ledger_tabl+'([drAcct],[tranAmt],[ifscCode],[tranParticular],  
[benCustAcctId],[benCustNamet],[benCustAddr1],[sendRecvInfo1],  
[sendRecvInfo2])

select substring(isnull(rBankACNo,''''),1,16) drAcct,
substring(cast(TotalRoundAmt as varchar),1,20) tranAmt,
substring(isnull(rBankAcType,''''),1,12) AS [ifscCode],
substring(isnull(reason_for_remittance,''''),1,20) tranParticular,
substring(dbo.decryptdb(refno),1,35) benCustAcctId,
substring(ReceiverName,1,40) benCustNamet,
substring(isnull(ReceiverAddress,''''),1,35) benCustAddr1,
substring(SenderName,1,20) sendRecvInfo1,
substring(isnull(SenderAddress,''''),1,20) sendRecvInfo2
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
			UPDATE moneysend set status=''Post'',
								 is_downloaded=''y'',
								 downloaded_by='''+ @login_user_id + ''',
								 downloaded_ts=dbo.getDateHO(GETUTCDATE())
			FROM moneysend m with(nolock) 
			JOIN ' + @ledger_tabl+ ' t on dbo.encryptdb(t.[benCustAcctId])=m.refno 
			where m.expected_payoutagentid='''+ @agent_id +''''
			PRINT @sql
EXEC (@sql) 
------------------------------------------------------------------------------------------------------------------------------------------------------

if @total_row>0  
begin  
declare @file_name varchar(100)    
--declare @total_amount varchar(50)  
declare @row_count_var varchar(5)  
set @row_count_var=cast(@total_row as varchar)  
--print @row_count_var  
create table #temp(  
total_amount varchar(15)  
)  

--exec('insert into #temp(total_amount)  
--select cast(sum([tranAmt]) as varchar) from '+@ledger_tabl)  
--  PRINT 'i5'
--select @total_amount=total_amount from #temp  
  
declare @file_count varchar(50)  
SET @file_count=dbo.FNAExportSequenceNumber(@agent_id)
  
set @file_name=@correspond_company_nick+'_'+replace(convert(varchar,cast(getdate() as datetime),102),'.','')+'_'+left('000000000000',5-len(@file_count))+@file_count  

  
exec('update '+ @ledger_tabl+' set [File Name]='''+@file_name+'''')  
  
end  
  
declare @total_row_pending int,@total_amount_pending money    
COMMIT transaction  
--print ('spa_make_bulk_payment_csv '''+@ditital_id+''',NULL,''y''')  
--exec ('spa_make_bulk_payment_csv '''+@ditital_id+''',NULL,''y''')  
declare @url_desc varchar(500)  
set @url_desc='paymentType='+isNUll(@paymentType,'')  
 set @desc ='PNB  Download <u>'+ isNUll(@paymentType,'ALL') +'</u> is completed.  TXN Found:' + cast(isNUll(@total_row,0) as varchar)  
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
  
   EXEC  spa_message_board 'u', @login_user_id,  
    NULL, @batch_id,  
    '<font color="red">Some error occured please try again!!</font>', 'p', @process_id,null,null  
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
GO


