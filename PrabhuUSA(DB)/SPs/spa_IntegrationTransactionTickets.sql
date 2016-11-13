IF OBJECT_ID('spa_IntegrationTransactionTickets','P') IS NOT NULL 
 DROP PROC [dbo].[spa_IntegrationTransactionTickets]  
GO  
--spa_IntegrationTransactionTickets  '193118739928','x'  
CREATE PROC [dbo].[spa_IntegrationTransactionTickets]  
@refno VARCHAR(50),  
@flag CHAR(1) = 's'  
AS  
IF @flag = 's'  
    SELECT *  
    FROM   TransactionNotes tn  
    WHERE  refno = dbo.encryptDb(@refno)  
   and noteType>0  
    ORDER BY  
           sno DESC  
ELSE   
IF @flag = 'x'  
BEGIN  
    SELECT (  
               SELECT   
                      'TransactionNotes' AS '@Table',  
                      'E' AS '@ChangeType',  
                      t.Refno AS 'Column/Refno',  
                      t.Comments AS 'Column/Comments',  
                     t.DatePosted AS 'Column/DatePosted',                        
                      postedBy AS 'Column/postedBy',  
                      t.uploadBY AS 'Column/uploadBY'  
                        
               FROM   TransactionNotes t  
               WHERE t.RefNo=dbo.encryptDb(@refno)  
    and noteType>0  
                      ORDER BY t.sno   
                      FOR XML PATH('DataRow'),  
                      TYPE  
           )  
           FOR XML PATH('Root')  
END  