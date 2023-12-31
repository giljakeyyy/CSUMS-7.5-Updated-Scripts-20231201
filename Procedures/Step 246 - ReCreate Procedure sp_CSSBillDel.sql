ALTER PROCEDURE [dbo].[sp_CSSBillDel]
	-- Add the parameters for the stored procedure here
	@Billnum int,
	@Xuser varchar(100)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    insert into Cbill_Logs (Custnum,subtot1,subtot2,subtot3,subtot4,subtot5,BillAmnt,Billdate,Duedate,Dtdate,xuser,commandType)
	Select b.Custnum,subtot1,subtot2,subtot3,subtot4,subtot5,BillAmnt,Billdate,a.Duedate,getdate(),@Xuser,'DELETE' 
	from Cbill a
	INNER JOIN Cust b
	on a.CustId = b.CustId
	where a.billnum=@Billnum;
		
	Delete from tbill where billnum=@billnum;
	Delete from cbill where billnum=@billnum;	
	
END

