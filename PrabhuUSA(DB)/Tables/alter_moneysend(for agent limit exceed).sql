/*
Author: Paribesh Jung Karki
modification: adding three columns for agent limit exceed
*/


ALTER TABLE moneySend ADD  agent_limit_exceed CHAR(1)
ALTER TABLE cancelMoneySend ADD  agent_limit_exceed CHAR(1)
ALTER TABLE delMoneysend ADD  agent_limit_exceed CHAR(1)
ALTER TABLE moneysend_arch1 ADD  agent_limit_exceed CHAR(1)
ALTER TABLE moneysend_arch1_audit ADD  agent_limit_exceed CHAR(1)
ALTER TABLE moneysend_audit ADD  agent_limit_exceed CHAR(1)
ALTER TABLE customerDetail ADD  agent_limit_exceed CHAR(1)


ALTER TABLE moneySend ADD  released_ts datetime
ALTER TABLE cancelMoneySend ADD released_ts datetime
ALTER TABLE delMoneysend ADD  released_ts datetime
ALTER TABLE moneysend_arch1 ADD  released_ts datetime
ALTER TABLE moneysend_arch1_audit ADD  released_ts datetime
ALTER TABLE moneysend_audit ADD released_ts datetime
ALTER TABLE customerDetail ADD  released_ts datetime



ALTER TABLE moneySend ADD  releasedby varchar(50)
ALTER TABLE cancelMoneySend ADD releasedby varchar(50)
ALTER TABLE delMoneysend ADD releasedby varchar(50)
ALTER TABLE moneysend_arch1 ADD  releasedby varchar(50)
ALTER TABLE moneysend_arch1_audit ADD  releasedby varchar(50)
ALTER TABLE moneysend_audit ADD releasedby varchar(50)
ALTER TABLE customerDetail ADD  releasedby varchar(50)
