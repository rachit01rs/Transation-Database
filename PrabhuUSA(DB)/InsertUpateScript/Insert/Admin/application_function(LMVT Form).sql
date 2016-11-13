
/*  
** Database    : PrabhuUsa
** Object      : Table application_function
** Purpose     : created insert script for dbo.application_function
** Author      : Sunita Shrestha
** Date        : 6th June,2014
*/ 

	INSERT into dbo.application_function
			( sno ,
			  function_name ,
			  Description ,
			  link_file ,
			  main_menu 
			)
	SELECT MAX(sno)+1,'LMVT Form','LMVT Form','LMVT_Form/searchLMVTForm.asp','OFAC Detail'
	FROM dbo.application_function
	
	INSERT into dbo.application_function
			( sno ,
			  function_name ,
			  Description ,
			  link_file ,
			  main_menu 
			)
	SELECT MAX(sno)+1,'BSA Form','BSA Form','BSA_Form/searchBSAForm.asp','OFAC Detail'
	FROM dbo.application_function
	 