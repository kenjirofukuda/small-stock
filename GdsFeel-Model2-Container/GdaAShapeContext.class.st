Class {
	#name : #GdaAShapeContext,
	#superclass : #GdaModel,
	#instVars : [
		'columnCount',
		'rowCount',
		'xStep',
		'yStep',
		'transforms',
		'offsets',
		'element'
	],
	#category : #'GdsFeel-Model2-Container'
}

{ #category : #'accessing - basic' }
GdaAShapeContext >> columnCount [

	^ columnCount
]

{ #category : #'accessing - basic' }
GdaAShapeContext >> columnCount: anInteger [

	self assert: [ anInteger isNumber ].
	self assert: [ anInteger > 0 ] description: 'columnCount >= 1'.
	columnCount = anInteger asInteger ifTrue: [ ^ self ].
	columnCount := anInteger asInteger.
	self refreshBounds.
	self changed: #columnCount
]

{ #category : #printing }
GdaAShapeContext >> consoleStringOn: aStream [

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

{ #category : #accessing }
GdaAShapeContext >> element: anGdaArrayedStructureReference [

	element := anGdaArrayedStructureReference
]

{ #category : #initialization }
GdaAShapeContext >> initialize [

	super initialize.
	rowCount := 1.
	columnCount := 1.
	xStep := 0.0.
	yStep := 0.0
]

{ #category : #private }
GdaAShapeContext >> lookupLocalBounds: localBounds [

	| vw vh |
	vw := self xStep * (self columnCount - 1) + localBounds width.
	vh := self yStep * (self rowCount - 1) + localBounds height.
	^ localBounds origin extent: vw @ vh
]

{ #category : #private }
GdaAShapeContext >> lookupOffsets [

	^ Array streamContents: [ :s | 
		  0 to: self columnCount - 1 do: [ :xIndex | 
			  0 to: self rowCount - 1 do: [ :yIndex | 
			  s nextPut: xIndex * self xStep @ (yIndex * self yStep) ] ] ]
]

{ #category : #private }
GdaAShapeContext >> lookupTransforms [

	^ self offsets collect: [ :offset | 
		  self transformClass withOffset: offset ]
]

{ #category : #accessing }
GdaAShapeContext >> offsets [

	^ offsets ifNil: [ offsets := self lookupOffsets ]
]

{ #category : #updating }
GdaAShapeContext >> refreshBounds [

	offsets := nil.
	transforms := nil.
	element ifNil: [ ^ self ].
	element refreshBounds
]

{ #category : #accessing }
GdaAShapeContext >> relativeTransforms [

	transforms ifNil: [ transforms := self lookupTransforms ].
	^ transforms
]

{ #category : #initialization }
GdaAShapeContext >> release [
	columnCount := nil.
	rowCount := nil.
	xStep := nil.
	yStep := nil.
	transforms := nil.
	offsets := nil.
	element := nil.
	super release 
]

{ #category : #'accessing - basic' }
GdaAShapeContext >> rowCount [

	^ rowCount
]

{ #category : #'accessing - basic' }
GdaAShapeContext >> rowCount: anInteger [

	self assert: [ anInteger isNumber ].
	self assert: [ anInteger > 0 ] description: 'rowCount >= 1'.
	rowCount = anInteger asInteger ifTrue: [ ^ self ].
	rowCount := anInteger asInteger.
	self refreshBounds.
	self changed: #rowCount
]

{ #category : #accessing }
GdaAShapeContext >> values [

	^ { 
		  self columnCount.
		  self rowCount.
		  self xStep.
		  self yStep }
]

{ #category : #accessing }
GdaAShapeContext >> values: anArray [

	self assert: [ anArray size = 4 ].
	self assert: [ anArray allSatisfy: [ :each | each isNumber ] ].
	self columnCount: anArray first.
	self rowCount: anArray second.
	self xStep: anArray third.
	self yStep: anArray fourth
]

{ #category : #'accessing - basic' }
GdaAShapeContext >> xStep [

	^ xStep
]

{ #category : #'accessing - basic' }
GdaAShapeContext >> xStep: aFloat [

	self assert: [ aFloat isNumber ].
	xStep = aFloat ifTrue: [ ^ self ].
	xStep := aFloat.
	self refreshBounds.
	self changed: #xStep
]

{ #category : #'accessing - basic' }
GdaAShapeContext >> yStep [

	^ yStep
]

{ #category : #'accessing - basic' }
GdaAShapeContext >> yStep: aFloat [

	self assert: [ aFloat isNumber ].
	yStep = aFloat ifTrue: [ ^ self ].
	yStep := aFloat.
	self refreshBounds.
	self changed: #yStep
]
