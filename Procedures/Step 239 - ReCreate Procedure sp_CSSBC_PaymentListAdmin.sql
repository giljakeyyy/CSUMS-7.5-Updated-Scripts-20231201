ALTER PROCEDURE [dbo].[sp_CSSBC_PaymentListAdmin]
	-- Add the parameters for the stored procedure here
	@Custnum varchar(20),
	@mode varchar(1)	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	IF(@mode = '1')
	BEGIN
		Select 
		subtot1=isnull(a.subtot1,0),
		subtot2=isnull(a.subtot2,0),
		subtot3=isnull(a.subtot3,0),
		subtot4=isnull(a.subtot4,0),
		subtot5=isnull(a.subtot5,0),
		subtot6=isnull(a.subtot6,0),
		subtot7=isnull(a.subtot7,0),
		subtot8=isnull(a.subtot8,0),
		subtot9=isnull(a.subtot9,0),
		subtot10=isnull(a.subtot10,0),
		subtot11=isnull(subtot11,0),
		subtot12=isnull(subtot12,0) + isnull(subtot13,0) + isnull(subtot14,0),
		b.custname,c.cpaycenter,'PStatus'= 
		case when pymntstat='1' then 'New' else 'Posted' end, 
		'ptype' = case when pymnttyp='1' then 'Cash' else 'Check' end ,
		a.pn_amount as amount,a.rrecfee,a.rwaterm,a.rpenfee,a.rservdep,a.rprocfee,a.rinsfee,a.rtechfee,a.rwatfee,
		b.custnum,PymntNum,CustName,a.PayAmnt,a.ORNum,a.RcvdBy,a.PymntDtl,a.oldorno,a.rbillnum ,a.paydate
		FROM Cpaym a 
		INNER JOIN Cust b 
		on a.CustId=b.CustId 
		INNER JOIN payment_center c 
		on a.pymntmode=c.pymntmode 
		WHERE b.CustNum=@custnum
		and a.PymntStat <> 2
	END
	ELSE IF (@mode='2')
	BEGIN
		Select 
		subtot1=isnull(a.subtot1,0),
		subtot2=isnull(a.subtot2,0)-isnull(a.pn_amount,0),
		subtot3=isnull(a.subtot3,0),
		subtot4=isnull(a.subtot4,0),
		subtot5=isnull(a.subtot5,0),
		subtot6=isnull(a.subtot6,0),
		subtot7=isnull(a.subtot7,0),
		subtot8=isnull(a.subtot8,0),
		subtot9=isnull(a.subtot9,0),
		subtot10=isnull(a.subtot10,0),
		subtot11=isnull(subtot11,0),
		subtot12=isnull(subtot12,0) + isnull(subtot13,0) + isnull(subtot14,0),
		b.custname,c.cpaycenter,'PStatus'= 
		case when pymntstat='1' then 'New' else 'Posted' end, 
		'ptype' = case when pymnttyp='1' then 'Cash' else 'Check' end ,
		a.Pn_amount as amount,a.rrecfee,a.rwaterm,a.rpenfee,a.rservdep,a.rprocfee,a.rinsfee,a.rtechfee,a.rwatfee,
		b.custnum,PymntNum,CustName,a.PayAmnt,a.ORNum,a.RcvdBy,a.PymntDtl,a.oldorno,a.rbillnum ,a.paydate
		FROM Cpaym a 
		INNER JOIN Cust b 
		on a.CustId=b.CustId 
		INNER JOIN payment_center c 
		on a.pymntmode=c.pymntmode 
		WHERE a.ornum = @custnum
		and a.PymntStat <> 2
	END
	ELSE IF(@mode='3')
	BEGIN
		Select 
		subtot1=isnull(a.subtot1,0),
		subtot2=isnull(a.subtot2,0),
		subtot3=isnull(a.subtot3,0),
		subtot4=isnull(a.subtot4,0),
		subtot5=isnull(a.subtot5,0),
		subtot6=isnull(a.subtot6,0),
		subtot7=isnull(a.subtot7,0),
		subtot8=isnull(a.subtot8,0),
		subtot9=isnull(a.subtot9,0),
		subtot10=isnull(a.subtot10,0),
		subtot11=isnull(subtot11,0),
		subtot12=isnull(subtot12,0) + isnull(subtot13,0) + isnull(subtot14,0),
		b.custname,c.cpaycenter,'PStatus'= 
		case when pymntstat='1' then 'New' else 'Posted' end, 
		'ptype' = case when pymnttyp='1' then 'Cash' else 'Check' end ,
		a.pn_amount as amount,a.rrecfee,a.rwaterm,a.rpenfee,a.rservdep,a.rprocfee,a.rinsfee,a.rtechfee,a.rwatfee,
		b.custnum,PymntNum,CustName,a.PayAmnt,a.ORNum,a.RcvdBy,a.PymntDtl,a.oldorno,a.rbillnum,a.paydate
		FROM Cpaym a 
		INNER JOIN Cust b 
		on a.CustId=b.CustId 
		INNER JOIN payment_center c 
		on a.pymntmode=c.pymntmode 
		WHERE a.oldorno = @custnum
		and a.PymntStat <> 2
	END
END
