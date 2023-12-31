ALTER PROCEDURE [dbo].[reOrder]
	-- Add the parameters for the stored procedure here
	@inc int,
	@BookId int,
	@start int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    		select b.CustId,d.bookno,b.custnum,b.custname,((ROW_NUMBER()  over (order by c.seqno)) * @inc) + (@start - @inc)   as SeqNo   
			from cust b 
			INNER JOIN members c 
			on b.CustId = c.CustId 
			INNER JOIN Books d 
			on c.BookId = d.BookId 
			where d.BookId= @BookId order by c.seqno
END
