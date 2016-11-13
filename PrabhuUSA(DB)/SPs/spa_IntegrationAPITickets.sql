DROP PROC spa_IntegrationAPITickets
Go
CREATE PROC spa_IntegrationAPITickets  
@Refno VARCHAR(50),  
@comments VARCHAR(150),  
@postedBy VARCHAR(50)  
AS  
  
DECLARE @tranno INT  
SELECT @tranno=tranno FROM moneySend ms WHERE ms.refno=@Refno  
IF @tranno IS NOT NULL   
BEGIN  
 INSERT INTO TransactionNotes  
 (  
  RefNo,  
  Comments,  
  DatePosted,  
  PostedBy,  
  uploadBy,  
  noteType,  
  tranno  
 )  
 VALUES  
 (  
  @Refno,@comments,GETDATE(),@postedBy,'A',1,@tranno  
 )  
 SELECT @tranno tranno,'Success' StatusMsg,'Sucessfully inserted ticket in remote server' [Message]
END  
ELSE
 SELECT @tranno tranno,'Error' StatusMsg,'Unable to find '+dbo.decryptDb(@refno)+'in remote machine' [Message]