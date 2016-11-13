  
CREATE proc [dbo].[spa_SMS_Process]  
@flag char(1),  
@sno int=NULL,  
@server_msg varchar(200)=NULL,  
@status varchar(100)=NULL  
as  
if @flag='s'  
begin  
  
select sno,mobileNo,Message,sender_id,deliveryDate into #temp_sms from sms_pending where status='p'  
update sms_pending set status='a'   
from sms_pending p,#temp_sms t  
where p.sno=t.sno  
  
insert SGServer.ofac_db.dbo.sms_pending(client_id,client_sno,client_mobile,client_text,orginated_date,sender_id)  
select 'cgfinco',sno,mobileNo,Message,deliveryDate,sender_id from #temp_sms  
  
  
  
end  
if @flag='u'  
begin  
   
 insert send_Sms(deliveryDate,MobileNo,Message,Refno,SMSTo,Country,AgentUser,Status,Server_msg)  
 select deliveryDate,MobileNo,Message,Refno,SMSTo,Country,AgentUser,@status,@server_msg from sms_pending  
 where sno=@sno  
  
 delete sms_pending where sno=@sno  
  
end  