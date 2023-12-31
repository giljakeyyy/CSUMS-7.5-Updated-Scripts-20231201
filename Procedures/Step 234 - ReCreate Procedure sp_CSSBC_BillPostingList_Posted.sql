ALTER PROCEDURE [dbo].[sp_CSSBC_BillPostingList_Posted]
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

	Select d.BillNum,c.CustId,e.custnum,e.custname,d.DueDate,d.Duedate2,
	Convert(numeric(18,2),d.BillAmnt) as BillAmnt,
	Convert(numeric(18,2),d.subtot1) as subtot1,
	Convert(numeric(18,2),d.subtot2) as subtot2,
	Convert(numeric(18,2),d.subtot3) as subtot3,
	Convert(numeric(18,2),d.subtot4) as subtot4,
	Convert(numeric(18,2),d.subtot5) as subtot5,	 
	d.DueDate,d.Duedate2,c.BillPeriod,
	'BillError'= case when subtot1 is null then '1'    
	when subtot3 is null then '1'
	when subtot4 is null then '1'
	when billamnt is null then '1'
	else '0' end,   d.BillDtls ,
	'BillStat' = case when d.BillStat= 1 then 'NEW' when d.BillStat= 2 then 'Posted'
	when d.BillStat= 3 then 'PAID' else  'Error' end
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
	where d.BillDate = @BillDate and d.BillStat <> 1		      			
END



