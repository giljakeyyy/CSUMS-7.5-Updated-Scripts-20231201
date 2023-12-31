ALTER PROCEDURE [dbo].[Cashier_UnpaidSewerageAdvance]
	
	@CustId int,
	@mode varchar(1),
	@pymntnum int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	--if(@mode = 0)
	begin
	
	
	declare @rate as varchar(10)
	declare @zoneno as varchar(10)
	declare @average as money
	declare @ifnull as money
	set @ifnull = 20
	--ifnull --> average 
	set @average = @ifnull

	set @ifnull = @average

	set @average = isnull(
	(
		Select avg(isnull(b.SubTot3,0)) as [Average Bill] from(
		Select row_number() over(order by billdate desc) as ctr,billdate,CustId from cbill
		where CustId = @CustId
		)a
		inner join cbill b
		on a.CustId = b.CustId
		and a.billdate = b.billdate
		and a.ctr <= 3
		and b.CustId = @CustId
	)
	,@ifnull)
	
			
	select 	@average as TotalBill,

	'SEWERAGE ADVANCE' as BillType,'' duedate,'Subtot14' Subtot,'ADVANCED' Ptype

	end

	
	
	
END
