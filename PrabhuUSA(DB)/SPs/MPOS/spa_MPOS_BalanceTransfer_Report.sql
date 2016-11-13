DROP PROCEDURE spa_MPOS_BalanceTransfer_Report
go
     --spa_BalanceTransfer_Report @flag='s',@tranno=NULL,@AgentBranchCode=NULL,@status=NULL,@from_date='2012-01-02',@to_date='2012-1-5',@operator=NULL           
--spa_BalanceTransfer_Report @flag='q',@from_date='2012-04-04',@to_date='2012-04-05', @AgentBranchCode='10',@user_name   ='panga'    
CREATE PROCEDURE [dbo].[spa_MPOS_BalanceTransfer_Report]          
    (          
      @flag CHAR(5) ,          
      @tranno INT = NULL ,          
      @AgentBranchCode VARCHAR(20) = NULL , 
      @AgentCode VARCHAR(20) = NULL ,         
      @status VARCHAR(50) = NULL ,          
      @from_date VARCHAR(20) = NULL ,          
      @to_date VARCHAR(20) = NULL ,          
      @user_name VARCHAR(50) = NULL ,          
      @operator INT = NULL,  
      @country_sno VARCHAR(100) = NULL                     
    )          
AS           
    DECLARE @sql VARCHAR(5000)                    
    IF @flag = 's'           
        BEGIN                     
            SET @sql = 'Select t.sno,t.MobileNo,t.Amount,t.Status as Status,                    
       t.User_id, t.dt_date, Isnull(t.dlr_response,''NOT DLR'') dlr_response,                    
       b.agent_name, isnull(t.selling_price,0) clientcostAmount, isnull(t.costamount_reseller,0) costamount_reseller  from MPOS_balanceTransfer t join reseller_agent b on                     
       t.agent_branch_code=b.reseller_id join agent_detail ad on ad.reseller_id = t.agent_branch_code and ad.username=t.user_id                     
       where t.status <>''Confirming'''                    
                     
            IF @tranno IS NOT NULL           
                SET @sql = @sql + ' and t.sno=' + CAST(@tranno AS VARCHAR)                    
            ELSE           
                BEGIN                     
                    IF @AgentBranchCode IS NOT NULL           
                        SET @sql = @sql + ' and t.agent_branch_code=''' + @AgentBranchCode          
                            + ''''                    
                    IF @status IS NOT NULL           
                        BEGIN                    
                            IF @status = 'y'           
                                SET @sql = @sql + ' and t.status=''Success'''                    
                            ELSE           
                                SET @sql = @sql          
                                    + ' and (t.status=''Fail'')'                    
                        END                    
                
                    IF @operator IS NOT NULL           
                        SET @sql = @sql + ' and mobile_operator = '          
                            + CAST(@operator AS VARCHAR(10))        
            
                    IF @from_date IS NOT NULL          
                        AND @tranno IS NULL           
                        SET @sql = @sql + ' and t.dt_date between '''          
                            + @from_date + ''' and ''' + @to_date          
                            + ' 23:59:59'''                    
                END                     
            IF @user_name IS NOT NULL           
    SET @sql= @sql + ' and  ad.agent_id =''' + @user_name + ''''        
                --SET @sql = @sql + ' and  user_id =''' + @user_name + ''''                   
            --PRINT @sql                    
                     
            EXEC(@sql)                    
        END                 
                
                
    IF @flag = 'a'   --user's last 10 transactions                  
        BEGIN                     
            SET @sql = 'Select top 10 t.sno,t.MobileNo,t.Amount, Status,                    
       t.User_id, t.dt_date, dlr_response, isnull(t.selling_price,'''') clientcostamount,                   
       b.agent_name from balanceTransfer t join reseller_agent b on                     
       t.agent_branch_code=b.reseller_id                    
       where 1=1'                
            SET @sql = @sql + ' and Status <> ''Confirming'' and  user_id =''' + @user_name + ''''                   
            SET @sql = @sql + 'order by dt_date desc '                  
            --PRINT @sql                
            EXEC(@sql)                
        END            
        
        
        
   IF @flag = 'q'     --show to client processsing status txns only           
       BEGIN                       
            SET @sql = 'Select t.sno,t.MobileNo,t.Amount,t.Status as Status,                  
       t.User_id, t.dt_date, Isnull(t.dlr_response,''NOT DLR'') dlr_response,                  
       b.agent_name from balanceTransfer t join reseller_agent b on                   
       t.agent_branch_code=b.reseller_id                        
 where ((t.status <>''Confirming'' and t.status=''Processing'') or t.dlr_response=''Recharge Successful'') '                 
                    
--            IF @from_date IS NOT NULL            
--                AND @tranno IS NULL             
                SET @sql = @sql + ' and t.dt_date between ''1950-01-01'' and DATEADD(minute,-1, dbo.getDateHO(GETUTCDATE()))'          
           IF @AgentBranchCode IS NOT NULL         
                        SET @sql = @sql + ' and t.agent_branch_code=''' + @AgentBranchCode        
                            + ''''             
             IF @user_name IS NOT NULL         
                SET @sql = @sql + ' and  user_id =''' + @user_name + ''''            
 --PRINT @sql                      
                       
            EXEC(@sql)                      
        END           
                        
          
  IF @flag='d'        
  BEGIN         
  UPDATE dbo.BalanceTransfer SET Status='Fail', DLR_Response = 'Cancelled by Agent ' + @user_name WHERE        
  sno = @tranno        
  END        
        
        
IF @flag = 'qa' -- showing to admin only processing and NTC successful case                 
        BEGIN                           
            SET @sql = 'Select t.sno,t.MobileNo,t.Amount,t.Status as Status,                      
       t.User_id, t.dt_date, Isnull(t.dlr_response,''NOT DLR'') dlr_response,                      
       b.agent_name from balanceTransfer t join reseller_agent b on                       
       t.agent_branch_code=b.reseller_id                            
 where ((t.status <>''Confirming'' and t.status=''Processing'') or t.dlr_response=''Recharge Successful'')'                   
          --PRINT @sql               
--            IF @from_date IS NOT NULL                
--    AND @tranno IS NULL                 
                SET @sql = @sql + ' and t.dt_date between ''1950-01-01'' and DATEADD(minute,-1, dbo.getDateHO(GETUTCDATE()))'              
           IF @AgentBranchCode IS NOT NULL             
                        SET @sql = @sql + ' and t.agent_branch_code=''' + @AgentBranchCode            
                            + ''''                 
             IF @user_name IS NOT NULL             
                SET @sql = @sql + ' and  user_id =''' + @user_name + ''''                
 --PRINT @sql                          
                           
            EXEC(@sql)                          
        END     
    
    
    
--show refund report                          
    IF @flag = 'fund'       
    BEGIN      
       SET @sql = 'SELECT bt.sno, bt.amount,bt.mobileno,bt.dlr_response, bt.dt_date, br.amount refundamount, br.refund_date,    
       ra.agent_name reseller_name, ad.agent_name + '' ('' + ad.username + '') '' agent_name      
       FROM dbo.balance_refund br with (nolock)        
         inner join balancetransfer bt WITH (NOLOCK) ON br.tranno = bt.sno      
         inner join reseller_Agent ra WITH (NOLOCK) ON bt.agent_branch_code = ra.reseller_id    
         inner join agent_detail ad WITH (NOLOCK) ON bt.user_id = ad.username    
          WHERE 1 = 1 '     
               
          SET @sql = @sql + ' and bt.dt_date between '''            
                            + @from_date + ''' and ''' + @to_date            
                            + ' 23:59:59'''       
           
           
       IF @AgentBranchCode  IS NOT NULL         
   SET @sql = @sql + ' AND bt.agent_branch_code =''' + @AgentBranchCode + ''''      
       
       IF @user_name IS NOT NULL      
  SET @sql = @sql + ' AND br.agent_id =''' + @user_name + ''''      
             
         SET @sql = @sql + 'order by ra.agent_name, ad.agent_name , ad.username asc '    
      --PRINT @sql       
      EXEC(@sql)       
    END   
      
      
      
IF @flag = 'sp' ---Reports based on Pending table for International Transaction                
        BEGIN                           
            SET @sql = 'SELECT t.refno pending_sno,t.sno tran_sno, c.country_name,        
        t.MobileNo ,        
t.denomination,t.denoccy,t.total_charge ,t.sendingCurrency,
        t.Status AS Status ,        
        op.operator_name ,        
        t.Agent_User_login ,        
        t.dt_date , t.gross_sending_amount  , t.agent_commission,    
        ISNULL(t.dlr_response, ''NOT DLR'') dlr_response         
       FROM     MPOS_balanceTransfer t WITH ( NOLOCK )    
        INNER JOIN dbo.agentDetail ad WITH ( NOLOCK ) ON t.AgentCode = ad.agentCode     
        INNER JOIN dbo.agentbranchdetail b WITH ( NOLOCK ) ON t.agent_branch_code = b.agent_branch_Code  AND ad.agentCode=b.agentCode             
        INNER JOIN dbo.agentsub ag WITH ( NOLOCK ) ON ag.agent_branch_code = t.agent_branch_code AND t.Agent_User_login = ag.User_login_Id              
        INNER JOIN MPOS_tbloperator op WITH ( NOLOCK ) ON t.mobile_operator = op.sno              
        INNER JOIN dbo.tblcountry c WITH ( NOLOCK ) ON op.country_name =c.country_name         
WHERE   t.status <> ''Confirming'' '                      
                           
            IF @tranno IS NOT NULL                 
                SET @sql = @sql + ' and t.sno=' + CAST(@tranno AS VARCHAR)                          
            ELSE                 
                BEGIN                           
                    IF @AgentBranchCode IS NOT NULL                 
                        SET @sql = @sql + ' and t.agent_branch_code=''' + @AgentBranchCode                
                            + '''' 
                    IF @agentCode IS NOT NULL    
							 SET @sql=@sql+'and t.AgentCode='''+@agentCode+''''                        
                    IF @status IS NOT NULL                 
                        BEGIN                          
                            IF @status = 'y'                 
                                SET @sql = @sql + ' and t.status=''Success'''                          
                            ELSE                 
                                SET @sql = @sql                
                                    + ' and (t.status=''Fail'')'                          
                        END                          
                      
                      
              IF @country_sno IS NOT NULL         
    SET @sql = @sql + ' and c.country_name  = '''                
                            + @country_sno+''''         
                      
                    IF @operator IS NOT NULL                 
                        SET @sql = @sql + ' and op.sno = '                
                            + CAST(@operator AS VARCHAR(10))              
                  
                    IF @from_date IS NOT NULL                
                        AND @tranno IS NULL                 
                        SET @sql = @sql + ' and t.dt_date between '''                
                            + @from_date + ''' and ''' + @to_date                
                            + ' 23:59:59'''                          
                END         
                                          
            IF @user_name IS NOT NULL                 
    SET @sql= @sql + ' and  ag.User_login_Id =''' + @user_name + ''''              
                 
 SET @sql= @sql + ' order by t.dt_date ASC '             
          PRINT @sql                          
                           
          EXEC(@sql)             
        END  
        
              
 IF @flag = 'sp2' ---Reports based on only Pending table for International Transaction                      
        BEGIN                              
             SET @sql = 'SELECT ta.sno pending_sno,ta.user_commission uc,'''' trans_no ,c.country_name        
