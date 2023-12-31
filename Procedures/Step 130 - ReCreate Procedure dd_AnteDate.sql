ALTER PROCEDURE [dbo].[dd_AnteDate]
	-- Add the parameters for the stored procedure here
	@colldate varchar(7),
	@newdate varchar(10),
	@action varchar(1)
	 
	
AS
BEGIN

	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	----DISPLAY
	--	if(@action = 'S')
	--	begin
	--	select pymntnum,a.custnum,ornum,paydate,
	--	case when pymntstat ='1' then 'Unposted' else 'Posted' end as [Status],
	--	b.billdate [Reference Bill Month],
	--	b.subtot1 [Basic Charge Bill],
	--	a.subtot1 [Basic Charge Payment]
	--	,subtot2 - isnull(x.amount,0) [Arrears],subtot3 [Advanced],
	--	isnull(x.amount,0) PN,
	--	[New Basic] = 
	--	(case when a.subtot2 - isnull(x.amount,0) > b.subtot1 then 
	--	b.subtot1
	--	else
	--	a.subtot2 - isnull(x.amount,0)
	--	end),
	--	[New Arrears] =
	--	(case when a.subtot2 - isnull(x.amount,0) >b.subtot1 then
	--	(a.subtot2 - x.amount) - b.subtot1 
	--	else 0 --To Exclude PN on display only  isnull(x.amount,0) (to include)
	--	end),
	--	[New Advanced] = a.subtot3 + a.subtot1,
	--	isnull(x.amount,0) [New PN]
	--	 from cpaym
	--	 a inner join (select subtot1,custnum,billdate from cbill where billdate= convert(varchar(7),dateadd(month,-1,convert(datetime,@colldate + '/01')),111)) b --reference billdate
	--	 on a.custnum=b.custnum
	--	 left join (select y.custnum,x.* from pn2 x left join pn1 y on x.cpnno=y.cpnno where x.cpnno = y.cpnno) 
	--	 x on (a.PymntNum = x.crefno) and a.custnum = b.custnum
		 
	--	  where left(paydate,7)=@colldate
	--	 and right(paydate,2) <4 and pymntstat='1'
	--	 end



	----UPDATE
	--if(left(convert(varchar(100),dateadd(month,-1,convert(datetime,@colldate + '/01')),111),7) = left(@newdate,7))
	--begin
	--	if(@action='U')
	--	begin
		
	--	insert payment_logger
	--	Select a.custnum,a.pymntnum,a.PayDate,a.subtot1,a.subtot2,a.subtot3,GETDATE()
	--	from cpaym
	--	a left join (select subtot1,custnum,billdate from cbill where billdate= convert(varchar(7),dateadd(month,-1,convert(datetime,@colldate + '/01')),111)) b --reference billdate
	--	on a.custnum=b.custnum 
	--	left join (select y.custnum,x.* from pn2 x left join pn1 y on x.cpnno=y.cpnno where x.cpnno = y.cpnno) 
	--	x on (a.pymntnum = x.crefno) and a.custnum = b.custnum
	--	where left(paydate,7)=@colldate
	--	 and right(paydate,2)<4 and pymntstat='1'

	--	update
	--	a set
	--	a.pymntdtl = '[' + a.paydate + ']',
	--	a.paydate = @newdate,
	--	a.Subtot3 = a.Subtot3 + a.Subtot1,
	--	a.Subtot1 = case

	--	when isnull(x.amount,0) = 0
	--	and a.Subtot2 <= isnull(b.SubTot1,0)
	--	then a.subtot2

	--	when isnull(x.amount,0) = 0
	--	and a.Subtot2 > isnull(b.SubTot1,0)
	--	then isnull(b.SubTot1,0)
		
	--	when isnull(x.amount,0) <> 0
	--	and a.Subtot2 <= isnull(x.amount,0)
	--	then 0

	--	when isnull(x.amount,0) <> 0
	--	and a.Subtot2 > isnull(x.amount,0)
	--	and a.Subtot2 - x.amount <= isnull(b.SubTot1,0)
	--	then a.Subtot2 - x.amount

	--	when isnull(x.amount,0) <> 0
	--	and a.Subtot2 > isnull(x.amount,0)
	--	and a.Subtot2 - x.amount > isnull(b.SubTot1,0)
	--	then isnull(b.SubTot1,0)

	--	else 0
	--	end,
	--	a.Subtot2 = case

	--	when isnull(x.amount,0) = 0
	--	and a.Subtot2 <= isnull(b.SubTot1,0)
	--	then 0

	--	when isnull(x.amount,0) = 0
	--	and a.Subtot2 > isnull(b.SubTot1,0)
	--	then a.Subtot2 - isnull(b.SubTot1,0)
		
	--	when isnull(x.amount,0) <> 0
	--	and a.Subtot2 <= isnull(x.amount,0)
	--	then a.Subtot2

	--	when isnull(x.amount,0) <> 0
	--	and a.Subtot2 > isnull(x.amount,0)
	--	and a.Subtot2 - x.amount <= isnull(b.SubTot1,0)
	--	then x.amount

	--	when isnull(x.amount,0) <> 0
	--	and a.Subtot2 > isnull(x.amount,0)
	--	and a.Subtot2 - x.amount > isnull(b.SubTot1,0)
	--	then a.Subtot2 - x.amount

	--	else 0
	--	end
	--	from cpaym
	--	a left join (select subtot1,custnum,billdate from cbill where billdate= convert(varchar(7),dateadd(month,-1,convert(datetime,@colldate + '/01')),111)) b --reference billdate
	--	on a.custnum=b.custnum 
	--	left join (select y.custnum,x.* from pn2 x left join pn1 y on x.cpnno=y.cpnno where x.cpnno = y.cpnno) 
	--	x on (a.pymntnum = x.crefno) and a.custnum = b.custnum
	--	where left(paydate,7)=@colldate
	--	 and right(paydate,2)<4 and pymntstat='1'

		--end
	--end
END