
/****** Object:  StoredProcedure [dbo].[spa_PartnerCheck_for_Cancel_SOAP]    Script Date: 01/19/2015 16:49:07 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--spa_PartnerCheck_for_Cancel_SOAP 'GFFFNNFEIFFF'
ALTER proc [dbo].[spa_PartnerCheck_for_Cancel_SOAP]
 @refno varchar(50),
 @temp_table VARCHAR(150)   
as    
begin     
    
 DECLARE @remote_db varchar(200),@sql varchar(5000)    
 DECLARE @sagentid varchar(50),@enable_update_remoteDB char(1),    
 @PartnerAgentCode varchar(50),@encRefno varchar(50),@PartnerAgent varchar(50),
@expected_payoutagentid varchar(50)   
     
select @encRefno=refno,@sagentid=agentid,@expected_payoutagentid=expected_payoutagentid from moneysend where refno=@refno

SELECT @remote_db=remote_db,@enable_update_remoteDB=enable_update_remote_DB,    
@PartnerAgentCode=PartnerAgentCode,@PartnerAgent=remarks 
from tbl_interface_setup 
where mode='Send' and AgentCode=@expected_payoutagentid

select @remote_db=additional_value,@PartnerAgent=static_value from static_values where sno=200 and static_data=@PartnerAgentCode
create table #temp(status varchar(50),transstatus varchar(50),process varchar(50),lock_status varchar(50))
if @enable_update_remoteDB='y' 
begin
	Declare @ObjectName varchar(50),@SchemaName varchar(50),@databaseName varchar(50),@servername varchar(50),@syntax varchar(200)
	DECLARE @msg VARCHAR(150)
	
	set @remote_db='PRABHU_MY.prabhuCASH.dbo.'
	set @remote_db=@remote_db+'spa_PartnerCheck_for_cancel_Remote'
	set @ObjectName= PARSENAME(@remote_db, 1)
	set @SchemaName= PARSENAME(@remote_db, 2)
	set @databaseName= PARSENAME(@remote_db, 3)
	set @servername=PARSENAME(@remote_db, 4)
    set @syntax = @databaseName+'.'+@SchemaName+'.'+@ObjectName +' '''''+@encRefno+''''',''''s''''' 
 
 exec ('insert into #temp(status,transstatus,lock_status)
 select status,transstatus,lock_status from 
 openQuery('+@servername+' , '''+@syntax+''')')
 print ('insert into #temp(status,transstatus,lock_status)
 select status,transstatus,lock_status from 
 openQuery('+@servername+' , '''+@syntax+''')')
 

	if exists(select * from #temp where status ='Un-Paid' and transstatus='Payment' and isNULL(lock_status,'unlocked')='unlocked')    
	begin    
			update #temp set process='SUCCESS'
			exec PRABHU_MY.prabhuCASH.dbo.spa_PartnerCheck_for_cancel_Remote @encRefno,'u'
			exec('insert '+ @temp_table +'(msg_status,msg_remarks)
			select ''Success'',''Ready for Cancel''') 
	end
	ELSE
	begin
	if not exists(select * from #temp where 1=1)
	begin    
		exec('insert '+ @temp_table +'(msg_status,msg_remarks)
			select ''ERROR'',''7931: Transaction not found in Remote System ('+@PartnerAgent+')''') 
		return    
	end
	else
	BEGIN
		select @msg='7930: Remote System ('+@PartnerAgent+') status is '+status+', '+transstatus+' and '+ lock_status from #temp  
		
		exec('insert '+ @temp_table +'(msg_status,msg_remarks)
		select ''ERROR'','''+@msg+'''') 
		  
		update #temp set process='ERROR'
		return    
	end    
	END
END
ELSE
		exec('insert '+ @temp_table +'(msg_status,msg_remarks)
			select ''Success'',''Ready for Cancel''') 

END
