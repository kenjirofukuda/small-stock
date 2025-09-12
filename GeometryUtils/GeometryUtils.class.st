Class {
	#name : #GeometryUtils,
	#superclass : #Object,
	#classVars : [
		'Degree45Theta',
		'MinusBounds',
		'Pi2',
		'PropMap'
	],
	#category : #GeometryUtils
}

{ #category : #'analisys-linesegment' }
GeometryUtils class >> analisysSegmentsAt: aPoint pointArray: vertices [ 
	^ self analisysSegmentsNewAt: aPoint  pointArray: vertices
]

{ #category : #accessing }
GeometryUtils class >> analisysSegmentsNewAt: aPoint pointArray: vertices [
	| contexts infos minSegIndex result minInfo |
	contexts := self segmentDistanceContexts: aPoint pointArray: vertices.
	minSegIndex := -1.
	infos := contexts collect: [ :each | self nearyInfoOfDistanceContext: each ].
	infos
		ifNotEmpty: [ 
			minInfo := (infos sort: [ :a :b | a second < b second ]) first.
			minSegIndex := minInfo last segIndex.
			infos := infos sort: [ :a :b | a third segIndex < b third segIndex ] ].
	result := Dictionary new.
	result at: #index put: minSegIndex.
	result at: #infos put: infos.
	result at: #testPoint put: aPoint.
	^ result
]

{ #category : #converting }
GeometryUtils class >> asCirculerIndex: segIndex segments: segs [
	| index |
	index := segIndex \\ segs size.
	index = 0
		ifTrue: [ index := segs size ].
	self assert: [ index between: 1 and: segs size ].
	^ index
]

{ #category : #api }
GeometryUtils class >> degressNormalized: aNumber [
	| newAngle |
	newAngle := aNumber.
	aNumber abs asFloat >= 360.0
		ifTrue: [ newAngle := aNumber \\ 360.0 ].
	newAngle negative
		ifTrue: [ newAngle := 360.0 + newAngle ].
	^ newAngle
]

{ #category : #accessing }
GeometryUtils class >> distanceContextAt: aPoint segment: aLineSegment [
	| distanceInfo |
	distanceInfo := DistanceContext fromPoint: aPoint lineSegment: aLineSegment.
	^ distanceInfo
]

{ #category : #accessing }
GeometryUtils class >> distanceContextAt: aPoint segment: aLineSegment index: segIndex [
	| distanceContext |
	distanceContext := self distanceContextAt: aPoint segment: aLineSegment.
	distanceContext segIndex: segIndex.
	^ distanceContext
]

{ #category : #deprecated }
GeometryUtils class >> distanceMapAt: aPoint segment: aLineSegment [
	| distanceMap p distP |
	distanceMap := Dictionary new.
	distanceMap at: #seg put: aLineSegment.
	p := aPoint nearestPointAlongLineFrom: aLineSegment start to: aLineSegment end.
	distanceMap at: #virtualCrossPoint put: p copy.
	p := (distanceMap at: #virtualCrossPoint) adhereTo: aLineSegment bounds.
	distanceMap at: #crossPoint put: p copy.
	distP := p distanceTo: aPoint.
	distanceMap at: #cross put: distP copy.
	distP := aLineSegment start distanceTo: aPoint.
	distanceMap at: #start put: distP copy.
	distP := aLineSegment start distanceTo: (distanceMap at: #crossPoint).
	distanceMap at: #startToCross put: distP copy.
	distP := aLineSegment end distanceTo: aPoint.
	distanceMap at: #end put: distP copy.
	distP := aLineSegment end distanceTo: (distanceMap at: #crossPoint).
	distanceMap at: #endToCross put: distP copy.
	distanceMap at: #side put: (aLineSegment sideOfPoint: aPoint).
	^ distanceMap
]

{ #category : #deprecated }
GeometryUtils class >> distanceMapAt: aPoint segment: aLineSegment index: segIndex [
	| distanceMap |
	distanceMap := self distanceMapAt: aPoint segment: aLineSegment.
	distanceMap at: #segIndex put: segIndex.
	^ distanceMap
]

{ #category : #initialization }
GeometryUtils class >> initialize [
	"GeometryUtils initialize"
	
	Degree45Theta := Float pi / 4.0.
	Pi2 := Float pi * 2.0.
	MinusBounds := nil.
	
	PropMap := Dictionary new.
	PropMap at: #transformClass put: self lookupTransformClass
]

{ #category : #api }
GeometryUtils class >> limitedPoint: aPoint [
	| x y |
	x := aPoint x < 0
		ifTrue: [ aPoint x max: -32768 ]
		ifFalse: [ aPoint x min: 32767 ].
	y := aPoint y < 0
		ifTrue: [ aPoint y max: -32768 ]
		ifFalse: [ aPoint y min: 32767 ].
	^ x @ y
]

{ #category : #api }
GeometryUtils class >> lineSegmentsFormPointArray: aPointArray [
	^ Array
		streamContents:
			[ :s | 
				self pointArray: aPointArray 
					lineSegmentsDo: [ :seg | s nextPut: seg ] ]
]

{ #category : #lookups }
GeometryUtils class >> lookupDataBounds: vertices [
	| minX minY maxX maxY |
	minX := SmallInteger maxVal.
	minY := SmallInteger maxVal.
	maxX := SmallInteger minVal.
	maxY := SmallInteger minVal.
	vertices
		do: [ :p | 
			minX := minX min: p x.
			minY := minY min: p y.
			maxX := maxX max: p x.
			maxY := maxY max: p y ].
	^ minX @ minY corner: maxX @ maxY
]

{ #category : #lookups }
GeometryUtils class >> lookupMinusBounds [
	^ Rectangle
		origin: SmallInteger maxVal @ SmallInteger maxVal
		corner: SmallInteger minVal @ SmallInteger minVal
]

{ #category : #lookups }
GeometryUtils class >> lookupTransformClass [

	^ Smalltalk
		  at: #MatrixTransform2x3
		  ifAbsent: [ Smalltalk at: #AffineTransformation ]
]

{ #category : #'analisys-linesegment' }
GeometryUtils class >> lookupVertexIndex: anAlisysResult [
	| segInfo distanceMap segIndex whichSide |
	segIndex := anAlisysResult at: #index.
	segInfo := (anAlisysResult at: #infos) at: segIndex.
	distanceMap := segInfo last.
	whichSide := segInfo first.
	#cross == whichSide
		ifTrue: [ whichSide := (distanceMap at: #startToCross)
				<= (distanceMap at: #endToCross)
				ifTrue: [ #start ]
				ifFalse: [ #end ] ].
	^ #start == whichSide
		ifTrue: [ segIndex ]
		ifFalse: [ segIndex + 1 ]
]

{ #category : #api }
GeometryUtils class >> midPointP1: pt1 p2: pt2 [
	^ (pt1 + pt2) / 2.0
]

{ #category : #api }
GeometryUtils class >> minusBounds [
	MinusBounds ifNil: [ MinusBounds := self lookupMinusBounds ].
	MinusBounds origin < MinusBounds corner
		ifTrue: [ "swap orign corner"
			| origin corner |
			origin := MinusBounds origin.
			corner := MinusBounds corner.
			MinusBounds instVarNamed: 'origin' put: corner.
			MinusBounds instVarNamed: 'corner' put: origin ].
	^ MinusBounds copy
]

{ #category : #'analisys-linesegment' }
GeometryUtils class >> nearyInfoOfDistanceContext: aDistanceContext [
	| infos sortItemBlock |
	sortItemBlock := [:context :sel | {sel . context perform: sel . context} ].
	(aDistanceContext start = aDistanceContext cross) 
		ifTrue: [ ^ sortItemBlock value: aDistanceContext value: #start].
	(aDistanceContext end = aDistanceContext cross) 
		ifTrue: [ ^ sortItemBlock value: aDistanceContext value: #end].
	infos := 
		{#start . #end . #cross } 
			collect: [:key | sortItemBlock value: aDistanceContext value: key] .
	^ (infos sort: [:a :b | a second < b second ]) first. 
	
]

{ #category : #'analisys-linesegment' }
GeometryUtils class >> nearyInfoOfDistanceMap: aDictionary [
	| infos sortItemBlock |
	sortItemBlock := [:map :sel | {sel . map at: sel . map} ].
	((aDictionary at: #start) = (aDictionary at: #cross)) 
		ifTrue: [^sortItemBlock value: aDictionary value: #start].
	((aDictionary at: #end) = (aDictionary at: #cross)) 
		ifTrue: [^sortItemBlock value: aDictionary value: #end].
	infos := (aDictionary keys select: [:each | 
		{#start . #end . #cross } includes: each]) asArray 
			collect: [:key | sortItemBlock value: aDictionary value: key] .
	^(infos sort: [:a :b | a second < b second]) first. 
	
]

{ #category : #api }
GeometryUtils class >> octagonalRoundTheta: aTheta [
	| ratio roundedRatio |
	ratio := aTheta / Pi2.
	roundedRatio := ratio roundTo: 0.125.
	^ Pi2 * roundedRatio
]

{ #category : #api }
GeometryUtils class >> offsetValues: aNumberArray [
	| values |
	values := OrderedCollection new.
	aNumberArray
		doWithIndex: [ :v :i | 
			| v2 |
			i < aNumberArray size
				ifTrue: [ 
					v2 := aNumberArray at: i + 1.
					values add: v2 - v ] ].
	^ values asArray
]

{ #category : #api }
GeometryUtils class >> point: aPoint roundTo: grid [
	"Answer a Point that is the receiver's x and y rounded to grid x and 
	grid y."

	| gridPoint nX nY |
	gridPoint := grid asPoint.
	nX := aPoint x copy.
	nY := aPoint y copy.
	(gridPoint x asFloat closeTo: 0.0)
		ifFalse: [ nX := aPoint x roundTo: gridPoint x ].
	(gridPoint y asFloat closeTo: 0.0)
		ifFalse: [ nY := aPoint y roundTo: gridPoint y ].
	^ nX @ nY
]

{ #category : #enumerating }
GeometryUtils class >> pointArray: aPointArray lineSegmentsDo: aLineSegmentBlock [
	| p1 p2 segment |
	aPointArray size < 2
		ifTrue: [ ^ self ].
	1 to: aPointArray size - 1 do: [ :index | 
		p1 := aPointArray at: index.
		p2 := aPointArray at: index + 1.
		segment := LineSegment from: p1 to: p2.
		aLineSegmentBlock value: segment ]
]

{ #category : #api }
GeometryUtils class >> reducedPoints: aLength p1: pt1 p2: pt2 [
	| deltaPoint theta dx dy |
	deltaPoint := pt2 - pt1.
	theta := deltaPoint theta.
	dx := theta cos * aLength.
	dy := theta sin * aLength.
	^ {(pt1 + (dx @ dy)). (pt2 - (dx @ dy))}
]

{ #category : #removing }
GeometryUtils class >> removeDuplicatePoints: aPointArray on: aOrderedCollection [
	| prevPoint |
	prevPoint := nil.
	aPointArray
		do: [ :each | 
			prevPoint
				ifNil: [ aOrderedCollection add: each ]
				ifNotNil: [ 
					prevPoint = each
						ifFalse: [ aOrderedCollection add: each ] ].
			prevPoint := each ]
]

{ #category : #'analisys-linesegment' }
GeometryUtils class >> segmentDistanceContexts: aPoint pointArray: vertices [
	| segIndex |
	^ Array
		streamContents: [ :s | 
			segIndex := 0.
			self class
				pointArray: vertices
				lineSegmentsDo: [ :lineSegment | 
					| distanceContext |
					segIndex := segIndex + 1.
					distanceContext := self distanceContextAt: aPoint segment: lineSegment index: segIndex.
					s nextPut: distanceContext ] ]
]

{ #category : #'analisys-linesegment' }
GeometryUtils class >> segmentDistanceMaps: aPoint pointArray: vertices [
	| segIndex |
	^ Array
		streamContents: [ :s | 
			segIndex := 0.
			self class
				pointArray: vertices
				lineSegmentsDo: [ :lineSegment | 
					| distanceMap |
					segIndex := segIndex + 1.
					distanceMap := self distanceMapAt: aPoint segment: lineSegment index: segIndex.
					s nextPut: distanceMap ] ]
]

{ #category : #api }
GeometryUtils class >> splitSegment: aLineSegment crossPoints: aCrossPoints epsilon: epsilon [
	^ Array
		streamContents: [ :stream | 
			(aCrossPoints
				select: [ :tp | tp onLineFrom: aLineSegment start to: aLineSegment end within: epsilon ])
				ifNotEmpty: [ :tpArray | 
					| sorted points |
					points := OrderedCollection new.
					points add: aLineSegment start.
					sorted := tpArray
						sort: [ :a :b | (a distanceTo: aLineSegment start) < (b distanceTo: aLineSegment start) ].
					points addAll: sorted.
					points add: aLineSegment end.
					points
						doWithIndex: [ :tp :index | 
							| start2 end2 |
							index < points size
								ifTrue: [ 
									start2 := points at: index.
									end2 := points at: index + 1.
									stream nextPut: (LineSegment from: start2 to: end2) ] ] ]
				ifEmpty: [ stream nextPut: aLineSegment ] ]
]

{ #category : #lookups }
GeometryUtils class >> transformClass [

	^ PropMap at: #transformClass
]

{ #category : #api }
GeometryUtils class >> verticesFromBounds: aBounds [
	^ {
	(aBounds origin x @ aBounds origin y).
	(aBounds origin x @ aBounds corner y).
	(aBounds corner x @ aBounds corner y).
	(aBounds corner x @ aBounds origin y).
	(aBounds origin x @ aBounds origin y)
	}
]

{ #category : #'look in class' }
GeometryUtils >> seeClassSide [
	"All the code for GeometryUtils is on the class side"
]
