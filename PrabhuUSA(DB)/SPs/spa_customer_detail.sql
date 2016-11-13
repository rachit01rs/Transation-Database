IF EXISTS (SELECT * FROM DBO.SYSOBJECTS WHERE ID = OBJECT_ID(N'[DBO].[spa_customer_detail]') AND OBJECTPROPERTY(ID, N'ISPROCEDURE') = 1)
DROP PROCEDURE [DBO].[spa_customer_detail]
  
GO 
/*  
** Database      : PrabhuUSA
** Object        : spa_customer_detail
** Purpose       : Create spa_customer_detail
** Modified by   : Puja Ghaju 
** Modified Date : 22 September 2013 
** Purpose       : Added @SenderZipCode
*/ 

CREATE proc [dbo].[spa_customer_detail]            
@flag char(1),       
@customer_sno int=null,     
@CustomerID varchar(50)=NULL,         
@SenderName varchar(100)=NULL,         
@SenderAddress varchar(150)=NULL,         
@SenderPhoneno varchar(30)=NULL,    
@SenderMobileno varchar(30)=NULL,          
@SenderCity  varchar(100)=NULL,          
@SenderCountry  varchar(30)=NULL,          
@senderPassport  varchar(50)=NULL,    
@senderState varchar(50)=NULL,    
@senderpassportType varchar(50)=NULL,         
@SenderEmail varchar(50)=NULL,        
@SenderVisa varchar(50)=NULL,    
@idIssueDate varchar(50)=NULL,     
@Date_Of_Birth varchar(50)=NULL,    
@socailsecurity varchar(50)=NULL,       
@create_ts datetime=NULL ,        
@update_ts datetime=NULL ,        
@senderFax  varchar(30)=NULL,        
@SenderCompany  varchar(30)=NULL,        
@Salary_Earn  varchar(30)=NULL,        
@SenderNativeCountry varchar(30)=NULL,        
@mileage_earn money=NULL,        
@trn_date datetime=NULL ,        
@trn_amt money=NULL,        
@confirm_continue char(1)=NULL,      
@reg_agent_id varchar(300)=NULL,    
@t_customerID varchar(50)=NULL,    
@img_path varchar(50)=NULL,    
@txtreason varchar(100)=NULL,  
@ReceiverName VARCHAR(100)=NULL,  
@ReceiverAddress VARCHAR(150)=NULL,  
@ReceiverCity VARCHAR(100)=NULL,  
@ReceiverCountry VARCHAR(100)=NULL,  
@ReceiverRelationship VARCHAR(150)=NULL,  
@ReceiverPhone VARCHAR(100)=NULL,  
@ReceiverMobile VARCHAR(100)=NULL,  
@freeSMS CHAR(1)=NULL,  
@ReceiverBankID INT=NULL,  
@ReceiverBankBranchID INT=NULL,  
@ReceiverAccountNumber VARCHAR(50)=NULL,  
@OtherBankName VARCHAR(100)=NULL,  
@OtherBankBranchName VARCHAR(50)=NULL ,
@SenderZipCode VARCHAR(50)=NULL,
@PictureIdType VARCHAR(50)=NULL ,
@Remark VARCHAR(1000)=NULL
      
AS        
      
