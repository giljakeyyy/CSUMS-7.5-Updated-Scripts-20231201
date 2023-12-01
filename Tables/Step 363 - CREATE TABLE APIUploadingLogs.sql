CREATE TABLE APIUploadingLogs
(
	ID int identity(1,1),
	PymntMode int,
	PaymentDate Date,
	UserName varchar(50),
	UploadingDate DateTime,
	TotaltoUpload int,
	TotalCheckedItems int,
	Uploaded int,
	AlreadyExists int,
	NoOR int,
	ORAlreadyUsed int,
	ErrorinSaving int
)