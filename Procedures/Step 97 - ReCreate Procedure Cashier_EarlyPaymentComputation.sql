ALTER PROCEDURE [dbo].[Cashier_EarlyPaymentComputation]
	@value money,
	@variable varchar(20),
	@cons decimal,
	@CustId int
AS
BEGIN
    DECLARE @EarlyPayDisc VARCHAR(150)
    DECLARE @EarlyPayDiscComp VARCHAR(150)

    DECLARE @RateId int
    DECLARE @Senior DATETIME
    DECLARE @BillDate VARCHAR(7)
    DECLARE @DueDate VARCHAR(10)
	DECLARE @Arrears DECIMAL(18, 2)

    SET @EarlyPayDisc = (SELECT [VarValue] FROM [Variable] WHERE [VarName] = 'EarlyPayDisc')
    SET @EarlyPayDiscComp = (SELECT [VarValue] FROM [Variable] WHERE [VarName] = 'EarlyPayDiscComp')

    SET @RateId = (SELECT [RateId] FROM [Cust] WHERE CustId = @CustId)
    SET @Senior = (SELECT [SeniorDate] FROM [Cust] WHERE CustId = @CustId)
    SET @BillDate = (SELECT MAX([BillDate]) FROM [Rhist] WHERE CustId = @CustId)
    SET @DueDate = (SELECT [DueDate] FROM [Rhist] WHERE CustId = @CustId AND [BillDate] = @BillDate)

	SET @Arrears = (SELECT [Water Balance] FROM [vw_ledger] WHERE CustId = @CustId)
	SET @Arrears = ISNULL(@Arrears, 0)

    IF @EarlyPayDisc = '1'
    BEGIN
        IF (Exists(Select RateCd from Rates where RateId = @RateId and RateCd = 'R1'))
        BEGIN
            IF (@EarlyPayDiscComp = '1') OR (@EarlyPayDiscComp = '0' AND (@Senior IS NULL OR @Senior < GETDATE()))
            BEGIN
                IF ISDATE(@DueDate) = 1
                BEGIN
                    IF CONVERT(DATETIME, CONVERT(VARCHAR(10), GETDATE(), 111)) <= CONVERT(DATETIME, @DueDate)
                    BEGIN
						IF @Arrears <= 0
						BEGIN
							IF @variable = 'subtot1'
							BEGIN
								SELECT value = (@value / vat) * discount, destination, description, nid FROM cashier_discount
								WHERE variable = @variable AND description LIKE '%Early Payment Discount%';
							END
							ELSE
							BEGIN
								IF @variable = 'subtot3'
								BEGIN
									SELECT value = (@value / vat) * discount, destination, description, nid FROM cashier_discount
									WHERE variable = @variable AND description LIKE '%Early Payment Discount%';
								END
								ELSE
								BEGIN
									SELECT value = 0,destination, description, nid FROM cashier_discount
									WHERE variable = @variable AND description LIKE '%Early Payment Discount%';
								END
							END
						END
						ELSE
						BEGIN
							SELECT value = 0,destination, description, nid FROM cashier_discount
							WHERE variable = @variable AND description LIKE '%Early Payment Discount%';
						END
                    END
                    ELSE
                    BEGIN
                        SELECT value = 0,destination, description, nid FROM cashier_discount
                        WHERE variable = @variable AND description LIKE '%Early Payment Discount%';
                    END
                END
                ELSE
                BEGIN
					SELECT value = 0,destination, description, nid FROM cashier_discount
					WHERE variable = @variable AND description LIKE '%Early Payment Discount%';
					/*
					IF @variable = 'subtot2'
					BEGIN
						SELECT value = 1,destination, description, nid FROM cashier_discount
						WHERE variable = @variable AND description LIKE '%Early Payment Discount%';
					END
					ELSE
					BEGIN
						SELECT value = 0,destination, description, nid FROM cashier_discount
						WHERE variable = @variable AND description LIKE '%Early Payment Discount%';
					END*/
                END
            END
            ELSE
            BEGIN
                SELECT value = 0,destination, description, nid FROM cashier_discount
                WHERE variable = @variable AND description LIKE '%Early Payment Discount%';
            END
        END
        ELSE
        BEGIN
            SELECT value = 0,destination, description, nid FROM cashier_discount
            WHERE variable = @variable AND description LIKE '%Early Payment Discount%';
        END
    END
    ELSE
    BEGIN
        SELECT value = 0,destination, description, nid FROM cashier_discount
        WHERE variable = @variable AND description LIKE '%Early Payment Discount%';
    END
END

GO


