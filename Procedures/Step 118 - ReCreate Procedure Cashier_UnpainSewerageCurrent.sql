ALTER PROCEDURE [dbo].[Cashier_UnpaidSewerageCurrent]
	
	@CustId int,
	@mode varchar(1),
	@pymntnum	int = null
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	
	--if(@mode = 0)
	begin
	declare @septfee money
	declare @maxbilldate varchar(7)
	declare @septagebal money
	declare @currbill money
	set @maxbilldate = (Select max(billdate) from rhist where cons1 >= 0 and CustId = @CustId)
	set @septfee = isnull((Select isnull(sept_fee,0) from rhist where CustId = @CustId and BillDate = @maxbilldate
	and CustId not in(Select CustId from cbill where CustId = @CustId and billdate = @maxbilldate and BillStat <> 1)),0)
	set @septagebal = isnull((Select isnull(Sewerage,0) from vw_ledger where CustId = @CustId),0)
	set @septagebal = @septagebal + @septfee
	set @currbill = isnull((Select subtot3 from cbill where billdate = @maxbilldate and CustId = @CustId and BillStat <> 1),0)

	if(@septagebal > 0 and @septfee > 0 and @septagebal >= @septfee)
	begin
		set @currbill = @septfee
	end
	else if(@septagebal > 0 and @septfee > 0 and @septagebal < @septfee)
	begin
		set @currbill = @septagebal
	end
	else if(@septagebal > 0 and @septagebal >= @currbill)
	begin
		set @currbill = @currbill
	end
	else if(@septagebal > 0 and @septagebal < @currbill)
	begin
		set @currbill = @septagebal
	end
	

	    
	    Select a.billdate,'' billnum,	
	    @currbill as TotalBill, 
	   'Sewerage Current' as BillType,a.duedate,'Subtot12' Subtot,'WATER' PType
		from rhist a where a.CustId=@CustId
		and a.billdate in (select max(billdate) from rhist where CustId = @CustId)

	end
	
END
