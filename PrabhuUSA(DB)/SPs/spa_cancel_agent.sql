DROP PROCEDURE [dbo].[spa_cancel_agent]    
go   
CREATE PROCEDURE [dbo].[spa_cancel_agent]    
 @flag char(1),    
 @agentCode varchar(1000)=NULL,    
 @accessed varchar(50)=NULL,    
 @updated_user varchar(50)=NULL,    
 @updated_ts datetime=NULL,    
 @country varchar(50)=NULL,    
 @super_agent_id varchar(50)=Null,
 @state VARCHAR(100)=NULL
     
AS    
     
    
 if @flag='d' --delete from agentdetail and agent is sent to Cancelled agent list    
 begin     
 update agentDetail     
  set accessed=@accessed,    
   updated_user=@updated_user,    
   updated_ts=dbo.getDateHO(getutcdate())    
 where agentCode=@agentCode    
 end    
    
else if @flag='c' -- for cancelling agent    
 begin     
 if @agentCode<>''     
  delete agentsub    
  from agentbranchdetail b,agentsub u    
  where b.agent_branch_Code=u.agent_branch_code and b.agentcode=@agentCode    
  delete agentbalance where agentcode=@agentCode    
  delete moneysend where Agentid=@agentCode    
  delete agentsub where agentcode=@agentCode    
  delete agentbranchdetail where AgentCode=@agentCode    
        delete  agent_branch_commission where agent_code=@agentCode --- added later    
  delete AgentDetail where AgentCode=@agentCode     
  delete agent_function where agent_Id=@agentCode    
  delete agentCurrencyRate where agentId=@agentCode    
  delete moneysend where expected_payoutAgentId=@agentCode --receiverAgentId=@agentCode    
 end    
    
else if @flag='l'  -- for cancel agent list    
begin    
Select * from AgentDetail where accessed =@accessed    
and agenttype not in('Account Header')     
order by country,CompanyName    
end    
    
    
    
else if @flag='r' --for restoring cancelled agent     
begin    
update agentDetail set accessed=@accessed where AgentCode=@agentCode    
end    
    
else if @flag='e' --for restoring cancelled agent else condition    
begin    
Select  * from ledgerreport where agentid=@agentCode    
end    
-- spa_cancel_agent 'y',null,null,null,null,NULL     
else if @flag='y' --for display agent if passed flag=s     
BEGIN    
 declare @sql as varchar(8000)    
 
  set @sql='Select a.currencyType,a.Country,      
a.AgentCode,a.CompanyName,a.limit,a.CurrentBalance,a.Accessed,    
  exRateBy,schargeBy,a.AGENTCAN,a.AGENTTYPE,a.CurrentCommission,a.agent_short_code,    
  case when s.headoffice_agent_id is null then ''n'' else ''y'' end      
isHeadOffice,a.created_ts,a.created_user,a.approve_ts,a.approve_by     
  ,case when a.super_agent_id is null then '''' else isNull(sa.agent_short_code,''---'') end scode,  
  a.restrict_anywhere_payment anywhere,  
    a.address, a.created_ts  
  from AgentDetail a with (nolock) left outer join agent_function f with (nolock) on a.agentcode=f.agent_id     
  left outer join tbl_Setup s with (nolock) on a.agentcode=s.headoffice_agent_id     
  left outer join AgentDetail sa  with (nolock) on sa.agentCode=a.super_agent_id    
        where a.accessed not in (''Cancel'') '     
  if @super_agent_id is not null and @super_agent_id<>''     
 set @sql=@sql+' and a.super_agent_id='''+@super_agent_id +''' '    
  IF @country IS NOT NULL   
 set @sql=@sql+' and a.Country='''+@country +''' '  
  IF @state IS NOT NULL   
 set @sql=@sql+' and a.state='''+@state +''' '   
   
  set @sql=@sql+' and a.agentType in(''Sender Agent'',''Send and Pay'',''ExtAgent'',''HORemit'',''RTAgent'')     
  order by a.country,a.CompanyName'    
 exec(@sql)    
      
  
   
end    
    
else if @flag='n' --for display agent if passed flag not equal to s     
begin    
 Select a.*,z.Zone_Name,case when a.super_agent_id is null then '' else isNull(s.agent_short_code,'---')      
end  scode     
 from AgentDetail a left outer join zone_detail z    
 on a.zone_id=z.zone_id left outer join AgentDetail s on s.agentCode=a.super_agent_id    
 where a.accessed not in ('Cancel') and a.country='Nepal'     
 and a.agentType in ('Local Agent') order by a.CompanyName    
end    
    