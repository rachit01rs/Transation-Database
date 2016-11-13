/****** Object:  StoredProcedure [dbo].[spa_xml_China_Reconcilation]    Script Date: 11/02/2014 12:06:02 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spa_xml_China_Reconcilation]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[spa_xml_China_Reconcilation]
GO

/****** Object:  StoredProcedure [dbo].[spa_xml_China_Reconcilation]    Script Date: 11/02/2014 12:06:02 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [dbo].[spa_xml_China_Reconcilation]    
@user_id varchar(50)=NULL,    
@xmlValue varchar(max)    
    
as    
DECLARE @sql VARCHAR(8000)    
DECLARE @idoc int    
DECLARE @doc varchar(1000)    
    
begin try    
exec sp_xml_preparedocument @idoc OUTPUT, @xmlValue    
-----------------------------------------------------------------    
SELECT companyId,username,method,transId,status,pStatus,ssn,errCode into #approve_china_rep    
FROM   OPENXML (@idoc, 'transactions/transaction',2)    
         WITH (    
   companyId varchar(50)  'companyId',    
   username varchar(50)  'username',    
   method  varchar(100) 'method',    
   transId  varchar(50)  'transId',       
   status  varchar(100) 'status' ,    
   pStatus  varchar(50)  'pStatus' ,    
   ssn   varchar(100) 'ssn' ,    
   errCode  varchar(100) 'errCode'       
   )    
exec sp_xml_removedocument @idoc    
    
    
declare @errcode varchar(20),@errDescription varchar(500),@sts_retriable CHAR(1)   
select @errcode=errCode from #approve_china_rep    
    
    
SELECT   
   @errDescription=[description]  
  ,@sts_retriable=retriable   
 FROM c2c_error_codes WHERE code=@errcode  
  
 IF @errDescription IS NULL  
  SET @errDescription='Unidentified Error'     
    
if not exists(select companyId from #approve_china_rep)    
begin     
 exec spa_xml_China_approve_Rep_fail @xmlValue    
 return    
end    
declare @session varchar(150)    
set @session=REPLACE(newid(),'-','_')    
    
    
insert into approve_china_rep_log(    
 [companyId],[username],[method],[transId],[status],[pStatus],[ssn],[errCode],[ErrorDescription],[create_ts],[sessionid],create_user    
)    
select companyId,username,method,dbo.encryptDb(transId),status,pStatus,ssn,errCode,@errDescription [ErrorDescription],    
getdate(),@session [sessionid],@user_id from #approve_china_rep    
    
delete approve_china_rep    
insert into approve_china_rep    
([companyId] ,[username],[method],[transId],[status],[pStatus],[ssn],[errCode],[ErrorDescription],[create_ts],[sessionid],create_user)    
select companyId,username,method,dbo.encryptDb(transId),status,pStatus,ssn,errCode,    
@errDescription [ErrorDescription],getdate(),@session [sessionid],@user_id from #approve_china_rep    
    
select companyId,username,method,transId,status,pStatus,ssn,errCode,@errDescription [ErrorDescription] from #approve_china_rep    
--where pStatus=1     
    
    
end try    
begin catch    
    
if @@trancount>0     
 rollback transaction    
    
 declare @desc varchar(1000)    
 set @desc='SQL Error found:  (' + ERROR_MESSAGE() + ')'    
     
     
 INSERT INTO [error_info]    
           ([ErrorNumber]    
           ,[ErrorDesc]    
           ,[Script]    
           ,[ErrorScript]    
           ,[QueryString]    
           ,[ErrorCategory]    
           ,[ErrorSource]    
           ,[IP]    
           ,[error_date])    
 select -1,@desc,'CashtoChina','SQL',@desc,'SQL','SP',@user_id,getdate()    
 select 'ERROR','1050','Error Please try again'    
    
end catch


GO


