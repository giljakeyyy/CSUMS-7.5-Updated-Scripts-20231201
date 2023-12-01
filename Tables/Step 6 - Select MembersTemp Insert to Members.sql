--Select Insert from Temp Table to New Members Table
Insert Members
(
	[CustId],[BookId],[SeqNo],[PRdate],[MeterNo1],[Mtype1],
	[Mmult1],[Pread1],[AveCon1],[MeterNo2],[Mtype2],
	[Mmult2],[Pread2],[AveCon2],[WarnCd],[Billnum]
)
Select [CustId],[BookId],[SeqNo],[PRdate],[MeterNo1],[Mtype1],
	[Mmult1],[Pread1],[AveCon1],[MeterNo2],[Mtype2],
	[Mmult2],[Pread2],[AveCon2],[WarnCd],[Billnum]
from MembersTemp