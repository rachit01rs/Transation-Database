
INSERT INTO dbo.static_values
        (
        sno ,	
          static_value ,
          static_data ,
          Description ,
          additional_value
        )
SELECT '301','Contact No.','txtrTelephone','Contact No.',NULL
UNION
SELECT '301','Account No.','txtAccountNo','Account No.',NULL

GO
--SELECT * FROM static_values 
INSERT INTO dbo.static_values
        ( sno ,
          static_value ,
          static_data ,
          Description ,
          additional_value
        )
SELECT '300','Receiver ID Type','ReceiverIDDescription','ReceiverIDDescription',NULL
UNION 
SELECT '300','Place Of Issue','receiverID_placeOfIssue','Place Of Issue',NULL
UNION
SELECT '300','Contact No.','txtrTelephone','Contact No.',NULL
UNION
SELECT '300','Receiver ID','receiverID','Receiver ID',NULL
UNION
SELECT '300','Agent Branch Code','agent_branch_code','Branch Code',NULL
UNION
SELECT '300','Account No.','txtAccountNo','Account No.',NULL
UNION
SELECT '300','Sender ID 1','txtsPassport','Sender ID 1',NULL
UNION
SELECT '300','Sender ID 2','SSN_Card_ID','Sender ID 2',NULL
UNION
SELECT '300','Date of Birth','Date_of_Birth','Date of Birth',NULL
UNION
SELECT '300','Source of Income','source_of_income','Source of Income',NULL