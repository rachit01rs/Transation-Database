Drop proc [dbo].[spaRemote_update_transaction_status]      
go
Create proc [dbo].[spaRemote_update_transaction_status]      
as      
if exists(select sno from tbl_status_moneysend where status='Approved')      
begin      
update moneysend set transStatus=case when m.compliance_flag='y' then 'Compliance'    
when m.ofac_list='y' then 'OFAC' else 'Payment' END from moneysend m join [Staging_process_2].[dbo].[moneySend_OUT] t on 
m.refno=t.refno where t.Remote_status='Completed'
delete [Staging_process_2].[dbo].[moneySend_OUT] from moneysend m join [Staging_process_2].[dbo].[moneySend_OUT] t on m.refno=t.refno where t.Remote_status='Completed'  
and m.transstatus in ('Payment','Compliance','OFAC')     
end 

