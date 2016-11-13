DROP  PROCEDURE [dbo].[spa_service_charge_setup]  
GO  
--spa_service_charge_setup 'a'  
CREATE  PROCEDURE [dbo].[spa_service_charge_setup]  
  @flag char(1),  
  @slab_id int=NULL,  
  @payment_type varchar(50)=NULL,  
  @agent_id varchar(50)=NULL,  
  @Rec_Country varchar(50)=NULL,  
  @payout_agent_id varchar(50)=NULL,  
  @min_amount money=NULL,  
  @max_amount money=NULL,  
  @service_charge_mode char(1)=NULL,  
  @service_charge_flat money=NULL,  
  @service_charge_per float=NULL,  
  @paid_commission money=NULL,  
  @paid_commission_type char(1)=NULL,  
  @send_commission money=NULL,  
  @send_commission_type char(1)=NULL,  
  @update_by varchar(50)=NULL  
    
AS  
  
if @flag='c'---Country wise   
begin  
if @rec_country is NULL  
begin  
SELECT distinct a.companyname agent_name,[Rec_Country],agent_id  
  FROM [dbo].[service_charge_setup] s JOIN agentdetail a ON a. agentcode=s.agent_id  
  where [agent_id]=@agent_id and [Rec_Country]is not null and [payout_agent_id] is null  
end  
else  
begin  
SELECT [slab_id]  
      ,Payment_type  
      ,[agent_id]  
      ,[Rec_Country]  
      ,[payout_agent_id]  
      ,[min_amount]  
      ,[max_amount]  
      ,[service_charge_mode]  
      ,isNULL([service_charge_flat],0) [service_charge_flat]  
      ,isNULL([service_charge_per],0) [service_charge_per]  
      ,isNULL([paid_commission],0) [paid_commission]  
      ,isNULL([paid_commission_type],'f') [paid_commission_type]  
      ,isNULL([send_commission],0) [send_commission]  
      ,isNULL([send_commission_type],'f') [send_commission_type]  
      ,[update_by]  
      ,[update_ts]  
  FROM [dbo].[service_charge_setup]  
 where [agent_id]=@agent_id and [Rec_Country]is not null and [payout_agent_id] is null  
AND [Rec_Country]=@Rec_Country  
 ORDER BY payment_type,min_amount  
  
end  
end  
if @flag='p'---payout agent wise   
begin  
if @payout_agent_id is NULL  
begin  
SELECT distinct a.companyname agent_name,pa.companyName Payout_agent,[payout_agent_id],agent_id  
  FROM [dbo].[service_charge_setup] s JOIN agentdetail a ON a. agentcode=s.agent_id  
 JOIN agentdetail pa ON pa.agentcode=s.[payout_agent_id]  
  where [agent_id]=@agent_id and [Rec_Country]is null and [payout_agent_id] is NOT null  
end  
else  
begin  
SELECT [slab_id]  
      ,[payment_type]  
      ,[agent_id]  
      ,pa.companyName Payout_agent  
      ,[payout_agent_id]  
      ,[min_amount]  
      ,[max_amount]  
      ,[service_charge_mode]  
      ,[service_charge_flat]  
      ,[service_charge_per]  
      ,[paid_commission]  
      ,[paid_commission_type]  
      ,[send_commission]  
      ,[send_commission_type]  
      ,[update_by]  
      ,[update_ts]  
  FROM [service_charge_setup] s JOIN agentdetail pa ON  pa.agentcode=s.payout_agent_id  
  where [agent_id]=@agent_id    
 AND [payout_agent_id]=@payout_agent_id  
 and [Rec_Country]is null and [payout_agent_id] is not NULL  
 ORDER BY payment_type,min_amount  
end  
end  
if @flag='s'  
begin  
SELECT [slab_id]  
      ,[payment_type]  
      ,[agent_id]  
      ,[Rec_Country]  
      ,[payout_agent_id]  
      ,[min_amount]  
      ,[max_amount]  
      ,[service_charge_mode]  
      ,[service_charge_flat]  
      ,[service_charge_per]  
      ,[paid_commission]  
      ,[paid_commission_type]  
      ,[send_commission]  
      ,[send_commission_type]  
      ,[update_by]  
      ,[update_ts]  
  FROM [dbo].[service_charge_setup] where slab_id=@slab_id  
