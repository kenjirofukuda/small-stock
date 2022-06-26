Class {
	#name : #GplCoords,
	#superclass : #GplSingleHandler,
	#category : #'GdsFeel-CLI-Commands'
}

{ #category : #testing }
GplCoords class >> isFunctionAllowed [
	^ true
]

{ #category : #testing }
GplCoords class >> isNiladicAllowed [
	^ true
]

{ #category : #accessing }
GplCoords class >> methodName [
	^ 'COORDS'
]

{ #category : #handler }
GplCoords >> evaluateToken: aToken [
	| values |
	values := OrderedCollection new.
	self currentItem vertices
		do: [ :pt | 
			values add: pt x.
			values add: pt y ].
	values ifEmpty: [ ^ self nullVector ].
	^ GdsMatrix
		fromGdsVector: (GdsVector withAll: (self floatVector: values))
		row: self currentItem vertices size
		col: 2
]
