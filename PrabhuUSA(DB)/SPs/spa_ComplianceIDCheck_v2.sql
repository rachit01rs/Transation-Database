DROP PROC [dbo].[spa_ComplianceIDCheck_v2] 
go
CREATE PROC [dbo].[spa_ComplianceIDCheck_v2] 
@send_agent_id VARCHAR(50),
@destination_country VARCHAR(50),
@payout_agent_id VARCHAR(50) = NULL,
@amount MONEY,
@customer_mobile VARCHAR(20),
@remitter_name VARCHAR(50) = NULL,
@benef_name VARCHAR(50) = NULL,
@remitter_address VARCHAR(150) = NULL, 
@benef_account_no VARCHAR(100) = NULL, 
@payment_type VARCHAR(50) = NULL,
@payout_amount MONEY,
@customer_id          VARCHAR(50),
@remitter_id1         VARCHAR(50),
@remitter_id2         VARCHAR(50),
@process_id           VARCHAR(150),
@remitter_address2 VARCHAR(150) = NULL 
AS
--DECLARE @send_agent_id        VARCHAR(50),
--        @destination_country  VARCHAR(50),
--        @payout_agent_id      VARCHAR(50),
--        @amount               MONEY,
--        @customer_mobile      VARCHAR(20),
--        @remitter_name        VARCHAR(50),
--        @benef_name           VARCHAR(50),
--        @remitter_address     VARCHAR(150),
--        @benef_account_no     VARCHAR(100),
--        @payment_type         VARCHAR(50),
--        @payout_amount        MONEY,
--        @customer_id          VARCHAR(50),
--        @remitter_id1         VARCHAR(50),
--        @remitter_id2         VARCHAR(50),
--        @process_id           VARCHAR(150),
		 --@remitter_address2     VARCHAR(150)
-- 
--
--SET @send_agent_id = '20100000'
--SET @destination_country = 'Nepal'
--SET @amount = 9800
--SET @customer_mobile = '784587695'
--SET @remitter_name = 'RABIN'
--SET @benef_name = 'RECEIVER'
--SET @remitter_address = '47-06 ,49 ST'
--SET @payment_type = 'Cash Pay'
--SET @payout_amount = 700000
--SET @process_id = '123123'
--SET @remitter_address2 = '123123'
--DROP TABLE #PaymentRule_Setup_v2
--DROP TABLE #temp 

CREATE TABLE #temp
(
	compliance_id INT
)

DECLARE @send_country  VARCHAR(50),
        @send_states   VARCHAR(50),
		@states   VARCHAR(50)
SELECT @send_country = country,
       @states = [state]
FROM   agentDetail ad
WHERE  ad.agentCode = @send_agent_id

SELECT @send_states=static_value  FROM static_values WHERE sno=100 AND static_data=@states order by static_value ASC

SELECT p.* INTO #PaymentRule_Setup_v2
FROM   (
           SELECT sno
           FROM   PaymentRule_Setup_v2 prs
           WHERE  prs.destination_country IS NULL
                  AND prs.send_agent_country IS NULL
                  AND prs.enable_disable = 'y'
           UNION 
           SELECT sno
           FROM   PaymentRule_Setup_v2 prs
           WHERE  send_agent_country = @send_country
                  AND prs.destination_country IS NULL
                  AND prs.send_states IS NULL
                  AND prs.enable_disable = 'y' 
           UNION
           SELECT sno
           FROM   PaymentRule_Setup_v2 prs
           WHERE  prs.send_states = @send_states
                  AND prs.destination_country IS NULL
                  AND prs.enable_disable = 'y'
           UNION
           SELECT sno
           FROM   PaymentRule_Setup_v2 prs
           WHERE  prs.destination_country = @destination_country
                  AND prs.send_agent_country IS NULL
                  AND prs.enable_disable = 'y' 
           UNION 
           SELECT sno
           FROM   PaymentRule_Setup_v2 prs
           WHERE  prs.destination_country = @destination_country
                  AND prs.send_agent_country = @send_country
                  AND prs.send_states IS NULL
                  AND prs.enable_disable = 'y' 
           UNION 
           SELECT sno
           FROM   PaymentRule_Setup_v2 prs
           WHERE  prs.destination_country = @destination_country
                  AND prs.send_states = @send_states
                  AND prs.enable_disable = 'y'
       ) l
       JOIN PaymentRule_Setup_v2 p
            ON  l.sno = p.sno 