end  
if @flag='a'  
begin  
SELECT [slab_id]  
      ,[payment_type]  
      ,[agent_id]  
   ,a.companyName [companyName]  
   ,a.country [Country]  
      ,isNULL([Rec_Country],pa.companyName) Payout_agent  
      ,[payout_agent_id]  
      ,[min_amount]  
      ,[max_amount]  
      ,[service_charge_mode]  
      ,[service_charge_flat]  
      ,[service_charge_per]  
      ,isNULL([paid_commission],0) [paid_commission]  
      ,[paid_commission_type]  
      ,isNULL([send_commission],0) [send_commission]  
      ,[send_commission_type]  
      ,[update_by]  
      ,[update_ts]  
  FROM [dbo].[service_charge_setup]  s left outer  JOIN agentdetail pa ON  pa.agentcode=s.payout_agent_id  
join agentdetail a on s.agent_id=a.agentcode   
order by a.country,a.companyName,payment_type,Rec_Country,payout_agent_id,min_amount  
  
end  
  
if @flag='i'  
  
begin  
 IF @Rec_Country IS NULL AND @payout_agent_id IS null  
 begin  
  select 'Error' status,'Country and Payout Agent Name can''t be Blank' msg  
  return  
 end  
   
 IF @Rec_Country IS NOT NULL  
  SET @payout_agent_id=NULL  
 ELSE  
  SET @Rec_Country=NULL  
  
 IF @service_charge_mode='f'   
  SET @service_charge_per=NULL  
 ELSE  
  SET @service_charge_flat=NULL  
  
 IF  @min_amount > @max_amount  
 begin  
  select 'Error' status,'The Max Amt. Should be greater than Min Amt' msg  
  return  
 end    
   
 IF (@payout_agent_id IS NOT NULL and @payment_type is not null)  
  BEGIN  
  Declare @maxamtpp money  
  set @maxamtpp=(select max([max_amount])from [service_charge_setup] where [agent_id]=@agent_id and [payment_type]=@payment_type AND [payout_agent_id]=@payout_agent_id)+0.01   
   IF @min_amount <> @maxamtpp  
   begin  
    select 'Error' status,'The Amount range is already defined, Please Redefine Min. Amt. from...'+cast(@maxamtpp as varchar)+'!!!' msg  
    return  
   end  
  END  
 IF (@payout_agent_id IS NOT NULL and @payment_type is null)  
  BEGIN  
  Declare @maxamtpn money  
  set @maxamtpn = (select max([max_amount])from [service_charge_setup] where [agent_id]=@agent_id and [payment_type]is null AND [payout_agent_id]=@payout_agent_id)+0.01  
  IF @min_amount <> @maxamtpn   
   begin  
    select 'Error' status,'The Amount range is already defined, Please Redefine Min. Amt. from...'+cast(@maxamtpn as varchar)+'!!!' msg  
    return  
   end  
  END  
  
 IF (@Rec_Country IS NOT NULL AND @payment_type is not null)  
  BEGIN  
  Declare @maxamtrp money  
  set @maxamtrp=(select max([max_amount])from [service_charge_setup] where [agent_id]=@agent_id and [payment_type]=@payment_type AND [Rec_Country]=@Rec_Country)+0.01  
  IF @min_amount <>@maxamtrp   
   begin  
    select 'Error' status,'The Amount range is already defined, Please Redefine Min. Amt. from...'+cast(@maxamtrp as varchar)+'!!!' msg  
    return  
   end  
  END  
  
 IF (@Rec_Country IS NOT NULL and @payment_type is null)  
  BEGIN  
  Declare @maxamtrn money  
  set @maxamtrn = (select max([max_amount])from [service_charge_setup] where [agent_id]=@agent_id and [payment_type]is null AND [Rec_Country]=@Rec_Country)+0.01  
  IF @min_amount <> @maxamtrn   
    begin  
     select 'Error' status,'The Amount range is already defined, Please Redefine Min. Amt. from...'+cast(@maxamtrn as varchar) +'!!!' msg  
     return  
    end  
  END  
  
 IF( exists  
  (select slab_id  
  from [dbo].[service_charge_setup]  
  where [payment_type]=@payment_type and [agent_id]=@agent_id   
  and [Rec_Country]=@Rec_Country and [min_amount]=@min_amount and [max_amount]=@max_amount  
  )  
   )  
  select 'Error' status,'Dublicate service type found' msg  
  
 else  
  begin  
  insert into [dbo].[service_charge_setup]  
   (  
      [payment_type]  
     ,[agent_id]  
     ,[Rec_Country]  
     ,[payout_agent_id]  
     ,[min_amount]  
     ,[max_amount]  
     ,[service_charge_mode]  
     ,[service_charge_flat]  
     ,[service_charge_per]  
     ,[paid_commission]  
     ,[paid_commission_type]  
     ,[send_commission]  
     ,[send_commission_type]  
     ,[update_by]  
     ,[update_ts]  
   )  
  values  
   (  
    @payment_type,  
    @agent_id,  
    @Rec_Country,  
    @payout_agent_id,  
    @min_amount,  
    @max_amount,  
    @service_charge_mode,  
    @service_charge_flat,  
    @service_charge_per,  
    @paid_commission,  
    @paid_commission_type,  
    @send_commission,  
    @send_commission_type,  
    @update_by,  
    dbo.getDateHO(getutcdate())  
  
   )  
   select 'Success' status,'Service Saved' msg  
     
  end  
