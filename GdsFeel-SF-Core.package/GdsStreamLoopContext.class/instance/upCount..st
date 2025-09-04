validations
upCount: aSymbol

	self using: aSymbol.
	countMap at: aSymbol put: (countMap at: aSymbol) + 1