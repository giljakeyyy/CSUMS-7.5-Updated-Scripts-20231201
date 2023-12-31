ALTER PROCEDURE [dbo].[Cashier_UnpaidWaterDeliveryCharge]
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
        
		set @balance = (select sum(isnull(debit, 0)) - sum(isnull(credit, 0)) from cust_ledger
                       where CustId = @CustId and ledger_type = 'DELIVERY CHARGE')
                      

        Select
            isnull(@balance, 0) as TotalBill,
            'Delivery Charge' as BillType,
            '' duedate,
            'Subtot4' Subtot,
            'WATER' Ptype,
            0 TotalPay
    end
END
