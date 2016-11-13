/****** Object:  StoredProcedure [dbo].[spa_approved_AgentLimit_Exceed]    Script Date: 12/31/2014 15:01:11 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spa_approved_AgentLimit_Exceed]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[spa_approved_AgentLimit_Exceed]
GO


/****** Object:  StoredProcedure [dbo].[spa_approved_AgentLimit_Exceed]    Script Date: 12/31/2014 15:01:11 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



/*
** Database : PrabhuUsa
** Object : spa_approved_AgentLimit_Exceed
**
** Purpose : ----created spa_approved_AgentLimit_Exceed for 
** Author: Paribesh Jung Karki	
** Date:    10/10/2014
**
** Modifications:
** 
**			
** Execute Examples :
** 	spa_HelloPaisa_Customer_report 's','02/01/2013','2/14/2014','10000032','10010285','n' 
*/
--spa_approved_AgentLimit_Exceed @tranno='1933435',@user_id='admin',@agentid='20100181',@approve_by=''
CREATE PROCEDURE [dbo].[spa_approved_AgentLimit_Exceed]
	@tranno varchar(500),          
@user_id varchar(500),          
@agentid varchar(500)=null,          
@approve_by varchar(500)=null             

AS
begin try 
	
select Item  INTO #temp
from  dbo.SplitCommaSeperatedValues(@tranno)
 
if @agentid is null
begin
	select top 1 @agentid=agentid FROM moneySend m  with (NOLOCK) Join  #temp t  on m.tranno = t.Item 
end
 DECLARE @process_id varchar(150)
SET @process_id = REPLACE(newid(),'-','_')

 IF  exists (select m.tranno FROM moneySend m  with (NOLOCK) Join  #temp t  on m.tranno = t.Item 
  AND transstatus not in ('Halt') )          
BEGIN          
 select 'ERROR' status,'Transaction cannot be Approved. Please check the status !!' Msg          
 return          
end          
          
IF  exists (select m.tranno FROM moneySend m  with (NOLOCK) Join #temp t  on m.tranno = t.Item 
where transstatus='Payment' )          
BEGIN          
 select 'ERROR' status,'Transaction has already been Approved !!' Msg          
 return          
end          
       
IF  exists (select m.tranno FROM moneySend m with (NOLOCK) Join  #temp t  on m.tranno = t.Item 
where isIRH_trn='y' )          
BEGIN          
 select 'ERROR' status,'Transaction cannot be Approved ! This is partner system transaction !!' Msg          
 return          
end  

declare @approve_amount money,@current_balance money,@ccy varchar(50)
select @approve_amount=sum(paidAmt) from moneysend m with (NOLOCK) 
Join  #temp t  on m.tranno = t.Item 
select @current_balance=isNUll(limit,0)-isNUll(CurrentBalance,0),@ccy=currencyType from agentdetail where agentCode=@agentid
--select @current_balance,@approve_amount


if isNull(@current_balance,0)< @approve_amount 
BEGIN          
 select 'ERROR' status,'Transaction cannot be Approved. You do not have sufficient balance.! 
Total Amount of Transaction: '+ cast(@approve_amount as varchar) +' '+ @ccy +' and Your Balance is:'+ cast(@current_balance as varchar) +' '+ @ccy  Msg          
 return          
end 
 
 
------------------ START API AGENTS -------------------      
declare @api_agent_id varchar(MAX) ,@api_Cash2China VARCHAR(50)         
select @api_agent_id=isNUll(xm_agentid+',','') +isNUll(tranglo_agentid+',','') +'20100275,20100309' from tbl_setup        

SET @api_agent_id = LTRIM(RTRIM(@api_agent_id))      

SELECT @api_agent_id = CASE WHEN @api_agent_id IS NOT NULL AND @api_agent_id<>'' THEN       
  @api_agent_id+','+agentcode       
 ELSE agentcode END      
FROM tbl_integrated_agents      
    
SELECT TOP 1 @api_Cash2China=agentcode FROM dbo.tbl_integrated_agents WHERE agentName='CASH TO CHINA'    
------------------ END API AGENTS -------------------      
       
declare @enable_update_remoteDB char(1),@remote_db varchar(500),          
 @payout_agentid varchar(50),@receiverCountry varchar(100),@status varchar(50),@refno varchar(30)          
 ,@comments varchar(500) 

declare @sql varchar(5000)
BEGIN TRANSACTION  
	--update moneysend set  
	--transstatus=CASE WHEN confirmDate IS NOT NULL then 'Payment' ELSE 'Hold' END,ofac_app_by=@user_id,          
	--ofac_app_ts=dbo.getDateHO(getutcdate()),
	--confirm_process_id=@process_id        
	-- from moneysend m with(nolock) Join  #temp t  on m.tranno = t.Item      
	-- where compliance_flag='y'
	--AND transstatus in ('ofac','Compliance')  
--------------------------------------------------------------------------------------	
	create table #temp_ofac (tranno int)
exec ('insert into #temp_ofac (tranno) select tranno from moneysend WITH(NOLOCK) where tranno in ('+@tranno+') and (ofac_list=''y'' or compliance_flag=''y'')and ofac_app_ts is null')
create table #temp_NONofac (tranno int)
exec ('insert into #temp_NONofac (tranno) select tranno from moneysend WITH(NOLOCK) where tranno in ('+@tranno+') and ((ofac_list is NULL and compliance_flag is NULL ) or ((ofac_list=''y'' or compliance_flag=''y'') and ofac_app_ts is not null))')

--create table #temp_halt (tranno int)
--exec ('insert into #temp_halt (tranno) select tranno from moneysend WITH(NOLOCK) where tranno in ('+@tranno+') and (agent_limit_exceed=''y'') ')

