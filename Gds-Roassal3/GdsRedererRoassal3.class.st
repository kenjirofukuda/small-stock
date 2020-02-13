Class {
	#name : #GdsRedererRoassal3,
	#superclass : #Object,
	#traits : 'TGdsStructureDrawable',
	#classTraits : 'TGdsStructureDrawable classTrait',
	#instVars : [
		'element',
		'structureDictionary',
		'structure',
		'canvas'
	],
	#category : #'Gds-Roassal3'
}

{ #category : #'as yet unclassified' }
GdsRedererRoassal3 class >> forElement: aGdsElement [
	^ self new initializeElement: aGdsElement
]

{ #category : #'as yet unclassified' }
GdsRedererRoassal3 class >> forStructure: aGdsStructure [
	^ self new initializeStructure: aGdsStructure
]

{ #category : #appearance }
GdsRedererRoassal3 >> backgroundColor [
	<override: 'TStructureDrawable'>
	^ Color black
]

{ #category : #visiting }
GdsRedererRoassal3 >> compositeClass [
	^ HgRSComposite
]

{ #category : #initialization }
GdsRedererRoassal3 >> initialize [ 
	structureDictionary := Dictionary new.
]

{ #category : #initialization }
GdsRedererRoassal3 >> initializeElement: aGdsElement [ 
	element := aGdsElement
]

{ #category : #initialization }
GdsRedererRoassal3 >> initializeStructure: aGdsStructure [ 
	structure := aGdsStructure
]

{ #category : #initialization }
GdsRedererRoassal3 >> lookupShapeOfStructureNamed: aStructureName [
	| struct composite |
	struct := self structure library structureNamed: aStructureName.
	composite := self compositeClass new.
	(struct children)
		do: [ :each | composite add: (each accept: self) ].
	composite updateBaseRectangle: struct dataExtentForElements.
	^ composite
]

{ #category : #initialization }
GdsRedererRoassal3 >> render [
	| shape prevScale |
	canvas := HgRSCanvas new.
	canvas color: self backgroundColor.
	shape := self renderTarget accept: self.
	shape matrix: (AthensAffineTransform new scaleX: 1.0 Y: -1.0).
	shape updateBaseRectangle.
	canvas add: shape.
	canvas zoomToFit.
	canvas @ RSCanvasController.
	prevScale := 1.0.
	canvas newAnimation
		repeat;
		duration: 1 seconds;
		onStepDo: [ :t | 
			(prevScale closeTo: canvas camera scale)
				ifFalse: [ 
					canvas clipedShapes do: [ :each | self setCosmetic: each ].
					prevScale := canvas camera scale .
					canvas signalUpdate] ].
	^ canvas
]

{ #category : #initialization }
GdsRedererRoassal3 >> renderTarget [
	^ structure ifNil: [ element ] ifNotNil: [ structure ].
	
]

{ #category : #initialization }
GdsRedererRoassal3 >> setCosmetic: aRSShape [
	| scale |
	(aRSShape isKindOf: RSComposite)
		ifTrue: [ ^ aRSShape children do: [ :each | self setCosmetic: each ] ].
	scale := canvas camera scale.
	aRSShape border ifNil: [ aRSShape withBorder ].
	aRSShape border width: 1.0 / scale
]

{ #category : #visiting }
GdsRedererRoassal3 >> shapeForStrokeVertices: aPointCollection [
	^ RSPolyline new
		controlPoints: aPointCollection;
		withBorder;
		yourself.

]

{ #category : #initialization }
GdsRedererRoassal3 >> shapeOfStructureNamed: aStructureName [
	^ structureDictionary at: aStructureName ifAbsentPut: [ self lookupShapeOfStructureNamed: aStructureName ].
]

{ #category : #accessing }
GdsRedererRoassal3 >> structure [
	<override: 'TStructureDrawable'>
	structure ifNotNil: [ ^ structure ].
	^ element structure
]

{ #category : #visiting }
GdsRedererRoassal3 >> visitAref: aGdsArrayedStructureReference [
	| composite |
	composite := self compositeClass new.
	composite model: aGdsArrayedStructureReference.
	aGdsArrayedStructureReference repeatTransforms
		do: [ :each | 
			| base |
			base := self
				visitStructure: aGdsArrayedStructureReference refStructure
				transform: each.
			composite add: base ].
	composite updateBaseRectangle: aGdsArrayedStructureReference dataBounds.
	^ composite
]

{ #category : #visiting }
GdsRedererRoassal3 >> visitBoundary: aGdsBoundary [
	| outline shape |
	outline := self shapeForStrokeVertices: aGdsBoundary vertices.
	shape := self compositeClass new.
	shape add: outline.
	shape model: aGdsBoundary.
	shape updateBaseRectangle.
	shape children
		do:
			[ :each | each border color: (self colorForLayer: aGdsBoundary layerNumber) ].
	^ shape
]

{ #category : #visiting }
GdsRedererRoassal3 >> visitPath: aGdsPath [
	| pathCenter pathBoundary shape |
	pathCenter := self shapeForStrokeVertices: aGdsPath vertices.
	pathBoundary := self
		shapeForStrokeVertices: aGdsPath dataOutlinePoints.
	shape := self compositeClass new.
	shape add: pathCenter.
	shape add: pathBoundary.
	shape model: aGdsPath.
	shape updateBaseRectangle.
	shape children
		do:
			[ :each | each border color: (self colorForLayer: aGdsPath layerNumber) ].
	^ shape
]

{ #category : #visiting }
GdsRedererRoassal3 >> visitPrimitiveElement: aGdsPrimitiveElement [
	| shape |
	shape := self shapeForStrokeVertices: aGdsPrimitiveElement vertices.
	shape model: aGdsPrimitiveElement.
	shape color: (self colorForLayer: aGdsPrimitiveElement layerNumber) .
	^ shape
]

{ #category : #visiting }
GdsRedererRoassal3 >> visitSref: aGdsStructureReference [
	| composite |
	composite := self visitStructure: aGdsStructureReference refStructure  transform: aGdsStructureReference transform.
	composite model: aGdsStructureReference.
	^ composite
]

{ #category : #visiting }
GdsRedererRoassal3 >> visitStructure: aGdsStructure [
	^ self visitStructure: aGdsStructure transform: nil
]

{ #category : #visiting }
GdsRedererRoassal3 >> visitStructure: aGdsStructure transform: aTransform [
	| composite |
	composite := (self shapeOfStructureNamed: aGdsStructure name) copy.
	aTransform ifNotNil: [ composite matrix: aTransform asAthensAT ].
	composite updateBaseRectangle.
	^ composite
]
