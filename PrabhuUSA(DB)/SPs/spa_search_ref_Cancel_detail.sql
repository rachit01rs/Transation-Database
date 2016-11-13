DROP PROC [dbo].[spa_search_ref_Cancel_detail]  
go
--exec spa_search_ref_Cancel_detail '1932139',NULL     
CREATE PROC [dbo].[spa_search_ref_Cancel_detail]  
    @tranno INT = NULL ,  
    @refno VARCHAR(50) = NULL ,  
    @agent_id INT = NULL ,  
    @branch_code INT = NULL ,  
    @payout_agent_id INT = NULL ,  
    @payout_branch_id INT = NULL ,  
    @payout_country VARCHAR(150) = NULL ,  
    @paymenttype VARCHAR(100) = NULL ,  
    @TransStatus VARCHAR(100) = NULL  
AS   
    DECLARE @sql VARCHAR(5000)    
    DECLARE @row_found INT ,  
        @table_name VARCHAR(100) ,  
        @enc_refno VARCHAR(50)    
    IF @refno IS NOT NULL   
        SET @enc_refno = dbo.encryptDB(@refno)    
    
        SET @table_name = 'CancelMoneySend'    
         
    
    SET @sql = 'select m.*,a.CompanyName PayoutAgent,z.Zone_Name,'''+ @table_name + ''' table_name  
    from ' + @table_name + ' m join agentdetail a on m.expected_payoutagentid=a.agentcode     
    left outer join agentbranchdetail b on b.agent_branch_code=m.rBankid     
    left outer join zone_detail z on z.zone_id=b.district_code     
    where 1=1 '    
    IF @tranno IS NOT NULL   
        SET @sql = @sql + ' and tranno=' + CAST(@tranno AS VARCHAR)    
    IF @refno IS NOT NULL   
        SET @sql = @sql + ' and refno=''' + @enc_refno + ''''    
    IF @agent_id IS NOT NULL   
        SET @sql = @sql + ' and agentid=' + CAST(@agent_id AS VARCHAR)    
    IF @branch_code IS NOT NULL   
        SET @sql = @sql + ' and branch_code=' + CAST(@branch_code AS VARCHAR)    
    IF @payout_agent_id IS NOT NULL   
        SET @sql = @sql + ' and paid_agent_id='+ CAST(@payout_agent_id AS VARCHAR)    
          
    IF @payout_country IS NOT NULL   
        SET @sql = @sql + ' and receiverCountry=''' + @payout_country + ''''    
    IF @paymenttype IS NOT NULL   
        SET @sql = @sql + ' and paymenttype=''' + @paymenttype + ''''    
    EXEC(@sql)    
    