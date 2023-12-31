ALTER PROCEDURE [dbo].[sp_retgdtopay] 
	-- Add the parameters for the stored procedure here
	@CustId int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	declare @lastbilldate as varchar(100)
	IF(NOT EXISTS(Select top 1 BillNum FROM Cbill where CustId = @CustId))
	BEGIN
		set @lastbilldate = left(convert(varchar(100),getdate(),111),7)
	END
	ELSE
	BEGIN
		set @lastbilldate = (Select max(BillDate) FROM Cbill where CustId = @CustId)
	END
	declare @lastbilldate1 as varchar(7)
	declare @lastbilldate2 as varchar(7)
	declare @lastbilldate3 as varchar(7)
	declare @lastbilldate4 as varchar(7)
	declare @lastbilldate5 as varchar(7)
	set @lastbilldate1 = left(convert(varchar(100),DATEADD(month,-1,convert(date,@lastbilldate + '/1')),111),7)
	set @lastbilldate2 = left(convert(varchar(100),DATEADD(month,-2,convert(date,@lastbilldate + '/1')),111),7)
	set @lastbilldate3 = left(convert(varchar(100),DATEADD(month,-3,convert(date,@lastbilldate + '/1')),111),7)
	set @lastbilldate4 = left(convert(varchar(100),DATEADD(month,-4,convert(date,@lastbilldate + '/1')),111),7)
	set @lastbilldate5 = left(convert(varchar(100),DATEADD(month,-5,convert(date,@lastbilldate + '/1')),111),7)
	

	Select a.CustId,a.custnum as [Acct #]
	,a.oldcustnum
	,a.CustName as Name,j.StatDesc as [Connection-Status]
	,isnull(k.[Water Balance],0) as [Water Balance]
	,isnull(k.[Penalty Balance],0) as [Penalty Balance]
	,isnull(k.[Old Arrears],0) as OldArrears,isnull(k.[Guarantee Deposit],0) as [GD Balance]
	,isnull(k.[Total Balance],0) as total
	,isnull(c.SubTot1,i.MinBill) as [Last Bill Amt]
	,isnull(d.SubTot1,i.MinBill) as [2nd Last]
	,isnull(e.SubTot1,i.MinBill) as [3rd Last]
	,isnull(f.SubTot1,i.MinBill) as [4th Last]
	,isnull(g.SubTot1,i.MinBill) as [5th Last]
	,isnull(h.SubTot1,i.MinBill) as [6th Last]
	,Average = (isnull(c.SubTot1,i.MinBill) + isnull(d.SubTot1,i.MinBill) + isnull(e.SubTot1,i.MinBill) + isnull(f.SubTot1,i.MinBill) + isnull(g.SubTot1,i.MinBill) + isnull(h.SubTot1,i.MinBill))/6
	,[Deposit Computation] = convert(numeric(18,2),(((isnull(c.SubTot1,i.MinBill) + isnull(d.SubTot1,i.MinBill) + isnull(e.SubTot1,i.MinBill) + isnull(f.SubTot1,i.MinBill) + isnull(g.SubTot1,i.MinBill) + isnull(h.SubTot1,i.MinBill))/6) * 2) + ((((isnull(c.SubTot1,i.MinBill) + isnull(d.SubTot1,i.MinBill) + isnull(e.SubTot1,i.MinBill) + isnull(f.SubTot1,i.MinBill) + isnull(g.SubTot1,i.MinBill) + isnull(h.SubTot1,i.MinBill))/6) * 2) * 0.1))
	,[Final Deposit] = 0
	from cust a
	INNER JOIN members b
	on a.CustId = b.CustId
	LEFT JOIN cbill c
	on a.CustId = c.CustId
	and c.CustId = @CustId
	and c.BillDate = @lastbilldate
	LEFT JOIN cbill d
	on a.CustId = d.CustId
	and d.CustId = @CustId
	and d.BillDate = @lastbilldate1
	LEFT JOIN cbill e
	on a.CustId = e.CustId
	and e.CustId = @CustId
	and e.BillDate = @lastbilldate2
	LEFT JOIN cbill f
	on a.CustId = f.CustId
	and f.CustId = @CustId
	and f.BillDate = @lastbilldate3
	LEFT JOIN cbill g
	on a.CustId = g.CustId
	and g.CustId = @CustId
	and g.BillDate = @lastbilldate4
	LEFT JOIN cbill h
	on a.CustId = h.CustId
	and h.CustId = @CustId
	and h.BillDate = @lastbilldate5
	INNER JOIN bill i
	on a.RateId = i.RateId
	and a.ZoneId = i.ZoneId
	LEFT JOIN CustStat j
	on a.Status = j.StatCd
	LEFT JOIN vw_ledger k
	on a.CustId = k.CustId
END
