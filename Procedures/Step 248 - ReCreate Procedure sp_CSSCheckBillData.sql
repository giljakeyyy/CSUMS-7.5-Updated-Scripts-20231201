ALTER PROCEDURE [dbo].[sp_CSSCheckBillData]
	-- Add the parameters for the stored procedure here
	@billdate varchar(7),
	@BookId int
AS
BEGIN



	select d.bookno,c.custnum,a.nbasic,c.oldcustnum,c.custname
	FROM Rhist a
	LEFT JOIN cbill b 
	on a.RhistId = b.RhistId	
	INNER JOIN Cust c 
	on a.CustId = c.CustId 
	INNER JOIN Books d
	on a.BookId = d.BookId
	where a.billdate=@billdate and a.BookId=@BookId and nbasic>=0  
	and c.[status] = '1'
	and b.BillNum is null 
	order by c.custnum
						 
 
END
