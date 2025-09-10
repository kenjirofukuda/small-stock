Class {
	#name : #GdsVertexInputTool,
	#superclass : #GdsNullTool,
	#instVars : [
		'lastRubberBandPoint'
	],
	#category : #'GdsFeel-UI-Tools'
}

{ #category : #testing }
GdsVertexInputTool >> autoFinishAfterPut [

	^ true
]

{ #category : #testing }
GdsVertexInputTool >> canFinish [

	^ self currentItem putEnabled and: [ 
		  self currentItem vertices last = self snapedWorldPoint2 ]
]

{ #category : #drawing }
GdsVertexInputTool >> drawFeedbackOn: aLocalCanvas [

	self currentItem isReferenceType
		ifTrue: [ morph drawItemReferencesOn: aLocalCanvas ]
		ifFalse: [ morph drawItemVerticesOn: aLocalCanvas ]
]

{ #category : #drawing }
GdsVertexInputTool >> drawRubberBandOn: aLocalCanvas currentPoint: aPoint [

	| points wp1 vwp |
	self structure currentItem editElement ifNotNil: [ ^ self ].
	self structure currentItem isReferenceType ifTrue: [ ^ self ].
	points := self structure currentItem vertices.
	points ifEmpty: [ 
		morph removeFeedbackCanvas.
		^ self ].
	wp1 := points last.
	vwp := self structure currentItem completionPointFrom: wp1 to: aPoint.
	vwp
		ifNil: [ morph drawOn: aLocalCanvas lineFrom: wp1 to: aPoint ]
		ifNotNil: [ 
			vwp := self snapedWorldPoint2: vwp.
			morph drawOn: aLocalCanvas lineFrom: wp1 to: vwp.
			self structure currentItem digitaizingMode = #octagonal ifFalse: [ 
				morph drawOn: aLocalCanvas lineFrom: vwp to: aPoint ] ].
	lastRubberBandPoint ifNotNil: [ 
		morph invalidBoundsFromPoint1: wp1 point2: lastRubberBandPoint ].
	morph invalidBoundsFromPoint1: wp1 point2: aPoint.
	lastRubberBandPoint := aPoint copy
]

{ #category : #action }
GdsVertexInputTool >> eventAction [

	| vPoint ce1 points |
	points := self currentItem vertices.
	"points ifEmpty: [self item boundary.].	"
	self canFinish ifTrue: [ "self item put.
			morph removeOffCanvas.
			morph changed."
		self stopCE.
		^ self finish ].
	ce1 := self snapedWorldPoint2.
	points isEmpty
		ifTrue: [ self currentItem ce: ce1 ]
		ifFalse: [ 
			self currentItem digitaizingMode = #straight ifTrue: [ 
				self currentItem ce: ce1.
				morph invalidBoundsFromPoint1: ce1 point2: points last ].
			vPoint := self currentItem completionPointFrom: points last to: ce1.
			vPoint ifNotNil: [ 
				vPoint := self snapedWorldPoint2: vPoint.
				self currentItem ce: vPoint.
				self currentItem digitaizingMode = #orthint
					ifTrue: [ 
						morph invalidBoundsFromPoint1: vPoint point2: points last.
						self currentItem ce: ce1.
						morph invalidBoundsFromPoint1: ce1 point2: points last ]
					ifFalse: [ 
					morph invalidBoundsFromPoint1: vPoint point2: points last ] ] ].
	morph invalidRect: (self markUpdateBounds: ce1)
]

{ #category : #initialization }
GdsVertexInputTool >> initialize [

	super initialize.
	stopCE := false
]

{ #category : #testing }
GdsVertexInputTool >> rubberBandEnabled [

	stopCE ifNil: [ stopCE := false ].
	^ stopCE not
]

{ #category : #action }
GdsVertexInputTool >> stopCE [

	stopCE := true
]
