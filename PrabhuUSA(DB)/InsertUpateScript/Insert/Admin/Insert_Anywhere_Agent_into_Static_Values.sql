INSERT INTO [dbo].[static_values]
           ([sno]
           ,[static_value]
           ,[static_data]
           ,[Description]
           )
           SELECT DISTINCT
           '80','Fusindo Bank','20100089','Anywhere Agent'
           
           FROM [static_values]
           
           INSERT INTO [dbo].[static_values]
           ([sno]
           ,[static_value]
           ,[static_data]
           ,[Description]
           )
           SELECT DISTINCT
           '80','PRABHU MONEY  TRANSFER','20100003','Anywhere Agent'
           
           FROM [static_values]
           
           
           INSERT INTO [dbo].[static_values]
           ([sno]
           ,[static_value]
           ,[static_data]
           ,[Description]
           )
           SELECT DISTINCT
           '80','PRABHU FINANCE COMPANY LTD.','20100064','Anywhere Agent'
           
           FROM [static_values]
 
GO
SELECT * FROM static_values WHERE sno=80

