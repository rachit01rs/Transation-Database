drop proc [dbo].[spa_Log_ViewNotPaid]
/****** Object:  StoredProcedure [dbo].[spa_Log_ViewNotPaid]    Script Date: 11/20/2014 01:05:35 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--spa_Log_ViewNotPaid 'Bangladesh'
CREATE proc [dbo].[spa_Log_ViewNotPaid]
@country_Name varchar(150)
as
declare @as_of_date varchar(15)
SET @as_of_date=CONVERT(VARCHAR,GETDATE()-1,112)
select cast(dbo.decryptDB(Refno) as varchar(20)) PINNO,cast(rBankName as varchar(60)) ExpectedPayoutBank,
cast(a.companyName as varchar(60)) ViewedBank,cast(b.branch as varchar(100)) ViewBranch,
cast(m.lock_by  as varchar(20)) ViewUserID,lock_dot UnLockDate
from moneysend m with (nolock) join agentsub s on m.lock_by=s.user_login_id 
join agentbranchdetail b on b.agent_branch_Code=s.agent_branch_code
join agentdetail a on a.agentcode=b.agentcode
where status='Un-Paid' and transStatus='Payment'
and m.lock_status='unlocked' and receiverCountry=@country_Name 
and lock_dot>@as_of_date order by rBankName,a.companyName desc 


--insert email_request(notes_subject,notes_text,attachment_file_name,send_to,send_cc,send_status,active_flag)
--values('Prabhu log - Bangladesh','Transaction View But not Paid Log - Bangladesh
--<br>Execute on:'+CONVERT(VARCHAR,GETDATE(),120) +'
--<br>Report Date:'+ CONVERT(VARCHAR,GETDATE()-1,112),
--'exec prabhuusa.dbo.spa_Log_ViewNotPaid @country_Name=''Bangladesh''','ithead@prabhugroupus.com','anoop@inficare.net','n','y')