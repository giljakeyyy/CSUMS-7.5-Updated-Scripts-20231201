ALTER PROCEDURE [dbo].[Cashier_UnpaidWaterDelivery]
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
                       where CustId = @CustId and ledger_type = 'WATER DELIVERY')

        Select
            isnull(@balance, 0) as TotalBill,
            'Water Delivery' as BillType,
            '' duedate,
            'Subtot8' Subtot,
            'WATER' Ptype,
            0 TotalPay
    end
END
