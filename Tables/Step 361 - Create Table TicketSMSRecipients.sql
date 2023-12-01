Create Table TicketSMSRecipients
(
	RecipientID int identity(1,1),
	RecipientName varchar(100),
	MobileNumber varchar(11) NOT NULL,
	EmailAddress varchar(100)
)