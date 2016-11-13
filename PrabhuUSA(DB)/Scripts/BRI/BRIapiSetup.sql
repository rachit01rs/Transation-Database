insert into static_values(sno,static_value,static_data,description,additional_value)
select '500','20100090','20100013','BRI','BRI'
GO
insert into tbl_integrated_agents(agentcode,agentname,paymenttype,approved_url,isenable,partnercode,api_url_wsdl)
select '20100013','BRI','Default','API_BRI/hold_trn/approvedConfirm.asp','y','BRI',NULL
GO

declare @sno int 
select top 1 @sno=sno from application_function order by sno desc
insert into application_function(sno,function_name,link_file,main_menu)
select @sno+1,'Hold Txn','API_BRI/hold_trn/approvedConfirm.asp','BRI'
GO
insert into static_values(sno,static_value,static_data,Description,additional_value)
select '101','BRI','BRI','Admin','BRI_logo.jpg'
GO
declare @sno int 
select top 1 @sno=sno from application_function order by sno desc
insert into application_function(sno,function_name,link_file,main_menu)
select @sno+1,'Check Balance','API_BRI/CheckBalance/checkBalance.asp','BRI'