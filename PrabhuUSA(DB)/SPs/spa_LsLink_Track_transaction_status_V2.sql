IF OBJECT_ID('[spa_LsLink_Track_transaction_status_V2]', 'P') IS NOT NULL 
    DROP PROCEDURE	[spa_LsLink_Track_transaction_status_V2]

GO

/*
** Database : PrabhuUSA
** Object : spa_LsLink_Track_transaction_status_V2
**
** Purpose : For Tracking Transactions
**
** Author:  Mukta Dhungana
** Date:    03/17/2013
**
** Modifications:
**  - created new proc For Tracking Transactions 

*/


CREATE  PROC [dbo].[spa_LsLink_Track_transaction_status_V2]
    @control_no VARCHAR(50) = NULL
AS 
    BEGIN
        DECLARE @enc_control_no VARCHAR(50)
        CREATE TABLE #transaction_status
            (
              system_name VARCHAR(200) ,
              tran_status VARCHAR(50) ,
              tran_information VARCHAR(1000) ,
              senderName VARCHAR(100) ,
              receiverName VARCHAR(100) ,
              totalroundamt VARCHAR(50)
            )    
        DECLARE @status VARCHAR(50) ,
            @PaymentType VARCHAR(50) ,
            @paidDate VARCHAR(50) ,
            @paidBy VARCHAR(50) ,
            @senderName VARCHAR(100) ,
            @receiverName VARCHAR(100) ,
            @totalroundamt VARCHAR(50) ,
            @paidCType VARCHAR(5) ,
            @info VARCHAR(1000)  
        SET @enc_control_no = dbo.encryptdb(@control_no)  
-----CHECK IN LOCAL SYSTEM  
        IF NOT EXISTS ( SELECT  status
                        FROM    moneysend WITH ( NOLOCK )
                        WHERE   refno = @enc_control_no ) 
            BEGIN   
                INSERT  INTO #transaction_status
                        ( system_name ,
                          tran_status ,
                          tran_information
                        )
                        SELECT  'USA System' ,
                                'N/A' ,
                                'Transaction Not Found in USA System'  
            END   
        ELSE 
            BEGIN  
                SELECT  @status = status ,
                        @PaymentType = paymentType ,
                        @paidDate = PaidDate ,
                        @paidBy = PaidBy ,
                        @senderName = sendername ,
                        @receiverName = receivername ,
                        @totalroundamt = totalroundamt ,
                        @paidCType = receiveCType
                FROM    moneysend WITH ( NOLOCK )
                WHERE   refno = @enc_control_no  
                SET @info = 'Payment Details(PaymentType:'
                    + ISNULL(@PaymentType, 'N/A') + ',Paid Date:'
                    + ISNULL(@paidDate, 'N/A') + ',Paid By:' + ISNULL(@paidBy,
                                                              'N/A')  
                INSERT  INTO #transaction_status
                        SELECT  'USA System' ,
                                ISNULL(@status, 'N/A') ,
                                @info ,
                                ISNULL(@senderName, 'N/A') ,
                                ISNULL(@receiverName, 'N/A') ,
                                ISNULL(@totalroundamt + ' ' + @paidCType,
                                       'N/A')  
            END
				SELECT * FROM #transaction_status
    END