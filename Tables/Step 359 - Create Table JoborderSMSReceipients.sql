Create Table JoborderSMSReceipients
(
	RecipientId int identity(1,1),
	RecipientName varchar(100),
	MobileNumber varchar(11),
	EmailAddress varchar(50)
)