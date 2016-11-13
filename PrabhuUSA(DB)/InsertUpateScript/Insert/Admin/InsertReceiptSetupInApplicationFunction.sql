INSERT INTO [dbo].[application_function]
           ([sno]
           ,[function_name]
           ,[Description]
           ,[link_file]
           ,[main_menu]
           )
           select
           MAX(sno+1)
           ,'Receipt Setup'
           ,'Receipt Setup'
           ,'ReceiptSetup/receiptSetup.asp'
           ,'Utilities'
           FROM application_function
GO


SELECT * FROM [application_function] WHERE main_menu='Utilities' ORDER BY sno DESC