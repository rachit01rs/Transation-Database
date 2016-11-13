IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spa_API_Transfer_TXN]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[spa_API_Transfer_TXN]
GO


/****** Object:  StoredProcedure [dbo].[spa_API_Transfer_TXN]    Script Date: 12/24/2014 02:49:17 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO
create proc spa_API_Transfer_TXN      
as 
update API_Transfer_TXN set isTransfer='y' from API_Transfer_TXN a with(nolock) join moneysend m with(nolock) on a.tranno=m.tranno 
join tbl_status_moneysend t with(nolock) on m.refno=t.refno

select t.* into #temp from API_Transfer_TXN t with(nolock) join moneysend m with(nolock) on t.tranno=m.tranno      
where t.isTransfer is null  and m.transStatus='Payment'     
      
DECLARE @eTranno INT,@user_id varchar(50),@agent_id varchar(50),@process_id varchar(150),@sno int      
  DECLARE TXNLoop CURSOR  FORWARD_ONLY READ_ONLY FOR      
  select t.sno,m.tranno,sEmpID,agentid,confirm_process_id from #temp t join moneysend m with(nolock) on t.tranno=m.tranno      
where t.isTransfer is null and m.transStatus='Payment'      
  OPEN TXNLoop      
  FETCH NEXT FROM TXNLoop into @sno,@eTranno,@user_id,@agent_id,@process_id      
  WHILE @@FETCH_STATUS = 0      
  BEGIN      
   EXEC spRemote_sendTrns 'i',@eTranno,@user_id,@agent_id,@process_id      
   update API_Transfer_TXN set isTransfer='y' where sno=@sno      
      
   FETCH NEXT FROM TXNLoop into @sno,@eTranno,@user_id,@agent_id,@process_id      
  end      
 close TXNLoop      
 deallocate TXNLoop      
      
drop table #temp      
