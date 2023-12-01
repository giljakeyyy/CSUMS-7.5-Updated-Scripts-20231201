--Select Insert from Temp Table to New BillingSchedule Table
Insert BillingSchedule
(
	[BookId],[BillDate],[DueDate],[FromDate],
	[ToDate],[DiscDate],[Status],[ExtractDT],
	[DnldDT],[UpldDT],[ReaderID],[PCA]
)
Select [BookId],[BillDate],[DueDate],[FromDate],
	[ToDate],[DiscDate],[Status],[ExtractDT],
	[DnldDT],[UpldDT],[ReaderID],[PCA]
from BillingScheduleTemp