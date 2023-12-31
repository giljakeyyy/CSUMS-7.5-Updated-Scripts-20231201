ALTER PROCEDURE [dbo].[sp_CSSCheckBooks]
	-- Add the parameters for the stored procedure here
	@billdate varchar(7)
AS
BEGIN




	select convert(bit,0) as x,a.BookId as [ID],a.bookno as [Book #]
	,convert(Date,a.bcompdt) as [Compute Date],[For Billing] = isnull(b.CTR,0)
	,Billed = isnull(c.CTR,0)
	, [For Approval] = isnull(b.ForApproval,0)
	,[Approved] = isnull(b.Approved,0)
	from books a
	left join
	vw_CheckBillForApproval b
	on a.BookId = b.BookId
	and b.billdate = @billdate
	left join [vw_CheckBilledByBookByBilldate] c
	on a.BookId = c.BookId
	and c.BillDate = @BillDate
	order by a.bookno

END
