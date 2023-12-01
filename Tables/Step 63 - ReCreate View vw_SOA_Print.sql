ALTER VIEW [dbo].[vw_SOA_Print]
AS
Select
	b.CustId as CustId,
		b.[CustNum] AS [CustNum],
		b.[oldcustnum] AS [OldCustNum],
		b.[CustName] AS [CustName],
		b.[BilStAdd] AS [BilStAdd],
		b.[BilCtAdd] AS [BilCtAdd],
		RTRIM(b.[cbank_ref]) + REPLACE(RIGHT(a.[DueDate], 5), '/', '') AS [BankRef],
		Books.BookId AS [BookId],
		Books.BookNo AS [BookNo],
		j.[MeterNo1] AS [MeterNo],
		h.[RateName] AS [RateName],
		CONVERT(VARCHAR, j.[BillNum]) AS [BillNum],
		a.[BillDate] AS [BillDate],
		a.[DueDate] AS [DueDate],
		a.[Duedate2] AS [DueDate2],
		ISNULL(f.[BillPeriod], '') AS [BillPeriod],
		g.[Pread1] AS [PrevRdg],
		g.[Read1] AS [CurrRdg],
		CONVERT(DECIMAL(18, 0), g.[Cons1]) AS [Cons],
		CONVERT(VARCHAR, CONVERT(MONEY, a.[SubTot1]), 1) AS [Basic],
		CONVERT(VARCHAR, CONVERT(MONEY, a.[BillAmnt]), 1) AS [BillAmount],
		ISNULL(a.[BillDtls], '') AS [BillDetails],
		ISNULL(a.[Dunning], '') AS [Dunning],

		-- || EVAT ----------------------------------------------------------------------------------------------------------------

		'' AS [Evat],


		-- || Senior Current Discount ---------------------------------------------------------------------------------------------

		CASE
			WHEN (b.[SeniorDate] >= GETDATE() AND g.[Cons1] <= 30)
			THEN '-' + CONVERT(VARCHAR, CONVERT(MONEY, a.[Subtot1] * 0.05), 1)

		ELSE '' END
		AS [SeniorDiscount],

		-- || SOA Individual Items ------------------------------------------------------------------------------------------------

		'Total Current Bill' AS [Item01],
		CONVERT(VARCHAR, CONVERT(MONEY,
			a.[SubTot1] -
			CASE
				WHEN (b.[SeniorDate] >= GETDATE() AND g.[Cons1] <= 30)
				THEN CONVERT(DECIMAL(18, 2), a.[Subtot1] * 0.05)

			ELSE 0 END
		), 1)
		AS [Value01],

		---------------------------------------------------------------------------------------------------------------------------

		'Residential Discount' AS [Item02],
		'-' + CONVERT(VARCHAR, CONVERT(MONEY,
			a.[SubTot2]
		), 1)
		AS [Value02],

		---------------------------------------------------------------------------------------------------------------------------

		'' AS [Item03], '' AS [Value03],

		---------------------------------------------------------------------------------------------------------------------------

		'Balance from Last Bill' AS [Item04],
		CONVERT(VARCHAR, CONVERT(MONEY,
			ISNULL(k.[BAL], 0) +
			CASE
				WHEN ISNULL(i.[end_procfee], 0) > 0
				THEN ISNULL(l.[Old Arrears], 0) - ISNULL(i.[end_procfee], 0)
				ELSE ISNULL(l.[Old Arrears], 0)
			END
		), 1)
		AS [Value04],

		---------------------------------------------------------------------------------------------------------------------------

		'Other Charges' AS [Item05],
		'' AS [Value05],

		---------------------------------------------------------------------------------------------------------------------------

		'Penalty Charges' AS [Item06],
		CONVERT(VARCHAR, CONVERT(MONEY,
			ISNULL(l.[Penalty Balance], 0)
		), 1)
		AS [Value06],

		---------------------------------------------------------------------------------------------------------------------------

		'PN Amortization' AS [Item07],
		CONVERT(VARCHAR, CONVERT(MONEY,
			ISNULL(i.[pn_remit], 0)
		), 1)
		AS [Value07],

		---------------------------------------------------------------------------------------------------------------------------

		'Meter Charge' AS [Item08],
		CONVERT(VARCHAR, CONVERT(MONEY,
			ISNULL(a.[SubTot5], 0)
		), 1)
		AS [Value08],

		---------------------------------------------------------------------------------------------------------------------------

		'Septage' AS [Item09],
		CONVERT(VARCHAR, CONVERT(MONEY,
			ISNULL(a.[SubTot3], 0)
		), 1)
		AS [Value09],

		---------------------------------------------------------------------------------------------------------------------------

		'' AS [Item10],
		0
		AS [Value10],

		---------------------------------------------------------------------------------------------------------------------------

		'[Test Item 02]' AS [Item11], '###.##' AS [Value11],
		'[Test Item 03]' AS [Item12], '###.##' AS [Value12],

		---------------------------------------------------------------------------------------------------------------------------

		CASE
			WHEN a.[BillDate] IN ('2020/07', '2020/08')
			THEN 'Total Amount Due'
			ELSE ''
		END
		AS [Item13],

		---------------------------------------------------------------------------------------------------------------------------

		CASE
			WHEN a.[BillDate] IN ('2020/07', '2020/08')
			THEN
				CONVERT(VARCHAR, CONVERT(MONEY,
					[TotalAmountDue].[TotalAmountDue]
				), 1)
			ELSE ''
		END
		AS [Value13],

		---------------------------------------------------------------------------------------------------------------------------

		'Total Amount Due'
		AS [Item14],

		---------------------------------------------------------------------------------------------------------------------------

		CONVERT(VARCHAR, CONVERT(MONEY,
		[TotalAmountDue].[TotalAmountDue]
		), 1)
		AS [Value14],

		---------------------------------------------------------------------------------------------------------------------------

		'Amount After Due Date (Php)' AS [Item15],

		---------------------------------------------------------------------------------------------------------------------------

		CONVERT(VARCHAR, CONVERT(MONEY,
			[AmountAfterDueDate].[AmountAfterDueDate]
		), 1)
		AS [Value15],

		-- || Remarks Type: -------------------------------------------------------------------------------------------------------
		-- ||   0 = None
		-- ||   1 = Standard Remarks ([BillDetails] from [Cbill])
		-- ||   2 = Static Remarks ("Check Payments, Payable to PrimeWater Infrastructure Corp.")
		-- ||   3 = Both Standard and Static Remarks
		-- ||   (note: static remarks not applicable on Dasma)
		3 AS [RemarksType],

		-- || (for specific water district(s) only): Munoz ------------------------------------------------------------------------

		CONVERT(VARCHAR, CONVERT(MONEY,
			[TotalAmountDue].[TotalAmountDue]), 1)
		AS [AmountBeforeDueDate],

		-- || (for specific water district(s) only): Dasma ------------------------------------------------------------------------

		CASE
			WHEN LEFT(b.[RateId], 1) IN ('G', 'g', 'B', 'b') OR i.[pn_remit] > 0
			THEN
				''
			ELSE
				CONVERT(VARCHAR, DATEADD(DAY, 1, CONVERT(DATETIME, a.[DueDate])), 111)
		END AS [DueDate01],

		---------------------------------------------------------------------------------------------------------------------------

		CASE
			WHEN LEFT(b.[RateId], 1) IN ('G', 'g') OR i.[pn_remit] > 0
			THEN
				CONVERT(VARCHAR, CONVERT(MONEY,
					[TotalAmountDue].[TotalAmountDue] - (a.[SubTot1] * 0.10)
				), 1)
			WHEN LEFT(b.[RateId], 1) IN ('B', 'b')
			THEN
				''
			ELSE
				CONVERT(VARCHAR, CONVERT(MONEY,
					[TotalAmountDue].[TotalAmountDue] + (a.[SubTot1] * 0.01)
				), 1)
		END AS [DueAmount01],

		---------------------------------------------------------------------------------------------------------------------------

		CASE
			WHEN LEFT(b.[RateId], 1) IN ('G', 'g', 'B', 'b') OR i.[pn_remit] > 0
			THEN
				''
			ELSE
				CONVERT(VARCHAR, DATEADD(DAY, 2, CONVERT(DATETIME, a.[DueDate])), 111)
		END AS [DueDate02],

		---------------------------------------------------------------------------------------------------------------------------

		CASE
			WHEN LEFT(b.[RateId], 1) IN ('G', 'g', 'B', 'b') OR i.[pn_remit] > 0
			THEN
				''
			ELSE
				CONVERT(VARCHAR, CONVERT(MONEY,
					[TotalAmountDue].[TotalAmountDue] + (a.[SubTot1] * 0.02)
				), 1)
		END AS [DueAmount02],

		---------------------------------------------------------------------------------------------------------------------------

		CASE
			WHEN LEFT(b.[RateId], 1) IN ('G', 'g', 'B', 'b') OR i.[pn_remit] > 0
			THEN
				''
			ELSE
				CONVERT(VARCHAR, DATEADD(DAY, 3, CONVERT(DATETIME, a.[DueDate])), 111)
		END AS [DueDate03],

		---------------------------------------------------------------------------------------------------------------------------

		
		CASE
			WHEN LEFT(b.[RateId], 1) IN ('G', 'g', 'B', 'b') OR i.[pn_remit] > 0
			THEN
				''
			ELSE
				CONVERT(VARCHAR, CONVERT(MONEY,
					[TotalAmountDue].[TotalAmountDue] + (a.[SubTot1] * 0.03)
				), 1)
		END AS [DueAmount03],

		---------------------------------------------------------------------------------------------------------------------------

		CASE
			WHEN LEFT(b.[RateId], 1) IN ('G', 'g', 'B', 'b') OR i.[pn_remit] > 0
			THEN
				''
			ELSE
				CONVERT(VARCHAR, DATEADD(DAY, 4, CONVERT(DATETIME, a.[DueDate])), 111)
		END AS [DueDate04],

		---------------------------------------------------------------------------------------------------------------------------

		CASE
			WHEN LEFT(b.[RateId], 1) IN ('G', 'g', 'B', 'b') OR i.[pn_remit] > 0
			THEN
				''
			ELSE
				CONVERT(VARCHAR, CONVERT(MONEY,
					[TotalAmountDue].[TotalAmountDue] + (a.[SubTot1] * 0.04)
				), 1)
		END AS [DueAmount04],

		---------------------------------------------------------------------------------------------------------------------------

		CASE
			WHEN LEFT(b.[RateId], 1) IN ('G', 'g', 'B', 'b') OR i.[pn_remit] > 0
			THEN
				''
			ELSE
				CONVERT(VARCHAR, DATEADD(DAY, 5, CONVERT(DATETIME, a.[DueDate])), 111)
		END AS [DueDate05],

		---------------------------------------------------------------------------------------------------------------------------

		CASE
			WHEN LEFT(b.[RateId], 1) IN ('G', 'g', 'B', 'b') OR i.[pn_remit] > 0
			THEN
				''
			ELSE
				CONVERT(VARCHAR, CONVERT(MONEY,
					[TotalAmountDue].[TotalAmountDue] + (a.[SubTot1] * 0.05)
				), 1)
		END AS [DueAmount05],

		---------------------------------------------------------------------------------------------------------------------------

		CASE
			WHEN LEFT(b.[RateId], 1) IN ('G', 'g', 'B', 'b') OR i.[pn_remit] > 0
			THEN
				''
			ELSE
				CONVERT(VARCHAR, DATEADD(DAY, 6, CONVERT(DATETIME, a.[DueDate])), 111)
		END AS [DueDate06],

		---------------------------------------------------------------------------------------------------------------------------

		CASE
			WHEN LEFT(b.[RateId], 1) IN ('G', 'g', 'B', 'b') OR i.[pn_remit] > 0
			THEN
				''
			ELSE
				CONVERT(VARCHAR, CONVERT(MONEY,
					[TotalAmountDue].[TotalAmountDue] + (a.[SubTot1] * 0.06)
				), 1)
		END AS [DueAmount06],

		---------------------------------------------------------------------------------------------------------------------------

		CASE
			WHEN LEFT(b.[RateId], 1) IN ('G', 'g', 'B', 'b') OR i.[pn_remit] > 0
			THEN
				''
			ELSE
				CONVERT(VARCHAR, DATEADD(DAY, 7, CONVERT(DATETIME, a.[DueDate])), 111)
		END AS [DueDate07],

		---------------------------------------------------------------------------------------------------------------------------

		CASE
			WHEN LEFT(b.[RateId], 1) IN ('G', 'g', 'B', 'b') OR i.[pn_remit] > 0
			THEN
				''
			ELSE
				CONVERT(VARCHAR, CONVERT(MONEY,
					[TotalAmountDue].[TotalAmountDue] + (a.[SubTot1] * 0.07)
				), 1)
		END AS [DueAmount07],

		---------------------------------------------------------------------------------------------------------------------------

		CASE
			WHEN LEFT(b.[RateId], 1) IN ('G', 'g', 'B', 'b') OR i.[pn_remit] > 0
			THEN
				''
			ELSE
				CONVERT(VARCHAR, DATEADD(DAY, 8, CONVERT(DATETIME, a.[DueDate])), 111)
		END AS [DueDate08],

		---------------------------------------------------------------------------------------------------------------------------

		CASE
			WHEN LEFT(b.[RateId], 1) IN ('G', 'g', 'B', 'b') OR i.[pn_remit] > 0
			THEN
				''
			ELSE
				CONVERT(VARCHAR, CONVERT(MONEY,
					[TotalAmountDue].[TotalAmountDue] + (a.[SubTot1] * 0.08)
				), 1)
		END AS [DueAmount08],

		---------------------------------------------------------------------------------------------------------------------------

		CASE
			WHEN LEFT(b.[RateId], 1) IN ('G', 'g', 'B', 'b') OR i.[pn_remit] > 0
			THEN
				''
			ELSE
				CONVERT(VARCHAR, DATEADD(DAY, 9, CONVERT(DATETIME, a.[DueDate])), 111)
		END AS [DueDate09],

		---------------------------------------------------------------------------------------------------------------------------

		CASE
			WHEN LEFT(b.[RateId], 1) IN ('G', 'g', 'B', 'b') OR i.[pn_remit] > 0
			THEN
				''
			ELSE
				CONVERT(VARCHAR, CONVERT(MONEY,
					[TotalAmountDue].[TotalAmountDue] + (a.[SubTot1] * 0.09)
				), 1)
		END AS [DueAmount09],

		---------------------------------------------------------------------------------------------------------------------------

		CASE
			WHEN LEFT(b.[RateId], 1) IN ('G', 'g', 'B', 'b') OR i.[pn_remit] > 0
			THEN
				''
			ELSE
				CONVERT(VARCHAR, DATEADD(DAY, 10, CONVERT(DATETIME, a.[DueDate])), 111)
		END AS [DueDate10],

		---------------------------------------------------------------------------------------------------------------------------

		CASE
			WHEN LEFT(b.[RateId], 1) IN ('G', 'g', 'B', 'b') OR i.[pn_remit] > 0
			THEN
				''
			ELSE
				CONVERT(VARCHAR, CONVERT(MONEY,
					[TotalAmountDue].[TotalAmountDue] + (a.[SubTot1] * 0.1)
				), 1)
		END AS [DueAmount10],

		---------------------------------------------------------------------------------------------------------------------------

		'14' AS [BillAmountDueColumn],
		'14' AS [MinAmountDueColumn],
		'Yes' AS [HasDueDate],
		'Yes' AS [ShowPreparedBy],

		
		'' AS [BusinessStyle]

	FROM
		[dbo].[Cbill] a
		INNER JOIN [dbo].[Cust] b
			ON a.[CustId] = b.[CustId]
		INNER JOIN
		(
			SELECT
				[CustId],
				MAX([BillDate]) [BillDate]
			FROM
				[Cbill]
			GROUP BY [CustId]
		) c
			ON a.[CustId] = c.[CustId]
			AND a.[BillDate] = c.[BillDate]
		INNER JOIN [dbo].[TBill] f
			ON a.Billnum = f.Billnum
		INNER JOIN [dbo].[Rhist] g
			ON a.RhistId = g.RhistId
		INNER JOIN [dbo].[Rates] h
			ON g.[RateId] = h.[RateId]
		INNER JOIN [dbo].[Members] j
			ON a.CustId = j.CustId
		INNER JOIN [vw_ledger] l
			ON a.CustId = l.CustId
		INNER JOIN Books
		on j.BookId = Books.BookId

		---------------------------------------------------------------------------------------------------------------------------

		LEFT JOIN
		(
			SELECT
				x.CustId,
				SUM(ISNULL(x.[debit], 0) - ISNULL(x.[credit], 0)) AS [BAL]
			FROM
				[cust_ledger] x
				INNER JOIN
				(
					SELECT
						CustId,
						MAX([Rdate]) [Rdate]
					FROM
						[Rhist]
					WHERE
						[nbasic] > 0
					GROUP BY
						CustId
				) y
					ON x.CustId = y.CustId
					AND
					(
						x.[ledger_type] <> 'Guarantee Deposit' 
						AND x.[ledger_type] <> 'Penalty'
						AND x.[ledger_type] <> 'Old Arrears'
					)
					AND
					(
						x.[trans_date] IS NULL
						OR CONVERT(VARCHAR(20), x.[trans_date], 111) < CONVERT(VARCHAR(20), y.[Rdate], 111)
					)
			GROUP BY
				x.CustId
		) k
			ON a.CustId = k.CustId

		---------------------------------------------------------------------------------------------------------------------------

		LEFT JOIN
		(
			SELECT
				w.CustId,
				(y.[SubTot1] - y.[SubTot2]) + [SubTot3] + [SubTot5] AS [SubTot1]
			FROM
			(
				SELECT
					CustId,
					MAX([BillDate]) [BillDate]
				FROM
					[Cbill]
				GROUP BY CustId
			) w
			INNER JOIN [Rhist] x
				ON w.CustId = x.CustId
				AND w.[BillDate] = x.[BillDate]
			LEFT JOIN [Cbill] y
				ON w.CustId = y.CustId
				AND w.[BillDate] = y.[BillDate]
				AND y.[BillStat] <> 1		
		) ibabawas
			ON a.CustId = ibabawas.CustId

		---------------------------------------------------------------------------------------------------------------------------

		LEFT JOIN
		(
			SELECT
				w.CustId,
				SUM([Subtot1] + [Subtot2] + [Subtot3] + [Subtot7] + [Subtot10] + [Subtot12] + [Subtot13] + [Subtot14]) AS [Subtot1]
			FROM
			(
				SELECT
					CustId,
					MAX([BillDate]) [BillDate]
				FROM
					[Cbill]
				GROUP BY CustId
			) w
			INNER JOIN [Rhist] x
				ON w.CustId = x.CustId
				AND w.[BillDate] = x.[BillDate]
			LEFT JOIN [Cpaym] y
				ON w.CustId = y.CustId
				AND x.[Rdate] < y.[PayDate]
				AND y.[PymntStat] <> 1
			GROUP BY w.CustId
		) idadagdag
			ON a.CustId = idadagdag.CustId

		---------------------------------------------------------------------------------------------------------------------------

		LEFT JOIN
		(
			SELECT
				*
			FROM
				[PN1]
			WHERE
				[end_bal] > 0
		) i
			ON a.CustId = i.CustId

		---------------------------------------------------------------------------------------------------------------------------

		LEFT JOIN [CbillOthers] ff
			ON a.BillNum = ff.BillNum
		INNER JOIN [Bill]
			ON [Bill].[RateId] = b.[RateId] AND [Bill].ZoneId = b.[ZoneId]
		

		-- || Computation: Total Amount Due ---------------------------------------------------------------------------------------

		OUTER APPLY
		(
			SELECT
				(
					(
					a.[Subtot1] - a.[Subtot2]																	-- Basic Charge 
						- CASE																					-- Senior Current Discount
							WHEN (b.[SeniorDate] >= GETDATE() AND g.[Cons1] <= 30)
							THEN CONVERT(DECIMAL(18, 2), a.[Subtot1] * 0.05)
							
							ELSE 0
							END
					)
					+ l.[Penalty Balance]																		-- Penalty
					+ CASE
							WHEN ISNULL(i.[end_procfee], 0) > 0													-- Old Arrears
							THEN ISNULL(l.[Old Arrears], 0) - ISNULL(i.[end_procfee], 0)
							ELSE ISNULL(l.[Old Arrears], 0)
						END
					+
					(
					ISNULL(k.[BAL], 0)																			-- Arrears
						- CASE
							WHEN (b.[SeniorDate] >= GETDATE() AND g.[Cons1] <= 30 AND ISNULL(k.[BAL], 0) > 0)
							THEN CONVERT(DECIMAL(18, 2), ISNULL(k.[BAL], 0) * 0.05)
							
							ELSE 0
							END
					)
					+ 0																							-- LCA/PCA
					+ ISNULL(a.[SubTot5], 0)																	-- Meter Charge
					+ ISNULL(i.[pn_remit], 0)																	-- PN Monthly Amortization
					+ a.[SubTot3]																				-- Sewerage
				)
				- CASE WHEN i.[nwatfee] > 0																		-- PN Ending Balance
					THEN i.[end_bal]
					ELSE 0
					END
			AS [TotalAmountDue]
		) [TotalAmountDue]

		-- || Computation: Installment --------------------------------------------------------------------------------------------

		

		-- || Computation: Minimum Amount Due -------------------------------------------------------------------------------------

		

		-- || Computation: Percent Penalty ----------------------------------------------------------------------------------------
		

		-- || Computation: Amount After Due ---------------------------------------------------------------------------------------

		OUTER APPLY
		(
			SELECT

					(
						(
						a.[Subtot1] - a.[Subtot2]																	-- Basic Charge
							- CASE																					-- Senior Current Discount
								WHEN (b.[SeniorDate] >= GETDATE() AND g.[Cons1] <= 30)
								THEN CONVERT(DECIMAL(18, 2), a.[Subtot1] * 0.05)

								ELSE 0
								END
						)
						+ l.[Penalty Balance]																		-- Penalty
						+ CASE WHEN ISNULL(i.[end_procfee], 0) > 0													-- Old Arrears
								THEN ISNULL(l.[Old Arrears], 0) - ISNULL(i.[end_procfee], 0)
								ELSE ISNULL(l.[Old Arrears], 0)
							END
						+
						(																							-- Discounted Basic Penalty
							(
							a.[Subtot1]
								-- remove this line for basic penalty (instead of discounted basic penalty)
								- CASE WHEN (b.[SeniorDate] >= GETDATE() AND g.[Cons1] <= 30)
									THEN CONVERT(DECIMAL(18, 2), a.[Subtot1] * 0.05)
									
									ELSE 0
									END
							)
							* 0.1
						)
						+ ISNULL(k.[BAL], 0)																		-- Arrears
						+ 0																							-- LCA/PCA
						+ ISNULL(a.[SubTot5], 0)																	-- Meter Charge
						+ ISNULL(i.[pn_remit], 0)																	-- PN Monthly Amortization
						+ a.[SubTot3]	

					- CASE WHEN i.[nwatfee] > 0																		-- PN Ending Balance
						THEN i.[end_bal]
						ELSE 0
						END	

			)AS [AmountAfterDueDate]
		) [AmountAfterDueDate]
	WHERE
		(a.[BillAmnt] IS NOT NULL)