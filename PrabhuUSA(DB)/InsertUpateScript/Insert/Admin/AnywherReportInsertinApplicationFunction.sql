INSERT INTO [dbo].[application_function]
           ([sno]
           ,[function_name]
           ,[Description]
           ,[link_file]
           ,[main_menu]
           )
           select
           MAX(sno+1)
           ,'Anywhere Report'
           ,'Anywhere Report'
           ,'report/Anywhere_Report/anywhereReport.asp'
           ,'Reports'
           FROM application_function
GO


SELECT * FROM [application_function] WHERE main_menu='Reports' ORDER BY sno DESC