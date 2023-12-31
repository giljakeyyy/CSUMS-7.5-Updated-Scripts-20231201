ALTER PROCEDURE [dbo].[Cashier_UnpaidMeterCharge]
    @CustId int,
    @mode varchar(1),
    @pymntnum int
AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON;

 

    begin
        declare @balance money
        --set @balance = (Select BalServ from cust where custnum = @custnum)
        set @balance = (Select isnull([SERVICE CHARGE],0) from vw_ledger where CustId = @CustId)

 

        declare @waterpn money
		set @waterpn = 0

 

        declare @currbill money
        set @currbill = (select subtot5 from cbill where CustId = @CustId and billstat = '1' and billdate = (select max(billdate) from cbill where CustId = @CustId))

 

        declare @stat varchar(2)
        set @stat = (select status from cust where CustId = @CustId)

 

        declare @maxbilldate varchar(10)
        declare @maxreaddate varchar(10)
        declare @month_diff int
        set @maxbilldate = (select max(billdate) from cbill where CustId = @CustId)
        set @maxreaddate = (select max(billdate) from rhist where CustId = @CustId)
        set @month_diff = abs(datediff(month,
                                convert(datetime, isnull(@maxbilldate, left(convert(varchar(20), getdate(), 111), 7)) + '/01'),
                                convert(datetime, isnull(@maxreaddate, left(convert(varchar(20), getdate(), 111), 7)) + '/01')))

 

        declare @totalpay money
        
		set @totalpay = (Select (isnull(subtot7, 0)) from cpaym where CustId = @CustId and pymntnum = @pymntnum)
        
        --to include payment of metercharge(penalty column in lingayen) after migration
        declare @currpay money
        set @currpay = (select sum(subtot7) from cpaym where CustId = @CustId and pymntstat=1 and left(paydate,7) = convert(varchar(7),getdate(),111))

 


        Select
          
		  CONVERT(DECIMAL(18,2),(@balance + isnull(@currbill,0) + CASE WHEN @stat = 1 THEN (@month_diff * 2) ELSE 0 END)- isnull(@currpay,0)) as TotalBill,
            'METER CHARGE' as BillType,
            '' duedate,
            'Subtot7' Subtot,
            'WATER' Ptype,
            isnull(@totalpay,0) TotalPay
    end
END