ALTER PROCEDURE [dbo].[sp_CSSCustAppPayment]
	-- Add the parameters for the stored procedure here
	@paydate varchar(12),
	@paydate1 varchar(12),
	@ptype int,
	@feesid int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	Select a.Applnum,'Name' = case when len(c.ApplName)>0 then ApplName else CustName end
	,sum(Amount) as Amount,
	a.Ornum,Paydate from Application_OtherFees a 
    left join Applicationfee_type b on a.Appfeetype=b.Appfeetype
	left join [Application] c on a.Applnum=c.ApplNum
	left join cust d on a.Applnum=d.CustNum	
	where len(a.Ornum)>0
	--Add Date as Filter
	and (len(@paydate) <= 0 or Convert(datetime,a.paydate) between @paydate and @paydate1)
	--Add Ptype as Filter
	and (@ptype <= 0 or ptype= @ptype)
	--Add FeesPaydId as Filter
	and (@feesid <= 0 or feespayid = @feesid)
	group by a.Applnum,case when len(c.ApplName)>0 then ApplName else CustName end,a.Ornum,Paydate

END