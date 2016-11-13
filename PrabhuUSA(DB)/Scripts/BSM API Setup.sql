declare @agent_short_code varchar(50), @agentCOde varchar(50)
set @agent_short_code='BSM'

select  @agentCode = s.agentCode from agentsub s join
agentDetail b on s.agentcode=b.agentcode 
where agent_short_code=@agent_short_code
and allow_integration_user is not null
if @agentCode is null 
BEGIN
 select 'Agent is not created'
 return 
END
select 'OK'

--insert into static_values(sno,static_data,static_value,description,additional_value)
select 500,s.agentCode,s.agent_branch_code,a.Companyname,a.agent_short_code from agentsub s join
agentDetail a on s.agentcode=a.agentcode where a.agent_short_code=@agent_short_code
and s.allow_integration_user is not null

--insert into tbl_integrated_agents
select agentcode,companyname,'Default','API_BSM/holdtxn/holdtransAll.asp',
NULL,NULL,NULL,
NULL
from agentdetail where agentcode = @agentCode   and agent_short_code=@agent_short_code


--insert into sender_function(sno,function_name,link_file,main_menu)
--select sno+1,'BSM','API_BSM/holdtxn/holdtransAll.asp'