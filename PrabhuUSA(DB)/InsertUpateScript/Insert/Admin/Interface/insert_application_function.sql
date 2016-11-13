-- =============================================
-- Author:  Sunita Shrestha
-- Create date: 18th february 2014
-- Purpose: inserted in to table application_function.
-- =============================================
 INSERT INTO [dbo].[application_function]
           (
           	[sno]
           ,[function_name]
           ,[Description]
           ,[link_file]
           ,[main_menu]
)
SELECT  MAX(sno)+1
           ,'Interface Setup'
           ,'Interface Setup'
           ,'InterfaceSetup/interface_agent_details.asp'
           ,'Utilities'
 FROM [application_function] 