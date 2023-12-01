ALTER FUNCTION [dbo].[GetArrearsForPenalty]
(
    @CustId int
)
RETURNS @BalanceInfo TABLE
(
    [ID] INT,
    [BillDate] VARCHAR(7),
    [Consumption] DECIMAL(18, 2),
    [ReadDateCurrent] VARCHAR(10),
    [RdateNext] VARCHAR(10),
    [DueDate] VARCHAR(10),
    [BillCurrent] DECIMAL(18, 2),
    [BillDiscount] DECIMAL(18, 2),
    [BillMeterCharge] DECIMAL(18, 2),
    [PayCurrentBeforeDueDate] DECIMAL(18, 2),
    [PayArrearsBeforeDueDate] DECIMAL(18, 2),
    [PayAdvancedBeforeDueDate] DECIMAL(18, 2),
    [PayMeterChargeBeforeDueDate] DECIMAL(18, 2),
    [PayDiscountBeforeDueDate] DECIMAL(18, 2),
    [PayCurrentForBillMonth] DECIMAL(18, 2),
    [PayArrearsForBillMonth] DECIMAL(18, 2),
    [PayAdvancedForBillMonth] DECIMAL(18, 2),
    [PayMeterChargeForBillMonth] DECIMAL(18, 2),
    [PayDiscountBillMonth] DECIMAL(18, 2),
    [TotalBill] DECIMAL(18, 2),
    [TotalPaymentBeforeDueDate] DECIMAL(18, 2),
    [TotalPaymentForBillMonth] DECIMAL(18, 2),
    [RemainingBalanceOnDueDate] DECIMAL(18, 2),
    [RemainingBalance] DECIMAL(18, 2),
    [CumulativeRemainingBalance] DECIMAL(18, 2)
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

    SET @ConfigSeniorDiscCons = 30      -- maximum consumption that is eligible for senior discount is 30
    SET @ConfigSeniorDiscConsHigh = 0   -- senior discount for consumption higher than 30 is forfeited

    -- || ***  Configuration Section End  *** --------------------------------------------------------------------------------------

    DECLARE @ZoneId int
    DECLARE @SeniorDate DATETIME
    DECLARE @ArrearsBillDate VARCHAR(7)


    DECLARE
        @TotalCount INT,
        @Counter1 INT,
        @Counter2 INT,
        @AmountToDistribute DECIMAL(18, 2),
        @CurrentMonthBalance DECIMAL(18, 2)

    --------------------------------------------------------------------------------------------------------------------------------

    SELECT
        @ZoneId = [ZoneId],
        @SeniorDate = [SeniorDate]
    FROM
        [Cust]
    WHERE
        CustId = @CustId

    SELECT TOP 1
        @ArrearsBillDate = [BillDate]
    FROM
        [Cbill]
    WHERE
        CustId = @CustId
        AND [SubTot4] <= 0
    ORDER BY
        [BillDate] DESC

    --------------------------------------------------------------------------------------------------------------------------------

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

    IF(ISNULL(@ArrearsBillDate, '') = '')
    BEGIN
        SELECT TOP 1
            @ArrearsBillDate = [BillDate]
        FROM
            [Rhist]
        WHERE
            CustId = @CustId
        ORDER BY
            [BillDate] ASC
    END

    --------------------------------------------------------------------------------------------------------------------------------

    INSERT @BalanceInfo
    SELECT
        ROW_NUMBER() OVER (ORDER BY a.[BillDate]),
        a.[BillDate],
        a.[Cons1] AS [Consumption],
        a.[Rdate] AS [ReadDateCurrent],
        c.[RdateNext] AS [ReadDateNext],
        b.[DueDate],
        ISNULL(d.[SubTot1], 0) AS [BillCurrent],
        ISNULL(d.[SubTot2], 0) AS [BillDiscount],
        --g.[SeniorDiscount],
        ISNULL(d.[SubTot5], 0) AS [BillMeterCharge],
        ISNULL(e.[Subtot1], 0) AS [PayCurrentBeforeDueDate],
        ISNULL(e.[Subtot2], 0) AS [PayArrearsBeforeDueDate],
        ISNULL(e.[Subtot3], 0) AS [PayAdvancedBeforeDueDate],
        ISNULL(e.[Subtot7], 0) AS [PayMeterChargeBeforeDueDate],
        ISNULL(e.[Subtot10], 0) AS [PayDiscountBeforeDueDate],
        ISNULL(f.[Subtot1], 0) AS [PayCurrentForBillMonth],
        ISNULL(f.[Subtot2], 0) AS [PayArrearsForBillMonth],
        ISNULL(f.[Subtot3], 0) AS [PayAdvancedForBillMonth],
        ISNULL(f.[Subtot7], 0) AS [PayMeterChargeForBillMonth],
        ISNULL(f.[Subtot10], 0) AS [PayDiscountBillMonth],

        ISNULL(d.[SubTot1], 0)
            - ISNULL(d.[SubTot2], 0)
            + CASE WHEN ISNULL(d.[SubTot4], 0) < 0 THEN ISNULL(d.[SubTot4], 0) ELSE 0 END
            -- g.[SeniorDiscount]
            + ISNULL(d.[SubTot5], 0)
        AS [TotalBill],

        ISNULL(e.[Subtot1], 0)
            + ISNULL(e.[Subtot2], 0)
            + ISNULL(e.[Subtot3], 0)
            + ISNULL(e.[Subtot7], 0)
            + ISNULL(e.[Subtot10], 0)
        AS [TotalPaymentBeforeDueDate],

        ISNULL(f.[Subtot1], 0)
            + ISNULL(f.[Subtot2], 0)
            + ISNULL(f.[Subtot3], 0)
            + ISNULL(f.[Subtot7], 0)
            + ISNULL(e.[Subtot10], 0)
        AS [TotalPaymentForBillMonth],

        (
        ISNULL(d.[SubTot1], 0)
            - ISNULL(d.[SubTot2], 0)
            + CASE WHEN ISNULL(d.[SubTot4], 0) < 0 THEN ISNULL(d.[SubTot4], 0) ELSE 0 END
            -- g.[SeniorDiscount]
            + ISNULL(d.[SubTot5], 0)
        )
        -
        (
        ISNULL(e.[Subtot1], 0)
            + ISNULL(e.[Subtot2], 0)
            + ISNULL(e.[Subtot3], 0)
            + ISNULL(e.[Subtot7], 0)
            + ISNULL(e.[Subtot10], 0)
        )
        AS [RemainingBalanceOnDueDate]
        ,NULL,NULL
    FROM
        [Rhist] a
        OUTER APPLY
        (
            SELECT
                CASE
                    WHEN ISNUMERIC(RIGHT(a.[DueDate], 4)) = 1
                        AND ISDATE(RIGHT(a.[DueDate], 4) + '/' + LEFT(a.[DueDate], 5)) = 1
                    THEN
                        RIGHT(a.[DueDate], 4) + '/' + LEFT(a.[DueDate], 5)
                    ELSE
                        ISNULL(a.[DueDate], EOMONTH(a.[BillDate] + '/01'))
            END AS [DueDate]
        ) b
        OUTER APPLY
        (
            SELECT
                [Rdate]
            FROM
                [Rhist]
            WHERE
                CustId = a.CustId
                AND [BillDate] = LEFT(CONVERT(VARCHAR(10), DATEADD(MONTH, 1, CONVERT(DATETIME, a.[BillDate] + '/01')), 111), 7)
                AND [BillDate] >= '2021/02'
        ) __hidden02
        OUTER APPLY
        (
            SELECT
                ISNULL(__hidden02.[Rdate], CONVERT(VARCHAR(10), DATEADD(MONTH, 2, CONVERT(DATETIME, a.[Rdate])), 111)) AS [RdateNext]
        ) c
        OUTER APPLY
        (
            SELECT
                [Subtot1],
                [Subtot2],
                [Subtot4],
                [Subtot5]
            FROM
                [Cbill]
            WHERE
                CustId = a.CustId
                AND [BillDate] = a.[BillDate]
                AND [BillDate] >= '2021/02'
        ) d
        OUTER APPLY
        (
            SELECT
                [Subtot1],
                [Subtot2],
                [Subtot3],
                [Subtot7],
                [Subtot10]
            FROM
                [Cpaym]
            WHERE
                CustId = a.CustId
                AND [PayDate] >= a.[Rdate]
                AND [PayDate] <= b.[DueDate]
        ) e
        OUTER APPLY
        (
            SELECT
                [Subtot1],
                [Subtot2],
                [Subtot3],
                [Subtot7],
                [Subtot10]
            FROM
                [Cpaym]
            WHERE
                CustId = a.CustId
                AND [PayDate] >= a.[Rdate]
                AND [PayDate] <= c.[RdateNext]
        ) f
        
    WHERE
        a.CustId = @CustId
        AND a.[BillDate] >= @ArrearsBillDate
        AND a.[BillDate] >= '2021/02'
    ORDER BY
        a.[BillDate]

    --------------------------------------------------------------------------------------------------------------------------------

    UPDATE @BalanceInfo SET [RemainingBalance] = [RemainingBalanceOnDueDate]

    -- || Payment Loop -------------------------------------------------------------------------------------------------------------

    SET @TotalCount = (SELECT COUNT(1) FROM @BalanceInfo)

    SET @Counter1 = 1
    SET @AmountToDistribute = 0

    WHILE(@Counter1 <= @TotalCount)
    BEGIN
        SET @AmountToDistribute = @AmountToDistribute + (SELECT [TotalPaymentForBillMonth] - [TotalPaymentBeforeDueDate] FROM @BalanceInfo WHERE [ID] = @Counter1)
        SET @CurrentMonthBalance = (SELECT [RemainingBalance] FROM @BalanceInfo WHERE [ID] = @Counter1)

        IF(@AmountToDistribute > @CurrentMonthBalance)
        BEGIN
            UPDATE @BalanceInfo SET [RemainingBalance] = 0 WHERE [ID] = @Counter1
            SET @AmountToDistribute = @AmountToDistribute - @CurrentMonthBalance
        END
        ELSE
        BEGIN
            UPDATE @BalanceInfo SET [RemainingBalance] = [RemainingBalance] - @AmountToDistribute WHERE [ID] = @Counter1
            SET @AmountToDistribute = 0
        END

        IF(@AmountToDistribute > 0)
        BEGIN
            SET @Counter2 = 1

            WHILE(@Counter2 <= (@Counter1 - 1))
            BEGIN
                SET @CurrentMonthBalance = (SELECT [RemainingBalance] FROM @BalanceInfo WHERE [ID] = @Counter2)

                IF(@AmountToDistribute > @CurrentMonthBalance)
                BEGIN
                    UPDATE @BalanceInfo SET [RemainingBalance] = 0 WHERE [ID] = @Counter2
                    SET @AmountToDistribute = @AmountToDistribute - @CurrentMonthBalance
                END
                ELSE
                BEGIN
                    UPDATE @BalanceInfo SET [RemainingBalance] = [RemainingBalance] - @AmountToDistribute WHERE [ID] = @Counter2
                    SET @AmountToDistribute = 0
                END

                SET @Counter2 = @Counter2 + 1
            END
        END

        SET @Counter1 = @Counter1 + 1
    END

    --------------------------------------------------------------------------------------------------------------------------------

    SET @TotalCount = (SELECT COUNT(1) FROM @BalanceInfo)

    SET @Counter1 = 1
    SET @CurrentMonthBalance = 0

    WHILE(@Counter1 <= @TotalCount)
    BEGIN
        SET @CurrentMonthBalance = (SELECT SUM([RemainingBalance]) FROM @BalanceInfo WHERE [ID] < @Counter1)
        UPDATE @BalanceInfo SET [CumulativeRemainingBalance] = ISNULL([RemainingBalance], 0) + ISNULL(@CurrentMonthBalance, 0) 	
		WHERE [ID] = @Counter1

        SET @Counter1 = @Counter1 + 1
    END

    --------------------------------------------------------------------------------------------------------------------------------

    RETURN;
END

GO


