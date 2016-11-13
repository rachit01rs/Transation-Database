--SELECT * FROM dbo.static_values WHERE sno=102

INSERT INTO dbo.static_values 
        ( sno ,
          static_value ,
          static_data ,
          Description
        )
VALUES  ( 102 , -- sno - int
          'Cash Management' , -- static_value - varchar(100)
          'Cash' , -- static_data - varchar(100)
          'Agent' 
        )

INSERT INTO dbo.sender_function
        ( sno ,
          function_name ,
          Description ,
          link_file ,
          main_menu 
        )
SELECT MAX(sno)+1,'Cash to Vault','Transfer Cash','store_cash/stored.asp','Cash' FROM dbo.sender_function

INSERT INTO dbo.sender_function
        ( sno ,
          function_name ,
          Description ,
          link_file ,
          main_menu 
        )
SELECT MAX(sno)+1,'Cash Received from Vault','Approve Cash Recei.','store_cash/approved.asp','Cash' FROM dbo.sender_function

INSERT INTO dbo.sender_function
        ( sno ,
          function_name ,
          Description ,
          link_file ,
          main_menu 
        )
SELECT MAX(sno)+1,'Pay Cash','Pay Cash','MoneyGram/paycash.asp','Cash' FROM dbo.sender_function

INSERT INTO dbo.sender_function
        ( sno ,
          function_name ,
          Description ,
          link_file ,
          main_menu 
        )
SELECT MAX(sno)+1,'Position - Cash','Cash Report Uniteller','Uniteller/CashReport/cashReportPanel.asp?report_name=Position','Cash' FROM dbo.sender_function

INSERT INTO dbo.sender_function
        ( sno ,
          function_name ,
          Description ,
          link_file ,
          main_menu 
        )
SELECT MAX(sno)+1,'Bank Deposit from Vault','Bank Report','Uniteller/BankReport/bankReportPanel.asp','Cash' FROM dbo.sender_function

INSERT INTO dbo.sender_function
        ( sno ,
          function_name ,
          Description ,
          link_file ,
          main_menu 
        )
SELECT MAX(sno)+1,'Position - Vault','Cash Vault Report','Deposit_Summary/agentComLedger_vault.asp','Cash' FROM dbo.sender_function

INSERT INTO dbo.sender_function
        ( sno ,
          function_name ,
          Description ,
          link_file ,
          main_menu 
        )
SELECT MAX(sno)+1,'Vault to Teller','Cash from Vault to Teller','store_cash/withdraw.asp','Cash' FROM dbo.sender_function

INSERT INTO dbo.sender_function
        ( sno ,
          function_name ,
          Description ,
          link_file ,
          main_menu 
        )
SELECT MAX(sno)+1,'Refund Cash (Cancel)','Refund Cash','uniteller/refund_cash.asp','Cash' FROM dbo.sender_function

INSERT INTO dbo.sender_function
        ( sno ,
          function_name ,
          Description ,
          link_file ,
          main_menu 
        )
SELECT MAX(sno)+1,'Receipt Cash to Vault','Refund Cash Approved','invoice/fund_detail_unapproved.asp?flag=c','Cash' FROM dbo.sender_function

INSERT INTO dbo.sender_function
        ( sno ,
          function_name ,
          Description ,
          link_file ,
          main_menu 
        )
SELECT MAX(sno)+1,'Transfer Cash to Vault','Transfer Cash','store_cash/transfer_cash_ho.asp','Cash' FROM dbo.sender_function

INSERT INTO dbo.sender_function
        ( sno ,
          function_name ,
          Description ,
          link_file ,
          main_menu 
        )
SELECT MAX(sno)+1,'User Credit Limit','User Credit Limit','BranchLimit/branchuserlimit.asp','Utilities' FROM dbo.sender_function

INSERT INTO dbo.sender_function 
        ( sno ,
          function_name ,
          Description ,
          link_file ,
          main_menu 
          )
          SELECT MAX(sno)+1,'Transfer To Bank/CIT','Transfer To Bank/CIT','invoice/singleInvoice.asp','Cash'
 FROM dbo.sender_function   

