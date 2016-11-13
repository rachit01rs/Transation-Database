IF OBJECT_ID('spa_checkduplicate_V1','P') IS NOT NULL
DROP PROCEDURE spa_checkduplicate_V1
GO
CREATE PROC [dbo].[spa_checkduplicate_V1]    
@session_id varchar(100),    
@sendername varchar(200) ,  
@paidAmt money=null   
as    
  
declare @date varchar(50)  
set @date=convert(varchar,getdate(),101)  
  
select senderName,AgentName,Branch,sempId,Local_dot   
from  moneysend m with (nolock)   
where convert(varchar,Local_dot,101)=@date  
  and paidAmt=@paidAmt  
 and m.sendername=@sendername    
and m.transStatus not in ('Cancel') 