--spa_LOG_App_Table 'user_id','visit_file','visit_para','dc','ip','tranno','refno'    
CREATE proc [dbo].[spa_LOG_App_Table]    
@log_user varchar(50),    
@visit_file varchar(1000),    
@visit_parameter varchar(5000),    
@dc_info varchar(250),    
@ip_address varchar(50),    
@tranno varchar(50)=NULL,    
@refno varchar(50)=NULL,    
@user_type varchar(50)    
as    
INSERT INTO [log_app_table]    
           ([log_date]    
           ,[log_user]    
           ,[visit_file]    
           ,[visit_parameter]    
           ,[dc_info]    
           ,[ip_address]    
           ,[tranno]    
           ,[refno]    
   ,user_type    
)    
     VALUES    
 (getdate(),@log_user,@visit_file,@visit_parameter,@dc_info,@ip_address,    
@tranno ,@refno,@user_type ) 