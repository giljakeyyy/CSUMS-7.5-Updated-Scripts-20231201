IF NOT EXISTS
(
	SELECT * FROM   INFORMATION_SCHEMA.COLUMNS
	WHERE  TABLE_NAME = 'PaymentCenter_Transactions'
	AND COLUMN_NAME = 'ReceivedDate'
)
BEGIN
	ALTER TABLE PaymentCenter_Transactions
	ADD ReceivedDate DateTime NULL
END
