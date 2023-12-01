CREATE PROCEDURE sp_CheckCreatedBills 
	-- Add the parameters for the stored procedure here
	@books varchar(MAX),
	@BillDate varchar(7)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	
	--Get BookNo and Insert to Temp Table
	set @books = @books + ','
	Declare @BooksTable as Table(BookId int)
	declare @ctr as int
	set @ctr = 1
	declare @Delimit as varchar(10)
	set @Delimit = ''
	while(@ctr <= len(@books))
	BEGIN
		if(SUBSTRING(@books,@ctr,1) <> ',')
		BEGIN
			set @Delimit = @Delimit + SUBSTRING(@books,@ctr,1)
		END
		else
		BEGIN
			Insert @BooksTable
			Values(@Delimit)

			set @Delimit = ''
		END
		set @ctr = @ctr + 1
	END

	Select B.BookNo,e.custnum as [Acct #],c.cons1 [Consumption],c.nbasic [Basic Charge],
	d.CreatedDate as [Date Created]
	FROM 
	@BooksTable a
	Inner Join Books b
	on a.BookId = b.BookId
	INNER JOIN Rhist c
	on b.BookId = c.BookId
	and c.BillDate = @BillDate
	INNER JOIN Cbill d
	on c.RhistId = d.RhistId
	INNER JOIN Cust e
	on c.CustId = e.CustId
END
GO
