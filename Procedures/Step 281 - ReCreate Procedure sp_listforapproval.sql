ALTER PROCEDURE [dbo].[sp_listforapproval]
	-- Add the parameters for the stored procedure here
	@read int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	declare @billdate varchar(7)
	
	set @billdate = (Select max(billdate) from Rhist)
		Select convert(bit,0) as [ ],--0
		b.custnum as [Acct #],--1
		b.CustName as Name,--2
        b.BilStAdd as [Address],--3
		a.billdate as [Blling Month],--4
        d.BookNo as [Book #],--5
		f.ratename as [Classification],--6
		c.Pread1 as [Prev RDG],--7
        c.Read1 as [Pres RDG],--8
		c.Cons1 as [Consumption],--9
		c.nbasic as [Basic Charge],--10
        c.Remark,--11
		e.FindDesc as [Findings]--12
        from for_approval a
        INNER JOIN cust b
        on a.custnum = b.custnum
        inner join rhist c
        on b.CustId = c.CustId
        and a.billdate = c.BillDate
		INNER JOIN Books d
		on c.BookId = d.BookId
        left join Finding e
        on c.FF1Cd = e.FindCd
        left join rates f
        on c.rateid = f.rateid
        where a.[read] = @read
		and a.approved = 0
        order by d.BookNo,left(a.custnum,4) + right(a.custnum,4)
END
