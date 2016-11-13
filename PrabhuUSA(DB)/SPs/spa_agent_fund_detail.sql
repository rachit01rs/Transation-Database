ALTER proc [dbo].[spa_agent_fund_detail]      
@flag char(1),      
@agent_id varchar(50),      
@branch_id varchar(50)=NULL,      
@date_from varchar(20),      
@date_to varchar(20),      
@type varchar(10),      
@bank_id VARCHAR(50)=NULL       
as      
SET NOCOUNT ON
declare @sql varchar(8000)      
set @sql='      
SELECT    f.*, s.BankName,      
case when invoice_type=''m'' then ''(Dr)'' else ''(Cr)'' end Type,      
b.branch,DATEDIFF(dd,GETUTCDATE(),f.DOT) DIFF      
FROM     agent_fund_detail f INNER JOIN      
     BankAgentSender s ON      
f.Sender_BankID = s.AgentCode      
left outer join agentbranchdetail b       
on f.branch_code=b.agent_branch_code      
where f.dot between '''+@date_from +''' and '''+ @date_to +' 23:59:59''      
and f.agentcode='''+@agent_id +''' and invoice_type not in (''f'',''r'')       
and case when invoice_type=''m'' then ''(Dr)'' else ''(Cr)'' end='''+@type+'''      
'     

IF @bank_id IS NOT NULL       
set @sql=@sql +' and f.Sender_BankId='''+@bank_id+''''      
if @branch_id is not null      
set @sql=@sql +' and f.branch_code='''+@branch_id+''''      
if @flag='u'      
 set @sql=@sql +'  and f.approve_ts is null and invoice_no not like ''C%'''      
else if @flag='c'      
 set @sql=@sql +' and f.approve_ts is null and invoice_no like ''C%'''      
ELSE IF @flag='s'      
SET @sql=@sql +'  and f.approve_ts is null'       
else      
 set @sql=@sql +' and f.approve_ts is not null'      
      
      
set @sql=@sql +' order by f.fund_id desc'      
--PRINT @sql       
exec(@sql)      
      
  
  