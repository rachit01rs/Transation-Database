DROP proc [dbo].[spa_approved_ofac]          
go
--spa_approved_ofac '1884794','HO:admin', '20100000','BIJESHM','2A8E8DEC_CE11_44A6_BCA3_0AA7CF84C558',NULL,'c'          
--spa_approved_ofac '1884794','HO:admin', '20100000','BIJESHM','2A8E8DEC_CE11_44A6_BCA3_0AA7CF84C558',NULL,'o'          
---spa_approved_ofac '1949211','HO:admin','92400000','soper215832EE670'          
CREATE proc [dbo].[spa_approved_ofac]          
@tranno varchar(50),          
@user_id varchar(100),          
@agentid varchar(100)=null,          
@approve_by varchar(200)=null,          
@process_id varchar(200)=null,          
@approve_notes varchar(2000)=null,          
@approve_type char(1)=NULL          
as          
begin try     
  
IF  exists (select tranno FROM moneySend  with (NOLOCK) WHERE tranno=@tranno AND transstatus not in ('ofac','Compliance') )          
BEGIN          
 select 'ERROR' status,'Transaction cannot be Approved. Please check the status !!' Msg          
 return          
end          
          
IF  exists (select tranno FROM moneySend  with (NOLOCK) WHERE tranno=@tranno AND transstatus='Payment' )          
BEGIN          
 select 'ERROR' status,'Transaction has already been Approved !!' Msg          
 return          
end          
       
IF  exists (select tranno FROM moneySend  with (NOLOCK) WHERE tranno=@tranno AND isIRH_trn='y' )          
BEGIN          
 select 'ERROR' status,'Transaction cannot be Approved ! This is partner system transaction !!' Msg          
 return          
end       
------------------ START API AGENTS -------------------      
declare @api_agent_id varchar(MAX) ,@api_Cash2China VARCHAR(50)         
select @api_agent_id=xm_agentid+','+tranglo_agentid+',20100275,20100309' from tbl_setup        
         
SET @api_agent_id = LTRIM(RTRIM(@api_agent_id))      

SELECT @api_agent_id = CASE WHEN @api_agent_id IS NOT NULL AND @api_agent_id<>'' THEN       
  @api_agent_id+','+agentcode       
 ELSE agentcode END      
FROM tbl_integrated_agents      
    
SELECT TOP 1 @api_Cash2China=agentcode FROM dbo.tbl_integrated_agents WHERE agentName='CASH TO CHINA'    
------------------ END API AGENTS -------------------      
       
declare @enable_update_remoteDB char(1),@remote_db varchar(500),          
 @payout_agentid varchar(50),@receiverCountry varchar(100),@status varchar(50),@refno varchar(30)          
 ,@comments varchar(500),@noteType CHAR(1)      
          
DECLARE @sql varchar(4000)          

BEGIN TRANSACTION          

if @approve_type='c' --FOR COMPLIANCE APPROVAL          
begin          
 set @sql='update moneysend set  transstatus=CASE WHEN confirmDate IS NOT NULL then ''Payment'' ELSE ''Hold'' END,ofac_app_by='''+@user_id+''',          
 ofac_app_ts=dbo.getDateHO(getutcdate())          
 where tranno='''+@tranno+'''          
 and compliance_flag=''y''  
 AND transstatus in (''ofac'',''compliance'')'          
 print @sql          
 exec(@sql)          
 ----------- COMPLIANCE Release For API Agent txn --------------------------           
 set @sql='update moneysend set transstatus=''Hold'',refno=case when 
 c2c_secure_pwd  is null or expected_payoutagentid in ('+@api_Cash2China+')     
 THEN refno else c2c_secure_pwd end where tranno='''+@tranno+''' 
 and expected_payoutagentid in ('+ @api_agent_id +')           
 and compliance_flag=''y'' AND SenderBankName<>''API Transaction'''           
 
 print @sql          
 exec(@sql)          
 -------------------------------------------------------------------------          
 
 set @comments='---- TXN Approved From Compliance Hold List ----' 
 SET @noteType='3'         
