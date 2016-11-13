drop PROCEDURE [dbo].[spa_RosterExRate]  
go   
--spa_RosterExRate 'e',25,'Nepal',68,68,0,'BDT','admin','admin',NULL,NULL,NULL,NULL           
--spa_RosterExRate 'c',25,'Bangladesh',68.40,68.40,NULL,NULL,'admin','admin','5904, 5905, 5902, 5901, 5903, 5907, 5906',NULL,'E1F3D164_6E31_422D_B279_F91F5974CC14',NULL          
--spa_RosterExRate 'e',34,'Bangladesh',66.71,66.71,0,'BDT','admin','admin',NULL,'30300000',NULL,NULL           
CREATE PROCEDURE [dbo].[spa_RosterExRate]  
 @flag CHAR(1),  
 @sno INT = NULL,  
 @country VARCHAR(50) = NULL,  
 @buyRate NUMERIC(19, 10) = NULL,  
 @sellRate NUMERIC(19, 10) = NULL,  
 @rateDiff NUMERIC(19, 10) = NULL,  
 @currencyType VARCHAR(3) = NULL,  
 @created_by VARCHAR(50) = NULL,  
 @updated_by VARCHAR(50) = NULL,  
 @effSno VARCHAR(max) = NULL,  
 @payoutAgentID VARCHAR(50) = NULL,  
 @session_id VARCHAR(200) = NULL,  
 @round_value INT = NULL,  
 @xmlData VARCHAR(max) = NULL,  
 @buy_sell_margin MONEY = NULL  
