Extension { #name : #TwkAbstractBrick }

{ #category : #'*TowerKit-GdsFeel' }
TwkAbstractBrick >> findRoundNodesForSlice: slice inStanNodes: aStanNodes [
	^ aStanNodes
		select: [ :node | 
			| reversePoint depthValue |
			reversePoint := node point3d asArray - self stanOffsetWithGrand.
			depthValue := self isPost
				ifTrue: [ reversePoint third ]
				ifFalse: [ reversePoint first ].
			slice isPlane
				ifTrue: [ slice sectionHeight closeTo: depthValue ]
				ifFalse: [ 
					slice naverMap values anySatisfy: [ :face | 
						face sectionHeight closeTo: depthValue ] ] ]
]

{ #category : #'*TowerKit-GdsFeel' }
TwkAbstractBrick >> gdsBuilder [
	^ self valueOfProperty: #gdsBuilder ifAbsentPut: [ TwkBrickGdsBuilder new model: self ] 
]

{ #category : #'*TowerKit-GdsFeel' }
TwkAbstractBrick >> slicePointFromNode: foundNode [
	^ self slicePointFromPoint3d: foundNode point3d asArray
]

{ #category : #'*TowerKit-GdsFeel' }
TwkAbstractBrick >> slicePointFromPoint3d: point3d [ 
	| scale2d reversePoint index2d xVal yVal |
	reversePoint := point3d - self stanOffsetWithGrand.
	index2d := self isPost
		ifTrue: [ #(1 2) ]
		ifFalse: [ #(2 3) ].
	scale2d := self isPost
		ifTrue: [ #(1 1) ]
		ifFalse: [ #(-1 1) ].
	xVal := (reversePoint at: (index2d at: 1)) * scale2d at: 1.
	yVal := (reversePoint at: (index2d at: 2)) * scale2d at: 2.
	^ (xVal @ yVal) fixNegativeZero
]

{ #category : #'*TowerKit-GdsFeel' }
TwkAbstractBrick >> stanNodeNumbersMapForFaceNodes: aNodes [
	| infs signs fMap |
	signs := self signsArray.
	infs := self directionToSignIndexArray.
	fMap := Dictionary new.
	aNodes
		do: [ :node | 
			| slice2d signPoint segsOfValume |
			slice2d := self slicePointFromNode: node.	"slice2d traceCr."
			signPoint := slice2d sign.
			(infs detect: [ :inf | (signs at: (inf at: 2)) = signPoint ] ifNone: [  ])
				ifNil: [ 
					self traceCr: ('Face detection failed: <1p>' expandMacrosWith: node).
					segsOfValume := self sliceRoundSegmentsOfVolume: (node point3d at: self depthSideIndex).
					segsOfValume do: [:each | each traceCr.].
					segsOfValume doWithIndex: [ :each :index | 
						((GeometryUtils distanceContextAt: slice2d  segment: each)
							cross roundedForStan closeTo: 0.0)
								ifTrue: [
									| dir |
									dir := self directions at: index.
									(fMap at: dir ifAbsentPut: [ OrderedCollection new ])
										add: node. ] ].
					 ]
				ifNotNil: [ :foundInf | 
					(fMap at: foundInf first ifAbsentPut: [ OrderedCollection new ])
						add: node.] ].
	^ fMap
]

{ #category : #'*TowerKit-GdsFeel' }
TwkAbstractBrick >> stanNodeNumbersMapForFacePoint [
	^ self stanNodeNumbersMapForFaceNodes: self stanNodesForFacePoint
]

{ #category : #'*TowerKit-GdsFeel' }
TwkAbstractBrick >> stanNodeNumbersMapForFaceRoundInsert [
	^ self stanNodeNumbersMapForFaceNodes: self stanNodesForSectionRoundInsert 
]
