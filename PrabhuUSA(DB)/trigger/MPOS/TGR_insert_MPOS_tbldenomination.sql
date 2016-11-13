-- ================================================
-- Template generated from Template Explorer using:
-- Create Trigger (New Menu).SQL
--
-- Use the Specify Values for Template Parameters 
-- command (Ctrl-Shift-M) to fill in the parameter 
-- values below.
--
-- See additional Create Trigger templates for more
-- examples of different Trigger statements.
--
-- This block of comments will not be included in
-- the definition of the function.

-- ================================================
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE TRIGGER TGR_INSERT_MPOS_tbldenomination ON dbo.MPOS_tbldenomination
 FOR INSERT
AS 
BEGIN
	SET NOCOUNT ON;

INSERT INTO dbo.MPOS_tbldenomination_audit
        ( MPOS_tbldenomination_sno ,
          receiving_country ,
          payout_amount ,
          total_charge ,
          gross_sending_amount ,
          agent_commission ,
          payout_currency ,
          sending_country ,
          sending_currency,
          operator_sno ,
          updated_by ,
          updated_ts ,
          user_action
        )
SELECT sno ,
          receiving_country ,
          payout_amount ,
          total_charge ,
          gross_sending_amount ,
          agent_commission ,
          payout_currency ,
          sending_country ,
          sending_currency,
          operator_sno ,
          updated_by ,
          GETDATE() ,
          'INSERT'
          FROM INSERTED
END
GO
