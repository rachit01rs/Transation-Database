IF EXISTS (SELECT * FROM DBO.SYSOBJECTS WHERE ID = OBJECT_ID(N'[DBO].[spa_SSIS_ExportFile_Agent]') AND OBJECTPROPERTY(ID, N'ISPROCEDURE') = 1)
DROP PROCEDURE [DBO].[spa_SSIS_ExportFile_Agent]
GO
/*  
** Database    : PrabhuUSA  
** Object      : spa_SSIS_ExportFile_Agent  
** Purpose     : 
** Author      : Bikash Giri 
** Date        : 23rd August 2013  

   
*/
 
--spa_SSIS_ExportFile_Agent '12345','20100031','bandana','Export_File','2013-08-05','2013-08-25','paidDate','20100003','Nepal','30106331','Paid','Cash Pay',null


CREATE proc [dbo].[spa_SSIS_ExportFile_Agent]
@process_id varchar(150),
@agent_id varchar(50),
@login_user_id varchar(50),
@batch_id varchar(50),
@from_date varchar(20) ,
@to_date varchar(20) ,
@date_type varchar(20)=null,
@payout_agent_id varchar(50)=null,
@payout_country varchar(50) =NULL,
@branch_code VARCHAR(50) = NULL,
@trn_status VARCHAR(50) = NULL,
@trn_type VARCHAR (50) =NULL,
@url_desc VARCHAR (1000) = NULL
as 
BEGIN
SELECT Tranno,SenderName,REPLACE(ISNULL(Senderaddress,''),'[t]',',')+','+REPLACE(ISNULL(Sendercompany,''),'[t]',',') Senderaddress,
	Sender_mobile,senderPassport,ReceiverName,ReceiverAddress,ReceiverCity,ReceiverCountry,
	ReceiverPhone,paidAmt,paidCType,SCharge,today_dollar_rate,totalRoundAmt,receiveCType,paymentType,
	rBankID,rBankName,rBankACNo,confirmDate,ReciverMessage,senderCountry,SenderCity,ms.SSN_Card_id,
	date_of_birth,sPaymentReceivedType,paidDate,paidby,rBankBranch,SenderFax,senderVisa,agentid,
	expected_payoutagentid,ho_dollar_rate,Branch_code,
	dbo.CTGetDate(local_dot) dot_date,dbo.decryptDB(refno) refnoD,
	dbo.CTGetTime(local_dot) dot_time,
	ab.ext_branch_code     from moneysend ms WITH (NOLOCK) 
	LEFT OUTER JOIN dbo.agentbranchdetail ab WITH(NOLOCK) ON ms.rBankID=ab.agent_branch_Code 
	WHERE agentid=@agent_id and 
	CASE WHEN @date_type='paidDate' THEN paidDate ELSE confirmDate END
	between @from_date and @to_date +' 23:59:59:998'
	and Transstatus ='Payment'
	AND CASE WHEN @payout_country IS NOT NULL THEN receiverCountry ELSE '1' END =ISNULL(@payout_country,'1') 
	AND	CASE WHEN @payout_agent_id IS NOT NULL THEN expected_payoutagentid ELSE '1' END =ISNULL(@payout_agent_id,'1')
	AND CASE WHEN @trn_type IS NOT NULL THEN paymentType ELSE '1' END =ISNULL (@trn_type,'1')
	AND CASE WHEN @branch_code IS NOT NULL THEN branch_code ELSE '1' END =ISNULL (@branch_code,'1') 
	AND	CASE WHEN @trn_status IS NOT NULL THEN [status] ELSE '1' END =ISNULL(@trn_status,'1')
 


declare @desc varchar(500),@totcount VARCHAR(100)
set @totcount =  @@ROWCOUNT

set @desc='Export file completed as of date '+ @from_date +' and '+ @to_date +' Total records exported= '+@totcount
	IF (@payout_country IS NOT NULL)      
		SET @desc=@desc +' | Country='+ @payout_country
	IF (@payout_agent_id IS NOT NULL)      
		SET @desc=@desc +' | Agent Name='+ @payout_agent_id
	IF (@branch_code IS NOT NULL)      
		SET @desc=@desc +' | Branch='+ @branch_code
	IF (@trn_status IS NOT NULL)      
		SET @desc=@desc +' | Status='+ @trn_status
	IF (@trn_type IS NOT NULL)      
		SET @desc=@desc +'| Payment Type='+ @trn_type
	IF (@date_type IS NOT NULL)      
		SET @desc=@desc +' | Date Type='+ @date_type

EXEC  spa_message_board 'u', @login_user_id,
				NULL, @batch_id,
				@desc, 'c', @process_id,null,@url_desc
END
GO