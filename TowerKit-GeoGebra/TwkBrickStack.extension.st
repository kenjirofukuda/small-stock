Extension { #name : #TwkBrickStack }

{ #category : #'*TowerKit-GeoGebra' }
TwkBrickStack >> geoGebraCommands [
	^ Array streamContents: [ :s |
			s nextPutAll: self sliceCommands.
			s nextPutAll: self widthSpecCommands.
			s nextPutAll: self slopeCommands ] 

]

{ #category : #'*TowerKit-GeoGebra' }
TwkBrickStack >> ggPool [
	^ self valueOfProperty: #ggPool ifAbsentPut: [ GGPool new ].
]

{ #category : #'*TowerKit-GeoGebra' }
TwkBrickStack >> sliceCommands [
	^ Array streamContents: [ :s |
		self sliceHeights doWithIndex: [ :each :index |
			s nextPut: (GGAtom horizontalLineNamed: 'h' index: index y: each ) ] ].

]

{ #category : #'*TowerKit-GeoGebra' }
TwkBrickStack >> slopeCommands [
	^ Array streamContents: [ :s |
		(self leftSlopeSegments, self rightSlopeSegments)  
			doWithIndex: [ :each :index |
				s nextPut: (GGAtom segmentNamed: 'slope' index: index segment: each) ]  ].
		

]

{ #category : #'*TowerKit-GeoGebra' }
TwkBrickStack >> widthSpecCommands [
	^ Array streamContents: [ :s |
			self validWidthItems doWithIndex: [ :each :index |
				s nextPut: (GGAtom circleNamed: 'c' index: index at: (0 @ (each height)) width: each width) ] ].

]
