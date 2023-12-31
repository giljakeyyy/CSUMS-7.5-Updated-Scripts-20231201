ALTER PROCEDURE [dbo].[Cashier_UnpaidArrears]
	@CustId int,
	@mode varchar(1),
	@pymntnum int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	
	begin
		declare @maxibilldate varchar(7)

		DECLARE @rdate VARCHAR(10)
		DECLARE @ReadDate DATETIME
		declare @ddate varchar(23)
		declare @nbasic money
		DECLARE @custnum1 varchar(20)

		set @custnum1 = (Select custnum from Cust where CustId = @CustId)

		set @maxibilldate =
			isnull
			(
				(Select max(billdate) from rhist where CustId = @CustId), ''
			)

		SET @rdate = (SELECT [Rdate] FROM [Rhist] WHERE CustId = @CustId and [BillDate] = @maxibilldate)
		SET @ReadDate = ISNULL(TRY_CAST(@rdate AS DATETIME), ISNULL(TRY_CAST(@maxibilldate + '/01' AS DATETIME), CONVERT(DATETIME, LEFT(CONVERT(VARCHAR(10), GETDATE(), 111), 7) + '/01')))
		SET @ddate =  (select convert(varchar(100),dateadd(month,+2, convert(datetime, max(Rdate))),111) 
					   from rhist where CustId = @CustId)

		declare @balance money
		--set @balance = (Select balance from cust where custnum = @custnum)
		set @balance = (Select isnull([Water Balance],0) from vw_ledger where CustId = @CustId)

		declare @waterpn money
		--set @waterpn = (select nwatfee watpn from pn1 where custnum = @custnum and end_bal > 0)
		--set @waterpn = (select isnull(end_watfee,0) watpn from pn1 a where custnum = @custnum and end_bal > 0)
		set @waterpn = isnull((select isnull(end_watfee,0) watpn from pn1 a where CustId = @CustId and end_bal > 0), 0)

		declare @currbill money
		--set @currbill = (select subtot1 - SubTot2 from cbill where custnum = @custnum and billstat <> '1' and billdate = (select max(billdate) from rhist where custnum = @custnum))
		--- orig set @currbill = (select subtot1 - SubTot2 from cbill where custnum = @custnum and billstat <> '1' and billdate = convert(varchar(7), getdate(), 111))
		--set @currbill = (select subtot1 - SubTot2 from cbill where custnum = @custnum and billstat <> '1' and billdate = @maxibilldate)
		set @currbill = ISNULL((select subtot1 - SubTot2 from cbill where CustId = @CustId and billstat <> '1' and billdate = (select max(billdate) from rhist where CustId = @CustId)),0)
						- ( select ISNULL(sum(isnull(subtot1,0)) + sum(isnull(tax1,0)),0) from Cpaym where CustId = @CustId and PayDate between @rdate and @ddate and PymntStat <>1)
		set @currbill = (CASE WHEN @currbill < 0 THEN 0 ELSE @currbill END )
		--declare @currpn money

		declare @totalpay money 
		set @totalpay = (select isnull(subtot2,0) from cpaym a where a.pymntnum = @pymntnum)
	
		declare @currpay money
		set @currpay = (select sum(subtot2) + sum(tax2) from cpaym where CustId = @CustId and pymntstat=1)
		--and left(paydate,7) = convert(varchar(7),getdate(),111)

		if((isnull(@currbill,0)) > isnull(@balance ,0) - isnull(@waterpn,0))	
		begin
			set @currbill = (isnull(@currbill,0) - (isnull(@currbill,0) - (isnull(@balance,0) - isnull(@waterpn,0)))) 
		end
		ELSE

		IF DATEDIFF(DAY, @ReadDate, GETDATE()) > CONVERT(INT, RIGHT(CONVERT(VARCHAR(10), EOMONTH(@ReadDate)), 2))
		BEGIN
			SET @currbill = 0
		END

		Select
			CONVERT(DECIMAL(18,2), ((@balance - (isnull(@currbill,0) + isnull(@waterpn,0))) - isnull(@currpay,0)) + isnull(@totalpay,0)) as TotalBill,
			'ARREARS' as BillType,
			'' duedate,
			'Subtot2' Subtot,
			'WATER' Ptype,
			isnull(@totalpay,0) TotalPay
	end
END
