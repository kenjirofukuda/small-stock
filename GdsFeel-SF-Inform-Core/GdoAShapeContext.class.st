Class {
	#name : #GdoAShapeContext,
	#superclass : #Object,
	#instVars : [
		'columnCount',
		'rowCount',
		'xStep',
		'yStep',
		'propertyOwner',
		'transforms',
		'offsets'
	],
	#category : #'GdsFeel-SF-Inform-Core'
}

{ #category : #accessing }
GdoAShapeContext >> columnCount [
	^columnCount
]

{ #category : #accessing }
GdoAShapeContext >> columnCount: anInteger [
	self assert: [ anInteger isNumber ].
	self assert: [ anInteger > 0 ] description: 'columnCount >= 1'.
	columnCount = anInteger asInteger
		ifTrue: [ ^ self ].
	columnCount := anInteger asInteger.
]

{ #category : #printing }
GdoAShapeContext >> consoleStringOn: aStream [
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
GdoAShapeContext >> initialize [
	super initialize.
	rowCount := 1.
	columnCount := 1.
	xStep := 0.0.
	yStep := 0.0.
	
	
]

{ #category : #private }
GdoAShapeContext >> lookupLocalBounds: localBounds [
	| vw vh |
	vw := (self xStep * (self columnCount - 1)) + localBounds width. 
	vh := (self yStep * (self rowCount - 1)) + localBounds height.
	^localBounds origin extent: vw@vh 
]

{ #category : #private }
GdoAShapeContext >> lookupOffsets [
	^ Array streamContents: [ :s |
		0 to: self columnCount - 1  do: [:xIndex |
			0 to: self rowCount - 1 do: [:yIndex |
				s nextPut: (xIndex * self xStep) @ (yIndex * self yStep) ] ] ]

]

{ #category : #private }
GdoAShapeContext >> lookupTransforms [
	^ self offsets collect: [ :offset | MatrixTransform2x3 withOffset: offset ]
]

{ #category : #accessing }
GdoAShapeContext >> offsets [
	^ offsets ifNil: [offsets := self lookupOffsets].
]

{ #category : #accessing }
GdoAShapeContext >> propertyOwner: anObject [
	propertyOwner := anObject.
	GdsFeel dependentEnabled
		ifTrue: [
			self addDependent: anObject].
]

{ #category : #accessing }
GdoAShapeContext >> relativeTransforms [
	transforms ifNil: [ transforms := self lookupTransforms ].
	^ transforms
]

{ #category : #accessing }
GdoAShapeContext >> rowCount [
	^ rowCount
]

{ #category : #accessing }
GdoAShapeContext >> rowCount: anInteger [
	self assert: [ anInteger isNumber ].
	self assert: [ anInteger > 0 ] description: 'rowCount >= 1'.
	rowCount = anInteger asInteger
		ifTrue: [ ^ self ].
	rowCount := anInteger asInteger
]

{ #category : #accessing }
GdoAShapeContext >> xStep [
	^xStep
]

{ #category : #accessing }
GdoAShapeContext >> xStep: aFloat [
	self assert: [ aFloat  isNumber ].
	xStep = aFloat
		ifTrue: [ ^ self ].
	xStep := aFloat
]

{ #category : #accessing }
GdoAShapeContext >> yStep [
	^ yStep
]

{ #category : #accessing }
GdoAShapeContext >> yStep: aFloat [
	self assert: [aFloat isNumber].
	yStep = aFloat ifTrue: [^self].
	yStep := aFloat.
	
]
