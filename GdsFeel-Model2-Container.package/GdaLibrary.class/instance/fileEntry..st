accessing
fileEntry: aPathOrFileEntry

	fileEntry ifNotNil: [ ^ self error: 'file set at once.' ].
	fileEntry := aPathOrFileEntry asFileEntry