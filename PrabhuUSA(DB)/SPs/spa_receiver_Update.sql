alter PROCEDURE [dbo].[spa_receiver_Update] 
@flag CHAR(1),
@sno VARCHAR(10)= NULL,
@Rsno VARCHAR(10)= NULL,
@ReceiverName VARCHAR(200)=NULL,
@ReceiverAddress VARCHAR(200)=NULL,
@ReceiverCity VARCHAR(150)=NULL,
@ReceiverCountry VARCHAR(100)=NULL,
@ReceiverRelationship VARCHAR(150)=NULL,
@ReceiverPhone VARCHAR(100)=NULL,
@ReceiverMobile VARCHAR(100)=NULL

AS
IF @flag='u'
BEGIN
	 Update customerdetail       
	    set       
	     ReceiverName = @ReceiverName,
	     ReceiverAddress =@ReceiverAddress,
	 ReceiverCity =@ReceiverCity,
	 ReceiverCountry =@ReceiverCountry,
	 relation =@ReceiverRelationship,
	 ReceiverPhone =@ReceiverPhone,
	 ReceiverMobile = @ReceiverMobile
	 WHERE sno = @sno
	 
--	 SELECT @Rsno = sno FROM customerReceiverDetail crd WHERE crd.sender_sno= @sno
--	 PRINT @Rsno
--	 
Update customerReceiverDetail       
	   set       
	ReceiverName = @ReceiverName,
	ReceiverAddress =@ReceiverAddress,
	ReceiverCity =@ReceiverCity,
	ReceiverCountry =@ReceiverCountry,
	relation =@ReceiverRelationship,
	ReceiverPhone =@ReceiverPhone,
	ReceiverMobile =@ReceiverMobile
WHERE  sender_sno= @sno AND sno= @Rsno 
	
	--select 'Success' Status,@CustomerId CustomerID 
END

--IF @flag='d'
--BEGIN
--	
--	DELETE FROM customerDetail
--END