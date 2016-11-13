
IF OBJECT_ID('spa_LengthRule_Setup','P') IS NOT NULL
DROP PROCEDURE spa_LengthRule_Setup
GO
/**            
DATE   : 2011.Aug.24 Wed
**/      
      
CREATE PROCEDURE [dbo].[spa_LengthRule_Setup]      
@flag CHAR(1)=NULL,      
@agentType VARCHAR(200)=NULL,      
@paymentType VARCHAR(200)=NULL,      
@requiredField VARCHAR(200)=NULL,      
@max_length VARCHAR(50)=NULL,      
@min_length VARCHAR(50)=NULL,      
@validation_msg VARCHAR(1000)=NULL,      
@create_ts VARCHAR(50)=NULL,      
@create_by VARCHAR(200)=NULL,      
@update_ts VARCHAR(50)=NULL,      
@update_by VARCHAR(200)=NULL,      
@sno VARCHAR(200)=NULL      
      
AS      
SET NOCOUNT ON;        
IF @flag='i'      
BEGIN    
 IF EXISTS(SELECT 'x' FROM LengthRule_Setup WHERE paymentType=@paymentType AND ISNULL(agentType,'NULL') LIKE CASE WHEN @agentType IS NOT NULL THEN @agentType ELSE 'NULL' END)  
  SELECT 'Error' Status, 'Can''t define multiple rule for same payout agent and payment type !!!' MSG  
 ELSE   
 BEGIN   
    INSERT INTO LengthRule_Setup(      
     agentType,      
     paymentType,      
     RequiredField,      
     max_length,      
     min_length,      
     validation_msg,      
     create_ts,      
     create_by      
    )      
    VALUES(      
     @agentType,      
     @paymentType,      
     @requiredField,      
     @max_length,      
     @min_length,      
     @validation_msg,      
     getdate(),      
     @create_by      
    )   
 SELECT 'Success' Status, 'Successfully inserted!!!' MSG    
 END   
END      
ELSE IF @flag='s'      
BEGIN      
 IF @sno IS NULL      
 BEGIN      
  SELECT  MAX(lrs.sno) sno,      
     MAX(ag.CompanyName) agentType,      
     MAX(sv.static_value) paymentType,      
     MAX(s.static_value) RequiredField,      
     MAX(max_length) max_length,      
     MAX(min_length) min_length,      
     MAX(validation_msg) validation_msg,      
     create_ts,      
     MAX(create_by) create_by      
    FROM LengthRule_Setup lrs      
     INNER JOIN agentdetail ag      
      ON ag.agentcode=lrs.agentType      
     LEFT OUTER JOIN static_values s      
      ON s.static_data=lrs.RequiredField      
     LEFT OUTER JOIN static_values sv      
      ON sv.static_data=lrs.paymentType      
    GROUP BY lrs.create_ts   
 UNION ALL  
  SELECT  MAX(lrs.sno) sno,      
     NULL,      
     MAX(sv.static_value) paymentType,      
     MAX(s.static_value) RequiredField,      
     MAX(max_length) max_length,      
     MAX(min_length) min_length,      
     MAX(validation_msg) validation_msg,      
     create_ts,      
     MAX(create_by) create_by      
    FROM LengthRule_Setup lrs         
     LEFT OUTER JOIN static_values s      
      ON s.static_data=lrs.RequiredField      
     LEFT OUTER JOIN static_values sv      
      ON sv.static_data=lrs.paymentType   
    WHERE agentType IS NULL     
    GROUP BY lrs.create_ts     
    ORDER BY lrs.create_ts DESC      
 END      
 ELSE      
 BEGIN      
   SELECT  sno,      
     agentType,      
     paymentType,      
     RequiredField,      
     max_length,      
     min_length,      
     validation_msg,      
     create_ts,      
     create_by      
   FROM LengthRule_Setup      
    WHERE sno=@sno      
   ORDER BY create_ts DESC      
 END      
END      
ELSE IF @flag='u'      
BEGIN      
  UPDATE LengthRule_Setup      
   SET agentType=@agentType,      
    paymentType=@paymentType,      
    RequiredField=@requiredField,      
       max_length=@max_length,      
                min_length=@min_length,      
    validation_msg=@validation_msg,      
    update_ts=getdate(),      
    update_by=@update_by      
  WHERE sno=@sno      
END      
ELSE IF @flag='d'      
BEGIN      
  DELETE FROM LengthRule_Setup      
  WHERE sno=@sno      
END  