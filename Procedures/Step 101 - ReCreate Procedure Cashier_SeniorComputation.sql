ALTER PROCEDURE [dbo].[Cashier_SeniorComputation]
	@value money,
	@variable varchar(20),
	@cons decimal,
	@CustId int = 0
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    DECLARE @RateId int
    DECLARE @ZoneId int
	DECLARE @ArrearsDiscount DECIMAL(18, 2)

    IF @CustId IS NOT NULL or @CustId <> 0
    BEGIN
        SELECT @RateId = [RateId], @ZoneId = [ZoneId] FROM [Cust] WHERE CustId = @CustId

    END
    ELSE
    BEGIN
        SET @RateId = isnull((Select RateId from Rates where RateCd = 'R1'),1)
        SET @ZoneId = isnull((Select ZoneId from Zones where ZoneNo = '9201'),1)
    END

    IF @variable = 'subtot1'
    BEGIN
        DECLARE @NBasicTable TABLE([nbasic] DECIMAL(18, 2))
        DECLARE @NBasicValue DECIMAL(18, 2)
        
        IF(@cons > 30)
        BEGIN
            INSERT @NBasicTable VALUES(0)
        END
        ELSE
        BEGIN
            INSERT @NBasicTable exec sp_NBASICupd @RateId, @ZoneId, @cons
        END
        
        BEGIN
            SELECT @NBasicValue = [nbasic] FROM @NBasicTable
            SELECT value = (@NBasicValue / vat) * discount, destination, description, nid FROM cashier_discount
            WHERE variable = @variable AND description LIKE '%Senior Discount%';
        END
    END
    ELSE
    BEGIN
        IF @variable = 'subtot2'
        BEGIN

            IF @cons <= 30
            BEGIN
				--------------------------------------------------------------------------------------------------------------------------------
				-- || Old Code of Arrears Senior Computation -----------------------------------------------------------------------------------
				/*
                SELECT value = (@value / vat) * discount, destination, description, nid from cashier_discount
                WHERE variable = @variable AND description LIKE '%Senior Discount%';
				*/
				--------------------------------------------------------------------------------------------------------------------------------

				--------------------------------------------------------------------------------------------------------------------------------
				-- || Mew Code of Arrears Senior Computation -----------------------------------------------------------------------------------
				SET @ArrearsDiscount =
				(
					SELECT
						SUM([Remaining]) - SUM([SeniorDiscount])
					FROM
						[fn_ComputeSeniorBalance](@CustId)
					WHERE
						[BillDate] != LEFT(CONVERT(VARCHAR(10), GETDATE(), 111), 7)
				)

				SELECT value = @ArrearsDiscount, destination, description, nid FROM cashier_discount
				WHERE variable = @variable AND description LIKE '%Senior Discount%';
				--------------------------------------------------------------------------------------------------------------------------------
            END
            ELSE
            BEGIN
                SELECT value = 0,destination, description, nid FROM cashier_discount
                WHERE variable = @variable AND description LIKE '%Senior Discount%';
            END
        END
        ELSE
        BEGIN
            SELECT value = 0,destination, description, nid FROM cashier_discount
            WHERE variable = @variable AND description LIKE '%Senior Discount%';
        END
    END
END
