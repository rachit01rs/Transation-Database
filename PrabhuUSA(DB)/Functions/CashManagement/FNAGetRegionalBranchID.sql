  
CREATE FUNCTION [dbo].[FNAGetRegionalBranchID] (@Reg_branch_code VARCHAR(50))      
RETURNS varchar(2000)   
  
AS      
BEGIN  
   
DECLARE @isHO CHAR(1),@branch_code VARCHAR(2000)  
  
 select @branch_code= COALESCE(@branch_code + ',', '') + reg_branch_id from agent_regional_branch  WHERE agent_branch_code=@Reg_branch_code  
 IF @branch_code IS NOT NULL   
  SET @branch_code=@branch_code +','+ @Reg_branch_code  
 ELSE   
 BEGIN   
  SET @branch_code=@Reg_branch_code  
 END    
 RETURN @branch_code  
END   