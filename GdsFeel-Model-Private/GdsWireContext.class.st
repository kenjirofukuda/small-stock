"
A GdsWireContext is GDS II's PATH or TEXT shared property.

Instance Variables
	boundaryPoints:		<Array<Point>>
	outlineSegMap:		<Object>
	width:		<Float>

boundaryPoints
	- xxxxx

outlineSegMap
	- xxxxx

width
	- xxxxx

"
Class {
	#name : #GdsWireContext,
	#superclass : #Model,
	#instVars : [
		'width',
		'outlineSegMap',
		'boundaryPoints',
		'pathtype',
		'element'
	],
	#category : #'GdsFeel-Model-Private'
}

{ #category : #testing }
GdsWireContext class >> hasWidth [
	^true.
]

{ #category : #accessing }
GdsWireContext class >> requiredVertexCount [
	^2.
]

{ #category : #accessing }
GdsWireContext class >> type [
	^#path
]

{ #category : #accessing }
GdsWireContext >> boundaryPoints [
	boundaryPoints ifNil: [boundaryPoints := self lookupBoundaryPoints].
	^boundaryPoints
]

{ #category : #printing }
GdsWireContext >> consoleStringOn: aStream [
	aStream nextPutAll: 'WIDTH: '.
	aStream print: self width.
	aStream cr.
	aStream nextPutAll: 'PATHTYPE: '.
	aStream print: self pathtype.

]

{ #category : #accessing }
GdsWireContext >> dataOutlinePoints [
	^ self boundaryPoints
]

{ #category : #outline }
GdsWireContext >> degressOfPathType [
	^self pathtype = 0 ifTrue: [90] ifFalse: [45].

]

{ #category : #accessing }
GdsWireContext >> element: aGdsElement [
	element := aGdsElement.
]

{ #category : #accessing }
GdsWireContext >> halfWidth [
	^self width / 2.0.
]

{ #category : #initialization }
GdsWireContext >> initialize [
	super initialize.
	width := 0.0.
	pathtype := 0.
]

{ #category : #other }
GdsWireContext >> lineSegmentsDo: aLineSegmentBlock [
	element lineSegmentsDo: aLineSegmentBlock
]

{ #category : #outline }
GdsWireContext >> lookupBoundaryPoints [
	|  unit r offsetRadians getSegsBlock lastSeg vpLeftPrev vpLeft vpRight vpRightPrev count points colPoints colLeftPoints colRightPoints segOutlinePoints segs1 segs2 leftSeg1 leftSeg2 rightSeg1 rightSeg2 |
	colPoints := OrderedCollection new.	
	colLeftPoints := OrderedCollection new.	
	colRightPoints := OrderedCollection new.	
	points := self vertices.
	offsetRadians :=  self degressOfPathType degreesToRadians.
	unit := offsetRadians sin.
	r := unit = 0 ifTrue: [self halfWidth] ifFalse: [self halfWidth / unit].
	lastSeg := nil.
	vpLeft := nil.
	vpLeftPrev := nil.
	vpRight := nil.
	vpRightPrev := nil.
	count := 0.
	getSegsBlock := [:each | self outlineSegmentsOf: each offsetRadians: offsetRadians r: r].
	self lineSegmentsDo: [:seg |
		|  |
		count := count + 1.
		segOutlinePoints := seg outlinePoints: offsetRadians r: r.
		(points size = 2)
			ifTrue: [
				colPoints addAll: {segOutlinePoints at: 3 . segOutlinePoints at: 2 . segOutlinePoints at: 1 . segOutlinePoints at: 4 . segOutlinePoints at: 3}.
				^colPoints asArray].	
		segs1 := getSegsBlock value: seg.
		leftSeg1 := segs1 second reversed.
		rightSeg1 := segs1 fourth .
		(count == 1)
			ifTrue: [
				vpLeft := leftSeg1 start copy.
				vpRight := rightSeg1 start copy..
				vpLeftPrev := leftSeg1 start copy..
				vpRightPrev := rightSeg1 start copy..				
				].		
		lastSeg ifNotNil: [
			segs2 := getSegsBlock value: lastSeg.
			leftSeg2 := segs2 second reversed.
			rightSeg2 := segs2 fourth .
			vpLeft := leftSeg1 intersectionWith: leftSeg2  virtualAllowed: true.
			vpLeft ifNil: [vpLeft := leftSeg2 end copy.].
			vpLeftPrev 
				ifNil:[vpLeftPrev := leftSeg2 start].
			colLeftPoints add: vpLeftPrev.
			colLeftPoints add: vpLeft.
			vpLeftPrev := vpLeft copy.
			
			vpRight := rightSeg1 intersectionWith: rightSeg2  virtualAllowed: true.
			vpRight ifNil: [vpRight := rightSeg2 end copy.].
			colRightPoints add: vpRightPrev.
			colRightPoints add: vpRight.
			vpRightPrev := vpRight copy.
		count = (points size - 1)
			ifTrue: [
				vpLeft ifNotNil: [
					colLeftPoints add: leftSeg1 end copy].
				vpRight ifNotNil: [
					colRightPoints add: rightSeg1 end copy]].].
		lastSeg := seg].
	colPoints addAll: colLeftPoints.
	colPoints addAll: colRightPoints reversed.	
	colPoints size >= 2 	
		ifTrue: [colPoints add: colPoints first].
	self assert: [colPoints size >= 5].
	^colPoints asArray.
	
]

{ #category : #outline }
GdsWireContext >> offsetRadiansAndRadiusDo: aBlock [
	|  unit r offsetRadians  |
	offsetRadians :=  self degressOfPathType degreesToRadians.
	unit := offsetRadians sin.
	r := unit = 0 ifTrue: [self halfWidth] ifFalse: [self halfWidth / unit].
	aBlock value: offsetRadians value: r.
]

{ #category : #outline }
GdsWireContext >> outlinePointsOf: aLineSegment [
	| points |
	points := #() copy.
	self offsetRadiansAndRadiusDo: [:radians :r |
		points := aLineSegment outlinePoints: radians r: r.].
	^points
]

{ #category : #outline }
GdsWireContext >> outlineSegmentsOf: aLineSegment [
	outlineSegMap ifNil: [outlineSegMap := Dictionary new].
	
]

{ #category : #outline }
GdsWireContext >> outlineSegmentsOf: aLineSegment offsetRadians: radians r: r [
	outlineSegMap ifNil: [outlineSegMap := Dictionary new].
	^outlineSegMap 
		at: aLineSegment 
		ifAbsentPut: [aLineSegment outlineSegments: radians r: r].
	
]

{ #category : #accessing }
GdsWireContext >> pathtype [
	^pathtype
]

{ #category : #accessing }
GdsWireContext >> pathtype: aInteger [
	self assert: [aInteger isInteger].
	pathtype = aInteger ifTrue: [^self].
	pathtype := aInteger.
	self removeGeometryCache.
	self changed: #pathtype.
]

{ #category : #other }
GdsWireContext >> removeGeometryCache [
	boundaryPoints := nil.
	outlineSegMap := nil.
]

{ #category : #accessing }
GdsWireContext >> vertices [
	^element vertices
]

{ #category : #accessing }
GdsWireContext >> width [
	width ifNil: [width := 10.0].
	^width.
]

{ #category : #accessing }
GdsWireContext >> width: aFloat [
	width = aFloat ifTrue: [^self].
	width := aFloat.
	self removeGeometryCache.
	self changed: #width.	
]
