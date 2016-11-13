INSERT INTO [dbo].[application_function]
           ([sno]
           ,[function_name]
           ,[Description]
           ,[link_file]
           ,[main_menu]
           )
           select
           MAX(sno+1)
           ,'Setup API Partner'
           ,'Setup API Partner'
           ,'api_partner/setup.asp'
           ,'Utilities'
           FROM application_function
GO