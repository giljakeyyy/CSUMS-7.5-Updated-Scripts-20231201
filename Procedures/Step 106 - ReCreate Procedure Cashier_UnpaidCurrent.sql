ALTER PROCEDURE [dbo].[Cashier_UnpaidCurrent]
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
        
		declare @rdate varchar(23)
		declare @ddate varchar(23)

		set @rdate =  (select  max(Rdate) from rhist where CustId = @CustId)
		SET @ddate =  (select convert(varchar(100),dateadd(month,+2, convert(datetime, max(Rdate))),111) 
					   from rhist where CustId = @CustId)

        set @maxibilldate =
            isnull
            (
                (Select max(billdate) from rhist where CustId = @CustId), ''
            )
        
        set @nbasic =
            isnull
            (
                (
                    Select isnull(nbasic, 0) from rhist 
					left join Cbill
					on Rhist.RhistId = CBill.RhistId
					and CBill.BillStat <> 1
					where rhist.billdate = @maxibilldate and Rhist.CustId = @CustId
					and CBill.RhistId is null
                ), 0
            )
        


        declare @balance money
        
		set @balance = (Select isnull([Water Balance],0) from vw_ledger where CustId = @CustId) + @nbasic


        declare @waterpn money
        
		set @waterpn = isnull((select isnull(end_watfee,0) watpn from pn1 
		INNER JOIN CUST
		on PN1.CustId = Cust.CustId
		where PN1.CustId = @CustId and end_bal > 0), 0)
        set @balance = @balance - isnull(@waterpn,0)


        declare @currbill money
        
		set @currbill = ISNULL((select subtot1 - subtot2 from cbill where CustId = @CustId and billstat <> '1' and billdate = @maxibilldate)
						- ( select ISNULL(sum(isnull(subtot1,0)) + sum(isnull(tax1,0)),0) from Cpaym where CustId = @CustId and PayDate between @rdate and @ddate and PymntStat <> 1),0)

        declare @totalpay money
        set @totalpay = (Select subtot1 from cpaym  where CustId = @CustId and pymntnum = @pymntnum)


        declare @currpay money
        set @currpay = (select sum(subtot1) + sum(tax1) from cpaym where CustId = @CustId and pymntstat = 1 and left(paydate, 7) = convert(varchar(7), getdate(), 111))


        Select
            a.billdate,
            '' billnum,
           convert(decimal(18,2), case

                when @nbasic > 0 and @nbasic > @balance
                then @balance - isnull(@currpay,0)
                when @nbasic > 0 and @nbasic <= @balance
                then @nbasic - isnull(@currpay,0)
                when @currbill > 0 and @currbill > @balance
                then @balance - isnull(@currpay,0)
                when @currbill > 0 and @currbill <= @balance
                then @currbill - isnull(@currpay,0)
                else 0
                end )as TotalBill,
            'CURRENT' as BillType,
            a.duedate,
            'Subtot1' Subtot,
            'WATER' PType
        from rhist a where a.CustId = @CustId
        and a.billdate = @maxibilldate
    end
END
 









