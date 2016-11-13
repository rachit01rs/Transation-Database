/****** Object:  Table [dbo].[email_request]    Script Date: 06/25/2012 10:44:57 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[email_request]') AND type in (N'U'))
DROP TABLE [dbo].[email_request]
GO
/****** Object:  Table [dbo].[SMS_Notification]    Script Date: 06/25/2012 10:44:57 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[SMS_Notification]') AND type in (N'U'))
DROP TABLE [dbo].[SMS_Notification]
GO
/****** Object:  Table [dbo].[email_request]    Script Date: 06/25/2012 10:44:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[email_request](
	[notes_id] [int] IDENTITY(1,1) NOT NULL,
	[notes_subject] [varchar](250) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[notes_text] [varchar](8000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[attachment_file_name] [varchar](500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[notes_attachment] [image] NULL,
	[send_from] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[send_to] [varchar](5000) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[send_cc] [varchar](5000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[send_bcc] [varchar](5000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[send_status] [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[active_flag] [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[create_user] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[create_ts] [datetime] NULL,
	[update_user] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[update_ts] [datetime] NULL,
 CONSTRAINT [PK_EMAIL_NOTES] PRIMARY KEY NONCLUSTERED 
(
	[notes_id] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[SMS_Notification]    Script Date: 06/25/2012 10:44:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[SMS_Notification](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[Notification_name] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[agentid] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[sendingCountry] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[receivingid] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[receivingCountry] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[address_book] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[sms_or_email] [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[sms_email_value] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO 
/****** Object:  StoredProcedure [dbo].[spa_SMS_Notification]    Script Date: 06/25/2012 10:43:53 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spa_SMS_Notification]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[spa_SMS_Notification]
GO
/****** Object:  StoredProcedure [dbo].[spa_ExRateUpdatePartner]    Script Date: 06/25/2012 10:43:53 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spa_ExRateUpdatePartner]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[spa_ExRateUpdatePartner]
GO
/****** Object:  StoredProcedure [dbo].[spa_NotificationExRate]    Script Date: 06/25/2012 10:43:53 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spa_NotificationExRate]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[spa_NotificationExRate]
GO
/****** Object:  StoredProcedure [dbo].[spa_SMS_Notification]    Script Date: 06/25/2012 10:43:42 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--	 spa_SMS_Notification 's',null
CREATE PROCEDURE [dbo].[spa_SMS_Notification]
@flag CHAR(1)=NULL,
@id VARCHAR(50)=NULL,
@notification_name VARCHAR(50)=NULL,
@agentid VARCHAR(50)=NULL,
@sendingCountry VARCHAR(50)=NULL,
@receivingid  VARCHAR(50)=NULL,
@receivingCountry  VARCHAR(50)=NULL,
@address_book  VARCHAR(50)=NULL,
@sms_or_email  VARCHAR(50)=NULL,
@sms_email_value VARCHAR(50)=NULL

AS

/*
	sms_or_email : b-both; e-email; s-sms;
	sms_email_value: column name of the exchange rate used in our system from exchange rate table
*/
SET NOCOUNT ON;

DECLARE @SQL VARCHAR(MAX)

IF @flag='i'
BEGIN
	INSERT INTO sms_notification(
		notification_name,
		agentid,
		sendingCountry,
		receivingid,
		receivingCountry,
		address_book,
		sms_or_email,
		sms_email_value
	)
	VALUES(
		@notification_name,
		@agentid,
		@sendingCountry,
		@receivingid,
		@receivingCountry,
		@address_book,
		@sms_or_email,
		@sms_email_value
	)
END
IF @flag='s'
BEGIN
	
	IF @id IS NOT NULL
	BEGIN
		SET @SQL='
					SELECT	
						id,
						notification_name,
						agentid,
						sendingCountry,
						receivingid,
						receivingCountry,
						address_book,
						sms_or_email,
						sms_email_value,
						a.companyname agentName,
						r.companyname receivingAgent,
						c.category_name
					FROM sms_notification s WITH(NOLOCK)
					LEFT OUTER JOIN agentdetail a WITH(NOLOCK)
					ON s.agentid=a.agentcode
					LEFT OUTER JOIN agentdetail r with(NOLOCK)
					ON s.receivingid=r.agentcode
					LEFT OUTER JOIN category_list c WITH(NOLOCK)
					ON	c.category_id=s.address_book
					 WHERE s.id='''+@id+''' ORDER BY Notification_name asc'
	END
	ELSE
	BEGIN
	
	SET @SQL='
	SELECT	
		id,
		notification_name,
		agentid,
		sendingCountry,
		receivingid,
		receivingCountry,
		address_book,
		sms_or_email,
		sms_email_value,
		a.companyname agentName,
		r.companyname receivingAgent,
		c.category_name
	FROM sms_notification s WITH(NOLOCK)
	LEFT OUTER JOIN agentdetail a WITH(NOLOCK)
	ON s.agentid=a.agentcode
	LEFT OUTER JOIN agentdetail r with(NOLOCK)
	ON s.receivingid=r.agentcode 
	LEFT OUTER JOIN category_list c WITH(NOLOCK)
	ON	c.category_id=s.address_book
	ORDER BY Notification_name asc'
	END
	--PRINT(@SQL)
	EXEC(@SQL)
END
IF @flag='d'
BEGIN
	DELETE FROM sms_notification
	WHERE id=@id
END
IF @flag='u'
BEGIN
	UPDATE	sms_notification
	SET notification_name=@notification_name,
		agentid=@agentid,
		sendingCountry=@sendingCountry,
		receivingid=@receivingid,
		receivingCountry=@receivingCountry,
		address_book=@address_book,
		sms_or_email=@sms_or_email,
		sms_email_value=@sms_email_value
	WHERE id=@id
