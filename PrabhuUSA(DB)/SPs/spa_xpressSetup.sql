/****** Object:  StoredProcedure [dbo].[spa_xpressSetup]    Script Date: 10/31/2014 13:26:57 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spa_xpressSetup]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[spa_xpressSetup]
GO

/****** Object:  StoredProcedure [dbo].[spa_xpressSetup]    Script Date: 10/31/2014 13:26:57 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



--spa_xpressSetup s,NULL,'y'
CREATE PROC [dbo].[spa_xpressSetup]
@flag char(1),
@sno int=null,
@enable_send char(1)=null,
@ex_rate_margin float=null,
@sCharge_margin float=null,
@XM_comm float=null,
@XM_comm_type varchar(2)=null,
@update_by varchar(50)=null

AS
--select all records
if @flag='s'
BEGIN
	declare @sql varchar(500),@slab_enable char(1)
	
	set @sql='select distinct c.*,s.rec_country from xpressMoney_country c left outer join 
	xm_service_charge_setup s on c.country=s.rec_country'
	if @enable_send ='y'
	set @sql=@sql+' where enable_send='''+@enable_send+''''
	if @enable_send is null
	set @sql=@sql+' where enable_send is null'
	
	set @sql=@sql+' order by country asc'
--print @sql
--return
exec(@sql)
END
---update 
if @flag='u'
BEGIN
	UPDATE xpressMoney_country
	set enable_send=@enable_send,
		ex_rate_margin=@ex_rate_margin,
		sCharge_margin=@sCharge_margin,
		XM_comm=@XM_comm,
		XM_comm_type=@XM_comm_type,
		update_by=@update_by,
		update_ts=getdate()
	where sno=@sno
	
END
if @flag='l' --- log view
select top 100 * from xpressmoney_country_audit where sno=@sno order by country_id desc



GO


