DROP proc [dbo].spa_customer_receiver_detail          
Go   
CREATE proc [dbo].[spa_customer_receiver_detail]          
@flag char(1),
@sno int= NULL,     
@customer_sno int=null,   
@ReceiverName VARCHAR(100)=NULL,
@ReceiverAddress VARCHAR(150)=NULL,
@ReceiverCity VARCHAR(100)=NULL,
@ReceiverCountry VARCHAR(100)=NULL,
@ReceiverRelationship VARCHAR(150)=NULL,
@ReceiverIDDescription VARCHAR(100)=NULL,
@receiverID VARCHAR(100)=NULL,
@ReceiverPhone VARCHAR(100)=NULL,
@ReceiverMobile VARCHAR(100)=NULL,
@PartnerBank VARCHAR(50)=NULL,
@PartnerBankBranch VARCHAR(50)=NULL,
@ReceiverAccountNumber VARCHAR(50)=NULL,
@ExtBankName VARCHAR(100)=NULL,
@EXTBankBranchName VARCHAR(50)=NULL,
@loginUser VARCHAR(50)=NULL 
    
AS    
   
if @flag='i'  --insert into customerReceiverdetail       
begin        
    
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
accountno ,
commercial_bank_id ,
commercial_bank_branch_id,
ReceiverID,
ReceiverIDDescription,
create_by,
create_ts

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
 @PartnerBank,
 @ReceiverAccountNumber,
 @ExtBankName,
 @EXTBankBranchName,
 @receiverID,
 @ReceiverIDDescription,@loginUser,GETDATE()
 )
 select 'Success' Status,@customer_sno CustomerID  
  
end        
else if @flag='u'  --update into customerdetail       
begin     
         
Update dbo.customerReceiverDetail       
   set       
	ReceiverName=@ReceiverName,
	ReceiverAddress=@ReceiverAddress,
	ReceiverPhone=@ReceiverPhone,
	ReceiverCity=@ReceiverCity,
	ReceiverCountry=@ReceiverCountry,
	ReceiverMobile=@ReceiverMobile,
	relation=@ReceiverRelationship,
	receivingbank=@PartnerBank,
	accountno=@ReceiverAccountNumber,
	commercial_bank_id=@ExtBankName,
	commercial_bank_branch_id=@EXTBankBranchName
	,update_ts= getDate()
	,update_by=@loginUser
	,ReceiverID=@receiverID
	,ReceiverIDDescription=@ReceiverIDDescription
	where sno=@sno     
   select 'Success' Status,@customer_sno CustomerID  
  
end    


--SELECT * FROM dbo.customerReceiverDetail