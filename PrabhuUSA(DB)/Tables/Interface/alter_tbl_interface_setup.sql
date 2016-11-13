
-- =============================================
-- Author:  Sunita Shrestha
-- Create date: 18th february 2014
-- Purpose: add column into table tbl_interface_setup
-- =============================================

ALTER TABLE tbl_interface_setup ADD createdTS [datetime],updateTS  [datetime],createdBY [varchar](50),updateBY [varchar](50)


ALTER TABLE tbl_interface_setup ADD PayoutCountry varchar(100)