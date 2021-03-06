drop procedure [dbo].[spa_branch_detail]

GO

CREATE procedure [dbo].[spa_branch_detail]    
 @flag char(1),    
 @agent_branch_Code varchar(200)=NULL,    
 @agentCode varchar(50)=NULL,    
 @Branch varchar(500)=NULL,    
 @Address varchar(100)=NULL,    
 @City varchar(50)=NULL,    
 @Country varchar(50)=NULL,    
 @email varchar(100)=NULL,    
 @contactPerson varchar(50)=NULL,    
 @Telephone varchar(50)=NULL,    
 @Fax varchar(50)=NULL,    
 @TransferType varchar(50)=NULL,    
 @branchCodeChar varchar(50)=NULL,    
 @district_code varchar(50)=NULL,    
 @block_branch char(1)=NULL,    
 @bank_id int=NULL,    
 @branch_name varchar(100)=NULL,    
 @account_no varchar(50)=NULL,    
 @letter_head varchar(500)=NULL,    
 @currentBalance money=NULL,    
 @currentCommission money=NULL,    
 @branch_bank_code int=NULL ,    
 @created_by varchar(50)=NULL,    
 @created_ts datetime=NULL,    
 @updated_by varchar(50)=NULL,    
 @updated_ts datetime=NULL,    
 @agent_code_id varchar(50)=NULL,    
 @isHeadOffice char(1)=NULL,    
 @start_working_hour int=NULL,    
 @end_working_hour int=NULL ,    
 @view_report_only char(1)=NULL ,    
 @comm_main_branch_id varchar(50)=NULL,    
 @urban_nonurban char(1)=NULL ,    
 @branchcan varchar(50)=NULL,    
 @paymentRights char(1)=NULL,    
 @creditLimit money=NULL ,    
 @limitPtran money=NULL ,    
 @send_to_all_location char(1)=NULL,    
 @account_holder_name varchar(50)=NULL,    
 @branch_type_id int=NULL ,    
 @company_name varchar(50)=NULL,    
 @is_test_branch char(1)=NULL,    
 @ext_branch_code varchar(50)=NULL,    
 @chk_create_comission CHAR(1)=NULL,    
 @payout_overlimit money =NULL,    
 @Allow_CashPay char(1) =NULL,    
 @Branch_Type varchar(50)=null,    
 @Branch_group varchar(150)=null,
 @state_branch varchar(50)=NULL,
 @compliance_plus CHAR(1)=NULL   
AS    
declare @audit_record int    
select @audit_record=audit_record_no from tbl_setup WITH(NOLOCK)    
    
declare @sql varchar(2000)    
 DECLARE @COM_BRANCH_ID VARCHAR(50),@HEADoFFICE_COMM_ID VARCHAR(50),@ho_country varchar(100),    
   @ho_agent_id varchar(50)    
