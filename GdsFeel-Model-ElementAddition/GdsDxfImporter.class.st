Class {
	#name : #GdsDxfImporter,
	#superclass : #Object,
	#category : #'GdsFeel-Model-ElementAddition'
}

{ #category : #'as yet unclassified' }
GdsDxfImporter class >> enabled [
	^ (Smalltalk at: #DxfFile ifAbsent: [  ]) notNil.
	
]

{ #category : #'as yet unclassified' }
GdsDxfImporter class >> pluginOn: aBuilder [
	<gdsPlugin>
	
]

{ #category : #'as yet unclassified' }
GdsDxfImporter >> attributesFromDxfArc: aDxfShape element: aGdsElement [
	self attributesFromDxfCircle: aDxfShape element: aGdsElement.
	aGdsElement startAngleDegress: aDxfShape startAngleDegress.
	aGdsElement endAngleDegress: aDxfShape endAngleDegress.
	

]

{ #category : #'as yet unclassified' }
GdsDxfImporter >> attributesFromDxfCircle: aDxfShape element: aGdsElement [
	self attributesFromDxfPoint: aDxfShape element: aGdsElement.
	aGdsElement radius: aDxfShape radius.
	

]

{ #category : #'as yet unclassified' }
GdsDxfImporter >> attributesFromDxfInsert: aDxfShape element: aGdsElement [
	aGdsElement xy: aDxfShape centerX @ aDxfShape centerY.
	aGdsElement mag: (aDxfShape scaleX max: aDxfShape scaleY).
	aGdsElement angle: aDxfShape angleDegress.
	(aDxfShape rowCount + aDxfShape columnCount) > 2
		ifTrue: [ 
			aGdsElement rowCount: aDxfShape rowCount.
			aGdsElement columnCount: aDxfShape columnCount.
			aGdsElement yStep: aDxfShape rowSpacing.
			aGdsElement xStep: aDxfShape columnSpacing.].
]

{ #category : #'as yet unclassified' }
GdsDxfImporter >> attributesFromDxfLine: aDxfShape element: aGdsElement [
	aGdsElement 
		vertices: (
			Array 
				with: (aDxfShape startX @ aDxfShape startY) 
				with: (aDxfShape endX @ aDxfShape endY)) 

]

{ #category : #'as yet unclassified' }
GdsDxfImporter >> attributesFromDxfMtext: aDxfShape element: aGdsElement [
	"aGdsElement 
		vertices: (
			Array 
				with: (aDxfShape firstX @ aDxfShape firstY) 
				with: ((aDxfShape firstX + aDxfShape width) @ aDxfShape firstY + aDxfShape height)) ."
	aGdsElement 
		vertices: (
			Array 
				with: (aDxfShape firstX @ aDxfShape firstY) 
				with: ((aDxfShape firstX + (aDxfShape height * aDxfShape text size)) @ aDxfShape firstY + aDxfShape height)) .
	aGdsElement contents: aDxfShape text.
	aGdsElement angle: aDxfShape angleDegress.

]

{ #category : #'as yet unclassified' }
GdsDxfImporter >> attributesFromDxfPoint: aDxfShape element: aGdsElement [
	aGdsElement centerPoint: (aDxfShape centerX @ aDxfShape centerY).
]

{ #category : #'as yet unclassified' }
GdsDxfImporter >> attributesFromDxfPolyline: aDxfShape element: aGdsElement [
	aGdsElement vertices: aDxfShape points.
	aGdsElement fixGeometryError.
]

{ #category : #'as yet unclassified' }
GdsDxfImporter >> attributesFromDxfText: aDxfShape element: aGdsElement [
	"aGdsElement 
		vertices: (
			Array 
				with: (aDxfShape firstX @ aDxfShape firstY) 
				with: ((aDxfShape firstX + aDxfShape width) @ aDxfShape firstY + aDxfShape height)) ."
	aGdsElement 
		vertices: (
			Array 
				with: (aDxfShape firstX @ aDxfShape firstY) 
				with: ((aDxfShape firstX + (aDxfShape height * aDxfShape text size)) @ aDxfShape firstY + aDxfShape height)) .
	aGdsElement contents: aDxfShape text.
	aGdsElement angle: aDxfShape angleDegress.

]

{ #category : #accessing }
GdsDxfImporter >> caption [
	^ 'Import DXF'
]

{ #category : #plugin }
GdsDxfImporter >> entryPoint [
	| dxf |
	dxf := nil.
	GdsStation default structure 
		ifNil: [ ^ self inform: 'Structure Not Opend'].
	(Smalltalk at: #DxfFile ifAbsent: [])
		ifNil: [ ^ self inform: 'DxfFile class not installed' ]	
		ifNotNil: [ :clazz | 
			dxf := clazz fromUser ].
	dxf ifNil: [ ^ self inform: 'DXF import canceled '  ].
	dxf shapes ifEmpty: [ ^ self inform: ' shpae not found ' ].	
	self import: dxf.
	self structure inspect.
	
				
]

{ #category : #'as yet unclassified' }
GdsDxfImporter >> gdsElementClassOf: aDxfShape [
	|  className |
	className := aDxfShape class asString.
	(className sameAs: 'DxfLine')
		ifTrue:  [ ^ GdsPath ].
	(className sameAs: 'DxfCircle')
		ifTrue:  [ ^ GdsAcCircle ].
	(className sameAs: 'DxfArc')
		ifTrue:  [ ^ GdsAcArc ].
	(className sameAs: 'DxfPoint')
		ifTrue:  [ ^ GdsAcPoint ].
	(className sameAs: 'DxfPolyline')
		ifTrue:  [ ^ aDxfShape isClosed ifTrue: [ GdsBoundary ] ifFalse: [ GdsPath ] ].
	(className sameAs: 'DxfMtext')
		ifTrue:  [ ^ GdsBoxText ].
	(className sameAs: 'DxfText')
		ifTrue:  [ ^ GdsBoxText ].
	(className sameAs: 'DxfInsert')
		ifTrue:  [ 
			^ aDxfShape isMultiple 
				ifTrue: [ GdsArrayedStructureReference  ] 
				ifFalse: [ GdsStructureReference ] ].
	^ nil
	

]

{ #category : #'as yet unclassified' }
GdsDxfImporter >> import: dxf [
	self structure setProperty: #dxfFile toValue: dxf.
	self importLayers: dxf.
	dxf shapes do: [ :each | self import: dxf shape: each ].
	self structure changed: #geometry.
	self structure comitDirty. 
				
]

{ #category : #'as yet unclassified' }
GdsDxfImporter >> import: dxf shape: aDxfShape [
	| gdsElementClass element sel |
	gdsElementClass := self gdsElementClassOf: aDxfShape.
	gdsElementClass ifNil: [ ^ self ].
	sel := self selectorOfDxfShape: aDxfShape.
	(self respondsTo: sel) ifFalse:  [^ self ].
	element := gdsElementClass basicNew initialize.
	element setProperty: #dxfShape toValue: aDxfShape.
	element ownColor: aDxfShape color.
	element datatype: 0.
	element pathtype: 0.
	element layerNumber: (self structure layers atName: (dxf layerOf: aDxfShape) name) layerNumber.
	self perform: sel with: aDxfShape with: element.
	self structure addElement: element.
	self structure pushDirtyReservedArea: element	
]

{ #category : #'as yet unclassified' }
GdsDxfImporter >> importLayers: dxf [
	| layerNumber |
	layerNumber := 0.
	dxf layers do: [ :each | | gdsLayer |
		gdsLayer := self structure layers atNumber: layerNumber.
		gdsLayer name: each name.
		gdsLayer color: each color.
		gdsLayer setProperty: #lineTypeName toValue: each lineTypeName.		
		gdsLayer setProperty: #dxfLayer toValue: each.
		layerNumber := layerNumber + 1.] 
]

{ #category : #'as yet unclassified' }
GdsDxfImporter >> layerOf: aDxfShape [
	aDxfShape layer.
]

{ #category : #'as yet unclassified' }
GdsDxfImporter >> selectorOfDxfShape: aDxfShape [
	^ ('attributesFrom', aDxfShape class asString, ':', 'element:') asSymbol.

]

{ #category : #accessing }
GdsDxfImporter >> structure [
	^ GdsStation default structure
]
