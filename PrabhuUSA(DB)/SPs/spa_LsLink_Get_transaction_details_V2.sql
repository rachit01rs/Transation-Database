IF OBJECT_ID('[spa_LsLink_Get_transaction_details_V2]', 'P') IS NOT NULL 
    DROP PROCEDURE	[spa_LsLink_Get_transaction_details_V2]

GO

/*
** Database : PrabhuUSA
** Object : spa_LsLink_Get_transaction_details_V2
**
** Purpose : Searching transactions through LinkServer
**
** Author:  Mukta Dhungana
** Date:    03/16/2013
**
** Modifications:
**  - created new proc for searching TXNs through LinkServer

*/
CREATE PROC [dbo].[spa_LsLink_Get_transaction_details_V2]
    @control_no VARCHAR(50) = NULL
AS 
    BEGIN
        DECLARE @encrypt_refno VARCHAR(50)
        SET @encrypt_refno = dbo.encryptdb(@control_no)
        SELECT  m.* ,
                CAST(ISNULL(payout_settle_usd,
                            ISNULL(ho_dollar_rate,
                                   exchangeRate * agent_settlement_rate)) AS FLOAT) NPR_USD_settelementRate ,
                a.CompanyName PayoutAgent
        FROM    moneysend m WITH ( NOLOCK )
                JOIN agentdetail a WITH ( NOLOCK ) ON m.expected_payoutagentid = a.agentcode
                LEFT OUTER JOIN agentbranchdetail b WITH ( NOLOCK ) ON b.agent_branch_code = m.rBankid
        WHERE   transStatus = 'Payment'
                AND receiverCountry = 'Nepal'
                AND refno = @encrypt_refno  
    END    