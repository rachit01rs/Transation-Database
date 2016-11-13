------example of reportwriter--------------------------------------------------------------------------------
DECLARE @drill1 VARCHAR(50),@main_report_id VARCHAR(50)
IF NOT EXISTS(SELECT 'X' FROM report_writer_header WHERE report_name='Search By Amount Summary')
BEGIN
	INSERT INTO dbo.report_writer_header (report_name, vw_sql, calc_total, main_menu, enable_paging, main_menu_agent)
	VALUES ('Search By Amount Summary', 'spa_rw_HubReport @agentId, @expected_payoutAgentId, @fromDate, @toDate, @viewLessThenAmount', NULL, NULL, NULL, NULL)
	SET @drill1=@@IDENTITY
END
ELSE
	SELECT @drill1=report_id FROM report_writer_header WHERE report_name='Search By Amount Summary'

INSERT INTO dbo.report_writer_clm (report_id, clm_name_id, clm_label, clm_type, clm_source, clm_sequence, null_allow)
VALUES (@drill1, '@agentId', 'Sender Agent', 'Combo', 'SELECT NULL VALUE,''[ ALL ]'' LEBEL  UNION ALL  select distinct agentCode,companyname from agentDetail with(nolock) where   agenttype in(''Send and Pay'' ,''Sender Agent'') and accessed=''Granted''', NULL, NULL)

INSERT INTO dbo.report_writer_clm (report_id, clm_name_id, clm_label, clm_type, clm_source, clm_sequence, null_allow)
VALUES (@drill1, '@expected_payoutAgentId', 'Receiver Agent', 'Combo', 'SELECT agentCode,CompanyName from AgentDetail with(nolock) where AgentCan in (''Receiver'',''NONE'',''BOTH'') order by CompanyName', NULL, NULL)

INSERT INTO dbo.report_writer_clm (report_id, clm_name_id, clm_label, clm_type, clm_source, clm_sequence, null_allow)
VALUES (@drill1, '@fromDate', 'From Date','Date','', NULL, NULL)

INSERT INTO dbo.report_writer_clm (report_id, clm_name_id, clm_label, clm_type, clm_source, clm_sequence, null_allow)
VALUES (@drill1, '@toDate', 'To Date', 'Date', '', NULL, NULL)

INSERT INTO dbo.report_writer_clm (report_id, clm_name_id, clm_label, clm_type, clm_source, clm_sequence, null_allow)
VALUES (@drill1, '@viewLessThenAmount', 'Filter Transaction By', 'Combo', 'Select ''Y'' value, ''[ View ALL ]'' label  Union All  Select NULL value,''[View Less then 100 USD]'' label', NULL, NULL)

INSERT INTO dbo.report_writer_clm (report_id, clm_name_id, clm_label, clm_type, clm_source, clm_sequence, null_allow)
VALUES (@drill1, 'TOTAL NO. OF TRANACTION', 'Total', 'Total', NULL, NULL, NULL)

INSERT INTO dbo.report_writer_clm (report_id, clm_name_id, clm_label, clm_type, clm_source, clm_sequence, null_allow)
VALUES (@drill1, 'USD Amount BY Payout Rate', 'Total', 'Total', NULL, NULL, NULL)

SELECT @drill1