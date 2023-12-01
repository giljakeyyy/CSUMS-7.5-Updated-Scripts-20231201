CREATE VIEW [dbo].[vw_Cust]
WITH SCHEMABINDING
AS
Select 'Water' as [Contract],f.bookno,g.zoneno,a.CustId,a.custnum [Customer No.],a.cbank_ref [ATM Bankref],a.custname [Account Name] 
             ,C.RateCd,c.ratename [Classification],c.RGroupid,d.statdesc [Status],a.status as [StatVal],b.seqno [Sequence #]
			 ,b.meterno1 [Meter No.],b.Mtype1,b.pread1 [Last Reading],
             a.BilstAdd [Bill St. Address],a.BilctAdd as [Bill Ct. Address]
             ,a.[ccelnumber],

             isnull(a.billnum,'-') [Posted Bill Number],a.lastpaydate [Posted Payment date],
             isnull(a.PNoteNo,'-') [Last PN #],isnull(a.PnoteAmt,'-') [Last PN Payment],a.PnoteDate [Last PN Payment Date]
             ,a.oldcustnum [Old Customer #]
             ,convert(varchar(10),a.seniordate,111) [Senior Date] 
             ,a.ctc [TCT No.]
             , a.[brgyid]
			 ,isnull(a.isWriteOff,0) as isWriteOff
             FROM dbo.cust a 
			 INNER JOIN dbo.members b 
			 on a.CustId = b.CustId
             INNER JOIN dbo.rates c 
			 on c.RateId = a.RateId
             INNER JOIN dbo.custstat d 
			 on d.statcd = a.status
             INNER JOIN dbo.rategroup e 
			 on c.rgroupid = e.rgroupid 
			 INNER JOIN dbo.Books f
			 on b.BookId = f.BookId
			 INNER JOIN dbo.Zones g
			 on a.ZoneId = g.ZoneId


GO