AS  
 IF @xmlData IS NOT NULL  
 BEGIN  
     SET @xmlData = REPLACE(@xmlData, '{', '<')          
     SET @xmlData = REPLACE(@xmlData, '}', '>')          
     SET @xmlData = REPLACE(@xmlData, '|', '"')          
     SET @xmlData = REPLACE(@xmlData, '&quot', '"')   
         --set @xmlData=replace(@xmlData,'&lt','<')  
         --set @xmlData=replace(@xmlData,'&gt','>')  
 END          
   
   
 SET @round_value = 4          
   
 IF @flag = 'a'  
     SELECT sno,  
            country,  
            buyRate,  
            sellRate,  
            rateDiff,  
            currencyType  
     FROM   forex  
     WHERE  sno = @sno          
   
 IF @flag = 'i'  
 BEGIN  
     DECLARE @agent_country  VARCHAR(50),  
             @status         VARCHAR(10)  
       
     IF @payoutAgentID IS NOT NULL  
     BEGIN  
         SELECT @agent_country = companyName  
         FROM   agentdetail  
         WHERE  agentcode = @payoutAgentID  
           
         IF NOT EXISTS (  
                SELECT payoutAgentID  
                FROM   forex  
                WHERE  payoutAgentID = @payoutAgentID  
            )  
         BEGIN  
             INSERT INTO forex  
               (  
                 country,  
                 buyRate,  
                 sellRate,  
                 rateDiff,  
                 currencyType,  
                 created_by,  
                 created_ts,  
                 payoutAgentID,  
                 Round_By  
               )  
             VALUES  
               (  
                 @country,  
                 @buyRate,  
                 @sellRate,  
                 @rateDiff,  
                 @currencyType,  
                 @created_by,  
                 dbo.getDateHO(GETUTCDATE()),  
                 @payoutAgentID,  
                 @round_value  
               )          
             EXEC spa_forex 'e',  
                  @sno,  
                  @country,  
                  @buyRate,  
                  @sellRate,  
                  @rateDiff,  
                  @currencyType,  
                  @created_by,  
                  @updated_by,  
                  NULL,  
                  @payoutAgentID,  
                  NULL,  
                  @round_value  
               
             SET @status = 'true'  
         END  
         ELSE  
             SET @status = 'false'  
     END  
     ELSE  
     BEGIN  
         SELECT @agent_country = @country          
         IF NOT EXISTS (  
                SELECT sno  
                FROM   forex  
                WHERE  country = @country  
                       AND payoutAgentID IS NULL  
            )  
         BEGIN  
             INSERT INTO forex  
               (  
                 country,  
                 buyRate,  
                 sellRate,  
                 rateDiff,  
                 currencyType,  
                 created_by,  
                 created_ts,  
                 Round_By  
               )  
             VALUES  
               (  
                 @country,  
                 @buyRate,  
                 @sellRate,  
                 @rateDiff,  
                 @currencyType,  
                 @created_by,  
                 dbo.getDateHO(GETUTCDATE()),  
                 @round_value  
               )          
             EXEC spa_forex 'e',  
                  @sno,  
                  @country,  
                  @buyRate,  
                  @sellRate,  
                  @rateDiff,  
                  @currencyType,  
                  @created_by,  
                  @updated_by  
               
             SET @status = 'true'  
         END  
         ELSE  
             SET @status = 'false'  
           
         SET @agent_country = @country  
     END          
     IF @status = 'false'  
         SELECT 'Error' STATUS,  
                'The Forex of ' + @agent_country + ' already exists' msg  
     ELSE  
         SELECT 'Success' STATUS,  
                'The forex successfylly inserted' msg  
 END           
   
 IF @flag = 'u'  
 BEGIN  
     EXEC spa_forex 'e',  
          @sno,  
          @country,  
          @buyRate,  
          @sellRate,  
          @rateDiff,  
          @currencyType,  
          @created_by,  
          @updated_by,  
          NULL,  
          NULL,  
          NULL,  
          @round_value  
 END  
   
 IF @flag = 'd'  
 BEGIN  
     DELETE forex  
     WHERE  sno = @sno  
       
     SELECT 'Success' STATUS,  
            'The Forex selected is deleted permantly' msg  
 END  
   
 IF @flag = 'e'  
 BEGIN  
     IF @session_id IS NULL  
     BEGIN  
         SET @session_id = REPLACE(NEWID(), '-', '_')  
     END          
       
     DELETE dbo.temp_forex_exchange  
     WHERE  session_id = @session_id  
       
     IF @payoutAgentID IS NOT NULL  
     BEGIN  
         INSERT INTO dbo.temp_forex_exchange  
           (  
             exType,  
             sender,  
             receiveCountry,  
             receiver,  
             OldBuyRate,  
             NewBuyRate,  
             OldSelRate,  
             alt_premium,  
             NewSelRate,  
             CURRENT_SETTLEMENT,  
             CURRENT_MARGIN,  
             CURRENT_CUSTOMER,  
             ho_offer,  
             ExchangeRate,  
             margin_sending_agent,  
             SENDING_CUST_EXCHANGERATE,  
             SEND_VS_PAYOUT_SETTMENT,  
             SEND_VS_PAYOUT_CUSTOMER,  
             SEND_VS_PAYOUT_MARGIN,  
             OldEffRate,  
             NewEffRate,  
             currencyId,  
             idType,  
             effictiveCountry,  
             updated_by,  
             session_id,  
             Payout_Currency_Code,  
             roundby,  
             alt_cost  
           )(  
                SELECT 'Buying' ExType,  
                       a.companyName Sender,  
                       receiveCountry,  
                       p.companyName Receiver,  
                       DollarRate [CurrentRate],  
                       @buyRate [Cost],  
                       ISNULL(agent_premium_payout, 0) agent_premium_payout,  
                       ISNULL(agent_premium_send, 0) agent_premium_send,  
                       @buyRate -ISNULL(agent_premium_payout, 0)   
                       [SettlementRate],  
                       @buyRate -ISNULL(agent_premium_payout, 0)   
                       CURRENT_SETTLEMENT,  
                       ISNULL(receiver_rate_diff_value, 0) CURRENT_MARGIN,  
                       @buyRate -(  
                           ISNULL(agent_premium_payout, 0) + ISNULL(receiver_rate_diff_value, 0)  
                       ) CURRENT_CUSTOMER,  
                       ROUND(  
                           (ISNULL(ExchangeRate, 0) -ISNULL(agent_premium_send, 0)),  
                           4  
                       ) ho_offer,  
                       ExchangeRate Alter_CURR_SETTLEMENT,  
                       margin_sending_agent Alter_CURR_MARGIN,  
                       SENDING_CUST_EXCHANGERATE Alter_CURR_CUSTOMER,  
                       ROUND(  
                           (@buyRate -ISNULL(agent_premium_payout, 0)) /   
                           ExchangeRate,  
                           roundby  
                       ) SEND_VS_PAYOUT_SETTMENT,  
                 ROUND(  
                           (  
                               @buyRate -(  
                                   ISNULL(agent_premium_payout, 0) + ISNULL(receiver_rate_diff_value, 0)  
                               )  
                           ) / SENDING_CUST_EXCHANGERATE,  
                           roundby  
                       ) SEND_VS_PAYOUT_CUSTOMER,  
                       ROUND(  
                           ((@buyRate -ISNULL(agent_premium_payout, 0)) / ExchangeRate)  
                           -(  
                               (  
                                   @buyRate -(  
                                       ISNULL(agent_premium_payout, 0) +   
                                       ISNULL(receiver_rate_diff_value, 0)  
                                   )  
                               ) / SENDING_CUST_EXCHANGERATE  
                           ),  
                           roundby  
                       ) SEND_VS_PAYOUT_MARGIN,  
                       Customer_rate [Old Rate],  
                       ROUND(  
                           DollarRate / (@sellRate -ISNULL(agent_premium_send, 0)),  
                           @round_value,  
                           1  
                       ) [Effective Rate],  
                       currencyId,  
                       'p' idType,  
                       @country,  
                       @updated_by updated_by,  
                       @session_id session_id,  
                       a.currencyType,  
                       roundby,  
                       ROUND(ISNULL(ExchangeRate, 0) + ISNULL(agent_premium_send, 0), 4)   
                       alt_cost  
                FROM   agentpayout_CurrencyRate e  
                       JOIN agentdetail a  
                            ON  a.agentcode = e.agentid  
                       JOIN agentdetail p  
                            ON  p.agentcode = e.payout_agent_id  
                WHERE  e.payout_agent_id = @payoutAgentID   
                  
                UNION ALL -- Country Wise          
                  
                SELECT 'Selling' ExType,  
                       a.companyName Sender,  
                       receiveCountry,  
                       '-' Receiver,  
                       ExchangeRate [Payout xRate],  
                       @sellRate [Cost],  
                       ISNULL(agent_premium_send, 0) agent_premium_send,  
                       ISNULL(agent_premium_payout, 0) agent_premium_payout,  
                       @sellRate -ISNULL(agent_premium_send, 0)   
                       [SettlementRate],  
                       @sellRate -ISNULL(agent_premium_send, 0)   
                       CURRENT_SETTLEMENT,  
                       ISNULL(margin_sending_agent, 0) CURRENT_MARGIN,  
                       (@sellRate -ISNULL(margin_sending_agent, 0)) -(ISNULL(agent_premium_send, 0))   
                       CURRENT_CUSTOMER,  
                       ROUND(  
                           (ISNULL(DollarRate, 0) -ISNULL(agent_premium_payout, 0)),  
                           4  
                       ) ho_offer,  
                       DollarRate Alter_CURR_SETTLEMENT,  
                       ISNULL(receiver_rate_diff_value, 0) Alter_CURR_MARGIN,  
                       payout_agent_rate Alter_CURR_CUSTOMER,  
                       ROUND(  
                           DollarRate / (@sellRate -ISNULL(agent_premium_send, 0)),  
                           roundby  
                       ) SEND_VS_PAYOUT_SETTMENT,  
                       ROUND(  
                           payout_agent_rate / (  
                               (@sellRate -ISNULL(margin_sending_agent, 0)) -(ISNULL(agent_premium_send, 0))  
                           ),  
                           roundby  
                       ) SEND_VS_PAYOUT_CUSTOMER,  
                       ROUND(  
                           (DollarRate / (@sellRate -ISNULL(agent_premium_send, 0)))   
                           -(  
                               payout_agent_rate / (  
                                   (@sellRate -ISNULL(margin_sending_agent, 0))  
                                   -(ISNULL(agent_premium_send, 0))  
                               )  
                           ),  
                           roundby  
                       ) SEND_VS_PAYOUT_MARGIN,  
                       Customer_rate [Old Rate],  
                       ROUND(  
                           DollarRate / (@sellRate -ISNULL(agent_premium_send, 0)),  
                           @round_value,  
                           1  
                       ) [Effective Rate],  
                       currencyId,  
                       'c' idType,  
                       @country,  
                       @updated_by updated_by,  
                       @session_id session_id,  
                       receiveCtype,  
                       roundby,  
                       ROUND(ISNULL(DollarRate, 0) + ISNULL(agent_premium_payout, 0), 4)   
                       alt_cost  
                FROM   agentCurrencyRate e  
                       JOIN agentdetail a  
                            ON  a.agentcode = e.agentid  
                WHERE  e.agentid = @payoutAgentID   
                UNION ALL --- Agent Wise          
                  
                SELECT 'Selling' ExType,  
                       a.companyName Sender,  
                       receiveCountry,  
                       p.companyName Receiver,  
                       ExchangeRate [Payout xRate],  
                       @sellRate [Cost],  
                       ISNULL(agent_premium_send, 0) agent_premium_send,  
                       ISNULL(agent_premium_payout, 0) agent_premium_payout,  
                       @sellRate -ISNULL(agent_premium_send, 0)   
                       [SettlementRate],  
                       @sellRate -ISNULL(agent_premium_send, 0)   
                       CURRENT_SETTLEMENT,  
                       ISNULL(margin_sending_agent, 0) CURRENT_MARGIN,  
                       (@sellRate -ISNULL(margin_sending_agent, 0)) -(ISNULL(agent_premium_send, 0))   
                       CURRENT_CUSTOMER,  
                       ROUND(  
                           (ISNULL(DollarRate, 0) -ISNULL(agent_premium_payout, 0)),  
                           4  
                       ) ho_offer,  
                       DollarRate Alter_CURR_SETTLEMENT,  
                       ISNULL(receiver_rate_diff_value, 0) Alter_CURR_MARGIN,  
                       payout_agent_rate Alter_CURR_CUSTOMER,  
                       ROUND(  
                           DollarRate / (@sellRate -ISNULL(agent_premium_send, 0)),  
                           roundby  
                       ) SEND_VS_PAYOUT_SETTMENT,  
                       ROUND(  
                           payout_agent_rate / (  
                               (@sellRate -ISNULL(margin_sending_agent, 0)) -(ISNULL(agent_premium_send, 0))  
                           ),  
                           roundby  
                       ) SEND_VS_PAYOUT_CUSTOMER,  
                       ROUND(  
                           (DollarRate / (@sellRate -ISNULL(agent_premium_send, 0)))   
                           -(  
                               payout_agent_rate / (  
                                   (@sellRate -ISNULL(margin_sending_agent, 0))  
                                   -(ISNULL(agent_premium_send, 0))  
                               )  
                           ),  
                           roundby  
                       ) SEND_VS_PAYOUT_MARGIN,  
                       Customer_rate [Old Rate],  
                       ROUND(  
                           DollarRate / (@sellRate -ISNULL(agent_premium_send, 0)),  
                           @round_value,  
                           1  
                       ) [Effective Rate],  
                       currencyId,  
                       'p' idType,  
                       @country,  
                       @updated_by updated_by,  
                       @session_id session_id,  
                       receiveCtype,  
                       roundby,  
                       ROUND(ISNULL(DollarRate, 0) + ISNULL(agent_premium_payout, 0), 4)   
                       alt_cost  
                FROM   agentpayout_CurrencyRate e  
                       JOIN agentdetail a  
                            ON  a.agentcode = e.agentid  
                       JOIN agentdetail p  
                            ON  p.agentcode = e.payout_agent_id  
                WHERE  e.agentid = @payoutAgentID  
            )  
     END  
     ELSE  
     BEGIN  
         --------Country wise ExRate          
           
         INSERT INTO dbo.temp_forex_exchange  
           (  
             exType,  
             sender,  
             receiveCountry,  
             receiver,  
             OldBuyRate,  
             NewBuyRate,  
             OldSelRate,  
             alt_premium,  
             NewSelRate,  
             CURRENT_SETTLEMENT,  
             CURRENT_MARGIN,  
             CURRENT_CUSTOMER,  
             ho_offer,  
             ExchangeRate,  
             margin_sending_agent,  
             SENDING_CUST_EXCHANGERATE,  
             SEND_VS_PAYOUT_SETTMENT,  
             SEND_VS_PAYOUT_CUSTOMER,  
             SEND_VS_PAYOUT_MARGIN,  
             OldEffRate,  
             NewEffRate,  
             currencyId,  
             idType,  
             effictiveCountry,  
             updated_by,  
             session_id,  
             Payout_Currency_Code,  
             roundby,  
             alt_cost  
           )(  
                SELECT 'Buying' ExType, -- B:Buying          
                       a.companyName Sender,  
                       receiveCountry,  
                       receiveCountry Receiver,  
                       DollarRate [CurrentRate],  
                       @buyRate [Cost],  
                       ISNULL(agent_premium_payout, 0) agent_premium_payout,  
                       ISNULL(agent_premium_send, 0) agent_premium_send,  
                       @buyRate -ISNULL(agent_premium_payout, 0)   
                       [SettlementRate],  
                       @buyRate -ISNULL(agent_premium_payout, 0)   
                       CURRENT_SETTLEMENT,  
                       ISNULL(receiver_rate_diff_value, 0) CURRENT_MARGIN,  
                       @buyRate -(  
                           ISNULL(agent_premium_payout, 0) + ISNULL(receiver_rate_diff_value, 0)  
                       ) CURRENT_CUSTOMER,  
                       ROUND(  
                           (ISNULL(ExchangeRate, 0) -ISNULL(agent_premium_send, 0)),  
                           4  
                       ) ho_offer,  
                       ExchangeRate Alter_CURR_SETTLEMENT,  
                       margin_sending_agent Alter_CURR_MARGIN,  
                       SENDING_CUST_EXCHANGERATE Alter_CURR_CUSTOMER,  
                       ROUND(  
                           (@buyRate -ISNULL(agent_premium_payout, 0)) /   
                           ExchangeRate,  
                           roundby  
                       ) SEND_VS_PAYOUT_SETTMENT,  
                       ROUND(  
                           (  
                               @buyRate -(  
                                   ISNULL(agent_premium_payout, 0) + ISNULL(receiver_rate_diff_value, 0)  
                               )  
                           )   
                           / SENDING_CUST_EXCHANGERATE,  
                           roundby  
                       ) SEND_VS_PAYOUT_CUSTOMER,  
                       ROUND(  
                           ((@buyRate -ISNULL(agent_premium_payout, 0)) / ExchangeRate)   
                           -(  
                               (  
                                   @buyRate -(  
                                       ISNULL(agent_premium_payout, 0) +   
                                       ISNULL(receiver_rate_diff_value, 0)  
                                   )  
                               ) / SENDING_CUST_EXCHANGERATE  
                           ),  
          roundby  
                       ) SEND_VS_PAYOUT_MARGIN,  
                       Customer_rate [Old Rate],  
                       ROUND(  
                           ((@buyRate -ISNULL(agent_premium_payout, 0)) / ExchangeRate),  
                           @round_value  
                       ) [Effective Rate],  
                       currencyId,  
                       'c' idType,  
                       @country,  
                       @updated_by updated_by,  
                       @session_id session_id,  
                       a.currencyType,  
                       roundby,  
                       ROUND(ISNULL(ExchangeRate, 0) + ISNULL(agent_premium_send, 0), 4)   
                       alt_cost  
                FROM   agentCurrencyRate e  
                       JOIN agentdetail a  
                            ON  a.agentcode = e.agentid  
                WHERE  ReceiveCountry = @country   
                UNION ALL ----------NEW ADDED by ANOOP  
                          ---  Country wise          
                SELECT 'Selling' ExType,  
                       a.companyName Sender,  
                       receiveCountry,  
                       '-' Receiver,  
                       ExchangeRate [Payout xRate],  
                       @sellRate [Cost],  
                       ISNULL(agent_premium_send, 0) agent_premium_send,  
                       ISNULL(agent_premium_payout, 0) agent_premium_payout,  
                       @sellRate -ISNULL(agent_premium_send, 0)   
                       [SettlementRate],  
                       @sellRate -ISNULL(agent_premium_send, 0)   
                       CURRENT_SETTLEMENT,  
                       ISNULL(margin_sending_agent, 0) CURRENT_MARGIN,  
                       (@sellRate -ISNULL(margin_sending_agent, 0)) -(ISNULL(agent_premium_send, 0))   
                       CURRENT_CUSTOMER,  
                       ROUND(  
                           (ISNULL(DollarRate, 0) -ISNULL(agent_premium_payout, 0)),  
                           4  
                       ) ho_offer,  
                       DollarRate Alter_CURR_SETTLEMENT,  
                       ISNULL(receiver_rate_diff_value, 0) Alter_CURR_MARGIN,  
                       payout_agent_rate Alter_CURR_CUSTOMER,  
                       ROUND(  
                           DollarRate / (@sellRate -ISNULL(agent_premium_send, 0)),  
                           roundby  
                       ) SEND_VS_PAYOUT_SETTMENT,  
                       ROUND(  
                           payout_agent_rate / (  
                               (@sellRate -ISNULL(margin_sending_agent, 0)) -(ISNULL(agent_premium_send, 0))  
                           ),  
                           roundby  
                       ) SEND_VS_PAYOUT_CUSTOMER,  
                       ROUND(  
                           (DollarRate / (@sellRate -ISNULL(agent_premium_send, 0)))   
                           -(  
                               payout_agent_rate / (  
                                   (@sellRate -ISNULL(margin_sending_agent, 0))  
                                   -(ISNULL(agent_premium_send, 0))  
                               )  
                           ),  
                           roundby  
                       ) SEND_VS_PAYOUT_MARGIN,  
                       Customer_rate [Old Rate],  
                       ROUND(  
                           DollarRate / (@sellRate -ISNULL(agent_premium_send, 0)),  
                           @round_value,  
                           1  
                       ) [Effective Rate],  
                       currencyId,  
                       'c' idType,  
                       @country,  
                       @updated_by updated_by,  
                       @session_id session_id,  
                       receiveCtype,  
                       roundby,  
                       ROUND(ISNULL(DollarRate, 0) + ISNULL(agent_premium_payout, 0), 4)   
                       alt_cost  
                FROM   agentCurrencyRate e  
                   JOIN agentdetail a  
                            ON  a.agentcode = e.agentid  
                WHERE  a.country = @country  
                       AND a.agentCode NOT IN (SELECT payoutagentid  
                                               FROM   roster  
                                               WHERE  country = @country  
                                                      AND payoutagentid IS   
                                                          NOT NULL)   
                UNION ALL -- AGENT WISE          
                  
                SELECT 'Selling' ExType,  
                       a.companyName Sender,  
                       receiveCountry,  
                       p.companyName Receiver,  
                       ExchangeRate [Payout xRate],  
                       @sellRate [Cost],  
                       ISNULL(agent_premium_send, 0) agent_premium_send,  
                       ISNULL(agent_premium_payout, 0) agent_premium_payout,  
                       @sellRate -ISNULL(agent_premium_send, 0)   
                       [SettlementRate],  
                       @sellRate -ISNULL(agent_premium_send, 0)   
                       CURRENT_SETTLEMENT,  
                       ISNULL(margin_sending_agent, 0) CURRENT_MARGIN,  
                       (@sellRate -ISNULL(margin_sending_agent, 0)) -(ISNULL(agent_premium_send, 0))   
                       CURRENT_CUSTOMER,  
                       ROUND(  
                           (ISNULL(DollarRate, 0) -ISNULL(agent_premium_payout, 0)),  
                           4  
                       ) ho_offer,  
                       DollarRate Alter_CURR_SETTLEMENT,  
                       ISNULL(receiver_rate_diff_value, 0) Alter_CURR_MARGIN,  
                       payout_agent_rate Alter_CURR_CUSTOMER,  
                       ROUND(  
                           DollarRate / (@sellRate -ISNULL(agent_premium_send, 0)),  
                           roundby  
                       ) SEND_VS_PAYOUT_SETTMENT,  
                       ROUND(  
                           payout_agent_rate / (  
                               (@sellRate -ISNULL(margin_sending_agent, 0)) -(ISNULL(agent_premium_send, 0))  
                           ),  
                           roundby  
                       ) SEND_VS_PAYOUT_CUSTOMER,  
                       ROUND(  
                           (DollarRate / (@sellRate -ISNULL(agent_premium_send, 0)))   
                           -(  
                               payout_agent_rate / (  
                                   (@sellRate -ISNULL(margin_sending_agent, 0))  
                                   -(ISNULL(agent_premium_send, 0))  
                               )  
                           ),  
                           roundby  
                       ) SEND_VS_PAYOUT_MARGIN,  
                       Customer_rate [Old Rate],  
                       ROUND(  
                           DollarRate / (@sellRate -ISNULL(agent_premium_send, 0)),  
                           @round_value,  
                           1  
                       ) [Effective Rate],  
                       currencyId,  
                       'p' idType,  
                       @country,  
                       @updated_by updated_by,  
                       @session_id session_id,  
                       receiveCtype,  
                       roundby,  
                       ROUND(ISNULL(DollarRate, 0) + ISNULL(agent_premium_payout, 0), 4)   
                       alt_cost  
                FROM   agentpayout_CurrencyRate e  
                       JOIN agentdetail a  
                            ON  a.agentcode = e.agentid  
                       JOIN agentdetail p  
                            ON  p.agentcode = e.payout_agent_id  
                WHERE  a.country = @country  
                       AND a.agentCode NOT IN (SELECT payoutagentid  
                                               FROM   roster  
                                               WHERE  country = @country  
                                                      AND payoutagentid IS   
                                                          NOT NULL)   
                             
                             
                           ---ANOOP ADDed END  
            )  
     END                       
     SELECT sno,  
            ExType,  
            Sender,  
            receiveCountry,  
            Receiver,  
            OldBuyRate [Current],  
            NewBuyRate [Cost],  
            OldSelRate [Preimum],  
            alt_premium,  
            NewSelRate [NewRate],  
            currencyId,  
            CURRENT_SETTLEMENT,  
            CURRENT_MARGIN,  
            CURRENT_CUSTOMER,  
            ho_offer,  
            ExchangeRate Alter_CURR_SETTLEMENT,  
            margin_sending_agent Alter_CURR_MARGIN,  
            SENDING_CUST_EXCHANGERATE Alter_CURR_CUSTOMER,  
            SEND_VS_PAYOUT_SETTMENT,  
            SEND_VS_PAYOUT_CUSTOMER,  
            SEND_VS_PAYOUT_MARGIN,  
            OldEffRate [Old Rate],  
            NewEffRate [Effective Rate],  
            currencyId,  
            idType,  
            updated_by,  
            session_id,  
            Payout_Currency_Code,  
            roundby,  
            alt_cost  
     FROM   temp_forex_exchange  
     WHERE  updated_by = @updated_by  
            AND session_id = @session_id  
     ORDER BY  
            exType,  
            receiveCountry,  
            payout_currency_code,  
            sender  
 END           
   
 IF @flag = 'p' --- PREVIEW REPORT  
 BEGIN  
     IF @session_id IS NOT NULL  
     BEGIN  
   exec('SELECT   
    [ExType],sender,  
        receiveCountry,  
             receiver  
     ,[session_id]  
     ,[sno]  
     ,[currencyId]  
     ,[idType]  
     ,[NewBuyRate] [Cost]  
     ,[premium] Preimum  
     ,[Current_SETTLEMENT]  
     ,[CURRENT_MARGIN]  
     ,[Current_Customer]  
     ,[agent_premium_send]  
     ,[ExchangeRate] Alter_CURR_SETTLEMENT  
     ,[margin_sending_agent] Alter_CURR_MARGIN  
     ,[SENDING_CUST_EXCHANGERATE] Alter_CURR_CUSTOMER  
     ,[SEND_VS_PAYOUT_SETTMENT]  
     ,[SEND_VS_Payout_Customer]  
     ,[SEND_VS_Payout_MARGIN]  
     ,[roundby]  
     ,alt_cost  
     ,alt_premium  
     ,Payout_Currency_Code  
         FROM temp_forex_print tfe  
   WHERE tfe.session_id='''+ @session_id +''' AND tfe.sno IN ('+ @effSno+')')  
   DELETE temp_forex_print  
   RETURN  
     END   
     ELSE   
     BEGIN  
            SET @session_id = REPLACE(NEWID(), '-', '_')  
     END          
       
     DELETE dbo.temp_forex_exchange  
     WHERE  session_id = @session_id  
       
     IF @payoutAgentID IS NOT NULL  
     BEGIN  
         INSERT INTO dbo.temp_forex_exchange  
           (  
             exType,  
             sender,  
             receiveCountry,  
             receiver,  
             OldBuyRate,  
             NewBuyRate,  
             OldSelRate,  
             NewSelRate,  
             CURRENT_SETTLEMENT,  
             CURRENT_MARGIN,  
             CURRENT_CUSTOMER,  
             ExchangeRate,  
             margin_sending_agent,  
             SENDING_CUST_EXCHANGERATE,  
             SEND_VS_PAYOUT_SETTMENT,  
             SEND_VS_PAYOUT_CUSTOMER,  
             SEND_VS_PAYOUT_MARGIN,  
             OldEffRate,  
             NewEffRate,  
             currencyId,  
             idType,  
             effictiveCountry,  
             updated_by,  
             session_id,  
             Payout_Currency_Code,  
             roundby,  
             alt_premium,  
             ho_offer,  
             alt_cost  
           )(  
                SELECT 'Buying' ExType,  
                       a.companyName Sender,  
                       receiveCountry,  
                       p.companyName Receiver,  
                       DollarRate [CurrentRate],  
                       DollarRate + ISNULL(agent_premium_payout, 0) [Cost],  
                       ISNULL(agent_premium_payout, 0) agent_premium_payout,  
                       DollarRate [SettlementRate],  
                       DollarRate CURRENT_SETTLEMENT,  
                       ISNULL(receiver_rate_diff_value, 0) CURRENT_MARGIN,  
                       Payout_agent_rate CURRENT_CUSTOMER,  
                       ExchangeRate Alter_CURR_SETTLEMENT,  
                       margin_sending_agent Alter_CURR_MARGIN,  
                       SENDING_CUST_EXCHANGERATE Alter_CURR_CUSTOMER,  
                       NPRRate SEND_VS_PAYOUT_SETTMENT,  
                       Customer_rate SEND_VS_PAYOUT_CUSTOMER,  
                       Customer_diff_value SEND_VS_PAYOUT_MARGIN,  
                       Customer_rate [Old Rate],  
                       Customer_rate [Effective Rate],  
                       currencyId,  
                       'p' idType,  
                       @country,  
                       @updated_by updated_by,  
                       @session_id session_id,  
                       a.currencyType,  
                       roundby,  
                       ISNULL(agent_premium_send, 0) agent_premium_send,  
                       ROUND(  
                           (ISNULL(ExchangeRate, 0) -ISNULL(agent_premium_send, 0)),  
                           4  
                       ) ho_offer,  
                       ROUND(ISNULL(ExchangeRate, 0) + ISNULL(agent_premium_send, 0), 4)   
                       alt_cost  
                FROM   agentpayout_CurrencyRate e  
                       JOIN agentdetail a  
                            ON  a.agentcode = e.agentid  
                       JOIN agentdetail p  
                            ON  p.agentcode = e.payout_agent_id  
                WHERE  e.payout_agent_id = @payoutAgentID   
                  
                UNION ALL -- Country wise          
                  
                SELECT 'Selling' ExType,  
                       companyName Sender,  
                       receiveCountry,  
                       '-' Receiver,  
                       ExchangeRate [Payout xRate],  
                       ExchangeRate + ISNULL(agent_premium_send, 0) [Cost],  
                       ISNULL(agent_premium_send, 0) agent_premium_send,  
                       ExchangeRate [SettlementRate],  
                       ExchangeRate CURRENT_SETTLEMENT,  
                       ISNULL(margin_sending_agent, 0) CURRENT_MARGIN,  
                       SENDING_CUST_EXCHANGERATE CURRENT_CUSTOMER,  
                       DollarRate Alter_CURR_SETTLEMENT,  
                       ISNULL(receiver_rate_diff_value, 0) Alter_CURR_MARGIN,  
                       payout_agent_rate Alter_CURR_CUSTOMER,  
                       NPRRate SEND_VS_PAYOUT_SETTMENT,  
                       Customer_rate SEND_VS_PAYOUT_CUSTOMER,  
                       Customer_diff_value SEND_VS_PAYOUT_MARGIN,  
                       Customer_rate [Old Rate],  
                       Customer_rate [Effective Rate],  
                       currencyId,  
                       'c' idType,  
                       @country,  
                       @updated_by updated_by,  
                       @session_id session_id,  
                       receiveCtype,  
                       roundby,  
                       ISNULL(agent_premium_payout, 0) agent_premium_payout,  
                       ROUND(  
                           (ISNULL(DollarRate, 0) -ISNULL(agent_premium_payout, 0)),  
                           4  
                       ) ho_offer,  
                       ROUND(ISNULL(DollarRate, 0) + ISNULL(agent_premium_payout, 0), 4)   
                       alt_cost  
                FROM   agentCurrencyRate e  
                       JOIN agentdetail a  
                            ON  a.agentcode = e.agentid  
                WHERE  e.agentid = @payoutAgentID   
                UNION ALL -- Agent Wise          
                  
                SELECT 'Selling' ExType,  
                       a.companyName Sender,  
                       receiveCountry,  
                       p.companyName Receiver,  
                       ExchangeRate [Payout xRate],  
                       ExchangeRate + ISNULL(agent_premium_send, 0) [Cost],  
                       ISNULL(agent_premium_send, 0) agent_premium_send,  
                       ExchangeRate [SettlementRate],  
                       ExchangeRate CURRENT_SETTLEMENT,  
                       ISNULL(margin_sending_agent, 0) CURRENT_MARGIN,  
                       SENDING_CUST_EXCHANGERATE CURRENT_CUSTOMER,  
                       DollarRate Alter_CURR_SETTLEMENT,  
                       ISNULL(receiver_rate_diff_value, 0) Alter_CURR_MARGIN,  
                       payout_agent_rate Alter_CURR_CUSTOMER,  
                       NPRRate SEND_VS_PAYOUT_SETTMENT,  
                       Customer_rate SEND_VS_PAYOUT_CUSTOMER,  
                       Customer_diff_value SEND_VS_PAYOUT_MARGIN,  
                       Customer_rate [Old Rate],  
                       Customer_rate [Effective Rate],  
                       currencyId,  
                       'p' idType,  
                       @country,  
                       @updated_by updated_by,  
                       @session_id session_id,  
                       receiveCtype,  
                       roundby,  
                       ISNULL(agent_premium_payout, 0) agent_premium_payout,  
                       ROUND(  
                           (ISNULL(DollarRate, 0) -ISNULL(agent_premium_payout, 0)),  
                           4  
                       ) ho_offer,  
                       ROUND(ISNULL(DollarRate, 0) + ISNULL(agent_premium_payout, 0), 4)   
                       alt_cost  
                FROM   agentpayout_CurrencyRate e  
                       JOIN agentdetail a  
                            ON  a.agentcode = e.agentid  
                       JOIN agentdetail p  
                            ON  p.agentcode = e.payout_agent_id  
                WHERE  e.agentid = @payoutAgentID  
            )  
     END  
     ELSE  
     BEGIN  
         --------Country wise ExRate          
         INSERT INTO dbo.temp_forex_exchange  
           (  
             exType,  
             sender,  
             receiveCountry,  
             receiver,  
             OldBuyRate,  
             NewBuyRate,  
             OldSelRate,  
             NewSelRate,  
             CURRENT_SETTLEMENT,  
             CURRENT_MARGIN,  
             CURRENT_CUSTOMER,  
             ExchangeRate,  
             margin_sending_agent,  
             SENDING_CUST_EXCHANGERATE,  
             SEND_VS_PAYOUT_SETTMENT,  
             SEND_VS_PAYOUT_CUSTOMER,  
             SEND_VS_PAYOUT_MARGIN,  
             OldEffRate,  
             NewEffRate,  
             currencyId,  
             idType,  
             effictiveCountry,  
             updated_by,  
             session_id,  
             Payout_Currency_Code,  
             roundby,  
             alt_premium,  
             ho_offer,  
             alt_cost  
           )(  
                SELECT 'Buying' ExType, -- B:Buying          
                       a.companyName Sender,  
                       receiveCountry,  
                       receiveCountry Receiver,  
                       DollarRate [CurrentRate],  
                       DollarRate + ISNULL(agent_premium_payout, 0) [Cost],  
                       ISNULL(agent_premium_payout, 0) agent_premium_payout,  
                       DollarRate [SettlementRate],  
                       DollarRate CURRENT_SETTLEMENT,  
                       ISNULL(receiver_rate_diff_value, 0) CURRENT_MARGIN,  
                       Payout_agent_rate CURRENT_CUSTOMER,  
                       ExchangeRate Alter_CURR_SETTLEMENT,  
                       margin_sending_agent Alter_CURR_MARGIN,  
                       SENDING_CUST_EXCHANGERATE Alter_CURR_CUSTOMER,  
                       NPRRate SEND_VS_PAYOUT_SETTMENT,  
                       Customer_rate SEND_VS_PAYOUT_CUSTOMER,  
                       Customer_diff_value SEND_VS_PAYOUT_MARGIN,  
                       Customer_rate [Old Rate],  
                       Customer_rate [Effective Rate],  
                       currencyId,  
                       'c' idType,  
                       @country,  
                       @updated_by updated_by,  
                       @session_id session_id,  
                       a.currencyType,  
                       roundby,  
                       ISNULL(agent_premium_send, 0) agent_premium_send,  
                       ROUND(  
                           (ISNULL(DollarRate, 0) -ISNULL(agent_premium_payout, 0)),  
                           4  
                       ) ho_offer,  
                       ROUND(ISNULL(DollarRate, 0) + ISNULL(agent_premium_payout, 0), 4)   
                       alt_cost  
                FROM   agentCurrencyRate e  
                       JOIN agentdetail a  
                            ON  a.agentcode = e.agentid  
                WHERE  ReceiveCountry = @country   
                UNION ALL ----------NEW ADDED by ANOOP  
                          --Country Wise          
                SELECT 'Selling' ExType,  
                       a.companyName Sender,  
                       receiveCountry,  
                       '-' Receiver,  
                       ExchangeRate [Payout xRate],  
                       ExchangeRate + ISNULL(agent_premium_send, 0) [Cost],  
                       ISNULL(agent_premium_send, 0) agent_premium_send,  
                       ExchangeRate [SettlementRate],  
                       ExchangeRate CURRENT_SETTLEMENT,  
                       ISNULL(margin_sending_agent, 0) CURRENT_MARGIN,  
                       (ExchangeRate -ISNULL(margin_sending_agent, 0))   
                       CURRENT_CUSTOMER,  
                       DollarRate Alter_CURR_SETTLEMENT,  
                       ISNULL(receiver_rate_diff_value, 0) Alter_CURR_MARGIN,  
                       payout_agent_rate Alter_CURR_CUSTOMER,  
                       ROUND(DollarRate / ExchangeRate, roundby)   
                       SEND_VS_PAYOUT_SETTMENT,  
                       ROUND(  
                           payout_agent_rate / (ExchangeRate -ISNULL(margin_sending_agent, 0)),  
                           roundby  
                       ) SEND_VS_PAYOUT_CUSTOMER,  
                       ROUND(  
                           (DollarRate / ExchangeRate)   
                           -(  
                               payout_agent_rate / (ExchangeRate -ISNULL(margin_sending_agent, 0))  
                           ),  
                           roundby  
                       ) SEND_VS_PAYOUT_MARGIN,  
                       Customer_rate [Old Rate],  
                       ROUND(DollarRate / (ExchangeRate), @round_value, 1)   
                       [Effective Rate],  
                       currencyId,  
                       'c' idType,  
                       @country,  
                       @updated_by updated_by,  
                       @session_id session_id,  
                       receiveCtype,  
                       roundby,  
                       ISNULL(agent_premium_payout, 0) agent_premium_payout,  
                       ROUND(  
                           (ISNULL(ExchangeRate, 0) -ISNULL(agent_premium_send, 0)),  
                           4  
                       ) ho_offer,  
                       ROUND(ISNULL(ExchangeRate, 0) + ISNULL(agent_premium_send, 0), 4)   
                       alt_cost  
                FROM   agentCurrencyRate e  
                       JOIN agentdetail a  
                            ON  a.agentcode = e.agentid  
                WHERE  a.country = @country  
                       AND a.agentCode NOT IN (SELECT payoutagentid  
                                               FROM   roster  
                                               WHERE  country = @country  
                                                      AND payoutagentid IS   
                                                          NOT NULL)   
                UNION ALL -- Agent Wise          
                SELECT 'Selling' ExType,  
                       a.companyName Sender,  
                       receiveCountry,  
                       p.companyName Receiver,  
                       ExchangeRate [Payout xRate],  
                       ExchangeRate + ISNULL(agent_premium_send, 0) [Cost],  
                       ISNULL(agent_premium_send, 0) agent_premium_send,  
                       ExchangeRate [SettlementRate],  
                       ExchangeRate CURRENT_SETTLEMENT,  
                       ISNULL(margin_sending_agent, 0) CURRENT_MARGIN,  
                       (ExchangeRate -ISNULL(margin_sending_agent, 0))   
                       CURRENT_CUSTOMER,  
                       DollarRate Alter_CURR_SETTLEMENT,  
                       ISNULL(receiver_rate_diff_value, 0) Alter_CURR_MARGIN,  
                       payout_agent_rate Alter_CURR_CUSTOMER,  
                       ROUND(DollarRate / ExchangeRate, roundby)   
                       SEND_VS_PAYOUT_SETTMENT,  
                       ROUND(  
                           payout_agent_rate / (ExchangeRate -ISNULL(margin_sending_agent, 0)),  
                           roundby  
                       ) SEND_VS_PAYOUT_CUSTOMER,  
                       ROUND(  
                           (DollarRate / ExchangeRate)   
                           -(  
                               payout_agent_rate / (ExchangeRate -ISNULL(margin_sending_agent, 0))  
                           ),  
                           roundby  
                       ) SEND_VS_PAYOUT_MARGIN,  
                       Customer_rate [Old Rate],  
                       ROUND(DollarRate / (ExchangeRate), @round_value, 1)   
                       [Effective Rate],  
                       currencyId,  
                       'c' idType,  
                       @country,  
                       @updated_by updated_by,  
                       @session_id session_id,  
                       receiveCtype,  
                       roundby,  
                       ISNULL(agent_premium_payout, 0) agent_premium_payout,  
                       ROUND(  
                           (ISNULL(ExchangeRate, 0) -ISNULL(agent_premium_send, 0)),  
                           4  
                       ) ho_offer,  
                       ROUND(ISNULL(ExchangeRate, 0) + ISNULL(agent_premium_send, 0), 4)   
                       alt_cost  
                FROM   agentpayout_CurrencyRate e  
                       JOIN agentdetail a  
                            ON  a.agentcode = e.agentid  
                       JOIN agentdetail p  
                            ON  p.agentcode = e.payout_agent_id  
                WHERE  a.country = @country  
                       AND a.agentCode NOT IN (SELECT payoutagentid  
                                               FROM   roster  
                                               WHERE  country = @country  
                                                      AND payoutagentid IS   
                                                          NOT NULL)   
                             
                             
                           ---ANOOP ADDed END  
            )  
     END                       
     SELECT sno,  
            ExType,  
            Sender,  
            receiveCountry,  
            Receiver,  
            OldBuyRate [Current],  
            NewBuyRate [Cost],  
            OldSelRate [Preimum],  
            NewSelRate [NewRate],  
            currencyId,  
            CURRENT_SETTLEMENT,  
            CURRENT_MARGIN,  
            CURRENT_CUSTOMER,  
            ExchangeRate Alter_CURR_SETTLEMENT,  
            margin_sending_agent Alter_CURR_MARGIN,  
            SENDING_CUST_EXCHANGERATE Alter_CURR_CUSTOMER,  
            SEND_VS_PAYOUT_SETTMENT,  
            SEND_VS_PAYOUT_CUSTOMER,  
            SEND_VS_PAYOUT_MARGIN,  
            OldEffRate [Old Rate],  
            NewEffRate [Effective Rate],  
            currencyId,  
            idType,  
            updated_by,  
            session_id,  
            Payout_Currency_Code,  
            roundby,  
            alt_premium,  
            ho_offer,  
            alt_cost  
     FROM   temp_forex_exchange  
     WHERE  updated_by = @updated_by  
            AND session_id = @session_id  
     ORDER BY  
            exType,  
            receiveCountry,  
            sender  
 END  
   
 IF @flag = 'c'  
 BEGIN  
     DECLARE @sql   VARCHAR(5000),  
             @sqlC  VARCHAR(5000),  
             @sql1  VARCHAR(5000)  
       
     SET @effSno = REPLACE(@effSno, ' ', '')          
       
     DECLARE @idoc  INT          
     DECLARE @doc   VARCHAR(8000)   
       
     -- FROM   OPENXML (@idoc, '/ExRate/Rate',2)  
     --         WITH ( currencyid int '@currencyId',  
     --    sno  int   '@sno',  
     --                premium  money '@premium',  
     --                CURRENT_MARGIN  money '@CURRENT_MARGIN',  
     --                Alter_CURR_MARGIN  money '@ALTER_CURR_MARGIN',  
     --    roundby  int '@roundby',  
     --    alt_premium money '@alt_premium'  
     --   )  
     --            
     EXEC sp_xml_preparedocument @idoc OUTPUT,  
          @xmlData   
     -----------------------------------------------------------------          
     SELECT * INTO #ztbl_xmlvalue  
     FROM   OPENXML(@idoc, '/ER/r', 2)   
            WITH (  
                currencyid INT '@cid',  
                sno INT '@sno',  
                premium MONEY '@p',  
                alt_premium MONEY '@ap'  
            )  
       
     EXEC sp_xml_removedocument @idoc          
       
  INSERT temp_forex_print([ExType],  
  sender,  
        receiveCountry,  
             receiver  
      ,[session_id]  
      ,[sno]  
      ,[currencyId]  
      ,[idType]  
      ,[NewBuyRate]  
      ,[premium]  
      ,[Current_SETTLEMENT]  
      ,[CURRENT_MARGIN]  
      ,[Current_Customer]  
      ,[agent_premium_send]  
      ,[ExchangeRate]  
      ,[margin_sending_agent]  
      ,[SENDING_CUST_EXCHANGERATE]  
      ,[SEND_VS_PAYOUT_SETTMENT]  
      ,[SEND_VS_Payout_Customer]  
      ,[SEND_VS_Payout_MARGIN]  
      ,[roundby])  
     SELECT t.ExType,t.sender,t.receiveCountry,t.receiver,  
            t.session_id,  
            t.sno,  
            x.currencyId,  
            t.idType,  
            NewBuyRate,  
            x.premium,  
            ROUND(NewBuyRate - x.premium, 6) Current_SETTLEMENT,  
            t.CURRENT_MARGIN,  
            ROUND((NewBuyRate - x.premium) -t.CURRENT_MARGIN, 6)   
            Current_Customer,  
            x.alt_premium agent_premium_send,  
            CASE   
                 WHEN x.alt_premium = t.alt_premium THEN ExchangeRate  
                 ELSE ROUND(((t.alt_premium + t.ExchangeRate) -x.alt_premium), 6)  
            END ExchangeRate,  
            margin_sending_agent,  
            CASE   
                 WHEN x.alt_premium = t.alt_premium THEN   
                      SENDING_CUST_EXCHANGERATE  
                 ELSE ROUND(  
                          (  
                              ((t.alt_premium + t.ExchangeRate) -x.alt_premium)  
                              -t.margin_sending_agent  
                          ),  
                          6  
                      )  
            END SENDING_CUST_EXCHANGERATE,  
            CASE   
                 WHEN x.alt_premium = t.alt_premium THEN ROUND(  
                          CASE   
                               WHEN exType = 'Buying' THEN ((NewBuyRate - x.premium) / ExchangeRate)  
                               ELSE (ExchangeRate / (NewBuyRate - x.premium))  
                          END,  
                          t.roundby  
                      )  
                 ELSE ROUND(  
                          CASE   
                               WHEN exType = 'Buying' THEN (  
                                        (NewBuyRate - x.premium) / (t.alt_premium + t.ExchangeRate -x.alt_premium)  
                                    )  
                               ELSE (  
                                        (t.alt_premium + t.ExchangeRate -x.alt_premium)  
                                        / (NewBuyRate - x.premium)  
                                    )  
                          END,  
                         t.roundby  
                      )  
            END SEND_VS_PAYOUT_SETTMENT,  
            CASE   
                 WHEN x.alt_premium = t.alt_premium THEN ROUND(  
                          CASE   
                               WHEN exType = 'Buying' THEN (  
                                        ((NewBuyRate - x.premium) -t.CURRENT_MARGIN)  
                                        / (SENDING_CUST_EXCHANGERATE)  
                                    )  
                               ELSE (  
                                        SENDING_CUST_EXCHANGERATE / ((NewBuyRate - x.premium) -t.CURRENT_MARGIN)  
                                    )  
                          END,  
                          t.roundby  
                      )  
                 ELSE ROUND(  
                          CASE   
                               WHEN exType = 'Buying' THEN (  
                                        ((NewBuyRate - x.premium) -t.CURRENT_MARGIN)  
                                        / (  
                                            (  
                                                ((t.alt_premium + t.ExchangeRate) -x.alt_premium)  
                                                -t.margin_sending_agent  
                                            )  
                                        )  
                                    )  
                               ELSE (  
                                        ((t.alt_premium + t.ExchangeRate) - x.alt_premium)  
                                        + t.margin_sending_agent  
                                    ) / ((NewBuyRate - x.premium) -t.CURRENT_MARGIN)  
                          END,  
                          t.roundby  
                      )  
            END SEND_VS_Payout_Customer,  
            CASE   
                 WHEN x.alt_premium = t.alt_premium THEN ROUND(  
                          CASE   
                               WHEN exType = 'Buying' THEN (  
                                        ((NewBuyRate - x.premium) / ExchangeRate)  
                                        -(  
                                            ((NewBuyRate - x.premium) -t.CURRENT_MARGIN)  
                                            / (SENDING_CUST_EXCHANGERATE)  
                                        )  
                                    )  
                               ELSE (  
                                        (ExchangeRate / (NewBuyRate - x.premium))  
                                        -(  
                                            SENDING_CUST_EXCHANGERATE / ((NewBuyRate - x.premium) -t.CURRENT_MARGIN)  
                                        )  
                                    )  
                          END,  
                          t.roundby  
                      )  
                 ELSE ROUND(  
                          CASE   
                               WHEN exType = 'Buying' THEN (  
                                        (  
                                            (NewBuyRate - x.premium) / (t.alt_premium + t.ExchangeRate -x.alt_premium)  
                                        ) -(  
                                            ((NewBuyRate - x.premium) -t.Current_MARGIN)  
                                            / (  
                                                (  
                                                    ((t.alt_premium + t.ExchangeRate) -x.alt_premium)  
                                                    -t.margin_sending_agent  
                                                )  
                                            )  
                                        )  
                                    )  
                               ELSE (  
                                        (  
                                            (t.alt_premium + t.ExchangeRate -x.alt_premium)  
                                            / (NewBuyRate - x.premium)  
                                        ) -(  
                     (  
                                                ((t.alt_premium + t.ExchangeRate) -x.alt_premium)  
                                                + t.margin_sending_agent  
                                            ) / ((NewBuyRate - x.premium) -t.CURRENT_MARGIN)  
                                        )  
                                    )  
                          END,  
                          t.roundby  
                      )  
            END SEND_VS_Payout_MARGIN,  
            t.roundby   
          
     FROM   temp_forex_exchange t  
            JOIN #ztbl_xmlvalue x  
                 ON  t.sno = x.sno  
                 AND t.currencyId = x.currencyId   
       
    
       
     DECLARE @sql_country VARCHAR(8000)          
       
     SET @sql_country =   
         'update agentCurrencyRate set          
     agent_premium_payout=case when t.exType=''Buying'' then t.premium else t.agent_premium_send end,          
     agent_premium_send=case when t.exType=''Buying'' then t.agent_premium_send else t.premium end,          
     dollarrate=case when t.exType=''Buying'' then t.Current_settlement else t.ExchangeRate end,          
     ExchangeRate= case when t.exType=''Buying'' then t.ExchangeRate else t.Current_settlement end,          
     receiver_rate_diff_value=isNull(case when t.exType=''Buying'' then t.Current_Margin else r.receiver_rate_diff_value end,0),          
     margin_sending_agent=isNull(case when t.exType=''Selling'' then t.Current_Margin else r.margin_sending_agent end,0),          
     payout_agent_rate=case when t.exType=''Buying'' then t.Current_Customer else t.SENDING_CUST_EXCHANGERATE end,          
     SENDING_CUST_EXCHANGERATE=case when t.exType=''Buying'' then t.SENDING_CUST_EXCHANGERATE else t.Current_Customer end,          
     NPRRate =t.SEND_VS_PAYOUT_SETTMENT,          
     Customer_rate = t.SEND_VS_PAYOUT_CUSTOMER,          
     customer_diff_value = t.SEND_VS_PAYOUT_Margin,          
     customer_diff_value_type = ''F'',          
     update_ts=dbo.getDateHO(getutcdate()),          
     update_by=''HO:' + @updated_by + ''',          
     roundby=t.roundby,          
     audit_process_id=''' + @session_id + '''          
     from agentCurrencyRate r,  temp_forex_print t          
     where r.currencyid=t.currencyid and t.idtype=''c''           
     and sno in (' + @effSno + ')          
     and t.session_id=''' + @session_id + ''''   
       
            
     EXEC (@sql_country)          
     SET @sql =   
         'update agentpayout_CurrencyRate set           
     agent_premium_payout=case when t.exType=''Buying'' then t.premium else t.agent_premium_send end,          
     agent_premium_send=case when t.exType=''Buying'' then t.agent_premium_send else t.premium end,          
     dollarrate=case when t.exType=''Buying'' then t.Current_settlement else t.ExchangeRate end,          
     ExchangeRate= case when t.exType=''Buying'' then t.ExchangeRate else t.Current_settlement end,          
     receiver_rate_diff_value=isNull(case when t.exType=''Buying'' then t.Current_Margin else r.receiver_rate_diff_value end,0),          
     margin_sending_agent=isNull(case when t.exType=''Selling'' then t.Current_Margin else r.margin_sending_agent end,0),          
     payout_agent_rate=case when t.exType=''Buying'' then t.Current_Customer else t.SENDING_CUST_EXCHANGERATE end,          
     SENDING_CUST_EXCHANGERATE=case when t.exType=''Buying'' then t.SENDING_CUST_EXCHANGERATE else t.Current_Customer end,          
     NPRRate =t.SEND_VS_PAYOUT_SETTMENT,          
     Customer_rate = t.SEND_VS_PAYOUT_CUSTOMER,          
     customer_diff_value = t.SEND_VS_PAYOUT_Margin,          
     customer_diff_value_type = ''F'',          
     update_ts=dbo.getDateHO(getutcdate()) ,          
     update_by=''HO:' + @updated_by + ''',          
     roundby=t.roundby ,          
     audit_process_id=''' + @session_id + '''             
     from agentpayout_CurrencyRate r, temp_forex_print t          
   where r.currencyid=t.currencyid and t.idtype=''p''           
     and sno in (' + @effSno + ') and t.session_id=''' + @session_id + ''''   
     -- print @sql          
     EXEC (@sql)   
     --  END           
       
     UPDATE roster  
     SET    buyRate = @buyRate,  
            sellRate = @sellRate,  
            rateDiff = @sellRate -@buyRate,  
            updated_by = @updated_by,  
            updated_ts = dbo.getDateHO(GETUTCDATE()),  
            Round_By = @round_value,  
            audit_process_id = @session_id,  
            buy_sell_margin = @sellRate -@buyRate  
     WHERE  sno = @sno          
       
       
       
     EXEC [spa_NotificationExRate] @session_id,  
          @effSno   
     ----update to partner's System    
     EXEC [spa_ExRateUpdatePartner] @session_id,  
          @effSno,  
          @updated_by    
       
     DELETE temp_forex_exchange  
     WHERE  session_id = @session_id  
--       
     SELECT 'Success' STATUS,  
            'The Forex of ' + @country + ' is updated sucessfully' msg  
 END