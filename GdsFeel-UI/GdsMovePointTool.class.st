"
A GdsMovePointTool is xxxxxxxxx.

Instance Variables
	analisysResult:		<Dictionary>
	moveToPoint:		<Point>
	replaceVertexIndex:		<Integer>

analisysResult
	- xxxxx

moveToPoint
	- xxxxx

replaceVertexIndex
	- xxxxx

"
Class {
	#name : #GdsMovePointTool,
	#superclass : #GdsNullTool,
	#instVars : [
		'analisysResult',
		'replaceVertexIndex',
		'moveToPoint'
	],
	#category : #'GdsFeel-UI-Tools'
}

{ #category : #action }
GdsMovePointTool >> afterSecondAction [
	self moveToVertex.		
]

{ #category : #testing }
GdsMovePointTool >> autoFinishAfterPut [
	^true
]

{ #category : #action }
GdsMovePointTool >> calcUpdateBounds [
	| p1 p2 p3 p4 |
	p1 := nil.
	p2 := nil.
	replaceVertexIndex >=2 
		ifTrue: [p1 := self currentItem vertices at: (replaceVertexIndex - 1)].
	replaceVertexIndex <=  (self currentItem vertices size - 1)
		ifTrue: [p2 := self currentItem vertices at: (replaceVertexIndex + 1)].
	(self currentItem isBoundary and:[
		replaceVertexIndex = 1 or: [replaceVertexIndex = self currentItem vertices size]])
			ifTrue: [
				p1 := self currentItem vertices at: 2.
				p2 := self currentItem vertices at: (self currentItem vertices size - 1).].	 	
	p3 := referencePoint.
	p4 := moveToPoint.
	^GeometryUtils lookupDataBounds: ({ p1 . p2 . p3 . p4 } reject: [:each | each isNil]).

	

]

{ #category : #'prompt message' }
GdsMovePointTool >> coodinateMessage [
	^self multiMoveSupported 
		ifTrue: ['Coordinate(s):']
		ifFalse: ['Coordinate:']
]

{ #category : #drawing }
GdsMovePointTool >> drawFeedbackOn: aLocalCanvas [
	analisysResult ifNil: [^self].
	({ referencePoint . moveToPoint } reject: [:each | each isNil])
		do: [:each | morph drawOn: aLocalCanvas markDiamondPointAt: each].
]

{ #category : #action }
GdsMovePointTool >> eventAction [
	self firstAndSecondAction.
	self prompt: self moveToMessage.
	morph invalidBounds: self calcUpdateBounds .

]

{ #category : #action }
GdsMovePointTool >> firstAction [
	analisysResult := GeometryUtils 
		analisysSegmentsAt: (self snapedWorldPoint2) pointArray: self currentItem vertices.
	"analisysResult inspect."
	replaceVertexIndex := self lookupReplaceVertexIndex. 
	(self currentItem holdsElement)
		ifTrue: [referencePoint := self currentItem vertices at: replaceVertexIndex]
		
]

{ #category : #action }
GdsMovePointTool >> lookupReplaceVertexIndex [
	^GeometryUtils lookupVertexIndex: analisysResult
]

{ #category : #'prompt message' }
GdsMovePointTool >> moveToMessage [
	^'Move to:'
]

{ #category : #action }
GdsMovePointTool >> moveToVertex [
	moveToPoint := self snapedWorldPoint2.
	self currentItem 
		verticesAt: replaceVertexIndex  
		put: moveToPoint copy 
		fixClosed: (self currentItem isBoundary).

	
]

{ #category : #testing }
GdsMovePointTool >> multiMoveSupported [
	^false
]

{ #category : #action }
GdsMovePointTool >> toolDidChange [
	self prompt: self coodinateMessage.
]
