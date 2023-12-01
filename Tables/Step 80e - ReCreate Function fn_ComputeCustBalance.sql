ALTER FUNCTION [dbo].[fn_ComputeCustBalance]
(
	@CustId int,
	@BillDate VARCHAR(7),
	@IncludeBalanceColumn BIT,
	@IncludeAdjustmentColumn BIT,
	@IncludePromisorryColumn BIT
)
RETURNS @CustBalance TABLE
(
	-- || Reading Column -----------------------------------------------------------------------------------------------------------


	[HasRead] BIT,
	[ReadRate] VARCHAR(8),
	[ReadDate] VARCHAR(10),
	[ReadPrevious] DECIMAL(18, 2),
	[ReadCurrent] DECIMAL(18, 2),
	[ReadConsumption] DECIMAL(18, 2),
	[ReadBasicCharge] DECIMAL(18, 4),
	[ReadDueDate] VARCHAR(10),
	[ReadArrears] DECIMAL(18, 2),
	[ReadSeptage] DECIMAL(18, 4),

	-- || Bill Column --------------------------------------------------------------------------------------------------------------

	[HasBill] BIT,
	[BillNum] INT,
	[BillCurrent] DECIMAL(18, 2),
	[BillDiscount] DECIMAL(18, 2),
	[BillSeptage] DECIMAL(18, 2),
	[BillArrears] DECIMAL(18, 2),
	[BillMeterCharge] DECIMAL(18, 2),
	[BillPenaltyCurrent] DECIMAL(18, 2),
	[BillPenaltyArrears] DECIMAL(18, 2),

	-- || Senior Column-------------------------------------------------------------------------------------------------------------

	[SeniorDiscountComputed] DECIMAL(18, 2),
	[SeniorDiscountActual] DECIMAL(18, 2),

	-- || Balance Column -----------------------------------------------------------------------------------------------------------

	[BalancePenalty] DECIMAL(18, 2),
	[BalanceOldArrears] DECIMAL(18, 2),
	[BalanceMeterCharge] DECIMAL(18, 2),
	[BalanceSeptage] DECIMAL(18, 2),

	-- || Adjustment Column --------------------------------------------------------------------------------------------------------

	[AdjustmentWater] DECIMAL(18, 2),
	[AdjustmentSeptage] DECIMAL(18, 2),
	[AdjustmentMeterCharge] DECIMAL(18, 2),
	[AdjustmentPenalty] DECIMAL(18, 2),

	-- || Payment Column -----------------------------------------------------------------------------------------------------------

	[HasPayment] BIT,
	[PaymentCurrent] DECIMAL(18, 2),
	[PaymentArrears] DECIMAL(18, 2),
	[PaymentAdvanced] DECIMAL(18, 2),
	[PaymentMeterCharge] DECIMAL(18, 2),
	[PaymentPenalty] DECIMAL(18, 2),
	[PaymentOldArrears] DECIMAL(18, 2),
	[PaymentDiscountTotal] DECIMAL(18, 2),
	[PaymentDiscountCurrent] DECIMAL(18, 2),
	[PaymentDiscountArrears] DECIMAL(18, 2),
	[PaymentSeptageCurrent] DECIMAL(18, 2),
	[PaymentSeptageArrears] DECIMAL(18, 2),
	[PaymentSeptageAdvanced] DECIMAL(18, 2),
	[PaymentPromisorryWater] DECIMAL(18, 2),
	[PaymentPromisorryOldArrears] DECIMAL(18, 2),

	-- || PN Column ----------------------------------------------------------------------------------------------------------------

	[PromissoryAmountWater] DECIMAL(18, 2),
	[PromissoryAmountOldArrears] DECIMAL(18, 2),
	[PromisorryMonthlyWater] DECIMAL(18, 2),
	[PromisorryMonthlyOldArrears] DECIMAL(18, 2),
	[PromisorryPaidWater] DECIMAL(18, 2),
	[PromisorryPaidOldArrears] DECIMAL(18, 2),

	-- || Penalty Column -----------------------------------------------------------------------------------------------------------

	[PaymentCurrentBeforeDueDate] DECIMAL(18, 2),
	[PenaltyComputed] DECIMAL(18, 2),
	[PenaltyActual] DECIMAL(18, 2)
)
AS
BEGIN
	
	DECLARE @Custnum varchar(14)
	set @CustNum = (Select custnum from Cust Where CustId = @CUstId)

	-- || *** Configuration Section Start *** --------------------------------------------------------------------------------------

	-- || #1: @ConfigSeniorDiscCons ------------------------------------------------------------------------------------------------
	-- || ->   (maximum consumption that is eligible for senior discount) ----------------------------------------------------------
	DECLARE @ConfigSeniorDiscCons INT

	-- || #2: @ConfigSeniorDiscConsHigh --------------------------------------------------------------------------------------------
	-- || ->    0 = senior discount for consumption higher than the value above is forfeited ---------------------------------------
	-- || ->    1 = senior discount for consumption higher than the value above is capped to maximum discount ----------------------
	DECLARE @ConfigSeniorDiscConsHigh INT

	-- || #3: @ConfigMeterChargeSubTot ---------------------------------------------------------------------------------------------
	-- || ->    5 = meter charge is on [SubTot5] -----------------------------------------------------------------------------------
	-- || ->    7 = meter charge is on [SubTot7] -----------------------------------------------------------------------------------
	DECLARE @ConfigMeterChargeSubTot INT

	-- || #4: @ConfigMeterChargeAmount ---------------------------------------------------------------------------------------------
	-- || ->   (monthly meter charge, used only on some areas, notably for penalty) ------------------------------------------------
	DECLARE @ConfigMeterChargeAmount DECIMAL(18, 2)

	-- || #5: @ConfigPenaltyCondition ----------------------------------------------------------------------------------------------
	-- || ->                      [ 0] = penalty is based on the whole basic charge ------------------------------------------------
	-- || ->    Bit 1 (0000 0001) [ 1] = penalty is based on the remaining water balance -------------------------------------------
	-- || ->    Bit 2 (0000 0010) [ 2] = subtract discount before computing penalty ------------------------------------------------
	-- || ->    Bit 3 (0000 0100) [ 4] = subtract advanced before computing penalty ------------------------------------------------
	-- || ->    Bit 4 (0000 1000) [ 8] = include arrears before computing penalty --------------------------------------------------
	-- || ->    Bit 5 (0001 0000) [16] = include meter charge before computing penalty ---------------------------------------------
	-- || *** (note: values can be combined, 6 is penalty on discounted whole basic charge - advanced) -----------------------------
	DECLARE @ConfigPenaltyCondition INT

	-- || #6: @ConfigPenaltyPercent ------------------------------------------------------------------------------------------------
	-- || ->   (penalty percent expressed in decimal form) -------------------------------------------------------------------------
	DECLARE @ConfigPenaltyPercent DECIMAL(18, 2)

	SET @ConfigSeniorDiscCons = 30		-- maximum consumption that is eligible for senior discount is 30
	SET @ConfigSeniorDiscConsHigh = 0	-- senior discount for consumption higher than 30 is forfeited
	SET @ConfigMeterChargeSubTot = 7	-- meter charge is on [SubTot7]
	SET @ConfigMeterChargeAmount = 0	-- meter charge is Php 0.00
	SET @ConfigPenaltyCondition = 0		-- penalty on discounted basic charge
	SET @ConfigPenaltyPercent = 0.02	-- penalty is 10%

	-- || ***  Configuration Section End  *** --------------------------------------------------------------------------------------

	-- =============================================================================================================================

	DECLARE
		@NextDate VARCHAR(10)

	DECLARE @BillDueDate VARCHAR(10)
	DECLARE @PromisorryNumber VARCHAR(20)
	DECLARE @PenaltyExempted INT

	--------------------------------------------------------------------------------------------------------------------------------

	DECLARE
		@HasRead BIT,
		@ReadRate int, @ReadDate VARCHAR(10),
		@ReadPrevious DECIMAL(18, 2), @ReadCurrent DECIMAL(18, 2), @ReadConsumption DECIMAL(18, 2),
		@ReadBasicCharge DECIMAL(18, 4), @ReadDueDate VARCHAR(10),
		@ReadArrears DECIMAL(18, 2), @ReadSeptage DECIMAL(18, 4)

	DECLARE
		@HasBill BIT, @BillNum INT,
		@BillCurrent DECIMAL(18, 2), @BillDiscount DECIMAL(18, 2), @BillSeptage DECIMAL(18, 2),
		@BillArrears DECIMAL(18, 2), @BillMeterCharge DECIMAL(18, 2),
		@BillPenaltyCurrent DECIMAL(18, 2), @BillPenaltyArrears DECIMAL(18, 2)

	DECLARE
		@SeniorDiscountComputed DECIMAL(18, 2), @SeniorDiscountActual DECIMAL(18, 2)

	DECLARE
		@BalancePenalty DECIMAL(18, 2), @BalanceOldArrears DECIMAL(18, 2),
		@BalanceMeterCharge DECIMAL(18, 2), @BalanceSeptage DECIMAL(18, 2)

	DECLARE
		@AdjustmentWater DECIMAL(18, 2), @AdjustmentSeptage DECIMAL(18, 2),
		@AdjustmentMeterCharge DECIMAL(18, 2), @AdjustmentPenalty DECIMAL(18, 2)

	DECLARE
		@HasPayment BIT,
		@PaymentCurrent DECIMAL(18, 2), @PaymentArrears DECIMAL(18, 2), @PaymentAdvanced DECIMAL(18, 2),
		@PaymentMeterCharge DECIMAL(18, 2), @PaymentPenalty DECIMAL(18, 2), @PaymentOldArrears DECIMAL(18, 2),
		@PaymentDiscountTotal DECIMAL(18, 2), @PaymentDiscountCurrent DECIMAL(18, 2), @PaymentDiscountArrears DECIMAL(18, 2),
		@PaymentSeptageCurrent DECIMAL(18, 2), @PaymentSeptageArrears DECIMAL(18, 2), @PaymentSeptageAdvanced DECIMAL(18, 2),
		@PaymentPromisorryWater DECIMAL(18, 2), @PaymentPromisorryOldArrears DECIMAL(18, 2)

	DECLARE
		@PromissoryAmountWater DECIMAL(18, 2), @PromissoryAmountOldArrears DECIMAL(18, 2),
		@PromisorryMonthlyWater DECIMAL(18, 2), @PromisorryMonthlyOldArrears DECIMAL(18, 2),
		@PromisorryPaidWater DECIMAL(18, 2), @PromisorryPaidOldArrears DECIMAL(18, 2)

	DECLARE
		@PaymentCurrentBeforeDueDate DECIMAL(18, 2),
		@PenaltyComputed DECIMAL(18, 2), @PenaltyActual DECIMAL(18, 2)

	-- =============================================================================================================================

	-- || Reading Info -------------------------------------------------------------------------------------------------------------

	SELECT TOP 1
		@HasRead = 1,
		@ReadRate = [RateId],
		@ReadDate = [Rdate],
		@ReadPrevious = TRY_CAST([Pread1] AS DECIMAL(18,2)),
		@ReadCurrent = TRY_CAST([Read1] AS DECIMAL(18,2)),
		@ReadConsumption = [Cons1],
		@ReadBasicCharge = [nbasic],
		@ReadDueDate = [DueDate],
		@ReadArrears = [arrears],
		@ReadSeptage = [sept_fee]
	FROM
		[Rhist]
	WHERE
		CustId = @CustId
		AND [BillDate] = @BillDate

	SET @NextDate = (SELECT TOP 1 [Rdate] FROM [Rhist] WHERE CustId = @CustId AND [BillDate] = LEFT(CONVERT(VARCHAR(10), DATEADD(MONTH, 1, CONVERT(DATETIME, @BillDate + '/01')), 111), 7))

	SET @HasRead = ISNULL(@HasRead, 0)
	SET @ReadRate = ISNULL(@ReadRate, '')
	SET @ReadDate = CASE ISDATE(@ReadDate) WHEN 1 THEN CONVERT(VARCHAR(10), CONVERT(DATETIME, @ReadDate), 111) ELSE LEFT(CONVERT(VARCHAR(10), CONVERT(DATETIME, @BillDate + '/01'), 111), 7) + '/01' END
	SET @ReadPrevious = ISNULL(@ReadPrevious, 0)
	SET @ReadCurrent = ISNULL(@ReadCurrent, 0)
	SET @ReadConsumption = ISNULL(@ReadConsumption, 0)
	SET @ReadBasicCharge = ISNULL(@ReadBasicCharge, 0)
	SET @ReadDueDate = CASE ISDATE(@ReadDueDate) WHEN 1 THEN CONVERT(VARCHAR(10), CONVERT(DATETIME, @ReadDueDate), 101) ELSE CONVERT(VARCHAR(10), DATEADD(MONTH, 1, CONVERT(DATETIME, @BillDate + '/01')), 101) END
	SET @ReadArrears = ISNULL(@ReadArrears, 0)
	SET @ReadSeptage = ISNULL(@ReadSeptage, 0)

	SET @NextDate = CASE ISDATE(@NextDate) WHEN 1 THEN CONVERT(VARCHAR(10), CONVERT(DATETIME, @NextDate), 111) ELSE LEFT(CONVERT(VARCHAR(10), DATEADD(MONTH, 2, CONVERT(DATETIME, @BillDate + '/01')), 111), 7) + '/01' END

	-- || Bill Info ----------------------------------------------------------------------------------------------------------------

	SELECT
		@HasBill = 1,
		@BillNum = a.[BillNum],
		@BillDueDate = a.[DueDate],
		@BillCurrent = a.[SubTot1],
		@BillDiscount = a.[SubTot2],
		@BillSeptage = a.[SubTot3],
		@BillArrears = a.[SubTot4],
		@BillMeterCharge = a.[SubTot5],
		@BillPenaltyCurrent = c.[Amount1],
		@BillPenaltyArrears = c.[Amount2]
	FROM
		[Cbill] a
		Inner JOIN Cust b
		on a.CustId = b.CustId
		LEFT JOIN [CbillOthers] c
			ON b.CustId = c.CustId AND a.[BillDate] = c.[BillDate]
	WHERE
		a.CustId = @CustId
		AND a.[BillDate] = @BillDate

	SET @HasBill = ISNULL(@HasBill, 0)
	SET @BillCurrent = ISNULL(@BillCurrent, 0)
	SET @BillDiscount = ISNULL(@BillDiscount, 0)
	SET @BillSeptage = ISNULL(@BillSeptage, 0)
	SET @BillArrears = ISNULL(@BillArrears, 0)
	SET @BillMeterCharge = ISNULL(@BillMeterCharge, 0)
	SET @BillPenaltyCurrent = ISNULL(@BillPenaltyCurrent, 0)
	SET @BillPenaltyArrears = ISNULL(@BillPenaltyArrears, 0)

	-- || Senior Info --------------------------------------------------------------------------------------------------------------

	SELECT
		@SeniorDiscountComputed =
			CASE
				WHEN @ReadConsumption >= 0 AND @ReadConsumption <= @ConfigSeniorDiscCons
				THEN
					CASE
						WHEN @HasBill = 1
						THEN
							(@BillCurrent - @BillDiscount) * 0.05
						ELSE
							CASE
								WHEN @HasRead = 1
								THEN
									@ReadBasicCharge * 0.05
								ELSE
									0
							END
					END
				ELSE
					CASE
						WHEN @ConfigSeniorDiscConsHigh = 1
						THEN
							(
								ISNULL(b.[MinBill], 0) +
								(ISNULL(b.[Rate1], 0) * (CASE WHEN @ConfigSeniorDiscCons - 10 >= 10 THEN 10 WHEN @ConfigSeniorDiscCons - 10 > 0 THEN @ConfigSeniorDiscCons - 10 ELSE 0 END)) +
								(ISNULL(b.[Rate2], 0) * (CASE WHEN @ConfigSeniorDiscCons - 20 >= 10 THEN 10 WHEN @ConfigSeniorDiscCons - 10 > 0 THEN @ConfigSeniorDiscCons - 20 ELSE 0 END)) +
								(ISNULL(b.[Rate3], 0) * (CASE WHEN @ConfigSeniorDiscCons - 30 >= 10 THEN 10 WHEN @ConfigSeniorDiscCons - 10 > 0 THEN @ConfigSeniorDiscCons - 30 ELSE 0 END)) +
								(ISNULL(b.[Rate4], 0) * (CASE WHEN @ConfigSeniorDiscCons - 40 >= 10 THEN 10 WHEN @ConfigSeniorDiscCons - 10 > 0 THEN @ConfigSeniorDiscCons - 40 ELSE 0 END)) +
								(ISNULL(b.[Rate5], 0) * (CASE WHEN @ConfigSeniorDiscCons - 50 > 0 THEN @ConfigSeniorDiscCons - 50 ELSE 0 END))
							)
						ELSE
							0
					END
			END,
		@SeniorDiscountActual =
			CASE
				WHEN a.[SeniorDate] >= CONVERT(DATETIME, @ReadDate)
				THEN
					@SeniorDiscountComputed
				ELSE
					0
			END
	FROM
		[Cust] a
		LEFT JOIN [Bill] b
			ON @ReadRate = b.[RateId] AND a.[ZoneId] = b.[ZoneId]
	WHERE
		a.CustId = @CustId

	SET @SeniorDiscountComputed = ISNULL(@SeniorDiscountComputed, 0)
	SET @SeniorDiscountActual = ISNULL(@SeniorDiscountActual, 0)

	-- || Balance Info -------------------------------------------------------------------------------------------------------------

	IF(@IncludeBalanceColumn = 1)
	BEGIN
		SET @BalancePenalty = (SELECT ISNULL(SUM([Debit]), 0) - ISNULL(SUM([Credit]), 0) FROM [cust_ledger] WHERE CustId = @CustId AND ISNULL([trans_date], CONVERT(DATETIME, -53690)) < CONVERT(DATETIME, @ReadDate) AND [ledger_type] = 'PENALTY')
		SET @BalanceOldArrears = (SELECT ISNULL(SUM([Debit]), 0) - ISNULL(SUM([Credit]), 0) FROM [cust_ledger] WHERE CustId = @CustId AND ISNULL([trans_date], CONVERT(DATETIME, -53690)) < CONVERT(DATETIME, @ReadDate) AND [ledger_type] = 'OLD ARREARS')
		SET @BalanceMeterCharge = (SELECT ISNULL(SUM([Debit]), 0) - ISNULL(SUM([Credit]), 0) FROM [cust_ledger] WHERE CustId = @CustId AND ISNULL([trans_date], CONVERT(DATETIME, -53690)) < CONVERT(DATETIME, @ReadDate) AND [ledger_type] = 'SERVICE CHARGE')
		SET @BalanceSeptage = (SELECT ISNULL(SUM([Debit]), 0) - ISNULL(SUM([Credit]), 0) FROM [cust_ledger] WHERE CustId = @CustId AND ISNULL([trans_date], CONVERT(DATETIME, -53690)) < CONVERT(DATETIME, @ReadDate) AND [ledger_type] = 'SEWERAGE')

		SET @BalancePenalty = ISNULL(@BalancePenalty, 0)
		SET @BalanceOldArrears = ISNULL(@BalanceOldArrears, 0)
		SET @BalanceMeterCharge = ISNULL(@BalanceMeterCharge, 0)
		SET @BalanceSeptage = ISNULL(@BalanceSeptage, 0)
	END
	ELSE
	BEGIN
		SET @BalancePenalty = 0
		SET @BalanceOldArrears = 0
		SET @BalanceMeterCharge = 0
		SET @BalanceSeptage = 0
	END

	-- || Adjustment Info ----------------------------------------------------------------------------------------------------------

	IF(@IncludeAdjustmentColumn = 1)
	BEGIN
		SET @AdjustmentWater = (SELECT ISNULL(SUM([Debit]), 0) - ISNULL(SUM([Credit]), 0) FROM [cust_ledger] WHERE CustId = @CustId AND ISNULL([trans_date], CONVERT(DATETIME, -53690)) >= CONVERT(DATETIME, @ReadDate) AND ISNULL([trans_date], CONVERT(DATETIME, -53690)) < CONVERT(DATETIME, @NextDate) AND [transaction_type] = 4 AND [ledger_type] = 'WATER' AND [ledger_subtype] != 'BEG')
		SET @AdjustmentSeptage = (SELECT ISNULL(SUM([Debit]), 0) - ISNULL(SUM([Credit]), 0) FROM [cust_ledger] WHERE CustId = @CustId AND ISNULL([trans_date], CONVERT(DATETIME, -53690)) >= CONVERT(DATETIME, @ReadDate) AND ISNULL([trans_date], CONVERT(DATETIME, -53690)) < CONVERT(DATETIME, @NextDate) AND [transaction_type] = 4 AND [ledger_type] = 'SEWERAGE' AND [ledger_subtype] != 'BEG')
		SET @AdjustmentMeterCharge = (SELECT ISNULL(SUM([Debit]), 0) - ISNULL(SUM([Credit]), 0) FROM [cust_ledger] WHERE CustId = @CustId AND ISNULL([trans_date], CONVERT(DATETIME, -53690)) >= CONVERT(DATETIME, @ReadDate) AND ISNULL([trans_date], CONVERT(DATETIME, -53690)) < CONVERT(DATETIME, @NextDate) AND [transaction_type] = 4 AND [ledger_type] = 'SERVICE CHARGE' AND [ledger_subtype] != 'BEG')
		SET @AdjustmentPenalty = (SELECT ISNULL(SUM([Debit]), 0) - ISNULL(SUM([Credit]), 0) FROM [cust_ledger] WHERE CustId = @CustId AND ISNULL([trans_date], CONVERT(DATETIME, -53690)) >= CONVERT(DATETIME, @ReadDate) AND ISNULL([trans_date], CONVERT(DATETIME, -53690)) < CONVERT(DATETIME, @NextDate) AND [transaction_type] = 4 AND [ledger_type] = 'PENALTY' AND [ledger_subtype] != 'BEG')

		SET @AdjustmentWater = ISNULL(@AdjustmentWater, 0)
		SET @AdjustmentSeptage = ISNULL(@AdjustmentSeptage, 0)
		SET @AdjustmentMeterCharge = ISNULL(@AdjustmentMeterCharge, 0)
		SET @AdjustmentPenalty = ISNULL(@AdjustmentPenalty, 0)
	END
	ELSE
	BEGIN
		SET @AdjustmentWater = 0
		SET @AdjustmentSeptage = 0
		SET @AdjustmentMeterCharge = 0
		SET @AdjustmentPenalty = 0
	END

	-- || Payment Info -------------------------------------------------------------------------------------------------------------

	SELECT
		@HasPayment = 1,
		@PaymentCurrent = SUM([Subtot1]),
		@PaymentArrears = SUM([Subtot2]),
		@PaymentAdvanced = SUM([Subtot3]),
		@PaymentMeterCharge = SUM(CASE @ConfigMeterChargeSubTot WHEN 5 THEN [Subtot5] WHEN 7 THEN [Subtot7] ELSE 0 END),
		@PaymentPenalty = SUM([Subtot6]),
		@PaymentOldArrears = SUM([Subtot9]),
		@PaymentDiscountTotal = SUM([Subtot10]),
		@PaymentDiscountCurrent = SUM([Tax1]),
		@PaymentDiscountArrears = SUM([Tax2]),
		@PaymentSeptageCurrent = SUM([Subtot12]),
		@PaymentSeptageArrears = SUM([Subtot13]),
		@PaymentSeptageAdvanced = SUM([Subtot14]),
		@PaymentPromisorryWater = SUM([rwatfee]),
		@PaymentPromisorryOldArrears = SUM([rprocfee])
	FROM
		[Cpaym]
	WHERE
		CustId = @CustId
		AND [PayDate] >= @ReadDate
		AND [PayDate] < @NextDate

	SET @HasPayment = ISNULL(@HasPayment, 0)
	SET @PaymentCurrent = ISNULL(@PaymentCurrent, 0)
	SET @PaymentArrears = ISNULL(@PaymentArrears, 0)
	SET @PaymentAdvanced = ISNULL(@PaymentAdvanced, 0)
	SET @PaymentMeterCharge = ISNULL(@PaymentMeterCharge, 0)
	SET @PaymentPenalty = ISNULL(@PaymentPenalty, 0)
	SET @PaymentOldArrears = ISNULL(@PaymentOldArrears, 0)
	SET @PaymentDiscountTotal = ISNULL(@PaymentDiscountTotal, 0)
	SET @PaymentDiscountCurrent = ISNULL(@PaymentDiscountCurrent, 0)
	SET @PaymentDiscountArrears = ISNULL(@PaymentDiscountArrears, 0)
	SET @PaymentSeptageCurrent = ISNULL(@PaymentSeptageCurrent, 0)
	SET @PaymentSeptageArrears = ISNULL(@PaymentSeptageArrears, 0)
	SET @PaymentSeptageAdvanced = ISNULL(@PaymentSeptageAdvanced, 0)
	SET @PaymentPromisorryWater = ISNULL(@PaymentPromisorryWater, 0)
	SET @PaymentPromisorryOldArrears = ISNULL(@PaymentPromisorryOldArrears, 0)

	-- || PN Info ------------------------------------------------------------------------------------------------------------------

	IF(@IncludePromisorryColumn = 1)
	BEGIN
		SET @PromisorryNumber = (SELECT TOP 1 [pnno] FROM [Cpaym] WHERE CustId = @CustId AND [PayDate] >= @ReadDate AND [PayDate] < @NextDate AND ISNUMERIC([pnno]) = 1)
		SET @PromisorryNumber = ISNULL(@PromisorryNumber, -1)

		SELECT
			@PromissoryAmountWater = [nwatfee],
			@PromissoryAmountOldArrears = [nprocfee],
			@PromisorryMonthlyWater = [rwatfee],
			@PromisorryMonthlyOldArrears = [rprocfee]
		FROM
			[PN1]
		WHERE
			CustId = @CustId
			AND [cpnno] = @PromisorryNumber

		SELECT
			@PromisorryPaidWater = SUM([rwatfee]),
			@PromisorryPaidOldArrears = SUM([rprocfee])
		FROM
			[Cpaym]
		WHERE
			CustId = @CustId
			AND [PayDate] < @ReadDate
			AND [pnno] = @PromisorryNumber

		SET @PromissoryAmountWater = ISNULL(@PromissoryAmountWater, 0)
		SET @PromissoryAmountOldArrears = ISNULL(@PromissoryAmountOldArrears, 0)
		SET @PromisorryMonthlyWater = ISNULL(@PromisorryMonthlyWater, 0)
		SET @PromisorryMonthlyOldArrears = ISNULL(@PromisorryMonthlyOldArrears, 0)

		SET @PromisorryPaidWater = ISNULL(@PromisorryPaidWater, 0)
		SET @PromisorryPaidOldArrears = ISNULL(@PromisorryPaidOldArrears, 0)
	END
	ELSE
	BEGIN
		SET @PromissoryAmountWater = 0
		SET @PromissoryAmountOldArrears = 0
		SET @PromisorryMonthlyWater = 0
		SET @PromisorryMonthlyOldArrears = 0
		SET @PromisorryPaidWater = 0
		SET @PromisorryPaidOldArrears = 0
	END

	-- || Penalty Info -------------------------------------------------------------------------------------------------------------

	SET @PenaltyExempted = (SELECT COUNT(1) FROM [dd_PenaltyExemption] WHERE ([CustNum] = @CustNum AND [Type] = '1') OR ([CustNum] = @CustNum AND [Type] = '2' AND [BillDate] = @BillDate))
	SET @PaymentCurrentBeforeDueDate = (SELECT ISNULL(SUM([Subtot1]), 0) + ISNULL(SUM([Subtot3]), 0) + ISNULL(SUM([Tax1]), 0) FROM [Cpaym] WHERE CustId = @CustId AND [PayDate] >= @ReadDate AND [PayDate] <= @BillDueDate)

	SET @PenaltyComputed =
		(
			CASE WHEN @HasBill = 1 THEN @BillCurrent ELSE CASE WHEN @HasRead = 1 THEN @ReadBasicCharge ELSE 0 END END
				- CASE WHEN ((@ConfigPenaltyCondition & 1) = 1) THEN @PaymentCurrentBeforeDueDate ELSE 0 END
				- CASE WHEN ((@ConfigPenaltyCondition & 2) = 2) THEN @SeniorDiscountActual ELSE 0 END
				+ CASE WHEN ((@ConfigPenaltyCondition & 4) = 4) THEN CASE WHEN @BillArrears < 0 THEN @BillArrears ELSE 0 END ELSE 0 END
				+ CASE WHEN ((@ConfigPenaltyCondition & 8) = 8) THEN @BillArrears ELSE 0 END
				+ CASE WHEN ((@ConfigPenaltyCondition & 16) = 16) THEN CASE WHEN @HasBill = 1 THEN @BillMeterCharge ELSE CASE WHEN @HasRead = 1 THEN @ConfigMeterChargeAmount ELSE 0 END END ELSE 0 END
		) * @ConfigPenaltyPercent

	SET @PenaltyComputed = ISNULL(@PenaltyComputed, 0)
	SET @PenaltyActual = CASE WHEN @PenaltyExempted > 0 THEN 0 ELSE @PenaltyComputed END

	INSERT @CustBalance
	VALUES
	(
		@HasRead,
		@ReadRate,
		@ReadDate,
		@ReadPrevious,
		@ReadCurrent,
		@ReadConsumption,
		@ReadBasicCharge,
		@ReadDueDate,
		@ReadArrears,
		@ReadSeptage,
		@HasBill,
		@BillNum,
		@BillCurrent,
		@BillDiscount,
		@BillSeptage,
		@BillArrears,
		@BillMeterCharge,
		@BillPenaltyCurrent,
		@BillPenaltyArrears,
		@SeniorDiscountComputed,
		@SeniorDiscountActual,
		@BalancePenalty,
		@BalanceOldArrears,
		@BalanceMeterCharge,
		@BalanceSeptage,
		@AdjustmentWater,
		@AdjustmentSeptage,
		@AdjustmentMeterCharge,
		@AdjustmentPenalty,
		@HasPayment,
		@PaymentCurrent,
		@PaymentArrears,
		@PaymentAdvanced,
		@PaymentMeterCharge,
		@PaymentPenalty,
		@PaymentOldArrears,
		@PaymentDiscountTotal,
		@PaymentDiscountCurrent,
		@PaymentDiscountArrears,
		@PaymentSeptageCurrent,
		@PaymentSeptageArrears,
		@PaymentSeptageAdvanced,
		@PaymentPromisorryWater,
		@PaymentPromisorryOldArrears,
		@PromissoryAmountWater,
		@PromissoryAmountOldArrears,
		@PromisorryMonthlyWater,
		@PromisorryMonthlyOldArrears,
		@PromisorryPaidWater,
		@PromisorryPaidOldArrears,
		@PaymentCurrentBeforeDueDate,
		@PenaltyComputed,
		@PenaltyActual
	)

	RETURN;
END