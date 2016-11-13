 create FUNCTION [dbo].[FNAGetConvertRate]  
(  
 @sellingAmt money,  
 @Amount money ,  
 @servicecharge money  
)  
RETURNS money AS  
BEGIN  
   
 DECLARE @SellingAmt_without_charge MONEY, @convertrate MONEY  
 SET @SellingAmt_without_charge = @sellingAmt - @servicecharge  
   
 SET @convertrate = @Amount / @SellingAmt_without_charge  
   
 RETURN @convertrate  
END