,ta.MobileNo,ta.Amount,ta.Status AS Status,op.operator_name ,        
ta.Agent_User_Id AS userid,ta.DT_date,        
  ISNULL(ta.DT_date,'''')dlr_response ,              
        ISNULL(ta.userRate, '''') fee ,              
        ISNULL(ta.payoutRate, 0) payoutRate ,              
        ISNULL(ta.user_commission, '''')discount,        
        b.Branch ,              
        ISNULL(ta.sellingpriceccy, 0) clientcostAmount ,              
        ISNULL (ta.service_charge, 0) service_charge,  
        dbo.FNAGetConvertRate(ta.sellingpriceccy,ta.Amount,ta.service_charge) convertrate          
         FROM    MPOS_BalanceTransfer_Pending ta WITH ( NOLOCK )                    
		INNER JOIN dbo.agentDetail ad WITH ( NOLOCK ) ON ta.AgentCode = ad.agentCode     
        INNER JOIN dbo.agentbranchdetail b WITH ( NOLOCK ) ON ta.agent_branch_code = b.agent_branch_Code  AND ad.agentCode=b.agentCode             
        INNER JOIN dbo.agentsub ag WITH ( NOLOCK ) ON ag.agent_branch_code = ta.agent_branch_code AND ta.agent_user_id = ag.agent_user_id              
        INNER JOIN MPOS_tbloperator op WITH ( NOLOCK ) ON ta.mobile_operator = op.sno              
        INNER JOIN dbo.tblcountry c WITH ( NOLOCK ) ON op.country_sno =c.sno               
WHERE   ta.Status= ''Pending'''          
                                               
            IF @user_name IS NOT NULL                       
    SET @sql= @sql + ' and ag.agent_user_id =''' + @user_name + ''''                    
            IF @AgentBranchCode IS NOT NULL    
 SET @sql=@sql+'and ta.agent_branch_code='''+@AgentBranchCode+''''    
             IF @agentCode IS NOT NULL    
 SET @sql=@sql+'and ta.AgentCode='''+@agentCode+''''  
          -- PRINT @sql                                
                                 
            EXEC(@sql)                                
        END      