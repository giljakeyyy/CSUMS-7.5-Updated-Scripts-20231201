ALTER FUNCTION [dbo].[checkdonee]
(
    @BillDate VARCHAR(7)
)
RETURNS TABLE
AS
RETURN
(
	SELECT
		b.CustId,
		b.[CustNum],
		c.[BillDate],
		CASE
			WHEN a.[Type] = 'S'
			THEN
				g.[BasicCharge]
			WHEN a.[Type] = 'P' OR a.[Type] = 'E'
			THEN
				(f.[BasicCharge] * (a.[Value] / 100))
			ELSE
				f.[BasicCharge]
		END AS [Discount]
	FROM
		[Donee_List] a
		LEFT JOIN [Cust] b
			ON a.[OldCustNum] = b.[oldcustnum]
		OUTER APPLY
		(
			SELECT
				[RateId],
				[BillDate],
				[Cons1]
			FROM
				[Rhist]
			WHERE
				CustId = b.CustId
				AND [BillDate] = @BillDate
		) c
		LEFT JOIN [Bill] d
			ON c.[RateId] = d.[RateId] AND b.[ZoneId] = d.[ZoneId]
		OUTER APPLY
		(
			SELECT
				CASE a.[Type]
					WHEN 'S'
					THEN
						c.[Cons1] - a.[Value]
					ELSE
						c.[Cons1]
				END AS [NewCons]
		) e
		OUTER APPLY
        (
            SELECT
                CASE
                    WHEN ISNULL(c.[Cons1], 0) <= 10
					THEN
                        d.[MinBill]
                    WHEN ISNULL(c.[Cons1], 0) > 10 AND ISNULL(c.[Cons1], 0) <= 20
					THEN
                        ((ISNULL(c.[Cons1], 0) - 10) * d.[Rate1]) + d.[MinBill]
                    WHEN ISNULL(c.[Cons1], 0) > 20 AND ISNULL(c.[Cons1], 0) <= 30
					THEN
                        ((ISNULL(c.[Cons1], 0) - 20) * d.[Rate2]) + d.[MinBill] + (d.[Rate1] * 10)
                    WHEN ISNULL(c.[Cons1], 0) > 30 AND ISNULL(c.[Cons1], 0) <= 50
					THEN
                        ((ISNULL(c.[Cons1], 0) - 30) * d.[Rate3]) + d.[MinBill] + (d.[Rate1] * 10) + (d.[Rate2] * 10)
                    WHEN ISNULL(c.[Cons1], 0) > 50 AND ISNULL(c.[Cons1], 0) <= 70 
					THEN
                        ((ISNULL(c.[Cons1], 0) - 50) * d.[Rate4]) + d.[MinBill] + (d.[Rate1] * 10) + (d.[Rate2] * 10) + (d.[Rate3] * 20)
                    WHEN ISNULL(c.[Cons1], 0) > 70  AND ISNULL(c.[Cons1], 0) <= 100
					THEN
                        ((ISNULL(c.[Cons1], 0) - 70) * d.[Rate5]) + d.[MinBill] + (d.[Rate1] * 10) + (d.[Rate2] * 10) + (d.[Rate3] * 20) + (d.[Rate4] * 20)
                    WHEN ISNULL(c.[Cons1], 0) > 100
					THEN
                        ((ISNULL(c.[Cons1], 0) - 100) * d.[Rate6]) + d.[MinBill] + (d.[Rate1] * 10) + (d.[Rate2] * 10) + (d.[Rate3] * 20) + (d.[Rate4] * 20) + (d.[Rate5] * 30)
                END AS [BasicCharge]
        ) f
		OUTER APPLY
        (
            SELECT
                CASE
                    WHEN ISNULL(e.[NewCons], 0) <= 10
					THEN
                        d.[MinBill]
                    WHEN ISNULL(e.[NewCons], 0) > 10 AND ISNULL(e.[NewCons], 0) <= 20
					THEN
                        ((ISNULL(e.[NewCons], 0) - 10) * d.[Rate1]) + d.[MinBill]
                    WHEN ISNULL(e.[NewCons], 0) > 20 AND ISNULL(e.[NewCons], 0) <= 30
					THEN
                        ((ISNULL(e.[NewCons], 0) - 20) * d.[Rate2]) + d.[MinBill] + (d.[Rate1] * 10)
                    WHEN ISNULL(e.[NewCons], 0) > 30 AND ISNULL(e.[NewCons], 0) <= 50
					THEN
                        ((ISNULL(e.[NewCons], 0) - 30) * d.[Rate3]) + d.[MinBill] + (d.[Rate1] * 10) + (d.[Rate2] * 10)
                    WHEN ISNULL(e.[NewCons], 0) > 50 AND ISNULL(e.[NewCons], 0) <= 70 
					THEN
                        ((ISNULL(e.[NewCons], 0) - 50) * d.[Rate4]) + d.[MinBill] + (d.[Rate1] * 10) + (d.[Rate2] * 10) + (d.[Rate3] * 20)
                    WHEN ISNULL(e.[NewCons], 0) > 70  AND ISNULL(e.[NewCons], 0) <= 100
					THEN
                        ((ISNULL(e.[NewCons], 0) - 70) * d.[Rate5]) + d.[MinBill] + (d.[Rate1] * 10) + (d.[Rate2] * 10) + (d.[Rate3] * 20) + (d.[Rate4] * 20)
                    WHEN ISNULL(e.[NewCons], 0) > 100
					THEN
                        ((ISNULL(e.[NewCons], 0) - 100) * d.[Rate6]) + d.[MinBill] + (d.[Rate1] * 10) + (d.[Rate2] * 10) + (d.[Rate3] * 20) + (d.[Rate4] * 20) + (d.[Rate5] * 30)
                END AS [BasicCharge]
        ) g
)

GO


