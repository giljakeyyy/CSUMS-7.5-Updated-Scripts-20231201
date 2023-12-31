ALTER PROCEDURE [dbo].[sp_smsdisconnoticedetails]
	-- Add the parameters for the stored procedure here
	@BookId int,
	@billdate varchar(7)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	
	declare @penaltytable table(CustId int,penaltyamount money)
	declare @custtable table(CustId int,id int identity(1,1))

	insert @custtable(CustId)
	select CustId from members where BookId = @BookId

	declare @ctr int
	set @ctr = 1;
	declare @CustId int
	declare @currpen money
	set @CustId = 0

	
	declare @penaltytable1 table(penaltyamount money)




	WHILE(@ctr <= isnull((Select max(id) from @custtable),0))
	BEGIN
		
		set @CustId = isnull((Select CustId from @custtable where id = @ctr),'')

		insert @penaltytable1
		exec sp_cumputeunsubmittedpenalty @CustId

		set @currpen = isnull((Select penaltyamount from @penaltytable1),0)

		insert @penaltytable
		values(@CustId,@currpen)

		delete from @penaltytable1

		set @ctr = @ctr + 1
	END


	select a.CustId,a.custnum,isnull(d.[Total Balance],0)+ (case when b.billstat = 1 then b.subtot1 else 0.00 end)
	+

	isnull(h.penaltyamount,0)
	,
	convert(varchar(6),cast(g.discdate as datetime),107) as discondate,a.ccelnumber 
	,':' + rtrim(ltrim(a.cbank_ref)) + right(replace(convert(varchar(20),convert(datetime,g.discdate),111),'/',''),4) as atmref
	,':' + convert(varchar(100),f.billnum),a.custname,'atmref=' + rtrim(ltrim(a.cbank_ref)) + right(replace(convert(varchar(20),convert(datetime,g.discdate),111),'/',''),4) + '&billnum=' + convert(varchar(100),f.billnum)
	FROM cust a
	LEFT JOIN Cbill b 
	on a.CustId=b.CustId and b.billdate=@billdate
	LEFT JOIN vw_ledger d
	on a.CustId = d.CustId
	LEFT JOIN rhist e
	on a.CustId = e.CustId
	and e.billdate = @billdate
	left join members f
	on a.CustId = f.CustId
	left join billingschedule g
	on f.BookId = g.BookId
	and g.billdate = @billdate
	left join @penaltytable h
	on a.CustId = h.CustId
	where f.BookId = @BookId and len(ccelnumber)=11
	and isnull([total balance],0) > 0
	and convert(varchar(20),e.duedate,111) < convert(varchar(20),getdate(),111)
END
