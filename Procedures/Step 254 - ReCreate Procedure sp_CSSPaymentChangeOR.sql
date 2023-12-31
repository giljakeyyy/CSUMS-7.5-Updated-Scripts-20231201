ALTER PROCEDURE [dbo].[sp_CSSPaymentChageOR]
	-- Add the parameters for the stored procedure here
	@PymntNum numeric(18),	
	@xuser varchar(100),
	@Remarks varchar(100),
	@ornum varchar(10),
	@temp int
AS
BEGIN
	
	Declare @FOrnum varchar(20)

	insert into cpaym_Logs 
	(
		PymntNum,CustNum,RbillNum,PymntMode,PymntTyp,PymntStat,PayAmnt,Penalty,Subtot1,Subtot2,Subtot3,Subtot4,
		Subtot5,Subtot6,Subtot7,Subtot8,PayDate,PymntDtl,ORNum,RcvdBy,subtot9,oldorno,ntype,capproved,Subtot10,tax1,tax2,Subtot11,DtDate,xuser,remarks
	)
	Select PymntNum,Cust.CustNum,RbillNum,PymntMode,PymntTyp,PymntStat,PayAmnt,Penalty,Subtot1,Subtot2,Subtot3,Subtot4,
	Subtot5,Subtot6,Subtot7,Subtot8,PayDate,PymntDtl,ORNum,RcvdBy,subtot9,oldorno,ntype,capproved,Subtot10,tax1,tax2,Subtot11,getdate(),@xuser,@Remarks 
	from Cpaym 
	INNER JOIN Cust
	on Cpaym.CustId = Cust.CustId
	where pymntnum=@PymntNum	

	set @FOrnum = (select case when len(ornum)= 0 then oldorno else ornum end as ornum from cpaym where pymntnum = @PymntNum)
	
	if (@temp=0)
	begin
		update  Cpaym set ornum=@ornum where pymntnum=@PymntNum	
		--update pn2 set crefno=@ornum where crefno =  @FOrnum
	end
	if (@temp=1)
	begin
		update  Cpaym set oldorno=@ornum where pymntnum=@PymntNum	
		--update pn2 set crefno=@ornum where crefno =  @FOrnum
	end
END
