create proc spRemote_pay_process
	@refno_R varchar(50),
	@rBankId_R varchar(50)=NULL,
	@rBankName_R varchar(50)=NULL,
	@rBankBranch_R varchar(50)=NULL,
	@paidBy_R varchar(50)=NULL,
	@paidDate_R varchar(50)=NULL,
	@podDate_R varchar(50)=NULL,
	@paidTime_R varchar(50)=NULL,
	@status_R varchar(50)=NULL,
	@receiverCommission_R varchar(50)=NULL,
	@receiveAgentID_R varchar(50)=NULL,
	@digital_id_payout_R varchar(50)=NULL,
	@agent_receiverCommission_R varchar(50)=NULL,
	@agent_receiverComm_Currency_R varchar(50)=NULL,
	@lock_status_R varchar(50)=NULL,
	@agent_receiverSCommission_R varchar(50)=NULL,
	@paid_agent_id_R varchar(50)=NULL,
	@paid_date_usd_rate_R varchar(50)=NULL
 
 as
 
 insert into tbl_status_moneysend_paid(  
 refno,rBankId,rBankName,rBankBranch,paidBy,paidDate,podDate,paidTime,status,  
 receiverCommission,receiveAgentID,digital_id_payout,agent_receiverCommission,  
 agent_receiverComm_Currency,lock_status,agent_receiverSCommission,paid_agent_id,  
 paid_date_usd_rate)
 values(@refno_R,@rBankId_R,@rBankName_R,@rBankBranch_R,@paidBy_R,@paidDate_R,@podDate_R,
 @paidTime_R,@status_R,@receiverCommission_R,@receiveAgentID_R,
 @digital_id_payout_R,@agent_receiverCommission_R,  
 @agent_receiverComm_Currency_R,@lock_status_R,@agent_receiverSCommission_R,
 @paid_agent_id_R,@paid_date_usd_rate_R)