end  
  
--select * from [service_charge_setup] where rec_country='Vietnam'  
  
IF @flag='u'  
BEGIN  
  IF @service_charge_mode='f'   
   SET @service_charge_per=NULL  
  ELSE  
   SET @service_charge_flat=NULL  
  
  IF  @min_amount > @max_amount  
   begin  
    select 'Error' status,'The Max Amt. Should be greater than Min Amt' msg  
    return  
   end   
  
  select @payment_type=payment_type from [service_charge_setup] where slab_id=@slab_id  
  
  IF (@Rec_Country IS NOT NULL and @payment_type is not null)  
  BEGIN  
  Declare @maxamtrpu money  
  set @maxamtrpu = (select max([max_amount])from [service_charge_setup]   
   where [slab_id ]< @slab_id and [payment_type]=@payment_type   
   and [agent_id]=@agent_id and [Rec_Country]=@Rec_Country)  
  Declare @minamtrpu money  
    
  set @minamtrpu = (select min([min_amount])from [service_charge_setup] where [slab_id ]> @slab_id and [payment_type]=@payment_type and [agent_id]=@agent_id and [Rec_Country]=@Rec_Country)  
  IF @min_amount <= @maxamtrpu  
    begin  
     select 'Error' status,'The Amount range is already defined, Please Redefine Min. Amt. Greater than'+cast(@maxamtrpu as varchar)+'!!!' msg  
     return  
    end  
  END    
  IF @max_amount >= @minamtrpu  
    begin  
     select 'Error' status,'The Amount range is already defined, Please Redefine Max. Amt. below'+cast(@minamtrpu as varchar)+'!!!' msg  
     return  
    end  
  
  
  IF (@Rec_Country IS NOT NULL and @payment_type is null)  
  BEGIN  
  Declare @maxamtrnu money  
  set @maxamtrnu = (select max([max_amount])from [service_charge_setup] where [slab_id ]< @slab_id and [agent_id]=@agent_id and [payment_type]is null AND [Rec_Country]=@Rec_Country)  
  Declare @minamtrnu money  
  set @minamtrnu = (select min([min_amount])from [service_charge_setup] where [slab_id ]> @slab_id and [agent_id]=@agent_id and [payment_type]is null AND [Rec_Country]=@Rec_Country)  
  IF @min_amount <= @maxamtrnu  
    begin  
     select 'Error' status,'The Amount range is already defined, Please Redefine Min. Amt. Greater than'+cast(@maxamtrnu as varchar)+'!!!' msg  
     return  
    end  
  END    
  IF @max_amount >= @minamtrnu  
    begin  
     select 'Error' status,'The Amount range is already defined, Please Redefine Max. Amt. below'+cast(@minamtrnu as varchar)+'!!!' msg  
     return  
    end  
  
  IF (@payout_agent_id IS NOT NULL and @payment_type is null)  
  BEGIN  
  Declare @maxamtpnu money  
  set @maxamtpnu = (select max([max_amount])from [service_charge_setup] where [slab_id ]< @slab_id and [agent_id]=@agent_id and [payment_type]is null AND [payout_agent_id]=@payout_agent_id)  
  Declare @minamtpnu money  
  set @minamtpnu = (select min([min_amount])from [service_charge_setup] where [slab_id ]> @slab_id and [agent_id]=@agent_id and [payment_type]is null AND [payout_agent_id]=@payout_agent_id)  
  IF @min_amount <= @maxamtpnu  
    begin  
     select 'Error' status,'The Amount range is already defined, Please Redefine Min. Amt. Greater than'+cast(@maxamtpnu as varchar)+'!!!' msg  
     return  
    end  
  END    
  IF @max_amount >= @minamtpnu  
    begin  
     select 'Error' status,'The Amount range is already defined, Please Redefine Max. Amt. below'+cast(@minamtpnu as varchar)+'!!!' msg  
     return  
    end  
  
  
  IF (@payout_agent_id IS NOT NULL and @payment_type is not null)  
  BEGIN  
  Declare @maxamtppu money  
  set @maxamtppu = (select max([max_amount])from [service_charge_setup] where [slab_id ]< @slab_id and [agent_id]=@agent_id and [payment_type]=@payment_type AND [payout_agent_id]=@payout_agent_id)  
  Declare @minamtppu money  
  set @minamtppu = (select min([min_amount])from [service_charge_setup] where [slab_id ]> @slab_id and [agent_id]=@agent_id and [payment_type]=@payment_type AND [payout_agent_id]=@payout_agent_id)  
  IF @min_amount <= @maxamtppu  
    begin  
     select 'Error' status,'The Amount range is already defined, Please Redefine Min. Amt. Greater than'+cast(@maxamtppu as varchar)+'!!!' msg  
     return  
    end  
  END    
  IF @max_amount >= @minamtppu  
    begin  
     select 'Error' status,'The Amount range is already defined, Please Redefine Max. Amt. below'+cast(@minamtppu as varchar)+'!!!' msg  
     return  
    end  
      
  
  
  
  
    
    
  
  
  
  
  
  
  
  
  IF(exists (select slab_id from [service_charge_setup]  
   where [payment_type]=@payment_type and [agent_id]=@agent_id   
   and [Rec_Country]=@Rec_Country and [min_amount]=@min_amount   
   and [max_amount]=@max_amount AND slab_id <> @slab_id  
   )  
    )  
   BEGIN  
    select 'Error' status,'Dublicate service type found' msg  
   END  
  
  ELSE  
   BEGIN  
  
    UPDATE [dbo].[service_charge_setup]  
    SET   [min_amount]=@min_amount  
       ,[max_amount]=@max_amount  
       ,[service_charge_mode]=@service_charge_mode  
       ,[service_charge_flat]=@service_charge_flat  
       ,[service_charge_per]=@service_charge_per  
       ,[paid_commission]=@paid_commission  
       ,[paid_commission_type]=@paid_commission_type  
       ,[send_commission]=@send_commission  
       ,[send_commission_type]=@send_commission_type  
       ,[update_by]=@update_by  
       ,[update_ts]=dbo.getDateHO(getutcdate())  
    where  
        [agent_id]=@agent_id AND [slab_id]=@slab_id   
    select 'Success' status,'Service Saved' msg     
   END  
END  
  
if @flag='d'  
begin  
   update [service_charge_setup] set update_by=@update_by where [slab_id]=@slab_id    
   
 delete from [dbo].[service_charge_setup] where [slab_id]=@slab_id  
 SELECT 'Success' status, 'Successfully Deleted' msg  
end  