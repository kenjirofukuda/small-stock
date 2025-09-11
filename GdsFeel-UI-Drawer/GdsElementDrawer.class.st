"
A GdsElementDrawer is xxxxxxxxx.

Instance Variables
	element:		<GdsElement>
	fillImage:		<Form>
	fillMaskImage:		<Form>
	morph:		<GdsStructureMorph>
	strokeImage:		<Form>
	strokeMaskImage:		<Form>

element
	- xxxxx

fillImage
	- xxxxx

fillMaskImage
	- xxxxx

morph
	- xxxxx

strokeImage
	- xxxxx

strokeMaskImage
	- xxxxx

"
Class {
	#name : #GdsElementDrawer,
	#superclass : #Object,
	#instVars : [
		'element',
		'morph'
	],
	#category : #'GdsFeel-UI-Drawer'
}

{ #category : #'as yet unclassified' }
GdsElementDrawer class >> drawerClassForItemContext: aGdsItemContext [

	^ aGdsItemContext elementClass drawerClass
]

{ #category : #'deprecated MVC style' }
GdsElementDrawer class >> fromElement: aGdsElement morph: aMorph [

	| drawer |
	drawer := aGdsElement drawerClass new.
	drawer element: aGdsElement.
	drawer morph: aMorph.
	^ drawer
]

{ #category : #testing }
GdsElementDrawer >> canDisplayKindForKey: aKey [

	"self isAtomicElement ifTrue: [ ^ true ]."
	^ (element structure kinds atKey: aKey) isVisible
]

{ #category : #testing }
GdsElementDrawer >> canDisplayOrigin [

	^ false
]

{ #category : #testing }
GdsElementDrawer >> canFill [

	^ morph fastDrawing not
]

{ #category : #defaults }
GdsElementDrawer >> defaultQDPatternIndex [

	^ 26
]

{ #category : #drawing }
GdsElementDrawer >> drawItemFeedbackOn: aCanvas [

	self subclassResponsibility
]

{ #category : #drawing }
GdsElementDrawer >> drawOriginOn: aCanvas [

	| origin |
	element vertices ifEmpty: [ ^ self ].
	origin := element xy.
	"origin crTrace."
	morph
		penColor: morph visibleMarkerColor
		during: [ morph drawOn: aCanvas markDiamondPointAt: origin ]
]

{ #category : #accessing }
GdsElementDrawer >> element [

	^ element
]

{ #category : #accessing }
GdsElementDrawer >> element: aGdsElement [

	element := aGdsElement
]

{ #category : #accessing }
GdsElementDrawer >> elementFill [

	self useFlatFill ifTrue: [ ^ self flatFill ].
	^ BitmapFillStyle fromForm: self petternForFill
]

{ #category : #drawing }
GdsElementDrawer >> fillOutlineOn: aCanvas [

	
]

{ #category : #accessing }
GdsElementDrawer >> flatFill [

	^ morph colorForElement: element
]

{ #category : #drawing }
GdsElementDrawer >> fullDrawOn: aCanvas [

	<todo: 're activate fillOutlineOn:'>
	element isReference ifFalse: [ 
		morph insideViewLevels ifFalse: [ ^ self ] ].
	element state = #inStructure ifTrue: [ 
		self canFill ifTrue: [ "self fillOutlineOn: aCanvas" ] ].
	self strokeOutlineOn: aCanvas.
	self optionalDrawOn: aCanvas
]

{ #category : #testing }
GdsElementDrawer >> isAtomicElement [
	^ element notNil and: [ element class name asString beginsWith: 'Gda' ]
]

{ #category : #testing }
GdsElementDrawer >> isDrawable [

	| drawer longSide pixelSize |
	drawer := GdsElementDrawer fromElement: self element morph: morph.
	longSide := self element dataBounds width max:
		            self element dataBounds height.
	pixelSize := self pixelSize: longSide.
	^ pixelSize > (morph fastDrawing
		   ifTrue: [ 10.0 ]
		   ifFalse: [ 2.0 ])
]

{ #category : #testing }
GdsElementDrawer >> isDrawableElement: aGdsElement [

	| drawer |
	drawer := GdsElementDrawer fromElement: aGdsElement morph: morph.
	^ drawer isDrawable
]

{ #category : #accessing }
GdsElementDrawer >> morph: aMorph [

	morph := aMorph
]

{ #category : #drawing }
GdsElementDrawer >> optionalDrawOn: aCanvas [

	self canDisplayOrigin ifTrue: [ self drawOriginOn: aCanvas ]
]

{ #category : #'drawing-attribute' }
GdsElementDrawer >> petternForFill [

	^ ColorForm
		  mappingWhiteToTransparentFrom:
		  (QDPattern formAt: self defaultQDPatternIndex)
		  blackAsColor: (morph colorForElement: element)
]

{ #category : #testing }
GdsElementDrawer >> pixelSize: worldSize [

	^ morph viewport pixelSize: worldSize abs asPoint
]

{ #category : #drawing }
GdsElementDrawer >> strokeOutlineOn: aCanvas [

	self subclassResponsibility
]

{ #category : #'drawing-utility' }
GdsElementDrawer >> strokeVerticesOn: aCanvas [

	self strokeVerticesOn: aCanvas points: element vertices
]

{ #category : #'drawing-utility' }
GdsElementDrawer >> strokeVerticesOn: aCanvas points: aPoints [

	morph drawOn: aCanvas polyLineVertices: aPoints
]

{ #category : #accessing }
GdsElementDrawer >> useFlatFill [

	^ false
]
