Class {
	#name : #GdaElement,
	#superclass : #GdaModel,
	#instVars : [
		'vertices',
		'dataBounds',
		'keyNumber',
		'statusNumber',
		'structure',
		'ownColor'
	],
	#classVars : [
		'TypeToClassMap'
	],
	#category : #'GdsFeel-Model2-Container-GdsFeel-Model2-Container'
}

{ #category : #private }
GdaElement class >> allCreatableClasses [

	"self allCreatableClasses inspect."

	^ self allSubclasses reject: [ :clazz | clazz type = #none ]
]

{ #category : #accessing }
GdaElement class >> classForType: aStringOrSymbol [

	| key |
	key := aStringOrSymbol asLowercase asSymbol.
	TypeToClassMap ifNil: [ self setupClassMap ].
	^ TypeToClassMap at: key ifAbsent: [  ]
]

{ #category : #accessing }
GdaElement class >> enabledStateNumbers [

	" 0 - 9 : item number
	       -1: id selected
	       -2: in database
	       -4: in trush (GdsFeel)"

	^ self itemNumberRange asArray , { 
		  self inIdStausNumber.
		  self inDatabaseStausNumber.
		  self inTrushStausNumber }
]

{ #category : #testing }
GdaElement class >> hasDataType [

	^ false
]

{ #category : #testing }
GdaElement class >> hasLayer [

	^ false
]

{ #category : #testing }
GdaElement class >> hasPathType [

	^ false
]

{ #category : #testing }
GdaElement class >> hasWidth [

	^ false
]

{ #category : #constants }
GdaElement class >> inDatabaseStausNumber [

	^ -2
]

{ #category : #constants }
GdaElement class >> inIdStausNumber [

	^ -1
]

{ #category : #constants }
GdaElement class >> inTrushStausNumber [

	"not presents original GDSII
	can't use -3. reason: MSELECT no sort action number"

	^ -4
]

{ #category : #initialization }
GdaElement class >> initialize [

	"GdsElement initialize"

	self setupClassMap.
	Smalltalk addToStartUpList: self
]

{ #category : #testing }
GdaElement class >> installedElementType: aSymbol [

	"self arefInstalled"

	TypeToClassMap ifNil: [ self setupClassMap ].
	^ TypeToClassMap includesKey: aSymbol asLowercase asSymbol
]

{ #category : #testing }
GdaElement class >> isGdsOriginalClass [

	^ false
]

{ #category : #testing }
GdaElement class >> isReference [

	^ false
]

{ #category : #accessing }
GdaElement class >> itemNumberRange [

	^ Interval from: 0 to: 9
]

{ #category : #initialization }
GdaElement class >> new [

	^ self error: 'Abstract class can''t instanciate.'
]

{ #category : #accessing }
GdaElement class >> requiredVertexCount [

	^ 1
]

{ #category : #private }
GdaElement class >> setupClassMap [

	TypeToClassMap := Dictionary new.
	self allCreatableClasses do: [ :clazz | 
		TypeToClassMap at: clazz type put: clazz ]
]

{ #category : #'system startup' }
GdaElement class >> startUp [

	self setupClassMap
]

{ #category : #accessing }
GdaElement class >> statusSymbolOf: statusNumber [

	self inTrushStausNumber = statusNumber ifTrue: [ ^ #inTrush ].
	self inIdStausNumber = statusNumber ifTrue: [ ^ #inId ].
	self inDatabaseStausNumber = statusNumber ifTrue: [ ^ #inStructure ].
	(self itemNumberRange includes: statusNumber) ifTrue: [ ^ #inItem ].
	^ #error
]

{ #category : #accessing }
GdaElement class >> type [

	^ #none
]

{ #category : #accessing }
GdaElement class >> typeString [

	^ self type asString asUppercase
]

{ #category : #'accessing - points' }
GdaElement >> absoluteAngle: aTheta [

	| theta |
	theta := aTheta.
	^ theta negative
		  ifTrue: [ Float pi * 2 + theta ]
		  ifFalse: [ theta ]
]

{ #category : #analisys }
GdaElement >> analisys: aPoint [

	| result |
	result := GeometryUtils
		          analisysSegmentsAt: aPoint
		          pointArray: self vertices.
	result at: #element put: self.
	^ result
]

{ #category : #'accessing - points' }
GdaElement >> basicDistance: aPoint [

	| col distP |
	col := OrderedCollection new.
	GeometryUtils
		pointArray: self dataOutlinePoints
		lineSegmentsDo: [ :seg | 
			| disCon |
			seg hasZeroLength ifFalse: [ 
				disCon := GeometryUtils distanceContextAt: aPoint segment: seg.
				distP := { 
					         disCon start.
					         disCon end.
					         disCon cross } min.
				col add: distP ] ].
	col ifEmpty: [ ^ aPoint distanceTo: self xy ].
	^ col min
]

{ #category : #accessing }
GdaElement >> children [

	^ #(  )
]

{ #category : #printing }
GdaElement >> closeChar [

	self statusNumber = -1 ifTrue: [ ^ $> ].
	^ $)
]

{ #category : #'accessing - points' }
GdaElement >> collectFor: aSegemntMessage [

	^ self lineSegments collect: [ :seg | seg perform: aSegemntMessage ]
]

{ #category : #copying }
GdaElement >> copyVertices [

	| points |
	points := self vertices collect: [ :each | each copy ].
	self privateWipe.
	self vertices: points
]

{ #category : #testing }
GdaElement >> damaged [

	^ self vertexCount < self requiredVertexCount
]

{ #category : #'accessing - points' }
GdaElement >> dataBounds [

	dataBounds ifNil: [ dataBounds := self lookupDataBounds ].
	^ dataBounds
]

{ #category : #'accessing - points' }
GdaElement >> dataOutlinePoints [

	^ self vertices
]

{ #category : #'accessing - points' }
GdaElement >> directions [

	^ self collectFor: #direction
]

{ #category : #'accessing - points' }
GdaElement >> directionsPacked [

	^ (self directions
		   inject: OrderedCollection new
		   into: [ :subtotal :each | 
			   subtotal
				   ifEmpty: [ 
					   subtotal
						   add: each;
						   yourself ]
				   ifNotEmpty: [ 
					   subtotal
						   add: each - subtotal last;
						   yourself ] ]) asArray
]

{ #category : #'accessing - points' }
GdaElement >> distanceTo: aPoint [

	^ self basicDistance: aPoint
]

{ #category : #testing }
GdaElement >> explodable [

	^ false
]

{ #category : #'accessing - points' }
GdaElement >> findBounds [

	| basicBounds maxSide |
	basicBounds := self dataBounds.
	maxSide := basicBounds width max: basicBounds height.
	(basicBounds width closeTo: 0.0) ifTrue: [ 
		^ basicBounds expandBy: maxSide / 10.0 ].
	(basicBounds height closeTo: 0.0) ifTrue: [ 
		^ basicBounds expandBy: maxSide / 10.0 ].
	^ basicBounds
]

{ #category : #validation }
GdaElement >> fixGeometryError [

	
]

{ #category : #testing }
GdaElement >> hasDataType [

	^ self class hasDataType
]

{ #category : #testing }
GdaElement >> hasLayer [

	^ self class hasLayer
]

{ #category : #testing }
GdaElement >> hasPathType [

	^ self class hasPathType
]

{ #category : #testing }
GdaElement >> hasWidth [

	^ self class hasWidth
]

{ #category : #testing }
GdaElement >> isElement [

	^ true
]

{ #category : #testing }
GdaElement >> isLeaf [

	^ self children isEmpty
]

{ #category : #testing }
GdaElement >> isReference [

	^ self class isReference
]

{ #category : #testing }
GdaElement >> isStrictGds [

	^ true
]

{ #category : #'accessing - basic' }
GdaElement >> keyNumber [

	^ keyNumber
]

{ #category : #initialization }
GdaElement >> keyNumber: anInteger [

	keyNumber := anInteger
]

{ #category : #testing }
GdaElement >> keyNumberFilled [

	^ keyNumber isNil not
]

{ #category : #'accessing - points' }
GdaElement >> lineSegments [

	^ Array streamContents: [ :s | 
		  self lineSegmentsDo: [ :seg | s nextPut: seg ] ]
]

{ #category : #'accessing - points' }
GdaElement >> lineSegmentsDo: aLineSegmentBlock [

	GeometryUtils
		pointArray: self vertices
		lineSegmentsDo: aLineSegmentBlock
]

{ #category : #'accessing - points' }
GdaElement >> lookupDataBounds [

	^ GeometryUtils lookupDataBounds: self dataOutlinePoints
]

{ #category : #'accessing - points' }
GdaElement >> moveRelative: aPoint [

	self moveRelative: aPoint from: self
]

{ #category : #'accessing - points' }
GdaElement >> moveRelative: aPoint from: aOtherElement [

	| translatedPoints |
	translatedPoints := aOtherElement vertices collect: [ :p | 
		                    p + aPoint ].
	self privateWipe.
	self vertices: translatedPoints
]

{ #category : #printing }
GdaElement >> openChar [

	self statusNumber = -1 ifTrue: [ ^ $< ].
	^ $(
]

{ #category : #'accessing - points' }
GdaElement >> originX [

	^ self xy x
]

{ #category : #'accessing - points' }
GdaElement >> originY [

	^ self xy y
]

{ #category : #'accessing - appearance' }
GdaElement >> ownColor [

	^ ownColor
]

{ #category : #'accessing - appearance' }
GdaElement >> ownColor: aColor [

	ownColor := aColor
]

{ #category : #copying }
GdaElement >> postCopy [

	super postCopy.
	self copyVertices
]

{ #category : #printing }
GdaElement >> printOn: aStream [

	aStream nextPutAll: self typeString.
	aStream nextPut: self openChar.
	keyNumber ifNotNil: [ aStream nextPutAll: keyNumber asString ].
	self printSelfOn: aStream.
	aStream nextPut: self closeChar
]

{ #category : #printing }
GdaElement >> printSelfOn: aStream [

	
]

{ #category : #private }
GdaElement >> privateWipe [

	vertices := nil.
	self refreshBounds
]

{ #category : #private }
GdaElement >> refreshBounds [

	dataBounds := nil
]

{ #category : #initialization }
GdaElement >> release [

	vertices := nil.
	structure := nil.
	super release
]

{ #category : #other }
GdaElement >> removeGeometryCache [

	
]

{ #category : #private }
GdaElement >> removeKeyNumber [

	keyNumber := nil
]

{ #category : #validation }
GdaElement >> requiredVertexCount [

	^ self class requiredVertexCount
]

{ #category : #'accessing - points' }
GdaElement >> setXy: aPoint [

	self vertices: (Array with: aPoint)
]

{ #category : #accessing }
GdaElement >> state [

	^ self class statusSymbolOf: self statusNumber
]

{ #category : #accessing }
GdaElement >> statusNumber [

	"in item: 0 - 9
	in id:	-1
	in database: -2"

	statusNumber ifNil: [ 
		statusNumber := self class inDatabaseStausNumber ].
	^ statusNumber
]

{ #category : #accessing }
GdaElement >> statusNumber: aInteger [

	"in item: 0 - 9
	in id:	-1
	in database: -2"

	self assert: [ self class enabledStateNumbers includes: aInteger ].
	statusNumber := aInteger.
	self changed: #statusNumber
]

{ #category : #relation }
GdaElement >> structure [

	^ structure
]

{ #category : #initialization }
GdaElement >> structure: aGdsStructure [

	structure := aGdsStructure
]

{ #category : #'accessing - points' }
GdaElement >> thetas [

	^ self lineSegments collect: [ :seg | seg direction theta ]
]

{ #category : #'accessing - points' }
GdaElement >> thetasPacked [

	| prevSeg |
	^ Array streamContents: [ :s | 
		  prevSeg := nil.
		  self lineSegmentsDo: [ :seg | 
			  prevSeg ifNotNil: [ 
				  | to from |
				  to := self absoluteAngle: seg direction theta.
				  from := self absoluteAngle: prevSeg reversed direction theta.
				  s nextPut: (self absoluteAngle: to - from) ].
			  prevSeg := seg ] ]
]

{ #category : #printing }
GdaElement >> type [

	^ self class type
]

{ #category : #printing }
GdaElement >> typeString [

	^ self type asString asUppercase
]

{ #category : #validation }
GdaElement >> validateVertices: aPointArray [

	aPointArray size < self requiredVertexCount ifTrue: [ 
		self error:
			'required vertex count is ' , self requiredVertexCount printString
			, 'but: ' , aPointArray size printString ].
	^ aPointArray
]

{ #category : #'accessing - basic' }
GdaElement >> vertexCount [

	^ self vertices size
]

{ #category : #'accessing - basic' }
GdaElement >> vertices [

	vertices ifNil: [ vertices := #(  ) ].
	^ vertices
]

{ #category : #'accessing - basic' }
GdaElement >> vertices: aPointArray [

	vertices := aPointArray.
	self removeGeometryCache.
	self refreshBounds
]

{ #category : #action }
GdaElement >> wipe [

	self privateWipe.
	self statusNumber: self class inTrushStausNumber
]

{ #category : #'accessing - basic' }
GdaElement >> xy [

	^ self vertices first
]

{ #category : #'accessing - basic' }
GdaElement >> xy: aPoint [

	self setXy: aPoint
]
