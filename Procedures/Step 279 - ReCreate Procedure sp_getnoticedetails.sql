ALTER PROCEDURE [dbo].[sp_getnoticedetails]
	-- Add the parameters for the stored procedure here
	@CustId int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	--Select a.custname,a.custnum,'' as oldcustnum 
	Select a.custname,a.custnum,isnull(a.oldcustnum,'') as oldcustnum 
	,a.bilstadd,b.MeterNo1,b.pread1,'Water Arrears' as label1
	,'Penalty Balance' as label2,'Septage Balance' as label3
	,'OldArrears' as label4,'Others' as label5
	,'WMF' as label6,'' as label7
	,isnull(c.[Water Balance],0) as amount1
	,isnull(c.[Penalty Balance],0) as amount2,isnull(c.Sewerage,0) as amount3
	,isnull(c.[Old Arrears],0) as amount4
	,0 as amount5
	,0 as amount6
	,0 as amount7
	,total_amt = isnull(c.[Total Balance],0)
	from cust a
	inner join members b
	on a.CustId = b.CustId
	left join vw_ledger c
	on a.CustId = c.CustId
	where a.CustId = @CustId
END
