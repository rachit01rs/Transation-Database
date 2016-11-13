create PROC [dbo].[spa_APIcountry_Setup]            
@flag char(1),            
@sno int=null,            
@enable_send char(1)=null, 
@partnerAPI_code VARCHAR(50)=NULL,           
@ex_rate_margin float=null,            
@sCharge_margin float=null,            
@agent_comm float=null,            
@agent_comm_type varchar(2)=null,            
@update_by varchar(50)=null,            
@country varchar(200) =NULL,            
@city varchar(200) = NULL,            
@paymentType varchar(100)=NULL                 
AS            
--select all records            
DECLARE @idoc INT        
DECLARE @doc varchar(1000)            
            
if @flag='s'            
BEGIN            
 declare @sql varchar(500),@slab_enable char(1)            
             
 set @sql='select * from API_Country_setup '  
 set @sql=@sql+' where API_agent='''+@partnerAPI_code+''''  
 if @enable_send ='y'               
  set @sql=@sql+' and enable_send='''+@enable_send+''''                
  if @enable_send is null                
  set @sql=@sql+' and enable_send is null'            
           
           
             
 set @sql=@sql+' order by country asc'            
--print @sql            
--return            
exec(@sql)            
END            
---update             
if @flag='u'            
BEGIN            
  UPDATE API_Country_setup            
   set enable_send=@enable_send,          
 ex_rate_margin=@ex_rate_margin,  
 sCharge_margin=@sCharge_margin,  
 update_by=@update_by,  
 update_ts=getdate()      
 where sno=@sno            
             
END 