DROP PROC [dbo].[spa_extbanklist]      
Go
/****** Object:  StoredProcedure [dbo].[spa_extbanklist]    Script Date: 04/01/2013 11:52:37 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[spa_extbanklist]      
@flag CHAR(3)=NULL,      
@Bank_name VARCHAR(50)=NULL,      
@country VARCHAR(50)=NULL,      
@agentcode VARCHAR(50)=NULL,      
@commercial_id INT=NULL,      
@branch_sno INT=NULL,      
@commercial_bank_name VARCHAR(50)=NULL,      
@commercial_branch_country VARCHAR(50)=NULL,      
@commercial_branch_name VARCHAR(50)=NULL,      
@external_branch_code VARCHAR(50)=NULL,      
@commercial_branch_contact VARCHAR(50)=NULL,      
@commercial_branch_address VARCHAR(50)=NULL,      
@commercial_branch_state VARCHAR(50)=NULL,      
@commercial_branch_city VARCHAR(50)=NULL,      
@commercial_branch_district VARCHAR(50)=NULL      
      
AS      
      
      
IF @flag='sb'    ---select bank      
BEGIN      
  DECLARE @sql VARCHAR(500)      
 set @sql='Select a.companyName agentName,c.country,c.Bank_name,c.external_bank_id,c.Commercial_id       
 FROM commercial_bank c WITH(NOLOCK)    
 left OUTER join agentdetail a WITH(NOLOCK) on c.payout_agent_id=a.agentcode WHERE 1=1'      
      

 IF @Bank_name IS NOT NULL       
 BEGIN  
  set @sql=@sql+' AND c.Bank_name  like '''+@Bank_name+'%'''      
 END      
 IF @country IS NOT NULL       
 BEGIN      
  set @sql=@sql+' AND c.country='''+@country+''''      
 END      

 IF @country IS NOT NULL AND @agentcode IS NOT NULL      
 BEGIN      
  set @sql=@sql+' AND c.payout_agent_id='''+@agentcode+''''      
 END      
 set @sql=@sql+' order by c.country,c.Bank_name'      
 --PRINT(@sql)      
 --RETURN      
 EXEC(@sql)       
END      
IF @flag='sbb' ---select bank branch      
BEGIN      
 set @sql='Select b.sno,b.commercial_id,b.branchname commercial_branch_name,a.Bank_name,b.IFSC_CODE [external_bank_id],b.address         
 from commercial_bank_branch b WITH(NOLOCK) join commercial_bank a WITH(NOLOCK) on b.commercial_id=a.commercial_id         
 where 1=1'
 
 if   @commercial_id   IS NOT NULL    
 BEGIN    
	set @sql=@sql+' AND b.commercial_id = '''+CAST(@commercial_id AS VARCHAR(20))+''''
 END

 if   @commercial_branch_name   IS NOT NULL    
 BEGIN    
  set @sql=@sql+' AND b.branchname  like '''+@commercial_branch_name+'%'''        
 END  
 
  if   @external_branch_code   IS NOT NULL    
 BEGIN    
  set @sql=@sql+' AND b.IFSC_CODE  like '''+@external_branch_code+'%'''        
 END 
 --PRINT(@sql)
  EXEC(@sql)      
END       
      
IF @flag='i'  ---add new branch of bank      
BEGIN      
 INSERT INTO commercial_bank_branch      
           ([bankName]      
           ,[IFSC_Code]      
           ,[MICR_Code]      
           ,[BranchName]      
           ,[address]      
           ,[contact]      
           ,[city]      
           ,[district]      
           ,[state]      
           ,[country]      
           ,[Commercial_id])      
     VALUES      
           (      
            @commercial_bank_name      
           ,@external_branch_code      
           ,NULL      
           ,@commercial_branch_name      
           ,@commercial_branch_address      
           ,@commercial_branch_contact      
           ,@commercial_branch_city      
           ,@commercial_branch_district      
           ,@commercial_branch_state      
           ,@commercial_branch_country      
           ,@commercial_id)       
      SELECT 'success' STATUS ,'Bank branch successfully inserterd!' MESSAGE      
END      
      
IF @flag='u'  ---upadate bank branch info      
BEGIN      
 UPDATE commercial_bank_branch      
 SET [bankName] =@commercial_bank_name       
      ,[IFSC_Code] =@external_branch_code            
      ,[BranchName] =@commercial_branch_name       
      ,[address] =@commercial_branch_address      
      ,[contact] =@commercial_branch_contact       
      ,[city] =@commercial_branch_city       
      ,[district] =@commercial_branch_district      
      ,[state] =@commercial_branch_state       
      ,[country] =@commercial_branch_country             
 WHERE Commercial_id=@commercial_id AND sno=@branch_sno      
       
 SELECT 'success' STATUS ,'Bank branch successfully updated!' MESSAGE       
END      
IF @flag='d'  ---delete bank branch      
BEGIN      
       
 DELETE FROM commercial_bank_branch WHERE sno=@branch_sno AND Commercial_id=@commercial_id      
 SELECT 'success' STATUS ,'Bank branch successfully deleted!' MESSAGE      
       
END