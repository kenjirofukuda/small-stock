"
A GdsStretchTool is xxxxxxxxx.

Instance Variables
	analisysResult:		<Dictionary>
	crossPointToPostSeg:		<Point>
	crossPointToPreSeg:		<Point>
	lastUpdateBounds:		<Rectangle>
	moveToSeg:		<LineSegment>
	nonEditUpdateBounds:		<Rectangle>
	offsetSeg:		<LineSegment>

analisysResult
	- xxxxx

crossPointToPostSeg
	- xxxxx

crossPointToPreSeg
	- xxxxx

lastUpdateBounds
	- xxxxx

moveToSeg
	- xxxxx

nonEditUpdateBounds
	- xxxxx

offsetSeg
	- xxxxx

"
Class {
	#name : #GdsStretchTool,
	#superclass : #GdsNullTool,
	#instVars : [
		'analisysResult',
		'moveToSeg',
		'offsetSeg',
		'crossPointToPreSeg',
		'crossPointToPostSeg',
		'nonEditUpdateBounds',
		'lastUpdateBounds'
	],
	#category : 'GdsFeel-UI-Tools'
}

{ #category : #testing }
GdsStretchTool >> autoFinishAfterPut [
	^true
]

{ #category : #'prompt message' }
GdsStretchTool >> chooserMessage [
	^self vertexStrechSupported 
		ifTrue: ['Point Near Segment or Vertex:']
		ifFalse: ['Point Near Segment:'].
]

{ #category : #drawing }
GdsStretchTool >> drawFeedbackOn: aLocalCanvas [
	| segInfo crossPoint seg |
	analisysResult ifNil: [^self].
	segInfo := (analisysResult at: #infos) at: (analisysResult at: #index).
	seg := (segInfo last at: #seg).
	self clickCount \\ 2 = 1
		ifTrue: [
			morph drawOn: aLocalCanvas  lineSegment: seg  width: 2.
			self drawSegmentEndPointByDiamondOn:  aLocalCanvas segment: seg.].
	GdsFeelMorphic debugStretchFeedback ifFalse: [^self].
	
	self markCrossPoint ifTrue:[
		crossPoint := (segInfo last at: #crossPoint).
		morph drawOn: aLocalCanvas centerCircleAt: crossPoint.].
	morph invalidBoundsForSegment: seg.
	moveToSeg ifNotNil: [
		self drawOn: aLocalCanvas segment: moveToSeg].
	offsetSeg ifNotNil: [
		self drawOn: aLocalCanvas segment: offsetSeg].
	self drawVirtualCrossPointOn: aLocalCanvas.

]

{ #category : #drawing }
GdsStretchTool >> drawOn: aLocalCanvas segment: segment [
	morph drawOn: aLocalCanvas  lineSegment: segment.
	self drawSegmentEndPointByDiamondOn:  aLocalCanvas segment: segment.
	morph invalidBoundsForSegment: segment.

]

{ #category : #drawing }
GdsStretchTool >> drawSegmentEndPointByCircleOn: aLocalCanvas segment: seg [
	morph drawOn: aLocalCanvas  centerCircleAt: seg start.
	morph drawOn: aLocalCanvas  centerCircleAt: seg end.

]

{ #category : #drawing }
GdsStretchTool >> drawSegmentEndPointByDiamondOn: aLocalCanvas segment: seg [
	morph drawOn: aLocalCanvas  markDiamondPointAt:  seg start.
	morph drawOn: aLocalCanvas  markDiamondPointAt: seg end.

]

{ #category : #drawing }
GdsStretchTool >> drawVirtualCrossPointOn: aLocalCanvas [
	crossPointToPreSeg ifNotNil: [
		morph drawOn: aLocalCanvas markPointAt: crossPointToPreSeg].
	crossPointToPostSeg ifNotNil: [
		morph drawOn: aLocalCanvas markPointAt: crossPointToPostSeg].

]

{ #category : #action }
GdsStretchTool >> evenAction [
	"TODO:  Move to segment or vertices"			
	self moveToSegment.
	"Next Message"
	self prompt: self chooserMessage

]

{ #category : #action }
GdsStretchTool >> eventAction [
	self evenOddAction.
]

{ #category : #action }
GdsStretchTool >> firstAction [
	nonEditUpdateBounds := 
		GeometryUtils 
			lookupDataBounds: (self currentItem editElement dataOutlinePoints).
]

{ #category : #private }
GdsStretchTool >> itemSegmentAt: segIndex [
	^self itemSegmentAt:  segIndex circurlerAllowed: false.
]

{ #category : #private }
GdsStretchTool >> itemSegmentAt: segIndex circurlerAllowed: aBoolean [
	| segs|
	segs := GeometryUtils lineSegmentsFormPointArray:  self currentItem vertices. 
	aBoolean ifFalse: [^segs at: segIndex ifAbsent: [nil.]].
	^segs at: (GeometryUtils asCirculerIndex: segIndex segments: segs).
]

{ #category : #'debugging-use-only' }
GdsStretchTool >> markCrossPoint [
	^false.
]

{ #category : #action }
GdsStretchTool >> moveTarget [
	^#segment
]

{ #category : #'prompt message' }
GdsStretchTool >> moveToMessage [
	^self moveTarget == #vertex 
		ifTrue: ['Point to Pull Vertex to:']
		ifFalse: ['Point to Stretch Edge To:'].
]

{ #category : #action }
GdsStretchTool >> moveToSegment [
	| segs fromDistanceMap segInfo seg toPoint preSeg postSeg toDistanceMap  circulerAllowed preSegIndex postSegIndex replaceVirtexPreIndex replaceVirtexPostIndex|
	toPoint := self snapedWorldPoint2.
	analisysResult ifNil: [^self].
	segInfo := (analisysResult at: #infos) at: (analisysResult at: #index).
	fromDistanceMap := segInfo last.
	seg := fromDistanceMap lineSegment.
	toDistanceMap := GeometryUtils distanceMapAt: toPoint segment: seg.
	offsetSeg := LineSegment 
		from: (toDistanceMap at: #virtualCrossPoint) 
		to: toPoint.
	moveToSeg := LineSegment 
		from: (seg start + offsetSeg direction) 
		to: (seg end + offsetSeg direction).

	circulerAllowed := (self currentItem isBoundary).
	segs := GeometryUtils lineSegmentsFormPointArray: self currentItem vertices.
	segs size = 1
		ifTrue: [
			self currentItem verticesAt: 1 put: moveToSeg start fixClosed: circulerAllowed.
			self currentItem verticesAt: 2 put: moveToSeg end fixClosed: circulerAllowed.
			^self updateInvalidArea].
	
	"PREvious Segment"
	preSegIndex := (analisysResult at: #index) - 1.
	circulerAllowed ifTrue: [
		preSegIndex := GeometryUtils 
			asCirculerIndex:  preSegIndex segments: segs.].
	preSeg := segs at: preSegIndex ifAbsent: nil.
	replaceVirtexPreIndex := preSegIndex + 1.
	preSeg ifNotNil: [
		crossPointToPreSeg := preSeg intersectionWith: moveToSeg virtualAllowed: true].
		
	"POST Segment"
	postSegIndex := (analisysResult at: #index) + 1.
	circulerAllowed ifTrue: [
		postSegIndex := GeometryUtils 
			asCirculerIndex:  postSegIndex segments: segs.].
	postSeg := segs at: postSegIndex ifAbsent: nil.
	replaceVirtexPostIndex := postSegIndex.
	postSeg ifNotNil: [
		crossPointToPostSeg := postSeg intersectionWith: moveToSeg virtualAllowed: true.].

	circulerAllowed ifTrue: [
		(crossPointToPreSeg isNil or: [crossPointToPostSeg isNil])
			ifTrue:[^self updateInvalidArea].].
	
	preSeg ifNil: [
		crossPointToPreSeg := crossPointToPostSeg - moveToSeg direction].

	postSeg ifNil: [
		crossPointToPostSeg := crossPointToPreSeg + moveToSeg direction].

	self currentItem 
		verticesAt: replaceVirtexPreIndex 
		put: crossPointToPreSeg copy
		fixClosed: circulerAllowed.
	
	self currentItem 
		verticesAt: replaceVirtexPostIndex 
		put: crossPointToPostSeg copy 
		fixClosed: circulerAllowed.
			
	self updateInvalidArea.
]

{ #category : #action }
GdsStretchTool >> oddAction [
	"TODO: Test Segment of vertex analisysresult"
	analisysResult := 
		GeometryUtils 
			analisysSegmentsAt: (self snapedWorldPoint2) 
			pointArray: self currentItem vertices.
	moveToSeg := nil.
	offsetSeg := nil.
	crossPointToPostSeg := nil.
	crossPointToPreSeg := nil.
	"Next Message"
	self prompt: self moveToMessage.

]

{ #category : #'event handling' }
GdsStretchTool >> toolDidChange [
	self prompt: self chooserMessage 
]

{ #category : #action }
GdsStretchTool >> updateInvalidArea [	
	| currentUpdateBounds |
	currentUpdateBounds := GeometryUtils lookupDataBounds: (self currentItem vertices) .
	currentUpdateBounds := currentUpdateBounds merge: nonEditUpdateBounds.
	lastUpdateBounds
		ifNotNil: [currentUpdateBounds := currentUpdateBounds merge: lastUpdateBounds.].
	morph invalidBounds: currentUpdateBounds.
	lastUpdateBounds := currentUpdateBounds copy.
]

{ #category : #testing }
GdsStretchTool >> vertexStrechSupported [
	"Sorry: current implements only Segment stretch"
	^false
]
