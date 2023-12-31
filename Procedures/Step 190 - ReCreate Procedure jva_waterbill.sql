ALTER PROCEDURE [dbo].[jva_waterbill](@billdate1 varchar(7),@mode1 varchar(1))
	-- Add the parameters for the stored procedure here
	
AS
BEGIN

	declare @billdate varchar(7)
	set @billdate = @billdate1
	declare	@mode varchar(1)
	set @mode = @mode1
	SET NOCOUNT ON;
	
	IF (@mode = '1')
	BEGIN
	

			select zoneno,Classification, 
			consumption,[Total Bill Amount],[Basic Charge],[Price Escalation],[Cons Cost], 
			[Arrears],[Recon fee/Penalty] 
			FROM 
			( 
				select f.zoneno,c.ratename as Classification
				,sum(isnull(e.cons1,0)) as Consumption 
				,sum(a.BillAmnt) as [Total Bill Amount],
				sum(a.Subtot1) as [Basic Charge],sum(a.Subtot2) as [Price Escalation], 
				sum(a.Subtot3) as [Cons Cost],sum(a.Subtot4) as [Arrears], 
				sum(a.Subtot5) as [Recon fee/Penalty] 
				from cbill a
				left join cust b 
				on a.CustId = b.CustId 
				left join rates c 
				on c.RateId = b.RateId     
				left join rhist e 
				on e.RhistId = a.RhistId  
				LEFT JOIN Zones f
				on b.ZoneId = f.ZoneId           
				where a.billdate= @billdate
				group by f.zoneno,c.ratename
			) a
			UNION
			(
				select
				f.zoneno,
				RateName Classification,
				sum(volume) consumption,
				sum(amount1) [Total Bill Amount],
				sum(amount1) [Basic Charge],
				0 [Price Escalation],
				0 [Cons Cost],
				0 [Arrears],
				0 [Recon fee/Penalty]
				from
				waterdelivery a
				left join cust b on a.[custnum] = b.[CustNum]
				left join rates c on c.RateId = b.[rateid]
				LEFT JOIN Zones f
				on b.ZoneId = f.ZoneId    
				where left(convert(varchar(20), [delivery_date], 111), 7) = @billdate
				group by f.zoneno,c.ratename
			)
			order by zoneno,classification
 
	END

	ELSE IF(@mode ='2')
	BEGIN
		 select bookno,Classification, 
		 consumption,[Total Bill Amount],[Basic Charge],[Price Escalation],[Cons Cost], 
		 [Arrears],[Recon fee/Penalty] 
		 FROM 
		 ( 
            select f.bookno,c.ratename as Classification
            ,sum(isnull(e.cons1,0)) as Consumption 
            ,sum(a.BillAmnt) as [Total Bill Amount],
            sum(a.Subtot1) as [Basic Charge],sum(a.Subtot2) as [Price Escalation], 
            sum(a.Subtot3) as [Cons Cost],sum(a.Subtot4) as [Arrears], 
            sum(a.Subtot5) as [Recon fee/Penalty] 
			FROM cbill a
            INNER JOIN cust b 
			on a.CustId = b.CustId 
            INNER JOIN rates c 
			on c.rateid = b.rateid     			   
            INNER JOIN rhist e 
			on e.RhistId = a.RhistId 
			INNER JOIN Books f
			on e.BookId = f.BookId         
			where a.billdate= @billdate
			group by f.bookno,c.ratename
		) a
		UNION
		(
			select
			f.zoneno,
			RateName Classification,
			sum(volume) consumption,
			sum(amount1) [Total Bill Amount],
			sum(amount1) [Basic Charge],
			0 [Price Escalation],
			0 [Cons Cost],
			0 [Arrears],
			0 [Recon fee/Penalty]
			from
			waterdelivery a
			left join cust b on a.[custnum] = b.[CustNum]
			left join rates c on c.RateId = b.[rateId]
			LEFT JOIN Zones f
			on b.ZoneId = f.ZoneId    
			where left(convert(varchar(20), [delivery_date], 111), 7) = @billdate
			group by f.zoneno,c.ratename
		)
		order by bookno,classification

	END

	ELSE
	BEGIN
	
		select f.bookno,g.zoneno,b.custnum,custname,c.Ratename Classification,ltrim(rtrim(d.meterno1)) as meter#,ltrim(rtrim(isnull((select max(idate) from cmeters where CustId = a.CustId),'N/A'))) as [Date Installed] 
		,e.Cons1 consumption,a.BillAmnt [Total Bill Amount],a.SubTot1 [Basic Charge],a.subtot2 as [Price Escalation],a.SubTot3 [Cons Cost], 
		a.subtot4 [Arrears],a.subtot5 [Recon fee/Penalty],a.billdate,case when seniordate > getdate() then (a.SubTot1 * .05) * -1 else 0 end as SeniorDiscount 
		
		FROM cbill a
        INNER JOIN cust b 
		on a.CustId = b.CustId 
        INNER JOIN rates c 
		on c.rateid = b.rateid 
        INNER JOIN Members d 
		on a.CustId = d.CustId    			   
        INNER JOIN rhist e 
		on e.RhistId = a.RhistId 
		INNER JOIN Books f
		on e.BookId = f.BookId    
		LEFT JOIN Zones g
		on b.ZoneId = g.ZoneId          
		where a.billdate= @billdate


		union

		Select e.bookno,g.zoneno,x.custnum,custname,c.Ratename Classification,ltrim(rtrim(d.meterno1)) as meter#,ltrim(rtrim(isnull((select max(idate) from cmeters where CustId = b.CustId),'N/A'))) as [Date Installed] 
		,x.consumption consumption,x.[Basic Charge] [Total Bill Amount],x.[Basic Charge] [Basic Charge],0 as [Price Escalation],0 [Cons Cost], 
		0 [Arrears],0 [Recon fee/Penalty],@billdate billdate,0 as SeniorDiscount 
		FROM
		(
			select a.custnum,sum(a.volume) consumption,sum(a.amount1) [Basic Charge]
			from
			waterdelivery a
			where convert(varchar(7),a.delivery_date,111)  = @billdate
			group by a.custnum
		)x
		INNER JOIN cust b on x.custnum = b.custnum 
		INNER JOIN rates c on c.rateid = b.rateid 
		INNER JOIN members d on d.CustId = b.CustId 
		INNER JOIN Books e on d.BookId = e.BookId   
		LEFT JOIN Zones g
		on b.ZoneId = g.ZoneId
    
	END
 
 
END
