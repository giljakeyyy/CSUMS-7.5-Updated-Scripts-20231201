ALTER PROCEDURE [dbo].[AgingBooks]
	-- Add the parameters for the stored procedure here
	@year varchar(4),
	@month varchar(2),
	@custnum varchar(20),
	@custname varchar(30),
	@stat varchar(2),
	@stat1 varchar(2),
	@stat2 varchar(2),
	@stat3 varchar(2)
	
AS
BEGIN

begin
IF OBJECT_ID('dbo.custage', 'U') IS NOT NULL
  DROP TABLE custage; 
end
begin	

select f.bookno,f.area,sum(d.totalarrears) totalarrears,
sum([1-30]) as [1-30]
,sum([31-60]) [31-60],
sum([61-90])[61-90],
sum([91-120])[91-120],
sum([121-150])[121-150],
sum([151-180])[151-180],
sum([181-210])[181-210],
sum([211-240])[211-240],
sum([241-270])[241-270],
sum([271-300])[271-300],
sum([301-330])[301-330],
sum([331-360])[331-360],
sum([1yr-2yrs])[1yr-2yrs],sum([over2yrs])[over2yrs] into custage from(
select zoneno,BookId,status,custnum,custname,balance as totalarrears,
case when [1-30] > 0 and  [31-60]+[61-90]+[91-120]+[121-150]+[151-180]+[181-210]+[211-240]+[241-270]+[271-300]+[301-330]+[331-360]+[1yr-2yrs]+over2yrs = 0 then
[1-30]+ total
else
[1-30]
end as [1-30],
case when [31-60] > 0 and [61-90]+[91-120]+[121-150]+[151-180]+[181-210]+[211-240]+[241-270]+[271-300]+[301-330]+[331-360]+[1yr-2yrs]+over2yrs  = 0 then
 [31-60]+ total
else
[31-60]
end as [31-60],
case when [61-90] > 0 and [91-120]+[121-150]+[151-180]+[181-210]+[211-240]+[241-270]+[271-300]+[301-330]+[331-360]+[1yr-2yrs]+over2yrs = 0 then
[61-90] + total
else
[61-90]
end as [61-90],
case when [91-120] > 0 and [121-150]+[151-180]+[181-210]+[211-240]+[241-270]+[271-300]+[301-330]+[331-360]+[1yr-2yrs]+over2yrs= 0 then
[91-120] + total
else
[91-120]
end as [91-120],
case when [121-150] > 0 and [151-180]+[181-210]+[211-240]+[241-270]+[271-300]+[301-330]+[331-360]+[1yr-2yrs]+over2yrs = 0 then
[121-150] + total
else
[121-150]
end as [121-150],
case when [151-180] > 0 and [181-210]+[211-240]+[241-270]+[271-300]+[301-330]+[331-360]+[1yr-2yrs]+over2yrs = 0 then
[151-180] + total
else
[151-180]
end as [151-180],
case when [181-210] > 0 and [211-240]+[241-270]+[271-300]+[301-330]+[331-360]+[1yr-2yrs]+over2yrs = 0 then
[181-210] + total
else
[181-210]
end as [181-210],

case when [211-240] > 0 and [241-270]+[271-300]+[301-330]+[331-360]+[1yr-2yrs]+over2yrs = 0 then
[211-240] + total
else
[211-240]
end as [211-240],

case when [241-270] > 0 and [271-300]+[301-330]+[331-360]+[1yr-2yrs]+over2yrs = 0 then
[241-270] + total
else
[241-270]
end as [241-270],

case when [271-300] > 0 and [301-330]+[331-360]+[1yr-2yrs]+over2yrs = 0 then
[271-300] + total
else
[271-300]
end as [271-300],

case when [301-330] > 0 and [331-360]+[1yr-2yrs]+over2yrs = 0 then
[301-330] + total
else
[301-330]
end as [301-330],

case when [331-360] > 0 and [1yr-2yrs]+over2yrs = 0 then
[331-360] + total
else
[331-360]
end as [331-360],

case when [1yr-2yrs] > 0 and over2yrs = 0 then
[1yr-2yrs] + total
else
[1yr-2yrs]
end as [1yr-2yrs],
case when over2yrs > 0 then
over2yrs + total
else
over2yrs
end as over2yrs

 from( 
select 
*,balance - ([1-30]+[31-60]+[61-90]+[91-120]+[121-150]+[151-180]+[181-210]+[211-240]+[241-270]+[271-300]+[301-330]+[331-360]+[1yr-2yrs]+over2yrs)  Total

from(
select custnum,custname,balance,BookId,zoneno,status,
case when balance >= sum(isnull([1-30],0)) then
sum(isnull([1-30],0))
when
 balance < sum(isnull([1-30],0)) 
then
 balance
else
0
end as [1-30],

case when balance >= sum(isnull([1-30],0)) + sum(isnull([31-60],0)) then
sum(isnull([31-60],0))
when
 balance > sum(isnull([1-30],0)) 
 and
 balance < sum(isnull([1-30],0)) + sum(isnull([31-60],0))
 and sum(isnull([31-60],0)) > 0
then
(balance - sum(isnull([1-30],0))) 

else
0
end as [31-60],

case when balance >= sum(isnull([1-30],0)) + sum(isnull([31-60],0)) + sum(isnull([61-90],0)) then
sum(isnull([61-90],0))
when
 balance > sum(isnull([1-30],0)) + sum(isnull([31-60],0)) 
 and
 balance < sum(isnull([1-30],0)) + sum(isnull([31-60],0)) + sum(isnull([61-90],0))
 and
 sum(isnull([61-90],0)) > 0
then
balance - sum(isnull([1-30],0)) - sum(isnull([31-60],0))
else 0
end as [61-90],

case when balance >= sum(isnull([1-30],0)) + sum(isnull([31-60],0)) + sum(isnull([61-90],0)) + sum(isnull([91-120],0)) then
sum(isnull([91-120],0))
when
 balance > sum(isnull([1-30],0)) + sum(isnull([31-60],0)) + sum(isnull([61-90],0)) 
 and
 balance < sum(isnull([1-30],0)) + sum(isnull([31-60],0)) + sum(isnull([61-90],0)) + sum(isnull([91-120],0)) 
 and
 sum(isnull([91-120],0)) > 0
then
balance - sum(isnull([1-30],0)) - sum(isnull([31-60],0)) - sum(isnull([61-90],0)) 
else 0
end as [91-120],

case when balance >= sum(isnull([1-30],0)) + sum(isnull([31-60],0)) + sum(isnull([61-90],0)) + sum(isnull([91-120],0))+  sum(isnull([121-150],0)) then
sum(isnull([121-150],0))
when
 balance > sum(isnull([1-30],0)) + sum(isnull([31-60],0)) + sum(isnull([61-90],0)) + sum(isnull([91-120],0))
 and
 balance < sum(isnull([1-30],0)) + sum(isnull([31-60],0)) + sum(isnull([61-90],0)) + sum(isnull([91-120],0)) +  sum(isnull([121-150],0))
 and 
 sum(isnull([121-150],0)) > 0
then
balance - sum(isnull([1-30],0)) - sum(isnull([31-60],0)) - sum(isnull([61-90],0)) - sum(isnull([91-120],0))
else 0
end as [121-150],

case when balance >= sum(isnull([1-30],0)) + sum(isnull([31-60],0)) + sum(isnull([61-90],0)) + sum(isnull([91-120],0))+  sum(isnull([121-150],0)) +sum(isnull([151-180],0)) then
sum(isnull([151-180],0)) 
when
 balance > sum(isnull([1-30],0)) + sum(isnull([31-60],0)) + sum(isnull([61-90],0)) + sum(isnull([91-120],0)) +  sum(isnull([121-150],0))
 and
 balance < sum(isnull([1-30],0)) + sum(isnull([31-60],0)) + sum(isnull([61-90],0)) + sum(isnull([91-120],0)) +  sum(isnull([121-150],0))+sum(isnull([151-180],0)) 
 and
 sum(isnull([151-180],0))  >0
then
balance - sum(isnull([1-30],0)) - sum(isnull([31-60],0)) - sum(isnull([61-90],0)) - sum(isnull([91-120],0)) -  sum(isnull([121-150],0)) 
else 0
end as [151-180],

case when balance >= sum(isnull([1-30],0)) + sum(isnull([31-60],0)) + sum(isnull([61-90],0)) + sum(isnull([91-120],0))+  sum(isnull([121-150],0)) +sum(isnull([151-180],0)) +sum(isnull([181-210],0)) then
sum(isnull([181-210],0)) 
when
 balance > sum(isnull([1-30],0)) + sum(isnull([31-60],0)) + sum(isnull([61-90],0)) + sum(isnull([91-120],0)) +  sum(isnull([121-150],0)) +sum(isnull([151-180],0))
 and
 balance < sum(isnull([1-30],0)) + sum(isnull([31-60],0)) + sum(isnull([61-90],0)) + sum(isnull([91-120],0)) +  sum(isnull([121-150],0))+sum(isnull([151-180],0))  +sum(isnull([181-210],0))
 and
sum(isnull([181-210],0)) >0
then
balance - sum(isnull([1-30],0)) - sum(isnull([31-60],0)) - sum(isnull([61-90],0)) - sum(isnull([91-120],0)) -  sum(isnull([121-150],0)) -  sum(isnull([151-180],0))
else 0
end as [181-210],

case when balance >= sum(isnull([1-30],0)) + sum(isnull([31-60],0)) + sum(isnull([61-90],0)) + sum(isnull([91-120],0))+  sum(isnull([121-150],0)) +sum(isnull([151-180],0)) +sum(isnull([181-210],0)) +sum(isnull([211-240],0)) then
sum(isnull([211-240],0))  
when
 balance > sum(isnull([1-30],0)) + sum(isnull([31-60],0)) + sum(isnull([61-90],0)) + sum(isnull([91-120],0)) +  sum(isnull([121-150],0)) +sum(isnull([151-180],0))+sum(isnull([181-210],0))
 and
 balance < sum(isnull([1-30],0)) + sum(isnull([31-60],0)) + sum(isnull([61-90],0)) + sum(isnull([91-120],0)) +  sum(isnull([121-150],0))+sum(isnull([151-180],0))  +sum(isnull([181-210],0)) +sum(isnull([211-240],0))
 and
sum(isnull([211-240],0)) >0
then
balance - sum(isnull([1-30],0)) - sum(isnull([31-60],0)) - sum(isnull([61-90],0)) - sum(isnull([91-120],0)) -  sum(isnull([121-150],0)) -  sum(isnull([151-180],0)) -sum(isnull([181-210],0))
else 0
end as [211-240],

case when balance >= sum(isnull([1-30],0)) + sum(isnull([31-60],0)) + sum(isnull([61-90],0)) + sum(isnull([91-120],0))+  sum(isnull([121-150],0)) +sum(isnull([151-180],0)) +sum(isnull([181-210],0)) +sum(isnull([211-240],0))   +sum(isnull([241-270],0))then
sum(isnull([241-270],0))
when
 balance > sum(isnull([1-30],0)) + sum(isnull([31-60],0)) + sum(isnull([61-90],0)) + sum(isnull([91-120],0)) +  sum(isnull([121-150],0)) +sum(isnull([151-180],0))+sum(isnull([181-210],0)) +sum(isnull([211-240],0)) 
 and
 balance < sum(isnull([1-30],0)) + sum(isnull([31-60],0)) + sum(isnull([61-90],0)) + sum(isnull([91-120],0)) +  sum(isnull([121-150],0))+sum(isnull([151-180],0))  +sum(isnull([181-210],0)) +sum(isnull([211-240],0))+sum(isnull([241-270],0))
 and
sum(isnull([241-270],0)) >0
then
balance - sum(isnull([1-30],0)) - sum(isnull([31-60],0)) - sum(isnull([61-90],0)) - sum(isnull([91-120],0)) -  sum(isnull([121-150],0)) - sum(isnull([151-180],0)) -sum(isnull([181-210],0))-sum(isnull([211-240],0))
else 0
end as [241-270],

case when balance >= sum(isnull([1-30],0)) + sum(isnull([31-60],0)) + sum(isnull([61-90],0)) + sum(isnull([91-120],0))+  sum(isnull([121-150],0)) +sum(isnull([151-180],0)) +sum(isnull([181-210],0)) +sum(isnull([211-240],0))   +sum(isnull([241-270],0)) +sum(isnull([271-300],0))then
sum(isnull([271-300],0))
when
 balance > sum(isnull([1-30],0)) + sum(isnull([31-60],0)) + sum(isnull([61-90],0)) + sum(isnull([91-120],0)) +  sum(isnull([121-150],0)) +sum(isnull([151-180],0))+sum(isnull([181-210],0)) +sum(isnull([211-240],0))  +sum(isnull([241-270],0))
 and
 balance < sum(isnull([1-30],0)) + sum(isnull([31-60],0)) + sum(isnull([61-90],0)) + sum(isnull([91-120],0)) +  sum(isnull([121-150],0))+sum(isnull([151-180],0))  +sum(isnull([181-210],0)) +sum(isnull([211-240],0))+sum(isnull([241-270],0))+sum(isnull([271-300],0))
 and
sum(isnull([271-300],0)) >0
then
balance - sum(isnull([1-30],0)) - sum(isnull([31-60],0)) - sum(isnull([61-90],0)) - sum(isnull([91-120],0)) -  sum(isnull([121-150],0)) - sum(isnull([151-180],0)) -sum(isnull([181-210],0))-sum(isnull([211-240],0))-sum(isnull([241-270],0))
else 0
end as [271-300],

case when balance >= sum(isnull([1-30],0)) + sum(isnull([31-60],0)) + sum(isnull([61-90],0)) + sum(isnull([91-120],0))+  sum(isnull([121-150],0)) +sum(isnull([151-180],0)) +sum(isnull([181-210],0)) +sum(isnull([211-240],0))   +sum(isnull([241-270],0)) +sum(isnull([271-300],0))+sum(isnull([301-330],0))then
sum(isnull([301-330],0))
when
 balance > sum(isnull([1-30],0)) + sum(isnull([31-60],0)) + sum(isnull([61-90],0)) + sum(isnull([91-120],0)) +  sum(isnull([121-150],0)) +sum(isnull([151-180],0))+sum(isnull([181-210],0)) +sum(isnull([211-240],0))  +sum(isnull([241-270],0))+sum(isnull([271-300],0))
 and
 balance < sum(isnull([1-30],0)) + sum(isnull([31-60],0)) + sum(isnull([61-90],0)) + sum(isnull([91-120],0)) +  sum(isnull([121-150],0))+sum(isnull([151-180],0))  +sum(isnull([181-210],0)) +sum(isnull([211-240],0))+sum(isnull([241-270],0))+sum(isnull([271-300],0))+sum(isnull([301-330],0))
 and
sum(isnull([301-330],0)) >0
then
balance - sum(isnull([1-30],0)) - sum(isnull([31-60],0)) - sum(isnull([61-90],0)) - sum(isnull([91-120],0)) -  sum(isnull([121-150],0)) -sum(isnull([151-180],0))  -sum(isnull([181-210],0))-sum(isnull([211-240],0))-sum(isnull([241-270],0))-sum(isnull([271-300],0))
else 0
end as [301-330],

case when balance >= sum(isnull([1-30],0)) + sum(isnull([31-60],0)) + sum(isnull([61-90],0)) + sum(isnull([91-120],0))+  sum(isnull([121-150],0)) +sum(isnull([151-180],0)) +sum(isnull([181-210],0)) +sum(isnull([211-240],0))   +sum(isnull([241-270],0)) +sum(isnull([271-300],0))+sum(isnull([301-330],0))+sum(isnull([331-360],0))then
sum(isnull([331-360],0))
when
 balance > sum(isnull([1-30],0)) + sum(isnull([31-60],0)) + sum(isnull([61-90],0)) + sum(isnull([91-120],0)) +  sum(isnull([121-150],0)) +sum(isnull([151-180],0))+sum(isnull([181-210],0)) +sum(isnull([211-240],0))  +sum(isnull([241-270],0))+sum(isnull([271-300],0))+sum(isnull([301-330],0))
 and
 balance < sum(isnull([1-30],0)) + sum(isnull([31-60],0)) + sum(isnull([61-90],0)) + sum(isnull([91-120],0)) +  sum(isnull([121-150],0))+sum(isnull([151-180],0))  +sum(isnull([181-210],0)) +sum(isnull([211-240],0))+sum(isnull([241-270],0))+sum(isnull([271-300],0))+sum(isnull([301-330],0))+sum(isnull([331-360],0))
 and
sum(isnull([331-360],0)) >0
then
balance - sum(isnull([1-30],0)) - sum(isnull([31-60],0)) - sum(isnull([61-90],0)) - sum(isnull([91-120],0)) -  sum(isnull([121-150],0))  - sum(isnull([151-180],0)) -sum(isnull([181-210],0))-sum(isnull([211-240],0))-sum(isnull([241-270],0))-sum(isnull([271-300],0))-sum(isnull([301-330],0))
else 0
end as [331-360],



case when balance >= sum(isnull([1-30],0)) + sum(isnull([31-60],0)) + sum(isnull([61-90],0)) + sum(isnull([91-120],0))+  sum(isnull([121-150],0)) +sum(isnull([151-180],0))  +sum(isnull([181-210],0)) +sum(isnull([211-240],0))   +sum(isnull([241-270],0)) +sum(isnull([271-300],0))+sum(isnull([301-330],0))+sum(isnull([331-360],0)) + sum(isnull([1yr-2yrs],0)) 
then
 sum(isnull([1yr-2yrs],0))

when
 balance > sum(isnull([1-30],0)) + sum(isnull([31-60],0)) + sum(isnull([61-90],0)) + sum(isnull([91-120],0)) +  sum(isnull([121-150],0))+sum(isnull([151-180],0))  +sum(isnull([181-210],0)) +sum(isnull([211-240],0))   +sum(isnull([241-270],0)) +sum(isnull([271-300],0))+sum(isnull([301-330],0))+sum(isnull([331-360],0))
 and
 balance < sum(isnull([1-30],0)) + sum(isnull([31-60],0)) + sum(isnull([61-90],0)) + sum(isnull([91-120],0)) +  sum(isnull([121-150],0))+sum(isnull([151-180],0))  +sum(isnull([181-210],0)) +sum(isnull([211-240],0))   +sum(isnull([241-270],0)) +sum(isnull([271-300],0))+sum(isnull([301-330],0))+sum(isnull([331-360],0)) + sum(isnull([1yr-2yrs],0)) 
 and
 sum(isnull([1yr-2yrs],0))  > 0
then
balance - sum(isnull([1-30],0)) - sum(isnull([31-60],0)) - sum(isnull([61-90],0)) - sum(isnull([91-120],0)) -  sum(isnull([121-150],0))- sum(isnull([151-180],0))-sum(isnull([181-210],0))-sum(isnull([211-240],0))-sum(isnull([241-270],0))-sum(isnull([271-300],0))-sum(isnull([301-330],0))
else 
0
end as [1yr-2yrs],

case when balance >= sum(isnull([1-30],0)) + sum(isnull([31-60],0)) + sum(isnull([61-90],0)) + sum(isnull([91-120],0))+  sum(isnull([121-150],0)) +sum(isnull([151-180],0))  +sum(isnull([181-210],0)) +sum(isnull([211-240],0))   +sum(isnull([241-270],0)) +sum(isnull([271-300],0))+sum(isnull([301-330],0))+sum(isnull([331-360],0)) + sum(isnull([1yr-2yrs],0)) +sum(isnull([over2yrs],0))
 then
 sum(isnull([over2yrs],0))
when
 balance > sum(isnull([1-30],0)) + sum(isnull([31-60],0)) + sum(isnull([61-90],0)) + sum(isnull([91-120],0)) +  sum(isnull([121-150],0))+sum(isnull([151-180],0))  +sum(isnull([181-210],0)) +sum(isnull([211-240],0))   +sum(isnull([241-270],0)) +sum(isnull([271-300],0))+sum(isnull([301-330],0))+sum(isnull([331-360],0))+ sum(isnull([1yr-2yrs],0)) 
 and
 balance < sum(isnull([1-30],0)) + sum(isnull([31-60],0)) + sum(isnull([61-90],0)) + sum(isnull([91-120],0)) +  sum(isnull([121-150],0))+sum(isnull([151-180],0))  +sum(isnull([181-210],0)) +sum(isnull([211-240],0))   +sum(isnull([241-270],0)) +sum(isnull([271-300],0))+sum(isnull([301-330],0))+sum(isnull([331-360],0))+ sum(isnull([1yr-2yrs],0))  +sum(isnull([over2yrs],0))
 and 
 sum(isnull([over2yrs],0)) > 0
then
balance - sum(isnull([1-30],0)) - sum(isnull([31-60],0)) - sum(isnull([61-90],0)) - sum(isnull([91-120],0)) -  sum(isnull([121-150],0))- sum(isnull([151-180],0))-sum(isnull([181-210],0))-sum(isnull([211-240],0))-sum(isnull([241-270],0))-sum(isnull([271-300],0))-sum(isnull([301-330],0)) - sum(isnull([1yr-2yrs],0))
else 0
end as [over2yrs]
from(
 select b.zoneno,b.custnum,b.BookId,b.custname,b.status,
case when billdate = @year + '/' + @month 
 then a.subtot1
 else 0
end as [1-30],
 case when billdate =CONVERT(varchar(7),DATEADD(month,-1,(Convert(DATETIME, CONVERT(VARCHAR(2), @month) + '/' + CONVERT(VARCHAR(2), '01') + '/' + CONVERT(VARCHAR(4), @year)))),111)
 then a.subtot1
 else 0
 end as [31-60],
 case when billdate =CONVERT(varchar(7),DATEADD(month,-2,(Convert(DATETIME, CONVERT(VARCHAR(2), @month) + '/' + CONVERT(VARCHAR(2), '01') + '/' + CONVERT(VARCHAR(4), @year)))),111)
 then a.subtot1
 else 0
 end as [61-90],
case when billdate =CONVERT(varchar(7),DATEADD(month,-3,(Convert(DATETIME, CONVERT(VARCHAR(2), @month) + '/' + CONVERT(VARCHAR(2), '01') + '/' + CONVERT(VARCHAR(4), @year)))),111)
 then a.subtot1
 else 0
 end as [91-120],
 CASE WHEN billdate =CONVERT(varchar(7),DATEADD(month,-4,(Convert(DATETIME, CONVERT(VARCHAR(2), @month) + '/' + CONVERT(VARCHAR(2), '01') + '/' + CONVERT(VARCHAR(4), @year)))),111)
then a.subtot1
else 0
end as [121-150],
 CASE WHEN billdate =CONVERT(varchar(7),DATEADD(month,-5,(Convert(DATETIME, CONVERT(VARCHAR(2), @month) + '/' + CONVERT(VARCHAR(2), '01') + '/' + CONVERT(VARCHAR(4), @year)))),111)
then a.subtot1
else 0
end as [151-180],
case when billdate = CONVERT(varchar(7),DATEADD(month,-6,(Convert(DATETIME, CONVERT(VARCHAR(2), @month) + '/' + CONVERT(VARCHAR(2), '01') + '/' + CONVERT(VARCHAR(4), @year)))),111)
then a.subtot1
else 0
end as [181-210],
case when billdate = CONVERT(varchar(7),DATEADD(month,-7,(Convert(DATETIME, CONVERT(VARCHAR(2), @month) + '/' + CONVERT(VARCHAR(2), '01') + '/' + CONVERT(VARCHAR(4), @year)))),111)
then a.subtot1
else 0
end as [211-240],
case when billdate = CONVERT(varchar(7),DATEADD(month,-8,(Convert(DATETIME, CONVERT(VARCHAR(2), @month) + '/' + CONVERT(VARCHAR(2), '01') + '/' + CONVERT(VARCHAR(4), @year)))),111)
then a.subtot1
else 0
end as [241-270],
case when billdate = CONVERT(varchar(7),DATEADD(month,-9,(Convert(DATETIME, CONVERT(VARCHAR(2), @month) + '/' + CONVERT(VARCHAR(2), '01') + '/' + CONVERT(VARCHAR(4), @year)))),111)
then a.subtot1
else 0
end as [271-300],
case when billdate = CONVERT(varchar(7),DATEADD(month,-10,(Convert(DATETIME, CONVERT(VARCHAR(2), @month) + '/' + CONVERT(VARCHAR(2), '01') + '/' + CONVERT(VARCHAR(4), @year)))),111)
then a.subtot1
else 0
end as [301-330],
case when billdate = CONVERT(varchar(7),DATEADD(month,-11,(Convert(DATETIME, CONVERT(VARCHAR(2), @month) + '/' + CONVERT(VARCHAR(2), '01') + '/' + CONVERT(VARCHAR(4), @year)))),111)
then a.subtot1
else 0
end as [331-360],
case when billdate <= CONVERT(varchar(7),DATEADD(month,-12,(Convert(DATETIME, CONVERT(VARCHAR(2), @month) + '/' + CONVERT(VARCHAR(2), '01') + '/' + CONVERT(VARCHAR(4), @year)))),111)
and billdate >= CONVERT(varchar(7),DATEADD(month,-24,(Convert(DATETIME, CONVERT(VARCHAR(2), @month) + '/' + CONVERT(VARCHAR(2), '01') + '/' + CONVERT(VARCHAR(4), @year)))),111)
then a.subtot1
else 0
end as [1yr-2yrs],
case when billdate <= CONVERT(varchar(7),DATEADD(month,-25,(Convert(DATETIME, CONVERT(VARCHAR(2), @month) + '/' + CONVERT(VARCHAR(2), '01')+ '/' + CONVERT(VARCHAR(4), @year)))),111)
 then a.subtot1 
 else 0
 end as Over2yrs,balance
 from cbill a left join (select Zones.zoneno,Members.BOokId,Cust.CustId,Cust.CustNum,custname,Cust.status,balance = [Water Balance] 
 from cust 
 INNER JOIN Members on Cust.CustId = Members.CustId
 INNER JOIN Zones on Cust.ZoneId = Zones.ZoneId 
 INNER JOIN vw_ledger on Cust.CustId = vw_ledger.CustId
 ) b on a.CustId = b.CustId
       --where #ofArrears is not null
       where b.balance > 0
       and a.billstat <> '1'
     --  and a.billdate >= CONVERT(varchar(7),DATEADD(month,-25,(Convert(DATETIME, CONVERT(VARCHAR(2), @month) + '/' + CONVERT(VARCHAR(2), '01')+ '/' + CONVERT(VARCHAR(4), @year)))),111)
       and (b.[Status] = @stat or b.[Status] = @stat1 or b.[Status] = @stat2 or b.[Status] = @stat3)
       ) a       
     group by custnum,custname,balance,zoneno,BookId,status
       ) b 
         ) c 
           ) d
			left join books f on d.BOokId = f.BOokId
       where [1-30]+[31-60]+[61-90]+[91-120]+[121-150]+[151-180]+[181-210]+[211-240]+[241-270]+[271-300]+[301-330]+[331-360]+[1yr-2yrs]+over2yrs = totalarrears 
 and (f.bookno like '%' + @custnum + '%' or f.area like '%' + @custname  + '%')
group by f.bookno,f.area
end

begin
select * from custage
end




END

--exec AgingNew '2018','02','','','1','2','3',''

--exec jv_YearEndAging '2018/05'