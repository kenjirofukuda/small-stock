"
A GdsNullTool is xxxxxxxxx.

Instance Variables
	clickCount:		<Integer>
	deltaPoint:		<Point>
	event:		<MouseEvent>
	lastDeltaPoint:		<Point>
	lastPoint:		<Point>
	morph:		<GdsStructureMorph>
	referencePoint:		<Point>
	stopCE:		<Boolean>
	userInfo:		<Object>

clickCount
	- xxxxx

deltaPoint
	- xxxxx

event
	- xxxxx

lastDeltaPoint
	- xxxxx

lastPoint
	- xxxxx

morph
	- xxxxx

referencePoint
	- xxxxx

stopCE
	- xxxxx

userInfo
	- xxxxx

"
Class {
	#name : 'GdsNullTool',
	#superclass : 'Object',
	#instVars : [
		'morph',
		'event',
		'userInfo',
		'clickCount',
		'lastPoint',
		'referencePoint',
		'lastDeltaPoint',
		'deltaPoint',
		'stopCE',
		'oldRubberBandBounds'
	],
	#category : 'GdsFeel-UI-Tools',
	#package : 'GdsFeel-UI',
	#tag : 'Tools'
}

{ #category : 'action' }
GdsNullTool >> afterSecondAction [
	self subclassResponsibility.
]

{ #category : 'testing' }
GdsNullTool >> autoFinishAfterPut [
	^false
]

{ #category : 'testing' }
GdsNullTool >> canFinish [
	^false
]

{ #category : 'event handling' }
GdsNullTool >> changeCursor [
	morph changeCursorToCross.
]

{ #category : 'accessing' }
GdsNullTool >> clickCount [
	clickCount ifNil: [clickCount := 0].
	^clickCount.
]

{ #category : 'action' }
GdsNullTool >> consoleOut [
	| resultPoint |
	resultPoint := self snapedWorldPoint2.
	GdsFeel ifDebugOn: [:s |
		s nextPutAll: event printString.
		s cr.
		s nextPutAll: (self worldPoint) printString]
]

{ #category : 'accessing' }
GdsNullTool >> currentItem [
	^self structure currentItem.
]

{ #category : 'drawing' }
GdsNullTool >> drawFeedbackOn: aLocalCanvas [.
]

{ #category : 'drawing' }
GdsNullTool >> drawRubberBandOn: aLocalCanvas currentPoint: aPoint [ 
	
]

{ #category : 'drawing' }
GdsNullTool >> drawRubberBandOn: aLocalCanvas currentPoint: aPoint boundsBlock: aBoundsBlock [

	| bounds |
	referencePoint ifNil: [ ^ self ].
	bounds := Rectangle encompassing:
		          (Array with: referencePoint with: aPoint).
	morph deltaLocationPane ifNotNil: [ :deltaLocationMorph | 
		morph
			showLocationPane: deltaLocationMorph
			at: bounds center
			contents: ('W:{1} H:{2} L:{3}' format: ({ 
						  bounds width.
						  bounds height.
						  (referencePoint distanceTo: aPoint) } collect: [ :each | 
						  each printShowingDecimalPlaces: 3 ])) ].
	aBoundsBlock value: bounds.
	oldRubberBandBounds ifNotNil: [ 
		morph invalidBounds: oldRubberBandBounds ].
	morph invalidBounds: bounds.
	oldRubberBandBounds := bounds copy
]

{ #category : 'drawing' }
GdsNullTool >> drawRubberBandOn: aLocalCanvas currentPoint: aPoint segmentBlock: aSegmentBlock [
	self 
		drawRubberBandOn:  aLocalCanvas 
		currentPoint:  aPoint 
		boundsBlock: [:b | "ignore bounds"
			aSegmentBlock value: referencePoint value: aPoint.] .
	
	
]

{ #category : 'action' }
GdsNullTool >> eachAction [
	self subclassResponsibility.
]

{ #category : 'action-pattern' }
GdsNullTool >> elementDetectAction [
	| found resultPoint | 
	resultPoint := self snapedWorldPoint2.
	found := self findNearestElementByPoint: resultPoint.
	self eventActionAt: resultPoint element: found.
	
]

{ #category : 'action' }
GdsNullTool >> evenAction [
	self subclassResponsibility.
]

{ #category : 'action-pattern' }
GdsNullTool >> evenOddAction [
	self upCount.
	self canFinish ifTrue: [^self finish].	
	self clickCount = 1
		ifTrue: [self firstAction].
	self clickCount \\ 2 = 0
		ifTrue: [
			self evenAction.
			morph hideRubberbandLocationPanes.]
		ifFalse: [self oddAction].

]

{ #category : 'action' }
GdsNullTool >> eventAction [
	self consoleOut.
]

{ #category : 'action' }
GdsNullTool >> eventActionAt: aWorldPoint element: aGdsElement [
	self subclassResponsibility.	
]

{ #category : 'accessing' }
GdsNullTool >> findNearestElementByPoint: resultPoint [
	^morph findNearestElementByPoint: resultPoint.
	
]

{ #category : 'action' }
GdsNullTool >> findPoints: aPoint ifAbsent: aBlock [
	| foundElements crossPoints targetPoints vertexPoints box |
	morph visibleElements ifEmpty: [ ^ #() ].
	box := self findRectOfCenter: aPoint.
	foundElements := self structure
		findNearestElementsByPoint: aPoint
		elements: morph visibleElements.
	foundElements ifEmpty: [ ^ #() ].
	vertexPoints := GdsElement vertexPointsOfElements: foundElements.
	crossPoints := GdsElement crossPointsOfElements: foundElements.
	targetPoints := (crossPoints , vertexPoints) asSet select: [ :p | box containsPoint: p ].
	targetPoints ifEmpty: [ aBlock cull: foundElements cull: vertexPoints cull: crossPoints ].
	^ targetPoints asArray
]

{ #category : 'as yet unclassified' }
GdsNullTool >> findRectOfCenter: aCenterPoint [
	^ self findRectOfCenter: aCenterPoint halfSize: 6.
]

{ #category : 'as yet unclassified' }
GdsNullTool >> findRectOfCenter: aCenterPoint  halfSize: aHalfSize [
	| size |
	size := aHalfSize / morph viewport absoluteScale asPoint.
	^ GeometryUtils lookupDataBounds: {(aCenterPoint - size) . (aCenterPoint + size) }.

]

{ #category : 'action' }
GdsNullTool >> finish [
	morph clearTool.
	morph hideRubberbandLocationPanes.
	
]

{ #category : 'action' }
GdsNullTool >> firstAction [
	self subclassResponsibility.
]

{ #category : 'action-pattern' }
GdsNullTool >> firstAndSecondAction [
	self upCount.
	self canFinish ifTrue: [^self finish].	
	self clickCount = 1
		ifTrue: [self firstAction]
		ifFalse: [self afterSecondAction].

]

{ #category : 'accessing' }
GdsNullTool >> globalPoint [
	^event cursorPoint.
]

{ #category : 'accessing' }
GdsNullTool >> idSelection [
	^self structure idSelection.
]

{ #category : 'initialize-release' }
GdsNullTool >> initialize [
	super initialize.
	clickCount := 0.
	lastPoint := 0@0.
]

{ #category : 'accessing' }
GdsNullTool >> localPoint [
	^morph morphicPointFromGlobal:  self globalPoint.
]

{ #category : 'drawing' }
GdsNullTool >> markOffsetFeedbackOn: aLocalCanvas [
	self clickCount = 0 ifTrue: [^self].
	referencePoint  ifNotNil: [morph drawOn: aLocalCanvas markDiamondPointAt: referencePoint].
	self clickCount >= 2 ifTrue: [.
		lastPoint ifNotNil: [morph drawOn: aLocalCanvas markDiamondPointAt: lastPoint].].
]

{ #category : 'drawing' }
GdsNullTool >> markUpdateBounds: aPoint [
	| upBounds |
	upBounds := Rectangle center: (morph viewport xy2hv: aPoint) extent: 10@10.
	upBounds := upBounds translateBy: morph pixelBounds origin.
	^upBounds

]

{ #category : 'event handling' }
GdsNullTool >> mouseDown: anEvent [
	self setEvent: anEvent.
	self eventAction. 
	GdsFeelMorphic clickSoundEnabled 
		ifTrue: ["SoundService default playSoundNamed: 'click' "].
	
]

{ #category : 'event handling' }
GdsNullTool >> mouseMove: anEvent [
	
]

{ #category : 'event handling' }
GdsNullTool >> mouseOver: anEvent [
	
]

{ #category : 'event handling' }
GdsNullTool >> mouseUp: anEvent [
	
]

{ #category : 'action' }
GdsNullTool >> oddAction [
	self subclassResponsibility.
]

{ #category : 'offset action' }
GdsNullTool >> offsetAction: aBlock [
	self prompt: self afterSecondMessage.
	deltaPoint := self snapedWorldPoint2 - referencePoint.
	aBlock value. "using #relativeOffset"
	lastDeltaPoint := deltaPoint copy.
	lastPoint := self snapedWorldPoint2.

]

{ #category : 'accessing' }
GdsNullTool >> prompt: aStringOrBlock [
	(aStringOrBlock isKindOf: BlockClosure )
		ifTrue: [
			Transcript cr; show: (String streamContents: [:stream |
				aStringOrBlock value: stream])]
		ifFalse: [Transcript cr; show: aStringOrBlock].
]

{ #category : 'prompt message' }
GdsNullTool >> referenceMessage [
	^'Enter Reference Coordinate:'.
]

{ #category : 'accessing' }
GdsNullTool >> relativeOffset [
	^deltaPoint - lastDeltaPoint
]

{ #category : 'action-pattern' }
GdsNullTool >> repeatEachAction [
	self upCount.
	self canFinish ifTrue: [^self finish].	
	self eachAction.
	self canFinish ifTrue: [^self finish].	

]

{ #category : 'testing' }
GdsNullTool >> rubberBandEnabled [
	^false
]

{ #category : 'offset action' }
GdsNullTool >> saveReferencePoint [
	referencePoint := self snapedWorldPoint2.
	lastDeltaPoint := 0 @ 0.
	morph referenceLocationPane
		ifNotNil:
			[ :ocationMorph | morph showLocationPane: ocationMorph at: referencePoint ]
]

{ #category : 'private' }
GdsNullTool >> setEvent: aEvent [
	event := aEvent.
	
]

{ #category : 'private' }
GdsNullTool >> setMorph: aMorph [
	morph := aMorph.
	
]

{ #category : 'accessing' }
GdsNullTool >> snapedWorldPoint [
	^self snapedWorldPoint: self worldPoint.
]

{ #category : 'accessing' }
GdsNullTool >> snapedWorldPoint2 [
	^self snapedWorldPoint2: self worldPoint.
]

{ #category : 'accessing' }
GdsNullTool >> snapedWorldPoint2: aWorldPoint [
	| pointsStage1  |
	pointsStage1 := self findPoints: aWorldPoint ifAbsent: [ ^ self snapedWorldPoint: aWorldPoint ].
	pointsStage1 size >= 2 ifTrue: [ self inform: 'multiple points found' ].
	pointsStage1 size = 1
		ifTrue: [ ^ pointsStage1 first ].
	^ self snapedWorldPoint: aWorldPoint 
	
]

{ #category : 'accessing' }
GdsNullTool >> snapedWorldPoint: aWorldPoint [
	^morph viewport snapedWorldPoint:  aWorldPoint.
]

{ #category : 'action' }
GdsNullTool >> stopCE [
	self subclassResponsibility
]

{ #category : 'accessing' }
GdsNullTool >> structure [
	^morph structure
]

{ #category : 'event handling' }
GdsNullTool >> toolDidChange [

]

{ #category : 'action' }
GdsNullTool >> upCount [
	clickCount := clickCount + 1.

]

{ #category : 'accessing' }
GdsNullTool >> userInfo [
	^userInfo
]

{ #category : 'accessing' }
GdsNullTool >> userInfo: anObject [
	userInfo := anObject.
]

{ #category : 'accessing' }
GdsNullTool >> worldPoint [
	^morph viewport worldPointFromGlobal:  self globalPoint.
]

{ #category : 'event handling' }
GdsNullTool >> worldPointFromGlobalEvent: anEvent [
	^ morph viewport worldPointFromGlobal: anEvent cursorPoint.
]
