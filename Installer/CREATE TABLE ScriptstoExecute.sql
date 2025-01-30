CREATE TABLE scriptsTOExecute
(
	execID int identity(1,1),
	execSequence int,
	execObjectType VARCHAR(50),
	scriptPath VARCHAR(250),
	CONSTRAINT UQ_ScriptstoExecute UNIQUE(ScriptPath)
)