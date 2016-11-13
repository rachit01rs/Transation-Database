/*
DATE: 2011 Oct 13 Thu
*/
IF OBJECT_ID('spa_ExRateAll_New', 'P') IS NOT NULL 
    DROP PROCEDURE spa_ExRateAll_New
GO
CREATE PROC [dbo].[spa_ExRateAll_New]
    @agent_id VARCHAR(50) = NULL ,
    @user_admin VARCHAR(50) = NULL ,
    @country VARCHAR(150) = NULL ,
    @payout_country VARCHAR(150) = NULL ,
    @payout_agent_id VARCHAR(50) = NULL ,
    @sAgentCode VARCHAR(50) = NULL
AS 
    DECLARE @sql VARCHAR(5000)  
  
    IF @user_admin IS NOT NULL
        AND @country IS NULL 
        SELECT  @country = country
        FROM    admintable
        WHERE   cUser = @user_admin  
  
    IF @country = 'Nepal' 
        SET @country = NULL  
  
  
    SET @sql = 'select * from 
				(  
				   SELECT   a.country ,
							'''' PayoutAgent ,
							'''' Branch ,
							ISNULL(a.agent_short_code, a.CompanyName) agent_short_code ,
							r.CurrencyType ,
							ReceiveCountry ,
							a.CompanyName CompanyName ,
							r.ReceiveCType ,
							ExchangeRate ,
							NPRRate SettlementRate ,
							DollarRate ,
							r.Customer_Rate ,
							update_by ,
							update_ts ,
							ISNULL(agent_premium_payout, 0) agent_premium_payout ,
							ISNULL(agent_premium_send, 0) agent_premium_send ,
							DollarRate + ISNULL(agent_premium_payout, 0) [PAIDCost] ,
							ExchangeRate + ISNULL(agent_premium_send, 0) SENDCOST
				FROM    agentcurrencyRate r
						JOIN agentDetail a ON r.agentid = a.agentcode
				WHERE   1 = 1'  
    IF @country IS NOT NULL
    BEGIN 
        SET @sql = @sql + ' and a.country=''' + @country + '''' 
        
        IF @sAgentCode IS NOT NULL
			SET @sql = @sql + ' and r.agentid=''' + @sAgentCode + '''' 
    END 
    
	IF @payout_country IS NOT NULL
    BEGIN 
        SET @sql = @sql + ' and r.ReceiveCountry=''' + @payout_country + '''' 
        
        IF @payout_agent_id IS NOT NULL
			SET @sql=@sql+' and 1=2' 
    END 
    
    SET @sql = @sql+ ' Union ALL  
							SELECT  a.country ,
									'''' PayoutAgent ,
									b.branch Branch ,
									ISNULL(a.agent_short_code, a.CompanyName) agent_short_code ,
									r.CurrencyType ,
									ReceiveCountry ,
									a.CompanyName CompanyName ,
									r.ReceiveCType ,
									ExchangeRate ,
									NPRRate SettlementRate ,
									DollarRate ,
									r.Customer_Rate ,
									update_by ,
									update_ts ,
									ISNULL(agent_premium_payout, 0) agent_premium_payout ,
									ISNULL(agent_premium_send, 0) agent_premium_send ,
									DollarRate + ISNULL(agent_premium_payout, 0) [PAIDCost] ,
									ExchangeRate + ISNULL(agent_premium_send, 0) SENDCOST
							FROM    agent_branch_rate r
									JOIN agentDetail a ON r.agentid = a.agentcode
									JOIN agentbranchdetail b ON r.agent_branch_code = b.agent_branch_code
							WHERE   1 = 1'  
    IF @country IS NOT NULL
    BEGIN 
        SET @sql = @sql + ' and a.country=''' + @country + '''' 
        
        IF @sAgentCode IS NOT NULL
			SET @sql = @sql + ' and a.agentcode=''' + @sAgentCode + '''' 
    END 
    
    IF @payout_country IS NOT NULL
    BEGIN 
        SET @sql = @sql + ' and r.ReceiveCountry=''' + @payout_country + '''' 
        
        IF @payout_agent_id IS NOT NULL
			SET @sql=@sql+' and 1=2' 
    END 
     
    SET @sql = @sql+ ' Union ALL  
							SELECT  a.country ,
									p.companyName PayoutAgent ,
									'''' Branch ,
									ISNULL(a.agent_short_code, a.CompanyName) agent_short_code ,
									a.CurrencyType ,
									p.Country ReceiveCountry ,
									a.CompanyName CompanyName ,
									r.ReceiveCType ,
									ExchangeRate ,
									NPRRate SettlementRate ,
									DollarRate ,
									r.Customer_Rate ,
									update_by ,
									update_ts ,
									ISNULL(agent_premium_payout, 0) agent_premium_payout ,
									ISNULL(agent_premium_send, 0) agent_premium_send ,
									DollarRate + ISNULL(agent_premium_payout, 0) [PAIDCost] ,
									ExchangeRate + ISNULL(agent_premium_send, 0) SENDCOST
							FROM    agentpayout_CurrencyRate r
									JOIN agentDetail a ON r.agentid = a.agentcode
									JOIN agentdetail p ON p.agentCode = r.payout_agent_id
							WHERE   1 = 1'  
    IF @country IS NOT NULL
    BEGIN 
        SET @sql = @sql + ' and a.country=''' + @country + '''' 
        
        IF @sAgentCode IS NOT NULL
			SET @sql = @sql + ' and a.agentcode=''' + @sAgentCode + '''' 
    END 
    
    IF @payout_country IS NOT NULL
    BEGIN 
        SET @sql=@sql+' and p.country='''+@payout_country+'''' 
        
        IF @payout_agent_id IS NOT NULL
			SET @sql=@sql+' and r.payout_agent_id='''+@payout_agent_id+'''' 
    END 
    
    SET @sql = @sql+ ' Union ALL  
							SELECT  a.country ,
									p.companyName PayoutAgent ,
									b.branch Branch ,
									ISNULL(a.agent_short_code, a.CompanyName) agent_short_code ,
									a.CurrencyType ,
									p.Country ReceiveCountry ,
									a.CompanyName CompanyName ,
									r.ReceiveCType ,
									ExchangeRate ,
									NPRRate SettlementRate ,
									DollarRate ,
									r.Customer_Rate ,
									update_by ,
									update_ts ,
									ISNULL(agent_premium_payout, 0) agent_premium_payout ,
									ISNULL(agent_premium_send, 0) agent_premium_send ,
									DollarRate + ISNULL(agent_premium_payout, 0) [PAIDCost] ,
									ExchangeRate + ISNULL(agent_premium_send, 0) SENDCOST
							FROM    agentpayout_CurrencyRate_branch r
									JOIN agentDetail a ON r.agentid = a.agentcode
									JOIN agentdetail p ON p.agentCode = r.payout_agent_id
									JOIN agentbranchdetail b ON r.agent_branch_code = b.agent_branch_code
							WHERE   1 = 1'  
    IF @country IS NOT NULL
    BEGIN 
        SET @sql = @sql + ' and a.country=''' + @country + '''' 
        
        IF @sAgentCode IS NOT NULL
			SET @sql = @sql + ' and a.agentcode=''' + @sAgentCode + '''' 
    END  
    
    IF @payout_country IS NOT NULL
    BEGIN 
        SET @sql=@sql+' and p.country='''+@payout_country+'''' 
        
        IF @payout_agent_id IS NOT NULL
			SET @sql=@sql+' and r.payout_agent_id='''+@payout_agent_id+'''' 
    END 
    
    SET @sql = @sql+ ')l order by l.country,l.ReceiveCountry,l.receiveCTYpe,l.agent_short_code,l.PayoutAgent,Branch '  
    PRINT @sql  
    EXEC (@sql)  