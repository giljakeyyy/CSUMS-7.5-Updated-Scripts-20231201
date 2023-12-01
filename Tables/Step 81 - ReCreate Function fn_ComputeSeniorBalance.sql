ALTER FUNCTION [dbo].[fn_ComputeSeniorBalance]
(
	@CustId int
)
RETURNS @SeniorBalance TABLE
(
	[BillDate] VARCHAR(7),
	[Consumption] DECIMAL(18, 2),
	[BasicCharge] DECIMAL(18, 2),
	[Remaining] DECIMAL(18, 2),
	[SeniorDiscount] DECIMAL(18, 2)
)
AS
BEGIN
	-- || *** Configuration Section Start *** --------------------------------------------------------------------------------------

	-- || #1: @ConfigSeniorDiscCons ------------------------------------------------------------------------------------------------
	-- || ->   (maximum consumption that is eligible for senior discount) ----------------------------------------------------------
	DECLARE @ConfigSeniorDiscCons INT

	-- || #2: @ConfigSeniorDiscConsHigh --------------------------------------------------------------------------------------------
	-- || ->    0 = senior discount for consumption higher than the value above is forfeited ---------------------------------------
	-- || ->    1 = senior discount for consumption higher than the value above is capped to maximum discount ----------------------
	DECLARE @ConfigSeniorDiscConsHigh INT

	SET @ConfigSeniorDiscCons = 30		-- maximum consumption that is eligible for senior discount is 30
	SET @ConfigSeniorDiscConsHigh = 0	-- senior discount for consumption higher than 30 is forfeited

	-- || ***  Configuration Section End  *** --------------------------------------------------------------------------------------

	-- =============================================================================================================================

	DECLARE
		@ZoneId int,
		@SeniorDate DATETIME,
		@BillDate VARCHAR(7)

	--------------------------------------------------------------------------------------------------------------------------------

	DECLARE @BalanceInfo TABLE
	(
		[ID] INT,
		[BillDate] VARCHAR(7),
		[RateId] int,
		[ReadDate] VARCHAR(10),
		[Consumption] DECIMAL(18, 2),
		[BasicCharge] DECIMAL(18, 2),
		[BillCurrent] DECIMAL(18, 2),
		[BillArrears] DECIMAL(18, 2),
		[PaymentCurrent] DECIMAL(18, 2),
		[PaymentArrears] DECIMAL(18, 2),
		[PaymentAdvanced] DECIMAL(18, 2),
		[PaymentDiscountTotal] DECIMAL(18, 2),
		[ComputeValue] DECIMAL(18, 2),
		[ComputeSenior] DECIMAL(18, 2)
	)

	--------------------------------------------------------------------------------------------------------------------------------

	DECLARE
		@TotalCount INT,
		@Counter1 INT,
		@Counter2 INT,
		@AmountToDistribute DECIMAL(18, 2),
		@CurrentMonthBalance DECIMAL(18, 2)

	-- =============================================================================================================================

	SELECT
		@ZoneId = [ZoneId],
		@SeniorDate = [SeniorDate]
	FROM
		[Cust]
	WHERE
		CustId = @CustId

	IF(ISNULL(@ZoneId, 0) = 0)
	BEGIN
		SELECT TOP 1
			@ZoneId = [ZoneId]
		FROM
			[Zones]
		ORDER BY
			[ZoneNo] ASC
	END

	SET @SeniorDate = ISNULL(@SeniorDate, CONVERT(DATETIME, -53690))

	SELECT TOP 1
		@BillDate = [BillDate]
	FROM
		[Cbill]
	WHERE
		CustId = @CustId
		AND [SubTot4] <= 0
	ORDER BY
		[BillDate] DESC

	IF(ISNULL(@BillDate, '') = '')
	BEGIN
		SELECT TOP 1
			@BillDate = [BillDate]
		FROM
			[Rhist]
		WHERE
			CustId = @CustId
		ORDER BY
			[BillDate] ASC
	END

	-- || Current Bill and Payment Info --------------------------------------------------------------------------------------------

	INSERT @BalanceInfo
	SELECT
		ROW_NUMBER() OVER (ORDER BY a.[BillDate]),
		a.[BillDate],
		a.[RateId],
		a.[Rdate],
		a.[Cons1],
		a.[nbasic],
		ISNULL(c.[SubTot1], 0),
		ISNULL(c.[SubTot2], 0),
		ISNULL(d.[Subtot1], 0),
		ISNULL(d.[Subtot2], 0),
		ISNULL(d.[Subtot3], 0),
		ISNULL(d.[Subtot10], 0),
		ISNULL(c.[SubTot1], 0) + ISNULL(c.[SubTot2], 0),
		0
	FROM
		[Rhist] a
		OUTER APPLY
		(
			SELECT
				[Rdate]
			FROM
				[Rhist]
			WHERE
				CustId = a.CustId
				AND [BillDate] = LEFT(CONVERT(VARCHAR(10), DATEADD(MONTH, 1, CONVERT(DATETIME, a.[BillDate] + '/01')), 111), 7)
		) b
		OUTER APPLY
		(
			SELECT
				[Subtot1],
				[Subtot2]
			FROM
				[Cbill]
			WHERE
				CustId = a.CustId
				AND [BillDate] = a.[BillDate]
		) c
		OUTER APPLY
		(
			SELECT
				[Subtot1],
				[Subtot2],
				[Subtot3],
				[Subtot10]
			FROM
				[Cpaym]
			WHERE
				CustId = a.CustId
				AND [PayDate] >= a.[Rdate]
				AND [PayDate] < ISNULL(b.[Rdate], CONVERT(VARCHAR(10), DATEADD(MONTH, 2, CONVERT(DATETIME, a.[Rdate])), 111))
		) d
	WHERE
		a.CustId = @CustId
		AND a.[BillDate] >= @BillDate
	ORDER BY
		a.[BillDate]

	-- || Payment Loop -------------------------------------------------------------------------------------------------------------

	SET @TotalCount = (SELECT COUNT(1) FROM @BalanceInfo)

	SET @Counter1 = 1
	SET @AmountToDistribute = 0

	WHILE(@Counter1 <= @TotalCount)
	BEGIN
		SET @AmountToDistribute = @AmountToDistribute + (SELECT [PaymentCurrent] + [PaymentArrears] + [PaymentAdvanced] + (CASE WHEN [PaymentDiscountTotal] <= (([PaymentCurrent] * 0.1) + ([PaymentArrears] * 0.1)) THEN [PaymentDiscountTotal] ELSE (([PaymentCurrent] * 0.1) + ([PaymentArrears] * 0.1)) END) FROM @BalanceInfo WHERE [ID] = @Counter1)
		SET @CurrentMonthBalance = (SELECT [ComputeValue] FROM @BalanceInfo WHERE [ID] = @Counter1)

		IF(@AmountToDistribute > @CurrentMonthBalance)
		BEGIN
			UPDATE @BalanceInfo SET [ComputeValue] = 0 WHERE [ID] = @Counter1
			SET @AmountToDistribute = @AmountToDistribute - @CurrentMonthBalance
		END
		ELSE
		BEGIN
			UPDATE @BalanceInfo SET [ComputeValue] = [ComputeValue] - @AmountToDistribute WHERE [ID] = @Counter1
			SET @AmountToDistribute = 0
		END

		IF(@AmountToDistribute > 0)
		BEGIN
			SET @Counter2 = 1

			WHILE(@Counter2 <= (@Counter1 - 1))
			BEGIN
				SET @CurrentMonthBalance = (SELECT [ComputeValue] FROM @BalanceInfo WHERE [ID] = @Counter2)

				IF(@AmountToDistribute > @CurrentMonthBalance)
				BEGIN
					UPDATE @BalanceInfo SET [ComputeValue] = 0 WHERE [ID] = @Counter2
					SET @AmountToDistribute = @AmountToDistribute - @CurrentMonthBalance
				END
				ELSE
				BEGIN
					UPDATE @BalanceInfo SET [ComputeValue] = [ComputeValue] - @AmountToDistribute WHERE [ID] = @Counter2
					SET @AmountToDistribute = 0
				END

				SET @Counter2 = @Counter2 + 1
			END
		END

		SET @Counter1 = @Counter1 + 1
	END

	-- || Senior Computation -------------------------------------------------------------------------------------------------------

	UPDATE
		a
	SET
		a.[ComputeSenior] =
		CASE
			WHEN @SeniorDate >= CONVERT(DATETIME, a.[ReadDate])
			THEN
				CASE
					WHEN a.[Consumption] >= 0 AND a.[Consumption] <= @ConfigSeniorDiscCons
					THEN
						a.[ComputeValue] * 0.05
					ELSE
						CASE
							WHEN @ConfigSeniorDiscConsHigh = 1
							THEN
								ISNULL(b.[MinBill], 0) +
								(ISNULL(b.[Rate1], 0) * (CASE WHEN @ConfigSeniorDiscCons - 10 >= 10 THEN 10 WHEN @ConfigSeniorDiscCons - 10 > 0 THEN @ConfigSeniorDiscCons - 10 ELSE 0 END)) +
								(ISNULL(b.[Rate2], 0) * (CASE WHEN @ConfigSeniorDiscCons - 20 >= 10 THEN 10 WHEN @ConfigSeniorDiscCons - 10 > 0 THEN @ConfigSeniorDiscCons - 20 ELSE 0 END)) +
								(ISNULL(b.[Rate3], 0) * (CASE WHEN @ConfigSeniorDiscCons - 30 >= 20 THEN 20 WHEN @ConfigSeniorDiscCons - 20 > 0 THEN @ConfigSeniorDiscCons - 30 ELSE 0 END)) +
								(ISNULL(b.[Rate4], 0) * (CASE WHEN @ConfigSeniorDiscCons - 50 >= 20 THEN 20 WHEN @ConfigSeniorDiscCons - 20 > 0 THEN @ConfigSeniorDiscCons - 50 ELSE 0 END)) +
								(ISNULL(b.[Rate5], 0) * (CASE WHEN @ConfigSeniorDiscCons - 70 >= 30 THEN 30 WHEN @ConfigSeniorDiscCons - 30 > 0 THEN @ConfigSeniorDiscCons - 70 ELSE 0 END)) +
								(ISNULL(b.[Rate6], 0) * (CASE WHEN @ConfigSeniorDiscCons - 100 > 0 THEN @ConfigSeniorDiscCons - 100 ELSE 0 END))
							ELSE
								0
						END
				END
			ELSE
				0
		END
	FROM
		@BalanceInfo a
		LEFT JOIN [Bill] b
			ON a.[RateId] = b.[RateId]
	WHERE
		b.ZoneId = @ZoneId

	INSERT @SeniorBalance
	SELECT
		[BillDate],
		[Consumption],
		[BasicCharge],
		[ComputeValue],
		[ComputeSenior]
	FROM
		@BalanceInfo
	ORDER BY
		[BillDate]

	RETURN;
END

GO


