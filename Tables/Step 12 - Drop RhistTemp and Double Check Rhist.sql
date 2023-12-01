--Select Insert from Temp Table to New Rhist Table
Insert Rhist
(
	[CustId],[BookId],[SeqNo],[RateId],[BillDate],[CreatedDate],[Rdate],
	[Rtime],[Pread1],[Read1],[Cons1],[Pread2],[Read2],[Cons2],
	[RangeCd] ,[Tries],[MissCd],[WarnCd],[FF1Cd],
	[FF2Cd],[FF3Cd],[Remark],[nbasic],[DueDate],[BillPeriod],
	[arrears],[OldArrears1],[sept_fee],[nrw],[GPSLOC],
	[IsPaid],[PaymentMode],[PaymentDate],[GPSHLOC]
)
Select [CustId],[BookId],[SeqNo],[RateId],[BillDate],convert(datetime,rdate),[Rdate],
	[Rtime],[Pread1],[Read1],[Cons1],[Pread2],[Read2],[Cons2],
	[RangeCd] ,[Tries],[MissCd],[WarnCd],[FF1Cd],
	[FF2Cd],[FF3Cd],[Remark],[nbasic],[DueDate],[BillPeriod],
	[arrears],[OldArrears1],[sept_fee],[nrw],[GPSLOC],
	[IsPaid],[PaymentMode],[PaymentDate],[GPSHLOC]
From RhistTemp
order by BillDate

--Drop Temp Table
Drop Table RhistTemp

--Double Check New Rhist
Select * from Rhist