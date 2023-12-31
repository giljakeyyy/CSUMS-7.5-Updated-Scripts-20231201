ALTER PROCEDURE [dbo].[dd_disconnection]
	-- Add the parameters for the stored procedure here
	@billdate varchar(7),
	@bookno varchar(8),
	@zoneno varchar(8),
	@arr varchar(2) = null
AS
BEGIN



    IF(@bookno != 'All')
    BEGIN
		
        insert dd_fDisconnection
        Select distinct a.CustId,a.custname,a.RateId,a.status,'' Remarks,0 [Hoa Balance],
		f.[Water Balance] as [UMS Balance],isnull(b.#ofArrears,0) #ofArrears,@billdate,g.BookId,i.ZoneId,null,
        isnull(f.[Old Arrears],0),isnull(f.LCA,0),isnull(f.[Service Charge],0),isnull(f.[Penalty Balance],0),isnull(f.Sewerage,0)
        from cust a
        left join checkdiscon() b on a.CustId =b.CustId 
        inner join (select CustId,BookId from members) c on a.CustId =c.CustId 
        left join disconstat() d on a.CustId =d.CustId
        left join discon_status_table e on d.type_status = e.statcode
        left join vw_ledger f
        on a.CustId = f.CustId
		inner join Books g
		on c.BookId = g.BookId
		left join dd_fDisconnection h
		on a.CustId = h.CustId
		and h.billdate=@billdate
		INNER JOIN Zones i
		on a.ZOneId = i.ZoneId
		INNER JOIN Rates j
		on a.RateId = j.RateId
        where isnull(f.[Total Balance],0) > 0 
        and (a.status <> 3)
        and g.bookno = @bookno and i.Zoneno  like '%' + @zoneno+ '%'
        and h.[fDisconnectionId] is null

        begin
        insert dd_svdisconnection(custnum,billdate)
        select distinct b.custnum,a.billdate from dd_fdisconnection a
        inner join cust b
        on a.CustId = b.CustId  
        inner join vw_ledger c
        on a.CustId = c.CustId
		Inner Join Books d
		on a.BookId = d.BookId
		INNER JOIN Zones e
		on b.ZoneId = e.ZoneId
		LEFT JOIN dd_svdisconnection f
		on b.CustNum = f.CustNum
		and f.billdate = @billdate
        where d.bookno = @bookno and a.billdate = @billdate and e.zoneno  like '%' + @zoneno+ '%'
        and f.custnum is null
        and #ofarrears >= 1 and statname is null
        
		end

        begin
        select 
        distinct a.CustId as ID, c.custnum as [Acct #],a.custname as Name,a.RateId as [Rate ID]
		,b.[Statdesc] status,
		a.Remarks,a.balance [Water Balance],a.balance1 [Penalty],
		a.oldarrears [Old Arrears],a.lcabal [LCA/PCA Balance],
		a.balserv [Service Connection],a.sewerage_bal [Sewerage],
		a.[#ofArrears],a.billdate,a.statname
        from dd_fDisconnection a left join custstat b on a.status=b.statcd 
		Inner Join Cust c
		on a.CustId = c.CustId
		Inner Join Books d
		on a.BookId = d.BookId
		INNER JOIN Zones e
		on c.ZOneId = e.ZoneId
		where d.bookno = @bookno and a.billdate = @billdate and e.zoneno  like '%' + @zoneno+ '%'
        and #ofarrears >=
            case when @arr = '1' then '1' when @arr = '2' then '2' when @arr = '3' then '3' else '0' end
        and #ofarrears <=
            case when @arr = '1' then '1' when @arr = '2' then '2' else '999' end
        and a.statname is null
        end
    END
    ELSE
    BEGIN
	
        insert dd_fDisconnection
        Select distinct a.CustId,a.custname,a.RateId,a.status,'' Remarks,0 [Hoa Balance],Balance as [UMS Balance],isnull(b.#ofArrears,0) #ofArrears,@billdate,i.BookId,a.ZoneId,null,
        isnull(f.[Old Arrears],0),isnull(f.LCA,0),isnull(f.[Service Charge],0),isnull(f.[Penalty Balance],0),isnull(f.Sewerage,0)
        from cust a
        left join checkdiscon() b on a.CustId =b.CustId 
        INner join (select CustId,BookId from members) c on a.CustId =c.CustId 
        left join disconstat() d on a.CustId =d.CustId
        left join discon_status_table e on d.type_status = e.statcode
        left join vw_ledger f
        on a.CustId = f.CustId
		left join dd_fDisconnection h
		on a.CustId = h.CustId
		and h.billdate=@billdate
		Inner join Books i
		on c.BookId = i.BookId
		INNER JOIN Zones j
		on a.ZOneId = j.ZoneId
		INNER JOIN Rates k
		on a.RateId = k.RateId
        where isnull(f.[Total Balance],0) > 0 
        and (a.status <> 3)
		and j.Zoneno  like '%' + @zoneno+ '%'
        and h.[fDisconnectionId] is null
        

        begin
        insert dd_svdisconnection(custnum,billdate)
        select distinct b.custnum,billdate from dd_fdisconnection a
        inner join cust b
        on a.CustId = b.CustId  
        inner join vw_ledger c
        on a.CustId = c.CustId
		INNER JOIN Zones d
		on b.ZOneId = d.ZoneId
        where
		billdate = @billdate and d.zoneno  like '%' + @zoneno+ '%'
        and b.custnum not in(select custnum from dd_svdisconnection where billdate = @billdate and d.zoneno  like '%' + @zoneno+ '%')
        and #ofarrears >= 1 and statname is null
        
		end

        begin
        select 
        distinct a.CustId as ID, c.custnum as [Acct #],a.custname as Name,a.RateId as [Rate ID]
		,b.[Statdesc] status,
		a.Remarks,a.balance [Water Balance],a.balance1 [Penalty],
		a.oldarrears [Old Arrears],a.lcabal [LCA/PCA Balance],
		a.balserv [Service Connection],a.sewerage_bal [Sewerage],
		a.[#ofArrears],a.billdate,a.statname
        from dd_fDisconnection a 
		left join custstat b on a.status=b.statcd
		Inner Join Cust c
		on a.CustId = c.CustId
		Inner Join Books d
		on a.BookId = d.BookId
		INNER JOIN Zones e
		on c.ZOneId = e.ZoneId
        where
        
		a.billdate = @billdate and e.zoneno  like '%' + @zoneno+ '%'
        and #ofarrears >=
            case when @arr = '1' then '1' when @arr = '2' then '2' when @arr = '3' then '3' else '0' end
        and #ofarrears <=
            case when @arr = '1' then '1' when @arr = '2' then '2' else '999' end
        and statname is null
        end
    END
END
