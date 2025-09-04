api
openForReadFileNamed: aString

	^ aString asFileEntry readStream binary

	