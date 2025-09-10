"
A GdsElement is top level abstruct GDS II's element class.

Instance Variables
	colVertices:		<Array<Point>>
	dataBounds:		<Rectangle<Float>>
	keyNumber:		<Integer>
	statusNumber:		<SmallInteger>

colVertices
	- xxxxx

dataBounds
	- xxxxx

keyNumber
	- xxxxx

statusNumber
	- in item: 0 - 9
	- in id:	-1
	- in database: -2
"
Class {
	#name : #GdsElement,
	#superclass : #GdsModel,
	#traits : 'TGdsExchange + TGdsPropertiesOwner',
	#classTraits : 'TGdsExchange classTrait + TGdsPropertiesOwner classTrait',
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
	#category : #'GdsFeel-Model-Element'
}

{ #category : #private }
GdsElement class >> allCreatableClasses [

	"self allCreatableClasses inspect."

	^ GdsElement allSubclasses reject: [ :clazz | clazz type = #none ]
]

{ #category : #accessing }
GdsElement class >> classForType: aStringOrSymbol [

	| key |
	key := aStringOrSymbol asLowercase asSymbol.
	TypeToClassMap ifNil: [ self setupClassMap ].
	^ TypeToClassMap at: key ifAbsent: [  ]
]

{ #category : #analisys }
GdsElement class >> crossPointsOfElements: elements [

	^ self
		  crossPointsOfElements: elements
		  transform: MatrixTransform2x3 identity
]

{ #category : #analisys }
GdsElement class >> crossPointsOfElements: elements transform: aTransform [

	^ self
		  crossPointsOfElements: elements
		  transform: aTransform
		  tolerance: 1e-6
]

{ #category : #analisys }
GdsElement class >> crossPointsOfElements: elements transform: aTransform tolerance: aTolerance [

	| allPoints |
	allPoints := OrderedCollection new.
	elements do: [ :each | 
		each isReference
			ifTrue: [ 
				| newTransform |
				newTransform := aTransform composedWithLocal: each transform.
				allPoints addAll: (self
						 crossPointsOfElements: each refStructure elements
						 transform: newTransform) ]
			ifFalse: [ 
				each lineSegmentsDo: [ :seg1 | 
					| seg1t seg2t |
					seg1t := LineSegment
						         from: (aTransform transformPoint: seg1 start)
						         to: (aTransform transformPoint: seg1 end).
					elements do: [ :each2 | 
						each == each2 ifFalse: [ 
							each2 lineSegmentsDo: [ :seg2 | 
								seg2t := LineSegment
									         from: (aTransform transformPoint: seg2 start)
									         to: (aTransform transformPoint: seg2 end).
								LineSegment
									intersectSegment1: seg1t
									segment2: seg2t
									hasCrossBlock: [ :crossPoint | 
									allPoints add: (crossPoint roundTo: 1e-12) ]
									ifNone: [  ]
									epsilon: aTolerance ] ] ] ] ] ].
	^ allPoints asSet asArray
]

{ #category : #accessing }
GdsElement class >> enabledStateNumbers [

	" 0 - 9 : item number
	       -1: id selected
	       -2: in database
	       -4: in trush (GdsFeel)"

	^ GdsCompatibility default itemNumberRange asArray , { 
		  GdsElement inIdStausNumber.
		  GdsElement inDatabaseStausNumber.
		  GdsElement inTrushStausNumber }
]

{ #category : #initialization }
GdsElement class >> fromItemContext: aGdsEditorContext [

	^ self basicNew initialize fromItemContext: aGdsEditorContext
]

{ #category : #'as yet unclassified' }
GdsElement class >> fromXmlNode: aXMLNode [

	^ self basicNew
		  initialize;
		  loadFromXmlNode: aXMLNode;
		  yourself
]

{ #category : #testing }
GdsElement class >> hasDataType [

	^ false
]

{ #category : #testing }
GdsElement class >> hasLayer [

	^ false
]

{ #category : #testing }
GdsElement class >> hasPathType [

	^ false
]

{ #category : #testing }
GdsElement class >> hasWidth [

	^ false
]

{ #category : #constants }
GdsElement class >> inDatabaseStausNumber [

	^ -2
]

{ #category : #constants }
GdsElement class >> inIdStausNumber [

	^ -1
]

{ #category : #constants }
GdsElement class >> inTrushStausNumber [

	"not presents original GDSII
	can't use -3. reason: MSELECT no sort action number"

	^ -4
]

{ #category : #initialization }
GdsElement class >> initialize [

	"GdsElement initialize"

	self setupClassMap.
	Smalltalk addToStartUpList: self
]

{ #category : #testing }
GdsElement class >> installedElementType: aSymbol [

	"self arefInstalled"

	TypeToClassMap ifNil: [ self setupClassMap ].
	^ TypeToClassMap includesKey: aSymbol asLowercase asSymbol
]

{ #category : #testing }
GdsElement class >> isGdsOriginalClass [

	^ false
]

{ #category : #testing }
GdsElement class >> isReference [

	^ false
]

{ #category : #initialization }
GdsElement class >> new [

	^ self error: 'Abstract class can''t instanciate.'
]

{ #category : #accessing }
GdsElement class >> requiredVertexCount [

	^ 1
]

{ #category : #private }
GdsElement class >> setupClassMap [

	TypeToClassMap := Dictionary new.
	self allCreatableClasses do: [ :clazz | 
		TypeToClassMap at: clazz type put: clazz ]
]

{ #category : #'system startup' }
GdsElement class >> startUp [

	self setupClassMap
]

{ #category : #accessing }
GdsElement class >> statusSymbolOf: statusNumber [

	self inTrushStausNumber = statusNumber ifTrue: [ ^ #inTrush ].
	self inIdStausNumber = statusNumber ifTrue: [ ^ #inId ].
	self inDatabaseStausNumber = statusNumber ifTrue: [ ^ #inStructure ].
	(GdsCompatibility default itemNumberRange includes: statusNumber) 
		ifTrue: [ ^ #inItem ].
	^ #error
]

{ #category : #accessing }
GdsElement class >> type [

	^ #none
]

{ #category : #accessing }
GdsElement class >> typeString [

	^ self type asString asUppercase
]

{ #category : #analisys }
GdsElement class >> vertexPointsOfElements: elements [

	^ self
		  vertexPointsOfElements: elements
		  transform: MatrixTransform2x3 identity
]

{ #category : #analisys }
GdsElement class >> vertexPointsOfElements: elements transform: aTransform [

	| allPoints |
	allPoints := OrderedCollection new.
	elements do: [ :e | 
		e isReference
			ifTrue: [ 
				| newTransform |
				newTransform := aTransform composedWithLocal: e transform.
				allPoints addAll: (self
						 vertexPointsOfElements: e refStructure elements
						 transform: newTransform) ]
			ifFalse: [ 
				allPoints addAll:
					(e vertices collect: [ :p | aTransform transformPoint: p ]) ] ].
	^ allPoints
]

{ #category : #'accessing-points' }
GdsElement >> absoluteAngle: aTheta [

	| theta |
	theta := aTheta.
	^ theta negative
		  ifTrue: [ Float pi * 2 + theta ]
		  ifFalse: [ theta ]
]

{ #category : #visiting }
GdsElement >> accept: aVisitor [

	^ aVisitor visitElement: self
]

{ #category : #analisys }
GdsElement >> analisys: aPoint [

	| result |
	result := GeometryUtils
		          analisysSegmentsAt: aPoint
		          pointArray: self vertices.
	result at: #element put: self.
	^ result
]

{ #category : #'as yet unclassified' }
GdsElement >> asJsonMap [

	| map |
	map := Dictionary new.
	self attributesOn: map.
	self jsonElementsOn: map.
	^ map
]

{ #category : #'xml/json data exchange' }
GdsElement >> asXmlElement [

	| elmt attrDict |
	attrDict := Dictionary new.
	self xmlAttributesOn: attrDict.
	elmt := XMLElement name: self topElementName attributes: attrDict.
	self xmlElementOn: elmt.
	^ elmt
]

{ #category : #'xml/json data exchange' }
GdsElement >> attributesFrom: aDictionary [

	| key |
	key := aDictionary at: 'keyNumber' ifAbsent: [ nil ].
	key ifNotNil: [ keyNumber := key asInteger ].
	(aDictionary at: 'ownColor' ifAbsent: [ nil ]) ifNotNil: [ 
		:colorString | self ownColor: (Color fromString: colorString) ]
]

{ #category : #'xml/json data exchange' }
GdsElement >> attributesOn: aDictionary [

	aDictionary at: 'type' put: self type asString.
	self keyNumberFilled ifTrue: [ 
		aDictionary at: 'keyNumber' put: self keyNumber ].
	self ownColor ifNotNil: [ :color | 
		aDictionary at: 'ownColor' put: color asHexString ]
]

{ #category : #'accessing-points' }
GdsElement >> basicDistance: aPoint [

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
GdsElement >> children [

	^ #(  )
]

{ #category : #printing }
GdsElement >> closeChar [

	self statusNumber = -1 ifTrue: [ ^ $> ].
	^ $)
]

{ #category : #'accessing-points' }
GdsElement >> collectFor: aSegemntMessage [

	^ self lineSegments collect: [ :seg | seg perform: aSegemntMessage ]
]

{ #category : #copying }
GdsElement >> copyVertices [

	| points |
	points := self vertices collect: [ :each | each copy ].
	self privateWipe.
	self vertices: points
]

{ #category : #'t-propertiesOwner properties counting' }
GdsElement >> count: aSelector property: aSymbol [

	"self propertyCounter at: (aSelector->aSymbol) ifAbsentPut: [0].
	self propertyCounter at: (aSelector->aSymbol) put: (self propertyCounter at: (aSelector->aSymbol) ) + 1."

	
]

{ #category : #testing }
GdsElement >> damaged [

	^ self vertexCount < self requiredVertexCount
]

{ #category : #'accessing-points' }
GdsElement >> dataBounds [

	dataBounds ifNil: [ dataBounds := self lookupDataBounds ].
	^ dataBounds
]

{ #category : #'accessing-points' }
GdsElement >> dataOutlinePoints [

	^ self vertices
]

{ #category : #'accessing-points' }
GdsElement >> directions [

	^ self collectFor: #direction
]

{ #category : #'accessing-points' }
GdsElement >> directionsPacked [

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

{ #category : #'accessing-points' }
GdsElement >> dist: aPoint [

	self
		deprecated: 'Use #distanceTo: instead.'
		on: '9 February 2021'
		in: #Pharo9
		transformWith:
		'`@receiver dist: `@arg' -> '`@receiver distanceTo: `@arg'.
	^ self distanceTo: aPoint
]

{ #category : #'accessing-points' }
GdsElement >> distanceTo: aPoint [

	^ self basicDistance: aPoint
]

{ #category : #testing }
GdsElement >> explodable [

	^ false
]

{ #category : #'accessing-points' }
GdsElement >> findBounds [

	| basicBounds maxSide |
	basicBounds := self dataBounds.
	maxSide := basicBounds width max: basicBounds height.
	(basicBounds width closeTo: 0.0) ifTrue: [ 
		^ basicBounds expandBy: maxSide / 10.0 ].
	(basicBounds height closeTo: 0.0) ifTrue: [ 
		^ basicBounds expandBy: maxSide / 10.0 ].
	^ basicBounds
]

{ #category : #other }
GdsElement >> fixGeometryError [

	
]

{ #category : #initialization }
GdsElement >> fromItemContext: aGdsItemContext [

	vertices := nil.
	self vertices: (self
			 validateVertices: aGdsItemContext vertices
			 editorContext: aGdsItemContext).
	self ownColor: aGdsItemContext ownColor.
	self statusNumber: aGdsItemContext number
]

{ #category : #testing }
GdsElement >> hasDataType [

	^ self class hasDataType
]

{ #category : #testing }
GdsElement >> hasLayer [

	^ self class hasLayer
]

{ #category : #testing }
GdsElement >> hasPathType [

	^ self class hasPathType
]

{ #category : #'t-propertiesOwner properties managing' }
GdsElement >> hasProperty: aSymbol [

	"Answer whether the receiver has the property named aSymbol"

	self count: #hasProperty: property: aSymbol.
	^ self properties includesKey: aSymbol
]

{ #category : #testing }
GdsElement >> hasWidth [

	^ self class hasWidth
]

{ #category : #testing }
GdsElement >> isElement [

	^ true
]

{ #category : #testing }
GdsElement >> isLeaf [

	^ self children isEmpty
]

{ #category : #'as yet unclassified' }
GdsElement >> isMultiValue: aValue [

	^ aValue isCollection or: [ aValue isDictionary ]
]

{ #category : #testing }
GdsElement >> isReference [

	^ self class isReference
]

{ #category : #testing }
GdsElement >> isStrictGds [

	^ true
]

{ #category : #testing }
GdsElement >> isVisible [

	^ true
]

{ #category : #'xml/json data exchange' }
GdsElement >> jsonElementsOn: aDictionary [

	aDictionary at: 'vertices' put: (self vertices collect: [ :p | 
			 { 
				 p x.
				 p y } ])
]

{ #category : #'xml/json data exchange' }
GdsElement >> jsonOn: aStream [

	self asJsonMap jsonOn: aStream
]

{ #category : #accessing }
GdsElement >> keyNumber [

	^ keyNumber
]

{ #category : #initialization }
GdsElement >> keyNumber: anInteger [

	keyNumber := anInteger
]

{ #category : #testing }
GdsElement >> keyNumberFilled [

	^ keyNumber isNil not
]

{ #category : #'accessing-points' }
GdsElement >> lineSegments [

	^ Array streamContents: [ :s | 
		  self lineSegmentsDo: [ :seg | s nextPut: seg ] ]
]

{ #category : #'accessing-points' }
GdsElement >> lineSegmentsDo: aLineSegmentBlock [

	GeometryUtils
		pointArray: self vertices
		lineSegmentsDo: aLineSegmentBlock
]

{ #category : #'objects from disk' }
GdsElement >> loadFromXmlNode: aXMLNode [

	self protectedLoadFromXmlNode: aXMLNode
]

{ #category : #'accessing-points' }
GdsElement >> lookupDataBounds [

	^ GeometryUtils lookupDataBounds: self dataOutlinePoints
]

{ #category : #'objects from disk' }
GdsElement >> missingDataTypeNumber [

	^ 0
]

{ #category : #'objects from disk' }
GdsElement >> missingLayerNumber [

	^ 1
]

{ #category : #'objects from disk' }
GdsElement >> missingPathTypeNumber [

	^ 0
]

{ #category : #'objects from disk' }
GdsElement >> missingWidthNumber [

	^ 1.0
]

{ #category : #'accessing-points' }
GdsElement >> moveRelative: aPoint [

	self moveRelative: aPoint from: self
]

{ #category : #'accessing-points' }
GdsElement >> moveRelative: aPoint from: aOtherElement [

	| translatedPoints |
	translatedPoints := aOtherElement vertices collect: [ :p | 
		                    p + aPoint ].
	self privateWipe.
	self vertices: translatedPoints
]

{ #category : #'xml/json data exchange' }
GdsElement >> neoJsonOn: neoJSONWriter [

	neoJSONWriter writeMap: self asJsonMap
]

{ #category : #printing }
GdsElement >> openChar [

	self statusNumber = -1 ifTrue: [ ^ $< ].
	^ $(
]

{ #category : #'accessing-points' }
GdsElement >> originX [

	^ self xy x
]

{ #category : #'accessing-points' }
GdsElement >> originY [

	^ self xy y
]

{ #category : #accessing }
GdsElement >> ownColor [

	^ ownColor
]

{ #category : #accessing }
GdsElement >> ownColor: aColor [

	ownColor := aColor
]

{ #category : #copying }
GdsElement >> postCopy [

	super postCopy.
	self copyVertices
]

{ #category : #printing }
GdsElement >> printOn: aStream [

	aStream nextPutAll: self typeString.
	aStream nextPut: self openChar.
	keyNumber ifNotNil: [ aStream nextPutAll: keyNumber asString ].
	self printSelfOn: aStream.
	aStream nextPut: self closeChar
]

{ #category : #printing }
GdsElement >> printSelfOn: aStream [

	
]

{ #category : #private }
GdsElement >> privateWipe [

	vertices := nil.
	self refreshBounds
]

{ #category : #private }
GdsElement >> properties [

	^ properties ifNil: [ properties := IdentityDictionary new ]
]

{ #category : #'t-propertiesOwner properties counting' }
GdsElement >> propertyCounter [

	^ self properties
		  at: #propertyCounter
		  ifAbsentPut: [ Dictionary new ]
]

{ #category : #'objects from disk' }
GdsElement >> protectedLoadFromXmlNode: aXMLNode [

	| col |
	self attributesFrom: aXMLNode attributes.
	col := OrderedCollection new.
	(aXMLNode findElementNamed: #vertices) elementsDo: [ :xyNode | 
		| words xy |
		words := xyNode stringNodes first string findTokens: ' '.
		xy := words first asNumber @ words last asNumber.
		col add: xy ].
	self assert: [ col isNotEmpty ].
	self vertices: col asArray.
	(aXMLNode findElementNamed: 'property-set1') ifNotNil: [ :elems | 
		elems elementsDo: [ :prop1node | 
			| keyString valueString |
			keyString := prop1node attributeAt: 'key'.
			valueString := prop1node attributeAt: 'value'.
			self setProperty: keyString toValue: valueString ] ]
]

{ #category : #private }
GdsElement >> refreshBounds [

	dataBounds := nil
]

{ #category : #initialization }
GdsElement >> release [

	vertices := nil.
	structure := nil.
	super release
]

{ #category : #other }
GdsElement >> removeGeometryCache [

	
]

{ #category : #private }
GdsElement >> removeKeyNumber [

	keyNumber := nil
]

{ #category : #'t-propertiesOwner properties managing' }
GdsElement >> removeProperty: aSymbol [

	"removes the property named aSymbol if it exists"

	self count: #removeProperty: property: aSymbol.
	self properties removeKey: aSymbol ifAbsent: [  ]
]

{ #category : #accessing }
GdsElement >> requiredVertexCount [

	^ self class requiredVertexCount
]

{ #category : #'t-propertiesOwner properties managing' }
GdsElement >> setProperty: aSymbol toValue: anObject [

	"change the receiver's property named aSymbol to anObject"

	self count: #setProperty: property: aSymbol.
	self properties at: aSymbol put: anObject
]

{ #category : #'accessing-points' }
GdsElement >> setXy: aPoint [

	self vertices: (Array with: aPoint)
]

{ #category : #accessing }
GdsElement >> state [

	^ GdsElement statusSymbolOf: self statusNumber
]

{ #category : #accessing }
GdsElement >> statusNumber [

	"in item: 0 - 9
	in id:	-1
	in database: -2"

	statusNumber ifNil: [ 
		statusNumber := GdsElement inDatabaseStausNumber ].
	^ statusNumber
]

{ #category : #accessing }
GdsElement >> statusNumber: aInteger [

	"in item: 0 - 9
	in id:	-1
	in database: -2"

	self assert: [ GdsElement enabledStateNumbers includes: aInteger ].
	statusNumber := aInteger.
	self changed: #statusNumber
]

{ #category : #other }
GdsElement >> stringNodeClass [

	^ Smalltalk
		  at: #XMLStringNode
		  ifAbsent: [ ^ Smalltalk at: #XMLString ]
]

{ #category : #accessing }
GdsElement >> structure [

	^ structure
]

{ #category : #initialization }
GdsElement >> structure: aGdsStructure [

	structure := aGdsStructure
]

{ #category : #'accessing-points' }
GdsElement >> thetas [

	^ self lineSegments collect: [ :seg | seg direction theta ]
]

{ #category : #'accessing-points' }
GdsElement >> thetasPacked [

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

{ #category : #'xml/json data exchange' }
GdsElement >> topElementName [

	^ 'element'
]

{ #category : #accessing }
GdsElement >> type [

	^ self class type
]

{ #category : #accessing }
GdsElement >> typeString [

	^ self type asString asUppercase
]

{ #category : #accessing }
GdsElement >> validateVertices: aPointArray [

	aPointArray size < self requiredVertexCount ifTrue: [ 
		self error:
			'required vertex count is ' , self requiredVertexCount printString
			, 'but: ' , aPointArray size printString ].
	^ aPointArray
]

{ #category : #accessing }
GdsElement >> validateVertices: aPointArray editorContext: aGdsEditorContext [

	^ self validateVertices: aPointArray
]

{ #category : #'xml/json data exchange' }
GdsElement >> valueAsStringOn: aDictionary [

	aDictionary keysAndValuesDo: [ :key :value | 
		(self isMultiValue: value) ifFalse: [ 
			aDictionary at: key asString put: value asString ] ]
]

{ #category : #'t-propertiesOwner properties managing' }
GdsElement >> valueOfProperty: aSymbol [

	"answer the value of the receiver's property named aSymbol"

	self count: #valueOfProperty: property: aSymbol.
	^ self valueOfProperty: aSymbol ifAbsent: [  ]
]

{ #category : #'t-propertiesOwner properties managing' }
GdsElement >> valueOfProperty: aSymbol ifAbsent: aBlock [

	"if the receiver possesses a property of the given name, answer  
	its value. If not then evaluate aBlock and answer the result of  
	this block evaluation"

	self count: #valueOfProperty:ifAbsent: property: aSymbol.
	^ self properties at: aSymbol ifAbsent: [ ^ aBlock value ]
]

{ #category : #'t-propertiesOwner properties managing' }
GdsElement >> valueOfProperty: aSymbol ifAbsentPut: aBlock [

	"If the receiver possesses a property of the given name, answer  
	its value. If not, then create a property of the given name, give 
	it the value obtained by evaluating aBlock, then answer that  
	value"

	self count: #valueOfProperty:ifAbsentPut: property: aSymbol.
	^ self properties at: aSymbol ifAbsentPut: aBlock
]

{ #category : #'t-propertiesOwner properties managing' }
GdsElement >> valueOfProperty: aSymbol ifPresentDo: aBlock [

	"If the receiver has a property of the given name, evaluate  
	aBlock on behalf of the value of that property"

	self count: #valueOfProperty:ifPresentDo: property: aSymbol.
	^ aBlock value: (self valueOfProperty: aSymbol ifAbsent: [ ^ self ])
]

{ #category : #'accessing-points' }
GdsElement >> vertexCount [

	^ self vertices size
]

{ #category : #'accessing-points' }
GdsElement >> vertices [

	vertices ifNil: [ vertices := #(  ) ].
	^ vertices
]

{ #category : #'accessing-points' }
GdsElement >> vertices: aPointArray [

	vertices := aPointArray.
	self removeGeometryCache.
	self refreshBounds
]

{ #category : #action }
GdsElement >> wipe [

	self privateWipe.
	self statusNumber: GdsElement inTrushStausNumber
]

{ #category : #'xml/json data exchange' }
GdsElement >> xmlAttributesOn: aDictionary [

	self attributesOn: aDictionary.
	self valueAsStringOn: aDictionary
]

{ #category : #'xml/json data exchange' }
GdsElement >> xmlElementOn: aXmlElement [

	| vertsElmt propset1 prop1 |
	vertsElmt := XMLElement named: 'vertices'.
	self vertices do: [ :xy | vertsElmt addNode: (self xyXmlElement: xy) ].
	aXmlElement addNode: vertsElmt.
	self properties keys ifEmpty: [ ^ self ].
	propset1 := XMLElement named: 'property-set1'.
	self properties keysAndValuesDo: [ :key :value | 
		prop1 := XMLElement name: 'property1' attributes: { 
				         ('key' -> key asString).
				         ('value' -> value asString) }.
		propset1 addNode: prop1 ].
	aXmlElement addNode: propset1
]

{ #category : #'accessing-points' }
GdsElement >> xy [

	^ self vertices first
]

{ #category : #'accessing-points' }
GdsElement >> xy: aPoint [

	self setXy: aPoint
]

{ #category : #accessing }
GdsElement >> xyXmlElement: aPoint [

	| point |
	point := aPoint asNonFractionalPoint.
	^ (XMLElement named: 'xy') addContent: (self stringNodeClass string:
			   point x asString , ' ' , point y asString)
]
