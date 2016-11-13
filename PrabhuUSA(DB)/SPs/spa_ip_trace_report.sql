IF OBJECT_ID('spa_ip_trace_report','P') IS NOT NULL
	DROP PROCEDURE [dbo].spa_ip_trace_report
GO
--spa_Export_JanataBank_job '20100004','Cash Pay','ranesh','30101265',NULL,'a','JBBLCashPay','09/12/2010','09/30/2011'  
CREATE PROCEDURE [dbo].spa_ip_trace_report
    @agentCode VARCHAR(50) = NULL,
    @senderCountry VARCHAR(100) = NULL,
    @fromDate VARCHAR(50) = NULL ,
    @toDate VARCHAR(50) = NULL ,
    @dateType VARCHAR(50)= null,
	@login_user_id varchar(50)=NULL,
	@batch_Id varchar(50)=NULL,
	@process_id varchar(150)   
AS 
BEGIN
SET @toDate=@toDate+' 23:59:59.998'
     DECLARE @sql VARCHAR(MAX) ,
        @ledger_tabl VARCHAR(100) ,
        @msg_agenttype VARCHAR(200) ,
        @desc VARCHAR(5000),@total_row INT,@agent_name VARCHAR(100),@url_desc VARCHAR(500)
        
         SET @ledger_tabl = dbo.FNAProcessTbl(@batch_id, REPLACE(@login_user_id,':','_'),
                                         @process_id)
                                         
SET @sql = 'SELECT dbo.decryptDb(m.refno) [Control_Number],m.agentname [Agent_Name],m.Branch [Branch_Name],m.SEmpID [User_Name],m.ip_address [IP_Address],digital_id_sender
 INTO ' + @ledger_tabl+' FROM dbo.moneySend m WITH (NOLOCK) 
JOIN dbo.agentsub a WITH (NOLOCK) ON a.User_login_Id=m.SEmpID
WHERE 1=1 AND m.'+@dateType+' BETWEEN '''+@fromDate+''' AND '''+ @toDate+'''' 
if @agentCode is NOT  NULL
	SET @sql=@sql+' and  m.agentid='''+@agentCode+''''
if @senderCountry is NOT  NULL 
	SET @sql=@sql+' and  m.SenderCountry='''+@senderCountry+''''
SET @sql=@sql+' order by m.'+@dateType
SET @sql = @sql + ' INSERT #temp_total(total_row) SELECT count(*) FROM ' + @ledger_tabl
CREATE TABLE #temp_total(total_row int ) 
   --PRINT @sql            
    EXEC (@sql)     
      SELECT  @total_row = total_row           
  FROM    #temp_total
  IF @senderCountry IS NOT NULL AND @agentCode IS NULL
	SET @url_desc='sendCountry='+@senderCountry+'&'
  IF @senderCountry IS NULL AND @agentCode IS NOT NULL
	SET @url_desc='senderAgent='+@agentCode+'&'
  IF @senderCountry IS NOT NULL AND @agentCode IS NOT NULL
	SET @url_desc='sendCountry='+@senderCountry+'&senderAgent='+@agentCode+'&'	
	
  IF @agentCode IS NOT NULL  
		SELECT @agent_name=a.CompanyName from dbo.agentDetail a WITH (NOLOCK) 
		 WHERE a.agentCode=@agentCode 
   ELSE
		SET @agent_name='All Agent'
	IF @senderCountry IS NULL
		SET @senderCountry='All Country'
          SET @desc = '<strong><u>IP Trace Report for '+UPPER(@senderCountry)+'('+UPPER(@agent_name)+') </u></strong> '          
            + ' is completed.  Total Record Found: <strong><u>'          
            + CAST(ISNULL(@total_row, 0) AS VARCHAR) + '</u></strong> From: ' + @fromDate + ' To: ' + @toDate 

    --PRINT 'spa_message_board ''u'', '''+@login_user_id+''', NULL,'''+ @batch_id+''','''+ @desc+''', ''c'',
    --    '''+@process_id+''', NULL,'+ ISNULL(@url_desc,'Null')
    EXEC spa_message_board 'u', @login_user_id, NULL, @batch_id, @desc, 'c',
        @process_id,NULL,@url_desc
END

