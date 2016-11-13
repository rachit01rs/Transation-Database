DROP FUNCTION [dbo].[FNAGetServiceCharge_Branch]  
go    
--20100003  
--SELECT * FROM dbo.FNAGetServiceCharge(20100003,NULL,'201','cash pay',NULL,'Nepal',NULL)  
--superAgent_commission superAgent_commission_type  
CREATE FUNCTION [dbo].[FNAGetServiceCharge_Branch]  
    (  
  @send_agent_id varchar(50),    
  @payout_agent_id varchar(50),    
  @total_collected money,    
  @payment_type varchar(100),    
  @send_branch_id varchar(50)=null,    
  @payout_country varchar(100)=NULL ,  
  @payinAmount MONEY=NULL  
    )  
RETURNS @tempTable TABLE  
    (  
     Exc_STATUS    VARCHAR(50),  
  MSG      VARCHAR(100),  
  slab_id     INT,  
  min_amount    MONEY,  
  max_amount    MONEY,  
  service_charge   MONEY,  
  send_commission   MONEY,  
  paid_commission   MONEY,  
  superAgent_commission MONEY,  
  payinAmount    MONEY,  
  total_collected   MONEY  
    )  
AS   
BEGIN  
      
    if @total_collected  is NULL  or @total_collected=0    
 SET @total_collected=1    
  
DECLARE @mode varchar(50)     
DECLARE @tempTableAll TABLE (    
   slab_id int,    
   min_amount money,    
   max_amount money,    
   service_charge money,    
   send_commission money,    
   paid_commission MONEY,  
   superAgent_commission MONEY  
   )   
     
if @payout_agent_id is not null    
 SELECT @payout_country=country FROM agentdetail with (nolock) WHERE agentcode=@payout_agent_id    
  
IF exists(SELECT slab_id FROM service_charge_setup_branch   with (nolock)    
WHERE agent_id=@send_branch_id AND payout_agent_id=@payout_agent_id AND payment_type=@payment_type)    
SET @mode='agent_payment'    
    
if @mode IS null    
BEGIN     
 IF exists(SELECT slab_id FROM service_charge_setup_branch   with (nolock)    
 WHERE agent_id=@send_branch_id AND payout_agent_id=@payout_agent_id AND payment_type IS null)    
 SET @mode='agent_NULL'    
END     
if @mode IS null    
BEGIN     
IF exists(SELECT slab_id FROM service_charge_setup_branch   with (nolock)    
WHERE agent_id=@send_branch_id AND rec_Country=@payout_country AND payment_type=@payment_type)    
SET @mode='country_payment'    
END     
if @mode IS null    
BEGIN     
IF exists(SELECT slab_id FROM service_charge_setup_branch    with (nolock)   
WHERE agent_id=@send_branch_id AND rec_Country=@payout_country AND payment_type IS null)    
SET @mode='country_NULL'    
END     
IF @mode IS NULL  
BEGIN  
 INSERT INTO @tempTable(Exc_STATUS,MSG)    
 SELECT 'Error' Exc_STATUS,'Service Charge not define, Contact headoffice' MSG    
END  
 IF @payinAmount IS NULL  
 BEGIN  
 --##############Agent wise Rate and Payment Type MATCHED ###################    
 IF @mode IN ('agent_payment' ,'agent_NULL' )  
 BEGIN    
   if exists(select * from service_charge_setup_branch  with (nolock) where @total_collected between min_amount and max_amount    
   and agent_id=@send_branch_id and payout_agent_id=@payout_agent_id and @payment_type=  
   CASE WHEN @mode='agent_payment' THEN payment_type ELSE isNULL(payment_type,@payment_type) END)    
   BEGIN    
    INSERT  INTO @tempTable  
   (slab_id,  
   min_amount,  
   max_amount,  
   service_charge,  
   send_commission,  
   paid_commission,  
   superAgent_commission  
     )  
   SELECT slab_id,min_amount, max_amount,      
   case when service_charge_mode='p' then (@total_collected * service_charge_per)/100 else service_charge_flat end as Service_Charge,    
   isNUll(case when send_commission_type='p' then     
   ((case when service_charge_mode='p' then (@total_collected * service_charge_per)/100  else service_charge_flat end) * send_commission)/100    
   ELSE send_commission END,0) AS send_commission,    
   isNull(case when paid_commission_type='p' then     
   ((case when service_charge_mode='p' then (@total_collected * service_charge_per)/100  else service_charge_flat end) * paid_commission)/100    
   ELSE paid_commission END,0) AS paid_commission,  
