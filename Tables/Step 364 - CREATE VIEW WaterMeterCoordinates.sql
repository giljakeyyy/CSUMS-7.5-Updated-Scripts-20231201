CREATE VIEW [dbo].WaterMeterCoordinates
AS
SELECT c.CustNum as AccntNo,c.CustName as AccntName,c.BilStAdd as StreetAddress,
c.BilCtAdd as CityAddress,b.GPSLOC as WaterMeterGPS,b.GPSHLOC as HouseAddressGPS
FROM
(
	SELECT CustId,MAX(BillDate)BillDate
	FROM Rhist
	WHERE RTRIM(LTRIM(ISNULL(gpsloc,''))) <> ''
	OR RTRIM(LTRIM(ISNULL(gpshloc,''))) <> ''
	GROUP BY CustId
)a
INNER JOIN Rhist b
on a.CustId = b.CustId
and a.BillDate = b.BillDate
INNER JOIN Cust c
on a.CustId = c.CustId