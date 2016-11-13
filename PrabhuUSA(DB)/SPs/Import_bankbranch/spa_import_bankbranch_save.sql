 DROP PROC [dbo].[spa_import_bankbranch_save]      
go  
--spa_import_branch_save @processid='admin_C7874A98_7344_44DC_8193_0494534E352E', @agentid='20100043'      
--spa_import_branch_save @processid='admin_5FCEF864_D0A0_4BF8_A422_B0BEEF81540B', @agentid='20100045'      
--spa_import_branch_save @processid='admin_E0EC6FAA_9228_4F3C_ABF9_365D3CD10461', @agentid='20100038'      
--select * from [error_info]      
--select * from agentbranchdetail      
--select * from temp_import_branchdetail      
--SELECT TOP 1 agent_branch_code FROM agentbranchDetail ORDER BY agent_branch_code DESC      
--selectmax([agent_user_id]) from agentsub      
-- DELETE FROM agentsub where agent_user_id>10010050      
--select * from agentsub      
create PROC [dbo].[spa_import_bankbranch_save]      
 @processid VARCHAR(200),      
 @agentid VARCHAR(50)=null    
AS      
--declare @agent_branch_code varchar(50),@SQL VARCHAR(200)      
BEGIN TRY      
       
 BEGIN TRANSACTION      
         
--  DECLARE @branch_id varchar(50), @country VARCHAR(100)      
--  SELECT TOP 1 @branch_id=agent_branch_code FROM agentbranchDetail ORDER BY agent_branch_code DESC      
--  SELECT TOP 1 @country=country FROM agentDetail WHERE agentcode=@agentid      
DECLARE @bankName VARCHAR(200)
  SELECT @bankName=Bank_name,@agentid=Commercial_id FROM dbo.commercial_bank  with(nolock) WHERE Commercial_id=@agentid
  INSERT INTO commercial_bank_branch(BranchName, Country,  District,  City, Address ,Contact, IFSC_Code,  MICR_Code,Commercial_id,state,bankName)      
  SELECT BranchName, Country,  District,  City, Address ,Contact, EXTCODE,  EXTCODE1,@agentid,state,@bankName   
 FROM temp_import_bankbranchDetail  with(nolock)     
  WHERE process_id=@processid ORDER BY BranchName   
  DELETE FROM temp_import_bankbranchDetail      
  WHERE process_id=@processid    
     -- Bank,ExtBankID,agent_country,payingOutAgent,digital_id_sENDer,process_id   
--    if @autouser ='y'    
-- Begin    
--    SELECT @agent_user_id=isNULL(max(agent_user_id),10010000) from agentsub      
--          
--          
--    insert into agentsub (agent_user_id,User_login_Id,User_pwd,user_name,user_post,user_address,user_email,agentCode,      
--    agent_branch_code,create_date,upload,rights,limited_date,lock_days,create_by,approve_by,approve_ts,      
--    user_remarks,enable_without_dc)      
--    select ROW_NUMBER() OVER (ORDER BY branch ASC) +@agent_user_id, ROW_NUMBER() OVER (ORDER BY branch ASC) +@agent_user_id,dbo.encryptdb(ltrim(rtrim(User_pwd))),user_name,user_post,user_address,user_email,agentCode,      
--    ROW_NUMBER() OVER (ORDER BY branch ASC) +@branch_id,getdate(),upload,cast(rights as int),cast(limited_date as int),cast(lock_days as int),create_by,approve_by,approve_ts,      
--    user_remarks,cast(enable_without_dc as char(1)) from temp_import_branchdetail where process_id=@processid       
--        
-- end    
      
      
 COMMIT TRANSACTION      
  SELECT 'SUCCESS'      
      
END TRY      
BEGIN CATCH      
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
  select '100',@desc,'spa_import_bankbranch_save','SQL',@desc,'SQL','SP','',getdate()            
END CATCH      
      
      
GO
