CREATE PROCEDURE [dbo].[spa_user_detail]          
          
 @flag char(1),          
 @agent_user_id int=NULL,          
 @User_login_Id varchar(50)=NUll ,          
 @User_pwd varchar(50)=NUll  ,          
 @user_name varchar(50)=NUll  ,          
 @user_post varchar(50)=NUll  ,          
 @user_address varchar(100)=NUll  ,          
 @user_email varchar(50)=NUll  ,          
 @agentCode varchar(50)=NUll  ,          
 @agent_branch_code varchar(50)=NUll  ,          
 @create_date datetime=NUll  ,          
 @upload varchar(50)=NUll  ,          
 @rights int=NUll  ,          
 @lastdateChanged datetime=NUll  ,          
 @limited_date int=NUll  ,          
 @last_login datetime =NUll ,          
 @lock_days int=NUll  ,          
 @ip_address varchar(15)=NUll  ,          
 @lock_status varchar(10)=NUll  ,          
 @create_by varchar(50)=NUll  ,          
 @create_ts datetime=NUll  ,          
 @approve_by varchar(50)=NUll  ,          
 @approve_ts datetime=NUll  ,          
 @update_by varchar(50)=NUll  ,          
 @update_ts datetime=NUll  ,          
 @trasfer_branch_id varchar(50)=NUll  ,          
 @last_login_pc varchar(200)=NUll  ,          
 @active_session varchar(50)=NUll  ,          
 @user_remarks varchar(800)=NUll  ,          
 @last_logout datetime=NUll  ,          
 @last_logout_info varchar(500)=NULL,        
 @allow_integration_user CHAR(1)=null,          
 @API_user_login_id VARCHAR(50)=NULL,          
  @API_user_password VARCHAR(50)=NULL,          
  @API_AccessCode VARCHAR(50)=NULL,          
  @API_authenticationAgentCode VARCHAR(50)=NULL,          
 @API_URL_WSDL VARCHAR (500) = NULL,          
 @API_receivingAgentCode  VARCHAR(50)=NULL,  
 @User_IP_Allowed varchar(100)=NULL             
AS          
declare @audit_record int          
select @audit_record=audit_record_no from tbl_setup          
if @flag='i'          
begin          
 if exists(select agent_user_id from agentsub where User_login_Id=@User_login_Id)          
 begin          
  select 'Error','User Name already exists, Please choose different username'          
  return          
 end          
 select @agent_user_id=max(agent_user_id)+1 from agentsub          
 if @agent_user_id is null           
  set @agent_user_id='40100000'          
   Insert into agentSub          
   (          
   agent_user_id,          
    User_login_Id          
   ,User_pwd          
   ,user_name          
   ,user_post           
   ,user_address           
   ,user_email           
   ,agentCode           
   ,agent_branch_code          
   ,create_date          
   ,upload          
   ,rights          
   ,limited_date          
   ,lock_days          
   ,create_by          
   ,approve_by          
   ,approve_ts          
   ,user_remarks        
   ,allow_integration_user       
 ,API_user_login_id          
 ,API_user_password          
 ,API_AccessCode          
 ,API_authenticationAgentCode          
 ,API_URL_WSDL          
 ,API_receivingAgentCode  
 ,User_IP_Allowed             
   )          
  Values           
     (          
   @agent_user_id,          
    @User_login_Id,          
    dbo.encryptdb(@User_pwd),          
    @user_name,          
    @user_post,              
    @user_address,          
    @user_email,          
    @agentCode,          
    @agent_branch_code,          
    dbo.getDateHO(getutcdate()),          
    @upload,          
    @rights,          
    @limited_date,          
    @lock_days,          
    @create_by,          
    NULL ,          
    NULL ,          
    @user_remarks,        
    @allow_integration_user,          
    @API_user_login_id,          
    @API_user_password,          
    @API_AccessCode,          
    @API_authenticationAgentCode,          
   @API_URL_WSDL,          
   @API_receivingAgentCode ,  
   @User_IP_Allowed                
     )          
select 'Success','User Name Created'          
end          
else if @flag='p'          
BEGIN           
 DECLARE @chksameagent varchar(50)          
 SELECT @chksameagent=create_by FROM agentSub WHERE agent_user_id=@agent_user_id     
 IF @chksameagent=@approve_by          
 BEGIN           
  SELECT 'Error' status,'Cannot approved by the Created User...!!!' message           
  RETURN           
 END           
  ELSE           
 BEGIN           
  UPDATE agentSub          
  SET approve_by=@approve_by,          
   approve_ts=dbo.getDateHO(getutcdate()),      
   update_ts= dbo.getDateHO(getutcdate())          
   WHERE agent_user_id=@agent_user_id           
   SELECT 'success' status,'Agent '+ cast(@agent_user_id AS varchar)+' is Approved Successfully...!!!' message           
 END           
END           
          
else if @flag='u'          
begin          
Update agentSub           
set            
 user_name=@user_name          
 ,user_post=@user_post          
 ,user_address=@user_address          
 ,user_email=@user_email          
 ,rights=@rights          
 ,limited_date=@limited_date          
 ,lock_days=@lock_days          
 ,update_by=@update_by          
 ,update_ts= dbo.getDateHO(getutcdate())           
 ,user_remarks=@user_remarks          
 ,allow_integration_user=@allow_integration_user      
 ,API_user_login_id = @API_user_login_id          
 ,API_user_password = @API_user_password          
 ,API_AccessCode = @API_AccessCode          
 ,API_authenticationAgentCode = @API_authenticationAgentCode          
 ,API_URL_WSDL = @API_URL_WSDL          
 ,API_receivingAgentCode = @API_receivingAgentCode   
 ,User_IP_Allowed=@User_IP_Allowed          
where agent_user_id=@agent_user_id           
end          
else if @flag='d'          
 begin          
 delete agentSub  where agent_user_id=@agent_user_id           
 end          
else if @flag='s'          
 begin          
  SELECT agentsub.User_login_Id, agentbranchDetail.branch, agentbranchDetail.branchCodeChar,          
  agentsub.agent_user_id, agentsub.rights, agentsub.lastdateChanged,agentDetail.AgentCan,          
  user_pwd,null branchCan,agentSub.lock_status,          
  last_login,trasfer_branch_id FROM agentsub join agentbranchDetail           
  on agentbranchDetail.agent_branch_code=agentsub.agent_branch_code INNER JOIN agentDetail          
   ON agentbranchDetail.agentCode = agentDetail.agentCode          
   where agentbranchDetail.agent_branch_code=@agent_branch_code           
  order by agentsub.agent_branch_code,User_login_Id          
          
 end          
          
else if @flag='a'          
 begin          
 select * from agentSub where  agent_user_id=@agent_user_id           
 end          
else if @flag='b'   --to lock/unlock user          
 begin           
update agentsub           
set lock_status=@lock_status          
 ,update_by=@update_by          
 ,update_ts= dbo.getDateHO(getutcdate())          
where agent_user_id=@agent_user_id          
 end          
          
else if @flag='c'          
begin           
select top(@audit_record)* from agentsub_audit where agent_user_id=@agent_user_id order by update_ts desc          
end          
else if @flag='z'          
begin          
select top(@audit_record) * from agentsub_audit where sno=@agent_user_id          
end          
          
          
          
          
          
          
          
          
          
          
          
          