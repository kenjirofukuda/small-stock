Class {
	#name : #GdaBoundary,
	#superclass : #GdaPrimitiveElement,
	#category : #'GdsFeel-Model2-Container'
}

{ #category : #testing }
GdaBoundary class >> isGdsOriginalClass [

	^ true
]

{ #category : #validation }
GdaBoundary class >> requiredVertexCount [

	^ 3
]

{ #category : #accessing }
GdaBoundary class >> type [

	^ #boundary
]

{ #category : #'accessing - validation' }
GdaBoundary >> validateVertices: aPointArray [

	| points |
	points := super validateVertices: aPointArray.
	points first = points last ifFalse: [ 
		points := aPointArray asOrderedCollection.
		points add: points first ].
	^ points asArray
]

{ #category : #accessing }
GdaBoundary >> vertexCount [

	(self vertices size >= 3 and: [ 
		 self vertices first = self vertices last ]) ifTrue: [ 
		^ self vertices size - 1 ].
	^ super vertexCount
]
