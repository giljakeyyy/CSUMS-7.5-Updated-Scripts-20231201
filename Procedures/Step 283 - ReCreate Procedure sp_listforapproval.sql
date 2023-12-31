ALTER PROCEDURE [dbo].[sp_loadforapproval]
	-- Add the parameters for the stored procedure here
	@billdate varchar(7),
	@BookId int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here

		Select convert(bit,0) as [ ],--0
		b.RhistId,
		f.custnum as [Acct #],--1
		f.CustName as Name,--2
        f.BilStAdd as [Address],--3
		b.billdate as [Blling Month],--4
        a.BookNo as [Book #],--5
		e.ratename as [Classification],--6
		b.Pread1 as [Prev RDG],--7
        b.Read1 as [Pres RDG],--8
		b.Cons1 as [Consumption],--9
		b.nbasic as [Basic Charge],--10
        b.Remark,--11
		d.FindDesc as [Findings]--12


        from rhist b
		INNER JOIN Books a
		on b.BookId = a.BookId
        INNER JOIN members c
        on b.CustId = c.CustId
        inner join cust f
        on b.CustId = f.CustId
        left join Finding d
        on b.FF1Cd = d.FindCd
        left join rates e
        on b.RateId = e.RateId
        left join cbill g
        on b.RhistId = g.RhistId
        left join rategroup h
        on e.rgroupid = h.rgroupid
        where b.ff3cd = 0
        and b.billdate = @billdate and b.BookId = @BookId
        and b.nbasic > 0
        and
        (
        ((isnull(b.cons1,0) >= (isnull(c.avecon1,0) * (case
        when RGDesc = 'Government' or RGdesc = 'Residential' then 1.5
        else 1.75 end))) and b.cons1 > 10)
        or
        ((isnull(b.cons1,0) <= (isnull(c.avecon1,0) - ((isnull(c.avecon1,0) * (case
        when RGDesc = 'Government' or RGdesc = 'Residential' then 0.25
        else 0.25 end)))) and c.AveCon1 > 10)
        ))
        and isnull(b.remark,'') <> ''
        order by b.nbasic desc
END
