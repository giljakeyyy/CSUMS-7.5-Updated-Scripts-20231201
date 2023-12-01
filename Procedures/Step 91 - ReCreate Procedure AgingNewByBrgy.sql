ALTER PROCEDURE [dbo].[AgingNewByBrgy]
	-- Add the parameters for the stored procedure here
	@year varchar(4),
	@month varchar(2)
AS
BEGIN
    declare @lastdate as varchar(100)

    set @lastdate = @year + '/' + @month + '/01'
    set @lastdate = convert(varchar(100), EOMONTH(convert(datetime, @lastdate)), 111)


    begin

    select isnull(Barangays.barangay,'Unassigned') as Barangays
	,convert(numeric(18,2),sum(totalarrears)) as totalarrears
	,convert(numeric(18,2),sum([1-30])) as [1-30]
	,convert(numeric(18,2),sum([31-60])) as [31-60]
	,convert(numeric(18,2),sum([61-90])) as [61-90]
	,convert(numeric(18,2),sum([91-120])) as [91-120]
	,convert(numeric(18,2),sum([121-150])) as [121-150]
	,convert(numeric(18,2),sum([151-180])) as [151-180]
	,convert(numeric(18,2),sum([181-210])) as [181-210]
	,convert(numeric(18,2),sum([211-240])) as [211-240]
	,convert(numeric(18,2),sum([241-270])) as [241-270]
	,convert(numeric(18,2),sum([271-300])) as [271-300]
	,convert(numeric(18,2),sum([301-330])) as [301-330]
	,convert(numeric(18,2),sum([331-360])) as [331-360]
	,convert(numeric(18,2),sum([1yr-2yrs])) as [1yr-2yr2]
	,convert(numeric(18,2),sum(over2yrs)) as [Over2yrs]
	from
    (
        select CustId,custnum,balance as totalarrears,
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
        from
        (
            select
            *, balance - ([1-30]+[31-60]+[61-90]+[91-120]+[121-150]+[151-180]+[181-210]+[211-240]+[241-270]+[271-300]+[301-330]+[331-360]+[1yr-2yrs]+over2yrs) Total
            from
            (
            select a.CustId,custnum,custname,balance,ZOneId,status,
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
             select b.ZoneId,b.CustId,b.custnum,b.custname,b.status,
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
             from cbill a left join (select cust.ZoneId,cust.CustId,cust.custnum,cust.custname,cust.status,isnull(cust_balance.balance,0) as balance from cust
                                    left join(Select CustId,sum(isnull(debit,0) - isnull(credit,0)) as balance from cust_ledger
                                    where ledger_type = 'WATER' 
                                    and (convert(varchar(100),trans_date,111) <= @lastdate or trans_date is null)
                                    group by CustId)cust_balance
                                    on cust.CustId = cust_balance.CustId
                                    ) b on a.CustId = b.CustId

                   where b.balance > 0
                   and a.billstat <> '1'
				   ) a       
                 group by a.CustId,custnum,custname,balance,ZoneId,status
                   ) b 
                 ) c 
               ) d   
			inner join cust 
			on d.CustNum = cust.CustNum
			left join Barangays
			on cust.brgyid = Barangays.brgyid
          where [1-30]+[31-60]+[61-90]+[91-120]+[121-150]+[151-180]+[181-210]+[211-240]+[241-270]+[271-300]+[301-330]+[331-360]+[1yr-2yrs]+over2yrs = totalarrears 
			group by isnull(Barangays.barangay,'Unassigned')
    end

END

GO


