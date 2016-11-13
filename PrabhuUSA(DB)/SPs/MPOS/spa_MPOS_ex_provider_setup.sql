CREATE proc [dbo].[spa_MPOS_ex_provider_setup](@flag varchar(5),@provider_id varchar(10)=null,@provider_name varchar(100)=null)  
 AS  
 BEGIN  
   
 IF @flag='i'  
 BEGIN  
   
 INSERT INTO dbo.MPOS_provider_list  
         ( provider_name)  
 VALUES  ( @provider_name)  
  END           
    
    
  IF @flag = 'u'  
  BEGIN   
 UPDATE  MPOS_provider_list SET  provider_name = @provider_name WHERE provider_id = @provider_id  
  END  
    
    
  IF @flag = 'd'  
  BEGIN   
 DELETE FROM  MPOS_provider_list  WHERE provider_id = @provider_id  
  END  
    
   IF @flag = 's'  
  BEGIN   
 SELECT * FROM dbo.MPOS_provider_list  with(nolock) WHERE 1=1  AND CASE WHEN @provider_id IS NOT NULL THEN provider_id ELSE 1 END = ISNULL(@provider_id,1)  
  END  
    
    
 END   