ALTER PROCEDURE [dbo].[sp_generatebillingtxtfile]
	-- Add the parameters for the stored procedure here
	@billdate varchar(7),
	@BookId int,
	@sortby int,
	@dunning varchar(max),
	@dunning1 varchar(max)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	Select result = left(convert(varchar(100),b.billnum) + '          ',10)--BIll #
	+
	left(right(a.billdate,2) + '-' + left(a.billdate,4) + '          ',10)--Billing Month
	+
	left(convert(varchar(20),b.duedate) + '          ',10)--DueDate
	+
	left(convert(varchar(20),b.duedate) + '          ',10)--DueDate1
	+
	left(c.custnum + '                    ',20)--custnum
	+
	left(c.custname + '                                                            ',70)--custname
	+
	left(isnull(c.BilStAdd,'') + '                                                            ',64)--bilstadd
	+ 
	left(c.BilCtAdd + '                                                            ',64)--bilctadd
	+ 
	left(d.RateName + '                                                            ',12)--ratename
	+ 
	left(convert(varchar(100),isnull(a.read1,0)) + '                                                            ',10)--read1
	+ 
	left(convert(varchar(100),isnull(a.pread1,0)) + '                                                            ',10)--pread1
	+ 
	left(convert(varchar(100),isnull(a.cons1,0)) + '                                                            ',10)--cons1
	+ 
	left(isnull(e.MeterNo1,'') + '                                                            ',20)--meterno1
	+ 
	right('                                                            ' + isnull(h.billperiod,''),24)--billperiod
	+ 
	left('Balance from Last Bill' + '                                                            ',50)--label1
	+ 
	left('Basic Charge' + '                                                            ',30)--label2
	+ 
	left('Reconnection Fee' + '                                                            ',30)--label3
	+ 
	left('Sewerage' + '                                                            ',30)

	+ 
	left(case when a.BookId in(Select BookId from Books where BookNo in('2303','2305','2315')) then 'Environmental Mgt Fee' else '' end 
		+ '                                                            ',30)
	+
	left('Amortization of Promissory Note' + '                                                            ',40)
	+ 
	left('12% VAT' + '                                                            ',30)
	+ 
	left('Total Charges' + '                                                            ',30)
	+ 
	left('' + '                                                            ',30)
	+ 
	left('' + '                                                            ',30)
	+ 
	left('' + '                                                            ',30)
	+
	left('Minimum Amount Due (Php)' + '                                                            ',30)
	+
	left('Remarks' + '                                                            ',8)
	+
	left(convert(varchar(100),b.SubTot4 + isnull(i.[Old Arrears],0) + isnull(i.Sewerage,0) + isnull(i.[Service Charge],0)) + '                                                            ',12)--subtot4
	+
	left(convert(varchar(100),b.subtot1) + '                                                            ',12)--subtot1
	+
	left('(Inclusive of VAT)' + '                                                            ',19)
	+
	left(convert(varchar(100),isnull(i.[Penalty Balance],0)) + '                                                            ',12)--recon
	+
	left(convert(varchar(100),b.SubTot3) + '                                                            ',12)--sewerage
	+
	left(convert(varchar(100),b.SubTot5)  + '                                                            ',12)--envir mgt
	+
	left(convert(varchar(100),isnull(f.pn_remit,0)) + '                                                            ',12)--pnamount
	+
	left(convert(varchar(100),b.subtot1 - (b.subtot1 / 1.12)) + '                                                            ',12)--vat
	+
	left(convert(varchar(100),isnull(b.subtot1,0) + isnull(b.subtot2,0) + isnull(b.subtot3,0) + isnull(b.subtot4,0) + isnull(b.subtot5,0)
	+ (isnull(i.[Total Balance],0) - isnull(i.[Water Balance],0))
	) + '                                                            ',12)--total
	+
	left('' + '                                                            ',12)--others
	+
	left(@dunning + ' ' + @dunning1  + '                                                                                                                                                                                                                                                                                                                                              ',270)--remarks
	+
	left(rtrim(ltrim(c.cbank_ref)) + right(replace(convert(varchar(20),b.duedate),'/',''),4)  + '                                                            ',14)--atmref
	+
	--right('                                                            ' + convert(varchar(100),isnull(g.subtot4,0)),12)--HOA Arrears
	right('                                                            ' + convert(varchar(100),0),12)--HOA Arrears
	+
	--right('                                                            ' + convert(varchar(100),isnull(g.SubTot1,0)),12)--HOA Basic
	right('                                                            ' + convert(varchar(100),0),12)--HOA Basic
	+
	--right('                                                            ' + convert(varchar(100),isnull(g.SubTot1,0) + isnull(g.subtot4,0) + isnull(g.subtot2,0) + isnull(g.subtot3,0) + isnull(g.subtot5,0) -- + isnull(g.subtot6,0)
	right('                                                            ' + convert(varchar(100),0 -- + isnull(g.subtot6,0)
	 + isnull(b.subtot1,0) + isnull(b.subtot2,0) + isnull(b.subtot3,0) + isnull(b.subtot4,0) + isnull(b.subtot5,0)
	+ (isnull(i.[Total Balance],0) - isnull(i.[Water Balance],0))
	),12)--Grand Total
	+
	--right('                                                            ' + convert(varchar(100),isnull(g.SubTot1,0) + isnull(g.subtot4,0)),12)--HOA Total
	right('                                                            ' + convert(varchar(100),0),12)--HOA Total
	+
	--right('                                                            ' + convert(varchar(100),isnull(g.SubTot1,0) + isnull(g.subtot4,0) + isnull(g.subtot2,0) + isnull(g.subtot3,0) + isnull(g.subtot5,0) -- + isnull(g.subtot6,0)
	right('                                                            ' + convert(varchar(100),0 -- + isnull(g.subtot6,0)
	 + isnull(b.subtot1,0) + isnull(b.subtot2,0) + isnull(b.subtot3,0) + isnull(b.subtot4,0) + isnull(b.subtot5,0)
	+ (isnull(i.[Total Balance],0) - isnull(i.[Water Balance],0))
	),12)--Min Amount Due
	+
	--right('                                                            ' + convert(varchar(100),isnull(g.subtot2,0)),12)--Enviro Arrears
	right('                                                            ' + convert(varchar(100),0),12)--Enviro Arrears
	+
	--right('                                                            ' + convert(varchar(100),isnull(g.subtot5,0)),12)--Enviro Basic
	right('                                                            ' + convert(varchar(100),0),12)--Enviro Basic
	+
	--left(convert(varchar(100),isnull(g.subtot5,0) + isnull(g.subtot2,0)) + '                                                            ',12)--Enviro Total
	left(convert(varchar(100),0) + '                                                            ',12)--Enviro Total
	
	from rhist a
	inner join cbill b
	on a.RhistId = b.RhistId
	inner join cust c
	on a.CustId = c.CustId
	inner join rates d
	on a.RateId = d.RateId
	inner join members e
	on a.CustId = e.CustId
	left join(Select *,ctr = ROW_NUMBER() over(partition by CustId order by dtransd) from pn1 where end_bal > 0)f
	on c.CustId = f.CustId
	and f.ctr = 1
	inner join tbill h
	on b.BillNum = h.BillNum
	left join vw_ledger i
	on a.CustId = i.CustId
	where a.BookId = @BookId
	and a.billdate = @billdate
	order by (case when @sortby = 0 then isnull(e.seqno,0)
	else c.CustNum end)
END
