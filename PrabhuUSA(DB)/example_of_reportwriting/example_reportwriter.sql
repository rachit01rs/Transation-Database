


-------example of reportwriter--------------------------------------------------------------------------------

DECLARE @drill1 VARCHAR(50),@main_report_id VARCHAR(50)
INSERT INTO dbo.report_writer_header (report_name, vw_sql, calc_total, main_menu, enable_paging, main_menu_agent)
VALUES ('Drill1 Report', 'select  Branch,dbo.FNADrillRefno(''t'',tranno) Tranno,dbo.FNADrillRefno(''r'',dbo.decryptDB(refno)) Refno, ReceiverCOuntry, PaidAmt,PaidCTYpe,SCharge Fee,TotalRoundAmt,ReceiveCTYpe from moneysend where confirmDate between @fromDate and @toDate +'' 23:59:59''
and dbo.FNAIsNULL(@ReceiverCOuntry,ReceiverCOuntry)=isNull(@ReceiverCOuntry,''1'')  and dbo.FNAIsNULL(@branch_code,branch_code)=IsNUll(@branch_code,''1'')
order by ReceiverCOuntry', NULL, 'Report', 'y', NULL)
SET @drill1=@@IDENTITY


INSERT INTO dbo.report_writer_clm (report_id, clm_name_id, clm_label, clm_type, clm_source)
VALUES (@drill1, '@fromDate', 'Start From', 'Date', '')
INSERT INTO dbo.report_writer_clm (report_id, clm_name_id, clm_label, clm_type, clm_source)
VALUES (@drill1, '@toDate', 'To Date', 'Date', '')
INSERT INTO dbo.report_writer_clm (report_id, clm_name_id, clm_label, clm_type, clm_source)
VALUES (@drill1, 'PaidAmt', 'Total', 'Total', '')
INSERT INTO dbo.report_writer_clm (report_id, clm_name_id, clm_label, clm_type, clm_source)
VALUES (@drill1, 'Fee', 'Fee', 'Total', '')
INSERT INTO dbo.report_writer_clm (report_id, clm_name_id, clm_label, clm_type, clm_source)
VALUES (@drill1, 'ReceiverCOuntry', 'PaidAmt', 'SubTotal', '')
INSERT INTO dbo.report_writer_clm (report_id, clm_name_id, clm_label, clm_type, clm_source)
VALUES (@drill1, 'ReceiverCOuntry', 'Fee', 'SubTotal', '')
INSERT INTO dbo.report_writer_clm (report_id, clm_name_id, clm_label, clm_type, clm_source)
VALUES (@drill1, '@ReceiverCOuntry', 'Payout Country', 'Combo', 'select distinct country value,country from agentdetail')
INSERT INTO dbo.report_writer_clm (report_id, clm_name_id, clm_label, clm_type, clm_source)
VALUES (@drill1, '@branch_code', 'branch', 'Text', '')

INSERT INTO dbo.report_writer_header (report_name, vw_sql, calc_total, main_menu, enable_paging, main_menu_agent)
VALUES ('Country Summary', 'Select dbo.FNADrillReport(ReceiverCountry,'+@drill1+',''##FromDate=''+@fromDate+'';##toDate=''+@toDate+'';##ReceiverCountry=''+ReceiverCountry+'';##branch_code=''+isnull(@agent_branch_id,''null'')) ReceiverCountry,count(*) TXN, Sum(PaidAmt) PaidAMT,Sum(SCharge) FEE from MOneySend where confirmDate between @fromDate and @toDate +'' 23:59:59'' and dbo.FNAISNULL(@agent_branch_id,branch_code)=isNull(@agent_branch_id,''1'')
Group by ReceiverCountry', NULL, 'Report', NULL, NULL)
SET @main_report_id=@@IDENTITY

INSERT INTO dbo.report_writer_clm (report_id, clm_name_id, clm_label, clm_type, clm_source)
VALUES (@main_report_id, '@FromDate', 'From Date', 'Date', '')

INSERT INTO dbo.report_writer_clm (report_id, clm_name_id, clm_label, clm_type, clm_source)
VALUES (@main_report_id, '@ToDate', 'To Date', 'Date', '')
INSERT INTO dbo.report_writer_clm (report_id, clm_name_id, clm_label, clm_type, clm_source)
VALUES (@main_report_id, '@agent_branch_id', 'BranchCode', 'Combo', 'select agent_branch_code val,branch labl from agentbranchdetail ')








