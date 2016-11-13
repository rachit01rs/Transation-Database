DROP proc [dbo].[spa_copy_service_charge]
GO


--spa_copy_service_charge 's',NULL,'32400151','p',NULL,'-1'
--spa_copy_service_charge 'c','32400119','32400119','c','Bangladesh',NULL,'Nepal',NULL,'deepen'
--spa_copy_service_charge 's','10100000'
CREATE proc [dbo].[spa_copy_service_charge]
		@flag char(1),
		@copyfrom varchar(50)=NULL,
		@agent_id varchar(50)=NULL,
		@servicetype char(1)=NULL,
		@Rec_Country varchar(50)=NULL,
		@payout_agent_id varchar(50)=NULL,
		@copy2Rec_Country varchar(50)=NULL,
		@copy2payout_agent_id varchar(50)=NULL,
		@update_by varchar(50)=NULL


as
declare @sql varchar(8000),@sql_del varchar(5000)
if @flag='s'
begin
if @servicetype='c'
set @sql='SELECT distinct a.companyname agent_name,[Rec_Country],agent_id
	FROM [dbo].[service_charge_setup] s JOIN agentdetail a ON a. agentcode=s.agent_id
	where [agent_id]='''+@agent_id+''' and [Rec_Country] is not null '
if @servicetype='p'
set @sql='SELECT distinct a.companyname agent_name,pa.companyName Payout_agent,[payout_agent_id],agent_id
  FROM [dbo].[service_charge_setup] s JOIN agentdetail a ON a. agentcode=s.agent_id
 JOIN agentdetail pa ON pa.agentcode=s.[payout_agent_id] 
	where [agent_id]='''+@agent_id+''' and payout_agent_id is not null '
if @Rec_Country is not null
set @sql=@sql+' and Rec_Country='''+@Rec_Country+''''
if @payout_agent_id is not null
set @sql=@sql+' and payout_agent_id='''+@payout_agent_id+''''
exec(@sql)
end
if @flag='c'
begin

set @sql_del='delete service_charge_setup where [agent_id]='''+@agent_id+''''
if @servicetype='c'
set @sql_del=@sql_del+' and [Rec_Country] is not null '
if @servicetype='p'
set @sql_del=@sql_del+' and payout_agent_id is not null '
if @Rec_Country is not null and @copy2Rec_Country is NULL
set @sql_del=@sql_del+' and Rec_Country='''+@Rec_Country+''''
if @copy2Rec_Country is not null
set @sql_del=@sql_del+' and Rec_Country='''+@copy2Rec_Country+''''

if @payout_agent_id is not null and @copy2payout_agent_id is NULL
set @sql_del=@sql_del+' and payout_agent_id='''+@payout_agent_id+''''
if @copy2payout_agent_id is not null
set @sql_del=@sql_del+' and payout_agent_id='''+@copy2payout_agent_id+''''

exec (@sql_del)

set @sql='insert into service_charge_setup
	([payment_type],[agent_id],[Rec_Country],[payout_agent_id],[min_amount],[max_amount],[service_charge_mode]
    ,[service_charge_flat],[service_charge_per],[paid_commission],[paid_commission_type],[send_commission]
    ,[send_commission_type],[update_by],[update_ts])
	select [payment_type]'
if @agent_id is not null
set @sql=@sql+','''+@agent_id+''''
else
set @sql=@sql+',[agent_id]'
if @copy2Rec_Country is not null
set @sql=@sql+','''+@copy2Rec_Country+''''
else
set @sql=@sql+',[Rec_Country]'
if @copy2payout_agent_id is not null
set @sql=@sql+','''+@copy2payout_agent_id+''''
else
set @sql=@sql+',[payout_agent_id]'
set @sql=@sql+',[min_amount],[max_amount],[service_charge_mode]
    ,[service_charge_flat],[service_charge_per],[paid_commission],[paid_commission_type],[send_commission]
    ,[send_commission_type],'''+@update_by+''',getdate() from service_charge_setup
	where [agent_id]='''+@copyfrom +''''

if @servicetype='c'
set @sql=@sql+' and [Rec_Country] is not null '
if @servicetype='p'
set @sql=@sql+' and payout_agent_id is not null '
if @Rec_Country is not null
set @sql=@sql+' and Rec_Country='''+@Rec_Country+''''
if @payout_agent_id is not null
set @sql=@sql+' and payout_agent_id='''+@payout_agent_id+''''

exec (@sql)
end

GO