END
GO
/****** Object:  StoredProcedure [dbo].[spa_ExRateUpdatePartner]    Script Date: 06/25/2012 10:43:43 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[spa_ExRateUpdatePartner]              
@process_id  VARCHAR(max),    
@costExchangeID VARCHAR(max),              
@updated_by  VARCHAR(100)              
AS              
BEGIN              
 -- SET NOCOUNT ON added to prevent extra result sets from              
 -- interfering with SELECT statements.              
 SET NOCOUNT ON;              
 BEGIN TRY                   
   ----------   RETRIVING HOST ADDRESS,PIC DATABSE FROM STATIC TABLE ---------              
   DECLARE @HOST VARCHAR(50),@P_AGENTID VARCHAR(50),@PartnerAgentCode VARCHAR(50),@sql_agentCurrencyRate VARCHAR(MAX),@sql VARCHAR(MAX)              
 CREATE table #temp_agent(              
   agentid VARCHAR(50),              
   agent_cost FLOAT,              
   payout_country VARCHAR(100),    
   payout_agent varchar(100)  )  
         
 SET @sql='    
 select agentid,dollarRate,payout_country,payout_agent from (    
 SELECT agentid,dollarRate,r.receiveCountry payout_country,''NA'' payout_agent 
	FROM agentcurrencyrate r,temp_forex_exchange t    
  WHERE r.currencyid=t.currencyid and t.idtype=''c''   
  AND t.sno in ('+@costExchangeID+') and r.audit_process_id='''+@process_id+'''
  AND t.session_id in('''+@process_id+''')     
  UNION ALL    
 SELECT agentid,dollarRate,r.receiveCountry payout_country,payout_agent_id payout_agent 
	FROM agentpayout_CurrencyRate r join temp_forex_exchange t    
  on r.currencyid=t.currencyid where  t.idtype=''p''  and r.audit_process_id='''+@process_id+'''
  AND t.sno in ('+@costExchangeID+')   
  AND t.session_id in('''+@process_id+'''))l'    
  PRINT @sql   

 INSERT #temp_agent(agentid,agent_cost,payout_country,payout_agent)          
    EXEC(@sql)          
      
  DECLARE @check_agentid VARCHAR(50),@agent_cost FLOAT,@payout_country VARCHAR(100),@payout_agent varchar(100)           
          
 
 DECLARE AGENT_CUR CURSOR FORWARD_ONLY READ_ONLY FOR              
 
       
 SELECT t.agentid,t.agent_cost,t.payout_country,t.payout_agent FROM #temp_agent t 
 JOIN static_values sv ON t.agentid=sv.static_data AND sv.sno=200 AND sv.static_value='PRABHU MY' 
       
 OPEN AGENT_CUR              
  FETCH NEXT FROM AGENT_CUR INTO @check_agentid,@agent_cost,@payout_country,@payout_agent         
   WHILE @@FETCH_STATUS = 0              
    BEGIN              
     SET @HOST = NULL              
     SELECT @HOST=additional_value,@P_AGENTID=static_data,@PartnerAgentCode=Description FROM static_values             
     WHERE SNO=200 and static_data=@check_agentid  
     IF @HOST IS NOT NULL              
     BEGIN              
      print(@payout_country)          
      SET @sql = @HOST + 'spa_PartnerExRateUpdate '+ CAST(@agent_cost AS VARCHAR(100))+','''+@payout_country+''',''P:'+@updated_by+''','''+@payout_agent+''','''+@PartnerAgentCode+''''  
      PRINT(@sql)             
      EXEC(@sql)              
     END             
     FETCH NEXT FROM AGENT_CUR INTO @check_agentid,@agent_cost,@payout_country,@payout_agent    
    END           
 CLOSE AGENT_CUR              
   DEALLOCATE AGENT_CUR          
             
 END TRY                              
 BEGIN CATCH             
  DECLARE @desc VARCHAR(1000)                              
  SET @desc='SQL Error found:  (' + ERROR_MESSAGE() + ')'            
  INSERT INTO [error_info]([ErrorNumber], [ErrorDesc], [Script], [ErrorScript], [QueryString], [ErrorCategory],                              
  [ErrorSource], [IP], [error_date])                              
  SELECT -1,@desc,'spa_ExRateUpdatePartner','SQL',@desc,'SQL','SP','',getdate()                              
  SELECT 'Error' status,'1050','Error!! while updating partner exchange rate.' msg                              
 END CATCH             
END     

GO
/****** Object:  StoredProcedure [dbo].[spa_NotificationExRate]    Script Date: 06/25/2012 10:43:43 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
----
----spa_NotificationExRate '519FDB75_6E58_4186_9602_C19F11F27086','1867, 1865, 1866, 1864, 1868, 1860, 1861, 1862, 1859, 
----1863'  
-- --select * from email_request order by notes_id desc  
CREATE proc [dbo].[spa_NotificationExRate]  
 @audit_process_id varchar(150)=NULL,  
 @costExchangeID varchar(max)=NULL  
as  
--declare @audit_process_id varchar(150)  
--set @audit_process_id='519FDB75_6E58_4186_9602_C19F11F27086'  
SET NOCOUNT ON;  
  
-- Create #temp table for exchange rate approved  
select r.Customer_rate,r.ExchangeRate,r.dollarRate,r.agentid,r.receiveCountry,receiveCType,
a.CurrencyType,a.companyName  
into #temp  
 FROM agentcurrencyrate r WITH(NOLOCK) join  temp_forex_exchange t WITH(NOLOCK)                   
 on r.currencyid=t.currencyid and t.idtype='c' 
 join agentdetail a WITH(NOLOCK) on a.agentcode=r.agentid  
 where t.session_id=@audit_process_id  
  
   
 SELECT id, Notification_name, sendingCountry, receivingid, receivingCountry, address_book, sms_or_email, sms_email_value,t.*   
 INTO #temp1   
  FROM sms_notification s with(nolock)   
join  #temp t   
on s.agentid=t.agentid and s.receivingCountry=t.receiveCountry  
  
INSERT INTO [email_request]  
           (  
           [notes_subject]  
           ,[notes_text]  
           ,[send_from]  
           ,[send_to]  
           , send_cc  
           ,[send_status]  
           ,[active_flag]  
          )  
            
SELECT 'Exchange Rate Updated: '+ convert(varchar,getdate(),121),  
 Email,  
 '',  
    email_id,  
    '',  
    'n',  
    'y'  
FROM (  
 SELECT case   
 when sms_or_email in ('e','b') then   
  '<body><Table border=1 cellspacing=0>  ' +  
   '<tr><td colspan=2><b>Exchange Rate :</b></td></tr>'+  
   '<tr><td colspan=2>ExRate rate for '+  
   case   
    when sms_email_value ='customer_rate' then  
     '1 '+ currencyType +' = '+ cast(customer_rate as varchar)  +' '+ receiveCType   
     when sms_email_value ='exchangerate' then  
     '1 USD = '+ cast(round(CAST(exchangerate AS MONEY),4,1)  as varchar) +' '+ currencyType    
        when sms_email_value ='dollarRate' then  
     '1 USD = '+ cast(dollarRate  as varchar) +' '+ receiveCType    
    else ''   
   end  +' updated on '+  convert(varchar,getdate(),121)+'</td></tr></table></body>'  
 else NULL  
 end Email,  
 a.email_id email_id  
   from #temp1 t   
join address_book a   
on t.address_book=a.category_type) t3     
where email is not null  
and email_id is not null  
 --INSERT INTO SMS Pending  
  
   
INSERT INTO sms_pending  
           (  
           deliveryDate,   
           MobileNo,   
           message,   
           SmsTo,   
           country,   
           agentUser,   
           status,   
           sender_id  
          )  
            
SELECT convert(varchar,getdate(),121),  
    mobile_no,  
  SMS,  
  'o',  
  null,  
  null,  
  'a',  
  null  
FROM (  
 SELECT case   
 when sms_or_email in ('s','b') then   
  'ExRate rate for '+  
  case   
   when sms_email_value ='customer_rate' then  
    '1 '+ currencyType +' = '+ cast(customer_rate as varchar)  +' '+ receiveCType   
   when sms_email_value ='exchangerate' then  
    '1 USD = '+ cast(round(CAST(exchangerate AS MONEY),4,1)  as varchar) +' '+ currencyType    
      when sms_email_value ='dollarRate' then  
    '1 USD = '+ cast(dollarRate  as varchar) +' '+ receiveCType    
  else '' end +' updated on '+ convert(varchar,getdate(),121)  
 else NULL  
 end SMS,  
 a.mobile_no  
   from #temp1 t   
join address_book a   
on t.address_book=a.category_type) t3     
where SMS is not null  
             
             
--exec spa_sendemail  
     
 GO 
 drop procedure [dbo].[spa_RosterExRate]   
  GO 
  
/****** Object:  StoredProcedure [dbo].[spa_RosterExRate]    Script Date: 06/25/2012 10:44:28 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spa_RosterExRate]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[spa_RosterExRate]
GO
/****** Object:  StoredProcedure [dbo].[spa_RosterExRate]    Script Date: 06/25/2012 10:44:18 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--spa_RosterExRate 'e',25,'Nepal',68,68,0,'BDT','admin','admin',NULL,NULL,NULL,NULL       
--spa_RosterExRate 'c',25,'Bangladesh',68.40,68.40,NULL,NULL,'admin','admin','5904, 5905, 5902, 5901, 5903, 5907, 5906',NULL,'E1F3D164_6E31_422D_B279_F91F5974CC14',NULL      
--spa_RosterExRate 'e',34,'Bangladesh',66.71,66.71,0,'BDT','admin','admin',NULL,'30300000',NULL,NULL       
CREATE procedure [dbo].[spa_RosterExRate]      
 @flag char(1),      
 @sno int=NULL,      
 @country varchar(50)=NULL,      
 @buyRate numeric(19, 10)=NULL,      
 @sellRate numeric(19, 10)=NULL,      
 @rateDiff numeric(19, 10)=NULL,      
 @currencyType varchar(3)=NULL,      
 @created_by varchar(50)=NULL,      
 @updated_by varchar(50)=NULL,      
 @effSno varchar(1000)=NULL,      
 @payoutAgentID varchar(50)=null,      
 @session_id varchar(200)=NULL,      
 @round_value int=null,      
 @xmlData varchar(8000)=null,      
 @buy_sell_margin money=null      
      
AS       
if @xmlData is not null      
begin      
set @xmlData=replace(@xmlData,'{','<')      
set @xmlData=replace(@xmlData,'}','>')      
set @xmlData=replace(@xmlData,'|','"')      
set @xmlData=replace(@xmlData,'&quot','"')      
--set @xmlData=replace(@xmlData,'&lt','<')      
--set @xmlData=replace(@xmlData,'&gt','>')      
end      
      
      
set @round_value=4      
      
if @flag='a'      
 select sno,country,buyRate,sellRate,rateDiff,currencyType from forex where sno=@sno      
      
if @flag='i'      
BEGIN       
DECLARE @agent_country varchar(50),@status varchar(10)      
 IF  @payoutAgentID IS NOT NULL       
  BEGIN      
  SELECT  @agent_country=companyName FROM agentdetail WHERE agentcode=@payoutAgentID      
  IF NOT EXISTS ( SELECT payoutAgentID FROM forex WHERE payoutAgentID=@payoutAgentID)      
  BEGIN      
   INSERT INTO forex(country,buyRate,sellRate,rateDiff,currencyType,created_by,created_ts,payoutAgentID,Round_By)      
   values(@country,@buyRate,@sellRate,@rateDiff,@currencyType,@created_by,dbo.getDateHO(getutcdate()),@payoutAgentID,@round_value)      
   exec spa_forex 'e',@sno,@country,@buyRate,@sellRate,@rateDiff,@currencyType,@created_by,@updated_by,NULL,@payoutAgentID,NULL,@round_value      
   SET @status='true'      
  END      
  ELSE      
   SET @status='false'      
 END      
 ELSE      
 BEGIN      
 select @agent_country=@country      
 IF NOT EXISTS (select sno from forex where country=@country AND payoutAgentID IS NULL)       
  BEGIN       
   INSERT INTO forex(country,buyRate,sellRate,rateDiff,currencyType,created_by,created_ts,Round_By)      
   values(@country,@buyRate,@sellRate,@rateDiff,@currencyType,@created_by,dbo.getDateHO(getutcdate()),@round_value)      
   exec spa_forex 'e',@sno,@country,@buyRate,@sellRate,@rateDiff,@currencyType,@created_by,@updated_by      
  SET @status='true'      
  END      
  ELSE      
  SET @status='false'      
 SET @agent_country=@country      
 END      
 IF @status='false'       
  SELECT 'Error' status,'The Forex of '+@agent_country+' already exists' msg      
 ELSE      
  SELECT 'Success' status,'The forex successfylly inserted' msg        
END       
      
if @flag='u'      
BEGIN       
 exec spa_forex 'e',@sno,@country,@buyRate,@sellRate,@rateDiff,@currencyType,@created_by,@updated_by,null,null,null,@round_value      
end      
if @flag='d'      
BEGIN       
 DELETE forex WHERE  sno=@sno      
 SELECT  'Success' status,'The Forex selected is deleted permantly' msg      
END       
IF @flag='e'      
BEGIN       
 IF @session_id IS NULL      
 BEGIN      
  SET @session_id= REPLACE(newid(),'-','_')      
 end      
       
 DELETE dbo.temp_forex_exchange WHERE session_id=@session_id      
 IF @payoutAgentID IS  NOT NULL      
 BEGIN       
      
   insert into dbo.temp_forex_exchange      
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
   roundby      
   ,alt_cost      
   )      
   (        
        
      
   select 'Buying' ExType,      
     a.companyName Sender,      
     receiveCountry,      
     p.companyName Receiver,      
        
     DollarRate [CurrentRate],      
     @buyRate [Cost],      
     isNull(agent_premium_payout,0) agent_premium_payout,      
     isNull(agent_premium_send,0) agent_premium_send,      
     @buyRate-isNull(agent_premium_payout,0) [SettlementRate],      
      
   @buyRate-isNull(agent_premium_payout,0) CURRENT_SETTLEMENT,      
   isNull(receiver_rate_diff_value,0) CURRENT_MARGIN,      
   @buyRate-(isNull(agent_premium_payout,0)+isNUll(receiver_rate_diff_value,0)) CURRENT_CUSTOMER,      
       round((isNull(ExchangeRate,0)-isNull(agent_premium_send,0)),4) ho_offer,    ExchangeRate Alter_CURR_SETTLEMENT,    margin_sending_agent Alter_CURR_MARGIN,      
   SENDING_CUST_EXCHANGERATE Alter_CURR_CUSTOMER,      
       round((@buyRate-isNull(agent_premium_payout,0))/ExchangeRate,roundby) SEND_VS_PAYOUT_SETTMENT,      
   round((@buyRate-(isNull(agent_premium_payout,0)+isNUll(receiver_rate_diff_value,0)))/SENDING_CUST_EXCHANGERATE,roundby) SEND_VS_PAYOUT_CUSTOMER,      
   round(((@buyRate-isNull(agent_premium_payout,0))/ExchangeRate)-((@buyRate-(isNull(agent_premium_payout,0)+isNUll(receiver_rate_diff_value,0)))/SENDING_CUST_EXCHANGERATE),roundby) SEND_VS_PAYOUT_MARGIN,      
      
   Customer_rate [Old Rate],      
   round(DollarRate/(@sellRate-isNull(agent_premium_send,0)),@round_value,1) [Effective Rate]      
   ,currencyId,      
         
   'p' idType,@country,@updated_by updated_by,      
         
   @session_id session_id,      
   a.currencyType,roundby,      
   round(isNull(ExchangeRate,0)+isNull(agent_premium_send,0),4) alt_cost      
   from agentpayout_CurrencyRate e join       
   agentdetail a on a.agentcode=e.agentid join agentdetail p      
    on p.agentcode=e.payout_agent_id      
   where e.payout_agent_id=@payoutAgentID      
      
union all -- Country Wise      
      
 select 'Selling' ExType,      
   a.companyName Sender,      
   receiveCountry,      
   '-' Receiver,      
         
   ExchangeRate [Payout xRate],      
   @sellRate [Cost],      
   isNull(agent_premium_send,0) agent_premium_send,      
   isNull(agent_premium_payout,0) agent_premium_payout,      
   @sellRate-isNull(agent_premium_send,0) [SettlementRate],      
      
   @sellRate-isNull(agent_premium_send,0) CURRENT_SETTLEMENT,      
   isNull(margin_sending_agent,0) CURRENT_MARGIN,      
   (@sellRate-isNUll(margin_sending_agent,0))-(isNull(agent_premium_send,0)) CURRENT_CUSTOMER,      
    round((isNull(DollarRate,0)-isNull(agent_premium_payout,0)),4) ho_offer,    DollarRate Alter_CURR_SETTLEMENT,    isNUll(receiver_rate_diff_value,0) Alter_CURR_MARGIN,      
   payout_agent_rate Alter_CURR_CUSTOMER,      
       round(DollarRate/(@sellRate-isNull(agent_premium_send,0)),roundby) SEND_VS_PAYOUT_SETTMENT,      
   round(payout_agent_rate/((@sellRate-isNUll(margin_sending_agent,0))-(isNull(agent_premium_send,0))),roundby) SEND_VS_PAYOUT_CUSTOMER,      
   round((DollarRate/(@sellRate-isNull(agent_premium_send,0)))      
 -(payout_agent_rate/((@sellRate-isNUll(margin_sending_agent,0))-(isNull(agent_premium_send,0)))),roundby) SEND_VS_PAYOUT_MARGIN,      
            
   Customer_rate [Old Rate],      
   round(DollarRate/(@sellRate-isNull(agent_premium_send,0)),@round_value,1) [Effective Rate]      
   ,currencyId, 'c' idType,@country,@updated_by updated_by,         
   @session_id session_id, receiveCtype,roundby,      
   round(isNull(DollarRate,0)+isNull(agent_premium_payout,0),4) alt_cost      
   from agentCurrencyRate e join agentdetail a on a.agentcode=e.agentid      
   where  e.agentid=@payoutAgentID      
union all --- Agent Wise      
      
 select 'Selling' ExType,      
   a.companyName Sender,      
   receiveCountry,      
   p.companyName Receiver,      
         
   ExchangeRate [Payout xRate],      
   @sellRate [Cost],         
   isNull(agent_premium_send,0) agent_premium_send,      
   isNull(agent_premium_payout,0) agent_premium_payout,      
   @sellRate-isNull(agent_premium_send,0) [SettlementRate],      
      
   @sellRate-isNull(agent_premium_send,0) CURRENT_SETTLEMENT,      
   isNull(margin_sending_agent,0) CURRENT_MARGIN,      
   (@sellRate-isNUll(margin_sending_agent,0))-(isNull(agent_premium_send,0)) CURRENT_CUSTOMER,      
    round((isNull(DollarRate,0)-isNull(agent_premium_payout,0)),4) ho_offer,    DollarRate Alter_CURR_SETTLEMENT,    isNUll(receiver_rate_diff_value,0) Alter_CURR_MARGIN,      
   payout_agent_rate Alter_CURR_CUSTOMER,      
       round(DollarRate/(@sellRate-isNull(agent_premium_send,0)),roundby) SEND_VS_PAYOUT_SETTMENT,      
   round(payout_agent_rate/((@sellRate-isNUll(margin_sending_agent,0))-(isNull(agent_premium_send,0))),roundby) SEND_VS_PAYOUT_CUSTOMER,      
   round(      
 (DollarRate/(@sellRate-isNull(agent_premium_send,0)))      
 -(payout_agent_rate/((@sellRate-isNUll(margin_sending_agent,0))-(isNull(agent_premium_send,0)))),roundby) SEND_VS_PAYOUT_MARGIN,      
      
   Customer_rate [Old Rate],      
   round(DollarRate/(@sellRate-isNull(agent_premium_send,0)),@round_value,1) [Effective Rate]      
   ,currencyId,      
         
   'p' idType,@country,@updated_by updated_by,      
           
   @session_id session_id,      
   receiveCtype,roundby,      
   round(isNull(DollarRate,0)+isNull(agent_premium_payout,0),4) alt_cost      
   from agentpayout_CurrencyRate e join       
   agentdetail a on a.agentcode=e.agentid join agentdetail p      
    on p.agentcode=e.payout_agent_id      
   where e.agentid=@payoutAgentID      
      
      
      
  )       
 END      
 ELSE      
 BEGIN --------Country wise ExRate      
      
   insert into dbo.temp_forex_exchange      
   (      
   exType,sender,receiveCountry,receiver,      
         
   OldBuyRate,NewBuyRate,         
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
      
   roundby      
   ,alt_cost      
    )       
  (      
   select 'Buying' ExType,   -- B:Buying      
     a.companyName Sender,      
     receiveCountry,      
     receiveCountry Receiver,      
        
     DollarRate [CurrentRate],      
     @buyRate [Cost],      
     isNull(agent_premium_payout,0) agent_premium_payout,      
     isNull(agent_premium_send,0) agent_premium_send,      
     @buyRate-isNull(agent_premium_payout,0) [SettlementRate],      
      
      
   @buyRate-isNull(agent_premium_payout,0) CURRENT_SETTLEMENT,      
   isNull(receiver_rate_diff_value,0) CURRENT_MARGIN,      
   @buyRate-(isNull(agent_premium_payout,0)+isNUll(receiver_rate_diff_value,0)) CURRENT_CUSTOMER,      
       round((isNull(ExchangeRate,0)-isNull(agent_premium_send,0)),4) ho_offer,    ExchangeRate Alter_CURR_SETTLEMENT,        margin_sending_agent Alter_CURR_MARGIN,      
   SENDING_CUST_EXCHANGERATE Alter_CURR_CUSTOMER,      
       round((@buyRate-isNull(agent_premium_payout,0))/ExchangeRate,roundby) SEND_VS_PAYOUT_SETTMENT,      
   round((@buyRate-(isNull(agent_premium_payout,0)+isNUll(receiver_rate_diff_value,0)))      
    /SENDING_CUST_EXCHANGERATE,roundby) SEND_VS_PAYOUT_CUSTOMER,      
   round(((@buyRate-isNull(agent_premium_payout,0))/ExchangeRate)      
  -((@buyRate-(isNull(agent_premium_payout,0)+isNUll(receiver_rate_diff_value,0)))/SENDING_CUST_EXCHANGERATE)      
  ,roundby) SEND_VS_PAYOUT_MARGIN,      
      
   Customer_rate [Old Rate],      
   round(((@buyRate-isNull(agent_premium_payout,0))/ExchangeRate),@round_value) [Effective Rate],      
   currencyId,'c' idType,@country,@updated_by updated_by,@session_id session_id,      
   a.currencyType,roundby,      
   round(isNull(ExchangeRate,0)+isNull(agent_premium_send,0),4) alt_cost      
   from agentCurrencyRate e join agentdetail a on a.agentcode=e.agentid      
  where ReceiveCountry=@country      
union all ----------NEW ADDED by ANOOP      
---  Country wise      
 select 'Selling' ExType,      
   a.companyName Sender,      
   receiveCountry,      
   '-' Receiver,      
         
   ExchangeRate [Payout xRate],      
   @sellRate [Cost],      
   isNull(agent_premium_send,0) agent_premium_send,      
   isNull(agent_premium_payout,0) agent_premium_payout,      
   @sellRate-isNull(agent_premium_send,0) [SettlementRate],      
      
   @sellRate-isNull(agent_premium_send,0) CURRENT_SETTLEMENT,      
   isNull(margin_sending_agent,0) CURRENT_MARGIN,      
   (@sellRate-isNUll(margin_sending_agent,0))-(isNull(agent_premium_send,0)) CURRENT_CUSTOMER,      
    round((isNull(DollarRate,0)-isNull(agent_premium_payout,0)),4) ho_offer,    DollarRate Alter_CURR_SETTLEMENT,    isNUll(receiver_rate_diff_value,0) Alter_CURR_MARGIN,      
   payout_agent_rate Alter_CURR_CUSTOMER,      
       round(DollarRate/(@sellRate-isNull(agent_premium_send,0)),roundby) SEND_VS_PAYOUT_SETTMENT,      
   round(payout_agent_rate/((@sellRate-isNUll(margin_sending_agent,0))-(isNull(agent_premium_send,0))),roundby) SEND_VS_PAYOUT_CUSTOMER,      
   round((DollarRate/(@sellRate-isNull(agent_premium_send,0)))      
 -(payout_agent_rate/((@sellRate-isNUll(margin_sending_agent,0))-(isNull(agent_premium_send,0)))),roundby) SEND_VS_PAYOUT_MARGIN,      
            
   Customer_rate [Old Rate],      
   round(DollarRate/(@sellRate-isNull(agent_premium_send,0)),@round_value,1) [Effective Rate]      
   ,currencyId, 'c' idType,@country,@updated_by updated_by,         
   @session_id session_id, receiveCtype,roundby,      
   round(isNull(DollarRate,0)+isNull(agent_premium_payout,0),4) alt_cost      
   from agentCurrencyRate e join agentdetail a on a.agentcode=e.agentid      
   where  a.country=@country and a.agentCode not in (select payoutagentid from roster where country=@country and payoutagentid is not null)      
union all  -- AGENT WISE      
      
  select 'Selling' ExType,      
   a.companyName Sender,      
   receiveCountry,      
   p.companyName Receiver,      
          
   ExchangeRate [Payout xRate],      
   @sellRate [Cost],      
   isNull(agent_premium_send,0) agent_premium_send,      
   isNull(agent_premium_payout,0) agent_premium_payout,      
   @sellRate-isNull(agent_premium_send,0) [SettlementRate],      
      
   @sellRate-isNull(agent_premium_send,0) CURRENT_SETTLEMENT,      
   isNull(margin_sending_agent,0) CURRENT_MARGIN,      
   (@sellRate-isNUll(margin_sending_agent,0))-(isNull(agent_premium_send,0)) CURRENT_CUSTOMER,      
    round((isNull(DollarRate,0)-isNull(agent_premium_payout,0)),4) ho_offer,    DollarRate Alter_CURR_SETTLEMENT,    isNUll(receiver_rate_diff_value,0) Alter_CURR_MARGIN,      
   payout_agent_rate Alter_CURR_CUSTOMER,      
       round(DollarRate/(@sellRate-isNull(agent_premium_send,0)),roundby) SEND_VS_PAYOUT_SETTMENT,      
   round(payout_agent_rate/((@sellRate-isNUll(margin_sending_agent,0))-(isNull(agent_premium_send,0))),roundby) SEND_VS_PAYOUT_CUSTOMER,      
   round((DollarRate/(@sellRate-isNull(agent_premium_send,0)))      
 -(payout_agent_rate/((@sellRate-isNUll(margin_sending_agent,0))-(isNull(agent_premium_send,0)))),roundby) SEND_VS_PAYOUT_MARGIN,      
            
   Customer_rate [Old Rate],      
   round(DollarRate/(@sellRate-isNull(agent_premium_send,0)),@round_value,1) [Effective Rate]      
   ,currencyId, 'p' idType,@country,@updated_by updated_by,         
   @session_id session_id, receiveCtype,roundby,      
   round(isNull(DollarRate,0)+isNull(agent_premium_payout,0),4) alt_cost      
   from agentpayout_CurrencyRate e join       
   agentdetail a on a.agentcode=e.agentid join agentdetail p      
   on p.agentcode=e.payout_agent_id      
   where  a.country=@country       
   and a.agentCode not in (select payoutagentid from roster where country=@country and payoutagentid is not null)      
       
      
  ---ANOOP ADDed END       
         
  )      
         
 end                   
   select sno,ExType,Sender,receiveCountry,Receiver, OldBuyRate [Current], NewBuyRate [Cost],      
     OldSelRate [Preimum],alt_premium,NewSelRate [NewRate],currencyId,      
     CURRENT_SETTLEMENT,      
     CURRENT_MARGIN,      
     CURRENT_CUSTOMER,      
           
     ho_offer,      
     ExchangeRate Alter_CURR_SETTLEMENT,      margin_sending_agent Alter_CURR_MARGIN,      
     SENDING_CUST_EXCHANGERATE Alter_CURR_CUSTOMER,      
      
     SEND_VS_PAYOUT_SETTMENT,      
     SEND_VS_PAYOUT_CUSTOMER,      
     SEND_VS_PAYOUT_MARGIN,      
      
     OldEffRate [Old Rate],NewEffRate [Effective Rate],      
     currencyId,idType,updated_by,session_id,      
     Payout_Currency_Code,roundby,      
     alt_cost      
     from temp_forex_exchange  where updated_by=@updated_by and       
   session_id=@session_id       
   order by exType,receiveCountry,payout_currency_code,sender      
      
END       
      
IF @flag='p' --- PREVIEW REPORT      
BEGIN       
 IF @session_id IS NULL      
 BEGIN      
  SET @session_id= REPLACE(newid(),'-','_')      
 end      
       
 DELETE dbo.temp_forex_exchange WHERE session_id=@session_id      
 IF @payoutAgentID IS  NOT NULL      
 BEGIN       
  insert into dbo.temp_forex_exchange      
   (exType,sender,receiveCountry,receiver,OldBuyRate,NewBuyRate,OldSelRate,NewSelRate,CURRENT_SETTLEMENT,CURRENT_MARGIN,      
   CURRENT_CUSTOMER,ExchangeRate,margin_sending_agent, SENDING_CUST_EXCHANGERATE,SEND_VS_PAYOUT_SETTMENT,SEND_VS_PAYOUT_CUSTOMER,      
   SEND_VS_PAYOUT_MARGIN,OldEffRate,NewEffRate,currencyId,idType,effictiveCountry,updated_by,session_id,      
   Payout_Currency_Code,roundby,alt_premium,ho_offer,alt_cost      
   )      
   (        
   select 'Buying' ExType,      
     a.companyName Sender,      
     receiveCountry,      
     p.companyName Receiver,      
     DollarRate [CurrentRate],      
     DollarRate+isNull(agent_premium_payout,0)  [Cost],      
     isNull(agent_premium_payout,0) agent_premium_payout,      
     DollarRate [SettlementRate],      
      
   DollarRate CURRENT_SETTLEMENT,      
   isNull(receiver_rate_diff_value,0) CURRENT_MARGIN,      
   Payout_agent_rate CURRENT_CUSTOMER,      
       ExchangeRate Alter_CURR_SETTLEMENT,    margin_sending_agent Alter_CURR_MARGIN,      
   SENDING_CUST_EXCHANGERATE Alter_CURR_CUSTOMER,      
       NPRRate SEND_VS_PAYOUT_SETTMENT,      
   Customer_rate SEND_VS_PAYOUT_CUSTOMER,      
   Customer_diff_value SEND_VS_PAYOUT_MARGIN,      
      
   Customer_rate [Old Rate],      
   Customer_rate [Effective Rate]      
   ,currencyId,      
         
   'p' idType,@country,@updated_by updated_by,      
         
   @session_id session_id,      
   a.currencyType,roundby,      
   isNull(agent_premium_send,0) agent_premium_send,      
   round((isNull(ExchangeRate,0)-isNull(agent_premium_send,0)),4) ho_offer,      
   round(isNull(ExchangeRate,0)+isNull(agent_premium_send,0),4) alt_cost      
   from agentpayout_CurrencyRate e join       
   agentdetail a on a.agentcode=e.agentid join agentdetail p      
    on p.agentcode=e.payout_agent_id      
   where e.payout_agent_id=@payoutAgentID      
      
union all -- Country wise      
      
 select 'Selling' ExType,      
   companyName Sender,      
   receiveCountry,      
   '-' Receiver,      
         
   ExchangeRate [Payout xRate],      
   ExchangeRate + isNull(agent_premium_send,0) [Cost],      
   isNull(agent_premium_send,0) agent_premium_send,      
   ExchangeRate [SettlementRate],      
      
   ExchangeRate CURRENT_SETTLEMENT,      
   isNull(margin_sending_agent,0) CURRENT_MARGIN,      
   SENDING_CUST_EXCHANGERATE CURRENT_CUSTOMER,      
    DollarRate Alter_CURR_SETTLEMENT,    isNUll(receiver_rate_diff_value,0) Alter_CURR_MARGIN,      
   payout_agent_rate Alter_CURR_CUSTOMER,      
       NPRRate SEND_VS_PAYOUT_SETTMENT,      
   Customer_rate SEND_VS_PAYOUT_CUSTOMER,      
   Customer_diff_value SEND_VS_PAYOUT_MARGIN,      
            
   Customer_rate [Old Rate],      
   Customer_rate [Effective Rate]      
   ,currencyId,      
         
   'c' idType,@country,@updated_by updated_by,      
         
   @session_id session_id,      
   receiveCtype,roundby,      
   isNull(agent_premium_payout,0) agent_premium_payout,      
   round((isNull(DollarRate,0)-isNull(agent_premium_payout,0)),4) ho_offer,      
   round(isNull(DollarRate,0)+isNull(agent_premium_payout,0),4) alt_cost      
      
   from agentCurrencyRate e join       
   agentdetail a on a.agentcode=e.agentid      
   where  e.agentid=@payoutAgentID      
union all -- Agent Wise      
      
 select 'Selling' ExType,      
   a.companyName Sender,      
   receiveCountry,      
   p.companyName Receiver,      
         
   ExchangeRate [Payout xRate],      
   ExchangeRate + isNull(agent_premium_send,0) [Cost],      
   isNull(agent_premium_send,0) agent_premium_send,      
   ExchangeRate [SettlementRate],      
      
   ExchangeRate CURRENT_SETTLEMENT,      
   isNull(margin_sending_agent,0) CURRENT_MARGIN,      
   SENDING_CUST_EXCHANGERATE CURRENT_CUSTOMER,      
    DollarRate Alter_CURR_SETTLEMENT,    isNUll(receiver_rate_diff_value,0) Alter_CURR_MARGIN,      
   payout_agent_rate Alter_CURR_CUSTOMER,      
       NPRRate SEND_VS_PAYOUT_SETTMENT,      
   Customer_rate SEND_VS_PAYOUT_CUSTOMER,      
   Customer_diff_value SEND_VS_PAYOUT_MARGIN,      
            
   Customer_rate [Old Rate],      
   Customer_rate [Effective Rate]      
   ,currencyId,      
            
   'p' idType,@country,@updated_by updated_by,      
           
   @session_id session_id,      
   receiveCtype,roundby,      
   isNull(agent_premium_payout,0) agent_premium_payout,      
   round((isNull(DollarRate,0)-isNull(agent_premium_payout,0)),4) ho_offer,      
   round(isNull(DollarRate,0)+isNull(agent_premium_payout,0),4) alt_cost      
   from agentpayout_CurrencyRate e join       
   agentdetail a on a.agentcode=e.agentid join agentdetail p      
    on p.agentcode=e.payout_agent_id      
   where e.agentid=@payoutAgentID      
  )       
 END      
 ELSE      
 BEGIN --------Country wise ExRate      
   insert into dbo.temp_forex_exchange      
   (      
   exType,sender,receiveCountry,receiver,OldBuyRate,NewBuyRate,OldSelRate,NewSelRate,CURRENT_SETTLEMENT,      
       CURRENT_MARGIN,      
   CURRENT_CUSTOMER,ExchangeRate,margin_sending_agent,SENDING_CUST_EXCHANGERATE,SEND_VS_PAYOUT_SETTMENT,      
   SEND_VS_PAYOUT_CUSTOMER,SEND_VS_PAYOUT_MARGIN,OldEffRate,NewEffRate,currencyId,idType,effictiveCountry,      
   updated_by, session_id, Payout_Currency_Code,roundby,alt_premium,ho_offer,alt_cost      
    )       
  (      
   select 'Buying' ExType,   -- B:Buying      
     a.companyName Sender,      
     receiveCountry,      
     receiveCountry Receiver,      
        
     DollarRate [CurrentRate],      
     DollarRate+isNull(agent_premium_payout,0)  [Cost],      
     isNull(agent_premium_payout,0) agent_premium_payout,      
     DollarRate [SettlementRate],      
      
   DollarRate CURRENT_SETTLEMENT,      
   isNull(receiver_rate_diff_value,0) CURRENT_MARGIN,      
   Payout_agent_rate CURRENT_CUSTOMER,      
       ExchangeRate Alter_CURR_SETTLEMENT,    margin_sending_agent Alter_CURR_MARGIN,      
   SENDING_CUST_EXCHANGERATE Alter_CURR_CUSTOMER,      
       NPRRate SEND_VS_PAYOUT_SETTMENT,      
   Customer_rate SEND_VS_PAYOUT_CUSTOMER,      
   Customer_diff_value SEND_VS_PAYOUT_MARGIN,      
      
   Customer_rate [Old Rate],      
   Customer_rate [Effective Rate]   
   ,currencyId,      
   'c' idType,@country,@updated_by updated_by,@session_id session_id,      
   a.currencyType,roundby,      
   isNull(agent_premium_send,0) agent_premium_send,      
   round((isNull(DollarRate,0)-isNull(agent_premium_payout,0)),4) ho_offer,      
   round(isNull(DollarRate,0)+isNull(agent_premium_payout,0),4) alt_cost      
   from agentCurrencyRate e join agentdetail a on a.agentcode=e.agentid      
   where ReceiveCountry=@country      
union all ----------NEW ADDED by ANOOP      
--Country Wise      
 select 'Selling' ExType,      
   a.companyName Sender,      
   receiveCountry,      
   '-' Receiver,      
         
   ExchangeRate [Payout xRate],      
   ExchangeRate + isNull(agent_premium_send,0)  [Cost],      
   isNull(agent_premium_send,0) agent_premium_send,      
   ExchangeRate [SettlementRate],      
      
   ExchangeRate CURRENT_SETTLEMENT,      
   isNull(margin_sending_agent,0) CURRENT_MARGIN,      
   (ExchangeRate-isNUll(margin_sending_agent,0)) CURRENT_CUSTOMER,      
    DollarRate Alter_CURR_SETTLEMENT,    isNUll(receiver_rate_diff_value,0) Alter_CURR_MARGIN,      
   payout_agent_rate Alter_CURR_CUSTOMER,      
       round(DollarRate/ExchangeRate,roundby) SEND_VS_PAYOUT_SETTMENT,      
   round(payout_agent_rate/(ExchangeRate-isNUll(margin_sending_agent,0)),roundby) SEND_VS_PAYOUT_CUSTOMER,      
   round((DollarRate/ExchangeRate)      
 -(payout_agent_rate/(ExchangeRate-isNUll(margin_sending_agent,0))),roundby) SEND_VS_PAYOUT_MARGIN,      
            
   Customer_rate [Old Rate],      
   round(DollarRate/(ExchangeRate),@round_value,1) [Effective Rate]      
   ,currencyId, 'c' idType,@country,@updated_by updated_by,         
   @session_id session_id, receiveCtype,roundby,      
   isNull(agent_premium_payout,0) agent_premium_payout,      
   round((isNull(ExchangeRate,0)-isNull(agent_premium_send,0)),4) ho_offer,      
   round(isNull(ExchangeRate,0)+isNull(agent_premium_send,0),4) alt_cost      
    from agentCurrencyRate e join agentdetail a on a.agentcode=e.agentid      
   where  a.country=@country and a.agentCode not in (select payoutagentid from roster where country=@country and payoutagentid is not null)      
Union all -- Agent Wise      
 select 'Selling' ExType,      
   a.companyName Sender,      
   receiveCountry,      
   p.companyName Receiver,      
         
   ExchangeRate [Payout xRate],      
   ExchangeRate + isNull(agent_premium_send,0)  [Cost],      
   isNull(agent_premium_send,0) agent_premium_send,      
   ExchangeRate [SettlementRate],      
      
   ExchangeRate CURRENT_SETTLEMENT,      
   isNull(margin_sending_agent,0) CURRENT_MARGIN,      
   (ExchangeRate-isNUll(margin_sending_agent,0)) CURRENT_CUSTOMER,      
    DollarRate Alter_CURR_SETTLEMENT,    isNUll(receiver_rate_diff_value,0) Alter_CURR_MARGIN,      
   payout_agent_rate Alter_CURR_CUSTOMER,      
       round(DollarRate/ExchangeRate,roundby) SEND_VS_PAYOUT_SETTMENT,      
   round(payout_agent_rate/(ExchangeRate-isNUll(margin_sending_agent,0)),roundby) SEND_VS_PAYOUT_CUSTOMER,      
   round((DollarRate/ExchangeRate)      
 -(payout_agent_rate/(ExchangeRate-isNUll(margin_sending_agent,0))),roundby) SEND_VS_PAYOUT_MARGIN,      
            
   Customer_rate [Old Rate],      
   round(DollarRate/(ExchangeRate),@round_value,1) [Effective Rate]      
   ,currencyId, 'c' idType,@country,@updated_by updated_by,         
   @session_id session_id, receiveCtype,roundby,      
   isNull(agent_premium_payout,0) agent_premium_payout,      
   round((isNull(ExchangeRate,0)-isNull(agent_premium_send,0)),4) ho_offer,      
   round(isNull(ExchangeRate,0)+isNull(agent_premium_send,0),4) alt_cost      
       
   from agentpayout_CurrencyRate e join       
    agentdetail a on a.agentcode=e.agentid join agentdetail p      
   on p.agentcode=e.payout_agent_id      
   where  a.country=@country       
   and a.agentCode not in (select payoutagentid from roster where country=@country and payoutagentid is not null)      
       
      
  ---ANOOP ADDed END       
           )      
         
 end                   
   select sno,ExType,Sender,receiveCountry,Receiver, OldBuyRate [Current], NewBuyRate [Cost],      
     OldSelRate [Preimum],NewSelRate [NewRate],currencyId,      
     CURRENT_SETTLEMENT,      
     CURRENT_MARGIN,      
     CURRENT_CUSTOMER,      
      
     ExchangeRate Alter_CURR_SETTLEMENT,      margin_sending_agent Alter_CURR_MARGIN,      
     SENDING_CUST_EXCHANGERATE Alter_CURR_CUSTOMER,      
      
     SEND_VS_PAYOUT_SETTMENT,      
     SEND_VS_PAYOUT_CUSTOMER,      
     SEND_VS_PAYOUT_MARGIN,      
      
     OldEffRate [Old Rate],NewEffRate [Effective Rate],      
     currencyId,idType,updated_by,session_id,      
     Payout_Currency_Code,roundby,alt_premium,ho_offer,alt_cost      
     from temp_forex_exchange  where updated_by=@updated_by and       
   session_id=@session_id       
   order by exType,receiveCountry,sender      
      
END       
if @flag='c'      
 begin      
      
  declare @sql varchar(5000),@sqlC varchar(5000),@sql1 varchar(5000)      
  set @effSno=replace(@effSno,' ','')      
       
DECLARE @idoc int      
DECLARE @doc varchar(8000)      
      
exec sp_xml_preparedocument @idoc OUTPUT, @xmlData      
-----------------------------------------------------------------      
SELECT * into #ztbl_xmlvalue      
FROM   OPENXML (@idoc, '/ExRate/Rate',2)      
         WITH ( currencyid int '@currencyId',      
    sno  int   '@sno',      
                premium  money '@premium',      
                CURRENT_MARGIN  money '@CURRENT_MARGIN',      
                Alter_CURR_MARGIN  money '@ALTER_CURR_MARGIN',      
    roundby  int '@roundby',      
    alt_premium money '@alt_premium'      
   )      
exec sp_xml_removedocument @idoc      
      
      
select       
t.ExType,t.session_id,t.sno,x.currencyId,t.idType,      
NewBuyRate,x.premium,      
round(NewBuyRate - x.premium,6) Current_SETTLEMENT,      
x.Current_MARGIN,      
round((NewBuyRate - x.premium)-x.Current_MARGIN,6) Current_Customer,      
      
x.alt_premium agent_premium_send,      
      
case when x.alt_premium=t.alt_premium then       
 ExchangeRate      
else      
 round(((t.alt_premium+t.ExchangeRate)-x.alt_premium),6)        
end ExchangeRate,      
      
margin_sending_agent,      
      
case when x.alt_premium=t.alt_premium then      
 SENDING_CUST_EXCHANGERATE      
else      
 round(      
  (((t.alt_premium+t.ExchangeRate)-x.alt_premium)-t.margin_sending_agent)      
 ,6)      
end SENDING_CUST_EXCHANGERATE,      
      
case when x.alt_premium=t.alt_premium then      
 round(      
 case when exType='Buying' then       
  ((NewBuyRate - x.premium)/ExchangeRate)      
 else (ExchangeRate/(NewBuyRate - x.premium)) end,x.roundby)        
else      
 round(      
 case when exType='Buying' then       
  ((NewBuyRate - x.premium)/(t.alt_premium+t.ExchangeRate-x.alt_premium))      
 else ((t.alt_premium+t.ExchangeRate-x.alt_premium)/(NewBuyRate - x.premium)) end,x.roundby)      
end SEND_VS_PAYOUT_SETTMENT,      
      
case when x.alt_premium=t.alt_premium then      
 round(      
 case when exType='Buying' then       
  (((NewBuyRate - x.premium)-x.Current_MARGIN)/(SENDING_CUST_EXCHANGERATE))      
 else (SENDING_CUST_EXCHANGERATE/((NewBuyRate - x.premium)-x.Current_MARGIN)) end,x.roundby)      
else      
 round(      
 case when exType='Buying' then       
  (((NewBuyRate - x.premium)-x.Current_MARGIN)/((((t.alt_premium+t.ExchangeRate)-x.alt_premium)-t.margin_sending_agent)))      
 else      
  (((t.alt_premium+t.ExchangeRate)-x.alt_premium)+t.margin_sending_agent)/((NewBuyRate - x.premium)-x.Current_MARGIN) end,x.roundby)      
      
end  SEND_VS_Payout_Customer,      
      
case when x.alt_premium=t.alt_premium then      
 round(      
 case when exType='Buying' then       
  (((NewBuyRate - x.premium)/ExchangeRate)-(((NewBuyRate - x.premium)-x.Current_MARGIN)/(SENDING_CUST_EXCHANGERATE)))      
 else      
  ((ExchangeRate/(NewBuyRate - x.premium))-(SENDING_CUST_EXCHANGERATE/((NewBuyRate - x.premium)-x.Current_MARGIN)))      
  end,x.roundby)      
else    
 round(      
 case when exType='Buying' then       
  (((NewBuyRate - x.premium)/(t.alt_premium+t.ExchangeRate-x.alt_premium))-      
  (((NewBuyRate - x.premium)-x.Current_MARGIN)/((((t.alt_premium+t.ExchangeRate)-x.alt_premium)-t.margin_sending_agent))))      
 else      
  (((t.alt_premium+t.ExchangeRate-x.alt_premium)/(NewBuyRate - x.premium))-      
  ((((t.alt_premium+t.ExchangeRate)-x.alt_premium)+t.margin_sending_agent)/((NewBuyRate - x.premium)-x.Current_MARGIN)))      
  end,x.roundby)      
end  SEND_VS_Payout_MARGIN,      
x.roundby      
      
into #temp_ExRate      
from temp_forex_exchange t join #ztbl_xmlvalue x      
on t.sno=x.sno and t.currencyId=x.currencyId      
      
--select * from #temp_ExRate      
      
      
declare @sql_country varchar(8000)      
      
   SET @sql_country ='update agentCurrencyRate set      
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
     update_by=''HO:'+@updated_by+''',      
     roundby=t.roundby,      
     audit_process_id='''+ @session_id +'''      
     from agentCurrencyRate r,  #temp_ExRate t      
     where r.currencyid=t.currencyid and t.idtype=''c''       
     and sno in ('+@effSno+')      
     and t.session_id='''+ @session_id +''''      
           
--      
--    IF @payoutAgentID IS NULL      
--    BEGIN      
--     exec (@sql_country)      
--        
--    END      
--      
--   else      
--    begin      
    exec (@sql_country)      
    SET @sql='update agentpayout_CurrencyRate set       
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
     update_by=''HO:'+@updated_by+''',      
     roundby=t.roundby ,      
     audit_process_id='''+ @session_id +'''         
     from agentpayout_CurrencyRate r, #temp_ExRate t      
     where r.currencyid=t.currencyid and t.idtype=''p''       
     and sno in ('+@effSno+') and t.session_id='''+@session_id+''''       
  -- print @sql      
   exec (@sql)      
 --  END       
         
   update roster set buyRate=@buyRate,      
      sellRate=@sellRate,      
      rateDiff=@sellRate-@buyRate,      
      updated_by=@updated_by,      
      updated_ts=dbo.getDateHO(getutcdate()),      
      Round_By=@round_value,      
      audit_process_id=@session_id,      
      buy_sell_margin=@sellRate-@buyRate      
      where sno=@sno      
  
    
  
    EXEC [spa_NotificationExRate] @session_id,@effSno
	----update to partner's System
	EXEC [spa_ExRateUpdatePartner] @session_id,@effSno,@updated_by
	
	-- DELETE temp_forex_exchange  
 select 'Success' status,'The Forex of '+@country+' is updated sucessfully' msg      
END   
  