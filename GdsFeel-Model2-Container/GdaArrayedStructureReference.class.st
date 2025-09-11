Class {
	#name : #GdaArrayedStructureReference,
	#superclass : #GdaStructureReference,
	#instVars : [
		'ashape'
	],
	#category : #'GdsFeel-Model2-Container'
}

{ #category : #accessing }
GdaArrayedStructureReference class >> type [

	^ #aref
]

{ #category : #private }
GdaArrayedStructureReference >> baseLocalBounds [

	^ super lookupLocalBounds
]

{ #category : #'accessing - basic' }
GdaArrayedStructureReference >> columnCount [

	^ ashape columnCount
]

{ #category : #'accessing - basic' }
GdaArrayedStructureReference >> columnCount: anInteger [

	ashape columnCount: anInteger
]

{ #category : #private }
GdaArrayedStructureReference >> fromItemContext: aGdsItemContext atIndex: aVerticesIndex [

	super fromItemContext: aGdsItemContext atIndex: aVerticesIndex.
	self columnCount: aGdsItemContext ashape columnCount.
	self rowCount: aGdsItemContext ashape rowCount.
	self xStep: aGdsItemContext ashape xStep.
	self yStep: aGdsItemContext ashape yStep
]

{ #category : #initialization }
GdaArrayedStructureReference >> initialize [

	super initialize.
	ashape := GdaAShapeContext new element: self
]

{ #category : #private }
GdaArrayedStructureReference >> lookupLocalBounds [

	^ ashape lookupLocalBounds: super lookupLocalBounds
]

{ #category : #accessing }
GdaArrayedStructureReference >> offsets [

	^ ashape offsets
]

{ #category : #private }
GdaArrayedStructureReference >> rebuildVertices [

	
]

{ #category : #accessing }
GdaArrayedStructureReference >> relativeTransforms [

	^ ashape relativeTransforms
]

{ #category : #initialization }
GdaArrayedStructureReference >> release [
	ashape release.
	ashape := nil.
	super release 
]

{ #category : #accessing }
GdaArrayedStructureReference >> repeatTransforms [

	^ self relativeTransforms collect: [ :each | 
		  self transform copy composedWithLocal: each ]
]

{ #category : #'accessing - basic' }
GdaArrayedStructureReference >> rowCount [

	^ ashape rowCount
]

{ #category : #'accessing - basic' }
GdaArrayedStructureReference >> rowCount: anInteger [

	ashape rowCount: anInteger
]

{ #category : #sizing }
GdaArrayedStructureReference >> stepToOwnSize [

	self xStepToOwnSize.
	self yStepToOwnSize
]

{ #category : #'accessing - basic' }
GdaArrayedStructureReference >> xStep [

	^ ashape xStep
]

{ #category : #'accessing - basic' }
GdaArrayedStructureReference >> xStep: aFloat [

	ashape xStep: aFloat.
	self rebuildVertices
]

{ #category : #private }
GdaArrayedStructureReference >> xStepToOwnSize [

	self xStep: self baseLocalBounds width
]

{ #category : #'accessing - basic' }
GdaArrayedStructureReference >> yStep [

	^ ashape yStep
]

{ #category : #'accessing - basic' }
GdaArrayedStructureReference >> yStep: aFloat [

	ashape yStep: aFloat.
	self rebuildVertices
]

{ #category : #sizing }
GdaArrayedStructureReference >> yStepToOwnSize [

	self yStep: self baseLocalBounds height
]
