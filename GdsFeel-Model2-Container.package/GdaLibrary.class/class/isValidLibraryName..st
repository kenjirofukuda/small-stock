compatibility
isValidLibraryName: aString

	^ (self isValidStorageName: aString) and: [ 
		  aString matchesRegex: '[A-Za-z][A-Za-z0-9$_]+' ]