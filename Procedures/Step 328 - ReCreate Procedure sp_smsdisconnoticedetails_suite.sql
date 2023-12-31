ALTER PROCEDURE [dbo].[sp_smsdisconnoticedetails_suite]
	-- Add the parameters for the stored procedure here
	@BookId int,
	@ZoneId int,
	@RateId int,
	@BrgyId int,
	@Municipality int,
	@billdate varchar(7)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	
	declare @penaltytable table(CustId varchar(30),penaltyamount money)
	declare @custtable table(CustId varchar(30),id int identity(1,1))

	insert @custtable(CustId)
	select CustId from members where BookId = @BookId

	declare @ctr int
	set @ctr = 1;
	declare @CustId int
	declare @currpen money
	set @CustId = 0

	
	declare @penaltytable1 table(penaltyamount money)




	while(@ctr <= isnull((Select max(id) from @custtable),0))
	begin
		
		set @CustId = isnull((Select CustId from @custtable where id = @ctr),'')

		insert @penaltytable1
		exec sp_cumputeunsubmittedpenalty @CustId

		set @currpen = isnull((Select penaltyamount from @penaltytable1),0)

		insert @penaltytable
		values(@CustId,@currpen)

		delete from @penaltytable1

		set @ctr = @ctr + 1
	end


	select ccelnumber,a.CustId,a.CustNum,isnull(d.[Total Balance],0)+ (case when b.billstat = 1 then b.subtot1 else 0.00 end)
	+

	isnull(h.penaltyamount,0)
	,
	convert(varchar(6),cast(g.discdate as datetime),107) as discondate,a.ccelnumber 
	,':' + rtrim(ltrim(a.cbank_ref)) + right(replace(convert(varchar(20),convert(datetime,g.discdate),111),'/',''),4) as atmref
	,':' + convert(varchar(100),f.billnum),a.custname,'atmref=' + rtrim(ltrim(a.cbank_ref)) + right(replace(convert(varchar(20),convert(datetime,g.discdate),111),'/',''),4) + '&billnum=' + convert(varchar(100),f.billnum)
	FROM cust a
	INNER JOIN rhist e
	on a.CustId = e.CustId
	and e.billdate = @billdate
	and e.nbasic > 0
	LEFT JOIN Cbill b 
	on e.RhistId =b.RhistId
	LEFT JOIN vw_ledger d
	on a.CustId = d.CustId
	LEFT JOIN members f
	on a.CustId = f.CustId
	LEFT JOIN BillingSchedule g
	on f.BookId = g.BookId
	and g.billdate = @billdate
	LEFT JOIN @penaltytable h
	on a.CustId = h.CustId
	where (f.BookId = @BookId and len(ccelnumber)=11
	and isnull([total balance],0) > 0
	and convert(varchar(20),convert(datetime,e.duedate),111) < convert(varchar(20),getdate(),111)
	and a.CustId = e.CustId
	and e.billdate = @billdate
	and e.nbasic > 0)

	OR  (a.ZoneId = @ZoneId and len(ccelnumber)=11
	and isnull([total balance],0) > 0
	and convert(varchar(20),convert(datetime,e.duedate),111) < convert(varchar(20),getdate(),111)
	and a.CustId = e.CustId
	and e.billdate = @billdate
	and e.nbasic > 0)

	OR  (a.RateId = @RateId and len(ccelnumber)=11
	and isnull([total balance],0) > 0
	and convert(varchar(20),convert(datetime,e.duedate),111) < convert(varchar(20),getdate(),111)
	and a.CustId = e.CustId
	and e.billdate = @billdate
	and e.nbasic > 0)

	OR  (CONVERT(VARCHAR,brgyid) = @BrgyId and len(ccelnumber)=11
	and isnull([total balance],0) > 0
	and convert(varchar(20),convert(datetime,e.duedate),111) < convert(varchar(20),getdate(),111)
	and a.CustId = e.CustId
	and e.billdate = @billdate
	and e.nbasic > 0)

	OR  (CONVERT(VARCHAR,municipality_id) = @Municipality and len(ccelnumber)=11
	and isnull([total balance],0) > 0
	and convert(varchar(20),convert(datetime,e.duedate),111) < convert(varchar(20),getdate(),111)
	and a.CustId = e.CustId
	and e.billdate = @billdate
	and e.nbasic > 0)

END
