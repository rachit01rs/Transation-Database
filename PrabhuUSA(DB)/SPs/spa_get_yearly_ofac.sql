GO
/****** Object:  StoredProcedure [dbo].[spa_get_yearly_ofac]    Script Date: 08/22/2014 16:40:12 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spa_get_yearly_ofac]') AND TYPE in (N'P', N'PC'))
DROP PROCEDURE [dbo].[spa_get_yearly_ofac]
GO

/****** Object:  StoredProcedure [dbo].[spa_get_yearly_ofac]    Script Date: 08/22/2014 16:40:12 ******/
/*
** Database :		PrabhuUSA
** Object :			spa_get_yearly_ofac
** Purpose :		Yearly Report generation
** Author:			Sudaman Shrestha
** Date:			08/22/2014

** Modification:	made stored procedure capable of generating report based on different report type(ofac,compliance,total transaction,total cancelled)
** Date:			09/05/2014
** Report type:		'tt' = total transaction, 'ct' = total cancelled transaction, 'ofac' = ofac, 'cpl' = compliance
** Note:			pass @batch_Id as shorter as possible. There is a maximum limit defined for naming table name = 50. In my case 'YR' = Yearly Report
** Execute Examples :
	spa_get_yearly_report @batch_Id='YR', @login_user_id ='admin', @sel_year='2013',@report_type='tt'
*/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO
   
CREATE PROC [dbo].[spa_get_yearly_ofac]  
	@agent_id VARCHAR(50)=NULL,    
	@sel_month INT=NULL,    
	@sel_year INT=NULL,    
	@date_type VARCHAR(200)=NULL,  
	@payout_country VARCHAR(50)=null,    
	@process_id VARCHAR(200)=NULL,	     
	@login_user_id VARCHAR(100),    
	@batch_Id VARCHAR(100),    
	@SenderCountry VARCHAR(100)=NUll,    
	@pay_agent VARCHAR(50)=NULL,  
	@sender_state VARCHAR(50)=NULL,
	@report_type VARCHAR(10)

AS

DECLARE @where_condition VARCHAR(1000)
DECLARE @sql1 VARCHAR(8000)
DECLARE @temptablename1  VARCHAR(500)
--DECLARE @sql VARCHAR(5000)
DECLARE @from_date VARCHAR(20)
DECLARE @to_date VARCHAR(50)
DECLARE @sel_Label VARCHAR(100)
DECLARE @full_batch_id_name VARCHAR(200)

IF @sel_month IS NULL    
	BEGIN    
		SET @from_date=CAST(@sel_year AS VARCHAR)+'-01-01'    
		SET @to_date=CAST(@sel_year AS VARCHAR)+'-12-31' +' 23:59:59.998'    
		SET @sel_Label=CAST(@sel_year AS VARCHAR)    
	END    
ELSE     
	BEGIN    
		SET @from_date=CAST(@sel_year AS VARCHAR)+'-'+CAST(@sel_month AS VARCHAR)+'-01'    
		SET @to_date=CAST(@sel_year AS VARCHAR)  +'-'+CAST(@sel_month AS VARCHAR)+'-'+CAST(dbo.FNALastDayInMonth(@from_date) AS VARCHAR) +' 23:59:59.998'
	END 

IF @report_type <>'ofac' AND @report_type <> 'cpl' SET @temptablename1 =dbo.FNAProcessTBl(@batch_Id, @login_user_id,@report_type+@process_id)

CREATE TABLE #TempResult1(    
	sno INT IDENTITY(1,1)    
)    
CREATE TABLE #temp_source1(    
	month_id VARCHAR(20),    
	month_name VARCHAR(50),    
	--agent_name VARCHAR(100),
	country_name VARCHAR(150),    
	tot_txn INT    
)

IF @report_type ='ct'
	SET @where_condition = 'transStatus=''Cancel'' AND '
	
IF @report_type ='tt'
	SET @where_condition = ''	

