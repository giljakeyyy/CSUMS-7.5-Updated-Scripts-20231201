ALTER PROCEDURE [dbo].[jva_currcol](@billdate1 varchar(7),@param1 varchar(100),@param2 varchar(100) = '')
	-- Add the parameters for the stored procedure here
	
AS
BEGIN

declare @billdate varchar(7)
set @billdate = replace(@billdate1,'-','/');
declare @param varchar(200)
declare @paramapps varchar(200);
set @param = @param1 + '+isnull(Subtot13,0)+isnull(Subtot14,0)+isnull(pn_amount,0)';
set @paramapps = @param2;						 
DECLARE @cols AS NVARCHAR(MAX),
    @query  AS NVARCHAR(MAX)


select @cols = STUFF((SELECT ',' + QUOTENAME(cpaycenter) 
                    from payment_center 												
                    order by pymntmode
            FOR XML PATH(''), TYPE
            ).value('.', 'NVARCHAR(MAX)') 
        ,1,1,'') 	

IF(rtrim(ltrim(@param1)) <> '' and rtrim(ltrim(@param2)) <> '')
BEGIN 
set @query = N'SELECT CONVERT(VARCHAR(10),paydate,111) as paydate, ' + @cols + N' from 
             (
                select 
				a.paydate,sum(' + @param + ') payamnt,cpaycenter
                from cpaym a left join payment_center b on a.pymntmode = b.pymntmode
				where convert(varchar(7),a.paydate,111) = '''+@billdate+'''
				group by a.paydate, b.cpaycenter	

				UNION ALL
				
                select 
				cpaym2.paydate,sum(' + @param2 + ') payamnt,cpaycenter
                from cpaym2 left join payment_center b on cpaym2.pymntmode = b.pymntmode
				where left(cpaym2.paydate,7) = '''+@billdate+'''
				group by cpaym2.paydate, b.cpaycenter						  
            ) x
            pivot 
            (
                max(payamnt)
                for cpaycenter in (' + @cols + N')
            ) p order by CONVERT(VARCHAR(10),paydate,111)';
END
ELSE IF(rtrim(ltrim(@param1)) <> '')
BEGIN   
	set @query = N'SELECT CONVERT(VARCHAR(10),paydate,111) as paydate, ' + @cols + N' from 
             (
                select 
				a.paydate,sum(' + @param + ') payamnt,cpaycenter
                from cpaym a left join payment_center b on a.pymntmode = b.pymntmode
				where convert(varchar(7),a.paydate,111) = '''+@billdate+'''
				group by a.paydate, b.cpaycenter						  
            ) x
            pivot 
            (
                max(payamnt)
                for cpaycenter in (' + @cols + N')
            ) p order by CONVERT(VARCHAR(10),paydate,111)';
END
ELSE IF(rtrim(ltrim(@param2)) <> '')
BEGIN				
	set @query = N'SELECT CONVERT(VARCHAR(10),paydate,111) as paydate, ' + @cols + N' from 
            (
                select 
				cpaym2.paydate,sum(' + @param2 + ') payamnt,cpaycenter
                from cpaym2 left join payment_center b on cpaym2.pymntmode = b.pymntmode
				where left(cpaym2.paydate,7) = '''+@billdate+'''
				group by cpaym2.paydate, b.cpaycenter						  
            ) x
            pivot 
            (
                max(payamnt)
                for cpaycenter in (' + @cols + N')
            ) p order by CONVERT(VARCHAR(10),paydate,111)';		
END
	
			
exec sp_executesql @query;


 
END


