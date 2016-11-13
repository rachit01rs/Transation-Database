
GO

/****** Object:  StoredProcedure [dbo].[spa_PartnerCheck_for_Cancel_Remote]    Script Date: 04/11/2012 16:22:49 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spa_PartnerCheck_for_Cancel_Remote]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[spa_PartnerCheck_for_Cancel_Remote]
GO


GO

/****** Object:  StoredProcedure [dbo].[spa_PartnerCheck_for_Cancel_Remote]    Script Date: 04/11/2012 16:22:49 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


--spa_PartnerCheck_for_pay_Remote 'FNHFFMLNEEHE'
Create proc [dbo].[spa_PartnerCheck_for_Cancel_Remote]
 @refno varchar(50)    
as
 
select status,transstatus,lock_status from moneysend with (nolock) where refno=@refno
if exists(select tranno from moneysend where status ='Un-Paid' and TransStatus='Payement' and isNULL(lock_status,'unlocked')='unlocked')
begin
update moneysend set transStatus='Cancel Processing',lock_status='locked' where refno=@refno
end

GO


