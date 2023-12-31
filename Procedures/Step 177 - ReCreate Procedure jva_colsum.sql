ALTER PROCEDURE [dbo].[jva_colsum]
(
	-- Add the parameters for the stored procedure here
	@billdate1 varchar(7),
	@param1 varchar(100)
)
AS
BEGIN
    DECLARE @cols AS NVARCHAR(MAX),
        @query  AS NVARCHAR(MAX),
        @billdate as varchar(7),
        @param varchar(100)

    set @param = @param1

    set @billdate = @billdate1
    select @cols = STUFF((SELECT ',' + QUOTENAME(cpaycenter)
                    from payment_center
                    order by pymntmode
            FOR XML PATH(''), TYPE
            ).value('.', 'NVARCHAR(MAX)') 
        ,1,1,'') 	
	

    set @query = N'SELECT zoneno,zonename, ' + @cols + N' from 
            (
                select 
				d.zoneno,d.zonename,cast(sum(' + @param + ') as decimal(18,2)) payamnt,cpaycenter
                from cpaym a 
				INNER JOIN payment_center b on a.pymntmode = b.pymntmode
				INNER JOIN cust c on a.CustId = c.CustId
				INNER JOIN zones d on d.ZoneId = c.ZoneId
				where left(a.paydate,7) = '''+@billdate+'''
					group by d.zoneno,d.zonename,b.cpaycenter
            ) x
            pivot 
            (
                max(payamnt)
                for cpaycenter in (' + @cols + N')
            ) p order by zoneno '

    exec sp_executesql @query;
END
