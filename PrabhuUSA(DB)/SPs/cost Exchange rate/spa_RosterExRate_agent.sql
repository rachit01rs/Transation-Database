DROP PROCEDURE [dbo].[spa_RosterExRate_agent]  
Go
CREATE PROCEDURE [dbo].[spa_RosterExRate_agent]    
 @flag CHAR(1),    
 @sno INT = NULL,    
 @country VARCHAR(50) = NULL,    
 @cost_SendRate NUMERIC(19, 10) = NULL,    
 @updated_by VARCHAR(50) = NULL,    
 @payoutAgentID VARCHAR(50) = NULL  
AS  
  
IF @flag = 'u'    
 BEGIN    
--ALTER TABLE dbo.agentCurrencyRate ADD sending_curr_cost_rate FLOAT
  UPDATE agentCurrencyRate  
     SET 
		sending_curr_cost_rate= @cost_SendRate, 
		agent_premium_send=0, 
		ExchangeRate=@cost_SendRate,  
		margin_sending_agent=0,--ROUND(ExchangeRate-@cost_SendRate,roundby),  
		SENDING_CUST_EXCHANGERATE=@cost_SendRate,
		nprRate=ROUND(dollarRate/@cost_SendRate,roundby),  
		customer_rate=ROUND(dollarRate/@cost_SendRate,roundby),  
		payout_agent_rate=dollarRate,  
		customer_diff_value=0,  
		receiver_rate_diff_value=0,  
		update_by=@updated_by,  
		update_ts=dbo.getDateHO(GETUTCDATE())              
     WHERE agentid=@payoutAgentID  
       
     UPDATE ROSTER  
     SET    
			--buyRate = ISNULL(@cost_SendRate, 0),  
            sellRate = ISNULL(@cost_SendRate, 0),  
            rateDiff = 0,  
            updated_by = @updated_by,  
            updated_ts = dbo.getDateHO(GETUTCDATE())  
     WHERE  payoutagentid=@payoutAgentID  
  
--         
     SELECT 'Success' STATUS,    
            'The Forex of ' + @country + ' is updated sucessfully' msg    
 END