if @flag='i'  --insert into customerdetail         
begin          
      
	 IF EXISTS ( SELECT sno
				 FROM   customerdetail WITH ( NOLOCK )
				 WHERE  CustomerId = @CustomerID
						OR senderName LIKE @SenderName + '%'
						OR senderPassport = @senderPassport
						OR ssn_card_id = @socailsecurity )
		AND @confirm_continue IS NULL 
		BEGIN    
			SELECT TOP 50
					'Error' Status ,
					*
			FROM    customerdetail WITH ( NOLOCK )
			WHERE   senderName LIKE @SenderName + '%'
					OR senderPassport = @senderPassport
					OR ssn_card_id = @socailsecurity    
		END  
	  -- checking duplicate entry              
	 ELSE 
		IF EXISTS ( SELECT  'x'
					FROM    customerDetail WITH ( NOLOCK )
					WHERE   senderpassport = @senderpassport
							AND senderFax = @senderpassportType
							AND CASE WHEN @senderpassportType = 'passport'
									 THEN SenderNativeCountry
									 ELSE SenderCountry
								END = CASE WHEN @senderpassportType = 'passport'
										   THEN @SenderNativeCountry
										   ELSE @SenderCountry
									  END ) 
			BEGIN              
	                
				SELECT  'ERROR' ,
						'1001' ,
						'duplicate ID Type and ID value!!!'              
				RETURN              
			END              
  else    
  begin    
     
  Insert into customerdetail          
     (      
 CustomerId,         
 SenderName,        
 SenderAddress,        
 SenderPhoneno,         
 SenderCity,        
 SenderCountry,          
 senderPassport,         
 SenderEmail,        
 SenderMobile,        
 senderVisa,    
 ID_Issue_date,         
 create_ts,        
 update_ts,        
 SenderFax,    
 Sender_Fax_No,        
 SenderCompany,        
 Salary_Earn,        
 SenderNativeCountry,    
 sender_State,    
 Date_Of_Birth,    
 SSN_Card_ID    
,img_path,reason_for_remittance,  ReceiverName,ReceiverAddress,ReceiverCity,ReceiverCountry,Relation,ReceiverPhone,ReceiverMobile,FreeSMS,picture_id_type,Remark  
    
)        
Values           
 (      
 @CustomerId,         
 @SenderName,        
 @SenderAddress,        
 @SenderPhoneno,         
 @SenderCity,        
 @SenderCountry,         
 @senderPassport,         
 @SenderEmail,        
 @SenderMobileno,        
 @senderVisa,       
 @idIssueDate,      
 dbo.getDateHO(getutcdate()),        
 @update_ts,        
 @senderpassportType,    
 @senderFax,        
 @SenderCompany,        
 @Salary_Earn,        
 @SenderNativeCountry,    
 @senderState,    
 @Date_Of_Birth,    
 @socailsecurity,  
 @img_path,@txtreason,   
@ReceiverName,  
@ReceiverAddress,@ReceiverCity,@ReceiverCountry,@ReceiverRelationship,@ReceiverPhone,@ReceiverMobile,@freeSMS,@PictureIdType,@Remark    
)        
SELECT @customer_sno= sno FROM customerDetail cd WITH(NOLOCK) WHERE cd.CustomerId= @CustomerID  
DECLARE @bankname VARCHAR(50),@branchName varchar(50)  
IF @ReceiverBankID IS NOT NULL   
 SELECT @bankname=Bank_name FROM dbo.commercial_bank WITH(NOLOCK) WHERE Commercial_id=@ReceiverBankID  
ELSE  
 SET @bankname=NULL  
IF @ReceiverBankBranchID IS NOT NULL  
 SELECT @branchName=BranchName FROM dbo.commercial_bank_branch WITH(NOLOCK) WHERE Commercial_id=@ReceiverBankBranchID  
ELSE  
 SET @branchName=NULL  
Insert into customerReceiverDetail          
(    
 sender_sno,   
ReceiverName,  
ReceiverAddress,  
ReceiverCity,  
ReceiverCountry,  
Relation,  
ReceiverPhone,  
ReceiverMobile,  
receivingbank ,  
bank_name ,  
branch_name ,  
accountno ,  
bankbranch ,  
commercial_bank_id ,  
commercial_bank_branch_id  
  
)        
Values           
 (   
 @customer_sno,  
  @ReceiverName,     
 @ReceiverAddress,  
 @ReceiverCity,  
 @ReceiverCountry,  
 @ReceiverRelationship,  
 @ReceiverPhone,  
 @ReceiverMobile,  
 @bankname,  
 @OtherBankName,  
 @branchName,  
 @ReceiverAccountNumber,  
 @OtherBankBranchName,  
 @ReceiverBankID,  
 @ReceiverBankBranchID  
 )  
 select 'Success' Status,@CustomerId CustomerID    
   end     
end          
else if @flag='u'  --update into customerdetail         
BEGIN
 DECLARE  @senderpassport_old VARCHAR(50), @txtsPassport_type_old  VARCHAR(50)          
  if exists (select sno from customerdetail WITH(NOLOCK)    
 where (senderName like @SenderName +'%' or senderPassport=@senderPassport or ssn_card_id=@socailsecurity) and sno<> @customer_sno)     
 and @confirm_continue is null    
  begin    
 select top 50 'Error' Status, * from customerdetail WITH(NOLOCK) where     
 (senderName like @SenderName +'%' or senderPassport=@senderPassport or ssn_card_id=@socailsecurity)    
 and sno<> @customer_sno     
 return    
  end    
      
  select @senderpassport_old=senderPassport,@txtsPassport_type_old=senderFax
    from customerdetail WITH(NOLOCK) where customerid=@customerid   
    IF     @senderpassport_old <>@senderpassport OR  @txtsPassport_type_old<>@senderpassportType 
    BEGIN
    	if exists (SELECT 'x' FROM customerDetail  WITH(NOLOCK) 
    	WHERE senderpassport=@senderpassport AND senderFax=@senderpassportType
    	AND CASE WHEN @senderpassportType = 'passport'
		THEN SenderNativeCountry
		ELSE SenderCountry
		END = CASE WHEN @senderpassportType = 'passport'
		THEN @SenderNativeCountry
		ELSE @SenderCountry
		END)              
		 begin              
		                
			 select 'ERROR','1001','duplicate ID Type and ID value!!!'              
		  return              
		end  
    END   
         
