check
checkLibName: aString

	| libnameSizeRange checkName |
	checkName := "self baseName: " aString.
	self libNameMax > 0 ifTrue: [ 
		libnameSizeRange := 1 to: self libNameMax.
		(libnameSizeRange includes: checkName size) ifFalse: [ 
			^ self error:
				  ('LIBRARYNAME SIZE UNDER {1} ' format: { libnameSizeRange max }) ] ].
	(self isValidLibraryName: checkName) ifFalse: [ "(self exists: checkName)
		ifTrue: [
			^self error: ('LIBNAME ALREADY EXISTS: {1}' format: {checkName})]." 
		self error: 'LIBRARY NAME ERROR' ]