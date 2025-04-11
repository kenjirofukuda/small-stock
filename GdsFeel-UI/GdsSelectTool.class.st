Class {
	#name : 'GdsSelectTool',
	#superclass : 'GdsNewTool',
	#category : 'GdsFeel-UI-Tools',
	#package : 'GdsFeel-UI',
	#tag : 'Tools'
}

{ #category : 'as yet unclassified' }
GdsSelectTool >> drawRubberBandOn: aLocalCanvas currentPoint: aPoint [ 
	self
		drawRubberBandOn: aLocalCanvas
		currentPoint: aPoint
		boundsBlock: [:bounds | morph drawOn: aLocalCanvas strokeBounds: bounds]
]

{ #category : 'as yet unclassified' }
GdsSelectTool >> rangeAction: aMouseButtonEvent [ 
	| bounds idElements actionSelector |
	actionSelector := shiftCount > 0
		ifTrue: [ #unIdAll: ]
		ifFalse: [ #idAddAll: ].
	bounds := Rectangle encompassing: {  worldPoints first. worldPoints last  }.
	idElements := (self idEnabledElementsInverted: (actionSelector = #unIdAll:)) 
		select: [ :each | each dataBounds intersects: bounds ].
	self structure idSelection perform: actionSelector with: (idElements collect: [:e | e keyNumber]).	
	morph removeFeedbackCanvas.
	referencePoint := nil.

]

{ #category : 'as yet unclassified' }
GdsSelectTool >> rubberBandEnabled [
	moveCount ifNil: [ moveCount := 0 ].
	^ moveCount > 0
]

{ #category : 'action' }
GdsSelectTool >> singleAction: anEvent [
	| actionSelector  foundElement pixelDistance targetElements |
	actionSelector := shiftCount > 0
		ifTrue: [ #unId: ]
		ifFalse: [ #idAdd: ].
	targetElements := self idEnabledElementsInverted: actionSelector = #unId:.
	targetElements ifEmpty: [ ^ self inform: 'no element' ].
	foundElement := self structure 
		findNearestElementByPoint: worldPoints last
		elements: targetElements.
	foundElement ifNil: [ ^ self inform: 'no element'].
	pixelDistance := morph viewport pixelSize: (foundElement dist: worldPoints last).
	pixelDistance > 10 ifTrue: [ ^ self inform: 'no element+', pixelDistance asString ].
	morph structure idSelection perform: actionSelector with: foundElement keyNumber.

		
]
