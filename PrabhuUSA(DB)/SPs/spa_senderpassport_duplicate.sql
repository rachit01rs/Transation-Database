/****** Object:  StoredProcedure [dbo].[spa_senderpassport_duplicate]    Script Date: 07/30/2014 13:16:48 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spa_senderpassport_duplicate]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[spa_senderpassport_duplicate]
GO


/****** Object:  StoredProcedure [dbo].[spa_senderpassport_duplicate]    Script Date: 07/30/2014 13:16:48 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


/*
** Database : Prabhu_Usa
** Object : 
** Purpose : ------------- 
**
** Author: Paribesh Jung Karki	
** Date:    07/30/2014
**			
** Execute Examples :
** 	spa_senderpassport_duplicate @flag='s', @senderfax='Bank Account', @senderPassport=NULL
** spa_senderpassport_duplicate @flag='d', @senderfax='Bank Account', @senderPassport=NULL
*/

Create PROCEDURE [dbo].[spa_senderpassport_duplicate]
@flag CHAR(1),
@senderfax VARCHAR(50)=NULL,
@senderPassport VARCHAR(50)=NULL,
@report_id VARCHAR(20)=null
AS	
BEGIN
	SET NOCOUNT ON
	
	IF @flag='s' -- summary report
	
		BEGIN
				SELECT ISNULL(c.senderfax,'') AS [Id type],ISNULL(c.senderpassport,'') AS [Id  number], 
				  dbo.FNADrillReport(COUNT(*) ,@report_id,  
                                       '##senderfax=' + ISNULL(c.senderfax,'-1')
                                       + ';##senderpassport=' + ISNULL(c.senderpassport,'-1')  
                                     ) [duplicate count]
				 FROM dbo.customerDetail c WITH (NOLOCK) 
				GROUP BY senderFax,senderPassport HAVING COUNT(*)>1
		END
	
	
	IF @flag='d' -- duplicate 
	BEGIN
		SELECT CustomerId,SenderName AS [Customer name], senderfax AS [Id type], senderpassport AS [Id number] FROM customerDetail  WITH(NOLOCK) 
		WHERE ISNULL(senderpassport,'-1')=ISNULL(@senderpassport,'-1') AND  ISNULL(senderFax,'-1')=ISNULL(@senderfax,'-1')
	END	
END

	
GO


