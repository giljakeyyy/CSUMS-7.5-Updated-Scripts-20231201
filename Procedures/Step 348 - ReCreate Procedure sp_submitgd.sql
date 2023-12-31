ALTER PROCEDURE [dbo].[sp_submitgd]
	-- Add the parameters for the stored procedure here
	@CustId int
	,@water as money
	,@penalty as money
	,@oldarrears as money
	,@gd as money
	,@bill1 as money
	,@bill2 as money
	,@bill3 as money
	,@bill4 as money
	,@bill5 as money
	,@bill6 as money
	,@ave as money
	,@autocomp as money
	,@submittedcomp as money
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	delete from [GDForentry] where CustId = @CustId
	insert [GDForentry] 
	(
		[CustId],[Water],[Penalty],[OldArrears],
		[GD],[Bill1],[Bill2],[Bill3],[Bill4],
		[Bill5],[Bill6],[Ave],[AutoComp],
		[SubmittedComp],[DateSubmitted]
	)
	values
	(
		@CustId,@water,@penalty,@oldarrears
		,@gd,@bill1,@bill2,@bill3,@bill4,@bill5,@bill6,@ave,@autocomp
		,@submittedcomp,convert(varchar(100),getdate(),111)
	)
END
