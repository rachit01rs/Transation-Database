INSERT INTO dbo.sender_function 
        ( sno ,
          function_name ,
          Description ,
          link_file ,
          main_menu 
        )
SELECT MAX(sno)+1 , -- sno - int
          'Airtime Report' , -- function_name - varchar(50)
          'Airtime Report' , -- Description - varchar(50)
          'MobileTransfer\Report\BalanceTransfer_Search.asp' , -- link_file - varchar(250)
          'Airtime' FROM dbo.sender_function
          
--          INSERT INTO dbo.sender_function 
--        ( sno ,
--          function_name ,
--          Description ,
--          link_file ,
--          main_menu 
--        )
--SELECT MAX(sno)+1 , -- sno - int
--          'Airtime Pending Report' , -- function_name - varchar(50)
--          'Airtime Pending Report' , -- Description - varchar(50)
--          'MobileTransfer\Report\BT_Pending_Report.asp' , -- link_file - varchar(250)
--          'Airtime' FROM dbo.sender_function
          
                    INSERT INTO dbo.sender_function 
        ( sno ,
          function_name ,
          Description ,
          link_file ,
          main_menu 
        )
SELECT MAX(sno)+1 , -- sno - int
          'International Airtime' , -- function_name - varchar(50)
          'International Airtime' , -- Description - varchar(50)
          'MobileTransfer\InternationalAirtime\BalanceTransfer.asp' , -- link_file - varchar(250)
          'Airtime' FROM dbo.sender_function
          
        