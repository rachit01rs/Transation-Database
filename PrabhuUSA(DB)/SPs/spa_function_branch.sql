  
  
  
CREATE procedure [dbo].[spa_function_branch]  
 @flag char(1),  
 @agent_branch_Code varchar(200)=NULL,  
 @agentCode varchar(50)=NULL,  
 @Branch varchar(500)=NULL,  
 @Address varchar(100)=NULL,  
 @Country varchar(100)=NULL,  
 @currentBalance money=NULL,  
 @created_by varchar(50)=NULL,  
 @created_ts datetime=NULL,  
 @updated_by varchar(50)=NULL,  
 @updated_ts datetime=NULL,  
 @agent_code_id varchar(50)=NULL,  
 @comm_main_branch_id varchar(50)=NULL  
   
AS  
    
    
 if @flag='l' -- for branch list  
 begin  
 select CompanyName,agentCan branch_agent_rights,agentType from agentdetail   
 where agentcode= @agentcode  
 end  
  
else if @flag='c' -- for create branch  
 begin  
select b.branch,isNull(ca.agent_branch_code,0) Status from   
 agentbranchdetail b left outer join agentbranchdetail ca on b.agent_branch_code=ca.comm_main_branch_id   
 where b.agent_branch_code=@agent_branch_Code  
end  
  
else if @flag='u'  -- for editing branch  
begin  
 select * from agentbranchdetail where comm_main_branch_id=@comm_main_branch_id  
end  
  
else if @flag='b' -- for  commission of branch   
begin  
 Select b.*,cm.branch Comm_branch,a.agentType from agentbranchdetail b   
left outer join agentbranchdetail cm on b.comm_main_branch_id=cm.agent_branch_code  
JOIN agentdetail a ON b.agentcode=a.agentcode  
where b.agent_branch_code=@agent_branch_code  
end  
  
else if @flag='e' -- for sending email to user  
begin  
select a.companyname,a.agentcan,a.currencytype,a.limit,a.limitpertran, b.branch,b.address,b.city,  
b.country,b.branchcodechar from agentdetail as a join agentbranchdetail as b on a.agentcode=b.agentcode   
where b.agent_branch_code=@agent_branch_code  
end  
  
else if @flag='y' --if comm_main_branch_id <>""  
begin  
select b.branch,isNull(ca.agent_branch_code,0) Status from   
agentbranchdetail b left outer join agentbranchdetail ca on b.agent_branch_code=ca.comm_main_branch_id   
where b.agent_branch_code=@agent_branch_code  
end  
  
else if @flag='n' --if comm_main_branch_id =""  
begin  
update agentbranchdetail set branch=@branch,  
  updated_by=@updated_by,updated_ts=dbo.getDateHO(getutcdate())  
  where agent_branch_code=@agent_branch_code  
end  
  
else if @flag='i'    ------updateBranch when chk_create_comission="y"  
begin  
  
insert into agentBranchdetail( agentCode, Branch, Address,  Country,currentBalance,created_by,created_ts,  
updated_by,updated_ts,agent_code_id,comm_main_branch_id)  
select @agentCode,@branch+'- Comm', @Address,@Country,@currentBalance,  
@created_by,@created_ts,@updated_by,@updated_ts,@agent_code_id,  
agent_branch_code from agentbranchdetail   
where agent_branch_code=@agent_branch_code  
  
end  
  
  
  
  
  
  
  
  