Update customerdetail         
   set         
    CustomerId=@CustomerId        
    ,SenderName=@SenderName      
    ,SenderAddress=@SenderAddress        
    ,SenderPhoneno=@SenderPhoneno           
    ,SenderCity=@SenderCity      
    ,SenderCountry=@SenderCountry       
    ,senderPassport=@senderPassport                 
    ,SenderEmail=@SenderEmail      
    ,SenderMobile=@SenderMobileno          
 ,senderVisa=@senderVisa      
    ,update_ts=dbo.getDateHO(getutcdate())          
    ,SenderFax=@senderpassportType      
 ,Sender_Fax_No=@SenderFax    
    ,SenderCompany=@SenderCompany      
 ,Date_Of_Birth=@Date_Of_Birth    
    ,Salary_Earn=@Salary_Earn        
 ,SenderNativeCountry=@SenderNativeCountry    
 ,sender_State=@senderState    
 ,SSN_Card_ID=@socailsecurity    
,img_path=CASE WHEN @img_path IS NULL THEN img_path ELSE @img_path END,  
reason_for_remittance=@txtreason,  
ReceiverName = CASE WHEN @ReceiverName IS NULL THEN ReceiverName ELSE @ReceiverName END,  
ReceiverAddress =CASE WHEN @ReceiverAddress IS NULL THEN ReceiverAddress ELSE @ReceiverAddress END,  
ReceiverCity =CASE WHEN @ReceiverCity IS NULL THEN ReceiverCity ELSE @ReceiverCity END,  
ReceiverCountry =CASE WHEN @ReceiverCountry IS NULL THEN ReceiverCountry ELSE @ReceiverCountry END,  
relation =CASE WHEN @ReceiverRelationship IS NULL THEN relation ELSE @ReceiverRelationship END,  
ReceiverPhone =CASE WHEN @ReceiverPhone IS NULL THEN ReceiverPhone ELSE @ReceiverPhone END,  
ReceiverMobile =CASE WHEN @ReceiverMobile IS NULL THEN ReceiverMobile ELSE @ReceiverMobile END,FreeSMS = @freeSMS ,
picture_id_type=@PictureIdType ,Remark=@Remark
where sno=@customer_sno       
   select 'Success' Status,@CustomerId CustomerID    
    
end      
else if @flag='a'  -- select distinct from customerdetail         
begin      
      
Select * from CustomerDetail WITH(NOLOCK) where sno=@customer_sno      
end      
else if @flag='d'  --delete from customerdetail      
       
begin       
  if exists(select customer_sno from moneySend WITH(NOLOCK) where customer_sno=@customer_sno)     
  begin    
   select 'ERROR' Status,dbo.decryptDb(refno)as ref, * from moneySend WITH(NOLOCK) where customer_sno=@customer_sno    
  return    
  end    
  delete customerdetail where sno=@customer_sno    
      
      
  select 'Success' Status,@customer_sno customer_sno     
      
end      
    
else if @flag='e'    
 begin    
declare @sno_old int, @sno_new int    
  select @sno_old= sno from customerdetail WITH(NOLOCK) where customerid=@CustomerID    
  select @sno_new= sno from customerdetail WITH(NOLOCK) where customerid=@SenderName    
  update moneysend set customer_sno=@sno_new where customer_sno=@sno_old    
  update customerReceiverDetail set sender_sno=@sno_new where sender_sno=@sno_old    
  Delete CustomerDetail where sno=@sno_old     
end    
    
if @flag='c' --checks custumer is disabled or not    
begin    
 --if exists(select sno from customerDetail where customerid=@customerID and is_enable='n')    
 select 'This customer is disabled' msg,senderName,senderPassport,senderVisa from customerDetail WITH(NOLOCK) where customerid=@customerID and is_enable='n'     
end    
    
    
--spa_customer_detail 'c',NULL,'1212' 