Class {
	#name : 'GdsClickTestTool',
	#superclass : 'GdsNewTool',
	#category : 'GdsFeel-UI-Tools',
	#package : 'GdsFeel-UI',
	#tag : 'Tools'
}

{ #category : 'action' }
GdsClickTestTool >> absentAction: foundElements [
	| savedColors |
	savedColors := foundElements collect: [ :e | e ownColor ].
	foundElements do: [ :e | e ownColor: Color brown twiceLighter ].
	morph markElementKeys.
	(foundElements
		collect: [ :e | 
			e
				->
					(DistanceContext
						fromPoint: worldPoints last
						lineSegment: (LineSegment from: e vertices first to: e vertices second)) ]) explore.
	[ (Delay forSeconds: 7) wait.
	foundElements doWithIndex: [ :e :i | e ownColor: (savedColors at: i) ] ] fork
]

{ #category : 'as yet unclassified' }
GdsClickTestTool >> canFinish [
	^ userInfo notNil
]

{ #category : 'as yet unclassified' }
GdsClickTestTool >> drawFindRectOn: aLocalCanvas currentPoint: aPoint [ 
	| vert1 vert2 updateBounds findBounds |
	findBounds := self findRectOfCenter: aPoint.
	morph drawOn: aLocalCanvas strokeBounds: findBounds.
	oldFindRect ifNil: [ oldFindRect := findBounds copy ].
	vert1 := GeometryUtils verticesFromBounds: oldFindRect.
	vert2 := GeometryUtils verticesFromBounds: findBounds.
	updateBounds := GeometryUtils lookupDataBounds: (vert1, vert2).
	morph invalidBounds: updateBounds.
]

{ #category : 'as yet unclassified' }
GdsClickTestTool >> drawRubberBandOn: aLocalCanvas currentPoint: aPoint [ 
	self drawFindRectOn: aLocalCanvas currentPoint: aPoint
]

{ #category : 'event handling' }
GdsClickTestTool >> mouseOver: anEvent [
	self rangeMouseOver: anEvent
]

{ #category : 'as yet unclassified' }
GdsClickTestTool >> rangeAction: aMouseButtonEvent [
	| bounds idElements actionSelector |
	actionSelector := shiftCount > 0
		ifTrue: [ #unIdAll: ]
		ifFalse: [ #idAddAll: ].
	bounds := Rectangle
		encompassing:
			{worldPoints first.
			worldPoints last}.
	idElements := (self idEnabledElementsInverted: actionSelector = #unIdAll:)
		select: [ :each | each dataBounds intersects: bounds ].
	"self structure idSelection perform: actionSelector with: (idElements collect: [:e | e keyNumber]).	"
	morph removeFeedbackCanvas.
	referencePoint := nil
]

{ #category : 'as yet unclassified' }
GdsClickTestTool >> rubberBandEnabled [
	^ true
]

{ #category : 'action' }
GdsClickTestTool >> singleAction: anEvent [
	| targetPoints |
	targetPoints := self
		findPoints: worldPoints last
		ifAbsent: [ :a :b :c | "{a . b . c } explore" ].
	userInfo
		ifNotNil: [ userInfo isBlock
				ifTrue: [ userInfo cull: targetPoints cull: self cull: worldPoints last copy ] ].
	morph markPoints: targetPoints.
	targetPoints do: [ :p | self inform: p asString ]
]
