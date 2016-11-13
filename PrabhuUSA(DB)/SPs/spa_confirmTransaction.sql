drop proc  [dbo].[spa_confirmTransaction]
GO
/****** Object:  StoredProcedure [dbo].[spa_confirmTransaction]    Script Date: 03/11/2014 14:29:15 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



--spa_confirmTransaction '1877144, 1877143, 1877142, 1877140','acharyabishnu','10100000'
--spa_confirmTransaction '1877189','deepen','10100000'

CREATE proc  [dbo].[spa_confirmTransaction]
@tranno varchar(8000),
@user_id varchar(50),
@agent_id varchar(50),
@mode char(1)=NULL
AS
BEGIN TRY
declare @TRN_APV_NOT_SAME char(1)

declare @gmt_now datetime,@row_approved int,@sql varchar(5000),@gmt_value varchar(10),@mangmt_appv_trn_local money
select @gmt_value=gmt_value,@TRN_APV_NOT_SAME=dont_allow_apv_same_user from agentDetail WITH(NOLOCK) where agentCode=@agent_id
select @mangmt_appv_trn_local=mangmt_appv_trn_local from agent_function WITH(NOLOCK) where agent_id=@agent_id

 SELECT item txnid INTO #TempSelected  
 FROM   dbo.SplitCommaSeperatedValues(@tranno)


if @mangmt_appv_trn_local is Null
	set @mangmt_appv_trn_local=0

if @TRN_APV_NOT_SAME ='y' 
begin
create table #temp(tranno int)
exec('insert into #temp select tranno from moneysend WITH(NOLOCK)where sempid='''+@user_id +''' and tranno in ('+ @tranno +')')

	if exists(select * from #temp)
	begin
		select 'Error' Status, 'Same user can''t Approve the Transaction made' Msg
		return
	end
end
--declare @count_agentid varchar(50)
--create table #temp_payout_count(
--agentcode varchar(50)
--)



--set @sql='insert into #temp_payout_count(agentcode)
--select count(distinct expected_payoutagentid) from moneysend where tranno in ('+@tranno+')'

--exec (@sql)

--select @count_agentid= agentcode from #temp_payout_count

--drop table #temp_payout_count


--if @count_agentid>1
--	begin
--		select 'Error' Status, 'You Can''t Approve Multiple Payout Agent Transaction at a Same Time' Msg
--		return
--	end

DECLARE @process_id varchar(150)
SET @process_id = REPLACE(newid(),'-','_')

begin transaction
--- check ofac_list flag
create table #temp_ofac (tranno int)
exec ('insert into #temp_ofac (tranno) select tranno from moneysend WITH(NOLOCK) where tranno in ('+@tranno+') and (ofac_list=''y'' or compliance_flag=''y'')and ofac_app_ts is null')
create table #temp_NONofac (tranno int)
exec ('insert into #temp_NONofac (tranno) select tranno from moneysend WITH(NOLOCK) where tranno in ('+@tranno+') and ((ofac_list is NULL and compliance_flag is NULL and agent_limit_exceed is NULL) or ((ofac_list=''y'' or compliance_flag=''y'' or agent_limit_exceed=''y'') and ofac_app_ts is not null))')
create table #temp_halt (tranno int)
exec ('insert into #temp_halt (tranno) select tranno from moneysend WITH(NOLOCK) where tranno in ('+@tranno+') and (agent_limit_exceed=''y'') ')
-- condition for transstatus according to ofac_list 

set @sql='update moneysend set confirmDate=dbo.FNADateUTC('+ @gmt_value +',GETUTCDATE()),HO_confirmDate=dbo.getDateHO(getutcdate()),transStatus=''Payment'',
approve_by='''+ @user_id +''',confirm_process_id='''+ @process_id +''' 
where transStatus=''Hold'' and tranno in (select tranno from #temp_NONofac) 
and agentid='''+ @agent_id +''''
if @mode is NulL and @mangmt_appv_trn_local > 0
	set @sql=@sql + 'and paidAmt <'+ cast(@mangmt_appv_trn_local as varchar)

exec(@sql)

set @sql=''
set @sql='update moneysend set confirmDate=dbo.FNADateUTC('+ @gmt_value +',GETUTCDATE()),HO_confirmDate=dbo.getDateHO(getutcdate()),transStatus=''OFAC'',
approve_by='''+ @user_id +''',confirm_process_id='''+ @process_id +'''  where transStatus=''Hold'' and tranno in (select tranno from #temp_ofac) 
and agentid='''+ @agent_id +''' and ofac_list=''y'''
if @mode is NulL and @mangmt_appv_trn_local > 0
	set @sql=@sql + 'and paidAmt <'+ cast(@mangmt_appv_trn_local as varchar)
exec(@sql)


---- For Compliance
set @sql='update moneysend set confirmDate=dbo.FNADateUTC('+ @gmt_value +',GETUTCDATE()),HO_confirmDate=dbo.getDateHO(getutcdate()),transStatus=''Compliance'',
approve_by='''+ @user_id +''',confirm_process_id='''+ @process_id +'''  where transStatus=''Hold'' and tranno in (select tranno from #temp_ofac) 
and agentid='''+ @agent_id +''' and compliance_flag=''y'''
if @mode is NulL and @mangmt_appv_trn_local > 0
	set @sql=@sql + 'and paidAmt <'+ cast(@mangmt_appv_trn_local as varchar)
exec(@sql)


-- For Halt(agentlimitexceed)
set @sql='update moneysend set confirmDate=dbo.FNADateUTC('+ @gmt_value +',GETUTCDATE()),HO_confirmDate=dbo.getDateHO(getutcdate()),transStatus=''Halt'',
approve_by='''+ @user_id +''',confirm_process_id='''+ @process_id +'''  where transStatus in (''Hold'',''Compliance'',''OFAC'') and tranno in (select tranno from #temp_halt) 
and agentid='''+ @agent_id +''' and agent_limit_exceed=''y'''
if @mode is NulL and @mangmt_appv_trn_local > 0
	set @sql=@sql + 'and paidAmt <'+ cast(@mangmt_appv_trn_local as varchar)
--print(@sql)
exec(@sql)

set @row_approved=@@rowcount
declare @enable_update_remoteDB char(1),@remote_db varchar(500)
declare @payout_agentid varchar(50)
commit transaction

DECLARE @tranno_col VARCHAR(MAX)
SET @tranno_col=''
	DECLARE payoutLoop CURSOR  FORWARD_ONLY READ_ONLY FOR
		select distinct tis.remote_db,tis.enable_update_remote_DB,tis.agentcode
		  from #TempSelected t JOIN moneySend ms WITH(NOLOCK) ON ms.Tranno=t.txnid
		   join tbl_interface_setup tis  on ms.expected_payoutagentid=tis.agentcode
		where mode='Send'
		OPEN payoutLoop
		FETCH NEXT FROM payoutLoop into @remote_db,@enable_update_remoteDB,@payout_agentid
		WHILE @@FETCH_STATUS = 0
		BEGIN
			SET @tranno_col=''
			SELECT  @tranno_col=@tranno_col+cast(tranno AS VARCHAR)+',' FROM MONEYsend m WITH(NOLOCK)
			JOIN #TempSelected scsv on scsv.txnid= m.Tranno  WHERE  m.expected_payoutagentid=@payout_agentid
			SET @tranno_col = LEFT(@tranno_col,LEN(@tranno_col)-1)
			if @enable_update_remoteDB='y'
			EXEC ('spRemote_sendTrns ''i'','''+@tranno_col+''','''+@user_id+''','''+@agent_id+''','''+ @process_id +'''')
	
			--print @tranno_col
			FETCH NEXT FROM payoutLoop into @remote_db,@enable_update_remoteDB,@payout_agentid
		end
	close payoutLoop
	deallocate payoutLoop


DECLARE @eTranno INT,@customerID varchar(50)
		DECLARE EmailLoop CURSOR  FORWARD_ONLY READ_ONLY FOR
		select m.tranno,m.customerID from #TempSelected t Join moneySend m WITH(NOLOCK) on t.txnid=m.Tranno
		where m.send_mode='m' and m.transStatus in ('Payment')
		OPEN EmailLoop
		FETCH NEXT FROM EmailLoop into @eTranno,@customerID
		WHILE @@FETCH_STATUS = 0
		BEGIN
			exec spa_MobileEmail @flag='a',@customerID=@customerID,@Tranno=@eTranno			
			print @eTranno
			FETCH NEXT FROM EmailLoop into @eTranno,@customerID
		end
	close EmailLoop
	deallocate EmailLoop

select 'Success' Status, cast(@row_approved  as varchar) +' Approved' Msg


end try
begin catch

if @@trancount>0 
	rollback transaction

	declare @desc varchar(1000)
	set @desc='SQL Error found:  (' + ERROR_MESSAGE() + ')'
	
	
	INSERT INTO [error_info]
           ([ErrorNumber]
           ,[ErrorDesc]
           ,[Script]
           ,[ErrorScript]
           ,[QueryString]
           ,[ErrorCategory]
           ,[ErrorSource]
           ,[IP]
           ,[error_date])
	select -1,@desc,'spa_confirmTransaction','SQL',@desc,'SQL','SP',@user_id,dbo.getDateHO(getutcdate())
	select 'ERROR','1050','Error Please try again'

end catch