DROP proc [dbo].[spa_SOAP_AgentList_V2]  
Go  
  
--select * from agentbranchdetail where agentcode=20100108 and isHeadoffice='y'  
--update agentbranchdetail set address='Shahnaz Tower 9 New Eskaton Road,  Mouza - Bara Moghbazar,  Dhaka-1000' where agent_branch_code=20104086  
--spa_SOAP_AgentList_V2 'PMTTMLRC01','TMLAPI','TML#123API',NULL,'E','BANGLADESH'  
--spa_SOAP_AgentList_v2 'FXC01','PMTFOR','FOR#123','1234','N','India','state'  
--SELECT dbo.decryptDb(s.User_pwd),a.branchCodeChar,*  
--  FROM agentsub s JOIN agentbranchdetail a ON s.agent_branch_code=a.agent_branch_Code  
--WHERE a.Country LIKE 'Q%' AND s.allow_integration_user='y'  
--spa_SOAP_AgentList_v2 'FXC001','FOREIGNPMT','FORe#123','12333','D','Nepal',Null,Null  
CREATE proc [dbo].[spa_SOAP_AgentList_V2]      
    @accesscode varchar(100),      
    @username varchar(100),      
    @password varchar(100),      
    @AGENT_REFID varchar(100),      
    @PAYMENTTYPE varchar(50),      
    @Payout_Country varchar(100),    
 @bank_name varchar(50)=null,    
 @states varchar(50) =null     
as      
declare @agentcode varchar(50),@agent_branch_code varchar(50),@user_pwd varchar(50), @accessed varchar(50)      
declare @Block_branch varchar(50), @BranchCodeChar varchar(50), @lock_status varchar(5),@agent_user_id varchar(50)      
declare @country varchar(50),@user_count int,@client_pc_id varchar(100),      
@agentname varchar(100),@branch varchar(100),@gmtdate datetime,@COLLECT_CURRENCY varchar(5)      
set @client_pc_id='192.168.1.100'      
     
set @PAYMENTTYPE=upper(@PAYMENTTYPE)     
      
declare @api_agent_id varchar(200),@sql varchar(8000)      
declare @return_value varchar(1000),@allow_integration_user CHAR(1)      
      
if @username='' or @password='' or @accesscode='' or @AGENT_REFID=''      
begin      
set @return_value='Invalid Request Parameter'      
insert  sys_access(ipadd, login_type, log_date, log_time, branch_code, emp_id, user_id, pwd, msg, status)       
values(@client_pc_id,'SOAP_FOREX',convert(varchar,getdate(),102),convert(varchar,getdate(),108),@accesscode,NULL,@username,'******','Invalid Request Parameter','Failed')      
select '1001' Code,@AGENT_REFID AGENT_REFID,@return_value Message      
return      
end      
      
SELECT @agentcode=a.agentcode,@agentname=a.companyName,@user_pwd=u.user_pwd,@agent_user_id=u.agent_user_id,      
@accessed=a.accessed,@country=a.country,@branch=b.branch,      
@agent_branch_code=b.agent_branch_code,@BranchCodeChar=b.BranchCodeChar,       
@Block_branch=isNUll(b.block_branch,'n'),@lock_status=isNUll(u.lock_status,'n'),@COLLECT_CURRENCY=a.currencyType,      
@gmtdate=dateadd(mi,isNUll(gmt_value,345),getutcdate()),@allow_integration_user=isNull(u.allow_integration_user,'n')      
 FROM agentDetail a  WITH (NOLOCK)    
JOin agentbranchdetail b WITH (NOLOCK) on a.agentcode=b.agentcode      
JOIN agentsub u WITH (NOLOCK) ON b.agent_branch_code=u.agent_branch_code       
where u.user_login_id=@username      
      
set @user_count=@@rowcount      
set @api_agent_id=@agentcode      
----AUTHENTICATING USER----------      
if @user_count=0      
begin      
set @return_value='Invalid User ID'      
insert  sys_access(ipadd, login_type, log_date, log_time, branch_code, emp_id, user_id, pwd, msg, status)       
values(@client_pc_id,'SOAP_FOREX',convert(varchar,getdate(),102),convert(varchar,getdate(),108),@accesscode,NULL,@username,'******','Invalid User Name','Failed')      
select '1002' Code,@AGENT_REFID AGENT_REFID,@return_value Message      
return      
end      
if @user_pwd<>dbo.encryptdb(@password)      
begin      
set @return_value='Invalid Password'      
insert  sys_access(ipadd, login_type, log_date, log_time, branch_code, emp_id, user_id, pwd, msg, status)       
values(@client_pc_id,'SOAP_FOREX',convert(varchar,getdate(),102),convert(varchar,getdate(),108),@accesscode,@agent_user_id,@username,@password,'Invalid Password','Failed')      
select '1002' Code,@AGENT_REFID AGENT_REFID,@return_value Message      
return      
end      
if @BranchCodeChar<>@accesscode      
begin      
set @return_value='Partner id invalid'      
insert  sys_access(ipadd, login_type, log_date, log_time, branch_code, emp_id, user_id, pwd, msg, status)     
values(@client_pc_id,'SOAP_FOREX',convert(varchar,getdate(),102),convert(varchar,getdate(),108),@accesscode,@agent_user_id,@username,'******','Branch Code invalid','Failed')      
select '1002' Code,@AGENT_REFID AGENT_REFID,@return_value Message      
return      
end      
if @Block_branch='y'   OR @lock_status='y'      
begin        
 set @return_value='Your userid is Blocked'        
 select '1003' Code,@AGENT_REFID AGENT_REFID,@return_value Message,NULL COLLECT_AMT        
 return        
