ALTER PROCEDURE [dbo].[jva_ontimepay_detail](@billdate1 varchar(7),@paystat1 varchar(1))
	-- Add the parameters for the stoared procedure here
	
AS
BEGIN

	declare @billdate varchar(7)
	set @billdate = @billdate1
	declare	@paystat varchar(1)
	set @paystat = @paystat1
	SET NOCOUNT ON;

	IF (@paystat <> '2')
	BEGIN
		select e.zoneno,c.custnum,d.ratename as Classification,isnull(a.subtot1, 0) as [Current Water Bill],a.duedate,
		case when b.paydate<=a.duedate then
		payamnt
		else
		NULL
		end as [On-Time Payment],
		case when b.paydate <= a.duedate 
		then
		b.PayDate
		else
		NULL
		end as PayDate
		from cbill a 
		LEFT JOIN 
		(
			select CustId,sum(subtot1) payamnt,paydate=max(paydate) from cpaym where left(paydate,7) = @billdate and pymntstat = @paystat and subtot1>0 group by CustId
		) b on a.CustId =b.CustId
		INNER JOIN Cust c on a.CustId = c.CustId 
		INNER JOIN rates d on c.RateId = d.RateId
		INNER JOIN Zones e
		on c.ZoneId = e.ZoneId
		where a.billdate=@billdate


	END

	ELSE
	BEGIN
		select e.zoneno,c.custnum,d.ratename as Classification,isnull(a.subtot1, 0) as [Current Water Bill],a.duedate,
		case when b.paydate<=a.duedate then
		payamnt
		else
		NULL
		end as [On-Time Payment],
		case when b.paydate <= a.duedate 
		then
		b.PayDate
		else
		NULL
		end as PayDate
		from cbill a 
		LEFT JOIN
		(
			select CustId,sum(subtot1) payamnt,paydate=max(paydate) 
			FROM cpaym 
			where left(paydate,7) = @billdate and subtot1>0 group by CustId
		) b 
		on a.CustId =b.CustId
		LEFT JOIN Cust c on a.CustId = c.CustId 
		left join rates d on c.rateId = d.rateid
		INNER JOIN Zones e
		on c.ZoneId = e.ZoneId
		where a.billdate=@billdate

	END



END

