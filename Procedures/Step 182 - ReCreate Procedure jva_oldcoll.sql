ALTER PROCEDURE [dbo].[jva_oldcoll](@billdate1 varchar(7))
	
AS
BEGIN

	declare @param varchar(200)
	set @param = 'isnull(Subtot9,0)+isnull(rprocfee,0)'
	DECLARE @cols AS NVARCHAR(MAX),@query  AS NVARCHAR(MAX)


	select @cols = STUFF((SELECT ',' + QUOTENAME(cpaycenter) 
						from payment_center 												
						order by pymntmode
				FOR XML PATH(''), TYPE
				).value('.', 'NVARCHAR(MAX)') 
			,1,1,'') 	

	set @query = N'SELECT paydate, ' + @cols + N' from 
				 (
					select 
					paydate,isnull(sum(' + @param + '),0.00) payamnt,cpaycenter
					from cpaym a left join payment_center b on a.pymntmode = b.pymntmode
					where left(paydate,7) = '''+@billdate1+'''
						group by paydate, b.cpaycenter					
				) x
				pivot 
				(
					max(payamnt)
					for cpaycenter in (' + @cols + N')
				) p order by paydate '
	
			
	exec sp_executesql @query;


 
END




