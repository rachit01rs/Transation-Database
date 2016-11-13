alter table customerDetail add allow_web_online char(1),SenderZipCode varchar(50),
IMEI_Code varchar(150),PaymentRoutingNumber varchar(50),
PaymentAccountNumber varchar(50),PaymentAccountType varchar(50),eWallet Money,
employmentType varchar(50),gender varchar(50),sender_occupation_other varchar(100),
source_of_income_other varchar(50)

alter table customerDetail add ONlineVerificationDeposit1 Money,ONlineVerificationDeposit2 Money,
onlineVerifyDate datetime,onlineVerifyUser varchar(50)
alter table customerDetail alter column approve_ts datetime
alter table customerDetail add lock_date datetime

alter table customerDetail add id_place_of_issue varchar(100)
alter table customerDetail add approve_by varchar(50),password varchar(50)
alter table customerReceiverDetail 
add commercial_bank_id int,commercial_bank_branch_id int

add receivingbank varchar(50),branch_MIRC varchar(50),bank_name varchar(100),
branch_name varchar(50),accountno varchar(50)

alter table customerReceiverDetail 
add bankbranch varchar(50)


alter table agentbranchdetail 
add branch_voucher_prefix varchar(10),
branch_voucher_seq int

alter table agentdetail add mileage_points_per_txn float

alter table moneysend add 
employmentType varchar(50),gender varchar(50),customerType varchar(50),id_place_of_issue varchar(50),
relation_other varchar(100),source_of_income_other varchar(100),sender_occupation_other varchar(50),
ben_bank_branch_extid varchar(50),premium_rate float,receiver_sno int,SenderZipCode varchar(50),
PaymentRoutingNumber varchar(50),
PaymentAccountNumber varchar(50),PaymentAccountType varchar(50)

select * from moneysend where ben_bank_branch_id is not null
select * from commercial_bank_branch

select * from customerDetail