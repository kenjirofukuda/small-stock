Class {
	#name : #GdsDegreesProperty,
	#superclass : #GdsFloatProperty,
	#category : #'GdsFeel-Foundation-Property'
}

{ #category : #private }
GdsDegreesProperty >> angle360: aDegree [
	| rem |
	rem := aDegree asFloat rem: 360.0.
	^aDegree negative ifTrue: [360.0 + rem] ifFalse: [rem].
]

{ #category : #private }
GdsDegreesProperty >> getValue [
	^self angle360: super getValue.
]

{ #category : #private }
GdsDegreesProperty >> newValue: aDegree [
	^self angle360: aDegree
]

{ #category : #private }
GdsDegreesProperty >> oldValue [
	^self angle360: super oldValue
]
