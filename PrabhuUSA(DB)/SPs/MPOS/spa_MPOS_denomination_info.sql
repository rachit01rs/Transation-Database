DROP PROCEDURE spa_MPOS_denomination_info
GO
CREATE PROC [dbo].[spa_MPOS_denomination_info]      
    (      
      @flag CHAR(5) ,      
      @country_name VARCHAR(50) = NULL ,      
  	  @total_charge varchar(50) = NULL,      
	 @payout_currency varchar(50) = NULL,    
   @sno varchar(10)=NULL,		
   @operator_sno INT =NULL ,
   @sendingAmount MONEY= NULL,
   @Commission MONEY = NULL,
   @sendingCountry varchar(50) = NULL ,
   @user_login_id VARCHAR(100)=NULL,
   @denominationListSno INT=NULL,
   @sendingCurrency varchar(50) = NULL 
     
    )      
AS     
BEGIN    
DECLARE @mobile_demination_sno INT,   
  @sql VARCHAR(max) ,@price_value MONEY,@actionKey VARCHAR(20)
      
      
        IF @flag = 's'   
            BEGIN          
                SET @sql = 'SELECT  o.operator_name operator,d.sno sno,d.payout_amount pvalue        
     ,d.total_charge cvalue,d.payout_currency faceCurrency,d.sending_currency,        
                    c.country_name Countryname,        
                    c.provider_id ,p.provider_name vendor  ,o.isenable,d.gross_sending_amount,d.agent_Commission,d.sending_country      
            FROM    tblCountry c        
                    INNER JOIN MPOS_tbloperator o ON o.country_name = c.country_name     
     INNER JOIN MPOS_provider_list p ON p.provider_id=c.provider_id    
     INNER JOIN MPOS_tbldenomination d ON  d.receiving_country  = c.country_name  AND d.operator_sno =  o.sno    
            WHERE ISNULL(c.provider_id, '''') <> '''' AND  isnull(o.isenable,''n'') <>''n''     '    
                
                IF @country_name IS NOT NULL   
                    SET @sql = @sql + ' AND d.receiving_country = ''' + @country_name +''''   
                
                     
                SET @sql = @sql + ' ORDER BY c.country_name  asc '       
                
                EXEC (@sql)     
            END              
      
    
    IF @flag = 'u'------Update                  
        BEGIN 
  --       IF EXISTS(SELECT 'X' FROM MPOS_tbldenomination WITH (NOLOCK) WHERE-- LOWER(Currency)=LOWER(@currency) AND
  --sno<>@sno  )  
		--	 BEGIN  
		--	  SELECT '0000' Code,'ERROR' status,'Denomination Already Defined!!! ' msg  
		--	  RETURN  
		--	 END       
          
            UPDATE  MPOS_tbldenomination      
            SET     total_charge= @total_charge,    
					agent_commission=@Commission,
					gross_sending_amount=@sendingAmount,
					updated_ts=GETUTCDATE(),
					 updated_by=@user_login_id
            WHERE   sno = @sno           
                     
 SELECT '1000' Code,'SUCCESS' status,'Denomination successfully  Updated !!' msg                       
        END               
         
        
        
    IF @flag = 'i'-------Inserting the values                  
        BEGIN 
                  SELECT @price_value=denomination,@actionKey=product_key FROM dbo.MPOS_tbldenomination_list WHERE sno=@denominationListSno                   
        If EXISTS(SELECT 'X' FROM MPOS_tbldenomination WITH (NOLOCK) WHERE 
				LOWER(receiving_country)=LOWER(@country_name) AND payout_amount=@price_value AND gross_sending_amount=@sendingAmount AND payout_currency=@payout_currency
				AND denomination_sno=@denominationListSno AND denomination_key=@actionKey AND sending_country=@sendingCountry)  
				 BEGIN  
				  SELECT '0000' Code,'ERROR' status,'Denomination Already Defined!!! ' msg  
				  RETURN  
				 END
     
            INSERT  INTO MPOS_tbldenomination      
                    ( receiving_country ,      
                      payout_amount ,      
                      total_charge,    
       payout_currency ,    
       operator_sno ,agent_commission,gross_sending_amount,sending_country,denomination_sno,denomination_key,sending_currency
           
                    )      
            VALUES  ( @country_name ,      
                      @price_value ,      
                      @total_charge,    
       @payout_currency,    
       @operator_sno,@Commission,@sendingAmount,@sendingCountry ,@denominationListSno,@actionKey,@sendingCurrency          
                    )                  
                    
            SELECT '1000' Code,'SUCCESS' status,'New Denomination successfully  Created!!' msg         
        END     
          
        -- SET @mobile_demination_sno = @@IDENTITY        
          
---when new denomination to country wrt operator is added, add the same denomination to the agent and its respective client  
--IF EXISTS (SELECT 'X' FROM dbo.MPOS_tblmobile_agent_Rate WHERE country_name = @country_name)         
-- BEGIN   
   
-- INSERT INTO dbo.MPOS_tblmobile_agent_Rate  
--         ( agent_id ,  
--           mobile_demination_sno ,  
--           selling_price ,  
--           service_charge ,  
--           agent_comission ,  
--           discount ,  
--           country_name  
--         )  
-- SELECT DISTINCT(agent_id),   
--   @mobile_demination_sno,  
--    @price_value - ((discount/100)* @price_value),  
--   service_charge,  
--   agent_comission,  
--   discount,  
--   country_name  
-- FROM   
-- MPOS_tblmobile_agent_Rate WHERE country_name = @country_name  
   
----assign TO  its clients  
-- INSERT INTO dbo.MPOS_tblMobile_User_Rate  
--         ( agent_deno_sno ,  
--           user_id ,  
--           selling_price ,  
--           service_charge ,  
--           user_commission,  
--           discount  
--         )  
-- SELECT  agent_deno_sno ,  
--   ad.agent_id,  
--         selling_price ,  
--         service_charge ,  
--         agent_comission ,  
--         discount   
--         FROM dbo.MPOS_tblmobile_agent_Rate mrr WITH (NOLOCK)  
--         INNER JOIN agent_detail ad WITH (NOLOCK) ON mrr.agent_id = ad.agent_id   
--     WHERE mrr.selling_price = @price_value - ((mrr.discount/100)* @price_value)   
--   AND agent_deno_sno NOT IN (SELECT agent_deno_sno FROM dbo.MPOS_tblMobile_User_Rate)  
   
-- END  
   
       IF @flag = 'd'-------Inserting the values                  
        BEGIN                  
        If NOT EXISTS(SELECT 'X' FROM MPOS_tbldenomination WITH (NOLOCK) WHERE sno=@sno )  
			 BEGIN  
			  SELECT '0000' Code,'ERROR' status,'Denomination Does not exists!!! ' msg  
			  RETURN  
			 END
           UPDATE dbo.MPOS_tbldenomination SET updated_by=@user_login_id,updated_ts=GETUTCDATE() WHERE sno=@sno 
			DELETE FROM [dbo].MPOS_tbldenomination WHERE sno=@sno  
			  SELECT '1000' Code,'SUCCESS' status,'Denomination successfully  Deleted!!' msg   
        END  
        
        IF @flag = 'a'   
            BEGIN          
                SET @sql = 'SELECT  o.operator_name operator,
                    c.country_name Countryname,        
                    c.provider_id ,p.provider_name vendor  ,o.isenable,d.*     
            FROM    tblCountry c        
                    INNER JOIN MPOS_tbloperator o ON  o.country_name = c.country_name     
     INNER JOIN MPOS_provider_list p ON p.provider_id=c.provider_id    
     INNER JOIN MPOS_tbldenomination_audit d ON  d.receiving_country  = c.country_name  AND d.operator_sno =  o.sno    
            WHERE ISNULL(c.provider_id, '''') <> '''' AND  isnull(o.isenable,''n'') <>''n'''    
                
                IF @country_name IS NOT NULL   
                    SET @sql = @sql + ' AND d.receiving_country = ''' + @country_name+''''    
                
                     
                SET @sql = @sql + ' ORDER BY c.country_name  asc '       
                
                EXEC (@sql)     
            END    
   
   
   
    
END  