if @flag='i'    
begin    
 if @Country is null     
  select @Country=country from agentdetail WITH(NOLOCK) where agentcode=@agentCode    
    
 SELECT @agent_branch_Code=MAX(agent_branch_Code)+1 FROM agentbranchdetail WITH(NOLOCK)    
 if @agent_branch_Code is null    
  set @agent_branch_Code='30100000'    
   Insert into agentbranchdetail     
   (agent_branch_Code,    
    agentCode    
   ,Branch     
   ,Address     
   ,City     
   ,Country     
   ,email     
   ,contactPerson    
   ,Telephone    
   ,Fax    
   ,TransferType     
   ,BranchCodeChar    
   ,district_code    
   ,bank_id    
   ,branch_name    
   ,account_no    
   ,letter_head    
   ,created_by    
   ,created_ts    
   ,agent_code_id    
   ,start_working_hour    
   ,end_working_hour    
   ,view_report_only    
   ,isHeadOffice    
   ,currentBalance    
   ,ext_branch_code    
   ,comm_main_branch_id    
   ,Allow_CashPay    
   ,creditLimit    
   ,limitPtran    
   ,Branch_Type    
   ,Branch_group
   ,state_branch
   ,is_compliancePlus    
)    
  Values     
  ( @agent_branch_Code,    
    @agentCode,    
    @Branch,    
    @Address ,        
    @City ,    
    @Country,    
    @email,    
    @contactPerson,    
    @Telephone,    
    @Fax,       
    @TransferType,    
    @branchCodeChar,    
    @district_code,    
    @bank_id,     
    @branch_name,    
    @account_no,    
    @letter_head,    
    @created_by,    
    dbo.getDateHO(getutcdate()),    
    @agent_code_id ,    
    @start_working_hour,    
    @end_working_hour,    
    @view_report_only,    
    @isHeadOffice,    
    cast(isNULL(@currentBalance,0) as money),    
    @ext_branch_code,    
    @comm_main_branch_id,     
    @Allow_CashPay,    
    @creditLimit,     
    @limitPtran,    
    @Branch_Type,    
    @Branch_group,
	@state_branch,
    @compliance_plus        
     )    
      
 IF @chk_create_comission='y'    
  BEGIN    
       
   SELECT @COM_BRANCH_ID=MAX(agent_branch_Code)+1 FROM agentbranchdetail WITH(NOLOCK)    
      
   SELECT @HEADOFFICE_COMM_ID=HEADOFFICE_COMMISSION_ID,    
   @ho_country=headoffice_country,@ho_agent_id=isNull(headoffice_agent_id,@agentcode) FROM TBL_SETUP WITH(NOLOCK)   
    
   insert into agentBranchdetail(agent_branch_Code, agentCode, Branch, Address,     
   Country,currentBalance,created_by,created_ts,    
   updated_by,updated_ts,agent_code_id,comm_main_branch_id)    
   select @COM_BRANCH_ID,@HEADOFFICE_COMM_ID,    
   @branch+'- Comm', @Address,country,0,    
   @updated_by,dbo.getDateHO(getutcdate()),@updated_by,dbo.getDateHO(getutcdate()),    
   case when country=@ho_country then @ho_agent_id else agentcode end,     
   agent_branch_code from agentbranchdetail WITH(NOLOCK)     
   where agent_branch_code=@agent_branch_code    
  END    
    
end    
    
else if @flag='d'    
    
BEGIN    
 declare @total varchar(100),@branch_Code varchar(50)    
 set @branch_code=@agent_branch_Code    
 select @total=count(agent_user_id) from agentsub WITH(NOLOCK) where agent_branch_code=@branch_Code    
 if @total>0    
 begin    
   select 'Failed' status,'You must delete all users before deleting BRANCH (User found '+ @total +') !!' msg    
 end    
 ELSE if (select count(tranno) from moneysend WITH(NOLOCK) where rBankid=@branch_Code or branch_code=@branch_Code)>0    
 begin    
  select 'Failed' status,'You must delete all the TRANSACTION done by this Branch !!' msg    
 end    
 else if (select count(sno) from agentbalance WITH(NOLOCK) where branch_code=@branch_Code)>0    
	  begin    
	      
	  select 'Failed' status,'You must delete all the Voucher done by this Branch !!' msg    
	  end    
 ELSE if EXISTS (SELECT * FROM agentbranchdetail WITH(NOLOCK) WHERE comm_main_branch_id=@agent_branch_Code)    
	  begin    
	      
	  select 'Failed' status,'You must delete Commission Ledger first !!' msg    
	  end    
 else    
 BEGIN    
     
  delete  agentbranchdetail where agent_branch_code=@agent_branch_Code    
  select 'Success' status,'Successfully Deleted' msg    
 end    
end
    
else if @flag='s'    
     
