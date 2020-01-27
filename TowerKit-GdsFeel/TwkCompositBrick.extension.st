Extension { #name : #TwkCompositBrick }

{ #category : #'*TowerKit-GdsFeel' }
TwkCompositBrick >> buildDxf [
	self fileOutDxfEnabled
		ifTrue: [ 
			GdsStation default
				ensureOpenLibrary: self gdsBuilder library
				during: [ 
					self stanSegments.
					self gdsBuilder build.
					self gdsBuilder fileOutDxf ] ]
]

{ #category : #'*TowerKit-GdsFeel' }
TwkCompositBrick >> buildOutputFilesWithGds [
	GdsStation default
		ensureOpenLibrary: self gdsBuilder library
		during: [ 
			self stanSegments.
			self fileOutDxfEnabled
				ifTrue: [
					self gdsBuilder build.
					self gdsBuilder fileOutDxf].
			self fileOutForStan.
			self jsonSerializeEnabled
				ifTrue: [ self fileOutAsJson ] ]
]

{ #category : #'*TowerKit-GdsFeel' }
TwkCompositBrick >> fileOutDxfEnabled [
	^ self valueOfProperty: #fileOutDxfEnabled ifAbsentPut: [ true ] 
]

{ #category : #'*TowerKit-GdsFeel' }
TwkCompositBrick >> fileOutDxfEnabled: aBoolean [
	self setProperty: #fileOutDxfEnabled toValue: aBoolean
]

{ #category : #'*TowerKit-GdsFeel' }
TwkCompositBrick >> gdsBuilder [
	^ self valueOfProperty: #gdsBuilder ifAbsentPut: [ TwkCompositBrickGdsBuilder new model: self ] 
]
