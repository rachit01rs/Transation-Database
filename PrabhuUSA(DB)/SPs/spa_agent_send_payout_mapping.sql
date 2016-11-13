IF OBJECT_ID('spa_agent_send_payout_mapping', 'P') IS NOT NULL 
    DROP PROC [dbo].[spa_agent_send_payout_mapping]

GO

CREATE PROC [dbo].[spa_agent_send_payout_mapping]
    @flag CHAR(1) ,
    @sno INT = NULL ,
    @send_agent_id VARCHAR(50) = NULL ,
    @pay_agent_id VARCHAR(50) = NULL ,
    @update_by VARCHAR(50) = NULL ,
    @sCountry VARCHAR(50) = NULL ,
    @rCountry VARCHAR(50) = NULL
AS /*  
   
 @flag =  
	's' => Select all the value from agent_send_payout_mapping  
    'a' => Select one record from agent_send_payout_mapping  
    'i' => Inserting data in agent_send_payout_mapping  
    'u' => Update data in agent_send_payout_mapping  
    'd' => Delete data by sno in agent_send_payout_mapping     
 */  
    IF @flag = 's' 
        BEGIN  
            DECLARE @SQL VARCHAR(MAX)  
            SET @SQL = 'SELECT sno,send_agent_id,pay_agent_id,s.companyName sender,s.country sCountry, '
                + ' r.companyName Receiver,r.country rCountry,update_ts,update_by '
                + ' FROM agent_send_payout_mapping m JOIN AgentDetail s ON s.agentcode=m.send_agent_id '
                + ' JOIN AgentDetail r ON r.agentcode=m.pay_agent_id WHERE 1=1 '  
            IF @sCountry IS NOT NULL 
                BEGIN   
                    SET @SQL = @SQL + ' AND s.country=''' + @sCountry + ''''  
                END   
            IF @send_agent_id IS NOT NULL 
                BEGIN   
                    SET @SQL = @SQL + ' AND send_agent_id=''' + @send_agent_id
                        + ''''  
                END  
            IF @rCountry IS NOT NULL 
                BEGIN   
                    SET @SQL = @SQL + ' AND r.country=''' + @rCountry + ''''  
                END  
            SET @SQL = @SQL + ' order by s.country,sender'  
  --print(@SQL)  
            EXECUTE(@SQL)  
        END   
    IF @flag = 'a' 
        BEGIN
            SELECT  sno ,
                    send_agent_id ,
                    pay_agent_id ,
                    update_ts ,
                    update_by
            FROM    agent_send_payout_mapping
            WHERE   sno = @sno  
        END 
          
    IF @flag = 'i' 
        BEGIN    
            IF NOT EXISTS ( SELECT  sno
                            FROM    agent_send_payout_mapping
                            WHERE   send_agent_id = @send_agent_id
                                    AND pay_agent_id = @pay_agent_id ) 
                BEGIN     
                    INSERT  INTO agent_send_payout_mapping
                            ( send_agent_id ,
                              pay_agent_id ,
                              update_ts ,
                              update_by
                            )
                    VALUES  ( @send_agent_id ,
                              @pay_agent_id ,
                              dbo.getDateHO(GETUTCDATE()) ,
                              @update_by
                            )    
                    SELECT  'Success' status ,
                            'Successfully Inserted' msg    
                END    
            ELSE 
                SELECT  'Error' status ,
                        'Dublicate Mapping found' msg    
        END 
           
    IF @flag = 'u' 
        BEGIN    
            IF NOT EXISTS ( SELECT  sno
                            FROM    agent_send_payout_mapping
                            WHERE   send_agent_id = @send_agent_id
                                    AND pay_agent_id = @pay_agent_id
                                    AND sno <> @sno ) 
                BEGIN     
                    UPDATE  agent_send_payout_mapping
                    SET     send_agent_id = @send_agent_id ,
                            pay_agent_id = @pay_agent_id ,
                            update_ts = dbo.getDateHO(GETUTCDATE()) ,
                            update_by = @update_by
                    WHERE   sno = @sno    
                    SELECT  'Success' status ,
                            'Successfully Updated' msg    
                END    
            ELSE 
                SELECT  'Error' status ,
                        'Dublicate Mapping found' msg    
        END    
        
    IF @flag = 'd' 
        BEGIN    
            DELETE  FROM agent_send_payout_mapping
            WHERE   sno = @sno    
            SELECT  'Success' status ,
                    'Successfully Deleted' msg    
        END
GO
