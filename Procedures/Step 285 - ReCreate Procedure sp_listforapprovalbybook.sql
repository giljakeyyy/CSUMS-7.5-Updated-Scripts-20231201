ALTER PROCEDURE [dbo].[sp_loadforapprovalbybook]
	-- Add the parameters for the stored procedure here
	@billdate varchar(7)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	Select a.BookNo as [Book #],count(b.CustId) as [Count]
    from rhist b
	INNER JOIN Books a
	on a.BookId = b.BookId
    inner join members c
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
    and b.billdate = @billdate
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
    group by a.bookno
    order by a.bookno desc
END