-- condition for transstatus according to ofac_list 
set @sql='update moneysend set transStatus=''Payment'',released_ts=dbo.getDateHO(getutcdate()),releasedby='''+ @user_id +'''
where transStatus=''Halt'' and tranno in (select tranno from #temp_NONofac) '
exec(@sql)
print(@sql)
set @sql=''
set @sql='update moneysend set transStatus=''OFAC'',released_ts=dbo.getDateHO(getutcdate()),releasedby='''+ @user_id +'''  
where transStatus=''Halt'' and tranno in (select tranno from #temp_ofac) 
 and ofac_list=''y'''
exec(@sql)
print(@sql)

---- For Compliance
set @sql='update moneysend set transStatus=''Compliance'',released_ts=dbo.getDateHO(getutcdate()),releasedby='''+ @user_id +'''  
where transStatus=''Halt'' and tranno in (select tranno from #temp_ofac) 
and compliance_flag=''y'''

exec(@sql)
print(@sql)
---------------------------------------------

	set @sql='update moneysend set transstatus=''Hold'',refno=case when c2c_secure_pwd  is null 
 or expected_payoutagentid in ('+@api_Cash2China+')     
 THEN refno else c2c_secure_pwd end 
  from moneysend m with(nolock) Join  #temp t  on m.tranno = t.Item 
 where expected_payoutagentid in ('+ @api_agent_id +')           
 and ofac_list=''y'' AND SenderBankName<>''API Transaction'''           
 
 print @sql          
 exec(@sql)       
 set @comments='---- TXN Approved From Compliance Hold List ----' 
 
-- create table #temp_payout(          
--agentcode varchar(50)          
--)          
          
--exec('insert into #temp_payout(agentcode)          
--select distinct expected_payoutagentid from moneysend with(nolock) 
--where tranno in ('+@tranno+')          
--and transStatus in (''Hold'',''Payment'')')          
          
--select * from #temp_payout          
--select @payout_agentid= agentcode from #temp_payout          
--drop table #temp_payout          
          
--select @remote_db=remote_db,@enable_update_remoteDB=enable_update_remote_DB from tbl_interface_setup           
--where agentcode=@payout_agentid and mode='Send'          
          
--if @enable_update_remoteDB='y'          
--BEGIN          
--print ('spRemote_sendTrns ''i'','''+@tranno+''','''+@approve_by+''','''+@agentid+''','''+ @process_id +''',''y''')          
--EXEC ('spRemote_sendTrns ''i'','''+@tranno+''','''+@approve_by+''','''+@agentid+''','''+ @process_id +''',''y''')          
--END          
          
declare @customerId varchar(50),@send_mode char(1)  
    
          
INSERT INTO TransactionNotes            
 (refno,Comments,DatePosted,PostedBy,uploadBy,noteType,tranno)           
--VALUES (@refno,@Comments,dbo.getDateHO(getutcdate()),@user_id,'A','1',@tranno)  

 SELECT			ms.refno
				,@Comments
				,dbo.getDateHO(getutcdate())
				,@user_id
				,'A'
				,'3'
				,t.Item
				 from #temp t JOIN moneySend ms WITH(NOLOCK) ON ms.Tranno=t.Item
	 commit transaction		  
-- if @enable_update_remoteDB='y'          
--BEGIN          
--print ('spRemote_sendTrns ''i'','''+@tranno+''','''+@approve_by+''','''+@agentid+''','''+ @process_id +''',''y''')          
--EXEC ('spRemote_sendTrns ''i'','''+@tranno+''','''+@approve_by+''','''+@agentid+''','''+ @process_id +''',''y''')          
--END   
-- DECLARE @tranno_col VARCHAR(MAX)
DECLARE @tranno_col VARCHAR(MAX)
SET @tranno_col=''
	DECLARE payoutLoop CURSOR  FORWARD_ONLY READ_ONLY FOR
		select distinct tis.remote_db,tis.enable_update_remote_DB,tis.agentcode
		  from #temp t JOIN moneySend ms WITH(NOLOCK) ON ms.Tranno=t.Item
		   join tbl_interface_setup tis  on ms.expected_payoutagentid=tis.agentcode
		where mode='Send'
		OPEN payoutLoop
		FETCH NEXT FROM payoutLoop into @remote_db,@enable_update_remoteDB,@payout_agentid
		WHILE @@FETCH_STATUS = 0
		BEGIN
			SET @tranno_col=''
			SELECT  @tranno_col=@tranno_col+cast(tranno AS VARCHAR)+',' FROM MONEYsend m WITH(NOLOCK)
			JOIN #temp scsv on scsv.Item= m.Tranno  WHERE  m.expected_payoutagentid=@payout_agentid
			SET @tranno_col = LEFT(@tranno_col,LEN(@tranno_col)-1)
			if @enable_update_remoteDB='y'
			EXEC ('spRemote_sendTrns ''i'','''+@tranno_col+''','''+@user_id+''','''+@agentid+''','''+ @process_id +'''')
	
			--print @tranno_col
			FETCH NEXT FROM payoutLoop into @remote_db,@enable_update_remoteDB,@payout_agentid
		end
	close payoutLoop
	deallocate payoutLoop
       
select 'Success' Status 

 end try
 
 begin catch          
          
if @@trancount>0           
 rollback transaction          
          
 declare @desc varchar(1000)          
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
 select -1,@desc,'AGENT LIMIT EXCEED Approved','SQL',@desc,'SQL','SP',@user_id,dbo.getDateHO(getutcdate())          
 select 'ERROR' status,'1050' error_id,'Error Please try again' msg          
          
end catch 


GO


