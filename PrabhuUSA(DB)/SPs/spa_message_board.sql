IF EXISTS (SELECT * FROM DBO.SYSOBJECTS WHERE ID = OBJECT_ID(N'[DBO].[spa_message_board]') AND OBJECTPROPERTY(ID, N'ISPROCEDURE') = 1)
DROP PROCEDURE [DBO].[spa_message_board]
GO
/*  
** Database    : PrabhuUSA  
** Object      : spa_message_board  
** Purpose     : Insert,update,delete data from message_board table
** Author      :  
** Date        : 
** Modifications  :   
** Modified by : Bikash Giri
** Date        : 6th september 2013

Flag
      c = To delete files that are greater than 7 days old.
      
*/

--spa_message_board	   @flag='s'


CREATE PROC [dbo].[spa_message_board] 
  @flag char, 
  @user_login_id as varchar(50)=null,  
  @message_id int = null, 
  @source varchar(50) = null,  
  @description varchar(8000) = null,  
  @type varchar(1) = null,   
  @job_name varchar(100) = null,  
  @as_of_date datetime = null,  
  @url_desc varchar(1000)=null,  
  @agent_id varchar(50)=null,  
  @branch_id varchar(50)=null,  
  @run_by char(1)=null,
  @agent_filter char(1)=null,      
  @branch_rights_reg varchar(50)=NULL    
AS  
If @flag = 'i'  
BEGIN  
 INSERT INTO message_board(user_login_id, source, [description],  
   type, job_name, as_of_date,AGENT_ID,BRANCH_ID,run_by)  
  VALUES(@user_login_id, @source, @description, @type, @job_name, dbo.getDateHO(getutcdate()),  
  @agent_id,@BRANCH_ID,@run_by)  
     
 Return  
END  
IF @flag = 'd'   
BEGIN  
 delete from message_board where message_id = @message_id  
END  
IF @flag = 'u'   
BEGIN  
  
 update message_board   
 set type=@type,  
 description=@description,  
 url_desc=@url_desc  
 where job_name = @job_name and user_login_id=@user_login_id  
END  
IF @flag = 's'   
BEGIN  
  
 DECLARE @sql varchar(1000)  
 SET @sql='  
 select top 20 * from message_board where source ='''+ @source +''''  
 IF @agent_id IS NOT NULL  
  SET @sql=@sql + ' and agent_id='''+@agent_id +''''  
 IF @branch_id IS NOT NULL  
  BEGIN      
	if exists(select regional_id from agent_regional_branch where agent_branch_code=@branch_id) and @branch_rights_reg='true'      
		SET @sql=@sql + ' and branch_id in (select reg_branch_id from agent_regional_branch where agent_branch_code='''+@branch_id+''' )'      
	else      
		SET @sql=@sql + ' and branch_id='''+@branch_id +''''      
  END      
 IF @agent_filter='a' 
  SET @sql=@sql + ' and branch_id is NULL' 
 IF @agent_filter='b' 
  SET @sql=@sql + ' and branch_id is NOT NULL'
 IF @run_by IS NOT NULL  
  SET @sql=@sql + ' and run_by='''+@run_by +''''  
 ELSE  
  SET @sql=@sql + ' and (run_by is null or run_by=''h'')'  
   IF @user_login_id IS NOT NULL  
  SET @sql=@sql + ' and user_login_id='''+@user_login_id +''''  
SET @sql=@sql+'  
  order by message_id desc '
print @sql
--return
 exec(@sql)  
END  


-----To delete files that are greater than 7days old-----------
IF @flag = 'c'
BEGIN    

SELECT mb.message_id,(source+'_'+job_name) AS FILENAME INTO #tmp_table
	  FROM message_board mb WHERE source=@source AND DATEDIFF(day,as_of_Date,GETDATE())> 7
	  --AND job_name='4B3AFDBF_86A8_4AB8_9926_EBB31346C8A3'

DELETE m FROM message_board AS m  
JOIN #tmp_table tt ON m.message_id=tt.message_id   
	  
Select * FROM #tmp_table
--DROP TABLE #tmp_table



END