end        
IF @allow_integration_user='n'      
begin      
 set @return_value='Your userid is not allowed for Web Services'      
 select '1003' Code,@AGENT_REFID AGENT_REFID,@return_value Message,NULL REFID      
 return      
END      
if not exists (SELECT * FROM service_charge_setup scs       
WHERE scs.agent_id=@agentcode AND scs.Rec_Country=@Payout_Country)      
BEGIN      
 set @return_value='You are not allowed to sent to country '+@Payout_Country      
 select '5001' Code,@AGENT_REFID AGENT_REFID,@return_value MESSAGE   RETURN         
END       
CREATE TABLE #temp_list(      
 code INT,      
 LocationID VARCHAR(50),      
 Agent VARCHAR(150),      
 Branch VARCHAR(150),      
 ADDRESS VARCHAR(500),      
 City VARCHAR(150),      
 Currency VARCHAR(50),      
 BankID VARCHAR(50),    
 Bank_BranchID VARCHAR(50),    
 Branch_State varchar(50)      
)      
if upper(@PAYMENTTYPE)='C'  --- Cash PickUp    
BEGIN      
 INSERT #temp_list(code,LocationID,Agent,Branch,[ADDRESS],City,Currency,Branch_State)      
 select 0 Code,Agent_Branch_Code LocationID,a.CompanyName Agent,Branch,b.Address,      
 b.City,a.CurrencyType Currency,isNUll(state_branch,Branch_group)      
 from agentbranchdetail b WITH (NOLOCK)     
 join agentdetail a WITH (NOLOCK) on b.agentcode=a.agentcode      
 where a.Country=@Payout_Country and (b.block_branch='n' or b.block_branch is NUll)       
 and AgentType in ('ExtAgent','Send and Pay') and AgentCan in ('Both','Receiver','SenderReceiver')      
 and accessed='Granted' and b.Branch_Type in('Both','Cash Pay') and isnull(b.hide_branch,'n')='n'  
 and case when @states is not null then isNUll(state_branch,Branch_group) else 'a' end =isNUll(@states,'a')      
 and case when @bank_name is not null then a.CompanyName else 'a' end  like isNUll(@bank_name +'%','a')      
 order by a.CompanyName,b.branch      
      
end      
else if upper(@PAYMENTTYPE)='E'  --- Extern Type PickUp    
BEGIN      
 INSERT #temp_list(code,LocationID,Agent,Branch,[ADDRESS],City,Currency,Branch_State)      
select 0 Code,Agent_Branch_Code LocationID,a.CompanyName Agent,Branch,b.Address,      
b.City,a.CurrencyType Currency,isNUll(state_branch,Branch_group)      
 from agentbranchdetail b WITH (NOLOCK)     
 join agentdetail a WITH (NOLOCK) on b.agentcode=a.agentcode      
 where a.Country=@Payout_Country and (b.block_branch='n' or b.block_branch is NUll)       
and AgentType in ('ExtAgent','Send and Pay') and AgentCan in ('Both','Receiver','SenderReceiver')      
 and accessed='Granted' and b.Branch_Type='External' and isnull(b.hide_branch,'n')='n'   
and case when @states is not null then  isNUll(state_branch,Branch_group) else 'a' end =isNUll(@states,'a')      
 and case when @bank_name is not null then a.CompanyName else 'a' end  like isNUll(@bank_name +'%','a')      
     
order by a.CompanyName,b.branch      
      
