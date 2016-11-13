
GO

/****** Object:  StoredProcedure [dbo].[spa_PartnerCheck_for_Cancel]    Script Date: 04/11/2012 16:21:36 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spa_PartnerCheck_for_Cancel]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[spa_PartnerCheck_for_Cancel]
GO

GO

/****** Object:  StoredProcedure [dbo].[spa_PartnerCheck_for_Cancel]    Script Date: 04/11/2012 16:21:36 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

--spa_PartnerCheck_for_pay 'FFFEFGGJMEEF'
CREATE proc [dbo].[spa_PartnerCheck_for_Cancel]
 @refno varchar(50)    
as    
begin     
    
 DECLARE @remote_db varchar(200),@sql varchar(5000)    
 DECLARE @sagentid varchar(50),@enable_update_remoteDB char(1),    
 @PartnerAgentCode varchar(50),@encRefno varchar(50),@PartnerAgent varchar(50)    
     
select @encRefno=refno,@sagentid=agentid from moneysend where refno=@refno

SELECT @remote_db=remote_db,@enable_update_remoteDB=enable_update_remote_DB,    
@PartnerAgentCode=PartnerAgentCode,@PartnerAgent=remarks 
from tbl_interface_setup 
where mode='Send' and AgentCode=@sagentid
select @remote_db=additional_value,@PartnerAgent=static_value from static_values where sno=200 and static_data=@PartnerAgentCode
create table #temp(status varchar(50),transstatus varchar(50),process varchar(50),lock_status varchar(50))
if @enable_update_remoteDB='y' 
begin
	Declare @ObjectName varchar(50),@SchemaName varchar(50),@databaseName varchar(50),@servername varchar(50),@syntax varchar(200)

	set @remote_db='PRABHU_MY.prabhuCASH.dbo.'
	set @remote_db=@remote_db+'spa_PartnerCheck_for_cancel_Remote'
	set @ObjectName= PARSENAME(@remote_db, 1)
	set @SchemaName= PARSENAME(@remote_db, 2)
	set @databaseName= PARSENAME(@remote_db, 3)
	set @servername=PARSENAME(@remote_db, 4)
    set @syntax = @databaseName+'.'+@SchemaName+'.'+@ObjectName +' '''''+@encRefno+''''''
 
 exec ('insert into #temp(status,transstatus,lock_status)
 select status,transstatus,lock_status from 
 openQuery('+@servername+' , '''+@syntax+''')')
 print ('insert into #temp(status,transstatus,lock_status)
 select status,transstatus,lock_status from 
 openQuery('+@servername+' , '''+@syntax+''')')
 

	if exists(select * from #temp where status ='Un-Paid' and transstatus='Payment' and isNULL(lock_status,'unlocked')='unlocked')    
	begin    
		update #temp set process='SUCCESS'
		exec ('update moneysend set transStatus=''Cancel Processing'' where refno='''+@encRefno+'''')    
	end
	ELSE
	begin
	if not exists(select * from #temp where 1=1)
	begin    
		select 'ERROR','7931: Transaction not found in Remote System ('+@PartnerAgent+')'
		return    
	end
	else
	begin
		select 'ERROR','7930: Remote System ('+@PartnerAgent+') status is '+status+', '+transstatus+' and '+ lock_status from #temp    
		update #temp set process='ERROR'
		return    
	end    
	END
END
ELSE
update moneysend set transStatus='Cancel Processing' where refno=@encRefno

END
GO


