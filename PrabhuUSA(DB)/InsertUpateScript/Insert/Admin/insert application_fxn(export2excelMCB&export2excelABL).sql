/*
** Database : PrabhuUsa
** Object : Insert_application_function	
**
** Purpose : ----to insert table application_function
** Author: Paribesh Jung Karki	
** Date:    09/19/2014
**
*/
 
 
IF NOT EXISTS(SELECT 'x' FROM  dbo.application_function WHERE link_file='export_xls_agent/export2excelABL.asp')

	BEGIN
	 
		 INSERT INTO [dbo].[application_function]
			   ([sno]
			   ,[function_name]
			   ,[Description]
			   ,[link_file]
			   ,[main_menu]
		   )
				SELECT MAX(sno)+1
			   ,'Export TXN ABL'
			   ,'export2excelABL Menu'
			   ,'export_xls_agent/export2excelABL.asp'
			   ,'Utilities'
		FROM dbo.application_function
	END
	
IF NOT EXISTS(SELECT 'x' FROM  dbo.application_function WHERE link_file='export_xls_agent/export2excelMCB.asp')

	BEGIN
	 
		 INSERT INTO [dbo].[application_function]
			   ([sno]
			   ,[function_name]
			   ,[Description]
			   ,[link_file]
			   ,[main_menu]
		   )
				SELECT MAX(sno)+1
			   ,'Export TXN MCB'
			   ,'export2excelMCB Menu'
			   ,'export_xls_agent/export2excelMCB.asp'
			   ,'Utilities'
		FROM dbo.application_function
	END	