end      
else if upper(@PAYMENTTYPE)='B'  --- Account Deposit    
BEGIN       
  INSERT #temp_list(code,LocationID,Agent,Branch,[ADDRESS],City,Currency,Branch_State)      
  select 0 Code,Agent_Branch_Code LocationID,      
  case when a.Country='Nepal' then Branch_group else a.CompanyName end  Agent,      
  Branch,b.Address,b.City,a.CurrencyType Currency,isNUll(state_branch,Branch_group)      
  from agentbranchdetail b WITH (NOLOCK)    
  join agentdetail a WITH (NOLOCK) on b.agentcode=a.agentcode      
  where a.Country=@Payout_Country and (b.block_branch='n' or b.block_branch is NUll)  and AgentCan in ('Both','None')      
  and accessed='Granted' and AgentType in ('ExtAgent','Send and Pay') and isnull(b.hide_branch,'n')='n' and       
  b.Branch_Type IN ('AC Deposit','Both')   
  and case when @states is not null then isNUll(state_branch,Branch_group) else 'a' end =isNUll(@states,'a')      
  and case when @bank_name is not null then a.CompanyName else 'a' end  like isNUll(@bank_name +'%','a')      
  order by a.CompanyName,b.branch_group,b.branch      
END       
--else if upper(@PAYMENTTYPE)='D'  --- Account Deposit to Other Bank    
--BEGIN       
--SELECT distinct agent_branch_Code,agentCode INTO #agent FROM agentbranchdetail WITH (NOLOCK) WHERE isHeadOffice='y'      
--INSERT #temp_list(code,LocationID,Agent,Branch,[ADDRESS],City,Currency,BankID,Branch_State)      
--SELECT 0 Code,a.agent_branch_code LocationID, cb.Bank_name Agent,      
--NULL Branch,NULL Address,NULL City,ad.CurrencyType Currency,    
--isNULL(cb.external_bank_id,cb.commercial_id) external_bank_id,    
--  FROM commercial_bank cb WITH (NOLOCK) JOIN #agent a       
--ON cb.payout_agent_id=a.agentcode     
--JOIN agentDetail ad WITH (NOLOCK) ON ad.agentCode=cb.payout_agent_id      
--WHERE cb.country=@Payout_Country --AND external_bank_id IS NOT NULL       
--order by  cb.Bank_name      
--END       
else if upper(@PAYMENTTYPE) in ('N','d')  --- NEFT    
BEGIN       
 if @bank_name is null and @states is null and @PAYMENTTYPE='N'    
 begin    
   set @return_value='Must Provide BANK_NAME or BANK_BRANCH_STATE'      
   select '5002' Code,@AGENT_REFID AGENT_REFID,@return_value MESSAGE      
   RETURN     
 end    
 SELECT distinct agent_branch_Code,agentCode INTO #agent1 FROM agentbranchdetail WITH (NOLOCK) WHERE isHeadOffice='y'     
 AND Country=@Payout_Country and Block_branch='n' and isnull(hide_branch,'n')='n'    
     
 INSERT #temp_list(code,LocationID,Agent,Branch,[ADDRESS],City,Currency,BankID,Bank_BranchID,Branch_State)      
 SELECT 0 Code,a.agent_branch_code LocationID,cb.Bank_name Agent,      
 cbb.BranchName Branch,[dbo].FNARemoveSpecialChar(cbb.[address]) Address,isnull(cbb.city,cbb.district) City,ad.CurrencyType Currency,    
 cb.commercial_id external_bank_id,cbb.sno,cbb.state    
 FROM commercial_bank cb WITH (NOLOCK) JOIN #agent1 a       
 ON cb.payout_agent_id=a.agentcode     
 JOIN agentDetail ad WITH (NOLOCK) ON ad.agentCode=cb.payout_agent_id      
 left outer JOIN commercial_bank_branch cbb ON cb.Commercial_id=cbb.Commercial_id    
 WHERE cb.country=@Payout_Country --AND external_bank_id IS NOT NULL     
 and case when @states is not null then cbb.state else 'a' end =isNUll(@states,'a')      
 and case when @bank_name is not null then     
   case when @PAYMENTTYPE='N' then cbb.bankName else ad.Companyname end     
  else 'a' end  like isNUll(@bank_name +'%','a')    
 and ad.accessed='Granted'    
 order by cb.Bank_name,cbb.branch     
END       
else      
begin      
 set @return_value='Invalid Payment Type'      
 select '3001' Code,@AGENT_REFID AGENT_REFID,@return_value MESSAGE      
 RETURN       
end       
IF not EXISTS(SELECT * FROM #temp_list)      
BEGIN       
 set @return_value='Not Location Found'      
 select '5001' Code,@AGENT_REFID AGENT_REFID,@return_value MESSAGE      
 RETURN       
END       
ELSE       
alter table #temp_list add sno int identity(1,1)    
SELECT code,LocationID,Agent,Branch,ADDRESS,City,Currency,BankID,@PAYMENTTYPE PAYMENTTYPE,    
@Payout_Country Payout_Country,Bank_BranchID,Branch_State FROM #temp_list    
    