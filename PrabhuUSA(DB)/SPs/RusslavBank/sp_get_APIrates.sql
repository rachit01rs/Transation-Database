CREATE PROCEDURE [dbo].[sp_get_APIrates]                        
@flag CHAR,                        
@sCountry VARCHAR(50),                        
@rCountry VARCHAR(50),                        
@sCurrency VARCHAR(50),                        
@dCurrency VARCHAR(50),                        
@receiveAmt float,                        
@dAmt float,                        
@PaidAmt float,                        
@HO_dollar_rate float,                        
@today_dollar_rate float,                        
@exRate float,                                
@customer_settlementRate float,                        
@confirm_process_id VARCHAR(200),                
@sCharge FLOAT ,                
@dollarAmt FLOAT,                
@send_USDrate FLOAT,                
@netSend_amt FLOAT,            
@sChargeUSD float             
                 
AS                        
DECLARE @iso_Country VARCHAR(20),@sChrage MONEY,@agent_settlement_rate FLOAT ,@settlement_margin FLOAT,@HO_EX_margin FLOAT                      
SELECT @iso_Country=Currency_code FROM tbl_CountryList tcl WHERE tcl.country_name =@rCountry                        
                        
IF @flag='i'                         
 BEGIN                    
      SELECT @HO_EX_margin=cc.ex_rate_margin FROM API_Country_setup cc WHERE cc.Country=@rCountry        
              
    SET @agent_settlement_rate   = @HO_dollar_rate / @exRate                 
    SET @customer_settlementRate = @today_dollar_rate       
    SET @settlement_margin       = @agent_settlement_rate - @customer_settlementRate           
               
   INSERT INTO Partner_API_rates                        
  (                        
   sendCountry ,                        
   payoutCountry,                        
   sendAmt ,                        
   sendCurrency ,                        
   payoutAmt ,                        
   ExchangeRate ,                        
   Ho_dollar_rate ,                        
   today_dollar_rate ,                        
   agent_ex_gain ,      
   Gain_amt ,                        
   agent_rate ,                        
   customer_rate,                        
   Dot,                        
   confirm_process_id,                        
   is_used, -- 'n'=not used and 'y='used                    
   paidamt,                    
   paidCtype,                
   send_USDrate,                
   sCharge,                
   dollarAmt,                
   pay_actualUSD,            
   netAmt_Send ,            
   sChargeUSD,        
   HO_EX_margin                       
  )                        
  SELECT @sCountry sendcountry,                
  @rCountry payoutCountry,                
  @receiveAmt sendAmt,                
  @sCurrency sendCurrency,                
  @dAmt payoutAmt,                        
  @exRate ExchangeRate,                
  @HO_dollar_rate Ho_dollar_rate,                
  @today_dollar_rate today_dollar_rate,                      
  @settlement_margin agent_ex_gain,      
  NULL Gain_amt,                
  @agent_settlement_rate agent_rate,                        
  @customer_settlementRate customer_rate,                
  dbo.getDateHO(GETUTCDATE()) Dot,                
  @confirm_process_id confirm_process_id,                
  'n' is_used ,                    
  @PaidAmt paidamt,                
  @iso_Country paidCtype ,                
  @send_USDrate send_USDrate,                
  @sCharge sCharge,                
  @dollarAmt  dollarAmt,                
  NULL pay_actualUSD,            
  @netSend_amt netAmt_Send ,            
  @sChargeUSD sChargeUSD ,       
  isnull(@HO_EX_margin,0) HO_EX_margin                   
 END                        
                        
  SELECT *FROM Partner_API_rates with(NOLOCK) WHERE confirm_process_id=@confirm_process_id 