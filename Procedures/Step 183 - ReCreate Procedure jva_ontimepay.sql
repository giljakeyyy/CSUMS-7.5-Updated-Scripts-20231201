ALTER PROCEDURE [dbo].[jva_ontimepay](@billdate1 varchar(7),@paystat1 varchar(1))
	-- Add the parameters for the stored procedure here
	
AS
BEGIN

	declare @billdate varchar(7)
	set @billdate = @billdate1
	declare	@paystat varchar(1)
	set @paystat = @paystat1
	SET NOCOUNT ON;
	
	if (@paystat <> '2')
	BEGIN
	
		select *,
		cast((cast(totalpaid as decimal(10,2))/cast(totalbilled as decimal(10,2))) * 100 as numeric(18,2)) as [On Time per Account] 
		,cast(([Pay Amount]/[Total Bill Amount]) * 100   as numeric(18,2))as [On Time Per Amount] from(
		select y.ZoneNo,TotalBilled,[Total Bill Amount],DueDate,TotalPaid,[Pay Amount] 
		FROM
		(
			select a.zoneno,sum(subtot1) as [Total Bill Amount],sum(payamnt) [Pay Amount],duedate = max(duedate)
			FROM
			(
				select e.zoneno,a.CustId,d.ratename as Classification,a.subtot1,a.duedate,
				case when b.paydate<=a.duedate then
				payamnt
				else
				NULL
				end as payamnt,
				case when b.paydate <= a.duedate 
				then
				b.PayDate
				else
				NULL
				end as PayDate
				FROM cbill a 
				LEFT JOIN 
				(
					select CustId,sum(subtot1) payamnt,paydate=max(paydate) 
					FROM Cpaym 
					where left(paydate,7) = @billdate and pymntstat = @paystat and subtot1>0 group by CustId
				) b 
				on a.CustId =b.CustId
				INNER JOIN Cust c 
				on a.CustId = c.CustId 
				INNER JOIN rates d 
				on c.RateId = d.RateId
				INNER JOIN Zones e
				on c.ZoneId = e.ZoneId
				where a.billdate=@billdate
			 ) a
			 group by a.zoneno
		 ) y
		 LEFT JOIN
		 (
			select c.zoneno,count(a.CustId) TotalBilled 
			from cbill a 
			INNER JOIN Cust b on a.CustId = b.CustId 
			INNER JOIN Zones c
			on b.ZoneId = c.ZoneId
			where billdate=@billdate group by c.zoneno
		 ) b
		 on b.zoneno = y.zoneno
		 left join 
		 (
			select c.zoneno,count(a.CustId) totalpaid from cpaym  a 
			INNER JOIN Cust b on a.CustId = b.CustId
			INNER JOIN Zones c
			on b.ZoneId = c.ZoneId
			where left(paydate,7) = @billdate and subtot1>0 group by c.zoneno
		 ) 
		 c on c.zoneno =y.zoneno
		 )
		 z
		 order by z.zoneno
 
	END
	ELSE
	BEGIN

		select *,
		cast((cast(totalpaid as decimal(10,2))/cast(totalbilled as decimal(10,2))) * 100 as numeric(18,2)) as [On Time per Account(%)] 
		,cast(([Pay Amount]/[Total Bill Amount]) * 100   as numeric(18,2))as [On Time Per Amount(%)] 
		FROM
		(
			select y.ZoneNo,TotalBilled,[Total Bill Amount],DueDate,TotalPaid,[Pay Amount] 
			FROM
			(
				select zoneno,sum(subtot1) as [Total Bill Amount],sum(payamnt) [Pay Amount],duedate = max(duedate)
				FROM
				(
					select e.zoneno,a.CustId,d.ratename as Classification,a.subtot1,a.duedate,
					case when b.paydate<=a.duedate then
					payamnt
					else
					NULL
					end as payamnt,
					case when b.paydate <= a.duedate 
					then
					b.PayDate
					else
					NULL
					end as PayDate
					from cbill a 
					LEFT JOIN
					(
						select CustId,sum(subtot1) payamnt,paydate=max(paydate) from cpaym 
						where left(paydate,7) = @billdate and subtot1>0 group by CustId
					) b on a.CustId =b.CustId
					LEFT JOIN Cust c 
					on a.CustId = c.CustId 
					INNER JOIN rates d 
					on c.RateId = d.RateId
					INNER JOIN Zones e
					on c.ZoneId = e.ZoneId
					where a.billdate=@billdate
				) a
				group by a.zoneno
			) y
			LEFT JOIN
			(
				select c.zoneno,count(a.CustId) TotalBilled 
				from cbill a 
				INNER JOIN Cust b on a.CustId = b.CustId
				INNER JOIN Zones c
				on b.ZoneId = c.ZoneId 
				where billdate=@billdate 
				group by c.zoneno
			) b
			on b.zoneno = y.zoneno
			LEFT JOIN 
			(
				select c.zoneno,count(a.CustId) totalpaid from cpaym  a 
				INNER JOIN Cust b 
				on a.CustId = b.CustId 
				INNER JOIN Zones c
				on b.ZoneId = c.ZoneId
				where left(paydate,7) = @billdate and subtot1>0 group by c.zoneno
			) 
			c on c.zoneno =y.zoneno
		)
		z
		order by z.zoneno
	 END
 
 
END



