CREATE VIEW [dbo].[vw_CheckBilledByBookByBilldate]
AS

Select a.billdate,b.BookId,count(a.billnum) as [CTR]
from cbill a
inner join rhist b
on a.RhistId = b.RhistId
inner join Books c
on b.BookId = c.BookId
group by a.billdate,b.BookId