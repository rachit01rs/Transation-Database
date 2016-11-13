  DROP proc spa_MPOS_ExRateCountry_Setup
  go
  
  
CREATE PROCEDURE [dbo].[spa_MPOS_ExRateCountry_Setup]  
    (  
      @flag VARCHAR(5) ,  
      @agent_id VARCHAR(10) = NULL ,  
      @s_charge MONEY = NULL ,  
      @commission MONEY = NULL ,  
      @discount MONEY = NULL ,  
      @country_sno INT = NULL ,  
      @agent_deno_sno INT = NULL,        
      @selling_price MONEY =NULL    
    
    )  
AS   
    BEGIN  
        DECLARE @sql VARCHAR(MAX)  
        IF @flag = 's'  
 --show assigned country of agent  
            BEGIN   
                SET @sql = 'SELECT  mrr.agent_id, mrr.agent_deno_sno ,c.country_name,c.sno,isnull(mrr.selling_price,0.00) selling_price,
                ra.CompanyName agent_name,isnull(d.price_value,0.00) price_value, mrr.service_charge,mrr.discount  
     ,mrr.agent_comission, op.operator_name   
   FROM MPOS_tblmobile_Agent_Rate mrr WITH (NOLOCK)  
   INNER JOIN MPOS_tbldenomination d WITH (NOLOCK) ON mrr.mobile_demination_sno = d.sno  
   INNER JOIN  MPOS_tbloperator op WITH (NOLOCK) ON d.operator_sno = op.sno  
   INNER JOIN dbo.tblCountry c WITH (NOLOCK) ON mrr.country_sno = c.sno 
	INNER JOIN dbo.agentDetail ra WITH(NOLOCK) ON mrr.agent_id =ra.agentCode  WHERE 1=1 AND  ISNULL(c.provider_id,'''') <> '''' '   
     
                IF @agent_id IS NOT NULL   
                    SET @sql = @sql + '  AND mrr.agent_id =' + @agent_id  
     
                IF @country_sno IS NOT NULL   
                    SET @sql = @sql + '  AND mrr.country_sno ='  
                        + CAST(@country_sno AS VARCHAR(10))  
     
     
                SET @sql = @sql + ' Order by c.country_name asc,op.operator_name, price_value  '  
                    EXEC (@sql)    
  
            END  
   
   
        IF @flag = 'i'  
 --import all the info based on country and assign to agent and its respective clients only  
            BEGIN  
                BEGIN TRY  
                    BEGIN TRANSACTION trancountry  
                    
                    IF NOT EXISTS(SELECT country_sno FROM dbo.MPOS_tbldenomination WHERE country_sno = @country_sno )
                    BEGIN
                             SELECT  'ERROR' STATUS ,  
                            'Country assignment UNSUCCESSFUL as denomination not found!!' MSG
                            RETURN 
                    END
 --assign to agent  
                    INSERT  INTO dbo.MPOS_tblmobile_Agent_Rate  
                            ( agent_id ,  
                              mobile_demination_sno ,  
                              selling_price ,  
                              service_charge ,  
                              agent_comission ,  
                              discount ,  
                              country_sno  
                       )  
                            SELECT  @agent_id ,  
                                    d.sno ,  
                                    price_value - ( ( @discount / 100 )  
                                                    * price_value ) ,  
                                    @s_charge ,  
                                    @commission ,  
                                    @discount ,  
                                    @country_sno  
                            FROM    dbo.MPOS_tbldenomination d WITH ( NOLOCK )  
                                    INNER JOIN dbo.tblCountry c WITH ( NOLOCK ) ON d.country_sno = c.sno  
                            WHERE   ISNULL(c.provider_id, '') <> ''  
                                    AND country_sno = @country_sno  
   
 --assign TO  its user  
            

    INSERT INTO dbo.MPOS_tblMobile_User_Rate
        ( agent_deno_sno ,
          agentCode ,
          agentBranchCode ,
          user_id ,
          selling_price ,
          service_charge ,
          user_commission ,
          discount
        )
        SELECT  agent_deno_sno ,  
		        ag.agentCode , 
                ag.agent_branch_code,
                ag.agent_user_id, 
                selling_price ,  
                service_charge ,  
                agent_comission ,  
                discount  
                FROM    dbo.MPOS_tblmobile_Agent_Rate mrr WITH (NOLOCK)  
                INNER JOIN dbo.agentDetail ad WITH ( NOLOCK ) ON ad.agentCode=mrr.agent_id
				INNER JOIN dbo.agentbranchdetail a WITH ( NOLOCK ) ON a.agentCode=ad.agentCode
				INNER JOIN dbo.agentsub ag WITH ( NOLOCK ) ON ag.agentCode=ad.agentCode AND ag.agent_branch_code=a.agent_branch_code
				WHERE   ad.agentcode = @agent_id
     
                    SELECT  'SUCCESS' STATUS ,  
                            ' Country assigned SUCCESSFULLY ' MSG      
                    COMMIT TRANSACTION trancountry  
   
                END TRY   
   
   
                BEGIN CATCH  
                    IF @@trancount > 1   
                        ROLLBACK TRANSACTION trancountry  
              
                    SELECT  'ERROR' STATUS ,  
                            'Country assignment UNSUCCESSFUL ' MSG      
              
                END CATCH  
   
            END   
   
   
        IF @flag = 'r'   
            BEGIN  
                BEGIN TRY  
                    BEGIN TRANSACTION delcountry  
   
 ----de-assign country from agent  
                    DELETE  FROM dbo.MPOS_tblMobile_User_Rate  
                    WHERE   agent_deno_sno IN (  
                            SELECT  agent_deno_sno  
                            FROM    dbo.MPOS_tblmobile_Agent_Rate  
                            WHERE   country_sno = @country_sno  
                                    AND agent_id = @agent_id )  
     
 --de-assign country from agent's clients  
                    DELETE  FROM MPOS_tblmobile_Agent_Rate  
                    WHERE   country_sno = @country_sno  
                            AND agent_id = @agent_id  
    
                    SELECT  'SUCCESS' STATUS ,  
                            'Country deassigned Successfully ! ' MSG  
                    COMMIT TRANSACTION delcountry  
                END TRY  
   
                BEGIN CATCH  
                    IF @@trancount > 1   
                        ROLLBACK TRANSACTION delcountry  
                    SELECT  'ERROR' STATUS ,  
                            'Deassigning Unsuccessful! ' MSG  
                END CATCH  
            END    
   
        IF @flag = 'u'   
            BEGIN  
                BEGIN TRY  
                    BEGIN TRANSACTION rates  
                    UPDATE  dbo.MPOS_tblmobile_Agent_Rate  
                    SET     agent_comission = @commission ,  
                            service_charge = @s_charge ,  
                            discount = @discount,        
                            selling_price = @selling_price  
                    WHERE   agent_deno_sno = @agent_deno_sno  
      
                    UPDATE  dbo.MPOS_tblMobile_User_Rate  
                    SET     user_commission = @commission ,  
                            service_charge = @s_charge ,  
                            discount = @discount,        
                            selling_price = @selling_price  
                    WHERE   agent_deno_sno = @agent_deno_sno  
      
      
                    SELECT  'SUCCESS' STATUS ,  
                            'Rate updated Successful! ' MSG  
                    COMMIT TRANSACTION rates  
                END TRY  
   
                BEGIN CATCH  
   
                    IF @@trancount > 1   
                        ROLLBACK TRANSACTION rates  
      
                    SELECT  'ERROR' STATUS ,  
                            'Rate updated Unsuccessful! ' MSG  
           -- EXEC Error_Info_log '', 'spa_ExRateCountry_Setup', 'SP', ''   
    
                END CATCH  
            END  
   
        IF @flag = 'sa'   
            BEGIN  
                SELECT DISTINCT  
                        ( c.country_name ) country ,  
                        mrr.agent_id agent_id ,  
                        c.sno ,  
                        ra.CompanyName agent_name  
                FROM    MPOS_tblmobile_Agent_Rate mrr WITH ( NOLOCK )  
						  INNER JOIN dbo.agentDetail ra WITH(NOLOCK) ON mrr.agent_id =ra.agentCode  
                        INNER JOIN dbo.tblCountry c WITH ( NOLOCK ) ON mrr.country_sno = c.sno  
                WHERE   1 = 1  
                        AND ISNULL(c.provider_id, '') <> ''  
                ORDER BY ra.CompanyName ASC  
      
  
            END  
  
    END  
  
  