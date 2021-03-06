/****** Object:  StoredProcedure [dbo].[spa_batch_report]    Script Date: 08/01/2014 12:40:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER proc [dbo].[spa_batch_report]  
@message_id int,  
@call_from varchar(100)=NULL,  
@order_by varchar(300)=NULL  
as  
declare @temp_table_name varchar(200),@sql varchar(5000)  
  
IF @call_from='soa_ledger_local'  
BEGIN  
select @temp_table_name='iremit_process.dbo.soa_ledger_'+user_login_id+'_'+job_name from message_board  
where message_id=@message_id AND source=@call_from  
END  
ELSE  
select @temp_table_name='iremit_process.dbo.'+source+'_'+user_login_id+'_'+job_name from message_board  
where message_id=@message_id AND source=@call_from  
--PRINT (@temp_table_name)  
  
IF @temp_table_name IS null  
SELECT 'ERROR' Status,2001,'Invalid batch id' Message  
else  
begin  
if @call_from is null  
 set @sql='select * from '+ @temp_table_name  
else if @call_from='SummaryBalance'   
 set @sql='select * from '+ @temp_table_name  
else  
 set @sql='select * from '+ @temp_table_name  
--print @sql  
end  
  
IF @order_by IS NOT NULL  
 SET @sql=@sql +' order by '+@order_by  
--PRINT (@sql)  
exec(@sql)  
  
  
  
  