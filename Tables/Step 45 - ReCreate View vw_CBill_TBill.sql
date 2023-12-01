ALTER VIEW [dbo].[vw_CBill_TBill]
AS
SELECT Cbill.BillNum, Cust.CustNum, Cbill.BillStat, Cbill.BillAmnt, 
    Cbill.DueDate, Cbill.BillDtls, Cbill.RpayNum, Cbill.SubTot1, 
    Cbill.SubTot2, Cbill.SubTot3, Cbill.SubTot4, Cbill.SubTot5, 
    Cust.CustName, Cust.BilStAdd, Cust.BilCtAdd, TBill.BillPeriod, 
    TBill.TotalCharges, TBill.MeterNo, TBill.RateCd, 
    TBill.MeterInfo1, TBill.MeterInfo2, TBill.PrevRdg, 
    TBill.PresRdg, TBill.TotalCons, TBill.Cons1, TBill.Amount1, 
    TBill.Cons2, TBill.Amount2, TBill.Cons3, TBill.Amount3, 
    TBill.Cons4, TBill.Amount4, TBill.Cons5, TBill.Amount5, 
    TBill.AveCons, TBill.ConsPerMonth, TBill.PesoPerDay, 
    TBill.BillType, TBill.BillDate, Cbill.Duedate2, TBill.cons6, 
    TBill.amount6
FROM Cust
INNER JOIN Cbill 
ON Cust.CustId = Cbill.CustId
INNER JOIN TBill 
ON Cbill.BillNum = TBill.BillNum
