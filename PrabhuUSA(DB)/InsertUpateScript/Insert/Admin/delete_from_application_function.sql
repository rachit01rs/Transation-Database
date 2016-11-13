

/*  
** Database    : PrabhuUSA
** Object      : TABLE application_function
** Purpose     : Remove customer online submenu from Utilities because it has been added in Online Transaction Module
** Author      : Puja Ghaju 
** Date        : 20 September 2013  
*/ 


DELETE FROM dbo.application_function WHERE function_name='Customer Online' AND main_menu='Utilities'