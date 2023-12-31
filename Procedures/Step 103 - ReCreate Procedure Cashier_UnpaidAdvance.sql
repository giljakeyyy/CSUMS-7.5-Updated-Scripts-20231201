ALTER PROCEDURE [dbo].[Cashier_UnpaidAdvance]
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

		set @ifnull = 200
		--ifnull --> average
		set @average = @ifnull

		set @average = isnull((Select isnull(minbill,@ifnull)
		from bill a
		inner join cust b
		on a.rateid = b.rateid
		and a.ZoneId = b.ZoneId
		where b.CustId = @CustId),@ifnull)

		--ave --> ifnull
		set @ifnull = @average

		set @average = isnull(
		(
			--Select avg(isnull(b.subtot1,0)) as [Average Bill] from(
			Select avg(isnull(b.subtot1,0) * 2) as [Average Bill] from(
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

		set @average = case when @average <=0 then 200 else @average end

		select CONVERT(DECIMAL(18, 2), @average) as TotalBill,
		'WATER ADVANCE' as BillType,
		'' duedate,
		'Subtot3' Subtot,
		'ADVANCED' Ptype
	end
END
