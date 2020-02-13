"
A GdsStructureReference is GDS II's SREF.

Instance Variables

"
Class {
	#name : #GdsStructureReference,
	#superclass : #GdsReferenceElement,
	#instVars : [
		'sname',
		'refStructure'
	],
	#category : #'GdsFeel-Model-Element'
}

{ #category : #testing }
GdsStructureReference class >> isGdsOriginalClass [
	^ true
]

{ #category : #accessing }
GdsStructureReference class >> type [
	^#sref
]

{ #category : #visiting }
GdsStructureReference >> accept: aVisitor [
	^ aVisitor visitSref: self
]

{ #category : #'objects from disk' }
GdsStructureReference >> attributesFrom: aDictionary [
	super attributesFrom: aDictionary.
	self structureName: (aDictionary at: 'sname' ifAbsent: ['ERRREF']) asString.
	self angle: (aDictionary at: 'angle' ifAbsent: [0.0]) asNumber.
	self mag: (aDictionary at: 'mag' ifAbsent: [1.0]) asNumber.	
	self setReflected: ((aDictionary at: 'reflected' ifAbsent: [false]) asString sameAs: 'true').	
	
]

{ #category : #'objects from disk' }
GdsStructureReference >> attributesOn: aDictionary [
	super attributesOn: aDictionary.
	aDictionary at: 'sname' put: self structureName asString.
	(self angle closeTo: 0.0)
		ifFalse: [
			aDictionary at: 'angle' put: self angle].	
	(self mag closeTo: 1.0)
		ifFalse: [
			aDictionary at: 'mag' put: self mag].
	self isReflected 
		ifTrue: [	
			aDictionary at: 'reflected' put: self isReflected].					
]

{ #category : #accessing }
GdsStructureReference >> children [
	^ self refStructure children
]

{ #category : #testing }
GdsStructureReference >> explodable [
	^ true
]

{ #category : #initialization }
GdsStructureReference >> fromItemContext: aGdsItemContext atIndex: aVerticesIndex [
	super fromItemContext:  aGdsItemContext atIndex: aVerticesIndex.
	self structureName: aGdsItemContext structureName.
]

{ #category : #initialization }
GdsStructureReference >> initialize [
	super initialize.
	sname := ''.
]

{ #category : #testing }
GdsStructureReference >> isVisible [
	| defaultResult |
	defaultResult := super isVisible.
	defaultResult
		ifFalse: [ ^ false ].
	self refStructure ifNil: [ ^ false ].
	^ self refStructure valueOfProperty: #visible ifAbsent: [true].
		
	
]

{ #category : #'objects from disk' }
GdsStructureReference >> loadFromXmlNode: aXmlNode [
	super loadFromXmlNode: aXmlNode.
	self xy: self vertices first.

]

{ #category : #accessing }
GdsStructureReference >> localBounds [
	^self lookupLocalBounds.
	 	 			
]

{ #category : #private }
GdsStructureReference >> lookupBasicExtentPoints [
	^GeometryUtils verticesFromBounds: self localBounds.
	 	 			
]

{ #category : #protected }
GdsStructureReference >> lookupExtentPoints [
	^ self lookupBasicExtentPoints collect: [ :each | self transform transformPoint: each ]
]

{ #category : #private }
GdsStructureReference >> lookupLocalBounds [
	^self refStructure dataExtentForElements.
	 	 			
]

{ #category : #printing }
GdsStructureReference >> printSelfOn: aStream [
	sname ifNil: [^self].
	aStream nextPut: $,.
	aStream nextPutAll: self structureName
]

{ #category : #accessing }
GdsStructureReference >> refStructure [
	refStructure ifNil: [
		refStructure := self structure library structureNamed: self structureName.].
	^refStructure
]

{ #category : #accessing }
GdsStructureReference >> repeatTransforms [
	^ self relativeTransforms collect: [:each | 
		self transform copy composedWithLocal: each].	
]

{ #category : #accessing }
GdsStructureReference >> structureName [
	^sname
	
]

{ #category : #accessing }
GdsStructureReference >> structureName: aString [
	sname := aString.
	self changed: #sname.
	
]
