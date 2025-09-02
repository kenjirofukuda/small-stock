Class {
	#name : #GdaStructureReference,
	#superclass : #GdaReferenceElement,
	#instVars : [
		'sname',
		'refStructure'
	],
	#category : #'GdsFeel-Model-Atomic'
}

{ #category : #testing }
GdaStructureReference class >> isGdsOriginalClass [

	^ true
]

{ #category : #accessing }
GdaStructureReference class >> type [

	^ #sref
]

{ #category : #accessing }
GdaStructureReference >> children [

	^ self refStructure children
]

{ #category : #testing }
GdaStructureReference >> explodable [

	^ true
]

{ #category : #initialization }
GdaStructureReference >> initialize [

	super initialize.
	sname := ''
]

{ #category : #accessing }
GdaStructureReference >> localBounds [

	^ self lookupLocalBounds
]

{ #category : #private }
GdaStructureReference >> lookupBasicExtentPoints [

	^ GeometryUtils verticesFromBounds: self localBounds
]

{ #category : #protected }
GdaStructureReference >> lookupExtentPoints [

	^ self lookupBasicExtentPoints collect: [ :each | 
		  self transform transformPoint: each ]
]

{ #category : #private }
GdaStructureReference >> lookupLocalBounds [

	^ self refStructure dataExtentForElements
]

{ #category : #printing }
GdaStructureReference >> printSelfOn: aStream [

	sname ifNil: [ ^ self ].
	aStream nextPut: $,.
	aStream nextPutAll: self structureName
]

{ #category : #accessing }
GdaStructureReference >> refStructure [

	refStructure ifNil: [ 
		refStructure := self structure library structureNamed:
			                self structureName ].
	^ refStructure
]

{ #category : #accessing }
GdaStructureReference >> repeatTransforms [

	^ self relativeTransforms collect: [ :each | 
		  self transform copy composedWithLocal: each ]
]

{ #category : #'accessing - basic' }
GdaStructureReference >> structureName [

	^ sname
]

{ #category : #'accessing - basic' }
GdaStructureReference >> structureName: aString [

	sname := aString.
	self changed: #sname
]
