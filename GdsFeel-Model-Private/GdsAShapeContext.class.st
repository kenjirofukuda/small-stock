"
A GdsArefContext is GDS II's ASHAPE value holder.

Instance Variables

"
Class {
	#name : #GdsAShapeContext,
	#superclass : #Model,
	#traits : 'TGdsExchange',
	#classTraits : 'TGdsExchange classTrait',
	#instVars : [
		'columnCount',
		'rowCount',
		'xStep',
		'yStep',
		'propertyOwner',
		'transforms',
		'offsets'
	],
	#category : #'GdsFeel-Model-Private'
}

{ #category : #accessing }
GdsAShapeContext >> asRequestString [
	^ GdsFeel join: (self values collect: [ :each | each asString ]) using: ' '
]

{ #category : #'objects from disk' }
GdsAShapeContext >> attributesFrom: aDictionary [
	self columnCount: (aDictionary at: 'cols' ifAbsent: [ 1 ]) asInteger.
	self rowCount: (aDictionary at: 'rows' ifAbsent: [ 1 ]) asInteger.
	self xStep: (aDictionary at: 'column-spacing' ifAbsent: [ 0.0 ]) asNumber.
	self yStep: (aDictionary at: 'row-spacing' ifAbsent: [ 0.0 ]) asNumber
]

{ #category : #'xml/json data exchange' }
GdsAShapeContext >> attributesOn: aDictionary [
	self columnCount >= 2
		ifTrue: [ aDictionary at: 'cols' put: self columnCount ].
	self rowCount >= 2
		ifTrue: [ aDictionary at: 'rows' put: self rowCount ].
	(self xStep closeTo: 0.0)
		ifFalse: [ aDictionary at: 'column-spacing' put: self xStep ].
	(self yStep closeTo: 0.0)
		ifFalse: [ aDictionary at: 'row-spacing' put: self yStep ]
]

{ #category : #updating }
GdsAShapeContext >> changed: anObject [
	propertyOwner ifNil: [ ^ super changed: anObject ].
	propertyOwner changed: anObject.
	super changed: anObject
]

{ #category : #accessing }
GdsAShapeContext >> columnCount [
	^columnCount
]

{ #category : #accessing }
GdsAShapeContext >> columnCount: anInteger [
	self assert: [ anInteger isNumber ].
	self assert: [ anInteger > 0 ] description: 'columnCount >= 1'.
	columnCount = anInteger asInteger
		ifTrue: [ ^ self ].
	columnCount := anInteger asInteger.
	self refreshBounds.
	self changed: #columnCount
]

{ #category : #printing }
GdsAShapeContext >> consoleStringOn: aStream [
	aStream nextPutAll: 'COLUMNS: '.
	aStream print: self columnCount.
	aStream cr.
	aStream nextPutAll: 'ROWS: '.
	aStream print: self rowCount.
	aStream cr.
	aStream nextPutAll: 'XSTEP: '.
	aStream print: self xStep.
	aStream cr.
	aStream nextPutAll: 'YSTEP: '.
	aStream print: self yStep
]

{ #category : #initialization }
GdsAShapeContext >> initialize [
	super initialize.
	rowCount := 1.
	columnCount := 1.
	xStep := 0.0.
	yStep := 0.0.
	
	
]

{ #category : #'xml/json data exchange' }
GdsAShapeContext >> jsonOn: aStream [
	| map |
	map := Dictionary new.
	self attributesOn: map.
	self jsonElementsOn: map.
	map jsonOn: aStream.
	
]

{ #category : #'objects from disk' }
GdsAShapeContext >> loadFromXmlNode: aXMLNode [
	self attributesFrom: aXMLNode attributes.

]

{ #category : #private }
GdsAShapeContext >> lookupLocalBounds: localBounds [
	| vw vh |
	vw := (self xStep * (self columnCount - 1)) + localBounds width. 
	vh := (self yStep * (self rowCount - 1)) + localBounds height.
	^localBounds origin extent: vw@vh 
]

{ #category : #private }
GdsAShapeContext >> lookupOffsets [
	^ Array streamContents: [ :s |
		0 to: self columnCount - 1  do: [:xIndex |
			0 to: self rowCount - 1 do: [:yIndex |
				s nextPut: (xIndex * self xStep) @ (yIndex * self yStep) ] ] ]

]

{ #category : #private }
GdsAShapeContext >> lookupTransforms [
	^ self offsets collect: [ :offset | self transformClass withOffset: offset ]
]

{ #category : #accessing }
GdsAShapeContext >> offsets [
	^ offsets ifNil: [offsets := self lookupOffsets].
]

{ #category : #accessing }
GdsAShapeContext >> propertyOwner: anObject [
	propertyOwner := anObject.
	GdsFeel dependentEnabled
		ifTrue: [
			self addDependent: anObject].
]

{ #category : #updating }
GdsAShapeContext >> refreshBounds [
	offsets := nil.
	transforms := nil.
	propertyOwner ifNil: [^self].
	propertyOwner refreshBounds.
]

{ #category : #accessing }
GdsAShapeContext >> relativeTransforms [
	transforms ifNil: [ transforms := self lookupTransforms ].
	^ transforms
]

{ #category : #accessing }
GdsAShapeContext >> rowCount [
	^ rowCount
]

{ #category : #accessing }
GdsAShapeContext >> rowCount: anInteger [
	self assert: [ anInteger isNumber ].
	self assert: [ anInteger > 0 ] description: 'rowCount >= 1'.
	rowCount = anInteger asInteger
		ifTrue: [ ^ self ].
	rowCount := anInteger asInteger.
	self refreshBounds.
	self changed: #rowCount
]

{ #category : #'xml/json data exchange' }
GdsAShapeContext >> topElementName [
	^'ashape'

]

{ #category : #accessing }
GdsAShapeContext >> transformClass [
	^ GeometryUtils transformClass
]

{ #category : #accessing }
GdsAShapeContext >> values [
	^{self columnCount . self rowCount . self xStep .  self yStep }
]

{ #category : #accessing }
GdsAShapeContext >> values: anArray [
	self assert: [anArray size = 4].
	self assert: [anArray allSatisfy: [:each | each isNumber]].
	self columnCount: 	anArray first.
	self rowCount: 	anArray second.
	self xStep: anArray third.
	self yStep: anArray fourth.
	
]

{ #category : #accessing }
GdsAShapeContext >> xStep [
	^xStep
]

{ #category : #accessing }
GdsAShapeContext >> xStep: aFloat [
	self assert: [ aFloat  isNumber ].
	xStep = aFloat
		ifTrue: [ ^ self ].
	xStep := aFloat.
	self refreshBounds.
	self changed: #xStep
]

{ #category : #accessing }
GdsAShapeContext >> yStep [
	^ yStep
]

{ #category : #accessing }
GdsAShapeContext >> yStep: aFloat [
	self assert: [aFloat isNumber].
	yStep = aFloat ifTrue: [^self].
	yStep := aFloat.
	self refreshBounds.
	self changed: #yStep.
	
]
