DROP PROCEDURE spa_batch_report_all
GO
--spa_batch_report_all '64197','SummaryBalance','AgentType Desc,Agent_Name',NULL  
CREATE proc [dbo].[spa_batch_report_all]      
@message_id INT=null,      
@call_from varchar(100)=NULL,      
@order_by varchar(300)=NULL ,    
@state VARCHAR(50)=NULL    
     
as      
DECLARE @sql VARCHAR(MAX),@temp_table_name varchar(200)    
     
--IF @state IS NULL    
--BEGIN    
-- SET @sql='spa_batch_report '''+CAST(@message_id AS VARCHAR)+''','''+@call_from+''','''+@order_by+''''    
-- EXEC(@sql)    
--END    
--ELSE    
--BEGIN  
   
 select @temp_table_name='iremit_process.dbo.'+source+'_'+user_login_id+'_'+job_name from message_board        
 where message_id=@message_id AND source=@call_from     
   
   IF @temp_table_name IS null      
   SELECT 'ERROR' Status,2001,'Invalid batch id' Message      
  ELSE  
  BEGIN    
    SET @sql='SELECT r.*,a.country FROM '+@temp_table_name+' r WITH(NOLOCK)   
    LEFT OUTER JOIN  agentdetail a WITH(NOLOCK)     
     ON  r.agent_id=a.agentCode '   
    IF @state IS NOT NuLL  
    SET @sql=@sql +' WHERE a.[STATE]='''+@state+''''  
    IF @order_by IS NOT NULL      
    SET @sql=@sql +' order by r.AgentType Desc,a.Country,Agent_Name'  
   --print  @sql    
    EXEC(@sql)  
  END   
--END 