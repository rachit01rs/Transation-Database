DROP PROC spa_branchuser_limit
GO
CREATE proc [dbo].[spa_branchuser_limit]  
@flag char(1),  
@agentcode varchar(50)=null,  
@agent_branch_code varchar(50)=null,  
@user_credit_limit money=null,  
@user_login_id varchar(50)=NULL,  
@updated_by VARCHAR(50)=NULL   
as   
if @flag='u'  
begin  
 update agentsub  
 set user_credit_limit=@user_credit_limit  
 where agent_branch_code=@agent_branch_code AND User_login_Id=@user_login_id  
 INSERT user_credit_limit_log(user_login_id,updated_by,updated_ts,user_credit_limit)  
 VALUES(@user_login_id,@updated_by,GETDATE(),@user_credit_limit)  
end  