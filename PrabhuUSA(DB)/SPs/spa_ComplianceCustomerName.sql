--spa_ComplianceCustomerName 'Anoop Sherchan'
--alter table customer_trans_limit add customer_Name varchar(50)
--alter table customer_trans_limit_extended add customer_Name varchar(50)
--alter table customer_trans_limit add customer_Name varchar(50)

create PROC spa_ComplianceCustomerName
@customer_name VARCHAR(100)
AS
SELECT * FROM (
SELECT ISNULL(c.senderName,e.customer_Name) customer_Name,e.paidAmt,trans_date,c.senderaddress,
isNULL(nos_of_txn,0) nos_of_txn,e.update_ts FROM customer_trans_limit_extended e 
LEFT OUTER JOIN dbo.customerDetail c 
ON e.customer_passport=c.sno
WHERE ISNULL(c.senderName,e.customer_Name)=@customer_name 
UNION all
SELECT ISNULL(c.senderName,e.customer_Name) customer_Name,e.paidAmt,trans_date,c.senderaddress,
isNULL(nos_of_txn,0) nos_of_txn,e.update_ts FROM customer_trans_limit e 
LEFT OUTER JOIN dbo.customerDetail c 
ON e.customer_passport=c.sno
WHERE ISNULL(c.senderName,e.customer_Name)=@customer_name 
) r
order by r.update_ts 

