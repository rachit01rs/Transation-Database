set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go


ALTER TRIGGER [trg_delete_agentbranchdetail] ON [dbo].[agentbranchdetail] 
FOR delete
AS
INSERT INTO agentbranchdetail_audit(
	[ext_branch_code],
	[agent_branch_Code],
	[agentCode],
	[Branch],
	[Address],
	[City],
	[Country],
	[email],
	[contactPerson],
	[Telephone],
	[Fax],
	[TransferType],
	[branchCodeChar],
	[district_code],
	[block_branch],
	[bank_id],
	[branch_name],
	[account_no],
	[letter_head],
	[currentBalance],
	[currentCommission],
	[branch_bank_code],
	[created_by],
	[created_ts],
	[user_action],
	[updated_by],
	[updated_ts],
	[agent_code_id],
	[isHeadOffice],
	[start_working_hour],
	[end_working_hour],
	[view_report_only],
	[comm_main_branch_id],
	[Allow_CashPay],
	[Branch_Type],
	[payout_overlimit],
	[creditlimit],
	[ext_limit],
	[current_branch_limit],
	[branch_limit],
	[add_branch_limit]

	
)
SELECT 
	[ext_branch_code],
	[agent_branch_Code],
	[agentCode],
	[Branch],
	[Address],
	[City],
	[Country],
	[email],
	[contactPerson],
	[Telephone],
	[Fax],
	[TransferType],
	[branchCodeChar],
	[district_code],
	[block_branch],
	[bank_id],
	[branch_name],
	[account_no],
	[letter_head],
	[currentBalance],
	[currentCommission],
	[branch_bank_code],
	[created_by],
	[created_ts],
	'DELETE',
	[updated_by],
	getdate(),
	[agent_code_id],
	[isHeadOffice],
	[start_working_hour],
	[end_working_hour],
	[view_report_only],
	[comm_main_branch_id],
	[Allow_CashPay],
	[Branch_Type],
	[payout_overlimit],
	[creditlimit],
	[ext_limit],
	[current_branch_limit],
	[branch_limit],
	[add_branch_limit]
	FROM DELETED