end          
else          
begin          
if exists(select tranno from moneysend with (nolock) where tranno=@tranno and ofac_list='y' and compliance_flag='y')          
begin          
 set @sql='update moneysend set  transstatus=''Compliance'',ofac_app_by='''+@user_id+''',          
 ofac_app_ts=dbo.getDateHO(getutcdate())          
 where tranno='''+@tranno+'''          
 and ofac_list=''y''  
 AND transstatus in (''ofac'',''compliance'')'          
 print @sql          
 exec(@sql)          
           
 set @comments='---- TXN Approved From OFAC Suspect List But It is Listed in Compliance Hold ----' 
 SET @noteType='4'         
end          
else          
begin          
 set @sql='update moneysend set  transstatus=CASE WHEN confirmDate IS NOT NULL then ''Payment'' ELSE ''Hold'' END,
 ofac_app_by='''+@user_id+''',          
 ofac_app_ts=dbo.getDateHO(getutcdate())          
 where tranno='''+@tranno+'''          
 and ofac_list=''y''  
 AND transstatus in (''ofac'',''compliance'')'          
 print @sql          
 exec(@sql)          
          
 set @sql='update moneysend set transstatus=''Hold'',refno=case when c2c_secure_pwd  is null 
 or expected_payoutagentid in ('+@api_Cash2China+')     
 THEN refno else c2c_secure_pwd end where tranno='''+@tranno+''' 
 and expected_payoutagentid in ('+ @api_agent_id +')           
 and ofac_list=''y'' AND SenderBankName<>''API Transaction'''           
 
 print @sql          
 exec(@sql)          
  
set @comments='---- TXN Approved From OFAC Suspect List ----'          
end          
end          
create table #temp_payout(          
agentcode varchar(50)          
)          
          
exec('insert into #temp_payout(agentcode)          
select distinct expected_payoutagentid from moneysend with(nolock) 
where tranno in ('+@tranno+')          
and transStatus in (''Hold'',''Payment'')')          
          
--select * from #temp_payout          
select @payout_agentid= agentcode from #temp_payout          
drop table #temp_payout          
          
select @remote_db=remote_db,@enable_update_remoteDB=enable_update_remote_DB from tbl_interface_setup           
where agentcode=@payout_agentid and mode='Send'          
          
--if @enable_update_remoteDB='y'          
--BEGIN          
--print ('spRemote_sendTrns ''i'','''+@tranno+''','''+@approve_by+''','''+@agentid+''','''+ @process_id +''',''y''')          
--EXEC ('spRemote_sendTrns ''i'','''+@tranno+''','''+@approve_by+''','''+@agentid+''','''+ @process_id +''',''y''')          
--END          
          
declare @customerId varchar(50),@send_mode char(1)  
  
select @refno=refno,@receiverCountry=receiverCountry,@status=transStatus,@customerId=customerID ,@send_mode=send_mode    
from moneysend where tranno=@tranno    
    
        
if @approve_notes is not null           
begin          
INSERT INTO TransactionNotes            
(refno,Comments,DatePosted,PostedBy,uploadBy,noteType,tranno)           
VALUES (@refno,@approve_notes,dbo.getDateHO(getutcdate()),@user_id,'A',@noteType,@tranno)          
end          
          
INSERT INTO TransactionNotes            
 (refno,Comments,DatePosted,PostedBy,uploadBy,noteType,tranno)           
VALUES (@refno,@Comments,dbo.getDateHO(getutcdate()),@user_id,'A',@noteType,@tranno)          
          
   if @send_mode='m'---- Mobile  
begin  
 exec spa_MobileEmail @flag='a',@customerID=@customerId,@tranno=@tranno  
end        
      
          
commit transaction          
if @enable_update_remoteDB='y'          
BEGIN          
print ('spRemote_sendTrns ''i'','''+@tranno+''','''+@approve_by+''','''+@agentid+''','''+ @process_id +''',''y''')          
EXEC ('spRemote_sendTrns ''i'','''+@tranno+''','''+@approve_by+''','''+@agentid+''','''+ @process_id +''',''y''')          
END       
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
 select -1,@desc,'OFAC Approved','SQL',@desc,'SQL','SP',@user_id,dbo.getDateHO(getutcdate())          
 select 'ERROR' status,'1050' error_id,'Error Please try again' msg          
          
end catch 