DROP PROC [spa_feedback_txn]
go 
/*
** Database : PRABHUUSA
** Object : spa_feedback_txn
**
** Purpose : TO RETRIVE THE FEEDBACK REPORT WHERE TXN WAS AUTOMATICALLY PAID OR SKIPPED.
**
** Author:  RANESH RATNA SHAKYA
** Date:    21/09/2012
**
** Modifications:
** 
** 
**			
** Execute Examples :
** spa_feedback_txn 's','20100201','success','2012-9-01','2012-9-24'
** spa_feedback_txn 'a'   // THIS ONLY SELECT THE DISTINCT PAYOUT AGENT FOR LISTING IN THE COMBO BOX.
** SELECT * FROM dbo.tbl_Feedback_Txn
  
*/

CREATE PROC [spa_feedback_txn]
    @flag CHAR(2) ,
    @payoutagentid VARCHAR(50) = NULL ,
    @status VARCHAR(20) = NULL ,
    @fromdate VARCHAR(50) = NULL ,
    @todate VARCHAR(50) = NULL
AS 
	SET NOCOUNT ON 
    DECLARE @sql VARCHAR(MAX)
	if @todate is not null
		set @todate=@todate +' 23:59:59:998'
    IF @flag = 's' 
        BEGIN
            SET @sql = '
            SELECT  *
            FROM    dbo.tbl_Feedback_Txn WITH ( NOLOCK )
            WHERE   PayoutAgent = ''' + @payoutagentid + '''
					AND IMPORTED_DATE BETWEEN '''+@fromdate+'''
                                                     AND     '''+@todate+'''
            '
            IF @status IS NOT NULL 
                IF @status <> 'success' 
                    SET @sql = @sql + ' AND SYSTEM_STATUS <> ''success'''					  
                ELSE 
                    SET @sql = @sql + ' AND SYSTEM_STATUS=''' + @status + ''''
            SET @sql = @sql + ' ORDER BY IMPORTED_DATE'
			--print @sql
            EXEC (@sql)
                    
        END 


    IF @flag = 'a' 
        BEGIN
            SELECT DISTINCT
                    a.agentCode,
                    a.CompanyName AgentName 
            FROM    dbo.agentdetail a WITH ( NOLOCK )
                    INNER JOIN dbo.tbl_Feedback_Txn t WITH ( NOLOCK ) ON a.agentCode = t.PayoutAgent
        END