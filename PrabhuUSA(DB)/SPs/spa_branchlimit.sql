create proc [dbo].spa_branchlimit  
@flag char(1),  
@agentcode varchar(50)=null,  
@branch_limit varchar(50)=null,  
@agent_branch_code varchar(50)=null,  
@extend_limit varchar(50)=null  
as   
declare @branchname varchar(50)  
  
if @flag='a'  
begin   
select branch,branch_limit,agent_branch_code,current_branch_limit,add_branch_limit, ((branch_limit + isNull(add_branch_limit,0)) - isNull(current_branch_limit,0)) as limit_left  from agentbranchdetail where agentCode=@agentcode order by branch asc  
end  
if @flag='u'  
begin  
update agentbranchdetail  
set branch_limit=@branch_limit  
where agent_branch_code=@agent_branch_code  
select @branchname= branch from agentbranchdetail where agent_branch_code=@agent_branch_code  
select 'Success' status, 'Branch Limit for '''+ @branchname +''' Branch Updated Successfully' msg  
end  
if @flag='e'--Extend Limit  
begin  
update agentbranchdetail  
set add_branch_limit=isNull(add_branch_limit,0)+@extend_limit  
where agent_branch_code=@agent_branch_code  
select @branchname= branch from agentbranchdetail where agent_branch_code=@agent_branch_code  
select 'Success' status, 'Branch Limit for '''+ @branchname +''' Branch Updated Successfully' msg  
end  
  
  
  
  
  