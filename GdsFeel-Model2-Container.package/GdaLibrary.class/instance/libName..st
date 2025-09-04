accessing - basic
libName: aString

	libname ifNotNil: [ ^ self error: 'LIBRARY NAME ASSIGNED ONCE' ].
	self class checkLibName: aString.
	libname := "self class baseName:" aString