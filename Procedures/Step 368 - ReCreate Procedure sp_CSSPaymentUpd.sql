CREATE PROCEDURE [dbo].[sp_CSSPaymentDateUpd]
	-- Add the parameters for the stored procedure here
	@origdate varchar(10),
	@newdate varchar(10),
	@ornum1 varchar(20),
	@ornum2 varchar(20),
	@xuser varchar(100),
	@type varchar(1),
	@subtype bit
AS
BEGIN
	if(@type = 1 and @subtype = 1)--prime with range
	begin
			insert into cpaym_Logs (PymntNum,CustNum,RbillNum,PymntMode,PymntTyp,PymntStat,PayAmnt,Penalty,Subtot1,Subtot2,Subtot3,Subtot4,
								Subtot5,Subtot6,Subtot7,Subtot8,PayDate,PymntDtl,ORNum,RcvdBy,subtot9,oldorno,ntype,capproved,Subtot10,tax1,tax2,Subtot11,DtDate,xuser,remarks)
			Select PymntNum,CustNum,RbillNum,PymntMode,PymntTyp,PymntStat,PayAmnt,Penalty,Subtot1,Subtot2,Subtot3,Subtot4,
								Subtot5,Subtot6,Subtot7,Subtot8,convert(varchar(10),PayDate,111),PymntDtl,ORNum,RcvdBy,subtot9,oldorno,ntype,capproved,Subtot10,tax1,tax2,Subtot11,getdate(),@xuser,'Change Paydate' 
								from Cpaym
								INNER JOIN Cust
								on Cpaym.CustId = Cust.CustId
								where
								ornum >= @ornum1 and ornum<= @ornum2 and convert(varchar(10),paydate,111)=@origdate

			update cpaym set paydate=@newdate ,pymntdtl = '[' + convert(varchar(10),paydate,111) + ']'  where paydate=@origdate and ornum >= @ornum1 and ornum<=@ornum2	
			update pn2 set dtransd=@newdate where convert(varchar(11),dtransd,111)=@origdate and crefno >= (select pymntnum from cpaym where ornum = @ornum1) and crefno<=(select pymntnum from cpaym where ornum = @ornum2)
	end
	else if(@type = 1 and @subtype = 0)--prime no range
	begin
			insert into cpaym_Logs (PymntNum,CustNum,RbillNum,PymntMode,PymntTyp,PymntStat,PayAmnt,Penalty,Subtot1,Subtot2,Subtot3,Subtot4,
								Subtot5,Subtot6,Subtot7,Subtot8,PayDate,PymntDtl,ORNum,RcvdBy,subtot9,oldorno,ntype,capproved,Subtot10,tax1,tax2,Subtot11,DtDate,xuser,remarks)
			Select PymntNum,CustNum,RbillNum,PymntMode,PymntTyp,PymntStat,PayAmnt,Penalty,Subtot1,Subtot2,Subtot3,Subtot4,
								Subtot5,Subtot6,Subtot7,Subtot8,convert(varchar(10),paydate,111),PymntDtl,ORNum,RcvdBy,subtot9,oldorno,ntype,capproved,Subtot10,tax1,tax2,Subtot11,getdate(),@xuser,'Change Paydate' 
								from Cpaym 
								INNER JOIN Cust
								on Cpaym.CustId = Cust.CustId
								where
								convert(varchar(10),paydate,111)=@origdate
								
			update cpaym set paydate=@newdate ,pymntdtl = '[' + convert(varchar(10),paydate,111) + ']'  where convert(varchar(10),paydate,111)=@origdate 
			update pn2 set dtransd=@newdate where convert(varchar(11),dtransd,111)=@origdate
	end
	else if(@type = 2 and @subtype = 1)--wd with range
	begin
			insert into cpaym_Logs (PymntNum,CustNum,RbillNum,PymntMode,PymntTyp,PymntStat,PayAmnt,Penalty,Subtot1,Subtot2,Subtot3,Subtot4,
								Subtot5,Subtot6,Subtot7,Subtot8,PayDate,PymntDtl,ORNum,RcvdBy,subtot9,oldorno,ntype,capproved,Subtot10,tax1,tax2,Subtot11,DtDate,xuser,remarks)
			Select PymntNum,CustNum,RbillNum,PymntMode,PymntTyp,PymntStat,PayAmnt,Penalty,Subtot1,Subtot2,Subtot3,Subtot4,
								Subtot5,Subtot6,Subtot7,Subtot8,convert(varchar(10),paydate,111),PymntDtl,ORNum,RcvdBy,subtot9,oldorno,ntype,capproved,Subtot10,tax1,tax2,Subtot11,getdate(),@xuser,'Change Paydate' 
								from Cpaym 
								INNER JOIN Cust
								on Cpaym.CustId = Cust.CustId
								where
								oldorno >= @ornum1 and oldorno<= @ornum2 and convert(varchar(10),paydate,111)=@origdate

			update cpaym set paydate=@newdate ,pymntdtl = '[' + convert(varchar(10),paydate,111) + ']'  where convert(varchar(10),paydate,111)=@origdate and oldorno >= @ornum1 and oldorno<=@ornum2	
			update pn2 set dtransd=@newdate where convert(varchar(11),dtransd,111)=@origdate and crefno >= (select pymntnum from cpaym where oldorno = @ornum1) and crefno<=(select pymntnum from cpaym where oldorno = @ornum2)
	end
	else if(@type = 2 and @subtype = 1)--wd no range
	begin
			insert into cpaym_Logs (PymntNum,CustNum,RbillNum,PymntMode,PymntTyp,PymntStat,PayAmnt,Penalty,Subtot1,Subtot2,Subtot3,Subtot4,
								Subtot5,Subtot6,Subtot7,Subtot8,PayDate,PymntDtl,ORNum,RcvdBy,subtot9,oldorno,ntype,capproved,Subtot10,tax1,tax2,Subtot11,DtDate,xuser,remarks)
			Select PymntNum,CustNum,RbillNum,PymntMode,PymntTyp,PymntStat,PayAmnt,Penalty,Subtot1,Subtot2,Subtot3,Subtot4,
								Subtot5,Subtot6,Subtot7,Subtot8,convert(varchar(10),paydate,111),PymntDtl,ORNum,RcvdBy,subtot9,oldorno,ntype,capproved,Subtot10,tax1,tax2,Subtot11,getdate(),@xuser,'Change Paydate' 
								from Cpaym 
								INNER JOIN Cust
								on Cpaym.CustId = Cust.CustId
								where
								convert(varchar(10),paydate,111)=@origdate

			update cpaym set paydate=@newdate ,pymntdtl = '[' + convert(varchar(10),paydate,111) + ']'  where convert(varchar(10),paydate,111)=@origdate 
			update pn2 set dtransd=@newdate where convert(varchar(11),dtransd,111)=@origdate
	end
	else if(@type = 3 and @subtype = 1)--app with range
	begin
			update cpaym2 set paydate= @newdate ,pymntdtl = '[' + paydate + ']' where convert(varchar(10),paydate,111)=@origdate and ornum >= @ornum1 and ornum<=@ornum2
	end
	else if(@type = 2 and @subtype = 1)--app no range
	begin
			update cpaym2 set paydate= @newdate ,pymntdtl = '[' + paydate + ']' where convert(varchar(10),paydate,111)=@origdate
	end
END
