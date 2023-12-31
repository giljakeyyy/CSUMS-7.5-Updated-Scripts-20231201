ALTER PROCEDURE [dbo].[sp_CSSBC_PaymentListPosted]
	-- Add the parameters for the stored procedure here
	@books varchar(Max),	
	@Custnum varchar(20),
	@DateFrom varchar(10),
	@DateTo varchar(10)	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	IF(@Custnum <> '')
	BEGIN
		Select a.PymntNum as [Payment #],b.CustId as [ID],
		b.CustNum as [Accnt #],b.CustName as [Name],a.PayAmnt as [Total Payment],
		a.Subtot1 as [Basic Charge],a.subtot2 as [Arrears],a.subtot3 as Advance,
		a.subtot4 as [Reconnection],a.subtot5 as [Deposit],a.subtot6 as Penalty,
		a.subtot7 as [Meter Maintenance],a.subtot8 as Others,a.subtot9 as [OldArrears],
		a.subtot12 as [Septage]
		from Cpaym a 				
		INNER JOIN Cust b 
		on a.CustId = b.CustId
		where a.pymntstat <> 1
		and (b.CustNum like ''+@Custnum+'%')
		and a.PayDate BETWEEN @DateFrom AND @DateTo
		order by PymntNum
	END
	ELSE IF(@Custnum = '')
	BEGIN
		
		--Get BookNo and Insert to Temp Table
		set @books = @books + ','
		Declare @BooksTable as Table(BookId int)
		declare @ctr as int
		set @ctr = 1
		declare @Delimit as varchar(10)
		set @Delimit = ''
		WHILE(@ctr <= len(@books))
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
		Select e.PymntNum as [Payment #],d.CustId as [ID],
		d.CustNum as [Accnt #],d.CustName as [Name],e.PayAmnt as [Total Payment],
		e.Subtot1 as [Basic Charge],e.subtot2 as [Arrears],e.subtot3 as Advance,
		e.subtot4 as [Reconnection],e.subtot5 as [Deposit],e.subtot6 as Penalty,
		e.subtot7 as [Meter Maintenance],e.subtot8 as Others,e.subtot9 as [OldArrears],
		e.subtot12 as [Septage]
		from @BooksTable a
		INNER JOIN Books b
		on a.BookId = b.BookId
		INNER JOIN Members c
		on b.BookId = c.BookId
		INNER JOIN Cust d
		on c.CustId = d.CustId
		INNER JOIN Cpaym e
		on d.CustId = e.CustId
		where e.pymntstat <> 1
		and (d.CustNum like ''+@Custnum+'%')
		and e.PayDate BETWEEN @DateFrom AND @DateTo
		order by e.PymntNum
	END
END
