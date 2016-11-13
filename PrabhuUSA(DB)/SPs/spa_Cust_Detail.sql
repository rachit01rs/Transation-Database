drop proc [dbo].[spa_Cust_Detail] 
go
--spa_Cust_Detail '10000005','11000001','101',NULL    
    
CREATE proc [dbo].[spa_Cust_Detail]    
@agentid varchar(50)=NUll,    
@branch_code varchar(50)=NULL,    
@ReceiverID varchar(50)=Null,    
@passport_no varchar(50)=NULL,  
@tranx_type CHAR(1)=NULL,  
@customer_id varchar(50)=NULL  
    
as    
declare @sql varchar(5000)    
begin    
set @sql='select min(confirmdate) fromdate,max(confirmdate) todate,isNull(datename(m,confirmdate)+'' ''+cast(datepart(yyyy,confirmdate) as varchar),''Un-Confirmed TXNS'') my,    
count(tranno) totaltrn,max(customerID) customer_id,max(paidCType) paidCType,max(senderpassport) senderpassport,    
sum(paidamt) totalamt, ReceiverName receiver, ReceiverID receiverid FROM moneysend with(nolock) where Transstatus not in(''Cancel'') '    
if @agentid is not null    
BEGIN  
  if @tranx_type='i'   
   set @sql=@sql +' and expected_payoutagentid='''+@agentid+''''    
  ELSE  
   set @sql=@sql +' and agentid='''+@agentid+''''    
 END   
if @branch_code is not null     
BEGIN  
  if @tranx_type='i'   
  set @sql=@sql +' and rBankID='''+@branch_code+''''  
  ELSE  
  set @sql=@sql +' and branch_code='''+@branch_code+''''    
 END    
if @passport_no is not null    
set @sql=@sql +' and senderpassport='''+@passport_no +''''    
if @ReceiverID is not null    
set @sql=@sql +' and paid_beneficiary_ID_number='''+@ReceiverID+''''    
if @customer_id is not null    
set @sql=@sql +' and CustomerId='''+@customer_id+''''    
SET @sql=@sql+'      
  group by datename(m,confirmdate),datepart(yyyy,confirmdate),ReceiverName,ReceiverID '    
print(@sql)    
exec(@sql)    
    
end 