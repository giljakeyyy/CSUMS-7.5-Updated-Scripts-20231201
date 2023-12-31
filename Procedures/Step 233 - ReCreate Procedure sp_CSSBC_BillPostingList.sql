ALTER PROCEDURE [dbo].[sp_CSSBC_BillPostingList]
	-- Add the parameters for the stored procedure here
	@books varchar(MAX),
	@Billdate varchar(7)
AS
BEGIN
   SET NOCOUNT ON;
   
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

	Select convert(bit,0) as x,d.BillNum,c.CustId,e.CustNum,e.custname,d.DueDate,d.Duedate2,d.BillAmnt,d.Subtot1,d.Subtot2,d.Subtot3,d.Subtot4,d.Subtot5,
	d.DueDate,d.Duedate2,c.BillPeriod,
	'BillError'= case when subtot1 is null then '1'    
	when subtot3 is null then '1'
	when subtot4 is null then '1'
	when billamnt is null then '1'
	else '0' end,d.BillDtls
	FROM 
	@BooksTable a
	INNER JOIN Books b
	on a.BookId = b.BookId
	INNER JOIN Rhist c
	on b.BookId = c.BookId
	INNER JOIN CBill d
	on c.RhistId = d.RhistId
	INNER JOIN Cust e
	on c.CustId = e.CustId
	where d.BillDate = @BillDate and d.BillStat = 1

END






