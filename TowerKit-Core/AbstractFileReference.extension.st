Extension { #name : #AbstractFileReference }

{ #category : #'*TowerKit-Core' }
AbstractFileReference >> mbReadStreamDo: aBlock [
	self
		readStreamDo: [ :ws | 
			| fs |
			fs := MultiByteFileStream newFrom: ws.
			"fs lineEndConvention: #lf."
			[ aBlock value: fs ]
				ensure: [ fs close ] ]
]

{ #category : #'*TowerKit-Core' }
AbstractFileReference >> mbWriteStreamDo: aBlock [
	self
		writeStreamDo: [ :ws | 
			| fs |
			fs := MultiByteFileStream newFrom: ws.
			"fs lineEndConvention: #lf."
			[ aBlock value: fs ]
				ensure: [ fs close ] ]
]
