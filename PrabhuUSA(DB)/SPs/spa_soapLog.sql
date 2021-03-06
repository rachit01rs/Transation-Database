
/****** Object:  StoredProcedure [dbo].[spa_soapLog]    Script Date: 12/12/2011 18:37:04 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[spa_soapLog]      
 @flag VARCHAR(1),      
 @sno INT=NULL,      
 @partnerId VARCHAR(50)=NULL,        
 @tranId VARCHAR(50)=NULL,        
 @partnerTranId VARCHAR(50)=NULL,        
 @reqxml VARCHAR(max)=NULL,        
 @resxml VARCHAR(max)=NULL,        
 @userId VARCHAR(50)=NULL,  
 @funcName VARCHAR(50)=NULL         
          
AS       
DECLARE @log_sno VARCHAR(50)      
IF @flag='i'       
BEGIN        
INSERT INTO soap_log(        
  partnerId        
    ,[tranId]        
    ,[partnerTranId]        
    ,[reqxml]        
    ,[resxml]        
    ,createTs        
    ,[userId]  
 ,[functionName]  
    )        
   VALUES(         
  @partnerId        
    ,@tranId        
    ,@partnerTranId        
    ,@reqxml        
    ,@resxml        
    ,GETDATE()        
    ,@userId  
    ,@funcName       
    )        
    set @log_sno=@@identity        
select @log_sno AS sno      
END       
ELSE      
BEGIN        
 UPDATE soap_log SET resxml=@resxml WHERE sno=@sno      
END