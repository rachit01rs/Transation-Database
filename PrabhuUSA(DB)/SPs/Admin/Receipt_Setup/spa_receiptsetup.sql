/****** Object:  StoredProcedure [dbo].[spa_receiptsetup]    Script Date: 02/03/2013 11:23:07 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[spa_receiptsetup]        
@flag CHAR(1)=NULL,        
@sno VARCHAR(50)=NULL,        
@static_id VARCHAR(50)=NULL,        
@static_data VARCHAR(50)=NULL,        
@helpdesk_detail VARCHAR(MAX)=NULL ,      
@static_value VARCHAR(50)=NULL      
        
AS        
SET NOCOUNT ON;        
        
DECLARE @description VARCHAR(50)      
        
IF @sno='114'      
 SET @description='Agent Name'      
      
IF @flag='u'        
BEGIN        
 UPDATE static_values        
  SET helpdesk_detail=@helpdesk_detail        
 WHERE static_data=@static_data AND sno=@sno        
        
 --SELECT static_id, helpdesk_detail FROM static_values WHERE static_data=@static_data AND sno=@sno        
END        
IF @flag='s'        
BEGIN   
 IF EXISTS(SELECT 'x' FROM static_values WHERE static_data=@static_data AND sno=@sno AND helpdesk_detail IS NOT NULL)     
  BEGIN    
  SELECT static_id, helpdesk_detail FROM static_values WHERE static_data=@static_data AND sno=@sno  
  END    
      
 ELSE  
  BEGIN    
  IF @sno='99'  
   SET @static_data='Default_State'  
  IF @sno='4'  
   SET @static_data='Default' 
  IF @sno='114'  
   SET @static_data='Default_Agent' 
    
  SELECT static_id, helpdesk_detail FROM static_values WHERE static_data=@static_data AND sno='113'  
  END   
END        
IF @flag='c'  ---select payout country or Agent name      
BEGIN     
 IF @sno='4'   --For Country List  
  BEGIN  
  SELECT static_id, helpdesk_detail FROM static_values WHERE static_data=@static_data AND sno=@sno  
  END  
 ELSE  
 BEGIN  
  IF NOT EXISTS(SELECT 'x' FROM dbo.static_values WHERE sno=@sno AND static_data=@static_data)      
   BEGIN      
     INSERT INTO static_values      
   ( sno ,      
     static_value ,      
     static_data ,      
     Description ,      
     helpdesk_detail      
   )      
     VALUES    ( @sno ,      
     @static_value ,      
     @static_data ,      
     @description ,      
    @helpdesk_detail      
   )      
   END      
  SELECT static_id, helpdesk_detail FROM static_values WHERE static_data=@static_data AND sno=@sno  
 END      
END      
IF @flag='a'    --update payout country and agent name      
      
  BEGIN      
   UPDATE static_values      
   SET helpdesk_detail=@helpdesk_detail      
   WHERE sno=@sno AND static_data=@static_data      
  END      
        
--IF @flag='c'  ---select  Agent name      
--BEGIN        
-- IF NOT EXISTS(SELECT 'x' FROM dbo.static_values WHERE sno=@sno AND static_data=@static_data)      
-- BEGIN      
--   INSERT INTO static_values      
--    ( sno ,      
--      static_value ,      
--      static_data ,      
--      Description ,      
--      helpdesk_detail      
--    )      
--   VALUES    ( @sno ,      
--      @static_value ,      
--      @static_data ,      
--      'Payout Country' ,      
--     @helpdesk_detail      
--    )      
-- END      
-- SELECT static_id, helpdesk_detail FROM static_values WHERE static_data=@static_data AND sno=@sno      
--END
GO


