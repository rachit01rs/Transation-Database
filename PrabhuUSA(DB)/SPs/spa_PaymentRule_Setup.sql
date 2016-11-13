/**      
DATE: 2011.Aug.24 Wed      
**/      
 IF OBJECT_ID('spa_PaymentRule_Setup','P') IS NOT NULL
 DROP PROCEDURE spa_PaymentRule_Setup
 GO
     
CREATE PROCEDURE [dbo].[spa_PaymentRule_Setup]      
@flag CHAR(1)=NULL,      
@agentType VARCHAR(200)=NULL,      
@paymentType VARCHAR(200)=NULL,      
@requiredField1 VARCHAR(200)=NULL,      
@requiredField2 VARCHAR(200)=NULL,      
@requiredField3 VARCHAR(200)=NULL,      
@validation_msg VARCHAR(1000)=NULL,      
@create_ts VARCHAR(50)=NULL,      
@create_by VARCHAR(200)=NULL,      
@update_ts VARCHAR(50)=NULL,      
@update_by VARCHAR(200)=NULL,      
@sno VARCHAR(200)=NULL ,  
@amount_if_more MONEY=NULL ,  
@send_agent_country VARCHAR(20)=NULL ,  
@nos_of_days INT=NULL  
AS      
SET NOCOUNT ON;      
      
IF @flag='i'      
BEGIN   
-- IF EXISTS(SELECT 'x' FROM PaymentRule_Setup   
--  WHERE paymentType=isNUll(@paymentType AND ISNULL(agentType,'NULL')   
--  LIKE CASE WHEN @agentType IS NOT NULL   
--  THEN @agentType ELSE 'NULL' END)  
--  SELECT 'Error' Status, 'Can''t define multiple rule for same payout agent and payment type !!!' MSG  
-- ELSE  
-- BEGIN  
    INSERT INTO PaymentRule_Setup(      
     agentType,      
     paymentType,      
     RequiredField1,      
     RequiredField2,      
     RequiredField3,      
     validation_msg,      
     create_ts,      
     create_by,  
     amount_if_more,  
     send_agent_country ,  
     nos_of_days    
    )      
    VALUES(      
     @agentType,      
     @paymentType,      
     @requiredField1,      
     @requiredField2,      
     @requiredField3,      
     @validation_msg,      
     getdate(),      
     @create_by,  
     @amount_if_more,  
     @send_agent_country ,  
     @nos_of_days  
    )   
     
  SELECT 'Success' Status, 'Successfully inserted!!!' MSG    
-- END   
END      
ELSE IF @flag='s'      
BEGIN          
 IF @sno IS NULL      
 BEGIN      
  SELECT  (prs.sno) sno,      
     (ag.companyName) agentType,      
     (sv.static_value) paymentType,      
     (s.static_value) RequiredField1,      
     (st.static_value) RequiredField2,      
     (sta.static_value) RequiredField3,      
     (prs.validation_msg) validation_msg,      
     (ISNULL(amount_if_more,0)) amount_if_more,  
     (ISNULL(send_agent_country,'All')) send_agent_country ,  
     nos_of_days     
 FROM PaymentRule_Setup prs      
     LEFT outer JOIN agentdetail ag      
     ON ag.agentcode=prs.agentType      
     LEFT JOIN static_values sv      
     ON sv.static_data=prs.paymentType  AND sv.sno=7   
     LEFT JOIN static_values s       
     ON s.static_data=prs.RequiredField1 AND s.sno=300     
     LEFT JOIN static_values st       
     ON st.static_data=prs.RequiredField2      AND st.sno=300  
     LEFT JOIN static_values sta       
     ON sta.static_data=prs.RequiredField3   AND sta.sno=300     
      
 END      
 ELSE      
 BEGIN      
  SELECT        
    sno,      
    agentType,      
    paymentType,      
    RequiredField1,      
    RequiredField2,      
    RequiredField3,      
    validation_msg,      
    create_ts,      
    create_by,  
    amount_if_more,  
    send_agent_country,  
    nos_of_days      
   FROM PaymentRule_Setup      
   WHERE sno=@sno      
 END       
END      
ELSE IF @flag='u'      
BEGIN      
  UPDATE PaymentRule_Setup      
   SET agentType=@agentType,      
    paymentType=@paymentType,      
    RequiredField1=@requiredField1,      
       RequiredField2=@requiredField2,      
                RequiredField3=@requiredField3,      
    validation_msg=@validation_msg,      
    update_ts=getdate(),      
    update_by=@update_by ,   
    amount_if_more=@amount_if_more ,  
    send_agent_country=@send_agent_country,  
    nos_of_days=@nos_of_days   
  WHERE sno=@sno      
END      
ELSE IF @flag='d'      
BEGIN      
  DELETE FROM PaymentRule_Setup      
  WHERE sno=@sno      
END  
  