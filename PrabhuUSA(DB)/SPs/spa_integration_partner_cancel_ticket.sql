/****** Object:  StoredProcedure [dbo].[spa_integration_partner_cancel_ticket]    Script Date: 02/08/2012 17:47:21 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spa_integration_partner_cancel_ticket]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[spa_integration_partner_cancel_ticket] 
GO
/****** Object:  StoredProcedure [dbo].[spa_integration_partner_cancel_ticket]    Script Date: 02/08/2012 17:47:21 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--exec spa_integration_partner_cancel_ticket 'u',NULL,'NLJJMQRQMKI','Un-Block',NULL,NULL,'deepen',NULL,'test',NULL,NULL                    
--select * from static_values where sno=200              
--spa_integration_partner_cancel_ticket 'i'          
--spa_integration_partner_cancel_ticket 't','20100021','RQOJQPRPONK','ticket','senderName','Deepen Shrestha','deepen','test'              
CREATE proc [dbo].[spa_integration_partner_cancel_ticket]          
 @flag char(1),              
 @PartnerAgentCode varchar(50)=NULL,              
 @refno varchar(50)=NULL,              
 @update_for varchar(50)=NULL,              
 @column_name varchar(50)=NULL,              
 @column_value varchar(50)=NULL,              
 @userid varchar(50)=NULL,              
 @uploadBy varchar(50)=NULL,              
 @remarks varchar(100)=NULL,              
 @gmt_get_date varchar(100)=NULL, ---for cancel              
 @DIG_INFO varchar(200)=NULL ---for cancel              
AS              
            
DECLARE @remote_db varchar(200),@sql varchar(8000),@extra_value char(2),@dup_char char(1)              
DECLARE @payout_agentid varchar(50),@enable_update_remoteDB char(1),@receiverCountry varchar(50),@sendAgent varchar(50)              
if @flag='t' or @flag='b' or @flag='c' or @flag='u'          
 begin              
 create table #temp_payout(              
  agentcode varchar(50),              
  receiverCountry varchar(50),              
  sendagent varchar(50)              
 )              
              
 exec('insert into #temp_payout(agentcode,receiverCountry,sendagent)              
 select distinct expected_payoutagentid,receiverCountry,agentid from moneysend with(nolock) where refno ='''+@refno+'''')              
              
 select @payout_agentid= agentcode,@receiverCountry=receiverCountry,@sendAgent=sendAgent from #temp_payout              
 drop table #temp_payout              
 print @receiverCountry       
   
   
 --SELECT * FROM tbl_interface_setup              
 if exists(select sno from tbl_interface_setup with(nolock) WHERE agentcode=@payout_agentid and mode='Send')              
  select @remote_db=remote_db,@enable_update_remoteDB=enable_update_remote_DB,              
  @PartnerAgentCode=PartnerAgentCode from tbl_interface_setup with(nolock) where agentcode=@payout_agentid and mode='Send'              
 else if exists(select sno from tbl_interface_setup with(nolock) where agentcode=@sendAgent and mode='Pay')              
  select @remote_db=remote_db,@enable_update_remoteDB=enable_update_remote_DB,              
  @PartnerAgentCode=isNULL(PartnerAgentCode,agentcode)              
   from tbl_interface_setup with(nolock) where agentcode=@sendAgent and mode='Pay'              
              
 declare @sql_temp varchar(1000)              
 print @payout_agentid              
END 

IF @enable_update_remoteDB='n'
	RETURN
  
IF @remote_db IS NULL   
BEGIN  
 IF @sendAgent='20100004' AND @payout_agentid='20100080' --- PIC and MUthoot  
 BEGIN  
  SELECT @remote_db=sv.additional_value,@PartnerAgentCode=@sendAgent  
    FROM static_values sv with(nolock) WHERE sv.static_data=@sendAgent  
 END  
   
END       
IF   @remote_db IS NULL and @flag<>'i'  
 RETURN   
  
if @flag='t'              
begin              
set @update_for='tickets'              
 insert into tbl_status(refno,upload_date,PartnerAgentCode,update_for,column_name,column_value,userid,remarks,status)              
 select @refno,getdate(),@PartnerAgentCode,'tickets',@column_name,@column_value,@userid,@remarks,'Pending'              
 SET @sql='              
 INSERT INTO '+@remote_db+'tbl_status(refno,upload_date,PartnerAgentCode,update_for,column_name,column_value,userid,remarks,partner_sno)              
 select refno,upload_date,PartnerAgentCode,''tickets'',column_name,column_value,userid,remarks,sno from tbl_status with(nolock) where           
 refno='''+@refno +''' and status=''Pending'' and update_for='''+@update_for+''''          
 print (@sql)          
 exec (@sql)          
 update tbl_status set status='Done' where refno=@refno and status='Pending' and update_for=@update_for          
END              
if @flag='b'              
begin              
set @update_for='Block'              
              
 insert into tbl_status(refno,upload_date,PartnerAgentCode,update_for,column_name,column_value,userid,remarks,status)              
 select @refno,getdate(),@PartnerAgentCode,'Block',@column_name,@column_value,@userid,@remarks,'Pending'          
               
 SET @sql='              
 INSERT INTO '+@remote_db+'tbl_status(refno,upload_date,PartnerAgentCode,update_for,column_name,column_value,userid,remarks,partner_sno)              
 select refno,upload_date,PartnerAgentCode,update_for,column_name,column_value,userid,remarks,sno from tbl_status where           
 refno='''+@refno +''' and status=''Pending'' and update_for='''+@update_for+''''          
print (@sql)          
 exec (@sql)          
 update tbl_status set status='Done' where refno=@refno and status='Pending' and update_for=@update_for          
end              
if @flag='u'              
begin              
set @update_for='Un-Block'              
              
 insert into tbl_status(refno,upload_date,PartnerAgentCode,update_for,column_name,column_value,userid,remarks,status)              
 select @refno,getdate(),@PartnerAgentCode,'Un-Block',@column_name,@column_value,@userid,@remarks,'Pending'          
               
 SET @sql='              
 INSERT INTO '+@remote_db+'tbl_status(refno,upload_date,PartnerAgentCode,update_for,column_name,column_value,userid,remarks,partner_sno)              
 select refno,upload_date,PartnerAgentCode,update_for,column_name,column_value,userid,remarks,sno from tbl_status where          
 refno='''+@refno +''' and status=''Pending'' and update_for='''+@update_for+''''          
 print (@sql)              
 exec (@sql)          
 update tbl_status set status='Done' where refno=@refno and status='Pending' and update_for=@update_for          
end              
if @flag='c'              
begin              
set @update_for='Cancel'              
 insert into tbl_status(refno,upload_date,PartnerAgentCode,update_for,column_name,column_value,userid,remarks,status)              
 select @refno,getdate(),@PartnerAgentCode,'Cancel',@column_name,@column_value,@userid,@remarks,'Pending'              
              
 SET @sql='              
 INSERT INTO '+@remote_db+'tbl_status(refno,upload_date,PartnerAgentCode,update_for,column_name,column_value,userid,remarks,partner_sno)              
 select refno,upload_date,PartnerAgentCode,update_for,column_name,column_value,userid,remarks,sno from tbl_status with(nolock) where           
 refno='''+@refno +''' and status=''Pending'' and update_for='''+@update_for+''''          
 print (@sql)              
 exec (@sql)          
 update tbl_status set status='Done' where refno=@refno and status='Pending' and update_for=@update_for          
end              
            
if @flag='i'              
begin              
if exists(select sno from tbl_status WHERE status IS NULL)          
begin              
          print 'i'      
              
 create table #temp_cancel(status varchar(50),remarks varchar(100))              
              
 declare @sno int,@status varchar(50),@partner_sno int              
               
 DECLARE Partner_Stat CURSOR  FORWARD_ONLY READ_ONLY FOR              
              
 SELECT sno,refno,update_for,column_name,column_Value,userid,remarks,partner_sno,status,gmt_get_date,Dig_INFO          
 FROM tbl_status with(nolock) WHERE status is null order by sno          
 OPEN Partner_Stat              
 FETCH NEXT FROM Partner_Stat into @sno,@refno,@update_for,@column_name,@column_Value,@userid,@remarks,@partner_sno,@status,@gmt_get_date,@Dig_INFO              
 WHILE @@FETCH_STATUS = 0              
 BEGIN              
             
--Tickets              
  if @update_for = 'tickets' and LTRIM(RTRIM(@column_name))<>'' and  @column_name  is not null              
  begin              
                  
   exec('update moneysend set '+@column_name+' = '''+@column_Value+''' where refno='''+@refno+'''')              
              
  end              
              
  if @update_for = 'tickets' and LTRIM(RTRIM(@column_name))=''   or @column_name  is null           
  begin              
   INSERT INTO TransactionNotes(refno,Comments,DatePosted,PostedBy,uploadBy,noteType,tranno)               
   select m.refno,remarks, getdate(),'R:'+userid,'A','1',tranno from moneysend m with(nolock) join tbl_status s with(nolock) on m.refno=s.refno              
   where update_for='tickets' and sno=@sno              
  end              
  if @update_for='Cancel'               
  begin              
  set @sql='spa_cancel_transaction '''+@refno+''',''R:'+@userid+''','              
   if @gmt_get_date is null              
    set @sql=@sql+'NULL,'              
   else              
    set @sql=@sql + ' '''+ @gmt_get_date+''','              
   set @sql=@sql+'''Payment'','              
   if @remarks is null              
    set @sql=@sql+'NULL,'              
   else              
    set @sql=@sql + ' '''+ @remarks+''','           
   if @DIG_INFO is null              
    set @sql=@sql+'NULL'              
   else              
    set @sql=@sql + ' '''+ @DIG_INFO+''''              
    set @sql=@sql +',''y'''              
   exec ('insert #temp_cancel(status,remarks)               
   exec '+@sql)              
   print ('insert #temp_cancel(status,remarks) '+@sql)             
  END              
--Cancel              
  if @update_for='Block'              
  begin              
   UPDATE moneysend set transStatus='Block',lock_dot=getdate(),              
   lock_by= 'R:'+@userid where refno=@refno          
              
   INSERT INTO TransactionNotes                
   (refno,Comments,DatePosted,PostedBy,uploadBy,noteType,tranno)               
   select m.refno,remarks,getdate(),'R:'+userid,'A','1',tranno from moneysend m WITH (NOLOCK) join tbl_status s on m.refno=s.refno              
   where update_for='Block' and sno=@sno          
  END              
                
  if @update_for='Un-Block'              
  begin              
   UPDATE moneysend set transStatus='Payment',lock_dot=getdate(),              
   lock_by= 'R:'+@userid where refno=@refno          
              
   INSERT INTO TransactionNotes                
   (refno,Comments,DatePosted,PostedBy,uploadBy,noteType,tranno)               
   select m.refno,remarks,getdate(),'R:'+userid,'A','1',tranno from moneysend m WITH (NOLOCK) join tbl_status s on m.refno=s.refno              
   where update_for='Un-Block' and sno=@sno              
  END              
  delete tbl_status where sno=@sno          
              
              
  FETCH NEXT FROM Partner_Stat into @sno,@refno,@update_for,@column_name,@column_Value,@userid,@remarks,@partner_sno,@status,@gmt_get_date,@Dig_INFO              
 end              
 close Partner_Stat              
 deallocate Partner_Stat              
drop table #temp_cancel              
END              
              
END               
--DELETE tbl_status WHERE status='pending' 