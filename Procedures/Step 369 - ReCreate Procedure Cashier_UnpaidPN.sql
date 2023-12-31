ALTER PROCEDURE [dbo].[Cashier_UnpaidPN]
	@CustId int,
	@mode varchar(1),
	@pymntnum int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	begin
		declare @totalpay money
		set @totalpay = (Select amount from pn2 where crefno = @pymntnum and ltrim(rtrim(crefno)) != 'CLOSE')

		DECLARE @Billdate VARCHAR(7)
		SET @Billdate =(SELECT CONVERT(VARCHAR(7),GETDATE(),111))

		EXEC [sp_pnmonthly] @CustId,@Billdate

		Select
			'PROMISSORY NOTE' as BillType,
			convert(varchar(10),dduedate,111) duedate,

			case
				when end_bal > pn_remit
					then pn_remit
					else end_bal
				end
			as TotalBill,
			'PN' Subtot,
			cpnno PType,
			isnull(@totalpay,0) TotalPay
		from pn1 
		INNER JOIN CUST
		on pn1.CustId = Cust.CustId
		and Cust.CustId = @CustId
		where Cust.CustId = @CustId and end_bal > 0
   end
END
