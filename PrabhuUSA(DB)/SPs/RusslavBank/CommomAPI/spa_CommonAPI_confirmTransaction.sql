alter proc  [dbo].[spa_CommonAPI_confirmTransaction]      
@tranno varchar(8000),      
@user_id varchar(50),      
@agent_id varchar(50),      
@mode char(1)=NULL,
@trackerID VARCHAR(70)=NULL     
AS      
BEGIN TRY      
declare @TRN_APV_NOT_SAME char(1)      
      
declare @gmt_now datetime,@row_approved int,@sql varchar(5000),@gmt_value varchar(10),@mangmt_appv_trn_local money      
select @gmt_value=gmt_value,@TRN_APV_NOT_SAME=dont_allow_apv_same_user from agentDetail where agentCode=@agent_id      
select @mangmt_appv_trn_local=mangmt_appv_trn_local from agent_function where agent_id=@agent_id      
      
if @mangmt_appv_trn_local is Null      
 set @mangmt_appv_trn_local=0      
      
if @TRN_APV_NOT_SAME ='y'       
begin      
create table #temp(tranno int)      
exec('insert into #temp select tranno from moneysend WITH(NOLOCK) where sempid='''+@user_id +''' and tranno in ('+ @tranno +')')      
      
 if exists(select * from #temp)      
 begin      
  select 'Error' Status, 'Same user can''t Approve the Transaction made' Msg      
  return      
 end      
end      
declare @count_agentid varchar(50)      
create table #temp_payout_count(      
agentcode varchar(50)      
)      
      
      
      
set @sql='insert into #temp_payout_count(agentcode)      
select count(distinct expected_payoutagentid) from moneysend WITH(NOLOCK) where tranno in ('+@tranno+')'      
      
exec (@sql)      
      
select @count_agentid= agentcode from #temp_payout_count      
      
drop table #temp_payout_count      
      
      
if @count_agentid>1      
 begin      
  select 'Error' Status, 'You Can''t Approve Multiple Payout Agent Transaction at a Same Time' Msg      
  return      
 end      
     
 --------------------------Block Agent Check--------------------------------------------    
create table #temp_block_agent(      
agentcode varchar(50),    
amount MONEY      
)      
      
      
      
set @sql='insert into #temp_block_agent(agentcode,amount)      
select distinct agentid,SUM(TotalRoundAmt) from moneysend WITH(NOLOCK) where tranno in ('+@tranno+') GROUP BY agentid'      
      
exec (@sql)      
IF not EXISTS (SELECT 'x' FROM agentdetail b WITH(NOLOCK) JOIN #temp_block_agent t ON b.agentCode=t.agentcode WHERE isNull(b.accessed,'Blocked')='Granted')     
   begin      
  select 'Error' Status, 'You Can''t Approve Transaction of blocked or cancelled sending agent' Msg      
  return      
 end      
    
IF not EXISTS (SELECT 'x' FROM agentdetail b WITH(NOLOCK) JOIN #temp_block_agent t ON b.agentCode=t.agentcode WHERE (isNull(b.limit,0)-isNull(b.CurrentBalance,0))>=t.amount)     
   begin      
  select 'Error' Status, 'You dont''t have credit limit to approve all this transaction' Msg      
  return      
 end     
 drop table #temp_block_agent      
--------------------------------------------------------------------------------------------    
--      
DECLARE @process_id varchar(150)      
SET @process_id = REPLACE(newid(),'-','_')      
      
BEGIN transaction  
     
--- check ofac_list flag      
--create table #temp_ofac (tranno int)      
--exec ('insert into #temp_ofac (tranno) select tranno from moneysend WITH(NOLOCK) where tranno in ('+@tranno+')   
--and ((ofac_list=''y'' AND ofac_app_ts IS NULL) or compliance_flag=''y'')')   
--     
--create table #temp_NONofac (tranno int)      
--exec ('insert into #temp_NONofac (tranno) select tranno from moneysend WITH(NOLOCK) where tranno in ('+@tranno+')   
--(ofac_list IS NULL OR (ofac_list=''y'' AND ofac_app_ts IS NOT NULL)) AND m.compliance_flag IS NULL ')      
  
 --- check ofac_list flag ---                    
 CREATE TABLE #temp_ofac                    
 (                    
  tranno INT                    
 )                    
                     
    insert into #temp_ofac (tranno)                     
    select tranno from  moneysend m WITH (NOLOCK) WHERE                                  
    tranno in (@tranno) and ((ofac_list='y' AND ofac_app_ts IS NULL) OR (compliance_flag='y' AND ofac_app_ts IS NULL))                         
                     
         
 CREATE TABLE #temp_NONofac                    
 (                    
  tranno INT                    
 )                    
  insert into #temp_NONofac (tranno)                     
    select tranno from  moneysend m WITH (NOLOCK)                                   
    where tranno in (@tranno) and ((ofac_list IS NULL OR   
  (ofac_list='y' AND ofac_app_ts IS NOT NULL)) OR   
  (m.compliance_flag IS NULL OR (m.compliance_flag='y' AND m.ofac_app_ts IS NOT NULL)))   
  PRINT(@tranno)  
  
-- condition for transstatus according to ofac_list       
      
set @sql='update moneysend set refno=dbo.encryptdb('''+@trackerID+'''),confirmDate=dateadd(mi,'+ @gmt_value +',getutcdate()),
HO_confirmDate=dbo.getDateHO(getutcdate()),transStatus=''Payment'',      
approve_by='''+ @user_id +''',confirm_process_id='''+ @process_id +'''       
where transStatus=''Hold'' and tranno in (select tranno from #temp_NONofac)       
and agentid='''+ @agent_id +''''      
if @mode is NulL and @mangmt_appv_trn_local > 0      
 set @sql=@sql + 'and paidAmt <'+ cast(@mangmt_appv_trn_local as varchar)      
      
exec(@sql)      
      
set @sql=''      
set @sql='update moneysend set refno=dbo.encryptdb('''+@trackerID+'''),
confirmDate=dateadd(mi,'+ @gmt_value +',getutcdate()),
HO_confirmDate=dbo.getDateHO(getutcdate()),transStatus=''OFAC'',      
approve_by='''+ @user_id +''',confirm_process_id='''+ @process_id +'''  
where transStatus=''Hold'' and tranno in (select tranno from #temp_ofac)       
and agentid='''+ @agent_id +''' and ofac_list=''y'''      
if @mode is NulL and @mangmt_appv_trn_local > 0      
 set @sql=@sql + 'and paidAmt <'+ cast(@mangmt_appv_trn_local as varchar)      
exec(@sql)      
      
---- For Compliance      
set @sql='update moneysend set refno=dbo.encryptdb('''+@trackerID+'''),
confirmDate=dateadd(mi,'+ @gmt_value +',getutcdate()),HO_confirmDate=dbo.getDateHO(getutcdate()),
transStatus=''Compliance'',approve_by='''+ @user_id +''',confirm_process_id='''+ @process_id +''' 
where transStatus=''Hold'' and tranno in (select tranno from #temp_ofac)       
and agentid='''+ @agent_id +''' and compliance_flag=''y'''      
if @mode is NulL and @mangmt_appv_trn_local > 0      
 set @sql=@sql + 'and paidAmt <'+ cast(@mangmt_appv_trn_local as varchar)      
exec(@sql)      
      
      
set @row_approved=@@rowcount      
declare @enable_update_remoteDB char(1),@remote_db varchar(500)      
declare @payout_agentid varchar(50)      
      
create table #temp_payout(      
agentcode varchar(50)      
)      
      
exec('insert into #temp_payout(agentcode)      
select distinct expected_payoutagentid from moneysend WITH(NOLOCK) where tranno in ('+@tranno+')')      
      
select @payout_agentid= agentcode from #temp_payout      
drop table #temp_payout     
   
COMMIT transaction      
      
select @remote_db=remote_db,@enable_update_remoteDB=enable_update_remote_DB from tbl_interface_setup       
where agentcode=@payout_agentid and mode='Send'      
      
if @enable_update_remoteDB='y'      
EXEC ('spRemote_sendTrns ''i'','''+@tranno+''','''+@user_id+''','''+@agent_id+''','''+ @process_id +'''')      
select 'Success' Status, cast(@row_approved  as varchar) +' Approved' Msg      
      
      
end try      
begin catch      
      
if @@trancount>0       
 ROLLBACK transaction      
      
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
 select -1,@desc,'[spa_CommonAPI_confirmTransaction]','SQL',@desc,'SQL','SP',@user_id,dbo.getDateHO(getutcdate())      
 select 'ERROR','1050','Error Please try again'      
      
end catch