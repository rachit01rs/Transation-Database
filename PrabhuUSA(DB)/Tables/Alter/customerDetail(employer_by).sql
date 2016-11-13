
/*  
** Database    : PrabhuUSA
** Object      : Table customerDetail
** Purpose     : alter table customerDetail
** Author      : Sunita Shrestha 
** Date        : 18th jan 2015
*/ 

 IF COL_LENGTH('customerDetail','employer_by') IS NULL
	ALTER TABLE customerDetail ADD employer_by VARCHAR(100)
GO