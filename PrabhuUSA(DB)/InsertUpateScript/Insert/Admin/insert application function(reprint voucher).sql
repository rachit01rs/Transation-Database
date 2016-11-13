/*
** Database : PrabhuUsa
** Object : Insert_application_function	
**
** Purpose : ----to insert table application_function
** Author: Paribesh Jung Karki	
** Date:    11/19/2014
**
*/
 
 
IF NOT EXISTS(SELECT 'x' FROM  dbo.application_function WHERE link_file='headoffice/reprint_voucher.asp')

	BEGIN
	 
		 INSERT INTO [dbo].[application_function]
			   ([sno]
			   ,[function_name]
			   ,[Description]
			   ,[link_file]
			   ,[main_menu]
		   )
				SELECT MAX(sno)+1
			   ,'RePrint Voucher'
			   ,'RePrint Voucher'
			   ,'headoffice/reprint_voucher.asp'
			   ,'Utilities'
		FROM dbo.application_function
	END