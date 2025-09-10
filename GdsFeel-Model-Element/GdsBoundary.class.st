"
A GdsBoundary is GDS II's BOUNDARY.

Instance Variables

"
Class {
	#name : #GdsBoundary,
	#superclass : #GdsPrimitiveElement,
	#category : #'GdsFeel-Model-Element'
}

{ #category : #testing }
GdsBoundary class >> isGdsOriginalClass [

	^ true
]

{ #category : #accessing }
GdsBoundary class >> requiredVertexCount [

	^ 3
]

{ #category : #accessing }
GdsBoundary class >> type [

	^ #boundary
]

{ #category : #visiting }
GdsBoundary >> accept: aVisitor [
	^ aVisitor visitBoundary: self
]

{ #category : #testing }
GdsBoundary >> isVisible [

	^ super isVisible and: [ 
		  (self structure kinds atKey: 'BD') isVisible ]
]

{ #category : #accessing }
GdsBoundary >> validateVertices: aPointArray [
	| points |
	points := super validateVertices: aPointArray.
	(points first = points last)
		ifFalse: [
			points := aPointArray asOrderedCollection.
			points add: points first].
	^points asArray.
]

{ #category : #accessing }
GdsBoundary >> validateVertices: aPointArray editorContext: aGdsEditorContext [
	| points vPoint ce1 |
	points := super validateVertices: aPointArray.
	ce1 := points last.
	(points first = ce1)
		ifFalse: [
			points := aPointArray asOrderedCollection.
			vPoint := aGdsEditorContext completionPointFrom: ce1 to: points first.
			vPoint ifNotNil:[
				(aGdsEditorContext digitaizingMode = #orthint)
					ifTrue: [
						points last = vPoint
							ifFalse:[points add: vPoint.]]]. 
			points add: points first].
	^points asArray.
]

{ #category : #accessing }
GdsBoundary >> vertexCount [
	((self vertices size >= 3) and:
	[self vertices first = self vertices last])
		ifTrue: [^self vertices size - 1].
	^super vertexCount
]
