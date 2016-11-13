USE [PrabhuUSA]
GO
/****** Object:  StoredProcedure [dbo].[spa_customer_detail_New]    Script Date: 05/16/2013 10:18:18 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
alter proc [dbo].[spa_customer_detail_New]          
@flag char(1),     
@customer_sno VARCHAR(50)=null,   
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
@ReceiverMobile VARCHAR(100)=NULL

    
AS      
    
if @flag='i'  --insert into customerdetail       
begin        
    
 if exists (select sno from customerdetail where CustomerId=@CustomerID or senderName like @SenderName +'%' or senderPassport=@senderPassport or ssn_card_id=@socailsecurity) and @confirm_continue is null  
  begin  
 select top 50 'Error' Status, * from customerdetail where senderName like @SenderName +'%' or senderPassport=@senderPassport or ssn_card_id=@socailsecurity  
  end  
  else  
  begin  
   
  Insert into customerdetail        
     (    
 CustomerId,       
 SenderName,      
 SenderAddress,      
 SenderPhoneno,
 SenderMobile,       
 SenderCity,      
 SenderCountry,        
 senderPassport,       
 SenderEmail,            
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
 SSN_Card_ID, 
img_path,reason_for_remittance,
ReceiverName,ReceiverAddress,ReceiverCity,ReceiverCountry,Relation,ReceiverPhone,ReceiverMobile
 
  
)      
Values         
 (    
 @CustomerId,       
 @SenderName,      
 @SenderAddress,      
 @SenderPhoneno, 
 @SenderMobileno,      
 @SenderCity,      
 @SenderCountry,       
 @senderPassport,       
 @SenderEmail,            
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
@img_path,@txtreason ,
@ReceiverName,
@ReceiverAddress,@ReceiverCity,@ReceiverCountry,@ReceiverRelationship,@ReceiverPhone,@ReceiverMobile 
)  

SELECT @customer_sno= sno FROM customerDetail cd WHERE cd.CustomerId= @CustomerID
Insert into customerReceiverDetail        
(  
	sender_sno, 
ReceiverName,
ReceiverAddress,
ReceiverCity,
ReceiverCountry,
Relation,
ReceiverPhone,
ReceiverMobile
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
 @ReceiverMobile 
 )
     
 select 'Success' Status,@CustomerId CustomerID  
   end   
end        
else if @flag='u'  --update into customerdetail       
begin     
  if exists (select sno from customerdetail   
 where (senderName like @SenderName +'%' or senderPassport=@senderPassport or ssn_card_id=@socailsecurity) and sno<> @customer_sno)   
 and @confirm_continue is null  
  begin  
 select top 50 'Error' Status, * from customerdetail where   
 (senderName like @SenderName +'%' or senderPassport=@senderPassport or ssn_card_id=@socailsecurity)  
 and sno<> @customer_sno   
 return  
  end  
  
       
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
ReceiverName = @ReceiverName,ReceiverAddress =@ReceiverAddress,
ReceiverCity =@ReceiverCity,ReceiverCountry =@ReceiverCountry,
relation =@ReceiverRelationship,ReceiverPhone =@ReceiverPhone,
ReceiverMobile =@ReceiverMobile 
  
     where sno=@customer_sno     
   select 'Success' Status,@CustomerId CustomerID  
  
end    
else if @flag='a'  -- select distinct from customerdetail       
begin    
    
Select * from CustomerDetail where sno=@customer_sno    
end    
else if @flag='d'  --delete from customerdetail    
     
begin     
  if exists(select customer_sno from moneySend where customer_sno=@customer_sno)   
  begin  
   select 'ERROR' Status,dbo.decryptDb(refno)as ref, * from moneySend where customer_sno=@customer_sno  
  return  
  end  
  delete customerdetail where sno=@customer_sno  
    
    
  select 'Success' Status,@customer_sno customer_sno   
    
end    
  
else if @flag='e'  
 begin  
declare @sno_old int, @sno_new int  
  select @sno_old= sno from customerdetail where customerid=@CustomerID  
  select @sno_new= sno from customerdetail where customerid=@SenderName  
  update moneysend set customer_sno=@sno_new where customer_sno=@sno_old  
  update customerReceiverDetail set sender_sno=@sno_new where sender_sno=@sno_old  
  Delete CustomerDetail where sno=@sno_old   
end  
  
if @flag='c' --checks custumer is disabled or not  
begin  
 --if exists(select sno from customerDetail where customerid=@customerID and is_enable='n')  
 select 'This customer is disabled' msg,senderName,senderPassport,senderVisa from customerDetail where customerid=@customerID and is_enable='n'   
end  
  
  
--spa_customer_detail 'c',NULL,'1212'  