    SELECT  
    LEFT(dbo.decryptDb(m.refno),20) [Ref_no],
    CONVERT(VARCHAR(10), confirmDate, 103) [Ref_date],
	LEFT(ISNULL(m.SenderName,''),80) [Rem_name],
	LEFT(ISNULL(m.SenderAddress,''),120) [Rem_address],
	LEFT(ISNULL(m.sender_mobile,''),20) [Rem_Mob_No],
	LEFT(ISNULL(m.ReceiverName,''),80) [Ben_name],
	LEFT(ISNULL(m.ReceiverAddress,''),120) [Ben_addr],
	LEFT(ISNULL(m.receiver_mobile,''),20) [Ben_Mob_no],
	LEFT(ISNULL(m.rBankName,''),60) [Ben_bank],
	CASE WHEN m.paymentType='Cash Pay' THEN '' ELSE LEFT(ISNULL(m.rBankBranch,''),80) END [Ben_br_name],
	LEFT(ISNULL(b.ext_branch_code,''),5) [Ben_br_code],
	LEFT('',9) [Routing Number],
	CASE WHEN m.paymentType='Cash Pay' THEN LEFT('Cash',8) WHEN m.paymentType IN ('Account Deposit','Bank Transfer') THEN LEFT('Transfer',8)  ELSE LEFT('Card',8) END [Pay_mode],
	LEFT('',10) [Ac_type],
	LEFT(ISNULL(m.rBankACNo,''),25) [Ben_ac_num],
	CAST(m.TotalRoundAmt AS NUMERIC(18,2)) [Remit_amt],
	LEFT(ISNULL(m.receiveCType,''),3) [Pay_cur],
	LEFT(ISNULL(m.ReceiverIDDescription,''),150) [Proof_ID],
	LEFT(LEFT(dbo.decryptDb(m.refno),20),12) [PCN/PIN],
	LEFT('',20) [Card No.]
    FROM    moneysend m WITH ( NOLOCK )
            LEFT OUTER JOIN agentbranchdetail b WITH ( NOLOCK ) ON m.rBankID = b.agent_branch_code
    WHERE   expected_payoutagentid = '20100064'
    AND Transstatus ='Payment' AND m.paymentType in ('Account Deposit','Bank Transfer','Cash Pay')
    
    --SELECT DISTINCT paymenttype FROM dbo.moneySend