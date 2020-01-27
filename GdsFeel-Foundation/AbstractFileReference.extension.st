Extension { #name : #AbstractFileReference }

{ #category : #'*GdsFeel-Foundation' }
AbstractFileReference >> mbReadStreamDo: aBlock [
	self
		readStreamDo: [ :ws | 
			| fs |
			fs := MultiByteFileStream newFrom: ws.
			"fs lineEndConvention: #lf."
			[ aBlock value: fs ]
				ensure: [ fs close ] ]
]

{ #category : #'*GdsFeel-Foundation' }
AbstractFileReference >> mbWriteStreamDo: aBlock [
	self
		writeStreamDo: [ :ws | 
			| fs |
			fs := MultiByteFileStream newFrom: ws.
			"fs lineEndConvention: #lf."
			[ aBlock value: fs ]
				ensure: [ fs close ] ]
]