begin    
declare @defaultCity varchar(50)    
set @defaultCity = (select top(1) city from agentbranchdetail WITH(NOLOCK) where agentcode=@agentcode)    
    
 if @City is null     
 begin    
	  Select @defaultCity [Default_City],b.*,a.agentCan,a.agentType from agentbranchdetail b WITH(NOLOCK)      
	  join agentdetail a WITH(NOLOCK)    
	  on a.agentcode=b.agentcode     
	  where a.agentcode=@agentcode order by branch_group,branch    
 end    
 else    
 begin    
	  if @city='-Blank-'    
		   Select b.*,a.agentCan,a.agentType from agentbranchdetail b  WITH(NOLOCK)    
		   join agentdetail a  WITH(NOLOCK)    
		   on a.agentcode=b.agentcode     
		   where a.agentcode=@agentcode and b.City is null order by branch_group,branch    
	  else    
		   Select b.*,a.agentCan,a.agentType from agentbranchdetail b  WITH(NOLOCK)    
		   join agentdetail a  WITH(NOLOCK)    
		   on a.agentcode=b.agentcode     
		   where a.agentcode=@agentcode and b.City= @City order by branch_group,branch    
	 end    
end    
    
else if @flag='a'    
 begin    
 select * from agentbranchdetail with(nolock) where agent_branch_code= @agent_branch_Code    
 end    
else if @flag='u'    
begin    
    
Update agentbranchdetail     
set     
	 branchCodeChar=@branchCodeChar    
	 ,branch=@branch    
	 ,address=@Address    
	 ,city=@City       
	 ,payout_overlimit=@payout_overlimit    
	 ,email=@email    
	 ,contactPerson=@contactPerson    
	 ,telephone=@telephone    
	 ,fax=@fax     
	 ,transferType=@transferType    
	 ,district_code=@district_code    
	 ,block_branch=@block_branch   ----- added later     
	 ,bank_id=@bank_id     
	 ,branch_name=@branch_name     
	 ,account_no=@account_no      
	 ,letter_head=@letter_head    
	 ,updated_by=@updated_by     
	 ,isHeadOffice=@isHeadOffice     
	 ,end_working_hour=@end_working_hour     
	 ,start_working_hour=@start_working_hour      
	 ,view_report_only =@view_report_only     
	 ,comm_main_branch_id=@comm_main_branch_id     
	 ,ext_branch_code=@ext_branch_code    
	 ,Allow_CashPay=@Allow_CashPay    
	 ,updated_ts=dbo.getDateHO(getutcdate())    
	 ,creditLimit=@creditLimit    
	 ,limitPtran=@limitPtran     
	 ,Branch_Type=@Branch_Type     
	 ,Branch_group=@Branch_group
	 ,state_branch=@state_branch
	 ,is_compliancePlus=@compliance_plus     
 	where agent_branch_code= @agent_branch_Code    
 IF @chk_create_comission='y'    
 BEGIN    
    
  SELECT @COM_BRANCH_ID=MAX(agent_branch_Code)+1 FROM agentbranchdetail with(nolock)    
     
  SELECT @HEADOFFICE_COMM_ID=HEADOFFICE_COMMISSION_ID,    
  @ho_country=headoffice_country,@ho_agent_id=isNull(headoffice_agent_id,@agentcode) FROM TBL_SETUP    
    
  insert into agentBranchdetail(agent_branch_Code, agentCode, Branch, Address,     
  Country,currentBalance,created_by,created_ts,    
  updated_by,updated_ts,agent_code_id,comm_main_branch_id)    
  select @COM_BRANCH_ID,@HEADOFFICE_COMM_ID,    
  @branch+'- Comm', @Address,country,0,    
  @updated_by,dbo.getDateHO(getutcdate()),@updated_by,dbo.getDateHO(getutcdate()),    
  case when country=@ho_country then @ho_agent_id else agentcode end,     
  agent_branch_code from agentbranchdetail     
  where agent_branch_code=@agent_branch_code    
 END    
end    
    
else if @flag='p'-- for audit report    
begin    
select top(@audit_record) * from agentbranchdetail_audit with(nolock) where agent_branch_Code=@agent_branch_Code order by updated_ts desc    
end    
    
else if @flag='q'    
begin    
select top(@audit_record)* from agentbranchdetail_audit with(nolock) where sno=@agent_branch_Code    
end    
    
else if @flag='c'--To Get Default City    
begin    
select top 1 city from agentbranchdetail with(nolock) where agentcode=@agentcode    
and city is not null and city <> ''    
 order by city     
    
end 