ALTER PROCEDURE [dbo].[sp_add_waterdelivery]
    @CustId int,
    @DeliveryDate VARCHAR(10),
    @Volume DECIMAL(9, 2),
    @Username VARCHAR(50),
    @Type INT,
    @Delivery INT
AS
BEGIN
    --SET NOCOUNT ON
    
    DECLARE @BasicCharge MONEY
    DECLARE @Sign INT
    
    
        
    SELECT TOP 1
        @BasicCharge = ISNULL([BasicCharge], 0)
    FROM
        [waterdelivery_rates]
    WHERE
        [Unit] <= ABS(@Volume) AND [Type] = 0
    ORDER BY
        [Unit] DESC
        
        
    IF @Volume >= 0
    BEGIN
        SET @Sign = 1
    END
    ELSE
    BEGIN
        SET @Sign = -1
    END
        
        
    SET @BasicCharge = ISNULL(@BasicCharge, 0) * ABS(@Volume)
        
    INSERT [waterdelivery] ([custnum], [delivery_date], [volume], [username], [entry_date], [amount1], [amount2], [type], [unit])
    SELECT
        (Select custnum from cust where CustId = @CustId),
        @DeliveryDate,
        @Volume,
        @Username,
        GETDATE(),
        @BasicCharge,
        0,
        0,
        [Unit]
    FROM
        [waterdelivery_type]
    WHERE
        [Type] = 0
        
    IF(@BasicCharge > 0)
    BEGIN
	
        INSERT [cust_ledger] (CustId, [posting_date], [trans_date], [refnum], [ledger_type], [ledger_subtype], [transaction_type], [previous_reading], [reading], [consumption], [debit], [credit], [duedate], [remark], [username])
        VALUES
        (
            @CustId,
            GETDATE(),
            GETDATE(),
            '',
            'WATER DELIVERY',
            'Basic',
            1,
            NULL,
            NULL,
            @Volume,
            @BasicCharge,
            NULL,
            NULL,
            'Water Delivery Bill',
            @Username
        )
    END
    ELSE
    BEGIN
        IF(@BasicCharge < 0)
        BEGIN
            INSERT [cust_ledger] (CustId, [posting_date], [trans_date], [refnum], [ledger_type], [ledger_subtype], [transaction_type], [previous_reading], [reading], [consumption], [debit], [credit], [duedate], [remark], [username])
            VALUES
            (
                @CustId,
                GETDATE(),
                GETDATE(),
                '',
                'WATER DELIVERY',
                'Basic',
                4,
                NULL,
                NULL,
                @Volume,
                NULL,
                ABS(@BasicCharge),
                NULL,
                'Water Delivery Bill Rollback',
                @Username
            )
        END
    END
       
        
    SELECT 1
END
