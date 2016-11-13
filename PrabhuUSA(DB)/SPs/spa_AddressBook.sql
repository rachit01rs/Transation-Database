DROP proc spa_AddressBook  
go
--spa_AddressBook @flag='i',@category_id=47,@Agent_ID='20100206',@Country='Bangladesh'  
CREATE proc spa_AddressBook  
@flag char(1),  
@category_id int,  
@Agent_ID varchar(50),  
@Country varchar(50)  
as  
select distinct SenderName,  
case when len(Sender_MObile)=10 then '1'+Sender_MObile else Sender_MObile End Mobile,  
SEnderEmail into #temp from moneysend WITH(NOLOCK)   
where agentid=@Agent_ID   
and receiverCOuntry=@Country  AND  sender_mobile is NOT null
  
delete #temp   
from #temp t join address_book a WITH(NOLOCK) 
on t.Mobile=a.mobile_no  
where a.category_type=@category_id  
declare @row varchar(50)  
  
insert address_book(address_name,mobile_no,email_id,agent_id,category_type)  
select distinct SenderName,Mobile,SEnderEmail,1,@category_id from #temp  
WHERE Mobile IS NOT NULL  
set @row=@@rowcount  
select 'Success' Status,'Total Row Import '+ @row Message