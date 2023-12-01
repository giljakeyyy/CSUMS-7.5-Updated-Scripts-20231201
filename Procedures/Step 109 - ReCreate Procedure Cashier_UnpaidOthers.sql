ALTER PROCEDURE [dbo].[Cashier_UnpaidOthers]
	@CustNum varchar(20),
	@mode varchar(1),
	@pymntnum int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	
	begin
		select 0 as TotalBill,
		'OTHERS' as BillType,
		'' duedate,
		'Subtot8' Subtot,
		'OTHERS' Ptype
	end
END