/*Have Replace <=(less than equal to) with <(less than) as there is no need for txn to be in compliance as 
maximum limitation is defined in those two fields(i.e max_send_amount,max_sender_nos)*/
---- Check by Customer Mobile
INSERT #temp
  (
    compliance_id
  )
SELECT sno
FROM   #PaymentRule_Setup_v2 p
       OUTER APPLY(
    SELECT SUM(paidamt) Send_Amount,
           COUNT(*) TotalTXN
    FROM   moneySend ms WITH (NOLOCK)
    WHERE  ms.transStatus <> 'Cancel'
           AND ms.DOT BETWEEN DATEADD(d, p.nos_of_days * -1, dbo.GETDATEHo(GETUTCDATE())) 
               AND dbo.GETDATEHo(GETUTCDATE())
           AND  RIGHT(ms.sender_mobile, 10)=RIGHT(@customer_mobile, 10)           
) a
WHERE  max_send_amount < (@amount + ISNULL(Send_Amount, 0))
       OR  max_sender_nos < (1 + ISNULL(TotalTXN, 0))

------ Check by Customer Mobile Destination
--INSERT #temp
--  (
--    compliance_id
--  )
--SELECT sno
--FROM   #PaymentRule_Setup_v2 p
--       OUTER APPLY(
--    SELECT SUM(ms.TotalRoundAmt) TotalRoundAmt,
--           COUNT(*) TotalTXN
--    FROM   moneySend ms WITH (NOLOCK)
--    WHERE  ms.transStatus <> 'Cancel'
--           AND ms.DOT BETWEEN DATEADD(d, p.nos_of_days * -1, dbo.GETDATEHo(GETUTCDATE())) 
--               AND dbo.GETDATEHo(GETUTCDATE())
--           AND ms.ReceiverCountry = p.destination_country
--             AND  RIGHT(ms.sender_mobile, 10)=RIGHT(@customer_mobile, 10)
--) a
--WHERE  max_des_amount < (@payout_amount + ISNULL(TotalRoundAmt, 0))
--       OR  max_receiver_nos < (1 + ISNULL(TotalTXN, 0))


