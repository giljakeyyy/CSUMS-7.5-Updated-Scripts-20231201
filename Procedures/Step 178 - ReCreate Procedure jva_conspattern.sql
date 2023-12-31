ALTER PROCEDURE [dbo].[jva_conspattern](@billdate1 varchar(7),@mode varchar(1))
	-- Add the parameters for the stored procedure here
	
AS
BEGIN

	declare @billdate varchar(7)
	set @billdate = @billdate1
	declare @mode1 varchar(1)
	set @mode1 = @mode
	SET NOCOUNT ON;
	
	IF (@mode1 = '1')
	BEGIN

		select 'Regular' as Type, ratename [Classification],
		SUM([0 cons]) [0 cons],
		sum(cast([0consval] as numeric(18,2))) [Value],
		SUM([1-5]) [1-5],
		sum(cast([5consval] as numeric(18,2))) [Value],
		SUM([6-10]) [6-10],
		sum(cast([6consval] as numeric(18,2))) [Value],
		SUM([11-20]) [11-20],
		sum(cast([11consval] as numeric(18,2))) [Value],
		SUM([21-30]) [21-30],
		sum(cast([21consval] as numeric(18,2))) [Value],
		SUM([31-40]) [31-40],
		sum(cast([31consval] as numeric(18,2))) [Value],
		SUM([41-50]) [41-50],
		sum(cast([41consval] as numeric(18,2))) [Value],
		SUM([51-up]) [51-up],
		sum(cast([51consval] as numeric(18,2))) [Value],
		SUM([0 cons]) + SUM([1-5]) + sum([6-10]) + SUM([11-20]) +SUM([21-30]) + SUM([31-40]) +SUM([41-50]) + SUM([51-up]) Total,
		cast(SUM([0consval]) + SUM([5consval]) + sum([6consval]) + SUM([11consval]) +SUM([21consval]) + SUM([31consval]) +SUM([41consval]) + SUM([51consval]) as numeric(18,2)) TotalValue

		from
		(
			select ratename,
			case when cons1 = 0 then 1
			else 0 end as [0 cons],
			case when cons1 > 0 and cons1 <=5 then 1
			else 0 end as [1-5],
			case when cons1 > 5 and cons1 <=10 then 1
			else 0 end as [6-10],
			case when cons1 > 10 and cons1 <= 20 then 1
			else 0
			end as [11-20],
			case when cons1 > 20 and cons1 <= 30 then 1
			else 0
			end as [21-30],
			case when cons1 > 30 and cons1 <= 40 then 1
			else 0
			end as [31-40],
			case when cons1 > 40 and cons1 <= 50 then 1
			else 0
			end as [41-50],
			case when cons1 > 50 then 1
			else 0
			end as [51-up],
			case when cons1 = 0 then subtot1
			else 0 end as [0consval],
			case when cons1 > 0 and cons1 <=5 then subtot1
			else 0 end as [5consval],
			case when cons1 > 5 and cons1 <=10 then subtot1
			else 0 end as [6consval],
			case when cons1 > 10 and cons1 <= 20 then subtot1
			else 0 end as [11consval],
			case when cons1 > 20 and cons1 <= 30 then subtot1
			else 0 end as [21consval],
			case when cons1 > 30 and cons1 <= 40 then subtot1
			else 0 end as [31consval],
			case when cons1 > 40 and cons1 <= 50 then subtot1
			else 0 end as [41consval],
			case when cons1 > 50 then subtot1
			else 0 end as [51consval]

			from rates a 
			INNER JOIN rhist b 
			on a.RateId = b.RateId
			INNER JOIN Cbill e 
			on b.RhistId = e.RhistId
			where b.BillDate = @billdate
		) a
		group by RateName

		UNION

		select 'WDelivery' as Type,ratename [Classification],
		SUM([0 cons]) [0 cons],
		sum(cast([0consval] as numeric(18,2))) [Value],
		SUM([1-5]) [1-5],
		sum(cast([5consval] as numeric(18,2))) [Value],
		SUM([6-10]) [6-10],
		sum(cast([6consval] as numeric(18,2))) [Value],
		SUM([11-20]) [11-20],
		sum(cast([11consval] as numeric(18,2))) [Value],
		SUM([21-30]) [21-30],
		sum(cast([21consval] as numeric(18,2))) [Value],
		SUM([31-40]) [31-40],
		sum(cast([31consval] as numeric(18,2))) [Value],
		SUM([41-50]) [41-50],
		sum(cast([41consval] as numeric(18,2))) [Value],
		SUM([51-up]) [51-up],
		sum(cast([51consval] as numeric(18,2))) [Value],
		SUM([0 cons]) + SUM([1-5]) + sum([6-10]) + SUM([11-20]) +SUM([21-30]) + SUM([31-40]) +SUM([41-50]) + SUM([51-up]) Total,
		cast(SUM([0consval]) + SUM([5consval]) + sum([6consval]) + SUM([11consval]) +SUM([21consval]) + SUM([31consval]) +SUM([41consval]) + SUM([51consval]) as numeric(18,2)) TotalValue

		from
		(
			select ratename,
			case when cons1 = 0 then 1
			else 0 end as [0 cons],
			case when cons1 > 0 and cons1 <=5 then 1
			else 0 end as [1-5],
			case when cons1 > 5 and cons1 <=10 then 1
			else 0 end as [6-10],
			case when cons1 > 10 and cons1 <= 20 then 1
			else 0
			end as [11-20],
			case when cons1 > 20 and cons1 <= 30 then 1
			else 0
			end as [21-30],
			case when cons1 > 30 and cons1 <= 40 then 1
			else 0
			end as [31-40],
			case when cons1 > 40 and cons1 <= 50 then 1
			else 0
			end as [41-50],
			case when cons1 > 50 then 1
			else 0
			end as [51-up],
			case when cons1 = 0 then subtot1
			else 0 end as [0consval],
			case when cons1 > 0 and cons1 <=5 then subtot1
			else 0 end as [5consval],
			case when cons1 > 5 and cons1 <=10 then subtot1
			else 0 end as [6consval],
			case when cons1 > 10 and cons1 <= 20 then subtot1
			else 0 end as [11consval],
			case when cons1 > 20 and cons1 <= 30 then subtot1
			else 0 end as [21consval],
			case when cons1 > 30 and cons1 <= 40 then subtot1
			else 0 end as [31consval],
			case when cons1 > 40 and cons1 <= 50 then subtot1
			else 0 end as [41consval],
			case when cons1 > 50 then subtot1
			else 0 end as [51consval]

			from rates a 
			left join (
				Select convert(varchar(7),delivery_date,111) as billdate,RateId,
				volume as cons1,amount1 AS SUBTOT1 from waterdelivery 
				left join cust 
				on waterdelivery.custnum = cust.CustNum 
				where convert(varchar(7),delivery_date,111) = @billdate
			) b on a.RateId = b.RateId
			where b.BillDate = @billdate

		) a
		group by RateName
		order by RateName

	END

	else if(@mode1 = '2')
	begin

		select 'Regular' as Type,zoneno,zonename,
		SUM([0 cons]) [0 cons],
		sum(cast([0consval] as numeric(18,2))) [Value],
		SUM([1-5]) [1-5],
		sum(cast([5consval] as numeric(18,2))) [Value],
		SUM([6-10]) [6-10],
		sum(cast([6consval] as numeric(18,2))) [Value],
		SUM([11-20]) [11-20],
		sum(cast([11consval] as numeric(18,2))) [Value],
		SUM([21-30]) [21-30],
		sum(cast([21consval] as numeric(18,2))) [Value],
		SUM([31-40]) [31-40],
		sum(cast([31consval] as numeric(18,2))) [Value],
		SUM([41-50]) [41-50],
		sum(cast([41consval] as numeric(18,2))) [Value],
		SUM([51-up]) [51-up],
		sum(cast([51consval] as numeric(18,2))) [Value],
		SUM([0 cons]) + SUM([1-5]) + sum([6-10]) + SUM([11-20]) +SUM([21-30]) + SUM([31-40]) +SUM([41-50]) + SUM([51-up]) Total,
		cast(SUM([0consval]) + SUM([5consval]) + sum([6consval]) + SUM([11consval]) +SUM([21consval]) + SUM([31consval]) +SUM([41consval]) + SUM([51consval]) as numeric(18,2)) TotalValue
		from
		(
			select d.zoneno,d.zonename,
			case when cons1 = 0 then 1
			else 0 end as [0 cons],
			case when cons1 > 0 and cons1 <=5 then 1
			else 0 end as [1-5],
			case when cons1 > 5 and cons1 <=10 then 1
			else 0 end as [6-10],
			case when cons1 > 10 and cons1 <= 20 then 1
			else 0
			end as [11-20],
			case when cons1 > 20 and cons1 <= 30 then 1
			else 0
			end as [21-30],
			case when cons1 > 30 and cons1 <= 40 then 1
			else 0
			end as [31-40],
			case when cons1 > 40 and cons1 <= 50 then 1
			else 0
			end as [41-50],
			case when cons1 > 50 then 1
			else 0
			end as [51-up],
			case when cons1 = 0 then subtot1
			else 0 end as [0consval],
			case when cons1 > 0 and cons1 <=5 then subtot1
			else 0 end as [5consval],
			case when cons1 > 5 and cons1 <=10 then subtot1
			else 0 end as [6consval],
			case when cons1 > 10 and cons1 <= 20 then subtot1
			else 0 end as [11consval],
			case when cons1 > 20 and cons1 <= 30 then subtot1
			else 0 end as [21consval],
			case when cons1 > 30 and cons1 <= 40 then subtot1
			else 0 end as [31consval],
			case when cons1 > 40 and cons1 <= 50 then subtot1
			else 0 end as [41consval],
			case when cons1 > 50 then subtot1
			else 0 end as [51consval]
			from rates a 
			INNER JOIN rhist b on a.RateId = b.RateId
			INNER JOIN cust c on c.CustId = b.CustId
			INNER JOIN zones d on d.ZoneId = c.ZoneId
			INNER JOIN Cbill e on b.RhistId = e.RhistId
			where b.BillDate = @billdate
		) a

		group by zoneno,zonename

		union

	
		select 'WDelivery' as Type,zoneno,zonename,
		SUM([0 cons]) [0 cons],
		sum(cast([0consval] as numeric(18,2))) [Value],
		SUM([1-5]) [1-5],
		sum(cast([5consval] as numeric(18,2))) [Value],
		SUM([6-10]) [6-10],
		sum(cast([6consval] as numeric(18,2))) [Value],
		SUM([11-20]) [11-20],
		sum(cast([11consval] as numeric(18,2))) [Value],
		SUM([21-30]) [21-30],
		sum(cast([21consval] as numeric(18,2))) [Value],
		SUM([31-40]) [31-40],
		sum(cast([31consval] as numeric(18,2))) [Value],
		SUM([41-50]) [41-50],
		sum(cast([41consval] as numeric(18,2))) [Value],
		SUM([51-up]) [51-up],
		sum(cast([51consval] as numeric(18,2))) [Value],
		SUM([0 cons]) + SUM([1-5]) + sum([6-10]) + SUM([11-20]) +SUM([21-30]) + SUM([31-40]) +SUM([41-50]) + SUM([51-up]) Total,
		cast(SUM([0consval]) + SUM([5consval]) + sum([6consval]) + SUM([11consval]) +SUM([21consval]) + SUM([31consval]) +SUM([41consval]) + SUM([51consval]) as numeric(18,2)) TotalValue
		from
		(
			select d.zoneno,d.zonename,
			case when cons1 = 0 then 1
			else 0 end as [0 cons],
			case when cons1 > 0 and cons1 <=5 then 1
			else 0 end as [1-5],
			case when cons1 > 5 and cons1 <=10 then 1
			else 0 end as [6-10],
			case when cons1 > 10 and cons1 <= 20 then 1
			else 0
			end as [11-20],
			case when cons1 > 20 and cons1 <= 30 then 1
			else 0
			end as [21-30],
			case when cons1 > 30 and cons1 <= 40 then 1
			else 0
			end as [31-40],
			case when cons1 > 40 and cons1 <= 50 then 1
			else 0
			end as [41-50],
			case when cons1 > 50 then 1
			else 0
			end as [51-up],
			case when cons1 = 0 then subtot1
			else 0 end as [0consval],
			case when cons1 > 0 and cons1 <=5 then subtot1
			else 0 end as [5consval],
			case when cons1 > 5 and cons1 <=10 then subtot1
			else 0 end as [6consval],
			case when cons1 > 10 and cons1 <= 20 then subtot1
			else 0 end as [11consval],
			case when cons1 > 20 and cons1 <= 30 then subtot1
			else 0 end as [21consval],
			case when cons1 > 30 and cons1 <= 40 then subtot1
			else 0 end as [31consval],
			case when cons1 > 40 and cons1 <= 50 then subtot1
			else 0 end as [41consval],
			case when cons1 > 50 then subtot1
			else 0 end as [51consval]
			from rates a 
			INNER JOIN 
			(
				Select convert(varchar(7),delivery_date,111) as billdate,ZoneId,RateId,
				volume as cons1,amount1 AS SUBTOT1 
				from waterdelivery 
				left join cust 
				on waterdelivery.custnum = cust.CustNum 
				where convert(varchar(7),delivery_date,111) = @billdate
				) b 
				on a.RateId = b.RateId
			left join zones d on d.ZoneId = b.ZoneId
		) a

		group by zoneno,zonename

		order by zoneno
	end

	else if (@mode1 = '3')
	begin

		select 'Regular' as Type,custnum,
		SUM([0 cons]) [0 cons],
		sum([0consval]) [Value],
		SUM([1-5]) [1-5],
		sum([5consval]) [Value],
		SUM([6-10]) [6-10],
		sum([6consval]) [Value],
		SUM([11-20]) [11-20],
		sum([11consval]) [Value],
		SUM([21-30]) [21-30],
		sum([21consval]) [Value],
		SUM([31-40]) [31-40],
		sum([31consval]) [Value],
		SUM([41-50]) [41-50],
		sum([41consval]) [Value],
		SUM([51-up]) [51-up],
		sum([51consval]) [Value],
		SUM([0 cons]) + SUM([1-5]) + sum([6-10]) + SUM([11-20]) +SUM([21-30]) + SUM([31-40]) +SUM([41-50]) + SUM([51-up]) Total,
		SUM([0consval]) + SUM([5consval]) + sum([6consval]) + SUM([11consval]) +SUM([21consval]) + SUM([31consval]) +SUM([41consval]) + SUM([51consval]) TotalValue

		from(
		select c.custnum,
		case when cons1 = 0 then 1
		else 0 end as [0 cons],
		case when cons1 > 0 and cons1 <=5 then 1
		else 0 end as [1-5],
		case when cons1 > 5 and cons1 <=10 then 1
		else 0 end as [6-10],
		case when cons1 > 10 and cons1 <= 20 then 1
		else 0
		end as [11-20],
		case when cons1 > 20 and cons1 <= 30 then 1
		else 0
		end as [21-30],
		case when cons1 > 30 and cons1 <= 40 then 1
		else 0
		end as [31-40],
		case when cons1 > 40 and cons1 <= 50 then 1
		else 0
		end as [41-50],
		case when cons1 > 50 then 1
		else 0
		end as [51-up],
		case when cons1 = 0 then subtot1
		else 0 end as [0consval],
		case when cons1 > 0 and cons1 <=5 then subtot1
		else 0 end as [5consval],
		case when cons1 > 5 and cons1 <=10 then subtot1
		else 0 end as [6consval],
		case when cons1 > 10 and cons1 <= 20 then subtot1
		else 0 end as [11consval],
		case when cons1 > 20 and cons1 <= 30 then subtot1
		else 0 end as [21consval],
		case when cons1 > 30 and cons1 <= 40 then subtot1
		else 0 end as [31consval],
		case when cons1 > 40 and cons1 <= 50 then subtot1
		else 0 end as [41consval],
		case when cons1 > 50 then subtot1
		else 0 end as [51consval]

		from rhist b 
		INNER JOIN Cust c
		on b.CustId = c.CustId
		INNER JOIN Cbill e on b.RhistId = e.RhistId
		where b.BillDate = @billdate
		) a group by custnum

		union

		select 'WDelivery' as Type,custnum,
		SUM([0 cons]) [0 cons],
		sum([0consval]) [Value],
		SUM([1-5]) [1-5],
		sum([5consval]) [Value],
		SUM([6-10]) [6-10],
		sum([6consval]) [Value],
		SUM([11-20]) [11-20],
		sum([11consval]) [Value],
		SUM([21-30]) [21-30],
		sum([21consval]) [Value],
		SUM([31-40]) [31-40],
		sum([31consval]) [Value],
		SUM([41-50]) [41-50],
		sum([41consval]) [Value],
		SUM([51-up]) [51-up],
		sum([51consval]) [Value],
		SUM([0 cons]) + SUM([1-5]) + sum([6-10]) + SUM([11-20]) +SUM([21-30]) + SUM([31-40]) +SUM([41-50]) + SUM([51-up]) Total,
		SUM([0consval]) + SUM([5consval]) + sum([6consval]) + SUM([11consval]) +SUM([21consval]) + SUM([31consval]) +SUM([41consval]) + SUM([51consval]) TotalValue

		from
		(
			select b.custnum,
			case when cons1 = 0 then 1
			else 0 end as [0 cons],
			case when cons1 > 0 and cons1 <=5 then 1
			else 0 end as [1-5],
			case when cons1 > 5 and cons1 <=10 then 1
			else 0 end as [6-10],
			case when cons1 > 10 and cons1 <= 20 then 1
			else 0
			end as [11-20],
			case when cons1 > 20 and cons1 <= 30 then 1
			else 0
			end as [21-30],
			case when cons1 > 30 and cons1 <= 40 then 1
			else 0
			end as [31-40],
			case when cons1 > 40 and cons1 <= 50 then 1
			else 0
			end as [41-50],
			case when cons1 > 50 then 1
			else 0
			end as [51-up],
			case when cons1 = 0 then subtot1
			else 0 end as [0consval],
			case when cons1 > 0 and cons1 <=5 then subtot1
			else 0 end as [5consval],
			case when cons1 > 5 and cons1 <=10 then subtot1
			else 0 end as [6consval],
			case when cons1 > 10 and cons1 <= 20 then subtot1
			else 0 end as [11consval],
			case when cons1 > 20 and cons1 <= 30 then subtot1
			else 0 end as [21consval],
			case when cons1 > 30 and cons1 <= 40 then subtot1
			else 0 end as [31consval],
			case when cons1 > 40 and cons1 <= 50 then subtot1
			else 0 end as [41consval],
			case when cons1 > 50 then subtot1
			else 0 end as [51consval]

			from 
			(
				Select waterdelivery.custnum,convert(varchar(7),delivery_date,111) as billdate,
				ZoneId,RateId,volume as cons1,amount1 AS SUBTOT1 
				from waterdelivery 
				left join cust 
				on waterdelivery.custnum = cust.CustNum 
				where convert(varchar(7),delivery_date,111) = @billdate
			) b
			where b.BillDate = @billdate
		) a group by custnum
		order by CustNum

	end

	else
	begin

		select 'Regular' as Type,bookno,area,
		SUM([0 cons]) [0 cons],
		sum(cast([0consval] as numeric(18,2))) [Value],
		SUM([1-5]) [1-5],
		sum(cast([5consval] as numeric(18,2))) [Value],
		SUM([6-10]) [6-10],
		sum(cast([6consval] as numeric(18,2))) [Value],
		SUM([11-20]) [11-20],
		sum(cast([11consval] as numeric(18,2))) [Value],
		SUM([21-30]) [21-30],
		sum(cast([21consval] as numeric(18,2))) [Value],
		SUM([31-40]) [31-40],
		sum(cast([31consval] as numeric(18,2))) [Value],
		SUM([41-50]) [41-50],
		sum(cast([41consval] as numeric(18,2))) [Value],
		SUM([51-up]) [51-up],
		sum(cast([51consval] as numeric(18,2))) [Value],
		SUM([0 cons]) + SUM([1-5]) + sum([6-10]) + SUM([11-20]) +SUM([21-30]) + SUM([31-40]) +SUM([41-50]) + SUM([51-up]) Total,
		cast(SUM([0consval]) + SUM([5consval]) + sum([6consval]) + SUM([11consval]) +SUM([21consval]) + SUM([31consval]) +SUM([41consval]) + SUM([51consval]) as numeric(18,2)) TotalValue
		from(
		select d.bookno,d.Area,
		case when cons1 = 0 then 1
		else 0 end as [0 cons],
		case when cons1 > 0 and cons1 <=5 then 1
		else 0 end as [1-5],
		case when cons1 > 5 and cons1 <=10 then 1
		else 0 end as [6-10],
		case when cons1 > 10 and cons1 <= 20 then 1
		else 0
		end as [11-20],
		case when cons1 > 20 and cons1 <= 30 then 1
		else 0
		end as [21-30],
		case when cons1 > 30 and cons1 <= 40 then 1
		else 0
		end as [31-40],
		case when cons1 > 40 and cons1 <= 50 then 1
		else 0
		end as [41-50],
		case when cons1 > 50 then 1
		else 0
		end as [51-up],
		case when cons1 = 0 then subtot1
		else 0 end as [0consval],
		case when cons1 > 0 and cons1 <=5 then subtot1
		else 0 end as [5consval],
		case when cons1 > 5 and cons1 <=10 then subtot1
		else 0 end as [6consval],
		case when cons1 > 10 and cons1 <= 20 then subtot1
		else 0 end as [11consval],
		case when cons1 > 20 and cons1 <= 30 then subtot1
		else 0 end as [21consval],
		case when cons1 > 30 and cons1 <= 40 then subtot1
		else 0 end as [31consval],
		case when cons1 > 40 and cons1 <= 50 then subtot1
		else 0 end as [41consval],
		case when cons1 > 50 then subtot1
		else 0 end as [51consval]
		 from rates a 
		 INNER JOIN rhist b on a.RateId = b.RateId
		 INNER JOIN books d on d.BookId = b.BookId
		 INNER JOIN cbill e on b.RhistId = e.RhistId
		where b.BillDate = @billdate
		) a
		group by bookno,area

		union

	
		select 'WDelivery' as Type,bookno,area,
		SUM([0 cons]) [0 cons],
		sum(cast([0consval] as numeric(18,2))) [Value],
		SUM([1-5]) [1-5],
		sum(cast([5consval] as numeric(18,2))) [Value],
		SUM([6-10]) [6-10],
		sum(cast([6consval] as numeric(18,2))) [Value],
		SUM([11-20]) [11-20],
		sum(cast([11consval] as numeric(18,2))) [Value],
		SUM([21-30]) [21-30],
		sum(cast([21consval] as numeric(18,2))) [Value],
		SUM([31-40]) [31-40],
		sum(cast([31consval] as numeric(18,2))) [Value],
		SUM([41-50]) [41-50],
		sum(cast([41consval] as numeric(18,2))) [Value],
		SUM([51-up]) [51-up],
		sum(cast([51consval] as numeric(18,2))) [Value],
		SUM([0 cons]) + SUM([1-5]) + sum([6-10]) + SUM([11-20]) +SUM([21-30]) + SUM([31-40]) +SUM([41-50]) + SUM([51-up]) Total,
		cast(SUM([0consval]) + SUM([5consval]) + sum([6consval]) + SUM([11consval]) +SUM([21consval]) + SUM([31consval]) +SUM([41consval]) + SUM([51consval]) as numeric(18,2)) TotalValue
		from(
		select d.bookno,d.Area,
		case when cons1 = 0 then 1
		else 0 end as [0 cons],
		case when cons1 > 0 and cons1 <=5 then 1
		else 0 end as [1-5],
		case when cons1 > 5 and cons1 <=10 then 1
		else 0 end as [6-10],
		case when cons1 > 10 and cons1 <= 20 then 1
		else 0
		end as [11-20],
		case when cons1 > 20 and cons1 <= 30 then 1
		else 0
		end as [21-30],
		case when cons1 > 30 and cons1 <= 40 then 1
		else 0
		end as [31-40],
		case when cons1 > 40 and cons1 <= 50 then 1
		else 0
		end as [41-50],
		case when cons1 > 50 then 1
		else 0
		end as [51-up],
		case when cons1 = 0 then subtot1
		else 0 end as [0consval],
		case when cons1 > 0 and cons1 <=5 then subtot1
		else 0 end as [5consval],
		case when cons1 > 5 and cons1 <=10 then subtot1
		else 0 end as [6consval],
		case when cons1 > 10 and cons1 <= 20 then subtot1
		else 0 end as [11consval],
		case when cons1 > 20 and cons1 <= 30 then subtot1
		else 0 end as [21consval],
		case when cons1 > 30 and cons1 <= 40 then subtot1
		else 0 end as [31consval],
		case when cons1 > 40 and cons1 <= 50 then subtot1
		else 0 end as [41consval],
		case when cons1 > 50 then subtot1
		else 0 end as [51consval]
		from rates a 
		INNER JOIN 
		(
			Select waterdelivery.custnum,members.BookId,convert(varchar(7),delivery_date,111) as billdate,
			ZoneId,RateId,volume as cons1,amount1 AS SUBTOT1 
			from waterdelivery 
			INNER JOIN cust on waterdelivery.custnum = cust.CustNum 
			INNER JOIN members on cust.CustId = members.CustId 
			where convert(varchar(7),delivery_date,111) = @billdate
		) b 
		on a.RateId = b.RateId
		INNER JOIN books d on d.BookId = b.BookId
		where b.BillDate = @billdate
		) a

		group by bookno,area
		order by bookno

	end



 
 
END
