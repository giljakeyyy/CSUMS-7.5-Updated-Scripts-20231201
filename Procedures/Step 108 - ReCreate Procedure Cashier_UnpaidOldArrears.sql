ALTER PROCEDURE [dbo].[Cashier_UnpaidOldArrears]
	@CustId int,
	@mode varchar(1),
	@pymntnum int = null
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	begin
		declare @maxibilldate varchar(7)
		declare @nbasic money

		DECLARE @BookId int
		DECLARE @sharing DECIMAL(18, 2)

		DECLARE @HasBill INT

		set @maxibilldate =
			isnull
			(
				(Select max(billdate) from rhist where CustId = @CustId), ''
			)

		Select
			@nbasic = isnull(nbasic, 0),
			@BookId = [BookId]
		from rhist where billdate = @maxibilldate and CustId = @CustId

		set @nbasic = isnull(@nbasic, 0)

		SET @sharing = (SELECT [sharing] FROM [Books] WHERE [BookId] = @BookId and [sharedmonth] = @maxibilldate)
		SET @sharing = ISNULL(@sharing, 1)

		SET @HasBill = (SELECT COUNT(1) FROM [Cbill] WHERE CustId = @CustId AND [BillDate] = '2020/12' AND [BillStat] != '1')

		declare @totalpay money
		set @totalpay = (Select isnull(subtot9,0) from cpaym a where a.CustId = @CustId and pymntnum = @pymntnum)

		declare @currpay money
		set @currpay = (select sum(subtot9) from cpaym where CustId = @CustId and pymntstat = 1 and left(paydate,7) = convert(varchar(7),getdate(),111))

		Select
			'OLD ARREARS' as BillType,
			convert (decimal (18,2),((isnull(c.[Old Arrears],0)) - isnull(nprocfee,0)) - isnull(@currpay,0)) + isnull(@totalpay,0)
				+ case when @HasBill != 1 then (@nbasic * (1 - @sharing)) else 0 end
			as TotalBill,
			'' duedate,
			'Subtot9' Subtot,
			'WATER' PType,
			isnull(@totalpay,0) TotalPay
		from cust a left join (select CustId, end_procfee nprocfee from pn1 where end_bal > 0) 
		b on a.CustId = b.CustId  
		left join vw_ledger c
		on a.CustId = c.CustId
		where a.CustId=@CustId
	end
END


