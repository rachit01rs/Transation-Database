
/*  
** Database    : PrabhuUSA
** Object      : Table moneysend
** Purpose     : alter table moneysend
** Author      : Sunita Shrestha 
** Date        : 18th jan 2015
*/ 

 IF COL_LENGTH('moneysend','employer_by') IS NULL
	ALTER TABLE moneysend ADD employer_by VARCHAR(100)
GO