accessing
directoryEntry

	"self directoryEntry"

	^ ('./' asDirectoryEntry / 'GdsFeel' / self projectName)
		  fullPrintString asDirectoryEntry assureExistence.