Class {
	#name : #GdsNewTool,
	#superclass : #GdsAbstractIdTool,
	#instVars : [
		'downTimeStamp',
		'upTimeStamp',
		'moveCount',
		'shiftCount',
		'worldPoints',
		'findRect',
		'prevOverPoint',
		'oldFindRect',
		'upDragging'
	],
	#category : #'GdsFeel-UI-Tools'
}

{ #category : #'as yet unclassified' }
GdsNewTool >> findPoint: aMouseEvent [
	findRect := self findRectOfCenter: (self worldPointFromGlobalEvent: aMouseEvent)
]

{ #category : #'as yet unclassified' }
GdsNewTool >> initialize [
	super initialize.
	worldPoints := OrderedCollection new.
	upDragging := false.
]

{ #category : #'event handling' }
GdsNewTool >> mouseDown: anEvent [
	anEvent traceCr.
	moveCount := 0.
	shiftCount := 0.
	anEvent shiftPressed
		ifTrue: [ shiftCount := 1 ].
	downTimeStamp := anEvent timeStamp.
	worldPoints add: (self worldPointFromGlobalEvent: anEvent).
	upDragging
		ifTrue: [ worldPoints first ~= worldPoints last
				ifTrue: [ self rangeAction: anEvent.
					worldPoints removeAll.
					upDragging := false.
					^ self ] ]
]

{ #category : #'event handling' }
GdsNewTool >> mouseMove: anEvent [
	self moveHandler: anEvent.
]

{ #category : #'event handling' }
GdsNewTool >> mouseOver: anEvent [
	upDragging 
		ifTrue: [	
			self rangeMouseOver: anEvent].
]

{ #category : #'event handling' }
GdsNewTool >> mouseUp: anEvent [
	| ellapsedTime |
	downTimeStamp ifNil: [ ^ self ].
	worldPoints add: (self worldPointFromGlobalEvent: anEvent).
	anEvent traceCr.
	anEvent shiftPressed
		ifTrue: [ shiftCount := shiftCount + 1 ].
	upTimeStamp := anEvent timeStamp.
	ellapsedTime := upTimeStamp - downTimeStamp.
	ellapsedTime traceCr.
	moveCount = 0
		ifTrue: [ 
			ellapsedTime < 500
				ifTrue: [ 
					self singleAction: anEvent.
					worldPoints removeAll ]
				ifFalse: [ 
					upDragging := true.
					self inform: 'start dragging' ] ]
		ifFalse: [ 
			worldPoints first ~= worldPoints last
				ifTrue: [ 
					self rangeAction: anEvent.
					worldPoints removeAll ] ].
	morph removeFeedbackCanvas.

]

{ #category : #'event handling' }
GdsNewTool >> moveHandler: anEvent [
	moveCount ifNil: [ moveCount := 0 ].
	worldPoints add: (self worldPointFromGlobalEvent: anEvent).
	"anEvent traceCr."	
	self findPoint: anEvent.
	moveCount := moveCount + 1.
	moveCount = 1
		ifTrue: [
			referencePoint := worldPoints first.].
	morph rubberbandPoint: worldPoints last.
]

{ #category : #'event handling' }
GdsNewTool >> rangeMouseOver: anEvent [
	prevOverPoint ifNil: [ prevOverPoint := 0 @ 0 ].
	prevOverPoint = anEvent cursorPoint
		ifFalse: [ 
			prevOverPoint := anEvent cursorPoint.
			self moveHandler: anEvent.
			"(anEvent asString , anEvent timeStamp asString) traceCr" ]
]

{ #category : #'as yet unclassified' }
GdsNewTool >> rubberBandEnabled [
	moveCount ifNil: [ moveCount := 0 ].
	^ moveCount > 0
]