--   isNull(case when superAgent_commission_type='p' then     
--   ((case when service_charge_mode='p' then (@total_collected * service_charge_per)/100  else service_charge_flat end) * superAgent_commission)/100    
--   ELSE superAgent_commission END,0)   
   0 AS superAgent_commission  
   FROM service_charge_setup_branch  with (nolock) WHERE @total_collected BETWEEN min_amount AND max_amount  
   AND agent_id=@send_branch_id AND payout_agent_id=@payout_agent_id AND @payment_type=  
   CASE WHEN @mode='agent_payment' THEN payment_type ELSE isNULL(payment_type,@payment_type) END  
   --isNULL(payment_type,@payment_type)=@payment_type  
   END   
   ELSE  
   BEGIN  
    INSERT INTO @tempTable(Exc_STATUS,MSG)    
   SELECT 'Error' Exc_STATUS,'Send Amount Exceeded Service Charge, Contact headoffice' MSG  
   END  
 END  
 IF @mode IN ('country_payment','country_Null')    
 BEGIN  
  if exists(select * from service_charge_setup_branch  with (nolock) where @total_collected between min_amount and max_amount    
   and agent_id=@send_branch_id AND rec_Country=@payout_country AND @payment_type=  
   CASE WHEN @mode='agent_payment' THEN payment_type ELSE isNULL(payment_type,@payment_type) END)    
   BEGIN    
    INSERT  INTO @tempTable  
   (slab_id,  
   min_amount,  
   max_amount,  
   service_charge,  
   send_commission,  
   paid_commission,  
   superAgent_commission  
     )  
   SELECT slab_id,min_amount, max_amount,      
   case when service_charge_mode='p' then (@total_collected * service_charge_per)/100 else service_charge_flat end as Service_Charge,    
   isNUll(case when send_commission_type='p' then     
   ((case when service_charge_mode='p' then (@total_collected * service_charge_per)/100  else service_charge_flat end) * send_commission)/100    
   ELSE send_commission END,0) AS send_commission,    
   isNull(case when paid_commission_type='p' then     
   ((case when service_charge_mode='p' then (@total_collected * service_charge_per)/100  else service_charge_flat end) * paid_commission)/100    
   ELSE paid_commission END,0) AS paid_commission,  
--   isNull(case when superAgent_commission_type='p' then     
--   ((case when service_charge_mode='p' then (@total_collected * service_charge_per)/100  else service_charge_flat end) * superAgent_commission)/100    
--   ELSE superAgent_commission END,0)  
   0 AS superAgent_commission  
   FROM service_charge_setup_branch  with (nolock) WHERE @total_collected BETWEEN min_amount AND max_amount  
   AND agent_id=@send_branch_id AND rec_Country=@payout_country AND @payment_type=  
   CASE WHEN @mode='agent_payment' THEN payment_type ELSE isNULL(payment_type,@payment_type) END  
   END   
   ELSE  
   BEGIN  
    INSERT INTO @tempTable(Exc_STATUS,MSG)    
   SELECT 'Error' Exc_STATUS,'Service Charge not setup for this Send Amount, Contact headoffice' MSG  
   END  
 END  
 END  
 ELSE  
 BEGIN  
 --##############Agent wise Rate and Payment Type MATCHED ###################    
 IF @mode IN ('agent_payment' ,'agent_NULL' )  
 BEGIN    
   if exists(select * from service_charge_setup_branch  with (nolock) where @payinAmount between min_amount and max_amount    
   and agent_id=@send_branch_id and payout_agent_id=@payout_agent_id and @payment_type=  
   CASE WHEN @mode='agent_payment' THEN payment_type ELSE isNULL(payment_type,@payment_type) END)    
   BEGIN    
    INSERT  INTO @tempTable  
   (slab_id,  
   min_amount,  
   max_amount,  
   service_charge,  
   send_commission,  
   paid_commission,  
   superAgent_commission,  
   total_collected  
     )  
   SELECT slab_id,min_amount, max_amount,      
   case when service_charge_mode='p' then (@payinAmount * service_charge_per)/100 else service_charge_flat end as Service_Charge,    
   isNUll(case when send_commission_type='p' then     
   ((case when service_charge_mode='p' then (@payinAmount * service_charge_per)/100  else service_charge_flat end) * send_commission)/100    
   ELSE send_commission END,0) AS send_commission,    
   isNull(case when paid_commission_type='p' then     
   ((case when service_charge_mode='p' then (@payinAmount * service_charge_per)/100  else service_charge_flat end) * paid_commission)/100    
   ELSE paid_commission END,0) AS paid_commission,  
