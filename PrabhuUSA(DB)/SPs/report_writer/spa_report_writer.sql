

/*  
** Database    : PrabhuUSA
** Object      : spa_report_writer
** Purpose     : Create spa_report_writer
** Author      : Puja Ghaju 
** Date        : 12 September 2013  
*/ 


IF EXISTS (SELECT * FROM DBO.SYSOBJECTS WHERE ID = OBJECT_ID(N'[DBO].[spa_report_writer]') AND OBJECTPROPERTY(ID, N'ISPROCEDURE') = 1)
DROP PROCEDURE [DBO].[spa_report_writer]
  
GO 

CREATE proc [dbo].[spa_report_writer]        
@flag char(1),        
@report_id int=NULL,        
@report_name varchar(200)=NULL,        
@vw_sql varchar(max)=NULL,        
@calc_total char(1)=NULL,    
@main_menu VARCHAR(50)=NULL,    
@enable_paging CHAR(1)=NULL        
as      
declare @main_menu_agent varchar(50),@menu_type varchar(50),@static_value varchar(50)    
    
if @flag='i'         
begin        
    
select @menu_type=sno,@static_value=static_data from static_values where static_id=@main_menu    
if @menu_type='101'    
set @main_menu=@static_value    
else    
begin    
set @main_menu_agent=@static_value    
set @main_menu=null    
end     
     
 insert report_writer_header(report_name,vw_sql,calc_total,main_menu,enable_paging,main_menu_agent)        
 values(@report_name,@vw_sql,@calc_total,@main_menu,@enable_paging,@main_menu_agent)        
 set @report_id=@@identity        
 select @report_id as Report_ID        
end        
if @flag='a'        
begin        
    
 select report_id,[report_name]    
           ,[vw_sql]    
           ,[calc_total]    
           ,isNUll(sp.static_id,sa.static_id) [main_menu]    
           ,[enable_paging]    
           from report_writer_header h left outer join static_values sa    
           on h.main_menu=sa.static_data and sa.sno=101    
           left outer join static_values sp    
           on h.main_menu_agent=sp.static_data and sp.sno=102    
           where report_id=@report_id        
end        
if @flag='u'        
begin       
 select @menu_type=sno,@static_value=static_data from static_values where static_id=@main_menu    
 if @menu_type='101'    
 set @main_menu=@static_value    
 else    
 begin    
 set @main_menu_agent=@static_value    
 set @main_menu=null    
 end     
      
 update report_writer_header set report_name=@report_name, main_menu=@main_menu,       
 vw_sql=@vw_sql, calc_total=@calc_total,enable_paging=@enable_paging,main_menu_agent=@main_menu_agent where report_id=@report_id        
end        
if @flag='d'        
begin        
 delete report_writer_clm where report_id=@report_id        
 delete report_writer_header where report_id=@report_id        
 delete report_func_user where function_id=@report_id        
        
end        
        
        
        
     