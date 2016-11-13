IF EXISTS (SELECT * FROM DBO.SYSOBJECTS WHERE ID = OBJECT_ID(N'[DBO].[spa_MPOS_MultiCurrency_exrate]') AND OBJECTPROPERTY(ID, N'ISPROCEDURE') = 1)
DROP PROCEDURE [DBO].[spa_MPOS_MultiCurrency_exrate]
GO
/*  
** Database    : PrabhuUSA  
** Object      : spa_MPOS_MultiCurrency_exrate  
** Purpose     : 
** Author      : Bikash 
** Date        : 24th October 2013  
    
*/
  
CREATE proc [dbo].[spa_MPOS_MultiCurrency_exrate]  
(  
@flag char(5),  
@id int,  
@currency varchar(50) = NULL,  
@ex_rate varchar(50) = NULL,  
@reseller_id varchar(50) = NULL,  
@up_date varchar(50) = NULL,  
@ip_address VARCHAR(100)=NULL  
)  
AS  
SET NOCOUNT ON
IF @flag='i'  
BEGIN  
 If EXISTS(SELECT 'X' FROM MPOS_tblCurrency_convert_rate WITH (NOLOCK) WHERE 
 LOWER(Currency)=LOWER(@currency))  
 BEGIN  
  SELECT '0000' Code,'ERROR' status,'Exchange Rate Already Defined!!! ' msg  
  RETURN  
 END
 INSERT INTO MPOS_tblCurrency_convert_rate(Currency,USD_Rate,CreatedBy,Created_Date)  
 VALUES(@currency,@ex_rate,@reseller_id,dbo.getDateHO(GETUTCDATE())) 
 SELECT '1000' Code,'SUCCESS' status,'New Exchange Rate Inserted!!' msg 
END  
  
IF @flag='u'  
BEGIN  
 --IF EXISTS(SELECT 'X' FROM MPOS_tblCurrency_convert_rate WITH (NOLOCK) WHERE-- LOWER(Currency)=LOWER(@currency) AND
 -- sno<>@id  )  
 --BEGIN  
 -- SELECT '0000' Code,'ERROR' status,'Exchange Rate Already Defined!!! ' msg  
 -- RETURN  
 --END
 UPDATE MPOS_tblCurrency_convert_rate SET USD_Rate=@ex_rate , UpdatedBy=@reseller_id , Updated_Date=dbo.getDateHO(GETUTCDATE())  
 WHERE sno=@id  
 SELECT '1000' Code,'SUCCESS' status,'Exchange Rate Updated Successfully!!' msg
END  
  
IF @flag='d'  
BEGIN  
 If NOT EXISTS(SELECT 'X' FROM MPOS_tblCurrency_convert_rate WITH (NOLOCK) WHERE sno=@id )  
 BEGIN  
  SELECT '0000' Code,'ERROR' status,'Exchange Rate Does not exists!!! ' msg  
  RETURN  
 END
 DELETE MPOS_tblCurrency_convert_rate WHERE sno=@id
  SELECT '1000' Code,'SUCCESS' status,'Exchange Rate Successfully Deleted!!' msg  
END  