printing
printOn: aStream

	aStream nextPutAll: 'STRANS'.
	aStream nextPut: $(.
	aStream nextPut: $[.
	self offset x printOn: aStream.
	aStream nextPut: $,.
	self offset y printOn: aStream.
	aStream nextPut: $].
	(self mag closeTo: 1.0) ifFalse: [ 
		aStream ensureEndsWith: $,.
		aStream nextPutAll: 'M:'.
		aStream print: self mag ].
	(self angle closeTo: 0.0) ifFalse: [ 
		aStream ensureEndsWith: $,.
		aStream nextPutAll: 'A:'.
		aStream print: self angle ].
	self isReflected ifTrue: [ 
		aStream ensureEndsWith: $,.
		aStream nextPutAll: 'REFL' ].
	aStream nextPut: $)