---- Check by Remitter Name
IF EXISTS (SELECT * FROM #PaymentRule_Setup_v2 p WHERE p.check_remitter = 'y')
BEGIN 
INSERT #temp
  (
    compliance_id
  )
SELECT sno
FROM   #PaymentRule_Setup_v2 p
       OUTER APPLY(
    SELECT SUM(paidamt) Send_Amount,
           COUNT(*) TotalTXN
    FROM   moneySend ms WITH (NOLOCK)
    WHERE  ms.transStatus <> 'Cancel'
           AND ms.DOT BETWEEN DATEADD(d, p.nos_of_days * -1, dbo.GETDATEHo(GETUTCDATE())) 
               AND dbo.GETDATEHo(GETUTCDATE())
           AND REPLACE(ms.SenderName, ' ', '') = REPLACE(@remitter_name, ' ', '')
           AND RIGHT(ms.sender_mobile, 10) <> RIGHT(@customer_mobile, 10)
) a
WHERE  max_send_amount < (@amount + ISNULL(Send_Amount, 0))
       OR  max_sender_nos < (1 + ISNULL(TotalTXN, 0))
       AND p.check_remitter = 'y'
END 
---- Check by Remitter Name Destination
--INSERT #temp
--  (
--    compliance_id
--  )
--SELECT sno
--FROM   #PaymentRule_Setup_v2 p
--       OUTER APPLY(
--    SELECT SUM(ms.TotalRoundAmt) TotalRoundAmt,
--           COUNT(*) TotalTXN
--    FROM   moneySend ms WITH (NOLOCK)
--    WHERE  ms.transStatus <> 'Cancel'
--           AND ms.DOT BETWEEN DATEADD(d, p.nos_of_days * -1, dbo.GETDATEHo(GETUTCDATE())) 
--               AND dbo.GETDATEHo(GETUTCDATE())
--           AND REPLACE(ms.SenderName, ' ', '') = REPLACE(@remitter_name, ' ', '')
--           AND RIGHT(ms.sender_mobile, 10) <> RIGHT(@customer_mobile, 10)
--           AND ms.ReceiverCountry = p.destination_country
--) a
--WHERE  max_des_amount < (@payout_amount + ISNULL(TotalRoundAmt, 0))
--       OR  max_receiver_nos < (1 + ISNULL(TotalTXN, 0))
--       AND p.check_remitter = 'y'

---- Check by Benef Name
IF EXISTS (SELECT * FROM #PaymentRule_Setup_v2 p WHERE p.check_benef = 'y')
BEGIN 
INSERT #temp
  (
    compliance_id
  )
SELECT sno
FROM   #PaymentRule_Setup_v2 p
       OUTER APPLY(
    SELECT SUM(paidamt) Send_Amount,
           COUNT(*) TotalTXN
    FROM   moneySend ms WITH (NOLOCK)
    WHERE  ms.transStatus <> 'Cancel'
           AND ms.DOT BETWEEN DATEADD(d, p.nos_of_days * -1, dbo.GETDATEHo(GETUTCDATE())) 
               AND dbo.GETDATEHo(GETUTCDATE())
           AND REPLACE(ms.ReceiverName, ' ', '') = REPLACE(@benef_name, ' ', '')
           AND RIGHT(ms.sender_mobile, 10) <> RIGHT(@customer_mobile, 10)
) a
WHERE  max_send_amount < (@amount + ISNULL(Send_Amount, 0))
       OR  max_sender_nos < (1 + ISNULL(TotalTXN, 0))
       AND p.check_benef = 'y'
END 
---- Check by Benef Name Destination
--INSERT #temp
--  (
--    compliance_id
--  )
--SELECT sno
--FROM   #PaymentRule_Setup_v2 p
--       OUTER APPLY(
--    SELECT SUM(ms.TotalRoundAmt) TotalRoundAmt,
--           COUNT(*) TotalTXN
--    FROM   moneySend ms WITH (NOLOCK)
--    WHERE  ms.transStatus <> 'Cancel'
--           AND ms.DOT BETWEEN DATEADD(d, p.nos_of_days * -1, dbo.GETDATEHo(GETUTCDATE())) 
--               AND dbo.GETDATEHo(GETUTCDATE())
--           AND REPLACE(ms.ReceiverName, ' ', '') = REPLACE(@benef_name, ' ', '')
--           AND RIGHT(ms.sender_mobile, 10) <> RIGHT(@customer_mobile, 10)
--           AND ms.ReceiverCountry = p.destination_country
--) a
--WHERE  max_des_amount < (@payout_amount + ISNULL(TotalRoundAmt, 0))
--       OR  max_receiver_nos < (1 + ISNULL(TotalTXN, 0))
--       AND p.check_benef = 'y'

---- Check by Remitter Address
IF EXISTS (SELECT * FROM #PaymentRule_Setup_v2 p WHERE p.check_remitter_address = 'y')
BEGIN 
INSERT #temp
  (
    compliance_id
  )
SELECT sno
FROM   #PaymentRule_Setup_v2 p
       OUTER APPLY(
    SELECT SUM(paidamt) Send_Amount,
           COUNT(*) TotalTXN
    FROM   moneySend ms WITH (NOLOCK)
    WHERE  ms.transStatus <> 'Cancel'
           AND ms.DOT BETWEEN DATEADD(d, p.nos_of_days * -1, dbo.GETDATEHo(GETUTCDATE())) 
               AND dbo.GETDATEHo(GETUTCDATE())
           AND REPLACE(ms.SenderAddress, ' ', '') = REPLACE(@remitter_address, ' ', '')
           AND REPLACE(ms.SenderCompany, ' ', '') = REPLACE(@remitter_address2, ' ', '')
          AND RIGHT(ms.sender_mobile, 10) <> RIGHT(@customer_mobile, 10)
) a
WHERE  max_send_amount < (@amount + ISNULL(Send_Amount, 0))
       OR  max_sender_nos < (1 + ISNULL(TotalTXN, 0))
       AND p.check_remitter_address = 'y'
END 
---- Check by Remitter Destination
--INSERT #temp
--  (
--    compliance_id
--  )
--SELECT sno
--FROM   #PaymentRule_Setup_v2 p
--       OUTER APPLY(
--    SELECT SUM(ms.TotalRoundAmt) TotalRoundAmt,
--           COUNT(*) TotalTXN
--    FROM   moneySend ms WITH (NOLOCK)
--    WHERE  ms.transStatus <> 'Cancel'
--           AND ms.DOT BETWEEN DATEADD(d, p.nos_of_days * -1, dbo.GETDATEHo(GETUTCDATE())) 
--               AND dbo.GETDATEHo(GETUTCDATE())
--           AND REPLACE(ms.SenderAddress, ' ', '') = REPLACE(@remitter_address, ' ', '')
--           AND RIGHT(ms.sender_mobile, 10) <> RIGHT(@customer_mobile, 10)
--           AND ms.ReceiverCountry = p.destination_country
--) a
--WHERE  max_des_amount < (@payout_amount + ISNULL(TotalRoundAmt, 0))
--       OR  max_receiver_nos < (1 + ISNULL(TotalTXN, 0))
--       AND p.check_remitter_address = 'y'

---- Check by Beneficiary Account No
IF EXISTS (SELECT * FROM #PaymentRule_Setup_v2 p WHERE p.check_benef_acc_no = 'y')
BEGIN 
INSERT #temp
  (
    compliance_id
  )
SELECT sno
FROM   #PaymentRule_Setup_v2 p
       OUTER APPLY(
    SELECT SUM(paidamt) Send_Amount,
           COUNT(*) TotalTXN
    FROM   moneySend ms WITH (NOLOCK)
    WHERE  ms.transStatus <> 'Cancel'
           AND ms.DOT BETWEEN DATEADD(d, p.nos_of_days * -1, dbo.GETDATEHo(GETUTCDATE())) 
               AND dbo.GETDATEHo(GETUTCDATE())
           AND REPLACE(ms.rBankACNo, ' ', '') = REPLACE(@benef_account_no, ' ', '')
           AND RIGHT(ms.sender_mobile, 10) <> RIGHT(@customer_mobile, 10)
) a
WHERE  max_send_amount < (@amount + ISNULL(Send_Amount, 0))
       OR  max_sender_nos < (1 + ISNULL(TotalTXN, 0))
       AND p.check_benef_acc_no = 'y'
END 
---- Check by Beneficiary Account No Destination
--INSERT #temp
--  (
--    compliance_id
--  )
--SELECT sno
--FROM   #PaymentRule_Setup_v2 p
--       OUTER APPLY(
--    SELECT SUM(ms.TotalRoundAmt) TotalRoundAmt,
--           COUNT(*) TotalTXN
--    FROM   moneySend ms WITH (NOLOCK)
--    WHERE  ms.transStatus <> 'Cancel'
--           AND ms.DOT BETWEEN DATEADD(d, p.nos_of_days * -1, dbo.GETDATEHo(GETUTCDATE())) 
--               AND dbo.GETDATEHo(GETUTCDATE())
--           AND REPLACE(ms.rBankACNo, ' ', '') = REPLACE(@benef_account_no, ' ', '')
--           AND RIGHT(ms.sender_mobile, 10) <> RIGHT(@customer_mobile, 10)
--           AND ms.ReceiverCountry = p.destination_country
--) a
--WHERE  max_des_amount < (@payout_amount + ISNULL(TotalRoundAmt, 0))
--       OR  max_receiver_nos < (1 + ISNULL(TotalTXN, 0))
--       AND p.check_remitter_address = 'y'

---- Check by Different Location
IF EXISTS (SELECT * FROM #PaymentRule_Setup_v2 p WHERE p.check_location_id = 'y')
BEGIN 
INSERT #temp
  (
    compliance_id
  )
SELECT sno
FROM   #PaymentRule_Setup_v2 p
       OUTER APPLY(
    SELECT COUNT(DISTINCT branch_code) TotalTXN
    FROM   moneySend ms WITH (NOLOCK)
    WHERE  ms.transStatus <> 'Cancel'
           AND ms.DOT BETWEEN DATEADD(d, p.nos_of_days * -1, dbo.GETDATEHo(GETUTCDATE())) 
               AND dbo.GETDATEHo(GETUTCDATE())
           AND RIGHT(ms.sender_mobile, 10) = RIGHT(@customer_mobile, 10)
) a
WHERE  max_sender_nos < (1 + ISNULL(TotalTXN, 0))
       AND p.check_location_id = 'y'
END 

delete temp_compliance_log where process_id=@process_id

INSERT temp_compliance_log
  (
    compliance_id,
    process_id,
    create_ts
  )
SELECT DISTINCT t.compliance_id,
       @process_id,
       GETDATE()
FROM   #temp t
       JOIN PaymentRule_Setup_v2 prsv
            ON  t.compliance_id = prsv.sno
WHERE  prsv.admin_check = 'y'

IF NOT EXISTS (
       SELECT *
       FROM   #temp
   )
BEGIN
    SELECT 'Success' STATUS,
           'Transaction is not in compliance' MSG
END
ELSE
BEGIN
    DECLARE @validation_message VARCHAR(1000)
    SELECT @validation_message = COALESCE(@validation_message + ' <br/> ', '') + prsv.validation_msg
    FROM   (
               SELECT DISTINCT compliance_id
               FROM   #temp
           ) t
           JOIN PaymentRule_Setup_v2 prsv
                ON  t.compliance_id = prsv.sno
		WHERE  ISNULL(prsv.admin_check, 'n') = 'n'
    
   
    IF @validation_message IS NOT NULL
    BEGIN
        SELECT 'Error' STATUS,
               @validation_message validation_msg
    END
    ELSE
    BEGIN

	SELECT @validation_message = COALESCE(@validation_message + '<br/> ', '') + isNUll(prsv.validation_msg,'')
	FROM   (
               SELECT DISTINCT compliance_id
               FROM   #temp
           ) t
           JOIN PaymentRule_Setup_v2 prsv
                ON  t.compliance_id = prsv.sno
		WHERE  ISNULL(prsv.admin_check, 'n') = 'y'

    	  SELECT 'Compliance' STATUS,requiredfield1,@validation_message validation_msg
			 FROM   (
               SELECT DISTINCT compliance_id
               FROM   #temp
           ) t
           JOIN PaymentRule_Setup_v2 prsv
                ON  t.compliance_id = prsv.sno
			WHERE  ISNULL(prsv.admin_check, 'n') = 'y' AND requiredfield1 IS NOT NULL 
			UNION  
			SELECT 'Compliance' STATUS,requiredfield2,@validation_message validation_msg
			 FROM   (
               SELECT DISTINCT compliance_id
               FROM   #temp
           ) t
           JOIN PaymentRule_Setup_v2 prsv
                ON  t.compliance_id = prsv.sno
			WHERE  ISNULL(prsv.admin_check, 'n') = 'y' AND requiredfield2 IS NOT NULL 
			UNION
		 SELECT 'Compliance' STATUS,requiredfield3,@validation_message validation_msg
			 FROM   (
               SELECT DISTINCT compliance_id
               FROM   #temp
           ) t
           JOIN PaymentRule_Setup_v2 prsv
                ON  t.compliance_id = prsv.sno
			WHERE  ISNULL(prsv.admin_check, 'n') = 'y' AND requiredfield3 IS NOT NULL 
			UNION
			SELECT 'Compliance' STATUS,requiredfield4,@validation_message validation_msg
			 FROM   (
               SELECT DISTINCT compliance_id
               FROM   #temp
           ) t
           JOIN PaymentRule_Setup_v2 prsv
                ON  t.compliance_id = prsv.sno
			WHERE  ISNULL(prsv.admin_check, 'n') = 'y' AND requiredfield4 IS NOT NULL 
			UNION
		 SELECT 'Compliance' STATUS,requiredfield5,@validation_message validation_msg
			 FROM   (
               SELECT DISTINCT compliance_id
               FROM   #temp
           ) t
           JOIN PaymentRule_Setup_v2 prsv
                ON  t.compliance_id = prsv.sno
			WHERE  ISNULL(prsv.admin_check, 'n') = 'y' AND requiredfield5 IS NOT NULL 
   
    END
END 
RETURN