IF @report_type ='ofac' OR @report_type = 'cpl'
	BEGIN
		DECLARE @sql2 VARCHAR(8000)
		DECLARE @sql3 VARCHAR(8000)
		DECLARE @temptablename2 VARCHAR(500) 
		DECLARE @temptablename3 VARCHAR(500)
		
		SET @temptablename1 =dbo.FNAProcessTBl(@batch_Id, @login_user_id,'all'+@report_type+@process_id)
		SET @temptablename2 =dbo.FNAProcessTBl(@batch_Id, @login_user_id, 'hold'+@report_type+@process_id)
		SET @temptablename3 =dbo.FNAProcessTBl(@batch_Id, @login_user_id,'cancel'+@report_type+@process_id)
		 
		CREATE TABLE #TempResult2(    
			sno INT IDENTITY(1,1)    
		) 
		   
		CREATE TABLE #temp_source2(    
			month_id VARCHAR(20),    
			month_name VARCHAR(50),    
			--agent_name VARCHAR(100),
			country_name VARCHAR(150),    
			tot_txn INT    
		)  

		CREATE TABLE #TempResult3(    
			sno INT IDENTITY(1,1)    
		)    
		CREATE TABLE #temp_source3(    
			month_id VARCHAR(20),    
			month_name VARCHAR(50),    
			--agent_name VARCHAR(100),
			country_name VARCHAR(150),    
			tot_txn INT    
		)
		 
		IF @report_type ='ofac' SET @where_condition = 'ofac_list = ''y'' AND '
		IF @report_type = 'cpl' SET @where_condition = 'compliance_flag = ''y'' AND ' 
	END 
	
------------COMMON SQL----------
	
