IF OBJECT_ID('update_slab_paidCommission_job') IS NOT NULL 
    DROP PROC update_slab_paidCommission_job
go
CREATE PROC update_slab_paidCommission_job
    @ditital_id_payout VARCHAR(200)
AS 
    DECLARE @refno VARCHAR(50)
    DECLARE db_cursor CURSOR
    FOR
        SELECT  m.refno
        FROM    moneysend m WITH ( NOLOCK )
                JOIN temp_trn_csv_pay t WITH ( NOLOCK ) ON m.refno = t.refno
        WHERE   status = 'Paid'
                AND m.expected_payoutAgentId = t.expected_payoutAgentId
                AND m.confirmDate IS NOT NULL
                AND m.test_trn IS NULL
                AND t.digital_id_payout = @ditital_id_payout
                  
      
    OPEN db_cursor   
    FETCH NEXT FROM db_cursor INTO @refno

    WHILE @@FETCH_STATUS = 0 
        BEGIN  
            EXEC update_slab_paidCommission @refno
            FETCH NEXT FROM db_cursor INTO @refno
        END   

    CLOSE db_cursor   
    DEALLOCATE db_cursor
    
    DELETE  temp_trn_csv_pay
    WHERE   digital_id_payout = @ditital_id_payout  