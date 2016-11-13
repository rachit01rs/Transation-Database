

/*  
** Database    : PrabhuUSA
** Object      : spa_getReport_header
** Purpose     : Create spa_getReport_header
** Author      : Puja Ghaju 
** Date        : 12 September 2013  
*/ 


IF EXISTS (SELECT * FROM DBO.SYSOBJECTS WHERE ID = OBJECT_ID(N'[DBO].[spa_getReport_header]') AND OBJECTPROPERTY(ID, N'ISPROCEDURE') = 1)
DROP PROCEDURE [DBO].[spa_getReport_header]
  
GO 
     
CREATE PROC [dbo].[spa_getReport_header]    
@report_id INT = NULL,    
@user_id VARCHAR(20) = NULL,    
@branch_id VARCHAR(50) = NULL,  
@flag CHAR(1)=NULL    
AS    
IF @flag='t' --- Total/Sub Total  
BEGIN  
     SELECT c.*   
    FROM   report_writer_clm c  
    WHERE  c.report_id = @report_id AND c.clm_type IN ('Total','SubTotal')  
    ORDER BY  
           clm_sequence  
END  
ELSE  
BEGIN  
   
  
IF @user_id IS NULL  
   AND @report_id IS NULL  
    SELECT report_id,  
           case when main_menu_agent is not null then 'Partner - '  
			else 'Admin -' end + report_name as report_name
    FROM   report_writer_header  
    ORDER BY  
           report_name  
ELSE   
IF @user_id IS NOT NULL  
   AND @report_id IS NULL  
    SELECT h.report_id,  
           h.report_name  
    FROM   report_writer_header h  
           JOIN report_func_user f  
                ON  f.function_id = h.report_id  
    WHERE  f.user_id = @user_id  
    ORDER BY  
           report_name  
ELSE   
IF @user_id IS NULL  
   AND @report_id IS NOT NULL  
    SELECT c.*   
    FROM   report_writer_clm c  
           LEFT OUTER JOIN report_writer_header h  
                ON  h.report_id = c.report_id  
    WHERE  h.report_id = @report_id AND c.clm_type NOT IN ('Total','SubTotal')  
    ORDER BY  
           clm_sequence  
ELSE   
IF @user_id IS NOT NULL  
   AND @report_id IS NOT NULL  
    SELECT c.*   
    FROM   report_writer_clm c  
           LEFT OUTER JOIN report_writer_header h  
                ON  h.report_id = c.report_id  
    WHERE  h.report_id = @report_id AND c.clm_type NOT IN ('Total','SubTotal')  
    ORDER BY  
           clm_sequence    
 END   
    
    
    
    
    