SET @sql1 ='    
	INSERT #temp_source1(month_id, month_name, country_name,tot_txn)    
	SELECT t.month_id, t.month_name, country_name,m.noOftrans FROM(    
	SELECT month(local_DOT) AS [month_id], year(local_DOT) AS [Year],SenderCountry AS country_name, count(*) AS noOfTrans    
	FROM moneysend m WITH(NOLOCK)  
	RIGHT OUTER JOIN tbl_month t WITH(NOLOCK) ON t.month_id = month(local_DOT)   
	JOIN agentdetail a WITH(NOLOCK) ON a.agentcode=m.agentid'     

SET @sql1 =@sql1 +' WHERE '+@where_condition+' local_DOT BETWEEN '''+@from_date+''' AND 
				'''+@to_date+''' AND a.agentType IN(''Sender Agent'',''Send and Pay'')' 

SET @sql1 =@sql1  + ' GROUP BY month(local_DOT),year(local_DOT),SenderCountry ) m 
	RIGHT OUTER JOIN tbl_month t WITH(NOLOCK) ON t.month_id =m.month_id    
	WHERE (year is null or year='+ CAST(@sel_year AS VARCHAR)   +')' 

IF @sel_month is not null    
	SET @sql1 =@sql1  + ' AND t.month_id='+CAST(@sel_month AS VARCHAR)      

PRINT @sql1     
EXEC(@sql1 )
    
IF EXISTS(SELECT TOP 1 country_name FROM #temp_source1)    
	BEGIN    
		SET @sql1 ='sys_CrossTab ''#temp_source1'',''month_name'',''month_name'',''2010-+''''''''+cast(month_id as varchar)+''''''''-1'',    
			''tot_txn'',''country_name'',''#TempResult1'',''sum'',0,NULL,0,''Total'',null,''country_name'',''int'''    

		PRINT @sql1  

		EXEC(@sql1) 
   
		ALTER TABLE #TempResult1    
		DROP COLUMN sno    

		EXEC('SELECT * INTO '+@temptablename1+' FROM #TempResult1')    
	END   
ELSE   
	BEGIN    
		SELECT 'Warring' Sno, 'No Transaction Found for the givien filter' Message    
	END
	
 
------------HOLD OFAC SQL----------

IF @report_type ='ofac' OR @report_type = 'cpl'
	BEGIN
		SET @sql2 ='    
			INSERT #temp_source2(month_id,month_name,country_name,tot_txn)    
			SELECT t.month_id,t.month_name,country_name,m.noOftrans FROM(    
			SELECT month(local_DOT) AS [month_id], year(local_DOT) AS [Year],SenderCountry AS country_name,count(*) AS noOfTrans    
			FROM moneysend m WITH(NOLOCK)  
			RIGHT OUTER JOIN tbl_month t WITH(NOLOCK) ON t.month_id = month(local_DOT)   
			JOIN agentdetail a WITH(NOLOCK) ON a.agentcode=m.agentid'     
	  
		SET @sql2 = @sql2 +' WHERE transStatus =''Payment'' AND '+ @where_condition +' local_DOT BETWEEN '''+@from_date+''' AND 
					'''+@to_date+''' AND a.agentType  IN(''Sender Agent'',''Send and Pay'')'
		   
		SET @sql2 = @sql2  + ' GROUP BY month(local_DOT),year(local_DOT),SenderCountry ) m 
			RIGHT OUTER JOIN tbl_month t WITH(NOLOCK) ON t.month_id =m.month_id    
			WHERE (year is null OR year='+ CAST(@sel_year AS VARCHAR)   +')' 
		    
		IF @sel_month IS NOT NULL   
			SET @sql2 = @sql2  + ' and t.month_id='+CAST(@sel_month AS VARCHAR)      
		 
			PRINT @sql2     
			EXEC(@sql2 ) 
	   
		IF EXISTS (select top 1 country_name from #temp_source2)    
			BEGIN    
				SET @sql2 ='sys_CrossTab ''#temp_source2'',''month_name'',''month_name'',''2010-+''''''''+cast(month_id as varchar)+''''''''-1'',    
					''tot_txn'',''country_name'',''#TempResult2'',''sum'',0,NULL,0,''Total'',null,''country_name'',''int'''    
			    
				PRINT @sql2     
				EXEC(@sql2)    
				ALTER TABLE #TempResult2    
					DROP COLUMN sno     
			   
				EXEC('SELECT * INTO '+@temptablename2 +' FROM #TempResult2')     
			END    
		ELSE    
			BEGIN    
			 SELECT 'Warring' Sno, 'No Transaction Found for the givien filter' Message    
			END


------------CANCEL OFAC/COMPLIANCE SQL----------
 
		SET @sql3 ='    
			INSERT #temp_source3(month_id,month_name,country_name,tot_txn)    
			SELECT t.month_id,t.month_name,country_name,m.noOftrans FROM(    
			SELECT month(local_DOT) AS [month_id], year(local_DOT) AS [Year],SenderCountry AS country_name,count(*) AS noOfTrans    
			FROM moneysend m WITH(NOLOCK)  
			RIGHT OUTER JOIN tbl_month t WITH(NOLOCK) ON t.month_id = month(local_DOT)   
			JOIN agentdetail a WITH(NOLOCK) ON a.agentcode=m.agentid'     
		  
		SET @sql3 =@sql3 +' WHERE transStatus=''Cancel'' AND '+ @where_condition + ' local_DOT BETWEEN '''+@from_date+''' AND 
				'''+@to_date+''' AND a.agentType  IN(''Sender Agent'',''Send and Pay'')' 
		   
		SET @sql3 =@sql3  + ' GROUP BY month(local_DOT),year(local_DOT),SenderCountry ) m 
			RIGHT OUTER JOIN tbl_month t with(nolock) ON t.month_id =m.month_id    
			WHERE (year is null OR year='+ CAST(@sel_year AS VARCHAR)   +')' 
		    
		IF @sel_month is not null    
			SET @sql3 =@sql3  + ' AND t.month_id='+CAST(@sel_month AS VARCHAR)      
		 
			PRINT @sql3     
			EXEC(@sql3 )   
		     
		IF EXISTS (SELECT TOP 1 country_name FROM #temp_source3)    
			BEGIN    
				SET @sql3 ='sys_CrossTab ''#temp_source3'',''month_name'',''month_name'',''2010-+''''''''+cast(month_id as varchar)+''''''''-1'',    
					''tot_txn'',''country_name'',''#TempResult3'',''sum'',0,NULL,0,''Total'',null,''country_name'',''int'''    
		    
				PRINT @sql3     
				EXEC(@sql3 )    
				ALTER TABLE #TempResult3    
					DROP COLUMN sno      
				EXEC('SELECT * INTO '+@temptablename3+' FROM #TempResult3')
			END    
		ELSE    
			BEGIN    
				SELECT 'Warring' Sno, 'No Transaction Found for the givien filter' Message    
			END    
    END
    
    
DECLARE @msg_agenttype VARCHAR(100),@url_desc VARCHAR(500),    
@sender_agentname VARCHAR(150),@payout_agentname VARCHAR(150),@desc VARCHAR(1000)    

IF @report_type = 'cpl' SET @full_batch_id_name = 'compliance'
IF @report_type = 'ct' SET @full_batch_id_name = 'cancelled transaction'
IF @report_type = 'tt' SET @full_batch_id_name = 'Total Transaction'
IF @report_type = 'ofac' SET @full_batch_id_name = @report_type
 
   
SET @msg_agenttype='Yearly '+ UPPER(@full_batch_id_name) +' Report Generation '     
SET @url_desc='cmbYear='+CAST(@sel_year AS VARCHAR)+'&Report_Type='+CAST(@report_type AS VARCHAR)   
SET @url_desc=@url_desc+'&msg='+@msg_agenttype   

SET @desc =@msg_agenttype +' is completed for the year:' + CAST(@sel_year  AS VARCHAR)     

IF @sel_month is not null    
	BEGIN    
		SET @desc=@desc+ ' Month:'+CAST(@sel_month AS VARCHAR)    
	END 
   
EXEC spa_message_board 'u',@login_user_id, NULL, @batch_id,@desc, 'c', @process_id,null,@url_desc 
 
  
  
  
  
  
  
  