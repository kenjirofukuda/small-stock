"
A GdsItemContext is attribute holder for ITEM edit.

Instance Variables
	colVertices:		<Array<Point>>
	digitaizingDirection:		<Symbol>
	digitaizingMode:		<Symbol>
	editElement:		<GdsElement>
	elementType:		<Symbol>
	itemNumber:		<SmallInteger>
	layer:		<SmallInteger>
	width:		<Float>
	structure:		<GdsStructure>

colVertices
	- xxxxx

digitaizingDirection
	- xxxxx

digitaizingMode
	- xxxxx

editElement
	- xxxxx

elementType
	- xxxxx

itemNumber
	- xxxxx

layer
	- xxxxx

structure
	- xxxxx

"
Class {
	#name : #GdsItemContext,
	#superclass : #Model,
	#instVars : [
		'elementType',
		'colVertices',
		'digitaizingDirection',
		'digitaizingMode',
		'editElement',
		'itemNumber',
		'offset',
		'text',
		'structureName',
		'wire',
		'datatype',
		'layerNumber',
		'ashape',
		'strans',
		'announcer',
		'lockMessages',
		'ownColor',
		'structure',
		'items'
	],
	#category : #'GdsFeel-Model-EditSpace'
}

{ #category : #'instance creation' }
GdsItemContext class >> new [
	^self error: 'only use #newWithNumber: '.
]

{ #category : #'instance creation' }
GdsItemContext class >> newWithNumber: anInteger [
	^self basicNew initWithNumber: anInteger
]

{ #category : #notification }
GdsItemContext class >> notificationNameWithProperty: aPropertySymbol [
	^GdsProperty autoNotificationNameBy: self propertyName: aPropertySymbol
]

{ #category : #accessing }
GdsItemContext >> angle [
	^strans angle
	
]

{ #category : #utility }
GdsItemContext >> angle360: aDegree [
	| rem |
	rem := aDegree asFloat rem: 360.0.
	^aDegree negative ifTrue: [360.0 + rem] ifFalse: [rem].
	
]

{ #category : #accessing }
GdsItemContext >> angle: aDegrees [
	| newAngle oldAngle |
	oldAngle := self angle360: self angle.  
	newAngle := self angle360: aDegrees.
	oldAngle = newAngle ifTrue: [^self].
	self privateAngle: newAngle.
	
]

{ #category : #'as yet unclassified' }
GdsItemContext >> announce: anAnnouncement [ 
	self announcer announce: anAnnouncement
]

{ #category : #'as yet unclassified' }
GdsItemContext >> announceAttributeChanged: aSymbol [
	self announceAttributeChanged: aSymbol to: nil. 
]

{ #category : #'as yet unclassified' }
GdsItemContext >> announceAttributeChanged: aSymbol from: aValue1 to: aValue2 [ 
	self announce: (GdsItemAttributeChanged new 
		item: self; 
		attribute: aSymbol;
		oldValue: aValue1;
		newValue: aValue2;
		yourself).
]

{ #category : #'as yet unclassified' }
GdsItemContext >> announceAttributeChanged: aSymbol to: aValue [
	self announceAttributeChanged: aSymbol from: nil to: aValue.
]

{ #category : #'as yet unclassified' }
GdsItemContext >> announcer [
	"Answer the announcer of the receiver."	
	^ announcer ifNil: [ announcer := Announcer new ]
]

{ #category : #'command-elementKind' }
GdsItemContext >> aref [
	self elementType: #aref.
	
]

{ #category : #'as yet unclassified' }
GdsItemContext >> arefActivated [
	^elementType == #aref.
]

{ #category : #'as yet unclassified' }
GdsItemContext >> arefEnabled [
	^ self srefEnabled "and: [more]"
]

{ #category : #accessing }
GdsItemContext >> ashape [
	^ashape
]

{ #category : #testing }
GdsItemContext >> ashapeInstalled [
	^(Smalltalk 
		at: #GdsAShapeContext
		ifAbsent: [ nil ]) notNil
]

{ #category : #'command-elementKind' }
GdsItemContext >> boundary [
	self elementType: #boundary.
	
]

{ #category : #testing }
GdsItemContext >> boundaryActivated [
	^self isBoundary.
]

{ #category : #testing }
GdsItemContext >> boundaryClosed [
	^(self isBoundary) and: [
	(self colVertices size > 3) and:
	[self colVertices first = self colVertices last]].

]

{ #category : #testing }
GdsItemContext >> boundaryEnabled [
	^true
]

{ #category : #'command-elementKind' }
GdsItemContext >> boxtext [
	self elementType: #boxtext.
	
]

{ #category : #'command-points' }
GdsItemContext >> ce: aPoint [
	| absPoint |
	aPoint class = Point
		ifFalse: [ self error: 'ce: require Point instance.' ].
	offset ifNil: [ offset := 0 @ 0 ].
	absPoint := offset + aPoint.
	self colVertices isEmpty
		ifFalse: [ 
			self colVertices last = absPoint
				ifTrue: [ ^ self ] ].
	self colVertices add: absPoint.
	self changedPutGetDependent
]

{ #category : #'command-points' }
GdsItemContext >> ceX: xValue y: yValue [
	self ce: (Point x: xValue y: yValue)
]

{ #category : #private }
GdsItemContext >> changedPutGetDependent [
	self lockMessages ifTrue: [ ^ self ].
	self putGetDependentSelectors do: [:each | self changed: each].
]

{ #category : #'accessing-points' }
GdsItemContext >> closeVertex [
	(self needsCloseBoundary)
		ifTrue: [colVertices add: (self colVertices first copy)].
]

{ #category : #private }
GdsItemContext >> colVertices [
	colVertices ifNil: [colVertices := OrderedCollection  new].
	 ^colVertices.
]

{ #category : #private }
GdsItemContext >> completionPointFrom: aPoint1 to: aPoint2 [
	| deltaPoint r theta roundedTheta |
	(self digitaizingMode = #straight)
		ifTrue: [^nil.].
	(self digitaizingMode = #octagonal)
		ifTrue: [
			deltaPoint := aPoint2 - aPoint1.
			r := deltaPoint r.
			theta := deltaPoint theta.
			roundedTheta := GeometryUtils octagonalRoundTheta: theta.
			^(Point r: r degrees: roundedTheta radiansToDegrees) + aPoint1.].
	(self digitaizingMode = #orthint)
		ifTrue: [
			^(self digitaizingDirection = #vertfirst)
				ifTrue: [(aPoint1 x)@(aPoint2 y)]
				ifFalse: [(aPoint2 x)@(aPoint1 y)]].
	^nil.
]

{ #category : #printing }
GdsItemContext >> consoleString [
	^String streamContents: [:s | self consoleStringOn: s.]
]

{ #category : #printing }
GdsItemContext >> consoleStringOn: aStream [
	self editElement ifNil: [^aStream nextPutAll: 'ITEM NOT GOTTEN'].
	aStream nextPutAll: 'ELEMENT TYPE: '.
	aStream nextPutAll: self elementType asString asUppercase.
	aStream cr.
	editElement 
		ifNotNil: [
			aStream nextPutAll: 'KEYNUMBER: '.
			aStream print: editElement keyNumber.
			aStream cr.].
	aStream nextPutAll: 'LAYER: '.
	aStream print: self layerNumber.
	aStream cr.
	aStream nextPutAll: 'DATATYPE: '.
	aStream print: self datatype.
	aStream cr.
	wire consoleStringOn: aStream.
	aStream cr.
	aStream nextPutAll: 'SNAME: '.
	aStream print: self structureName.
	aStream cr.
	strans consoleStringOn: aStream.
	aStream cr.
	ashape consoleStringOn: aStream.

]

{ #category : #copying }
GdsItemContext >> copyTo: aGdsItemContext [
	aGdsItemContext privateWipe.
	aGdsItemContext vertices: self vertices.
	
]

{ #category : #command }
GdsItemContext >> createElement [
	^self elementClass fromItemContext: self.

]

{ #category : #command }
GdsItemContext >> createElements [
	^ Array streamContents: [ :s |
		1 to: self vertices size do: [:index |
			s nextPut: (self elementClass fromItemContext: self atIndex: index)]]

]

{ #category : #accessing }
GdsItemContext >> datatype [
	^datatype
	
	

]

{ #category : #accessing }
GdsItemContext >> datatype: anInteger [
	datatype  = anInteger ifTrue: [^self].
	datatype := anInteger.
	self changed: #datatype.
	"TODO: remove this change. Model not known GUI"
	"self changed: #chooseDataTypeLabel.	"
	

]

{ #category : #command }
GdsItemContext >> digitaizingDirection [
	digitaizingDirection ifNil: [digitaizingDirection := #vertfirst.].
	^digitaizingDirection.
	

]

{ #category : #command }
GdsItemContext >> digitaizingDirection: aSymbol [
	digitaizingDirection := aSymbol.
	self changed: #vertfirstActivated.
	self changed: #horizfirstActivated.	
]

{ #category : #accessing }
GdsItemContext >> digitaizingMode [
	digitaizingMode ifNil: [self digitaizingMode: #straight].
	^digitaizingMode

]

{ #category : #accessing }
GdsItemContext >> digitaizingMode: aSymbol [
	digitaizingMode = aSymbol ifTrue: [^self].
	digitaizingMode := aSymbol.

	self orthintActivated 
		ifTrue:[
			self changed: #vertfirstActivated.
			self changed: #horizfirstActivated.].
		
	self changed: #vertfirstEnabled.
	self changed: #horizfirstEnabled.
	
	self changed: #straightActivated.
	self changed: #octagonalActivated.
	self changed: #orthintActivated.
	self announceAttributeChanged: #digitaizingMode to: digitaizingMode.

]

{ #category : #accessing }
GdsItemContext >> editElement [
	^editElement
]

{ #category : #command }
GdsItemContext >> elementClass [
	^GdsElement classForType: elementType.

]

{ #category : #accessing }
GdsItemContext >> elementType [
	^elementType
]

{ #category : #accessing }
GdsItemContext >> elementType: aSymbol [
	elementType = aSymbol ifTrue: [^self].
	elementType := aSymbol.
	self changed: #elementType.
	self changed: #boundaryActivated.
	self changed: #pathActivated.
	self changed: #srefActivated.	
	self changed: #arefActivated.	
	self changedPutGetDependent.
	self announceAttributeChanged: #elementType.
]

{ #category : #testing }
GdsItemContext >> enterTextEnabled [
	^true
]

{ #category : #utility }
GdsItemContext >> feedbackElements [
	| el |
	el := self  editElement.
	el ifNotNil: [
		el := el copy.
		[el fromItemContext: self]
			on: Error do: [:ex | ^#() copy].
		^Array with: el ].
	
	^[self isReferenceType
			ifTrue: [self  createElements] 
			ifFalse: [ Array with: self createElement ]]
		on: Error do:  [:ex | #() copy].
]

{ #category : #utility }
GdsItemContext >> fixMag: aFactor [
	^(aFactor asFloat <= 0.0) ifTrue: [1.0] ifFalse: [aFactor asFloat].

	
]

{ #category : #private }
GdsItemContext >> forgetStructure [
	"structure ifNotNil: [
		self removeDependent: structure.
		self announcer unsubscribe: structure.
		structure := nil]"
	
]

{ #category : #command }
GdsItemContext >> get: aGdsElement [
	self colVertices ifNotEmpty: [^self error: 'item not empty'].
	self importAttribute: aGdsElement.
	aGdsElement statusNumber: itemNumber.
	editElement := aGdsElement.
	self changed.
	self changedPutGetDependent.
]

{ #category : #testing }
GdsItemContext >> getEnabled [
	^editElement isNil and: [self vertices isEmpty].

]

{ #category : #testing }
GdsItemContext >> holdsElement [
	^editElement isNil not.

]

{ #category : #'command-digitaizingMode' }
GdsItemContext >> horizfirst [
	self digitaizingDirection: #horizfirst.
	
	
]

{ #category : #'testing - dizitizing' }
GdsItemContext >> horizfirstActivated [
	^digitaizingDirection == #horizfirst.
	
	
]

{ #category : #'testing - dizitizing' }
GdsItemContext >> horizfirstEnabled [
	^self isPrimitiveType and: [digitaizingMode == #orthint].
	
	
]

{ #category : #command }
GdsItemContext >> importAttribute: aGdsElement [
	self ownColor: aGdsElement ownColor.
	aGdsElement hasLayer ifTrue: [self layerNumber: aGdsElement layerNumber].
	aGdsElement hasDataType ifTrue: [self pathtype: aGdsElement datatype].
	aGdsElement hasPathType ifTrue: [self pathtype: aGdsElement pathtype].
	aGdsElement hasWidth ifTrue: [self width: aGdsElement width].
	(aGdsElement isMemberOf: GdsBoxText ) ifTrue: [self text: aGdsElement contents].
	(aGdsElement isKindOf: GdsStructureReference)
		ifTrue: [
			self structureName: aGdsElement structureName.
			self angle: aGdsElement angle.
			self mag: aGdsElement mag .
			self setReflected: aGdsElement isReflected].
	self colVertices addAll: aGdsElement vertices.
	(aGdsElement type = #aref)
		ifTrue: [
			ashape xStep: aGdsElement xStep.
			ashape yStep: aGdsElement yStep.
			ashape columnCount: aGdsElement columnCount.
			ashape rowCount: aGdsElement rowCount.
			colVertices := nil.
			self colVertices add: aGdsElement xy.].
	wire removeGeometryCache.
	self elementType: aGdsElement type.
]

{ #category : #initialization }
GdsItemContext >> initWithNumber: anInteger [
	self initialize.
	itemNumber := anInteger.
	offset := 0 @ 0.
	layerNumber := 1.
	datatype := 0.
	structureName := ''.
	wire := GdsWireContext new.
	strans := GdsStructureTransform new.
	ashape := nil.
	(Smalltalk at: #GdsAShapeContext ifAbsent: [ nil ])
		ifNotNil: [ :clazzAref | ashape := clazzAref new propertyOwner: self ].
	self digitaizingMode: #straight.
	self elementType: #boundary
]

{ #category : #testing }
GdsItemContext >> isAbsAngle [
	^false "should implement."
	
]

{ #category : #testing }
GdsItemContext >> isAbsMag [
	^false "should implement."
	
]

{ #category : #testing }
GdsItemContext >> isBoundary [
	^elementType == #boundary.
]

{ #category : #testing }
GdsItemContext >> isEmpty [
	^self colVertices isEmpty
]

{ #category : #testing }
GdsItemContext >> isPrimitiveType [
	^self isReferenceType not
]

{ #category : #testing }
GdsItemContext >> isReferenceType [
	^self elementClass isReference
]

{ #category : #private }
GdsItemContext >> isReflected [
	^strans isReflected
	
]

{ #category : #testing }
GdsItemContext >> itemReverseEnabled [
	^ self vertexCount >= 2
]

{ #category : #accessing }
GdsItemContext >> items: aGdsItems [
	items := aGdsItems.

]

{ #category : #accessing }
GdsItemContext >> keyNumber [
	editElement ifNil: [ ^-1 ].
	^editElement keyNumber
]

{ #category : #testing }
GdsItemContext >> layerEnabled [
	self elementClass ifNil: [^false].
	^self elementClass hasLayer.
]

{ #category : #accessing }
GdsItemContext >> layerNumber [
	^layerNumber.
]

{ #category : #accessing }
GdsItemContext >> layerNumber: aInteger [
	layerNumber = aInteger ifTrue: [^self].
	layerNumber := aInteger.
	self changed: #layerNumber.
	"TODO: remove this change. Model not known GUI"	
	self changed: #chooseLayerLabel.	

]

{ #category : #accessing }
GdsItemContext >> lockMessages [
	^ lockMessages ifNil: [ lockMessages := false ].
]

{ #category : #accessing }
GdsItemContext >> lockMessages: aBoolean [
	lockMessages := aBoolean
]

{ #category : #accessing }
GdsItemContext >> lockMessagesDuring: aBlock [
	self lockMessages: true.
	aBlock ensure: [ self lockMessages: false ]
]

{ #category : #accessing }
GdsItemContext >> mag [
	^strans mag.
	
]

{ #category : #accessing }
GdsItemContext >> mag: aFactor [
	| oldValue newValue |
	oldValue := self fixMag: self mag.
	newValue := self fixMag: aFactor.
	oldValue = newValue ifTrue: [^self].
	self privateMag: newValue.
	
]

{ #category : #testing }
GdsItemContext >> needsCloseBoundary [
	^ self isBoundary
		and: [ self colVertices size >= 3 and: [ self colVertices first ~= self colVertices last ] ]
]

{ #category : #accessing }
GdsItemContext >> number [
	^itemNumber
]

{ #category : #private }
GdsItemContext >> number: aNumber [
	itemNumber := aNumber.
	
]

{ #category : #'command-digitaizingMode' }
GdsItemContext >> octagonal [
	self digitaizingMode: #octagonal.

]

{ #category : #'testing - dizitizing' }
GdsItemContext >> octagonalActivated [
	^digitaizingMode == #octagonal.

]

{ #category : #'testing - dizitizing' }
GdsItemContext >> octagonalEnabled [
	^self isPrimitiveType 

]

{ #category : #'command-digitaizingMode' }
GdsItemContext >> orthint [
	self digitaizingMode: #orthint.

]

{ #category : #'testing - dizitizing' }
GdsItemContext >> orthintActivated [
	^digitaizingMode == #orthint.

]

{ #category : #'testing - dizitizing' }
GdsItemContext >> orthintEnabled [
	^self isPrimitiveType 

]

{ #category : #accessing }
GdsItemContext >> ownColor [
	^ ownColor
]

{ #category : #accessing }
GdsItemContext >> ownColor: aColor [
	ownColor := aColor
]

{ #category : #'command-elementKind' }
GdsItemContext >> path [
	self elementType: #path.
	
]

{ #category : #testing }
GdsItemContext >> pathActivated [
	^elementType == #path.
]

{ #category : #testing }
GdsItemContext >> pathEnabled [
	^true
]

{ #category : #testing }
GdsItemContext >> pathTypeEnabled [
	self elementClass ifNil: [^false].
	^self elementClass = GdsPath.
]

{ #category : #accessing }
GdsItemContext >> pathtype [
	^wire pathtype
	
	

]

{ #category : #accessing }
GdsItemContext >> pathtype: anInteger [
	wire pathtype  = anInteger ifTrue: [^self].
	wire pathtype: anInteger.
	self changed: #pathtype.
	"TODO: remove this change. Model not known GUI"
	self changed: #choosePathTypeLabel.	
	
	

]

{ #category : #printing }
GdsItemContext >> printOn: aStream [
	aStream nextPutAll: 'ITEM: '.
	aStream nextPutAll: itemNumber printString.
]

{ #category : #private }
GdsItemContext >> privateAngle: aDegree [
	strans angle: aDegree.
	self changed: #angle.
	"TODO: remove this change. Model not known GUI"
	self changed: #requestAngleLabel.	
	self announceAttributeChanged: #angle.
	
]

{ #category : #private }
GdsItemContext >> privateMag: aFloat [
	strans mag: aFloat.
	self changed: #mag.
	"TODO: remove this change. Model not known GUI"
	self changed: #requestMagLabel.	
	
]

{ #category : #private }
GdsItemContext >> privateReflected: aBoolean [
	strans setReflected: aBoolean.
	self changed: #reflected.
	self changed: #toggleReflectLabel.
	
]

{ #category : #private }
GdsItemContext >> privateUnget [
	editElement ifNil: [self error: 'item is not holds element'].
	self colVertices ifEmpty: [ self error: 'empty vertices' ].
	self elementClass ifNil: [ self error: 'element type not set' ].
	self privateWipe.	
	editElement statusNumber: GdsElement inDatabaseStausNumber.
	editElement := nil.

]

{ #category : #private }
GdsItemContext >> privateWipe [
	colVertices := nil.
	
]

{ #category : #command }
GdsItemContext >> put [
	self colVertices ifEmpty: [ self error: 'empty vertices' ].
	self elementClass ifNil: [ self error: 'element type not set' ].
	(self elementClass isReference)
		ifTrue: [ self putReference]
		ifFalse: [ self putPrimitive].
]

{ #category : #'as yet unclassified' }
GdsItemContext >> putBoxText: aRectangle [
	self assert: aRectangle origin ~= aRectangle corner.
	self boxtext.
	self ce: aRectangle origin.
	self ce: aRectangle corner.
	self put.
]

{ #category : #testing }
GdsItemContext >> putEnabled [
	self elementClass ifNil: [^false].
	^(self vertexCount >= self elementClass requiredVertexCount)

]

{ #category : #command }
GdsItemContext >> putEpilogue: newElement [
	self privateWipe.
	editElement := nil.
	self changed.
	newElement ifNotNil: [self changed: #newElement].
	self changed: #put.
	self changedPutGetDependent.
	
]

{ #category : #private }
GdsItemContext >> putGetDependentSelectors [
	| col |
	col := OrderedCollection new.
	col add: #boundaryEnabled.
	col add: #pathEnabled.
	col add: #srefEnabled.
	col add: #arefEnabled.
	
	col add: #putEnabled.
	col add: #ungetEnabled.
	col add: #ceEnabled.
	col add: #getElementEnabled.
	col add: #confirmWipeEnabled.

	col add: #itemMoveEnabled.
	col add: #itemStretchEnabled.
	col add: #itemMovePointEnabled.
	col add: #itemDeleteVertexEnabled.
	col add: #itemReverseEnabled.
	
	col add: #chooseLayerEnabled.
	col add: #requestWidthEnabled.
	col add: #choosePathTypeEnabled.

	col add: #chooseStructureNameEnabled.
	col add: #requestAngleEnabled.
	col add: #requestMagEnabled.
	col add: #toggleReflectEnabled.
	col add: #requestArrayShapeEnabled.

	col add: #tstructEnabled.
	col add: #holdsElement.
	"dizitizing direction"
	col add: #vertfirstEnabled.
	col add: #horizfirstEnabled.
	col add: #octagonalEnabled.
	col add: #straightEnabled.
	col add: #orthintEnabled.
	^ col asArray
]

{ #category : #utility }
GdsItemContext >> putPathFrom: aPoint1 to: aPoint2 [
	self  path.
	self  ce: aPoint1.
	self  ce: aPoint2.
	self  put.
]

{ #category : #command }
GdsItemContext >> putPrimitive [
	| newElement savedKeyNumber |
	savedKeyNumber := self keyNumber.
	newElement := self createElement.
	savedKeyNumber negative
		ifFalse: [ newElement keyNumber: savedKeyNumber ].
	editElement
		ifNotNil: [ self structure removeElement: editElement.
			editElement isNil ].
	self structure addElement: newElement.
	newElement statusNumber: GdsElement inDatabaseStausNumber.
	self putEpilogue: newElement
]

{ #category : #utility }
GdsItemContext >> putRecangleExtent: aSize centerAt: aPoint. [
	self putRectangle: (Rectangle center: aPoint extent: aSize asPoint).
]

{ #category : #utility }
GdsItemContext >> putRectangle: aRectangle [
	self  boundary.
	(GeometryUtils verticesFromBounds: aRectangle)
		do: [:each | self  ce: each].
	self  put.
]

{ #category : #command }
GdsItemContext >> putReference [
	| targetElement newElement targetElements removeElements |
	newElement := false.
	removeElements := #().
	editElement
		ifNil: [newElement := true]
		ifNotNil: [
			elementType ~= editElement type
				ifTrue: [
					newElement := true.
					removeElements := Array with: editElement]].

	newElement
		ifTrue: [
			targetElements := self createElements.
			targetElements do: [:each |
				self structure addElement: each.]]
		ifFalse: [
			targetElement := editElement.
			targetElement fromItemContext: self atIndex: 1.
			targetElements := Array with: targetElement].

	targetElements 
		do: [:each |
			each statusNumber: GdsElement inDatabaseStausNumber.].

	removeElements 
		do: [:each |
			each statusNumber: GdsElement inTrushStausNumber.].

	self putEpilogue: newElement
	
]

{ #category : #utility }
GdsItemContext >> putSegment: aLineSegment [
	self putPathFrom: aLineSegment start to: aLineSegment end 
]

{ #category : #utility }
GdsItemContext >> putSquareSize: aSize centerAt: aPoint [
]

{ #category : #private }
GdsItemContext >> refreshBounds [
	"dummy"
]

{ #category : #initialization }
GdsItemContext >> release [
	ashape ifNotNil: 
		[ ashape removeDependent: self.
		ashape := nil ].
	super release
]

{ #category : #'accessing-points' }
GdsItemContext >> removeVertexAt: anIndex [	
	| savedSize closed |
	savedSize := self colVertices size.
	savedSize = 0 ifTrue: [^self].
	closed := (savedSize >= 4) and: [self colVertices first = self colVertices last].
	colVertices removeAt: anIndex.
	(self isBoundary and: [closed])
		ifTrue: [
			anIndex = 1
				ifTrue: [colVertices removeLast].
			anIndex = savedSize
				ifTrue: [colVertices removeFirst].
			self closeVertex].
	self changed: #geometry.
]

{ #category : #'develop-now' }
GdsItemContext >> reverseVertices [
	self vertexCount < 2 ifTrue: [^self].
	colVertices := colVertices reversed.
	self changed: #geometry.
	
]

{ #category : #private }
GdsItemContext >> safeReset [
	structureName := ''.
	strans safeReset.
	
	
	
]

{ #category : #private }
GdsItemContext >> setReflected: aBoolean [
	self privateReflected: aBoolean.
	
]

{ #category : #testing }
GdsItemContext >> snameSpecified [
	^ structureName isNotEmpty
]

{ #category : #'command-elementKind' }
GdsItemContext >> sref [
	self elementType: #sref.
	
]

{ #category : #testing }
GdsItemContext >> srefActivated [
	^elementType == #sref.
]

{ #category : #testing }
GdsItemContext >> srefEnabled [
	self structure ifNil: [ ^ false ].
	self structure library ifNil: [ ^ false ].
	^ self structure referenceEnabledStructureNames isNotEmpty
]

{ #category : #'command-digitaizingMode' }
GdsItemContext >> straight [
	self digitaizingMode: #straight.
	
]

{ #category : #'testing - dizitizing' }
GdsItemContext >> straightActivated [
	^digitaizingMode == #straight.
	
]

{ #category : #'testing - dizitizing' }
GdsItemContext >> straightEnabled [
	^self isPrimitiveType 
	
]

{ #category : #'as yet unclassified' }
GdsItemContext >> structure [
	^ structure
]

{ #category : #initialization }
GdsItemContext >> structure: aGdsStructure [
	structure := aGdsStructure.
]

{ #category : #accessing }
GdsItemContext >> structureName [
	^structureName
]

{ #category : #accessing }
GdsItemContext >> structureName: aString [
	structureName := aString.
	self changed: #sname.
	self changed: #srefEnabled.
	self changed: #ceEnabled.
	self changed: #chooseStructureNameLabel. "BAD BUT..."

]

{ #category : #accessing }
GdsItemContext >> text [
	text ifNil: [text := 'UNTITLED'].
	^text
	
]

{ #category : #accessing }
GdsItemContext >> text: aString [
	text = aString ifTrue: [^self].
	text := aString.
	self changed: #text.
	
]

{ #category : #utility }
GdsItemContext >> toggleReflect [
	self  setReflected: self  isReflected not.
]

{ #category : #'command-points' }
GdsItemContext >> translate: aPoint [
	| col |
	aPoint class = Point
		ifFalse: [self error: 'ce: require Point instance.'].
	(self colVertices size <= 0)
		ifTrue: [self error: 'empty vertices'.].
	col := colVertices copy.
	col doWithIndex: [ :p :i |
		colVertices at: i put: p + aPoint.].
	self changed: #geometry.
]

{ #category : #command }
GdsItemContext >> unget [
	self privateUnget.
	self changed.
	self changed: #unget.
	self changedPutGetDependent.
]

{ #category : #testing }
GdsItemContext >> ungetEnabled [
	^self holdsElement

]

{ #category : #'as yet unclassified' }
GdsItemContext >> update: anObject [
	(#(columnCount rowCount) includes: anObject)
		ifTrue: [^self changed: #requestArrayShapeLabel].
	super update: anObject.
]

{ #category : #'accessing-points' }
GdsItemContext >> vertexCount [
	(self isBoundary and: [self vertices size > 1])
		ifTrue: [
			self vertices first = self vertices last
				ifTrue: [^self vertices size - 1]].
	^self vertices size
]

{ #category : #'command-digitaizingMode' }
GdsItemContext >> vertfirst [
	self digitaizingDirection: #vertfirst.

]

{ #category : #'testing - dizitizing' }
GdsItemContext >> vertfirstActivated [
	^digitaizingDirection == #vertfirst.

]

{ #category : #'testing - dizitizing' }
GdsItemContext >> vertfirstEnabled [
	^self isPrimitiveType and: [digitaizingMode == #orthint].

]

{ #category : #'accessing-points' }
GdsItemContext >> vertices [
	^self colVertices asArray.
]

{ #category : #'accessing-points' }
GdsItemContext >> verticesAt: index put: aPoint [
	self verticesAt:  index put: aPoint  fixClosed: self isBoundary.
]

{ #category : #'accessing-points' }
GdsItemContext >> verticesAt: index put: aPoint fixClosed: aBoolean. [
	(aBoolean and: [index = 1 or: [colVertices size = index]])
		ifFalse: [colVertices at: index put: aPoint]
		ifTrue: [
			colVertices at: 1 put: aPoint.
			colVertices at: (colVertices size) put: aPoint].
	self changed: #geometry.
]

{ #category : #'accessing-points' }
GdsItemContext >> verticesBounds [
	^GeometryUtils lookupDataBounds: self vertices.
]

{ #category : #'accessing-points' }
GdsItemContext >> verticesWithoutClosePoint [
	self boundaryClosed
		ifTrue: [^self vertices allButLast].	
	^self vertices
]

{ #category : #accessing }
GdsItemContext >> width [
	^wire width
	
	

]

{ #category : #accessing }
GdsItemContext >> width: aFloat [
	| oldValue |
	wire width  = aFloat ifTrue: [^self].
	oldValue := wire width.
	wire width: aFloat.
	(GdsProperty new owner: self) 
		postNotificationProperty: #width oldValue: oldValue newValue: wire width. 
	self changed: #width.
	"TODO: remove this change. Model not known GUI"
	self changed: #requestWidthLabel.	

]

{ #category : #testing }
GdsItemContext >> widthEnabled [
	self elementClass ifNil: [^false].
	^self elementClass hasWidth.
]

{ #category : #command }
GdsItemContext >> wipe [
	self privateWipe.
	editElement 
		ifNotNil: [
			editElement wipe.
			self structure removeElement: editElement.
			editElement := nil.].
	self changed.
	self changed: #wipe.
	self changedPutGetDependent.
	
]

{ #category : #testing }
GdsItemContext >> wipeEnabled [
	^self holdsElement

]
