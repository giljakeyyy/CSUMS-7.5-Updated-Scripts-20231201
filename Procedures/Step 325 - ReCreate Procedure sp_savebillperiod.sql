ALTER PROCEDURE [dbo].[sp_savebillperiod]
	-- Add the parameters for the stored procedure here
	@BookId int,
	@billdate varchar(7),
	@fromdate varchar(20),
	@todate varchar(20),
	@duedate varchar(20),
	@discondate varchar(20),
	@reader varchar(200),
	@pca money
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	IF(EXISTS(Select BillingScheduleId from BillingSchedule where BookId = @BookId and billdate = @billdate))
	BEGIN

		update BillingSchedule
		set FromDate = @fromdate,duedate = @duedate
		,DiscDate = @discondate,ReaderID = @reader,ToDate = @todate
		,pca = @pca
		where BillDate = @billdate and BookId = @BookId

		INSERT [BillingSchedule_Logs] 
		(
			[Type], [BookNo], [BillDate], [DueDate], [FromDate], [ToDate], [DiscDate], [ReaderID], [PCA], [LogDate]
		)
		VALUES 
		(
			'U', (Select BookNo from Books where BookId = @BookId), 
			@billdate, @duedate, @fromdate, @todate, @discondate, 
			@reader, @pca, GETDATE()
		)

		update a
		set pread1 = b.read1,AveCon1 = ISNULL(f.average_cons,0)
		FROM Members a
		INNER JOIN rhist b
		on a.CustId = b.CustId
		and ISNULL(Read1,'') <> '' and len(read1)>0
		and b.BillDate = left(convert(varchar(100),dateadd(month,-1,convert(datetime,@billdate + '/01')),111),7)
		and a.BookId = @BookId
		LEFT JOIN
		(
			Select rhist_1.CustId,convert(numeric(18,0),AVG(cons1)) as average_cons
			FROM Rhist rhist_1
			INNER JOIN
			(
				Select CustId,billdate,row_number() over(partition by CustId order by billdate desc) as ctr from
				rhist where cons1 >= 0 and billdate < @billdate
			)rhist_2
			on rhist_1.CustId = rhist_2.CustId
			and rhist_1.billdate = rhist_2.billdate
			and rhist_2.ctr <= 3
			where cons1 >= 0
			group by rhist_1.CustId
		)f
		on a.CustId = f.CustId
		where a.CustId = b.CustId
		and ISNULL(Read1,'') <> '' and len(read1)>0
		and b.BillDate = left(convert(varchar(100),dateadd(month,-1,convert(datetime,@billdate + '/01')),111),7)
		and a.BookId = @BookId
		
	END
	ELSE
	BEGIN


		insert BillingSchedule
		(
			BookId,BillDate,DueDate,FromDate,ToDate,DiscDate,ReaderID,PCA
		)
		values
		(
			@BookId,@billdate,@duedate,@fromdate,@todate,@discondate,@reader,@pca
		)

		INSERT [BillingSchedule_Logs] 
		(
			[Type], [BookNo], [BillDate], [DueDate], [FromDate], [ToDate], [DiscDate], [ReaderID], [PCA], [LogDate]
		)
		VALUES 
		(
			'I', (Select BookNo from Books where BookId = @BookId), @billdate, 
			@duedate, @fromdate, @todate, @discondate, @reader, @pca, GETDATE()
		)

		update a
		set pread1 = b.read1,AveCon1 = ISNULL(f.average_cons,0)
		from Members a
		INNER JOIN Rhist b
		on a.CustId = b.CustId
		and ISNULL(Read1,'') <> '' and len(read1)>0
		and b.BillDate = left(convert(varchar(100),dateadd(month,-1,convert(datetime,@billdate + '/01')),111),7)
		and a.BookId = @BookId
		LEFT JOIN
		(
			Select rhist_1.CustId,convert(numeric(18,0),AVG(cons1)) as average_cons
			from rhist rhist_1
			INNER JOIN
			(
				Select CustId,billdate,row_number() over(partition by CustId order by billdate desc) as ctr from
				rhist where cons1 >= 0 and billdate < @billdate
			)rhist_2
			on rhist_1.CustId = rhist_2.CustId
			and rhist_1.billdate = rhist_2.billdate
			and rhist_2.ctr <= 3
			where cons1 >= 0
			group by rhist_1.CustId
		)f
		on a.CustId = f.CustId
		where a.CustId = b.CustId
		and ISNULL(Read1,'') <> '' and len(read1)>0
		and b.BillDate = left(convert(varchar(100),dateadd(month,-1,convert(datetime,@billdate + '/01')),111),7)
		and a.BookId = @BookId
		
	end

	--get all accounts with PN
	Select a.CustId,ROW_NUMBER() over(order by a.CustId) as ctr 
	INTO #test	
	from Members a
	INNER JOIN Cust b
	on a.CustId = b.CustId
	inner join pn1 c
	on b.CustId = c.CustId
	and c.end_bal > 0
	where a.BookId = @BookId

	declare @x as int
	declare @max as int
	set @x = 1
	set @max = isnull((Select max(ctr) from #test),0)
	while(@x <= @max)
	BEGIN
		declare @CustId int
		set @CustId = isnull((Select CustId from #test where ctr = @x),0)
		exec sp_pnmonthly @CustId ,@billdate
		set @x = @x + 1
	END

END
