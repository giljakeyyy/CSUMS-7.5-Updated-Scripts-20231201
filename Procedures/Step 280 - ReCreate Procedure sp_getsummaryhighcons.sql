ALTER PROCEDURE [dbo].[sp_getsummaryhighcons]
	-- Add the parameters for the stored procedure here
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	declare @billdate varchar(7)

	set @billdate = (Select max(billdate) from Rhist)

	Select Books.BookNo as [Book] 
	,[Percent] = 
	case when isnull(a.[Reading],0) = 0 or isnull(b.High,0) = 0
	then 0
	else
	convert(numeric(18,2),(convert(numeric(18,2),isnull(b.High,0)) / convert(numeric(18,2),isnull(a.Reading,0))) * 100)
	end
	FROM Books
	INNER JOIN
	(
		Select BookId,count(CustId) as [Reading]
		from rhist
		where billdate = @billdate
		group by BookId
	) a
	on Books.BookId = a.BookId
	LEFT JOIN
	(
		Select b.BookId,count(b.CustId) as [High]
		from rhist b
		inner join Members d
		on b.CustId = d.CustId
		where b.billdate = @billdate
		and isnull(b.Cons1,0) >= (isnull(d.AveCon1,0) * 2)
		and isnull(d.AveCon1,0) > 0
		group by b.BookId
	)b
	on Books.BookId = b.BookId

END
