ALTER PROCEDURE [dbo].[sp_CSSPaymentModeUpd]
	-- Add the parameters for the stored procedure here
	@newmode varchar(10),
	@Pymntnum int,
	@xuser varchar(100),	
	@subtype bit
AS
BEGIN


	IF(@subtype=1)
	BEGIN
		insert into cpaym_modehist 
		(
			PymntNum,CustNum,RbillNum,PymntMode,PymntTyp,PymntStat,PayAmnt,Penalty,Subtot1,Subtot2,
			Subtot3,Subtot4,Subtot5,Subtot6,Subtot7,Subtot8,PayDate,PymntDtl,ORNum,RcvdBy,Xuser
		)
		Select PymntNum,Cust.CustNum,RbillNum,PymntMode,PymntTyp,PymntStat,PayAmnt,Penalty,Subtot1,Subtot2,
		Subtot3,Subtot4,Subtot5,Subtot6,Subtot7,Subtot8,PayDate,PymntDtl + Convert(varchar(11),getdate(),111),
		ORNum,RcvdBy,@xuser 
		from cpaym
		INNER JOIN Cust
		on Cpaym.CustId = Cust.CustId
		where PymntNum = @Pymntnum


		update Cpaym 
		set pymntmode=@newmode  
		where PymntNum = @Pymntnum

		update pn2 set pymntmode = @newmode
		From PN2
		INNER JOIN Cpaym
		on PN2.crefno = convert(varchar(100),Cpaym.PymntNum)
		and convert(varchar(11),dtransd,111) = Cpaym.PayDate
		and PN2.CPnno = Cpaym.pnno
		Where Cpaym.PymntNum = @Pymntnum					
									 
	END
	ELSE	
	BEGIN
		insert into cpaym_modehist (PymntNum,CustNum,RbillNum,PymntMode,PymntTyp,PymntStat,PayAmnt,Penalty,Subtot1,Subtot2,
		Subtot3,Subtot4,Subtot5,Subtot6,Subtot7,Subtot8,PayDate,PymntDtl,ORNum,RcvdBy,Xuser)
		Select PymntNum,CustNum,RbillNum,PymntMode,PymntTyp,PymntStat,PayAmnt,Penalty,Subtot1,Subtot2,
		Subtot3,Subtot4,Subtot5,Subtot6,Subtot7,Subtot8,PayDate,PymntDtl + Convert(varchar(11),getdate(),111),
		ORNum,RcvdBy,@xuser
		from cpaym
		INNER JOIN Cust
		on Cpaym.CustId = Cust.CustId
		Where Cpaym.PymntNum = @Pymntnum

		update cpaym set pymntmode=@newmode
		Where Cpaym.PymntNum = @Pymntnum

		update pn2 set pymntmode = @newmode
		From PN2
		INNER JOIN Cpaym
		on PN2.crefno = convert(varchar(100),Cpaym.PymntNum)
		and convert(varchar(11),dtransd,111) = Cpaym.PayDate
		and PN2.CPnno = Cpaym.pnno
		Where Cpaym.PymntNum = @Pymntnum	

	END
	
	


END

