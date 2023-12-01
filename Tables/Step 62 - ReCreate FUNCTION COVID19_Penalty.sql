ALTER FUNCTION [dbo].[COVID19_Penalty]
(
	@CustId int,
	@Instance INT = 0
)
RETURNS @ArrearsTable TABLE
(
	[FebBalance] DECIMAL(18, 2),
	[MarArrears] DECIMAL(18, 2),
	[AprArrears] DECIMAL(18, 2),
	[MayArrears] DECIMAL(18, 2),
	[JunArrears] DECIMAL(18, 2),
	[JulArrears] DECIMAL(18, 2),
	[AugArrears] DECIMAL(18, 2),
	[FebPenalty] DECIMAL(18, 2),
	[MarBillDiscount] DECIMAL(18, 2),
	[AprBillDiscount] DECIMAL(18, 2),
	[MayBillDiscount] DECIMAL(18, 2),
	[JunBillDiscount] DECIMAL(18, 2),
	[JulBillDiscount] DECIMAL(18, 2),
	[AugBillDiscount] DECIMAL(18, 2),
	[MarMeterCharge] DECIMAL(18, 2),
	[AprMeterCharge] DECIMAL(18, 2),
	[MayMeterCharge] DECIMAL(18, 2),
	[JunMeterCharge] DECIMAL(18, 2),
	[JulMeterCharge] DECIMAL(18, 2),
	[AugMeterCharge] DECIMAL(18, 2),
	[MarSeptage] DECIMAL(18, 2),
	[AprSeptage] DECIMAL(18, 2),
	[MaySeptage] DECIMAL(18, 2),
	[JunSeptage] DECIMAL(18, 2),
	[JulSeptage] DECIMAL(18, 2),
	[AugSeptage] DECIMAL(18, 2)
)
AS
BEGIN
	----------------------------------------------------------------------------------------------------------------------------------
	----------------------------------------------------------------------------------------------------------------------------------
	-- || @Instance:
	-- ||   0 - June 2020 GCQ
	-- ||   1 - July 2020 GCQ (water only)
	-- ||   2 - July 2020 GCQ (water, meter charge, sewerage)
	----------------------------------------------------------------------------------------------------------------------------------
	----------------------------------------------------------------------------------------------------------------------------------

	IF @Instance = 0
	----------------------------------------------------------------------------------------------------------------------------------
	----------------------------------------------------------------------------------------------------------------------------------
	-- || June 2020 Original GCQ Arrears Computation
	-- || (including contributed codes from IT specialists)
	----------------------------------------------------------------------------------------------------------------------------------
	----------------------------------------------------------------------------------------------------------------------------------
	BEGIN
		DECLARE @MarReadDate VARCHAR(10), @AprReadDate VARCHAR(10), @MayReadDate VARCHAR(10), @JunReadDate VARCHAR(10)
		DECLARE @JulReadDate VARCHAR(10), @AugReadDate VARCHAR(10)
		DECLARE @FebBalance DECIMAL(18, 2), @MarCurrent DECIMAL(18, 2), @MarAdjust DECIMAL(18, 2)
		DECLARE @AprCurrent DECIMAL(18, 2), @AprArrears DECIMAL(18, 2), @AprAdjust DECIMAL(18, 2)
		DECLARE @MayCurrent DECIMAL(18, 2), @MayArrears DECIMAL(18, 2), @MayAdjust DECIMAL(18, 2)

		DECLARE @MarPayCurrent DECIMAL(18, 2), @MarPayAdvance DECIMAL(18, 2), @MarPayDiscCurrent DECIMAL(18, 2), @MarPayDiscArrears DECIMAL(18, 2)
		DECLARE @AprPayCurrent DECIMAL(18, 2), @AprPayArrears DECIMAL(18, 2), @AprPayAdvance DECIMAL(18, 2), @AprPayDiscCurrent DECIMAL(18, 2), @AprPayDiscArrears DECIMAL(18, 2)
		DECLARE @MayPayCurrent DECIMAL(18, 2), @MayPayArrears DECIMAL(18, 2), @MayPayAdvance DECIMAL(18, 2), @MayPayDiscCurrent DECIMAL(18, 2), @MayPayDiscArrears DECIMAL(18, 2)
		DECLARE @JunPayArrears DECIMAL(18, 2), @JulPayArrears DECIMAL(18, 2)

		DECLARE @MarFinalArrears DECIMAL(18, 2)
		DECLARE @AprFinalArrears DECIMAL(18, 2)
		DECLARE @MayFinalArrears DECIMAL(18, 2)

		--Harold Start
		DECLARE @MarDiscount DECIMAL(18, 2)
		DECLARE @AprDiscount DECIMAL(18, 2)
		DECLARE @MayDiscount DECIMAL(18, 2)

		SET @MarDiscount = (SELECT CASE WHEN Cust.SeniorDate >= getdate() and Rhist.Cons1 <=30 THEN (nbasic * 0.05) ELSE
							0
							-- uncomment next line (and delete the line above) for first 30 (or 50) cons discount on cons higher than 30 (or 50)
							--Bill.MinBill + (Bill.Rate1 * 10) + (bill.Rate2 * 10)
							END AS DISCOUNT
							FROM Cust INNER JOIN Rhist ON Cust.CustId = Rhist.CustId
							-- uncomment next line for first 30 (or 50) cons discount on cons higher than 30 (or 50)
							--LEFT JOIN Bill ON Cust.Zoneno = Bill.BillType AND Cust.Rate = Bill.RateCd
							WHERE Rhist.BillDate = '2020/03' AND Cust.CustId = @CustId)

		SET @AprDiscount = (SELECT CASE WHEN Cust.SeniorDate >= getdate() and Rhist.Cons1 <=30 THEN (nbasic * 0.05) ELSE
							0
							-- uncomment next line (and delete the line above) for first 30 (or 50) cons discount on cons higher than 30 (or 50)
							--Bill.MinBill + (Bill.Rate1 * 10) + (bill.Rate2 * 10)
							END AS DISCOUNT
							FROM Cust INNER JOIN Rhist ON Cust.CustId = Rhist.CustId
							-- uncomment next line for first 30 (or 50) cons discount on cons higher than 30 (or 50)
							--LEFT JOIN Bill ON Cust.Zoneno = Bill.BillType AND Cust.Rate = Bill.RateCd
							WHERE Rhist.BillDate = '2020/04' AND Cust.CustId = @CustId)

		SET @MayDiscount = (SELECT CASE WHEN Cust.SeniorDate >= getdate() and Rhist.Cons1 <=30 THEN (nbasic * 0.05) ELSE
							0
							-- uncomment next line (and delete the line above) for first 30 (or 50) cons discount on cons higher than 30 (or 50)
							--Bill.MinBill + (Bill.Rate1 * 10) + (bill.Rate2 * 10)
							END AS DISCOUNT
							FROM Cust INNER JOIN Rhist ON Cust.CustId = Rhist.CustId
							-- uncomment next line for first 30 (or 50) cons discount on cons higher than 30 (or 50)
							--LEFT JOIN Bill ON Cust.Zoneno = Bill.BillType AND Cust.Rate = Bill.RateCd
							WHERE Rhist.BillDate = '2020/05' AND Cust.CustId = @CustId)
		--Harold End

		--Rebate Start
		/*
		DECLARE @MarRebate DECIMAL(18, 2)
		DECLARE @AprRebate DECIMAL(18, 2)
		DECLARE @MayRebate DECIMAL(18, 2)

		SET @MarRebate = (SELECT [Amount] FROM [rebate_monthly] WHERE [CustNum] = @CustNum AND [BillDate] = '2020/03')
		SET @AprRebate = (SELECT [Amount] FROM [rebate_monthly] WHERE [CustNum] = @CustNum AND [BillDate] = '2020/04')
		SET @MayRebate = (SELECT [Amount] FROM [rebate_monthly] WHERE [CustNum] = @CustNum AND [BillDate] = '2020/05')
		*/
		--Rebate End

		SET @MarReadDate = (SELECT [Rdate] FROM [Rhist] WHERE CustId = @CustId AND [BillDate] = '2020/03')
		SET @MarReadDate = CASE ISDATE(@MarReadDate) WHEN 1 THEN CONVERT(VARCHAR(20), CONVERT(DATETIME, @MarReadDate), 111) ELSE '2020/03/01' END

		SET @AprReadDate = (SELECT [Rdate] FROM [Rhist] WHERE CustId = @CustId AND [BillDate] = '2020/04')
		SET @AprReadDate = CASE ISDATE(@AprReadDate) WHEN 1 THEN CONVERT(VARCHAR(20), CONVERT(DATETIME, @AprReadDate), 111) ELSE '2020/04/01' END

		SET @MayReadDate = (SELECT [Rdate] FROM [Rhist] WHERE CustId = @CustId AND [BillDate] = '2020/05')
		SET @MayReadDate = CASE ISDATE(@MayReadDate) WHEN 1 THEN CONVERT(VARCHAR(20), CONVERT(DATETIME, @MayReadDate), 111) ELSE '2020/05/01' END

		SET @JunReadDate = (SELECT [Rdate] FROM [Rhist] WHERE CustId = @CustId AND [BillDate] = '2020/06')
		SET @JunReadDate = CASE ISDATE(@JunReadDate) WHEN 1 THEN CONVERT(VARCHAR(20), CONVERT(DATETIME, @JunReadDate), 111) ELSE '2020/06/01' END

		SET @JulReadDate = (SELECT [Rdate] FROM [Rhist] WHERE CustId = @CustId AND [BillDate] = '2020/07')
		SET @JulReadDate = CASE ISDATE(@JulReadDate) WHEN 1 THEN CONVERT(VARCHAR(20), CONVERT(DATETIME, @JulReadDate), 111) ELSE '2020/07/01' END

		SET @AugReadDate = (SELECT [Rdate] FROM [Rhist] WHERE CustId = @CustId AND [BillDate] = '2020/08')
		SET @AugReadDate = CASE ISDATE(@AugReadDate) WHEN 1 THEN CONVERT(VARCHAR(20), CONVERT(DATETIME, @AugReadDate), 111) ELSE '2020/08/01' END

		-- 7.0+
		SET @FebBalance = (SELECT ISNULL(SUM([Debit]), 0) - ISNULL(SUM([Credit]), 0) FROM [cust_ledger] WHERE CustId = @CustId AND [posting_date] < CONVERT(DATETIME, @MarReadDate))
		-- 6.0-
		--SET @FebBalance = (SELECT ISNULL(SUM([Amount]), 0) FROM [CLedger] WHERE [CustNum] = @CustNum AND [Pdate] < CONVERT(DATETIME, @MarReadDate))

		SET @MarCurrent = (SELECT [Subtot1] - [Subtot2] FROM [Cbill] WHERE CustId = @CustId AND [BillDate] = '2020/03')
		SET @MarCurrent = ISNULL(@MarCurrent, 0)
		-- 7.0+
		SET @MarAdjust = (SELECT ISNULL(SUM([Debit]), 0) - ISNULL(SUM([Credit]), 0) FROM [cust_ledger] WHERE CustId = @CustId AND [posting_date] >= CONVERT(DATETIME, @MarReadDate) AND [posting_date] < CONVERT(DATETIME, @AprReadDate) AND [transaction_type] IN (4, 5, 10) AND [ledger_type] = 'WATER' AND [ledger_subtype] != 'BEG')
		-- 6.0-
		--SET @MarAdjust = (SELECT ISNULL(SUM([Amount]), 0) FROM [CLedger] WHERE [CustNum] = @CustNum AND [Pdate] >= CONVERT(DATETIME, @MarReadDate) AND [Pdate] < CONVERT(DATETIME, @AprReadDate) AND [Type] = '3' AND [Amount] >= 0)

		SELECT @AprCurrent = [Subtot1] - [Subtot2], @AprArrears = [Subtot4] FROM [Cbill] WHERE CustId = @CustId AND [BillDate] = '2020/04'
		SET @AprCurrent = ISNULL(@AprCurrent, 0)
		SET @AprArrears = ISNULL(@AprArrears, 0)
		-- 7.0+
		SET @AprAdjust = (SELECT ISNULL(SUM([Debit]), 0) - ISNULL(SUM([Credit]), 0) FROM [cust_ledger] WHERE CustId = @CustId AND [posting_date] >= CONVERT(DATETIME, @AprReadDate) AND [posting_date] < CONVERT(DATETIME, @MayReadDate) AND [transaction_type] IN (4, 5, 10) AND [ledger_type] = 'WATER' AND [ledger_subtype] != 'BEG')
		-- 6.0-
		--SET @AprAdjust = (SELECT ISNULL(SUM([Amount]), 0) FROM [CLedger] WHERE [CustNum] = @CustNum AND [Pdate] >= CONVERT(DATETIME, @AprReadDate) AND [Pdate] < CONVERT(DATETIME, @MayReadDate) AND [Type] = '3' AND [Amount] >= 0)

		SELECT @MayCurrent = [Subtot1] - [Subtot2], @MayArrears = [Subtot4] FROM [Cbill] WHERE CustId = @CustId AND [BillDate] = '2020/05'
		SET @MayCurrent = ISNULL(@MayCurrent, 0)
		SET @MayArrears = ISNULL(@MayArrears, 0)
		-- 7.0+
		SET @MayAdjust = (SELECT ISNULL(SUM([Debit]), 0) - ISNULL(SUM([Credit]), 0) FROM [cust_ledger] WHERE CustId = @CustId AND [posting_date] >= CONVERT(DATETIME, @MayReadDate) AND [posting_date] < CONVERT(DATETIME, @JunReadDate) AND [transaction_type] IN (4, 5, 10) AND [ledger_type] = 'WATER' AND [ledger_subtype] != 'BEG')
		-- 6.0-
		--SET @MayAdjust = (SELECT ISNULL(SUM([Amount]), 0) FROM [CLedger] WHERE [CustNum] = @CustNum AND [Pdate] >= CONVERT(DATETIME, @MayReadDate) AND [Pdate] < CONVERT(DATETIME, @JunReadDate) AND [Type] = '3' AND [Amount] >= 0)

		SELECT
			@MarPayCurrent = SUM([Subtot1]),
			@MarPayAdvance = SUM([Subtot3]),
			@MarPayDiscArrears = SUM([Tax2]),
			@MarPayDiscCurrent = SUM([Subtot10]) - SUM([Tax2])
		FROM
			[Cpaym]
		WHERE
			CustId = @CustId
			AND [PayDate] >= @MarReadDate
			AND [PayDate] < @AprReadDate

		SET @MarPayCurrent = ISNULL(@MarPayCurrent, 0)
		SET @MarPayAdvance = ISNULL(@MarPayAdvance, 0)
		SET @MarPayDiscArrears = ISNULL(@MarPayDiscArrears, 0)
		SET @MarPayDiscCurrent = ISNULL(@MarPayDiscCurrent, 0)

		SELECT
			@AprPayCurrent = SUM([Subtot1]),
			@AprPayArrears = SUM([Subtot2]),
			@AprPayAdvance = SUM([Subtot3]),
			@AprPayDiscArrears = SUM([Tax2]),
			@AprPayDiscCurrent = SUM([Subtot10]) - SUM([Tax2])
		FROM
			[Cpaym]
		WHERE
			CustId = @CustId
			AND [PayDate] >= @AprReadDate
			AND [PayDate] < @MayReadDate

		SET @AprPayCurrent = ISNULL(@AprPayCurrent, 0)
		SET @AprPayArrears = ISNULL(@AprPayArrears, 0)
		SET @AprPayAdvance = ISNULL(@AprPayAdvance, 0)
		SET @AprPayDiscArrears = ISNULL(@AprPayDiscArrears, 0)
		SET @AprPayDiscCurrent = ISNULL(@AprPayDiscCurrent, 0)

		SELECT
			@MayPayCurrent = SUM([Subtot1]),
			@MayPayArrears = SUM([Subtot2]),
			@MayPayAdvance = SUM([Subtot3]),
			@MayPayDiscArrears = SUM([Tax2]),
			@MayPayDiscCurrent = SUM([Subtot10]) - SUM([Tax2])
		FROM
			[Cpaym]
		WHERE
			CustId = @CustId
			AND [PayDate] >= @MayReadDate
			AND [PayDate] < @JunReadDate

		SET @MayPayCurrent = ISNULL(@MayPayCurrent, 0)
		SET @MayPayArrears = ISNULL(@MayPayArrears, 0)
		SET @MayPayAdvance = ISNULL(@MayPayAdvance, 0)
		SET @MayPayDiscArrears = ISNULL(@MayPayDiscArrears, 0)
		SET @MayPayDiscCurrent = ISNULL(@MayPayDiscCurrent, 0)

		SELECT
			@JunPayArrears = SUM([Subtot2])
		FROM
			[Cpaym]
		WHERE
			CustId = @CustId
			AND [PayDate] >= @JunReadDate
			AND [PayDate] < @JulReadDate

		SET @JunPayArrears = ISNULL(@JunPayArrears, 0)

		SELECT
			@JulPayArrears = SUM([Subtot2])
		FROM
			[Cpaym]
		WHERE
			CustId = @CustId
			AND [PayDate] >= @JulReadDate
			AND [PayDate] < @AugReadDate

		SET @JulPayArrears = ISNULL(@JulPayArrears, 0)

		-- | (original) | Quezon | Surigao | Trece | Himamaylan | Porac | Tacloban

		SET @MarFinalArrears = (@MarCurrent + @MarAdjust) - (@MarPayCurrent + @MarPayAdvance + @MarPayDiscCurrent) - @AprPayArrears
		SET @AprFinalArrears = (@AprCurrent + @AprAdjust) - (@AprPayCurrent + @AprPayAdvance + @AprPayDiscCurrent) - @MayPayArrears
		SET @MayFinalArrears = (@MayCurrent + @MayAdjust) - (@MayPayCurrent + @MayPayAdvance + @MayPayDiscCurrent)

		/*
		-- | Cadiz | 

		SET @MarFinalArrears = (@MarCurrent + @MarAdjust) - (@MarPayCurrent + @MarPayAdvance + @MarPayDiscCurrent + @AprPayDiscArrears) - @AprPayArrears - @MarDiscount + CASE WHEN @FebBalance < 0 THEN @FebBalance ELSE 0 END
		SET @AprFinalArrears = (@AprCurrent + @AprAdjust) - (@AprPayCurrent + @AprPayAdvance + @AprPayDiscCurrent + @MayPayDiscArrears) - @AprDiscount  
		SET @MayFinalArrears = (@MayCurrent + @MayAdjust) - (@MayPayCurrent + @MayPayAdvance + @MayPayDiscCurrent) - @MayDiscount 

		-- | Camiling | Ilocos Norte | Marilao | Meycauayan | Rosales | Samal v1 | Subic | Urdaneta |

		SET @MarFinalArrears = (@MarCurrent + @MarAdjust) - (@MarPayCurrent + @MarPayAdvance + @MarPayDiscCurrent + @AprPayDiscArrears) - @AprPayArrears - @MarDiscount + CASE WHEN @FebBalance < 0 THEN @FebBalance ELSE 0 END
		SET @AprFinalArrears = (@AprCurrent + @AprAdjust) - (@AprPayCurrent + @AprPayAdvance + @AprPayDiscCurrent + @MayPayDiscArrears) - @MayPayArrears - @AprDiscount
		SET @MayFinalArrears = (@MayCurrent + @MayAdjust) - (@MayPayCurrent + @MayPayAdvance + @MayPayDiscCurrent) - @MayDiscount

		-- | Daraga |

		SET @MarFinalArrears = (@MarCurrent + @MarAdjust) - (@MarPayCurrent + @MarPayAdvance + @MarPayDiscCurrent + @AprPayDiscArrears) - @AprPayArrears  - @MarDiscount + CASE WHEN @FebBalance < 0 THEN @FebBalance ELSE 0 END
		SET @AprFinalArrears = (@AprCurrent + @AprAdjust) - (@AprPayCurrent + @AprPayAdvance + @AprPayDiscCurrent + @MayPayDiscArrears) - @MayPayArrears - @AprDiscount
		SET @MayFinalArrears = (@MayCurrent + @MayAdjust) - (@MayPayCurrent + @MayPayAdvance + @MayPayDiscCurrent) - @MayDiscount + CASE WHEN (@AprCurrent - @MayPayArrears) < 0 THEN (@AprCurrent - @MayPayArrears) ELSE 0 END

		-- | Dingras | Gerona | Sta. Maria |

		SET @MarFinalArrears = (@MarCurrent + @MarAdjust) - (@MarPayCurrent + @MarPayAdvance + @MarPayDiscCurrent + @AprPayDiscArrears) - @AprPayArrears + CASE WHEN @FebBalance < 0 THEN @FebBalance ELSE 0 END
		SET @AprFinalArrears = (@AprCurrent + @AprAdjust) - (@AprPayCurrent + @AprPayAdvance + @AprPayDiscCurrent + @MayPayDiscArrears) - @MayPayArrears
		SET @MayFinalArrears = (@MayCurrent + @MayAdjust) - (@MayPayCurrent + @MayPayAdvance + @MayPayDiscCurrent)

		-- | Gapan |

		SET @MarFinalArrears = (@MarCurrent + @MarAdjust) - (@MarPayCurrent + @MarPayAdvance + @MarPayDiscCurrent + @AprPayDiscArrears) - @AprPayArrears - @MarDiscount + CASE WHEN @FebBalance < 0 THEN @FebBalance ELSE 0 END
		SET @AprFinalArrears = (@AprCurrent + @AprAdjust) - (@AprPayCurrent + @AprPayAdvance + @AprPayDiscCurrent + @MayPayDiscArrears) - @AprDiscount - @MayPayArrears + (CASE WHEN @MarFinalArrears < 0 THEN @MarDiscount ELSE 0 END) + (CASE WHEN @MarFinalArrears < 0 THEN (@MarDiscount + @MarFinalArrears) ELSE 0 END) 
		SET @MayFinalArrears = (@MayCurrent + @MayAdjust) - (@MayPayCurrent + @MayPayAdvance + @MayPayDiscCurrent) - @MayDiscount + (CASE WHEN @AprFinalArrears < 0 THEN @AprFinalArrears ELSE 0 END)

		-- | Iriga | Mauban | Sorsogon |

		SET @MarFinalArrears = (@MarCurrent + @MarAdjust) - (@MarPayCurrent + @MarPayAdvance + @MarPayDiscCurrent) - @AprPayArrears - @MarDiscount
		SET @AprFinalArrears = (@AprCurrent + @AprAdjust) - (@AprPayCurrent + @AprPayAdvance + @AprPayDiscCurrent) - @MayPayArrears - @AprDiscount
		SET @MayFinalArrears = (@MayCurrent + @MayAdjust) - (@MayPayCurrent + @MayPayAdvance + @MayPayDiscCurrent) - @MayDiscount

		-- | Jaen |

		SET @MarFinalArrears = (@MarCurrent + @MarAdjust) - (@MarPayCurrent + @MarPayAdvance + @MarPayDiscCurrent) - @AprPayArrears - @MarDiscount
		SET @AprFinalArrears = (@AprCurrent + @AprAdjust) - (@AprPayCurrent + @AprPayAdvance + @AprPayDiscCurrent) - @MayPayArrears - @AprDiscount
		SET @MayFinalArrears = (@MayCurrent + CASE WHEN @AprArrears < 0 THEN @AprArrears ELSE 0 END + @MayAdjust) - (@MayPayCurrent + @MayPayAdvance + @MayPayDiscCurrent) - @MayDiscount

		-- | Maasin | Paniqui | Hilongos |

		SET @MarFinalArrears = (@MarCurrent + @MarAdjust) - (@MarPayCurrent + @MarPayAdvance + @MarPayDiscCurrent + @AprPayDiscArrears) - @AprPayArrears + CASE WHEN @FebBalance < 0 THEN @FebBalance ELSE 0 END
		SET @AprFinalArrears = (@AprCurrent + @AprAdjust) - (@AprPayCurrent + @AprPayAdvance + @AprPayDiscCurrent + @MayPayDiscArrears) - @MayPayArrears
		SET @MayFinalArrears = (@MayCurrent + CASE WHEN @AprArrears < 0 THEN @AprArrears ELSE 0 END + @MayAdjust) - (@MayPayCurrent + @MayPayAdvance + @MayPayDiscCurrent)

		-- | Mabalacat | Malolos | Orani | San Rafael | Lubao |

		SET @MarFinalArrears = (@MarCurrent + @MarAdjust) - (@MarPayCurrent + @MarPayAdvance + @MarPayDiscCurrent + @AprPayDiscArrears) - @AprPayArrears - @MarDiscount + CASE WHEN @FebBalance < 0 THEN @FebBalance ELSE 0 END
		SET @AprFinalArrears = (@AprCurrent + @AprAdjust) - (@AprPayCurrent + @AprPayAdvance + @AprPayDiscCurrent + @MayPayDiscArrears) - @MayPayArrears - @AprDiscount
		SET @MayFinalArrears = (@MayCurrent + CASE WHEN @AprArrears < 0 THEN @AprArrears ELSE 0 END + @MayAdjust) - (@MayPayCurrent + @MayPayAdvance + @MayPayDiscCurrent) - @MayDiscount

		-- | Mapandan |

		SET @MarFinalArrears = convert (decimal(18,2),(@MarCurrent + @MarAdjust) - (@MarPayCurrent + @MarPayAdvance + @MarPayDiscCurrent + @AprPayDiscArrears) - @AprPayArrears + CASE WHEN @FebBalance < 0 THEN @FebBalance ELSE 0 END
		SET @AprFinalArrears = convert (decimal(18,2),(@AprCurrent + @AprAdjust) - (@AprPayCurrent + @AprPayAdvance + @AprPayDiscCurrent + @MayPayDiscArrears) + (CASE WHEN @MarFinalArrears < 0 THEN @MarFinalArrears ELSE 0 END) - @MayPayArrears)
		SET @MayFinalArrears = (@MayCurrent + CASE WHEN @AprArrears < 0 THEN @AprArrears ELSE 0 END + @MayAdjust) - (@MayPayCurrent + @MayPayAdvance + @MayPayDiscCurrent)

		-- | Mayantoc |

		SET @MarFinalArrears = (@MarCurrent + @MarAdjust) - (@MarPayCurrent + @MarPayAdvance + @MarPayDiscCurrent + @AprPayDiscArrears) - @AprPayArrears - @MarDiscount + CASE WHEN @FebBalance < 0 THEN @FebBalance ELSE 0 END
		SET @AprFinalArrears = (@AprCurrent + @AprAdjust) - (@AprPayCurrent + @AprPayAdvance + @AprPayDiscCurrent + @MayPayDiscArrears) - @MayPayArrears - @AprDiscount - CASE WHEN (@AprCurrent - (@MarPayAdvance + @MayPayArrears)) = 0 THEN @MarPayAdvance ELSE 0 END
		SET @MayFinalArrears = (@MayCurrent + @MayAdjust) - (@MayPayCurrent + @MayPayAdvance + @MayPayDiscCurrent) - @MayDiscount

		-- | Mindoro | Munoz |

		SET @MarFinalArrears = (@MarCurrent + @MarAdjust) - (@MarPayCurrent + @MarPayAdvance + @MarPayDiscCurrent + @AprPayDiscArrears) - @AprPayArrears
		SET @AprFinalArrears = (@AprCurrent + @AprAdjust) - (@AprPayCurrent + @AprPayAdvance + @AprPayDiscCurrent + @MayPayDiscArrears) - @MayPayArrears
		SET @MayFinalArrears = (@MayCurrent + @MayAdjust) - (@MayPayCurrent + @MayPayAdvance + @MayPayDiscCurrent)

		-- | Panabo |

		SET @MarFinalArrears = (@MarCurrent + @MarAdjust) - (@MarPayCurrent + @MarPayAdvance + @MarPayDiscCurrent + @AprPayDiscArrears) - @AprPayArrears + CASE WHEN @FebBalance < 0 THEN @FebBalance ELSE 0 END
		SET @AprFinalArrears = (@AprCurrent + @AprAdjust) - (@AprPayCurrent + @AprPayAdvance + @AprPayDiscCurrent + @MayPayDiscArrears) - @MayPayArrears
		SET @MayFinalArrears = (@MayCurrent + CASE WHEN @AprArrears < 0 THEN @AprArrears ELSE 0 END + @MayAdjust) - (@MayPayCurrent + @MayPayAdvance + @MayPayDiscCurrent) - @MayDiscount

		-- | Pozorrubio

		SET @MarFinalArrears = (@MarCurrent + @MarAdjust) - (@MarPayCurrent + @MarPayAdvance + @MarPayDiscCurrent) - @AprPayArrears + CASE WHEN @FebBalance < 0 THEN @FebBalance ELSE 0 END
		SET @AprFinalArrears = (@AprCurrent + @AprAdjust) - (@AprPayCurrent + @AprPayAdvance + @AprPayDiscCurrent) - @MayPayArrears
		SET @MayFinalArrears = (@MayCurrent + CASE WHEN @AprArrears < 0 THEN @AprArrears ELSE 0 END + @MayAdjust ) - (@MayPayCurrent + @MayPayAdvance + @MayPayDiscCurrent + @AprPayAdvance) 

		-- | San Antonio |

		SET @MarFinalArrears = (@MarCurrent + @MarAdjust) - (@MarPayCurrent + @MarPayAdvance + @MarPayDiscCurrent) - @AprPayArrears - @MarDiscount + CASE WHEN @FebBalance < 0 THEN @FebBalance ELSE 0 END
		SET @AprFinalArrears = (@AprCurrent + @AprAdjust) - (@AprPayCurrent + @AprPayAdvance + @AprPayDiscCurrent) - @MayPayArrears - @MarPayAdvance - @AprDiscount
		SET @MayFinalArrears = (@MayCurrent + CASE WHEN @AprArrears < 0 AND @AprFinalArrears > 0 THEN @AprArrears ELSE 0 END + @MayAdjust) - (@MayPayCurrent + @MayPayAdvance + @MayPayDiscCurrent) - @MayPayArrears - @MayDiscount 

		-- | SJDM |

		SET @MarFinalArrears = (@MarCurrent + @MarAdjust) - (@MarPayCurrent + @MarPayAdvance + @MarPayDiscCurrent + @AprPayDiscArrears) - @AprPayArrears - @MarDiscount + CASE WHEN @FebBalance < 0 THEN @FebBalance ELSE 0 END
		SET @AprFinalArrears = (@AprCurrent + @AprAdjust) - (@AprPayCurrent + @AprPayAdvance + @AprPayDiscCurrent + @MayPayDiscArrears) - @MayPayArrears - @AprDiscount
		SET @MayFinalArrears = (@MayCurrent + CASE WHEN @AprFinalArrears < 0 THEN @AprFinalArrears ELSE 0 END + @MayAdjust) - (@MayPayCurrent + @MayPayAdvance + @MayPayDiscCurrent) - @MayDiscount

		-- | Sta. Cruz |

		SET @MarFinalArrears = (@MarCurrent + @MarAdjust) - (@MarPayCurrent + @MarPayAdvance + @MarPayDiscCurrent + @AprPayDiscArrears) - @AprPayArrears - @MarDiscount + CASE WHEN @FebBalance < 0 THEN @FebBalance ELSE 0 END
		SET @AprFinalArrears = (@AprCurrent + @AprAdjust) - (@AprPayCurrent + @AprPayAdvance + @AprPayDiscCurrent + @MayPayDiscArrears) - @MayPayArrears - @AprDiscount
		SET @MayFinalArrears = (@MayCurrent + @MayAdjust) - (@MayPayCurrent + @MayPayAdvance + @MayPayDiscCurrent) - @MayDiscount - @JunPayArrears

		-- | Tagaytay |

		SET @MarFinalArrears = (@MarCurrent + @MarAdjust) - (@MarPayCurrent + @MarPayAdvance + @MarPayDiscCurrent + @AprPayDiscArrears) - @AprPayArrears - @FebBalance
		SET @AprFinalArrears = (@AprCurrent + @AprAdjust) - (@AprPayCurrent + @AprPayAdvance + @AprPayDiscCurrent + @MayPayDiscArrears) - @MayPayArrears
		SET @MayFinalArrears = (@MayCurrent + CASE WHEN @AprArrears < 0 THEN @AprArrears ELSE 0 END + @MayAdjust) - (@MayPayCurrent + @MayPayAdvance + @MayPayDiscCurrent)

		-- | Samal v2 |

		SET @MarFinalArrears = (@MarCurrent + @MarAdjust) - (@MarPayCurrent + @MarPayAdvance + @MarPayDiscCurrent + @AprPayDiscArrears) - @AprPayArrears -@MarDiscount
		SET @AprFinalArrears = (@AprCurrent + @AprAdjust) - (@AprPayCurrent + @AprPayAdvance + @AprPayDiscCurrent + @MayPayDiscArrears) - @MayPayArrears - @AprDiscount + CASE WHEN @AprRebate < 0 THEN @AprRebate ELSE 0 END
		SET @MayFinalArrears = (@MayCurrent + @MayAdjust) - (@MayPayCurrent + @MayPayAdvance + @MayPayDiscCurrent) - @MayDiscount + CASE WHEN @MayRebate < 0 THEN @MayRebate ELSE 0 END

		-- | Agoncillo |

		SET @MarFinalArrears = (@MarCurrent + @MarAdjust) - (@MarPayCurrent + @MarPayAdvance + @MarPayDiscCurrent + @AprPayDiscArrears) - @AprPayArrears - @MarDiscount 
		SET @AprFinalArrears = (@AprCurrent + @AprAdjust) - (@AprPayCurrent + @AprPayAdvance + @AprPayDiscCurrent + @MayPayDiscArrears) - @MayPayArrears - @AprDiscount + (CASE WHEN @MarFinalArrears < 0 THEN @MarFinalArrears ELSE 0 END) 
		SET @MayFinalArrears = (@MayCurrent + @MayAdjust) - (@MayPayCurrent + @MayPayAdvance + @MayPayDiscCurrent+ @AprPayAdvance) - @MayDiscount  

		-- | Dasma |

		SET @MarFinalArrears = (@MarCurrent + @MarAdjust) - (@MarPayCurrent + @MarPayArrears + @MarPayAdvance + @MarPayDiscCurrent + @AprPayDiscArrears) - @AprPayArrears + CASE WHEN @FebBalance <= 0 THEN @FebBalance ELSE 0 END WHEN @FebBalance > 0 AND @MarPayCurrent > 0 THEN @FebBalance ELSE 0 END 
		SET @AprFinalArrears = (@AprCurrent + @AprAdjust) - (@AprPayCurrent + @AprPayAdvance + @AprPayDiscCurrent + @MayPayDiscArrears) - @MayPayArrears
		SET @MayFinalArrears = (@MayCurrent + CASE WHEN @AprArrears < 0 THEN @AprArrears ELSE 0 END + @MayAdjust) - (@MayPayCurrent + @MayPayArrears + @MayPayAdvance + @MayPayDiscCurrent)

		-- | La Union |

		SET @MarFinalArrears = (@MarCurrent + @MarAdjust) - (@MarPayCurrent + @MarPayAdvance + @MarPayDiscCurrent + @AprPayDiscArrears) - @AprPayArrears - @MarDiscount + CASE WHEN @FebBalance < 0 THEN @FebBalance ELSE 0 END
		SET @AprFinalArrears = (@AprCurrent + @AprAdjust) - (@AprPayCurrent + @AprPayAdvance + @AprPayDiscCurrent + @MayPayDiscArrears) - @MayPayArrears - @AprDiscount
		SET @MayFinalArrears = (@MayCurrent + CASE WHEN @AprArrears < 0 THEN @AprArrears ELSE 0 END + @MayAdjust) - (@MayPayCurrent + @MayPayAdvance + @MayPayDiscCurrent + @AprPayAdvance) - @MayDiscount

		-- | Silang |

		SET @MarFinalArrears = (@MarCurrent + @MarAdjust) - (@MarPayCurrent + @MarPayAdvance + @MarPayDiscCurrent + @AprPayDiscArrears) - @AprPayArrears - @MarDiscount + CASE WHEN @FebBalance < 0 THEN @FebBalance ELSE 0 END
		SET @AprFinalArrears = (@AprCurrent + @AprAdjust) - (@AprPayCurrent + @AprPayAdvance + @AprPayDiscCurrent + @MayPayDiscArrears) - @MayPayArrears - @AprDiscount
		SET @MayFinalArrears = (@MayCurrent + CASE WHEN @AprArrears < 0 THEN @AprArrears ELSE 0 END + @MayAdjust) - (@MayPayCurrent + @MayPayAdvance + (CASE WHEN @MayPayDiscCurrent > 0 THEN (@MayPayDiscCurrent) ELSE 0 END)) - @MayDiscount																					 
		*/

		INSERT @ArrearsTable
		SELECT
			0,
			CASE
				WHEN @MarFinalArrears + (CASE WHEN @AprFinalArrears < 0 THEN @AprFinalArrears ELSE 0 END) + (CASE WHEN @MayFinalArrears < 0 THEN @MayFinalArrears ELSE 0 END) >= 0
				THEN @MarFinalArrears + (CASE WHEN @AprFinalArrears < 0 THEN @AprFinalArrears ELSE 0 END) + (CASE WHEN @MayFinalArrears < 0 THEN @MayFinalArrears ELSE 0 END)
				ELSE 0 END,
			CASE
				WHEN @AprFinalArrears + (CASE WHEN @MayFinalArrears < 0 THEN @MayFinalArrears ELSE 0 END) >= 0
				THEN @AprFinalArrears + (CASE WHEN @MayFinalArrears < 0 THEN @MayFinalArrears ELSE 0 END)
				ELSE 0 END,
			CASE
				WHEN @MayFinalArrears >= 0
				THEN @MayFinalArrears
				ELSE 0 END,
			0, 0, 0, 0,
			0, 0, 0, 0, 0, 0,
			0, 0, 0, 0, 0, 0,
			0, 0, 0, 0, 0, 0
	END
	ELSE
	BEGIN
		IF @Instance IN (1, 2)
		----------------------------------------------------------------------------------------------------------------------------------
		----------------------------------------------------------------------------------------------------------------------------------
		-- || July 2020 Modified GCQ Arrears Computation
		-- || (simplified version based on new requirement, including all codes from IT specialists)
		----------------------------------------------------------------------------------------------------------------------------------
		----------------------------------------------------------------------------------------------------------------------------------
		BEGIN
			-- *** Variables to control the script. ***

			-- || @_Conf_Discounted:
			-- ||   0 for penalty on basic charge
			-- ||   1 for penalty on discounted basic charge
			DECLARE @_Conf_Discounted BIT

			-- || @_Conf_Cons_Senior:
			-- ||   consumption that is discounted for senior (example: 30 cons)
			DECLARE @_Conf_Cons_Senior INT

			-- || @_Conf_Cons_Higher_Disc:
			-- ||   0 for cons higher than {@_Conf_Cons_Senior}, the senior discount is forfeited
			-- ||   1 for cons higher than {@_Conf_Cons_Senior}, the first {@_Conf_Cons_Senior} is discounted
			DECLARE @_Conf_Cons_Higher_Disc BIT

			-- || @_Conf_MeterCharge_Subtot:
			-- ||   5 for [Subtot5]
			-- ||   7 for [Subtot7]
			DECLARE @_Conf_MeterCharge_Subtot INT

			-- || @_Conf_Migrate_March:
			-- ||   1 for areas migrated within March 2020
			-- ||   0 for other areas
			DECLARE @_Conf_Migrate_March INT

			-- || @_Conf_Senior_Arrears:
			-- ||   1 to compute for arrears senior discount on payment
			-- ||   0 to ignore arrears senior discount on payment
			DECLARE @_Conf_Senior_Arrears BIT

			SET @_Conf_Discounted = 0			-- penalty on basic charge
			SET @_Conf_Cons_Senior = 30			-- 30 cons senior discount
			SET @_Conf_Cons_Higher_Disc = 0		-- for 31 cons up, no senior discount
			SET @_Conf_MeterCharge_Subtot = 7	-- meter charge on Subtot7
			SET @_Conf_Migrate_March = 0		-- not migrated on March 2020
			SET @_Conf_Senior_Arrears = 1		-- compute arrears senior discount

			----------------------------------

			DECLARE @_CSSVersion INT

			IF EXISTS (SELECT 1 FROM [sys].[columns] WHERE [name] = 'end_procfee' AND OBJECT_ID = OBJECT_ID('dbo.PN1'))
			BEGIN
				SET @_CSSVersion = 7
			END
			ELSE
			BEGIN
				SET @_CSSVersion = 6
			END

			----------------------------------

			DECLARE
				@_MarReadDate VARCHAR(10),
				@_AprReadDate VARCHAR(10),
				@_MayReadDate VARCHAR(10),
				@_JunReadDate VARCHAR(10),
				@_JulReadDate VARCHAR(10),
				@_AugReadDate VARCHAR(10),
				@_SepReadDate VARCHAR(10)

			DECLARE
				@_FebBalance DECIMAL(18, 2), @_FebBillPenalty DECIMAL(18, 2), @_FebPayPenalty DECIMAL(18, 2), @_FebPenalty DECIMAL(18, 2)

			DECLARE
				@_MarBillBasic DECIMAL(18, 2), @_MarBillDiscount DECIMAL(18, 2), @_MarBillSeptage DECIMAL(18, 2), @_MarBillMeterCharge DECIMAL(18, 2),
				@_MarBillSenior DECIMAL(18, 2), @_MarBillAdjustment DECIMAL(18, 2), @_MarBillTotal DECIMAL(18, 2)
				,
				@_AprBillBasic DECIMAL(18, 2), @_AprBillDiscount DECIMAL(18, 2), @_AprBillSeptage DECIMAL(18, 2), @_AprBillMeterCharge DECIMAL(18, 2),
				@_AprBillSenior DECIMAL(18, 2), @_AprBillAdjustment DECIMAL(18, 2), @_AprBillTotal DECIMAL(18, 2)
				,
				@_MayBillBasic DECIMAL(18, 2), @_MayBillDiscount DECIMAL(18, 2), @_MayBillSeptage DECIMAL(18, 2), @_MayBillMeterCharge DECIMAL(18, 2),
				@_MayBillSenior DECIMAL(18, 2), @_MayBillAdjustment DECIMAL(18, 2), @_MayBillTotal DECIMAL(18, 2)
				,
				@_JunBillBasic DECIMAL(18, 2), @_JunBillDiscount DECIMAL(18, 2), @_JunBillSeptage DECIMAL(18, 2), @_JunBillMeterCharge DECIMAL(18, 2),
				@_JunBillSenior DECIMAL(18, 2), @_JunBillAdjustment DECIMAL(18, 2), @_JunBillTotal DECIMAL(18, 2)
				,
				@_JulBillBasic DECIMAL(18, 2), @_JulBillDiscount DECIMAL(18, 2), @_JulBillSeptage DECIMAL(18, 2), @_JulBillMeterCharge DECIMAL(18, 2),
				@_JulBillSenior DECIMAL(18, 2), @_JulBillAdjustment DECIMAL(18, 2), @_JulBillTotal DECIMAL(18, 2)
				,
				@_AugBillBasic DECIMAL(18, 2), @_AugBillDiscount DECIMAL(18, 2), @_AugBillSeptage DECIMAL(18, 2), @_AugBillMeterCharge DECIMAL(18, 2),
				@_AugBillSenior DECIMAL(18, 2), @_AugBillAdjustment DECIMAL(18, 2), @_AugBillTotal DECIMAL(18, 2)

			DECLARE
				@_MarBillSeniorFixed DECIMAL(18, 2),
				@_AprBillSeniorFixed DECIMAL(18, 2),
				@_MayBillSeniorFixed DECIMAL(18, 2),
				@_JunBillSeniorFixed DECIMAL(18, 2),
				@_JulBillSeniorFixed DECIMAL(18, 2),
				@_AugBillSeniorFixed DECIMAL(18, 2)

			DECLARE
				@_MarPayCurrent DECIMAL(18, 2), @_MarPayArrears DECIMAL(18, 2), @_MarPayAdvance DECIMAL(18, 2), @_MarPayMeterCharge DECIMAL(18, 2),
				@_MarPaySeptageCurrent DECIMAL(18, 2), @_MarPaySeptageArrears DECIMAL(18, 2), @_MarPaySeptageAdvanced DECIMAL(18, 2), @_MarPayPN DECIMAL(18, 2),
				@_MarPayDiscNonSenior DECIMAL(18, 2), @_MarPayTotal DECIMAL(18, 2)
				,
				@_AprPayCurrent DECIMAL(18, 2), @_AprPayArrears DECIMAL(18, 2), @_AprPayAdvance DECIMAL(18, 2), @_AprPayMeterCharge DECIMAL(18, 2),
				@_AprPaySeptageCurrent DECIMAL(18, 2), @_AprPaySeptageArrears DECIMAL(18, 2), @_AprPaySeptageAdvanced DECIMAL(18, 2), @_AprPayPN DECIMAL(18, 2),
				@_AprPayDiscNonSenior DECIMAL(18, 2), @_AprPayTotal DECIMAL(18, 2)
				,
				@_MayPayCurrent DECIMAL(18, 2), @_MayPayArrears DECIMAL(18, 2), @_MayPayAdvance DECIMAL(18, 2), @_MayPayMeterCharge DECIMAL(18, 2),
				@_MayPaySeptageCurrent DECIMAL(18, 2), @_MayPaySeptageArrears DECIMAL(18, 2), @_MayPaySeptageAdvanced DECIMAL(18, 2), @_MayPayPN DECIMAL(18, 2),
				@_MayPayDiscNonSenior DECIMAL(18, 2), @_MayPayTotal DECIMAL(18, 2)
				,
				@_JunPayCurrent DECIMAL(18, 2), @_JunPayArrears DECIMAL(18, 2), @_JunPayAdvance DECIMAL(18, 2), @_JunPayMeterCharge DECIMAL(18, 2),
				@_JunPaySeptageCurrent DECIMAL(18, 2), @_JunPaySeptageArrears DECIMAL(18, 2), @_JunPaySeptageAdvanced DECIMAL(18, 2), @_JunPayPN DECIMAL(18, 2),
				@_JunPayDiscNonSenior DECIMAL(18, 2), @_JunPayTotal DECIMAL(18, 2)
				,
				@_JulPayCurrent DECIMAL(18, 2), @_JulPayArrears DECIMAL(18, 2), @_JulPayAdvance DECIMAL(18, 2), @_JulPayMeterCharge DECIMAL(18, 2),
				@_JulPaySeptageCurrent DECIMAL(18, 2), @_JulPaySeptageArrears DECIMAL(18, 2), @_JulPaySeptageAdvanced DECIMAL(18, 2), @_JulPayPN DECIMAL(18, 2),
				@_JulPayDiscNonSenior DECIMAL(18, 2), @_JulPayTotal DECIMAL(18, 2)
				,
				@_AugPayCurrent DECIMAL(18, 2), @_AugPayArrears DECIMAL(18, 2), @_AugPayAdvance DECIMAL(18, 2), @_AugPayMeterCharge DECIMAL(18, 2),
				@_AugPaySeptageCurrent DECIMAL(18, 2), @_AugPaySeptageArrears DECIMAL(18, 2), @_AugPaySeptageAdvanced DECIMAL(18, 2), @_AugPayPN DECIMAL(18, 2),
				@_AugPayDiscNonSenior DECIMAL(18, 2), @_AugPayTotal DECIMAL(18, 2)

			DECLARE
				@_FebRunningAmount DECIMAL(18, 2),
				@_MarRunningAmount DECIMAL(18, 2),
				@_AprRunningAmount DECIMAL(18, 2),
				@_MayRunningAmount DECIMAL(18, 2),
				@_JunRunningAmount DECIMAL(18, 2),
				@_JulRunningAmount DECIMAL(18, 2),
				@_AugRunningAmount DECIMAL(18, 2)

			-- || Reading Dates --------------------------------------------------------------------------------------------------------------

			SET @_MarReadDate = (SELECT [Rdate] FROM [Rhist] WHERE CustId = @CustId AND [BillDate] = '2020/03')
			SET @_MarReadDate = CASE ISDATE(@_MarReadDate) WHEN 1 THEN CONVERT(VARCHAR(20), CONVERT(DATETIME, @_MarReadDate), 111) ELSE '2020/03/01' END

			SET @_AprReadDate = (SELECT [Rdate] FROM [Rhist] WHERE CustId = @CustId AND [BillDate] = '2020/04')
			SET @_AprReadDate = CASE ISDATE(@_AprReadDate) WHEN 1 THEN CONVERT(VARCHAR(20), CONVERT(DATETIME, @_AprReadDate), 111) ELSE '2020/04/01' END

			SET @_MayReadDate = (SELECT [Rdate] FROM [Rhist] WHERE CustId = @CustId AND [BillDate] = '2020/05')
			SET @_MayReadDate = CASE ISDATE(@_MayReadDate) WHEN 1 THEN CONVERT(VARCHAR(20), CONVERT(DATETIME, @_MayReadDate), 111) ELSE '2020/05/01' END

			SET @_JunReadDate = (SELECT [Rdate] FROM [Rhist] WHERE CustId = @CustId AND [BillDate] = '2020/06')
			SET @_JunReadDate = CASE ISDATE(@_JunReadDate) WHEN 1 THEN CONVERT(VARCHAR(20), CONVERT(DATETIME, @_JunReadDate), 111) ELSE '2020/06/01' END

			SET @_JulReadDate = (SELECT [Rdate] FROM [Rhist] WHERE CustId = @CustId AND [BillDate] = '2020/07')
			SET @_JulReadDate = CASE ISDATE(@_JulReadDate) WHEN 1 THEN CONVERT(VARCHAR(20), CONVERT(DATETIME, @_JulReadDate), 111) ELSE '2020/07/01' END

			SET @_AugReadDate = (SELECT [Rdate] FROM [Rhist] WHERE CustId = @CustId AND [BillDate] = '2020/08')
			SET @_AugReadDate = CASE ISDATE(@_AugReadDate) WHEN 1 THEN CONVERT(VARCHAR(20), CONVERT(DATETIME, @_AugReadDate), 111) ELSE '2020/08/01' END

			SET @_SepReadDate = (SELECT [Rdate] FROM [Rhist] WHERE CustId = @CustId AND [BillDate] = '2020/09')
			SET @_SepReadDate = CASE ISDATE(@_SepReadDate) WHEN 1 THEN CONVERT(VARCHAR(20), CONVERT(DATETIME, @_SepReadDate), 111) ELSE '2020/09/01' END

			-- || February and Older Balance -------------------------------------------------------------------------------------------------

			IF @_CSSVersion >= 7
			BEGIN
				IF @Instance = 1
				BEGIN
					SET @_FebBalance = (SELECT ISNULL(SUM([Debit]), 0) - ISNULL(SUM([Credit]), 0) FROM [cust_ledger] WHERE CustId = @CustId AND ISNULL([trans_date], '1900-01-01') < CONVERT(DATETIME, @_MarReadDate) AND [ledger_type] IN ('WATER', 'PENALTY'))
					SET @_FebBillPenalty = (SELECT ISNULL(SUM([Debit]), 0) - ISNULL(SUM([Credit]), 0) FROM [cust_ledger] WHERE CustId = @CustId AND ISNULL([trans_date], '1900-01-01') < CONVERT(DATETIME, @_MarReadDate) AND [ledger_type] = 'PENALTY')
				END
				ELSE
				BEGIN
					IF @Instance = 2
					BEGIN
						SET @_FebBalance = (SELECT ISNULL(SUM([Debit]), 0) - ISNULL(SUM([Credit]), 0) FROM [cust_ledger] WHERE CustId = @CustId AND ISNULL([trans_date], '1900-01-01') < CONVERT(DATETIME, @_MarReadDate) AND [ledger_type] IN ('WATER', 'SERVICE CHARGE', 'SEWERAGE', 'PENALTY'))
						SET @_FebBillPenalty = (SELECT ISNULL(SUM([Debit]), 0) - ISNULL(SUM([Credit]), 0) FROM [cust_ledger] WHERE CustId = @CustId AND ISNULL([trans_date], '1900-01-01') < CONVERT(DATETIME, @_MarReadDate) AND [ledger_type] = 'PENALTY')
					END
					ELSE
					BEGIN
						SET @_FebBalance = 0
						SET @_FebBillPenalty = 0
					END
				END
			END
			

			SET @_FebPenalty = @_FebBillPenalty

			-- || March Bill -----------------------------------------------------------------------------------------------------------------

			IF @_Conf_Migrate_March = 0
			BEGIN
				SELECT
					@_MarBillBasic = c.[SubTot1],
					@_MarBillDiscount = c.[SubTot2],
					@_MarBillSeptage = CASE WHEN @Instance = 2 THEN c.[SubTot3] ELSE 0 END,
					@_MarBillMeterCharge = CASE WHEN @Instance = 2 THEN c.[SubTot5] ELSE 0 END,
					@_MarBillSenior = 
						CASE
							WHEN @_Conf_Discounted = 1
							THEN
								CASE
									WHEN a.[SeniorDate] >= CONVERT(DATETIME, @_MarReadDate)
									THEN
										CASE
											WHEN ISNULL(b.[Cons1], 0) <= @_Conf_Cons_Senior
											THEN
												(b.[nbasic] - c.[SubTot2]) * 0.05
											ELSE
												CASE
													WHEN @_Conf_Cons_Higher_Disc = 1
													THEN
														(d.[MinBill] + (d.[Rate1] * 10) + (d.[Rate2] * 10)) * 0.05
													ELSE
														0
												END
										END
									ELSE
										0
								END
							ELSE
								0
						END,
					@_MarBillSeniorFixed =
						CASE
							WHEN a.[SeniorDate] >= CONVERT(DATETIME, @_MarReadDate)
							THEN
								CASE
									WHEN ISNULL(b.[Cons1], 0) <= @_Conf_Cons_Senior
									THEN
										(b.[nbasic] - c.[SubTot2]) * 0.05
									ELSE
										CASE
											WHEN @_Conf_Cons_Higher_Disc = 1
											THEN
												(d.[MinBill] + (d.[Rate1] * 10) + (d.[Rate2] * 10)) * 0.05
											ELSE
												0
										END
								END
							ELSE
								0
						END
				FROM
					[Cust] a
					OUTER APPLY
					(
						SELECT
							[Cons1],
							[nbasic]
						FROM
							[Rhist]
						WHERE
							CustId = a.CustId
							AND [BillDate] = '2020/03'
					) b
					OUTER APPLY
					(
						SELECT
							[SubTot1],
							[SubTot2],
							[SubTot3],
							[SubTot5]
						FROM
							[Cbill]
						WHERE
							CustId = a.CustId
							AND [BillDate] = '2020/03'
					) c
					LEFT JOIN [Bill] d
						ON a.RateId = d.RateId AND a.ZoneId = d.ZoneId
				WHERE
					a.CustId = @CustId

				SET @_MarBillBasic = ISNULL(@_MarBillBasic, 0)
				SET @_MarBillDiscount = ISNULL(@_MarBillDiscount, 0)
				SET @_MarBillSeptage = ISNULL(@_MarBillSeptage, 0)
				SET @_MarBillMeterCharge = ISNULL(@_MarBillMeterCharge, 0)
				SET @_MarBillSenior = ISNULL(@_MarBillSenior, 0)

				IF @_CSSVersion >= 7
				BEGIN
					IF @Instance = 1
					BEGIN
						SET @_MarBillAdjustment = (SELECT ISNULL(SUM([Debit]), 0) - ISNULL(SUM([Credit]), 0) FROM [cust_ledger] WHERE CustId = @CustId AND [posting_date] >= CONVERT(DATETIME, @_MarReadDate) AND [posting_date] < CONVERT(DATETIME, @_AprReadDate) AND [transaction_type] IN (4, 5, 10) AND [ledger_type] = 'WATER' AND [ledger_subtype] != 'BEG')
					END
					ELSE
					BEGIN
						IF @Instance = 2
						BEGIN
							SET @_MarBillAdjustment = (SELECT ISNULL(SUM([Debit]), 0) - ISNULL(SUM([Credit]), 0) FROM [cust_ledger] WHERE CustId = @CustId AND [posting_date] >= CONVERT(DATETIME, @_MarReadDate) AND [posting_date] < CONVERT(DATETIME, @_AprReadDate) AND [transaction_type] IN (4, 5, 10) AND [ledger_type] IN ('WATER', 'SERVICE CHARGE', 'SEWERAGE') AND [ledger_subtype] != 'BEG')
						END
						ELSE
						BEGIN
							SET @_MarBillAdjustment = 0
						END
					END
				END
				

				SET @_MarBillTotal = (@_MarBillBasic - @_MarBillDiscount) - @_MarBillSenior + @_MarBillAdjustment
			END
			ELSE
			BEGIN
				IF @Instance = 1
				BEGIN
					SET @_MarBillTotal = (SELECT ISNULL(SUM([Debit]), 0) - ISNULL(SUM([Credit]), 0) FROM [cust_ledger] WHERE CustId = @CustId AND [transaction_type] = 4 AND [ledger_type] = 'WATER' AND [ledger_subtype] = 'BEG')
				END
				ELSE
				BEGIN
					IF @Instance = 2
					BEGIN
						SET @_MarBillTotal = (SELECT ISNULL(SUM([Debit]), 0) - ISNULL(SUM([Credit]), 0) FROM [cust_ledger] WHERE CustId = @CustId AND [transaction_type] = 4 AND [ledger_type] IN ('WATER', 'SERVICE CHARGE', 'SEWERAGE') AND [ledger_subtype] = 'BEG')
					END
					ELSE
					BEGIN
						SET @_MarBillTotal = 0
					END
				END

				SET @_MarBillBasic = 0
				SET @_MarBillDiscount = 0
				SET @_MarBillSeptage = 0
				SET @_MarBillMeterCharge = 0
				SET @_MarBillSenior = 0
				SET @_MarBillAdjustment = 0
			END

			-- || April Bill -----------------------------------------------------------------------------------------------------------------
			
			SELECT
				@_AprBillBasic = c.[SubTot1],
				@_AprBillDiscount = c.[SubTot2],
				@_AprBillSeptage = CASE WHEN @Instance = 2 THEN c.[SubTot3] ELSE 0 END,
				@_AprBillMeterCharge = CASE WHEN @Instance = 2 THEN c.[SubTot5] ELSE 0 END,
				@_AprBillSenior = 
					CASE
						WHEN @_Conf_Discounted = 1
						THEN
							CASE
								WHEN a.[SeniorDate] >= CONVERT(DATETIME, @_AprReadDate)
								THEN
									CASE
										WHEN ISNULL(b.[Cons1], 0) <= @_Conf_Cons_Senior
										THEN
											(b.[nbasic] - c.[SubTot2]) * 0.05
										ELSE
											CASE
												WHEN @_Conf_Cons_Higher_Disc = 1
												THEN
													(d.[MinBill] + (d.[Rate1] * 10) + (d.[Rate2] * 10)) * 0.05
												ELSE
													0
											END
									END
								ELSE
									0
							END
						ELSE
							0
					END,
				@_AprBillSeniorFixed =
					CASE
							WHEN a.[SeniorDate] >= CONVERT(DATETIME, @_AprReadDate)
							THEN
								CASE
									WHEN ISNULL(b.[Cons1], 0) <= @_Conf_Cons_Senior
									THEN
										(b.[nbasic] - c.[SubTot2]) * 0.05
									ELSE
										CASE
											WHEN @_Conf_Cons_Higher_Disc = 1
											THEN
												(d.[MinBill] + (d.[Rate1] * 10) + (d.[Rate2] * 10)) * 0.05
											ELSE
												0
										END
								END
							ELSE
								0
						END
			FROM
				[Cust] a
				OUTER APPLY
				(
					SELECT
						[Cons1],
						[nbasic]
					FROM
						[Rhist]
					WHERE
						CustId = a.CustId
						AND [BillDate] = '2020/04'
				) b
				OUTER APPLY
				(
					SELECT
						[SubTot1],
						[SubTot2],
						[SubTot3],
						[SubTot5]
					FROM
						[Cbill]
					WHERE
						CustId = a.CustId
						AND [BillDate] = '2020/04'
				) c
				LEFT JOIN [Bill] d
					ON a.RateId = d.RateId AND a.ZoneId = d.ZoneId
			WHERE
				a.CustId = @CustId

			SET @_AprBillBasic = ISNULL(@_AprBillBasic, 0)
			SET @_AprBillDiscount = ISNULL(@_AprBillDiscount, 0)
			SET @_AprBillSeptage = ISNULL(@_AprBillSeptage, 0)
			SET @_AprBillMeterCharge = ISNULL(@_AprBillMeterCharge, 0)
			SET @_AprBillSenior = ISNULL(@_AprBillSenior, 0)

			IF @_CSSVersion >= 7
			BEGIN
				IF @Instance = 1
				BEGIN
					SET @_AprBillAdjustment = (SELECT ISNULL(SUM([Debit]), 0) - ISNULL(SUM([Credit]), 0) FROM [cust_ledger] WHERE CustId = @CustId AND [posting_date] >= CONVERT(DATETIME, @_AprReadDate) AND [posting_date] < CONVERT(DATETIME, @_MayReadDate) AND [transaction_type] IN (4, 5, 10) AND [ledger_type] = 'WATER' AND [ledger_subtype] != 'BEG')
				END
				ELSE
				BEGIN
					IF @Instance = 2
					BEGIN
						SET @_AprBillAdjustment = (SELECT ISNULL(SUM([Debit]), 0) - ISNULL(SUM([Credit]), 0) FROM [cust_ledger] WHERE CustId = @CustId AND [posting_date] >= CONVERT(DATETIME, @_AprReadDate) AND [posting_date] < CONVERT(DATETIME, @_MayReadDate) AND [transaction_type] IN (4, 5, 10) AND [ledger_type] IN ('WATER', 'SERVICE CHARGE', 'SEWERAGE') AND [ledger_subtype] != 'BEG')
					END
					ELSE
					BEGIN
						SET @_AprBillAdjustment = 0
					END
				END
			END
			

			SET @_AprBillTotal = (@_AprBillBasic - @_AprBillDiscount) - @_AprBillSenior + @_AprBillAdjustment

			-- || May Bill -------------------------------------------------------------------------------------------------------------------
			
			SELECT
				@_MayBillBasic = c.[SubTot1],
				@_MayBillDiscount = c.[SubTot2],
				@_MayBillSeptage = CASE WHEN @Instance = 2 THEN c.[SubTot3] ELSE 0 END,
				@_MayBillMeterCharge = CASE WHEN @Instance = 2 THEN c.[SubTot5] ELSE 0 END,
				@_MayBillSenior = 
					CASE
						WHEN @_Conf_Discounted = 1
						THEN
							CASE
								WHEN a.[SeniorDate] >= CONVERT(DATETIME, @_MayReadDate)
								THEN
									CASE
										WHEN ISNULL(b.[Cons1], 0) <= @_Conf_Cons_Senior
										THEN
											(b.[nbasic] - c.[SubTot2]) * 0.05
										ELSE
											CASE
												WHEN @_Conf_Cons_Higher_Disc = 1
												THEN
													(d.[MinBill] + (d.[Rate1] * 10) + (d.[Rate2] * 10)) * 0.05
												ELSE
													0
											END
									END
								ELSE
									0
							END
						ELSE
							0
					END,
				@_MayBillSeniorFixed =
					CASE
						WHEN a.[SeniorDate] >= CONVERT(DATETIME, @_MayReadDate)
						THEN
							CASE
								WHEN ISNULL(b.[Cons1], 0) <= @_Conf_Cons_Senior
								THEN
									(b.[nbasic] - c.[SubTot2]) * 0.05
								ELSE
									CASE
										WHEN @_Conf_Cons_Higher_Disc = 1
										THEN
											(d.[MinBill] + (d.[Rate1] * 10) + (d.[Rate2] * 10)) * 0.05
										ELSE
											0
									END
							END
						ELSE
							0
					END
			FROM
				[Cust] a
				OUTER APPLY
				(
					SELECT
						[Cons1],
						[nbasic]
					FROM
						[Rhist]
					WHERE
						CustId = a.CustId
						AND [BillDate] = '2020/05'
				) b
				OUTER APPLY
				(
					SELECT
						[SubTot1],
						[SubTot2],
						[SubTot3],
						[SubTot5]
					FROM
						[Cbill]
					WHERE
						CustId = a.CustId
						AND [BillDate] = '2020/05'
				) c
				LEFT JOIN [Bill] d
					ON a.RateId = d.RateId AND a.[ZoneId] = d.[ZoneId]
			WHERE
				a.CustId = @CustId

			SET @_MayBillBasic = ISNULL(@_MayBillBasic, 0)
			SET @_MayBillDiscount = ISNULL(@_MayBillDiscount, 0)
			SET @_MayBillSeptage = ISNULL(@_MayBillSeptage, 0)
			SET @_MayBillMeterCharge = ISNULL(@_MayBillMeterCharge, 0)
			SET @_MayBillSenior = ISNULL(@_MayBillSenior, 0)

			IF @_CSSVersion >= 7
			BEGIN
				IF @Instance = 1
				BEGIN
					SET @_MayBillAdjustment = (SELECT ISNULL(SUM([Debit]), 0) - ISNULL(SUM([Credit]), 0) FROM [cust_ledger] WHERE CustId = @CustId AND [posting_date] >= CONVERT(DATETIME, @_MayReadDate) AND [posting_date] < CONVERT(DATETIME, @_JunReadDate) AND [transaction_type] IN (4, 5, 10) AND [ledger_type] = 'WATER' AND [ledger_subtype] != 'BEG')
				END
				ELSE
				BEGIN
					IF @Instance = 2
					BEGIN
						SET @_MayBillAdjustment = (SELECT ISNULL(SUM([Debit]), 0) - ISNULL(SUM([Credit]), 0) FROM [cust_ledger] WHERE CustId = @CustId AND [posting_date] >= CONVERT(DATETIME, @_MayReadDate) AND [posting_date] < CONVERT(DATETIME, @_JunReadDate) AND [transaction_type] IN (4, 5, 10) AND [ledger_type] IN ('WATER', 'SERVICE CHARGE', 'SEWERAGE') AND [ledger_subtype] != 'BEG')
					END
					ELSE
					BEGIN
						SET @_MayBillAdjustment = 0
					END
				END
			END
			

			SET @_MayBillTotal = (@_MayBillBasic - @_MayBillDiscount) - @_MayBillSenior + @_MayBillAdjustment

			-- || June Bill ------------------------------------------------------------------------------------------------------------------
			
			SELECT
				@_JunBillBasic = c.[SubTot1],
				@_JunBillDiscount = c.[SubTot2],
				@_JunBillSeptage = CASE WHEN @Instance = 2 THEN c.[SubTot3] ELSE 0 END,
				@_JunBillMeterCharge = CASE WHEN @Instance = 2 THEN c.[SubTot5] ELSE 0 END,
				@_JunBillSenior = 
					CASE
						WHEN @_Conf_Discounted = 1
						THEN
							CASE
								WHEN a.[SeniorDate] >= CONVERT(DATETIME, @_JunReadDate)
								THEN
									CASE
										WHEN ISNULL(b.[Cons1], 0) <= @_Conf_Cons_Senior
										THEN
											(b.[nbasic] - c.[SubTot2]) * 0.05
										ELSE
											CASE
												WHEN @_Conf_Cons_Higher_Disc = 1
												THEN
													(d.[MinBill] + (d.[Rate1] * 10) + (d.[Rate2] * 10)) * 0.05
												ELSE
													0
											END
									END
								ELSE
									0
							END
						ELSE
							0
					END,
				@_JunBillSeniorFixed =
					CASE
						WHEN a.[SeniorDate] >= CONVERT(DATETIME, @_JunReadDate)
						THEN
							CASE
								WHEN ISNULL(b.[Cons1], 0) <= @_Conf_Cons_Senior
								THEN
									(b.[nbasic] - c.[SubTot2]) * 0.05
								ELSE
									CASE
										WHEN @_Conf_Cons_Higher_Disc = 1
										THEN
											(d.[MinBill] + (d.[Rate1] * 10) + (d.[Rate2] * 10)) * 0.05
										ELSE
											0
									END
							END
						ELSE
							0
					END
			FROM
				[Cust] a
				OUTER APPLY
				(
					SELECT
						[Cons1],
						[nbasic]
					FROM
						[Rhist]
					WHERE
						CustId = a.CustId
						AND [BillDate] = '2020/06'
				) b
				OUTER APPLY
				(
					SELECT
						[SubTot1],
						[SubTot2],
						[SubTot3],
						[SubTot5]
					FROM
						[Cbill]
					WHERE
						CustId = a.CustId
						AND [BillDate] = '2020/06'
				) c
				LEFT JOIN [Bill] d
					ON a.[RateId] = d.[RateId] AND a.[ZoneId] = d.[ZoneId]
			WHERE
				a.CustId = @CustId

			SET @_JunBillBasic = ISNULL(@_JunBillBasic, 0)
			SET @_JunBillDiscount = ISNULL(@_JunBillDiscount, 0)
			SET @_JunBillSeptage = ISNULL(@_JunBillSeptage, 0)
			SET @_JunBillMeterCharge = ISNULL(@_JunBillMeterCharge, 0)
			SET @_JunBillSenior = ISNULL(@_JunBillSenior, 0)

			IF @_CSSVersion >= 7
			BEGIN
				IF @Instance = 1
				BEGIN
					SET @_JunBillAdjustment = (SELECT ISNULL(SUM([Debit]), 0) - ISNULL(SUM([Credit]), 0) FROM [cust_ledger] WHERE CustId = @CustId AND [posting_date] >= CONVERT(DATETIME, @_JunReadDate) AND [posting_date] < CONVERT(DATETIME, @_JulReadDate) AND [transaction_type] IN (4, 5, 10) AND [ledger_type] = 'WATER' AND [ledger_subtype] != 'BEG')
				END
				ELSE
				BEGIN
					IF @Instance = 2
					BEGIN
						SET @_JunBillAdjustment = (SELECT ISNULL(SUM([Debit]), 0) - ISNULL(SUM([Credit]), 0) FROM [cust_ledger] WHERE CustId = @CustId AND [posting_date] >= CONVERT(DATETIME, @_JunReadDate) AND [posting_date] < CONVERT(DATETIME, @_JulReadDate) AND [transaction_type] IN (4, 5, 10) AND [ledger_type] IN ('WATER', 'SERVICE CHARGE', 'SEWERAGE') AND [ledger_subtype] != 'BEG')
					END
					ELSE
					BEGIN
						SET @_JunBillAdjustment = 0
					END
				END
			END
			

			SET @_JunBillTotal = (@_JunBillBasic - @_JunBillDiscount) - @_JunBillSenior + @_JunBillAdjustment

			-- || July Bill ------------------------------------------------------------------------------------------------------------------
			
			SELECT
				@_JulBillBasic = c.[SubTot1],
				@_JulBillDiscount = c.[SubTot2],
				@_JulBillSeptage = CASE WHEN @Instance = 2 THEN c.[SubTot3] ELSE 0 END,
				@_JulBillMeterCharge = CASE WHEN @Instance = 2 THEN c.[SubTot5] ELSE 0 END,
				@_JulBillSenior = 
					CASE
						WHEN @_Conf_Discounted = 1
						THEN
							CASE
								WHEN a.[SeniorDate] >= CONVERT(DATETIME, @_JulReadDate)
								THEN
									CASE
										WHEN ISNULL(b.[Cons1], 0) <= @_Conf_Cons_Senior
										THEN
											(b.[nbasic] - c.[SubTot2]) * 0.05
										ELSE
											CASE
												WHEN @_Conf_Cons_Higher_Disc = 1
												THEN
													(d.[MinBill] + (d.[Rate1] * 10) + (d.[Rate2] * 10)) * 0.05
												ELSE
													0
											END
									END
								ELSE
									0
							END
						ELSE
							0
					END,
				@_JulBillSeniorFixed =
					CASE
						WHEN a.[SeniorDate] >= CONVERT(DATETIME, @_JulReadDate)
						THEN
							CASE
								WHEN ISNULL(b.[Cons1], 0) <= @_Conf_Cons_Senior
								THEN
									(b.[nbasic] - c.[SubTot2]) * 0.05
								ELSE
									CASE
										WHEN @_Conf_Cons_Higher_Disc = 1
										THEN
											(d.[MinBill] + (d.[Rate1] * 10) + (d.[Rate2] * 10)) * 0.05
										ELSE
											0
									END
							END
						ELSE
							0
					END
			FROM
				[Cust] a
				OUTER APPLY
				(
					SELECT
						[Cons1],
						[nbasic]
					FROM
						[Rhist]
					WHERE
						CustId = a.CustId
						AND [BillDate] = '2020/07'
				) b
				OUTER APPLY
				(
					SELECT
						[SubTot1],
						[SubTot2],
						[SubTot3],
						[SubTot5]
					FROM
						[Cbill]
					WHERE
						CustId = a.CustId
						AND [BillDate] = '2020/07'
				) c
				LEFT JOIN [Bill] d
					ON a.[RateId] = d.[RateId] AND a.[ZoneId] = d.ZoneId
			WHERE
				a.CustId = @CustId

			SET @_JulBillBasic = ISNULL(@_JulBillBasic, 0)
			SET @_JulBillDiscount = ISNULL(@_JulBillDiscount, 0)
			SET @_JulBillSeptage = ISNULL(@_JulBillSeptage, 0)
			SET @_JulBillMeterCharge = ISNULL(@_JulBillMeterCharge, 0)
			SET @_JulBillSenior = ISNULL(@_JulBillSenior, 0)

			IF @_CSSVersion >= 7
			BEGIN
				IF @Instance = 1
				BEGIN
					SET @_JulBillAdjustment = (SELECT ISNULL(SUM([Debit]), 0) - ISNULL(SUM([Credit]), 0) FROM [cust_ledger] WHERE CustId = @CustId AND [posting_date] >= CONVERT(DATETIME, @_JulReadDate) AND [posting_date] < CONVERT(DATETIME, @_AugReadDate) AND [transaction_type] IN (4, 5, 10) AND [ledger_type] = 'WATER' AND [ledger_subtype] != 'BEG')
				END
				ELSE
				BEGIN
					IF @Instance = 2
					BEGIN
						SET @_JulBillAdjustment = (SELECT ISNULL(SUM([Debit]), 0) - ISNULL(SUM([Credit]), 0) FROM [cust_ledger] WHERE CustId = @CustId AND [posting_date] >= CONVERT(DATETIME, @_JulReadDate) AND [posting_date] < CONVERT(DATETIME, @_AugReadDate) AND [transaction_type] IN (4, 5, 10) AND [ledger_type] IN ('WATER', 'SERVICE CHARGE', 'SEWERAGE') AND [ledger_subtype] != 'BEG')
					END
					ELSE
					BEGIN
						SET @_JulBillAdjustment = 0
					END
				END
			END
			

			SET @_JulBillTotal = (@_JulBillBasic - @_JulBillDiscount) - @_JulBillSenior + @_JulBillAdjustment

			-- || August Bill ----------------------------------------------------------------------------------------------------------------
			
			SELECT
				@_AugBillBasic = c.[SubTot1],
				@_AugBillDiscount = c.[SubTot2],
				@_AugBillSeptage = CASE WHEN @Instance = 2 THEN c.[SubTot3] ELSE 0 END,
				@_AugBillMeterCharge = CASE WHEN @Instance = 2 THEN c.[SubTot5] ELSE 0 END,
				@_AugBillSenior = 
					CASE
						WHEN @_Conf_Discounted = 1
						THEN
							CASE
								WHEN a.[SeniorDate] >= CONVERT(DATETIME, @_AugReadDate)
								THEN
									CASE
										WHEN ISNULL(b.[Cons1], 0) <= @_Conf_Cons_Senior
										THEN
											(b.[nbasic] - c.[SubTot2]) * 0.05
										ELSE
											CASE
												WHEN @_Conf_Cons_Higher_Disc = 1
												THEN
													(d.[MinBill] + (d.[Rate1] * 10) + (d.[Rate2] * 10)) * 0.05
												ELSE
													0
											END
									END
								ELSE
									0
							END
						ELSE
							0
					END,
				@_AugBillSeniorFixed = 
					CASE
						WHEN a.[SeniorDate] >= CONVERT(DATETIME, @_AugReadDate)
						THEN
							CASE
								WHEN ISNULL(b.[Cons1], 0) <= @_Conf_Cons_Senior
								THEN
									(b.[nbasic] - c.[SubTot2]) * 0.05
								ELSE
									CASE
										WHEN @_Conf_Cons_Higher_Disc = 1
										THEN
											(d.[MinBill] + (d.[Rate1] * 10) + (d.[Rate2] * 10)) * 0.05
										ELSE
											0
									END
							END
						ELSE
							0
					END
			FROM
				[Cust] a
				OUTER APPLY
				(
					SELECT
						[Cons1],
						[nbasic]
					FROM
						[Rhist]
					WHERE
						CustId = a.CustId
						AND [BillDate] = '2020/08'
				) b
				OUTER APPLY
				(
					SELECT
						[SubTot1],
						[SubTot2],
						[SubTot3],
						[SubTot5]
					FROM
						[Cbill]
					WHERE
						CustId = a.CustId
						AND [BillDate] = '2020/08'
				) c
				LEFT JOIN [Bill] d
					ON a.[RateId] = d.[RateId] AND a.[ZoneId] = d.ZoneId
			WHERE
				a.CustId = @CustId

			SET @_AugBillBasic = ISNULL(@_AugBillBasic, 0)
			SET @_AugBillDiscount = ISNULL(@_AugBillDiscount, 0)
			SET @_AugBillSeptage = ISNULL(@_AugBillSeptage, 0)
			SET @_AugBillMeterCharge = ISNULL(@_AugBillMeterCharge, 0)
			SET @_AugBillSenior = ISNULL(@_AugBillSenior, 0)

			IF @_CSSVersion >= 7
			BEGIN
				IF @Instance = 1
				BEGIN
					SET @_AugBillAdjustment = (SELECT ISNULL(SUM([Debit]), 0) - ISNULL(SUM([Credit]), 0) FROM [cust_ledger] WHERE CustId = @CustId AND [posting_date] >= CONVERT(DATETIME, @_AugReadDate) AND [posting_date] < CONVERT(DATETIME, @_SepReadDate) AND [transaction_type] IN (4, 5, 10) AND [ledger_type] = 'WATER' AND [ledger_subtype] != 'BEG')
				END
				ELSE
				BEGIN
					IF @Instance = 2
					BEGIN
						SET @_AugBillAdjustment = (SELECT ISNULL(SUM([Debit]), 0) - ISNULL(SUM([Credit]), 0) FROM [cust_ledger] WHERE CustId = @CustId AND [posting_date] >= CONVERT(DATETIME, @_AugReadDate) AND [posting_date] < CONVERT(DATETIME, @_SepReadDate) AND [transaction_type] IN (4, 5, 10) AND [ledger_type] IN ('WATER', 'SERVICE CHARGE', 'SEWERAGE') AND [ledger_subtype] != 'BEG')
					END
					ELSE
					BEGIN
						SET @_AugBillAdjustment = 0
					END
				END
			END
			

			SET @_AugBillTotal = (@_AugBillBasic - @_AugBillDiscount) - @_AugBillSenior + @_AugBillAdjustment

			-- || March Payment --------------------------------------------------------------------------------------------------------------

			IF @_Conf_Migrate_March = 0
			BEGIN
				SELECT
					@_MarPayCurrent = SUM([Subtot1]),
					@_MarPayArrears = SUM([Subtot2]),
					@_MarPayAdvance = SUM([Subtot3]),
					@_MarPayMeterCharge = SUM(CASE WHEN @Instance = 2 THEN CASE @_Conf_MeterCharge_Subtot WHEN 5 THEN [Subtot5] WHEN 7 THEN [Subtot7] ELSE 0 END ELSE 0 END),
					@_MarPaySeptageCurrent = SUM(CASE WHEN @Instance = 2 THEN [Subtot12] ELSE 0 END),
					@_MarPaySeptageAdvanced = SUM(CASE WHEN @Instance = 2 THEN CASE WHEN @_CSSVersion >= 7 THEN [Subtot13] ELSE 0 END ELSE 0 END),
					@_MarPaySeptageArrears = SUM(CASE WHEN @Instance = 2 THEN CASE WHEN @_CSSVersion >= 7 THEN [Subtot14] ELSE 0 END ELSE 0 END),
					@_MarPayPN = SUM([rwatfee]),
					@_MarPayDiscNonSenior = SUM([Subtot10]) - (CASE WHEN @_MarBillSenior > 0 THEN (SUM([Subtot1]) + SUM([Tax1])) * 0.05 ELSE 0 END) - (CASE WHEN @_Conf_Senior_Arrears = 1 THEN CASE WHEN @_MarBillSenior > 0 THEN (SUM([Subtot2]) + SUM([Tax2])) * 0.05 ELSE 0 END ELSE 0 END),
					--@_MarPayDiscNonSenior = SUM([Subtot10]) - (CASE WHEN @_MarBillSenior > 0 THEN SUM([Tax1]) ELSE 0 END) - (CASE WHEN @_Conf_Senior_Arrears = 1 THEN CASE WHEN @_MarBillSenior > 0 THEN SUM([Tax2]) ELSE 0 END ELSE 0 END),

					@_FebPayPenalty = SUM([Subtot6])
				FROM
					[Cpaym]
				WHERE
					CustId = @CustId
					AND [PayDate] >= @_MarReadDate
					AND [PayDate] < @_AprReadDate

				SET @_MarPayCurrent = ISNULL(@_MarPayCurrent, 0)
				SET @_MarPayArrears = ISNULL(@_MarPayArrears, 0)
				SET @_MarPayAdvance = ISNULL(@_MarPayAdvance, 0)
				SET @_MarPayMeterCharge = ISNULL(@_MarPayMeterCharge, 0)
				SET @_MarPaySeptageCurrent = ISNULL(@_MarPaySeptageCurrent, 0)
				SET @_MarPaySeptageArrears = ISNULL(@_MarPaySeptageArrears, 0)
				SET @_MarPaySeptageAdvanced = ISNULL(@_MarPaySeptageAdvanced, 0)
				SET @_MarPayPN = ISNULL(@_MarPayPN, 0)
				SET @_MarPayDiscNonSenior = ISNULL(@_MarPayDiscNonSenior, 0)
				SET @_FebPayPenalty = ISNULL(@_FebPayPenalty, 0)

				SET @_MarPayTotal = @_MarPayCurrent + @_MarPayArrears + @_MarPayAdvance + @_MarPayMeterCharge + @_MarPaySeptageCurrent + @_MarPaySeptageArrears + @_MarPaySeptageAdvanced + @_MarPayPN + @_MarPayDiscNonSenior

				IF @_FebBillPenalty > @_FebPayPenalty
				BEGIN
					SET @_FebBillPenalty = @_FebBillPenalty - @_FebPayPenalty
					SET @_MarPayTotal = @_MarPayTotal + @_FebPayPenalty
				END
				ELSE
				BEGIN
					SET @_MarPayTotal = @_MarPayTotal + @_FebBillPenalty
					SET @_FebBillPenalty = 0
				END
			END
			ELSE
			BEGIN
				SELECT
					@_MarPayCurrent = SUM([Subtot1]),
					@_MarPayArrears = SUM([Subtot2]),
					@_MarPayAdvance = SUM([Subtot3]),
					@_MarPayMeterCharge = SUM(CASE WHEN @Instance = 2 THEN CASE @_Conf_MeterCharge_Subtot WHEN 5 THEN [Subtot5] WHEN 7 THEN [Subtot7] ELSE 0 END ELSE 0 END),
					@_MarPaySeptageCurrent = SUM(CASE WHEN @Instance = 2 THEN [Subtot12] ELSE 0 END),
					@_MarPaySeptageAdvanced = SUM(CASE WHEN @Instance = 2 THEN CASE WHEN @_CSSVersion >= 7 THEN [Subtot13] ELSE 0 END ELSE 0 END),
					@_MarPaySeptageArrears = SUM(CASE WHEN @Instance = 2 THEN CASE WHEN @_CSSVersion >= 7 THEN [Subtot14] ELSE 0 END ELSE 0 END),
					@_MayPayPN = SUM([rwatfee]),
					@_MarPayDiscNonSenior = SUM([Subtot10]) - (CASE WHEN @_MarBillSenior > 0 THEN (SUM([Subtot1]) + SUM([Tax1])) * 0.05 ELSE 0 END) - (CASE WHEN @_Conf_Senior_Arrears = 1 THEN CASE WHEN @_MarBillSenior > 0 THEN (SUM([Subtot2]) + SUM([Tax2])) * 0.05 ELSE 0 END ELSE 0 END),
					--@_MarPayDiscNonSenior = SUM([Subtot10]) - (CASE WHEN @_MarBillSenior > 0 THEN SUM([Tax1]) ELSE 0 END) - (CASE WHEN @_Conf_Senior_Arrears = 1 THEN CASE WHEN @_MarBillSenior > 0 THEN SUM([Tax2]) ELSE 0 END ELSE 0 END),

					@_FebPayPenalty = SUM([Subtot6])
				FROM
					[Cpaym] a
					OUTER APPLY
					(
						SELECT
							COUNT([refnum]) AS [PaymentOnLedger]
						FROM
							[cust_ledger]
						WHERE
							CustId = a.CustId
							AND [transaction_type] = 2
							AND [refnum] = a.[PymntNum]
					) b
				WHERE
					CustId = @CustId
					AND [PayDate] >= @_MarReadDate
					AND [PayDate] < @_AprReadDate
					AND b.[PaymentOnLedger] > 0

				SET @_MarPayCurrent = ISNULL(@_MarPayCurrent, 0)
				SET @_MarPayArrears = ISNULL(@_MarPayArrears, 0)
				SET @_MarPayAdvance = ISNULL(@_MarPayAdvance, 0)
				SET @_MarPayMeterCharge = ISNULL(@_MarPayMeterCharge, 0)
				SET @_MarPaySeptageCurrent = ISNULL(@_MarPaySeptageCurrent, 0)
				SET @_MarPaySeptageArrears = ISNULL(@_MarPaySeptageArrears, 0)
				SET @_MarPaySeptageAdvanced = ISNULL(@_MarPaySeptageAdvanced, 0)
				SET @_MarPayPN = ISNULL(@_MarPayPN, 0)
				SET @_MarPayDiscNonSenior = ISNULL(@_MarPayDiscNonSenior, 0)
				SET @_FebPayPenalty = ISNULL(@_FebPayPenalty, 0)

				SET @_MarPayTotal = @_MarPayCurrent + @_MarPayArrears + @_MarPayAdvance + @_MarPayMeterCharge + @_MarPaySeptageCurrent + @_MarPaySeptageArrears + @_MarPaySeptageAdvanced + @_MarPayPN + @_MarPayDiscNonSenior

				IF @_FebBillPenalty > @_FebPayPenalty
				BEGIN
					SET @_FebBillPenalty = @_FebBillPenalty - @_FebPayPenalty
					SET @_MarPayTotal = @_MarPayTotal + @_FebPayPenalty
				END
				ELSE
				BEGIN
					SET @_MarPayTotal = @_MarPayTotal + @_FebBillPenalty
					SET @_FebBillPenalty = 0
				END
			END

			-- || April Payment --------------------------------------------------------------------------------------------------------------
			
			SELECT
				@_AprPayCurrent = SUM([Subtot1]),
				@_AprPayArrears = SUM([Subtot2]),
				@_AprPayAdvance = SUM([Subtot3]),
				@_AprPayMeterCharge = SUM(CASE WHEN @Instance = 2 THEN CASE @_Conf_MeterCharge_Subtot WHEN 5 THEN [Subtot5] WHEN 7 THEN [Subtot7] ELSE 0 END ELSE 0 END),
				@_AprPaySeptageCurrent = SUM(CASE WHEN @Instance = 2 THEN [Subtot12] ELSE 0 END),
				@_AprPaySeptageAdvanced = SUM(CASE WHEN @Instance = 2 THEN CASE WHEN @_CSSVersion >= 7 THEN [Subtot13] ELSE 0 END ELSE 0 END),
				@_AprPaySeptageArrears = SUM(CASE WHEN @Instance = 2 THEN CASE WHEN @_CSSVersion >= 7 THEN [Subtot14] ELSE 0 END ELSE 0 END),
				@_AprPayPN = SUM([rwatfee]),
				@_AprPayDiscNonSenior = SUM([Subtot10]) - (CASE WHEN @_AprBillSenior > 0 THEN (SUM([Subtot1]) + SUM([Tax1])) * 0.05 ELSE 0 END) - (CASE WHEN @_Conf_Senior_Arrears = 1 THEN CASE WHEN @_AprBillSenior > 0 THEN (SUM([Subtot2]) + SUM([Tax2])) * 0.05 ELSE 0 END ELSE 0 END),
				--@_AprPayDiscNonSenior = SUM([Subtot10]) - (CASE WHEN @_AprBillSenior > 0 THEN SUM([Tax1]) ELSE 0 END) - (CASE WHEN @_Conf_Senior_Arrears = 1 THEN CASE WHEN @_AprBillSenior > 0 THEN SUM([Tax2]) ELSE 0 END ELSE 0 END),

				@_FebPayPenalty = SUM([Subtot6])
			FROM
				[Cpaym]
			WHERE
				CustId = @CustId
				AND [PayDate] >= @_AprReadDate
				AND [PayDate] < @_MayReadDate

			SET @_AprPayCurrent = ISNULL(@_AprPayCurrent, 0)
			SET @_AprPayArrears = ISNULL(@_AprPayArrears, 0)
			SET @_AprPayAdvance = ISNULL(@_AprPayAdvance, 0)
			SET @_AprPayMeterCharge = ISNULL(@_AprPayMeterCharge, 0)
			SET @_AprPaySeptageCurrent = ISNULL(@_AprPaySeptageCurrent, 0)
			SET @_AprPaySeptageArrears = ISNULL(@_AprPaySeptageArrears, 0)
			SET @_AprPaySeptageAdvanced = ISNULL(@_AprPaySeptageAdvanced, 0)
			SET @_AprPayPN = ISNULL(@_AprPayPN, 0)
			SET @_AprPayDiscNonSenior = ISNULL(@_AprPayDiscNonSenior, 0)
			SET @_FebPayPenalty = ISNULL(@_FebPayPenalty, 0)

			SET @_AprPayTotal = @_AprPayCurrent + @_AprPayArrears + @_AprPayAdvance + @_AprPayMeterCharge + @_AprPaySeptageCurrent + @_AprPaySeptageArrears + @_AprPaySeptageAdvanced + @_AprPayPN + @_AprPayDiscNonSenior

			IF @_FebBillPenalty > @_FebPayPenalty
			BEGIN
				SET @_FebBillPenalty = @_FebBillPenalty - @_FebPayPenalty
				SET @_AprPayTotal = @_AprPayTotal + @_FebPayPenalty
			END
			ELSE
			BEGIN
				SET @_AprPayTotal = @_AprPayTotal + @_FebBillPenalty
				SET @_FebBillPenalty = 0
			END

			-- || May Payment ----------------------------------------------------------------------------------------------------------------
			
			SELECT
				@_MayPayCurrent = SUM([Subtot1]),
				@_MayPayArrears = SUM([Subtot2]),
				@_MayPayAdvance = SUM([Subtot3]),
				@_MayPayMeterCharge = SUM(CASE WHEN @Instance = 2 THEN CASE @_Conf_MeterCharge_Subtot WHEN 5 THEN [Subtot5] WHEN 7 THEN [Subtot7] ELSE 0 END ELSE 0 END),
				@_MayPaySeptageCurrent = SUM(CASE WHEN @Instance = 2 THEN [Subtot12] ELSE 0 END),
				@_MayPaySeptageAdvanced = SUM(CASE WHEN @Instance = 2 THEN CASE WHEN @_CSSVersion >= 7 THEN [Subtot13] ELSE 0 END ELSE 0 END),
				@_MayPaySeptageArrears = SUM(CASE WHEN @Instance = 2 THEN CASE WHEN @_CSSVersion >= 7 THEN [Subtot14] ELSE 0 END ELSE 0 END),
				@_MayPayPN = SUM([rwatfee]),
				@_MayPayDiscNonSenior = SUM([Subtot10]) - (CASE WHEN @_MayBillSenior > 0 THEN (SUM([Subtot1]) + SUM([Tax1])) * 0.05 ELSE 0 END) - (CASE WHEN @_Conf_Senior_Arrears = 1 THEN CASE WHEN @_MayBillSenior > 0 THEN (SUM([Subtot2]) + SUM([Tax2])) * 0.05 ELSE 0 END ELSE 0 END),
				--@_MayPayDiscNonSenior = SUM([Subtot10]) - (CASE WHEN @_MayBillSenior > 0 THEN SUM([Tax1]) ELSE 0 END) - (CASE WHEN @_Conf_Senior_Arrears = 1 THEN CASE WHEN @_MayBillSenior > 0 THEN SUM([Tax2]) ELSE 0 END ELSE 0 END),

				@_FebPayPenalty = SUM([Subtot6])
			FROM
				[Cpaym]
			WHERE
				CustId = @CustId
				AND [PayDate] >= @_MayReadDate
				AND [PayDate] < @_JunReadDate

			SET @_MayPayCurrent = ISNULL(@_MayPayCurrent, 0)
			SET @_MayPayArrears = ISNULL(@_MayPayArrears, 0)
			SET @_MayPayAdvance = ISNULL(@_MayPayAdvance, 0)
			SET @_MayPayMeterCharge = ISNULL(@_MayPayMeterCharge, 0)
			SET @_MayPaySeptageCurrent = ISNULL(@_MayPaySeptageCurrent, 0)
			SET @_MayPaySeptageArrears = ISNULL(@_MayPaySeptageArrears, 0)
			SET @_MayPaySeptageAdvanced = ISNULL(@_MayPaySeptageAdvanced, 0)
			SET @_MayPayPN = ISNULL(@_MayPayPN, 0)
			SET @_MayPayDiscNonSenior = ISNULL(@_MayPayDiscNonSenior, 0)
			SET @_FebPayPenalty = ISNULL(@_FebPayPenalty, 0)

			SET @_MayPayTotal = @_MayPayCurrent + @_MayPayArrears + @_MayPayAdvance + @_MayPayMeterCharge + @_MayPaySeptageCurrent + @_MayPaySeptageArrears + @_MayPaySeptageAdvanced + @_MayPayPN + @_MayPayDiscNonSenior

			IF @_FebBillPenalty > @_FebPayPenalty
			BEGIN
				SET @_FebBillPenalty = @_FebBillPenalty - @_FebPayPenalty
				SET @_MayPayTotal = @_MayPayTotal + @_FebPayPenalty
			END
			ELSE
			BEGIN
				SET @_MayPayTotal = @_MayPayTotal + @_FebBillPenalty
				SET @_FebBillPenalty = 0
			END

			-- || June Payment ---------------------------------------------------------------------------------------------------------------
			
			SELECT
				@_JunPayCurrent = SUM([Subtot1]),
				@_JunPayArrears = SUM([Subtot2]),
				@_JunPayAdvance = SUM([Subtot3]),
				@_JunPayMeterCharge = SUM(CASE WHEN @Instance = 2 THEN CASE @_Conf_MeterCharge_Subtot WHEN 5 THEN [Subtot5] WHEN 7 THEN [Subtot7] ELSE 0 END ELSE 0 END),
				@_JunPaySeptageCurrent = SUM(CASE WHEN @Instance = 2 THEN [Subtot12] ELSE 0 END),
				@_JunPaySeptageAdvanced = SUM(CASE WHEN @Instance = 2 THEN CASE WHEN @_CSSVersion >= 7 THEN [Subtot13] ELSE 0 END ELSE 0 END),
				@_JunPaySeptageArrears = SUM(CASE WHEN @Instance = 2 THEN CASE WHEN @_CSSVersion >= 7 THEN [Subtot14] ELSE 0 END ELSE 0 END),
				@_JunPayPN = SUM([rwatfee]),
				@_JunPayDiscNonSenior = SUM([Subtot10]) - (CASE WHEN @_JunBillSenior > 0 THEN (SUM([Subtot1]) + SUM([Tax1])) * 0.05 ELSE 0 END) - (CASE WHEN @_Conf_Senior_Arrears = 1 THEN CASE WHEN @_JunBillSenior > 0 THEN (SUM([Subtot2]) + SUM([Tax2])) * 0.05 ELSE 0 END ELSE 0 END),
				--@_JunPayDiscNonSenior = SUM([Subtot10]) - (CASE WHEN @_JunBillSenior > 0 THEN SUM([Tax1]) ELSE 0 END) - (CASE WHEN @_Conf_Senior_Arrears = 1 THEN CASE WHEN @_JunBillSenior > 0 THEN SUM([Tax2]) ELSE 0 END ELSE 0 END),

				@_FebPayPenalty = SUM([Subtot6])
			FROM
				[Cpaym]
			WHERE
				CustId = @CustId
				AND [PayDate] >= @_JunReadDate
				AND [PayDate] < @_JulReadDate

			SET @_JunPayCurrent = ISNULL(@_JunPayCurrent, 0)
			SET @_JunPayArrears = ISNULL(@_JunPayArrears, 0)
			SET @_JunPayAdvance = ISNULL(@_JunPayAdvance, 0)
			SET @_JunPayMeterCharge = ISNULL(@_JunPayMeterCharge, 0)
			SET @_JunPaySeptageCurrent = ISNULL(@_JunPaySeptageCurrent, 0)
			SET @_JunPaySeptageArrears = ISNULL(@_JunPaySeptageArrears, 0)
			SET @_JunPaySeptageAdvanced = ISNULL(@_JunPaySeptageAdvanced, 0)
			SET @_JunPayPN = ISNULL(@_JunPayPN, 0)
			SET @_JunPayDiscNonSenior = ISNULL(@_JunPayDiscNonSenior, 0)
			SET @_FebPayPenalty = ISNULL(@_FebPayPenalty, 0)

			SET @_JunPayTotal = @_JunPayCurrent + @_JunPayArrears + @_JunPayAdvance + @_JunPayMeterCharge + @_JunPaySeptageCurrent + @_JunPaySeptageArrears + @_JunPaySeptageAdvanced + @_JunPayPN + @_JunPayDiscNonSenior

			IF @_FebBillPenalty > @_FebPayPenalty
			BEGIN
				SET @_FebBillPenalty = @_FebBillPenalty - @_FebPayPenalty
				SET @_JunPayTotal = @_JunPayTotal + @_FebPayPenalty
			END
			ELSE
			BEGIN
				SET @_JunPayTotal = @_JunPayTotal + @_FebBillPenalty
				SET @_FebBillPenalty = 0
			END

			-- || July Payment ---------------------------------------------------------------------------------------------------------------
			
			SELECT
				@_JulPayCurrent = SUM([Subtot1]),
				@_JulPayArrears = SUM([Subtot2]),
				@_JulPayAdvance = SUM([Subtot3]),
				@_JulPayMeterCharge = SUM(CASE WHEN @Instance = 2 THEN CASE @_Conf_MeterCharge_Subtot WHEN 5 THEN [Subtot5] WHEN 7 THEN [Subtot7] ELSE 0 END ELSE 0 END),
				@_JulPaySeptageCurrent = SUM(CASE WHEN @Instance = 2 THEN [Subtot12] ELSE 0 END),
				@_JulPaySeptageAdvanced = SUM(CASE WHEN @Instance = 2 THEN CASE WHEN @_CSSVersion >= 7 THEN [Subtot13] ELSE 0 END ELSE 0 END),
				@_JulPaySeptageArrears = SUM(CASE WHEN @Instance = 2 THEN CASE WHEN @_CSSVersion >= 7 THEN [Subtot14] ELSE 0 END ELSE 0 END),
				@_JulPayPN = SUM([rwatfee]),
				@_JulPayDiscNonSenior = SUM([Subtot10]) - (CASE WHEN @_JulBillSenior > 0 THEN (SUM([Subtot1]) + SUM([Tax1])) * 0.05 ELSE 0 END) - (CASE WHEN @_Conf_Senior_Arrears = 1 THEN CASE WHEN @_JulBillSenior > 0 THEN (SUM([Subtot2]) + SUM([Tax2])) * 0.05 ELSE 0 END ELSE 0 END),
				--@_JulPayDiscNonSenior = SUM([Subtot10]) - (CASE WHEN @_JulBillSenior > 0 THEN SUM([Tax1]) ELSE 0 END) - (CASE WHEN @_Conf_Senior_Arrears = 1 THEN CASE WHEN @_JulBillSenior > 0 THEN SUM([Tax2]) ELSE 0 END ELSE 0 END),

				@_FebPayPenalty = SUM([Subtot6])
			FROM
				[Cpaym]
			WHERE
				CustId = @CustId
				AND [PayDate] >= @_JulReadDate
				AND [PayDate] < @_AugReadDate

			SET @_JulPayCurrent = ISNULL(@_JulPayCurrent, 0)
			SET @_JulPayArrears = ISNULL(@_JulPayArrears, 0)
			SET @_JulPayAdvance = ISNULL(@_JulPayAdvance, 0)
			SET @_JulPayMeterCharge = ISNULL(@_JulPayMeterCharge, 0)
			SET @_JulPaySeptageCurrent = ISNULL(@_JulPaySeptageCurrent, 0)
			SET @_JulPaySeptageArrears = ISNULL(@_JulPaySeptageArrears, 0)
			SET @_JulPaySeptageAdvanced = ISNULL(@_JulPaySeptageAdvanced, 0)
			SET @_JulPayPN = ISNULL(@_JulPayPN, 0)
			SET @_JulPayDiscNonSenior = ISNULL(@_JulPayDiscNonSenior, 0)
			SET @_FebPayPenalty = ISNULL(@_FebPayPenalty, 0)

			SET @_JulPayTotal = @_JulPayCurrent + @_JulPayArrears + @_JulPayAdvance + @_JulPayMeterCharge + @_JulPaySeptageCurrent + @_JulPaySeptageArrears + @_JulPaySeptageAdvanced + @_JulPayPN + @_JulPayDiscNonSenior

			IF @_FebBillPenalty > @_FebPayPenalty
			BEGIN
				SET @_FebBillPenalty = @_FebBillPenalty - @_FebPayPenalty
				SET @_JulPayTotal = @_JulPayTotal + @_FebPayPenalty
			END
			ELSE
			BEGIN
				SET @_JulPayTotal = @_JulPayTotal + @_FebBillPenalty
				SET @_FebBillPenalty = 0
			END

			-- || August Payment -------------------------------------------------------------------------------------------------------------
			
			SELECT
				@_AugPayCurrent = SUM([Subtot1]),
				@_AugPayArrears = SUM([Subtot2]),
				@_AugPayAdvance = SUM([Subtot3]),
				@_AugPayMeterCharge = SUM(CASE WHEN @Instance = 2 THEN CASE @_Conf_MeterCharge_Subtot WHEN 5 THEN [Subtot5] WHEN 7 THEN [Subtot7] ELSE 0 END ELSE 0 END),
				@_AugPaySeptageCurrent = SUM(CASE WHEN @Instance = 2 THEN [Subtot12] ELSE 0 END),
				@_AugPaySeptageAdvanced = SUM(CASE WHEN @Instance = 2 THEN CASE WHEN @_CSSVersion >= 7 THEN [Subtot13] ELSE 0 END ELSE 0 END),
				@_AugPaySeptageArrears = SUM(CASE WHEN @Instance = 2 THEN CASE WHEN @_CSSVersion >= 7 THEN [Subtot14] ELSE 0 END ELSE 0 END),
				@_AugPayPN = SUM([rwatfee]),
				@_AugPayDiscNonSenior = SUM([Subtot10]) - (CASE WHEN @_AugBillSenior > 0 THEN (SUM([Subtot1]) + SUM([Tax1])) * 0.05 ELSE 0 END) - (CASE WHEN @_Conf_Senior_Arrears = 1 THEN CASE WHEN @_AugBillSenior > 0 THEN (SUM([Subtot2]) + SUM([Tax2])) * 0.05 ELSE 0 END ELSE 0 END),
				--@_AugPayDiscNonSenior = SUM([Subtot10]) - (CASE WHEN @_AugBillSenior > 0 THEN SUM([Tax1]) ELSE 0 END) - (CASE WHEN @_Conf_Senior_Arrears = 1 THEN CASE WHEN @_AugBillSenior > 0 THEN SUM([Tax2]) ELSE 0 END ELSE 0 END),

				@_FebPayPenalty = SUM([Subtot6])
			FROM
				[Cpaym]
			WHERE
				CustId = @CustId
				AND [PayDate] >= @_AugReadDate
				AND [PayDate] < @_SepReadDate

			SET @_AugPayCurrent = ISNULL(@_AugPayCurrent, 0)
			SET @_AugPayArrears = ISNULL(@_AugPayArrears, 0)
			SET @_AugPayAdvance = ISNULL(@_AugPayAdvance, 0)
			SET @_AugPayMeterCharge = ISNULL(@_AugPayMeterCharge, 0)
			SET @_AugPaySeptageCurrent = ISNULL(@_AugPaySeptageCurrent, 0)
			SET @_AugPaySeptageArrears = ISNULL(@_AugPaySeptageArrears, 0)
			SET @_AugPaySeptageAdvanced = ISNULL(@_AugPaySeptageAdvanced, 0)
			SET @_AugPayPN = ISNULL(@_AugPayPN, 0)
			SET @_AugPayDiscNonSenior = ISNULL(@_AugPayDiscNonSenior, 0)
			SET @_FebPayPenalty = ISNULL(@_FebPayPenalty, 0)

			SET @_AugPayTotal = @_AugPayCurrent + @_AugPayArrears + @_AugPayAdvance + @_AugPayMeterCharge + @_AugPaySeptageCurrent + @_AugPaySeptageArrears + @_AugPaySeptageAdvanced + @_AugPayPN + @_AugPayDiscNonSenior

			IF @_FebBillPenalty > @_FebPayPenalty
			BEGIN
				SET @_FebBillPenalty = @_FebBillPenalty - @_FebPayPenalty
				SET @_AugPayTotal = @_AugPayTotal + @_FebPayPenalty
			END
			ELSE
			BEGIN
				SET @_AugPayTotal = @_AugPayTotal + @_FebBillPenalty
				SET @_FebBillPenalty = 0
			END

			----------------------------------

			DECLARE @_BillInfo TABLE
			(
				[Month] INT,
				[Amount] DECIMAL(18, 2)
			)

			DECLARE @_PayInfo TABLE
			(
				[Month] INT,
				[Amount] DECIMAL(18, 2)
			)

			DECLARE @_Counter1 INT
			DECLARE @_Counter2 INT
			DECLARE @_AmountToDistribute DECIMAL(18, 2)
			DECLARE @_CurrentMonthBalance DECIMAL(18, 2)

			INSERT @_BillInfo ([Month], [Amount]) VALUES (2, CASE WHEN @_FebBalance > 0 THEN @_FebBalance ELSE 0 END)
			INSERT @_BillInfo ([Month], [Amount]) VALUES (3, @_MarBillTotal)
			INSERT @_BillInfo ([Month], [Amount]) VALUES (4, @_AprBillTotal)
			INSERT @_BillInfo ([Month], [Amount]) VALUES (5, @_MayBillTotal)
			INSERT @_BillInfo ([Month], [Amount]) VALUES (6, @_JunBillTotal)
			INSERT @_BillInfo ([Month], [Amount]) VALUES (7, @_JulBillTotal)
			INSERT @_BillInfo ([Month], [Amount]) VALUES (8, @_AugBillTotal)

			INSERT @_PayInfo ([Month], [Amount]) VALUES (2, CASE WHEN @_FebBalance < 0 THEN ABS(@_FebBalance) ELSE 0 END)
			INSERT @_PayInfo ([Month], [Amount]) VALUES (3, @_MarPayTotal)
			INSERT @_PayInfo ([Month], [Amount]) VALUES (4, @_AprPayTotal)
			INSERT @_PayInfo ([Month], [Amount]) VALUES (5, @_MayPayTotal)
			INSERT @_PayInfo ([Month], [Amount]) VALUES (6, @_JunPayTotal)
			INSERT @_PayInfo ([Month], [Amount]) VALUES (7, @_JulPayTotal)
			INSERT @_PayInfo ([Month], [Amount]) VALUES (8, @_AugPayTotal)

			SET @_Counter1 = 2
			SET @_AmountToDistribute = 0

			WHILE(@_Counter1 < 8)
			BEGIN
				SET @_AmountToDistribute = @_AmountToDistribute + (SELECT [Amount] FROM @_PayInfo WHERE [Month] = @_Counter1)
				SET @_CurrentMonthBalance = (SELECT [Amount] FROM @_BillInfo WHERE [Month] = @_Counter1)

				IF(@_AmountToDistribute > @_CurrentMonthBalance)
				BEGIN
					UPDATE @_BillInfo SET [Amount] = 0 WHERE [Month] = @_Counter1
					SET @_AmountToDistribute = @_AmountToDistribute - @_CurrentMonthBalance
				END
				ELSE
				BEGIN
					UPDATE @_BillInfo SET [Amount] = [Amount] - @_AmountToDistribute WHERE [Month] = @_Counter1
					SET @_AmountToDistribute = 0
				END

				IF(@_AmountToDistribute > 0)
				BEGIN
					SET @_Counter2 = 2

					WHILE(@_Counter2 <= @_Counter1 - 1)
					BEGIN
						SET @_CurrentMonthBalance = (SELECT [Amount] FROM @_BillInfo WHERE [Month] = @_Counter2)

						IF(@_AmountToDistribute > @_CurrentMonthBalance)
						BEGIN
							UPDATE @_BillInfo SET [Amount] = 0 WHERE [Month] = @_Counter2
							SET @_AmountToDistribute = @_AmountToDistribute - @_CurrentMonthBalance
						END
						ELSE
						BEGIN
							UPDATE @_BillInfo SET [Amount] = [Amount] - @_AmountToDistribute WHERE [Month] = @_Counter2
							SET @_AmountToDistribute = 0
						END

						SET @_Counter2 = @_Counter2 + 1
					END
				END

				SET @_Counter1 = @_Counter1 + 1
			END

			/*
			SET @_MarRunningAmount = @_MarBillTotal - @_MarPayTotal
			SET @_AprRunningAmount = @_AprBillTotal - @_AprPayTotal
			SET @_MayRunningAmount = @_MayBillTotal - @_MayPayTotal
			SET @_JunRunningAmount = @_JunBillTotal - @_JunPayTotal
			SET @_JulRunningAmount = @_JulBillTotal - @_JulPayTotal
			SET @_AugRunningAmount = @_AugBillTotal - @_AugPayTotal
			*/

			SET @_FebRunningAmount = (SELECT [Amount] FROM @_BillInfo WHERE [Month] = 2)
			SET @_MarRunningAmount = (SELECT [Amount] FROM @_BillInfo WHERE [Month] = 3)
			SET @_AprRunningAmount = (SELECT [Amount] FROM @_BillInfo WHERE [Month] = 4)
			SET @_MayRunningAmount = (SELECT [Amount] FROM @_BillInfo WHERE [Month] = 5)
			SET @_JunRunningAmount = (SELECT [Amount] FROM @_BillInfo WHERE [Month] = 6)
			SET @_JulRunningAmount = (SELECT [Amount] FROM @_BillInfo WHERE [Month] = 7)
			SET @_AugRunningAmount = (SELECT [Amount] FROM @_BillInfo WHERE [Month] = 8)

			INSERT @ArrearsTable
			VALUES
			(
				@_FebRunningAmount,
				@_MarRunningAmount,
				@_AprRunningAmount,
				@_MayRunningAmount,
				@_JunRunningAmount,
				@_JulRunningAmount,
				@_AugRunningAmount,
				@_FebPenalty,
				@_MarBillSeniorFixed,
				@_AprBillSeniorFixed,
				@_MayBillSeniorFixed,
				@_JunBillSeniorFixed,
				@_JulBillSeniorFixed,
				@_AugBillSeniorFixed,
				@_MarBillMeterCharge,
				@_AprBillMeterCharge,
				@_MayBillMeterCharge,
				@_JunBillMeterCharge,
				@_JulBillMeterCharge,
				@_AugBillMeterCharge,
				@_MarBillSeptage,
				@_AprBillSeptage,
				@_MayBillSeptage,
				@_JunBillSeptage,
				@_JulBillSeptage,
				@_AugBillSeptage
			)
		END
		/*
		ELSE
		----------------------------------------------------------------------------------------------------------------------------------
		----------------------------------------------------------------------------------------------------------------------------------
		-- || July 2020 Modified GCQ Arrears Computation
		-- || (for Sta. Cruz only)
		----------------------------------------------------------------------------------------------------------------------------------
		----------------------------------------------------------------------------------------------------------------------------------
		BEGIN
			DECLARE
				@_MarBasic DECIMAL(18, 2),
				@_AprBasic DECIMAL(18, 2),
				@_MayBasic DECIMAL(18, 2),
				@_JunBasic DECIMAL(18, 2)

			DECLARE @_BillBreak DECIMAL(18, 2)

			SET @_MarBasic = (SELECT [nbasic] FROM [Rhist] WHERE [CustNum] = @CustNum AND [BillDate] = '2020/03')
			SET @_MarBasic = CASE ISNUMERIC(@_MarBasic) WHEN 1 THEN @_MarBasic ELSE 0 END

			SET @_AprBasic = (SELECT [nbasic] FROM [Rhist] WHERE [CustNum] = @CustNum AND [BillDate] = '2020/04')
			SET @_AprBasic = CASE ISNUMERIC(@_AprBasic) WHEN 1 THEN @_AprBasic ELSE 0 END

			SET @_MayBasic = (SELECT [nbasic] FROM [Rhist] WHERE [CustNum] = @CustNum AND [BillDate] = '2020/05')
			SET @_MayBasic = CASE ISNUMERIC(@_MayBasic) WHEN 1 THEN @_MayBasic ELSE 0 END

			SET @_JunBasic = (SELECT [nbasic] FROM [Rhist] WHERE [CustNum] = @CustNum AND [BillDate] = '2020/06')
			SET @_JunBasic = CASE ISNUMERIC(@_JunBasic) WHEN 1 THEN @_JunBasic ELSE 0 END

			SET @_BillBreak = (@_MarBasic + @_AprBasic + @_MayBasic + @_JunBasic) / 6

			INSERT @ArrearsTable
			VALUES
			(
				0, 0, 0, 0,
				@_BillBreak,
				@_BillBreak,
				@_BillBreak,
				@_BillBreak,
				@_BillBreak,
				@_BillBreak,
				0
			)
		END
		*/
	END

	RETURN;
END

GO


