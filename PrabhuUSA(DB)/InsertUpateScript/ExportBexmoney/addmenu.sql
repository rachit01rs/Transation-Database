select * from sender_function  ORDER BY sno desc
INSERT INTO sender_function( sno, function_name, [Description], link_file,main_menu)
SELECT MAX(sno)+1,'Export Txn Bexmoney','values export to .xls','export_xls/export2excelBexmoney.asp','HOPayment' 
FROM sender_function sf

SELECT  dbo.decryptDb(user_pwd),branchcodechar,* FROM agentsub a1 JOIN agentbranchdetail a2 ON a1.agent_branch_code=a2.agent_branch_Code
 WHERE User_login_Id='ranesh'
 UPDATE agentbranchdetail a1 JOIN agentsub a2 ON a1.agent_branch_Code=a2.agent_branch_code SET branchcodechar=NULL WHERE user_login_id='ranesh'	
 SELECT * FROM agentbranchdetail	
SELECT branchCodeChar FROM agentsub a1 JOIN agentbranchdetail a2 on a1.agent_branch_code=a2.agent_branch_Code									 