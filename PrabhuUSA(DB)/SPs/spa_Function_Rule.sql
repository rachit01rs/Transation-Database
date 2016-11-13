/**      
     
DATE   : 2011.MAR.14 MON      
**/      
IF OBJECT_ID('spa_Function_Rule','P') IS NOT NULL
DROP PROCEDURE spa_Function_Rule
GO
create PROCEDURE [dbo].[spa_Function_Rule]      
@flag CHAR(1)=NULL ,  
@agent_country VARCHAR(150)=NULL     
AS      
SET NOCOUNT ON;      
      
IF @flag='l'      
BEGIN       
  SELECT        
     upper(paymentType) paymentType,      
agentType,     
    validation_msg,      
    min_length,      
    max_length,      
    RequiredField      
  FROM LengthRule_Setup      
END       
ELSE IF @flag='p'      
BEGIN       
  SELECT      
    upper(paymentType) paymentType,      
 agentType,     
    validation_msg,      
    RequiredField1,      
    RequiredField2,      
    RequiredField3,  
    amount_if_more,  
    send_agent_country,  
    nos_of_days  
  FROM PaymentRule_Setup  
  WHERE --ISNULL(send_agent_country,@agent_country)=@agent_country  
 CASE WHEN @agent_country IS NULL THEN '1' ELSE  
 ISNULL(send_agent_country,@agent_country) END =ISNULL(@agent_country,'1')  
        
END   
  
  