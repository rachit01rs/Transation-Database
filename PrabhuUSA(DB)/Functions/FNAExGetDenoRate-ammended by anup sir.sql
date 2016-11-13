drop FUNCTION [dbo].[FNAExGetDenoRate] 
go 
   --SELECT * FROM dbo.FNAExGetDenoRate('20100004',NULL,NULL,'1')   
--SELECT * FROM dbo.[EX_GetDenoRate](46597,18,11)      
---SELECT * FROM dbo.FNAExGetDenoRate('20100004','Malaysia',NULL,'122','Nepal')  
--SELECT * FROM dbo.FNAExGetDenoRate('20100004','Malaysia',672,'122','Nepal')  
    
CREATE FUNCTION [dbo].[FNAExGetDenoRate]        
    (        
      @agentCode VARCHAR(50)=NULL ,    
      @sending_country_name VARCHAR(100) ,      
      @denomination_id INT=NULL ,        
      @operator INT,  
      @receiving_country_name VARCHAR(100)        
    )        
RETURNS @Items TABLE        
    (        
      sno INT ,        
      DenoCustomer VARCHAR(100) ,        
      denomination MONEY ,        
      DenoCCY VARCHAR(3) ,        
      SendingCurrency VARCHAR(3) ,    
      gross_sending_amount MONEY ,        
      total_charge MONEY ,        
      agent_commission MONEY,  
      denomination_usd MONEY,  
      operator_sno INT,       
      actionkey VARCHAR(10),       
      Operator_name VARCHAR(100),       
      sending_country VARCHAR(100),  
      roundby INT,   
      dRate_SendCCY MONEY,  
      dRate_ReceivingCCY MONEY        
    )        
AS         
    BEGIN        
DECLARE  @round_value INT,@PaidCType MONEY,@ReceiveCType MONEY   
             
--     SELECT @settlement_ccy=CurrencyType FROM dbo.agentDetail WHERE agentCode=@agentCode   
    
--SELECT @user_exRate=customer_rate,@round_value=ISNULL(roundby,2),@usd_exRate=sending_cust_exchangerate FROM dbo.agentCurrencyRate WHERE agentid=@agentCode AND LOWER(receiveCountry)=LOWER(@receiving_country_name) AND LOWER(CurrencyType)=LOWER(@settlement_ccy)  
    
--SET @user_exRate=ROUND(@user_exRate,@round_value)  
  
IF EXISTS( SELECT 'X' FROM dbo.Roster r WITH(NOLOCK) WHERE country=@sending_country_name AND payoutagentid=@agentCode)  
BEGIN  
 SELECT @PaidCType=sellRate,@round_value=@round_value FROM dbo.Roster r WITH(NOLOCK) WHERE country=@sending_country_name AND payoutagentid=@agentCode  
END  
ELSE  
BEGIN   
 SELECT @PaidCType=sellRate,@round_value=@round_value FROM dbo.Roster r WITH(NOLOCK) WHERE country=@sending_country_name  and payoutagentid is null
END  
  
IF EXISTS( SELECT 'X' FROM dbo.Roster r WITH(NOLOCK) WHERE country=@receiving_country_name AND payoutagentid=@agentCode)  
BEGIN  
 SELECT @ReceiveCType=sellRate FROM dbo.Roster r WITH(NOLOCK) WHERE country=@receiving_country_name AND payoutagentid=@agentCode  
END  
ELSE  
BEGIN   
 SELECT @ReceiveCType=sellRate FROM dbo.Roster r WITH(NOLOCK) WHERE country=@receiving_country_name  and payoutagentid is null 
END  
  
INSERT INTO @Items         
    (        
      sno  ,        
      DenoCustomer ,        
      denomination  ,        
      DenoCCY ,        
      SendingCurrency,        
      gross_sending_amount  ,        
      total_charge  ,        
      agent_commission ,  
      denomination_usd ,  
      operator_sno ,       
      actionkey ,       
      Operator_name,       
      sending_country ,  
      roundby ,  
      dRate_SendCCY,    
      dRate_ReceivingCCY       
    )       
    SELECT   
     l.sno,  
    CAST(l.denomination AS VARCHAR) +' '+ l.denomination_currency +' - '+ CAST(d.total_charge AS VARCHAR) +' ' + d.sending_currency DenoCustomer,  
     l.denomination,  
  l.denomination_currency DenoCCY,  
  d.sending_currency,  
  d.gross_sending_amount,  
  d.total_charge,  
  d.agent_commission gross_profit_settlement_currency_agent,  
  l.denomination_usd,  
  o.sno operator_sno,  
  o.actionKey actionKey,        
  o.operator_name operator_name,  
  d.sending_country,  
  @round_value roundby,  
  @PaidCType,  
  @ReceiveCType  
      FROM dbo.MPOS_tbldenomination_list l WITH(NOLOCK) JOIN  
     dbo.MPOS_tblOperator o WITH (NOLOCK) ON l.operator=o.sno     
     JOIN dbo.MPOS_tbldenomination d WITH (NOLOCK) ON d.denomination_key=l.product_key AND d.denomination_sno=l.sno  
     WHERE d.sending_country=@sending_country_name AND   
     d.operator_sno=@operator  
      AND   
     CASE WHEN @denomination_id IS NOT NULL THEN d.denomination_sno ELSE -1 END=ISNULL(@denomination_id,-1)        
    ORDER BY o.operator_name,d.denomination_sno   
     
        RETURN        
    END 