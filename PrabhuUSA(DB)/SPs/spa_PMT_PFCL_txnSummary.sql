IF OBJECT_ID('spa_PMT_PFCL_txnSummary','P') IS NOT NULL
	DROP PROC spa_PMT_PFCL_txnSummary
Go
/*
** Database			: prabhuUSA
** Object 			: spa_PMT_PFCL_txnSummary
**
** Purpose 			: Txn summary report of PFCL and PMT
**
** Author			:  Anonymous
** MODIFIED Author	:  Ranesh Ratna shakya
** Date				:  16 April 2013, Tue
**
** Modifications	:

*   
** spa_PMT_PFCL_txnSummary '2012-05-13','2013-05-13' 
*/
CREATE PROC spa_PMT_PFCL_txnSummary
    @fromdate VARCHAR(50) ,
    @todate VARCHAR(50)
AS 
    SELECT  CONVERT(VARCHAR, paiddate, 102) PaidDate ,
            receiveAgentID ,
            a.companyName ,
            COUNT(*) totalTXN ,
            SUM(totalroundamt) PayoutAmount ,
            SUM(agent_receiverCommission) RecComm
    INTO    #master
    FROM    moneysend m WITH ( NOLOCK )
            JOIN agentdetail a WITH ( NOLOCK ) ON m.receiveAgentID = a.agentcode
    WHERE   expected_payoutagentid ='20100064' --'20100115'
            AND paidDate BETWEEN @fromdate
                         AND     @todate + ' 23:59:59.998'
    GROUP BY receiveAgentID ,
            a.companyName ,
            CONVERT(VARCHAR, paiddate, 102)
   

    SELECT DISTINCT
            PaidDate
    INTO    #date
    FROM    #master

    SELECT  *
    INTO    #pmt
    FROM    #master
    WHERE   receiveAgentID ='20100003'-- '20100003'--PMT
    SELECT  *
    INTO    #pfcl
    FROM    #master
    WHERE   receiveAgentID ='20100064'-- '20100115'--PFCL
	
     
    	SELECT  d.PaidDate ,
            p.totaltxn  PMTTotal ,
            CAST(p.PayoutAmount AS VARCHAR(50)) +' NPR' PMTAMT ,
            CAST(p.RecComm AS VARCHAR(50)) +' NPR' PMTCOmm ,
            f.totaltxn PFCLTotal ,
            CAST(f.PayoutAmount AS VARCHAR(50)) +' NPR' PFCLAMT ,
            CAST(f.RecComm AS VARCHAR(50)) +' NPR' PFCLCOmm
    FROM    #date d
            LEFT OUTER JOIN #pmt p ON p.paidDate = d.paiddate
            LEFT OUTER JOIN #pfcl f ON d.paidDate = f.paiddate 
			UNION ALL
			SELECT  'Grand Total' ,
            sum(p.totaltxn) ,
            CAST(sum(p.PayoutAmount) AS VARCHAR(50)) +' NPR' PMTAMT ,
            CAST(sum(p.RecComm) AS VARCHAR(50)) +' NPR' PMTCOmm ,
            sum(f.totaltxn) PFCLTotal ,
            CAST(sum(f.PayoutAmount) AS VARCHAR(50)) +' NPR' PFCLAMT ,
            CAST(sum(f.RecComm) AS VARCHAR(50)) +' NPR' PFCLCOmm
    FROM    #date d
            LEFT OUTER JOIN #pmt p ON p.paidDate = d.paiddate
            LEFT OUTER JOIN #pfcl f ON d.paidDate = f.paiddate 
     

          
     