--   isNull(case when superAgent_commission_type='p' then     
--   ((case when service_charge_mode='p' then (@payinAmount * service_charge_per)/100  else service_charge_flat end) * superAgent_commission)/100    
--   ELSE superAgent_commission END,0)  
   0 AS superAgent_commission,  
   case when service_charge_mode='f' then @payinAmount + service_charge_flat  
   ELSE @payinAmount*100/(100-service_charge_per) END total_collected  
   FROM service_charge_setup_branch  with (nolock) WHERE @payinAmount BETWEEN min_amount AND max_amount  
   AND agent_id=@send_branch_id AND payout_agent_id=@payout_agent_id AND @payment_type=  
   CASE WHEN @mode='agent_payment' THEN payment_type ELSE isNULL(payment_type,@payment_type) END  
   --isNULL(payment_type,@payment_type)=@payment_type  
   END   
   ELSE  
   BEGIN  
    INSERT INTO @tempTable(Exc_STATUS,MSG)    
   SELECT 'Error' Exc_STATUS,'Send Amount Exceeded Service Charge, Contact headoffice' MSG  
   END  
 END  
 IF @mode IN ('country_payment','country_Null')    
 BEGIN  
  if exists(select * from service_charge_setup_branch  with (nolock) where @payinAmount between min_amount and max_amount    
   and agent_id=@send_branch_id AND rec_Country=@payout_country AND @payment_type=  
   CASE WHEN @mode='agent_payment' THEN payment_type ELSE isNULL(payment_type,@payment_type) END)    
   BEGIN    
    INSERT  INTO @tempTable  
   (slab_id,  
   min_amount,  
   max_amount,  
   service_charge,  
   send_commission,  
   paid_commission,  
   superAgent_commission,  
   total_collected  
     )  
   SELECT slab_id,min_amount, max_amount,      
   case when service_charge_mode='p' then (@payinAmount * service_charge_per)/100 else service_charge_flat end as Service_Charge,    
   isNUll(case when send_commission_type='p' then     
   ((case when service_charge_mode='p' then (@payinAmount * service_charge_per)/100  else service_charge_flat end) * send_commission)/100    
   ELSE send_commission END,0) AS send_commission,    
   isNull(case when paid_commission_type='p' then     
   ((case when service_charge_mode='p' then (@payinAmount * service_charge_per)/100  else service_charge_flat end) * paid_commission)/100    
   ELSE paid_commission END,0) AS paid_commission,  
--   isNull(case when superAgent_commission_type='p' then     
--   ((case when service_charge_mode='p' then (@payinAmount * service_charge_per)/100  else service_charge_flat end) * superAgent_commission)/100    
--   ELSE superAgent_commission END,0)  
   0 AS superAgent_commission,  
   case when service_charge_mode='f' then @payinAmount + service_charge_flat  
   ELSE @payinAmount*100/(100-service_charge_per) END total_collected  
   FROM service_charge_setup_branch  with (nolock) WHERE @payinAmount BETWEEN min_amount AND max_amount  
   AND agent_id=@send_branch_id AND rec_Country=@payout_country AND @payment_type=  
   CASE WHEN @mode='agent_payment' THEN payment_type ELSE isNULL(payment_type,@payment_type) END  
   END   
   ELSE  
   BEGIN  
    INSERT INTO @tempTable(Exc_STATUS,MSG)    
   SELECT 'Error' Exc_STATUS,'Service Charge not setup for this Send Amount, Contact headoffice' MSG  
   END  
 END  
 END  
 RETURN     
END  