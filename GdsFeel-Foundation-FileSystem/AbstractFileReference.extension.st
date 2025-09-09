Extension { #name : #AbstractFileReference }

{ #category : #'*GdsFeel-Foundation-FileSystem' }
AbstractFileReference >> mbReadStreamDo: aBlock [
	self
		readStreamDo: [ :ws | 
			| fs |
			fs := MultiByteFileStream newFrom: ws.
			"fs lineEndConvention: #lf."
			[ aBlock value: fs ]
				ensure: [ fs close ] ]
]

{ #category : #'*GdsFeel-Foundation-FileSystem' }
AbstractFileReference >> mbWriteStreamDo: aBlock [
	self
		writeStreamDo: [ :ws | 
			| fs |
			fs := MultiByteFileStream newFrom: ws.
			"fs lineEndConvention: #lf."
			[ aBlock value: fs ]
				ensure: [ fs close ] ]
]
