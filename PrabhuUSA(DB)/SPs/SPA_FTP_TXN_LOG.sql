IF OBJECT_ID('SPA_FTP_TXN_LOG','P') IS NOT NULL
DROP PROCEDURE	SPA_FTP_TXN_LOG
GO  

/*    
** Database    : PrabhuUSA    
** Object      : SPA_FTP_TXN_LOG    
** Purpose     : Insert data to moneysend table from dummy table  
** Author      : Bikash Giri  
** Modified	   :Mukta Dhungana
** Modification : Delete record if staus is error  
** Date        : 02 Septemper 2013    
*/  
  
--SPA_FTP_TXN_LOG @flag='l',@PartnerID='PLEX001'   
  
CREATE PROC SPA_FTP_TXN_LOG  
@flag CHAR(1),  
@process_id VARCHAR(200)=NULL,  
@filename VARCHAR(100)=NULL,  
@PartnerID VARCHAR(50)=NULL,  
@refno VARCHAR (100)= NULL, 
@fromdate VARCHAR (100)= NULL,
@todate VARCHAR (100)= NULL,
@status_id INT=NULL,
@status varchar(50)=null,
@remark varchar(150)=null,
@userDetail varchar(50)=null
AS  
  
IF @flag='s'  
BEGIN  
 SELECT * FROM data_import_status  WITH (NOLOCK)   
 WHERE source='tbl_FTP_Import_File_Data' AND   create_ts between @fromdate and @todate +' 23:59:59'   
 AND CASE WHEN @PartnerID IS NULL THEN '1' ELSE recommendation END =ISNULL(@PartnerID,'1') AND code=ISNULL(@status,code) 
 ORDER BY status_id DESC
END  
  
IF @flag='l'       
BEGIN  
 SELECT *,CASE  
        WHEN DataInsertedInMoneySend = 'P' THEN 'Pending'  
        WHEN DataInsertedInMoneySend = 'F' THEN 'Failed'   
        WHEN DataInsertedInMoneySend = 'S' THEN 'Success'    
        END AS Status FROM tbl_FTP_Import_File_Data t WITH (NOLOCK)   
 WHERE CASE WHEN @process_id IS NULL THEN '1' ELSE ProcessId END =ISNULL(@process_id,'1')  
 AND CASE WHEN @PartnerID IS NULL THEN '1' ELSE PartnerID END =ISNULL(@PartnerID,'1')  
 AND CASE WHEN @refno IS NULL THEN '1' ELSE PINNO END =ISNULL(@refno,'1')   
 ORDER BY sno DESC
END 

--DELETE IF STATUS IS ERROR--

IF @flag='d'  
BEGIN
	select @process_id=  process_id FROM data_import_status dis WITH(NOLOCK) WHERE status_id=@status_id
	
	DELETE FROM data_import_status WHERE status_id=@status_id
	DELETE FROM tbl_FTP_Import_File_Data WHERE processid=@process_id
END 



IF @flag='c'				 
BEGIN
	IF EXISTS(SELECT 'X' FROM tbl_FTP_Import_File_Data WHERE ISNULL(DataInsertedInMoneySend,'F') = 'F' AND PINNO=@refno AND ProcessId=@process_id)
	BEGIN
	SELECT '1000' Code,'Error' STATUS,'Pinno is already Failed/Cancel' Message
	RETURN
	END

	   UPDATE   dbo.tbl_FTP_Import_File_Data
	   SET      DataInsertedInMoneySend = 'F',
				Remarks = '[Cancel Transaction]: '+@remark,
				cancel_by=@userDetail,
				cancel_date=dbo.getDateHO(GETUTCDATE())
	   WHERE    PINNO=@refno AND ProcessId=@process_id
	   SELECT '0000' Code,'Success' STATUS,@refno+' successffully Canceled!!!' Message FROM tbl_FTP_Import_File_Data WHERE 
	   DataInsertedInMoneySend = 'F' AND PINNO=@refno AND cancel_by=@userDetail AND ProcessId=@process_id

END