"
A GdsStructureMorph is GDSII structures editor view morph.

Instance Variables
	offCanvas:		<FormCanvas>
	penColor:		<Color>
	viewport:		<GdsViewport>
			


offCanvas
	- xxxxx

penColor
	- xxxxx

viewport
	- xxxxx

portStack
	- xxxxx

"
Class {
	#name : #GdsStructureViewMorph,
	#superclass : #PluggableLayersMorph,
	#traits : 'TGdsStructureDrawable',
	#classTraits : 'TGdsStructureDrawable classTrait',
	#instVars : [
		'penColor',
		'offCanvas',
		'viewport',
		'colClipBounds',
		'portStack',
		'viewRange',
		'fastDrawing',
		'lastResizeAtTime',
		'processFirstDrawing',
		'handleEventsBySelf',
		'ttContext',
		'autoFitOnResize',
		'state',
		'defaultToolClass',
		'contextMenu'
	],
	#category : #'GdsFeel-UI-Morph'
}

{ #category : #'as yet unclassified' }
GdsStructureViewMorph class >> exampleMorphOnly [
	"GdsStructureMorph exampleMorphOnly"
	| window |
	window := self new openInWindowLabeled: 'GDSII'.
	"why Color to white"
	(window submorphOfClass: self) color: Color black.
]

{ #category : #accessing }
GdsStructureViewMorph >> autoFitOnResize [
	^ autoFitOnResize ifNil: [ autoFitOnResize := false ]
]

{ #category : #accessing }
GdsStructureViewMorph >> autoFitOnResize: aBoolean [
	autoFitOnResize := aBoolean
]

{ #category : #accessing }
GdsStructureViewMorph >> backgroundColor [
	^ GdsFeelMorphic backgroundColor
]

{ #category : #accessing }
GdsStructureViewMorph >> backgroundColor: aColor [
	self color: aColor
]

{ #category : #initialization }
GdsStructureViewMorph >> bindCurrentItemFor: aGdsStructure [
	self unbindCurrentItemFor: aGdsStructure.
	aGdsStructure currentItem
		ifNotNil: [ :item | 
			item announcer
				when: GdsItemAttributeChanged
				send: #itemAttributeChanged:
				to: self ]
]

{ #category : #utility }
GdsStructureViewMorph >> clearAllProxyMorphs [
	self structure ifNil: [ ^ self ].
	self structure elements do: [ :each |
		self clearProxyMorph: each ]
]

{ #category : #utility }
GdsStructureViewMorph >> clearProxyMorph: aGdsElement [
	(aGdsElement valueOfProperty: #proxyMorph ifAbsent: [  ])
		ifNotNil: [ :m | self removeMorph: m ].
	aGdsElement removeProperty: #proxyMorph
]

{ #category : #drawing }
GdsStructureViewMorph >> clipedElements [
	"^ self structure elements"
	^ self clipedElements:  self viewport worldViewBounds.
	
	
]

{ #category : #drawing }
GdsStructureViewMorph >> clipedElements: viewBounds [
	^model liveElements select: [:each |
		each findBounds intersects: viewBounds.].
	
	
]

{ #category : #accessing }
GdsStructureViewMorph >> color: aColor [
	super color: aColor.
	self removeCachedCanvas.
	self invalidRect: self bounds.
]

{ #category : #accessing }
GdsStructureViewMorph >> contextMenu [

	^ contextMenu
]

{ #category : #accessing }
GdsStructureViewMorph >> contextMenu: aGdsTrackingValueBlock [
	"EXAMPLE:
		self contextMenu: [ :tracking | tracking event cursorPoint. ... ]"
	contextMenu := aGdsTrackingValueBlock
]

{ #category : #viewport }
GdsStructureViewMorph >> createViewport [
	| vp |
	vp := GdsViewport new.
	vp model: self model.
	vp pixelBoundsSelector: #innerBounds.
	vp pixelBoundsTarget: self.
	vp announcer 
		when: #viewTransformChanged 
		do: [ 
			self removeCachedCanvas.
			self changed.
			"self fireFirstdrawing "].
	^vp

]

{ #category : #deprecated }
GdsStructureViewMorph >> defaultBoundsDeprecated [
	^0@0 corner: 512@342.
		
	
]

{ #category : #defaults }
GdsStructureViewMorph >> defaultOffCanvasDepth [
	^32
	
]

{ #category : #drawing }
GdsStructureViewMorph >> drawInlineOn: aCanvas [
	super drawOn: aCanvas.
	self drawOffOn: aCanvas

]

{ #category : #drawing }
GdsStructureViewMorph >> drawLocalIgnoreItemOn: aLocalCanvas [
	self drawLocalIgnoreItemOn: aLocalCanvas elements: self visibleElements

]

{ #category : #drawing }
GdsStructureViewMorph >> drawLocalIgnoreItemOn: aLocalCanvas elements: aElements [
	self 
		drawLocalIgnoreItemOn: aLocalCanvas 
		elements:  aElements 
		drawBlock: [:canvas :element |
			self drawOn: canvas element: element] 
]

{ #category : #drawing }
GdsStructureViewMorph >> drawLocalIgnoreItemOn: aLocalCanvas elements: aElements drawBlock: aDrawBlock [
	|  sElements pElements consumed|
	self fastDrawing 
		ifTrue: [ "skip layer orderd drawing"
			^ aElements asArray do: [:e |	aDrawBlock value: aLocalCanvas value: e] ].
	sElements := OrderedCollection new.
	pElements := OrderedCollection new.
	aElements do: [:each |
		each hasLayer 
			ifTrue: [pElements add: each] 
			ifFalse: [sElements add: each]].
		
	sElements asArray do: [:e |		
			aDrawBlock value: aLocalCanvas value: e].
	
	consumed := Set new.	
	pElements := pElements asArray. 
	self structure layers numbers do: [:each| 
		pElements asArray do: [:e |
			((consumed includes: e keyNumber) not and: [ e layerNumber = each])
				ifTrue: [
					aDrawBlock value: aLocalCanvas value: e.
					consumed add: e keyNumber]]]
]

{ #category : #drawing }
GdsStructureViewMorph >> drawOffOn: aCanvas [
	model ifNil: [^self].
	offCanvas
		ifNil: [
			offCanvas := 
				FormCanvas 
					extent: (self pixelBounds extent) 
					depth: (self defaultOffCanvasDepth ). 
			offCanvas fillColor: self backgroundColor.
			self drawLocalIgnoreItemOn: offCanvas].
	offCanvas 
		ifNotNil: [
			aCanvas drawImage: offCanvas form at: self pixelBounds origin.].
]

{ #category : #drawing }
GdsStructureViewMorph >> drawOn: aCanvas [
	self viewport ifNil: [^super drawOn: aCanvas].
	self drawInlineOn: aCanvas.
]

{ #category : #'drawing-world' }
GdsStructureViewMorph >> drawOn: aCanvas centerCircleAt: aWorldPoint [
	self drawOn: aCanvas centerCircleAt: aWorldPoint  pixelUnit: 5.
]

{ #category : #'drawing-world' }
GdsStructureViewMorph >> drawOn: aCanvas centerCircleAt: aWorldPoint pixelUnit: unit [ 
	self drawOn: aCanvas centerCircleAt: aWorldPoint  pixelUnit: unit width: 1.
]

{ #category : #'drawing-world' }
GdsStructureViewMorph >> drawOn: aCanvas centerCircleAt: aWorldPoint pixelUnit: unit width: width [
	| np1 box|
	np1 := self viewport xy2hv: aWorldPoint.
	box := Rectangle center: np1 extent: (unit * 2)@(unit * 2).
	aCanvas frameOval: box width: width color: self penColor.
]

{ #category : #'drawing-world' }
GdsStructureViewMorph >> drawOn: aCanvas centerCrossAt: aWorldPoint pixelUnit: unit width: width [
	| np1 |
	np1 := self viewport xy2hv: aWorldPoint.
	aCanvas line: (np1 + (unit negated @0 )) to: (np1 + (unit@0))  width: width  color: self penColor.
	aCanvas line: (np1 + (0 @ unit negated)) to: (np1 + (0 @ unit))  width: width  color: self penColor.	
	
]

{ #category : #drawing }
GdsStructureViewMorph >> drawOn: aCanvas element: aGdsElement [ 
	self drawOn: aCanvas element: aGdsElement  color: (self colorForElement: aGdsElement)
]

{ #category : #drawing }
GdsStructureViewMorph >> drawOn: aCanvas element: aGdsElement  color: aColor [
	| drawer |
	self
		penColor: aColor
		during: [
			drawer := GdsElementDrawer 
				fromElement: aGdsElement
				morph: self.
			drawer fullDrawOn: aCanvas]
]

{ #category : #'drawing-world' }
GdsStructureViewMorph >> drawOn: aLocalCanvas elements: elements drawingSelector: aDrawSel [
	elements ifNil: [^self].
	elements ifEmpty: [^self].
	elements do: [:el | 	
		| drawer |
		drawer := GdsElementDrawer fromElement: el morph: self. 
		drawer perform: aDrawSel with: aLocalCanvas].
	
]

{ #category : #'drawing-world' }
GdsStructureViewMorph >> drawOn: aCanvas fillPolyLineVertices: aPointArray [
	| hvPoins |	
	aPointArray isEmpty ifTrue: [^self].
	hvPoins := self viewport xy2hvPoints:  aPointArray.
	aCanvas drawPolygon: hvPoins color: self penColor borderWidth: 0 borderColor: nil.
	
]

{ #category : #'drawing-world' }
GdsStructureViewMorph >> drawOn: aCanvas fittingFillString: aObject at: aWorldPoint extent: aWorldExtent [
	self 
		drawOn: aCanvas 
		fittingString: aObject 
		at: aWorldPoint 
		extent: aWorldExtent 
		pointsBlock: [:ptArray |
			self drawOn: aCanvas fillPolyLineVertices: ptArray].
	
]

{ #category : #'drawing-world' }
GdsStructureViewMorph >> drawOn: aCanvas fittingString: aObject at: aWorldPoint extent: aWorldExtent pointsBlock: aBlock [
	| defaultFTDesc glyph translatedContours finalTransform scaleTransform locationTransform heightRatio widthRatio ttBounds string xStart colPoints np1 skipBlock |
	defaultFTDesc := FTBoxTextPrimitive defaultFont.
	defaultFTDesc ifNil: [ ^ self ].
	string := aObject asString.
	ttBounds := FTBoxTextPrimitive calcBoundsString: string fontDescription: defaultFTDesc.
	widthRatio := aWorldExtent x asFloat / ttBounds width asFloat.
	heightRatio := aWorldExtent y asFloat / ttBounds height asFloat.
	scaleTransform := MatrixTransform2x3 withScale: widthRatio @ heightRatio.
	locationTransform := MatrixTransform2x3 withOffset: aWorldPoint.
	finalTransform := MatrixTransform2x3 identity.
	finalTransform := finalTransform composedWithLocal: locationTransform.
	finalTransform := finalTransform composedWithLocal: scaleTransform.
	"finalTransform := finalTransform composedWithLocal: (MatrixTransform2x3 withAngle: 45)."
	xStart := 0.0.
	skipBlock := [ :ptArray | 
		Array
			streamContents: [ :s | 
				1 to: ptArray size by: 3 do: [ :i | 
					s nextPut: (ptArray at: i).
					s nextPut: (ptArray at: i + 2) ] ] ].
	string
		do: [ :ch | 
			glyph := defaultFTDesc face glyphOfCharacter: ch.
			translatedContours := glyph outline contoursCollection 
				collect: [ :assoc | assoc value , {(assoc value first)} ].
			translatedContours := translatedContours
				collect: [ :ptArray | 
					| points |
					"points := skipBlock value: ptArray."
					points := ptArray.
					self mustBeAllPoints: points.
					colPoints := OrderedCollection new.
					colPoints
						addAll:
							(points
								collect: [ :pt | 
									| newPt |
									newPt := pt x asFloat @ pt y asFloat.
									newPt := newPt + (xStart @ 0.0) - ttBounds origin.
									np1 := finalTransform localPointToGlobal: newPt ]).
					colPoints add: colPoints first copy.
					self mustBeAllPoints: colPoints.
					colPoints ].
			translatedContours
				do: [ :ptArray | 
					self mustBeAllPoints: ptArray.
					aBlock value: ptArray ].
			xStart := xStart + glyph advanceX asFloat ]
]

{ #category : #'drawing-world' }
GdsStructureViewMorph >> drawOn: aCanvas fittingStrokeString: aObject at: aWorldPoint extent: aWorldExtent [
	self 
		drawOn: aCanvas 
		fittingString: aObject 
		at: aWorldPoint 
		extent: aWorldExtent 
		pointsBlock: [:ptArray |
			self drawOn: aCanvas polyLineVertices: ptArray].
	
]

{ #category : #'drawing-world' }
GdsStructureViewMorph >> drawOn: aCanvas fittingStrokeString: aObject bounds: aWorldBounds [
	self 
		drawOn: aCanvas 
		fittingStrokeString: aObject 
		at: aWorldBounds origin 
		extent: aWorldBounds extent.
]

{ #category : #'drawing-world' }
GdsStructureViewMorph >> drawOn: aCanvas fittingStrokeStringOrig: aObject at: aWorldPoint extent: aWorldExtent [
	| origin extent string  morphicBounds ttbox|
	string := aObject asString.
	extent := (self viewport transform a11 * aWorldExtent) rounded.
	origin := (self viewport xy2hv: aWorldPoint) - (0@extent y).
	morphicBounds := origin extent: extent.
	"string isWideString 
		ifTrue: 
			[ ^ aCanvas drawString: string at: origin font: nil color: self penColor ]."	
	ttbox := FTBoxTextContext new.
	ttbox aaLevel: 2.
	ttbox fillColor: self penColor.
	ttbox borderWidth: 0.
	ttbox borderColor: self penColor.
	ttbox drawOn: aCanvas string: string bounds: morphicBounds.
	
]

{ #category : #'drawing-world' }
GdsStructureViewMorph >> drawOn: aCanvas fittingStrokeStringOrig: aObject bounds: aWorldBounds [
	self 
		drawOn: aCanvas 
		fittingStrokeStringOrig: aObject 
		at: aWorldBounds origin 
		extent: aWorldBounds extent.
]

{ #category : #'drawing-world' }
GdsStructureViewMorph >> drawOn: aCanvas lineFrom: aWorldPoint1 to: aWorldPoint2 [ 
	self drawOn: aCanvas lineFrom: aWorldPoint1 to: aWorldPoint2 width: 1.
	
]

{ #category : #'drawing-world' }
GdsStructureViewMorph >> drawOn: aCanvas lineFrom: aWorldPoint1 to: aWorldPoint2 width: width [
	| np1 np2 |
	np1 := self viewport xy2hv: aWorldPoint1.
	np2 := self viewport xy2hv: aWorldPoint2.
	aCanvas line: np1 to: np2 width: width color: self penColor.
	
]

{ #category : #'drawing-world' }
GdsStructureViewMorph >> drawOn: aCanvas lineSegment: aLineSegment [
	self drawOn: aCanvas lineSegment: aLineSegment width: 1
	
]

{ #category : #'drawing-world' }
GdsStructureViewMorph >> drawOn: aCanvas lineSegment: aLineSegment width: width [
	self drawOn: aCanvas lineFrom: aLineSegment start to: aLineSegment end width: width.
	
]

{ #category : #'drawing-world' }
GdsStructureViewMorph >> drawOn: aCanvas markDiamondPointAt: aWorldPoint [
	self drawOn: aCanvas markDiamondPointAt: aWorldPoint pixelUnit: 5.
	
]

{ #category : #'drawing-world' }
GdsStructureViewMorph >> drawOn: aCanvas markDiamondPointAt: aWorldPoint pixelUnit: unit [
	| points |
	points := self pixelPointsOfDiamondPointAt: aWorldPoint pixelUnit: unit.
	aCanvas drawPolygon: points color: nil borderWidth: 1 borderColor: self penColor
	
]

{ #category : #'drawing-world' }
GdsStructureViewMorph >> drawOn: aCanvas markPointAt: aWorldPoint [
	self drawOn: aCanvas  markPointAt: aWorldPoint  pixelUnit: 4.
	
	
]

{ #category : #'drawing-world' }
GdsStructureViewMorph >> drawOn: aCanvas markPointAt: aWorldPoint pixelUnit: unit [
	| center p1 p2 p3 p4|
	center := self viewport xy2hv: aWorldPoint.
	p1 := center + (unit negated@unit negated).
	p2 := center + (unit@unit).
	p3 := center + (unit@unit negated).
	p4 := center + (unit negated@unit).
	aCanvas line: p1 to: p2 width: 1 color: self penColor.
	aCanvas line: p3 to: p4 width: 1 color: self penColor.
	
]

{ #category : #'drawing-world' }
GdsStructureViewMorph >> drawOn: aCanvas pointAt: aWorldPoint [
	| np1 |
	np1 := self viewport xy2hv: aWorldPoint.
	aCanvas line: np1 to: np1 width: 1 color: self penColor.
	
]

{ #category : #'drawing-world' }
GdsStructureViewMorph >> drawOn: aCanvas polyLineVertices: aPointArray [
	self drawOn: aCanvas polyLineVertices: aPointArray width: 1.
	
	
]

{ #category : #'drawing-world' }
GdsStructureViewMorph >> drawOn: aCanvas polyLineVertices: aPointArray width: aWidth [
	| p1 p2 |
	aPointArray ifEmpty: [^self].
	1 to: aPointArray size - 1 do: [:index |
		p1 := aPointArray at: index.
		p2 := aPointArray at: index + 1.
		self drawOn: aCanvas lineFrom: p1 to: p2 width: aWidth .].
	
	
]

{ #category : #'drawing-world' }
GdsStructureViewMorph >> drawOn: aCanvas strokeBounds: aBounds [
	self drawOn:  aCanvas polyLineVertices: (GeometryUtils verticesFromBounds: aBounds).		

]

{ #category : #'drawing-world' }
GdsStructureViewMorph >> drawOn: aCanvas text: aObject at: aWorldPoint [
	| center |
	center := self viewport xy2hv: aWorldPoint.
	aCanvas drawString: aObject asString at: center font: nil color: self penColor
	
]

{ #category : #geometry }
GdsStructureViewMorph >> extent: aPoint [
	super extent: aPoint.
	self removeCachedCanvas.
	self viewport 
		ifNotNil: [
			self viewport extent: aPoint.
			self autoFitOnResize 
				ifTrue: [ 
					self viewport viewFit ] ].

]

{ #category : #initialization }
GdsStructureViewMorph >> fastDrawing [
	^ fastDrawing
	
]

{ #category : #updating }
GdsStructureViewMorph >> findNearestElementByPoint: aPoint [
	^self structure findNearestElementByPoint: aPoint elements: self visibleElements. 
]

{ #category : #initialization }
GdsStructureViewMorph >> fireFirstdrawing [
	fastDrawing := true.
	processFirstDrawing ifNotNil: [ processFirstDrawing terminate ].	
	processFirstDrawing := [
		self normalDrawing ] 
			valueAfterWaiting: (Delay forMilliseconds: 500).
	
]

{ #category : #testing }
GdsStructureViewMorph >> handleEventsBySelf [
	^ handleEventsBySelf ifNil: [ handleEventsBySelf := true ]
]

{ #category : #testing }
GdsStructureViewMorph >> handleEventsBySelf: aBoolean [
	handleEventsBySelf := aBoolean
]

{ #category : #'event handling' }
GdsStructureViewMorph >> handlesKeyboard: anEvent [
	self viewport ifNil: [^false].
	^ self handleEventsBySelf.
]

{ #category : #'event handling' }
GdsStructureViewMorph >> handlesMouseDown: anEvent [
	self viewport ifNil: [ ^ false ].
	^ self handleEventsBySelf and: [ self pixelBounds containsPoint: anEvent cursorPoint ]
]

{ #category : #'event handling' }
GdsStructureViewMorph >> handlesMouseOver: anEvent [
	self viewport ifNil: [^false].
	^ self handleEventsBySelf.
]

{ #category : #'event handling' }
GdsStructureViewMorph >> handlesMouseWheel: event [
	^ self handleEventsBySelf.
]

{ #category : #'state tracking' }
GdsStructureViewMorph >> inState: stateName [


	^ (state at: stateName ifAbsent: nil) notNil
]

{ #category : #'state tracking' }
GdsStructureViewMorph >> inState: stateName do: aBlock [


	^ (state at: stateName ifAbsent: nil) ifNotNil: aBlock 
]

{ #category : #initialization }
GdsStructureViewMorph >> initialize [
	super initialize.
	self clipSubmorphs: true.
	self color: Color black.
	fastDrawing := false.
	state := Dictionary new.

]

{ #category : #initialization }
GdsStructureViewMorph >> initializeLayers [

]

{ #category : #viewport }
GdsStructureViewMorph >> insideViewLevels [
	viewRange ifNil: [^true].
	^self viewRange includes: self portStack size - 1.
	
]

{ #category : #initialization }
GdsStructureViewMorph >> inspectFastdrawing: anAnnouncement [
	| current diff |
	current := Time microsecondClockValue.
	lastResizeAtTime ifNil: [ lastResizeAtTime := Time microsecondClockValue. ].
	diff := current - lastResizeAtTime.
	diff traceCr.
	self fireFirstdrawing.
	lastResizeAtTime := current.
	
]

{ #category : #'damage control' }
GdsStructureViewMorph >> invalidBounds: aRectangle [
	false
		ifTrue: [ ^self invalidRect: (self bounds) ].
	self invalidRect: (self updateBoundsFromWorldRectangle: aRectangle).
]

{ #category : #'damage control' }
GdsStructureViewMorph >> invalidBoundsForSegment: aLineSegment [
	self invalidBoundsFromPoint1:  aLineSegment start point2: aLineSegment end. 

]

{ #category : #'damage control' }
GdsStructureViewMorph >> invalidBoundsFromPoint1: aPoint1 point2: aPoint2 [
	false ifTrue: [ ^self invalidRect: self bounds ].
	self invalidRect: (self updateBoundsFromPoint1: aPoint1 point2: aPoint2 )

]

{ #category : #'damage control' }
GdsStructureViewMorph >> invalidMarkDiamondAt: aWorldPoint [
	| aRectangle |
	aRectangle := GeometryUtils 
		lookupDataBounds: (
			self pixelPointsOfDiamondPointAt:  aWorldPoint pixelUnit: 10).
	self invalidRect: aRectangle.
]

{ #category : #updating }
GdsStructureViewMorph >> isElementCollection: anObject [
	^((anObject isKindOf: Collection) and: [anObject notEmpty and: [anObject first isKindOf: GdsElement]])

]

{ #category : #'tests-as yet unclassified' }
GdsStructureViewMorph >> isNavigarionClick: aMouseButtonEvent [ 
	^ aMouseButtonEvent yellowButtonPressed 
]

{ #category : #updating }
GdsStructureViewMorph >> itemAttributeChanged: anAnnouncer [
	anAnnouncer traceCr.
]

{ #category : #initialization }
GdsStructureViewMorph >> model: aGdsStructure [
	| oldModel |
	self structureWillChange.
	oldModel := super model.
	super model: aGdsStructure.
	aGdsStructure
		ifNil: [ oldModel
				ifNotNil: [ :om | 
					self crLog: 'unsubscribe'.
					self unbindCurrentItemFor: om ].
			self structureDidUnbind ]
		ifNotNil: [ self bindCurrentItemFor: aGdsStructure.
			self structureDidBind ].
	self structureDidChanged.
	self changed
]

{ #category : #'event handling 2' }
GdsStructureViewMorph >> mouseDown2: evt [

	| pos |
	
	pos := evt cursorPoint.
	
	"left button"
	evt redButtonPressed ifTrue: [ 
		self setState: #panning value: { self viewport transform x@ self viewport transform y. pos }
		 ].
]

{ #category : #'event handling' }
GdsStructureViewMorph >> mouseDown: anEvent [
	self handleEventsBySelf
		ifFalse: [ ^ super mouseDown: anEvent ].
	(self isNavigarionClick: anEvent)
		ifTrue: [ 
			| track |
			track := GdsTracking new event: anEvent copy.
			self setProperty: #gdsTracking toValue: track ]
]

{ #category : #'event handling 2' }
GdsStructureViewMorph >> mouseEnter2: evt [

	self setState: #mouseIn
]

{ #category : #'event handling' }
GdsStructureViewMorph >> mouseEnter: anEvent [
	self handleEventsBySelf 
		ifFalse: [ ^ super mouseEnter: anEvent ].
	anEvent hand newKeyboardFocus: self.
]

{ #category : #'event handling 2' }
GdsStructureViewMorph >> mouseLeave2: evt [
	self 
		resetState: #mouseIn;
		resetState: #panning.
]

{ #category : #'event handling' }
GdsStructureViewMorph >> mouseLeave: anEvent [
	self handleEventsBySelf 
		ifFalse: [ ^ super mouseLeave: anEvent ].
	anEvent hand newKeyboardFocus: nil.	
]

{ #category : #'event handling 2' }
GdsStructureViewMorph >> mouseMove2: evt [

	self inState: #panning do: [ :startPanAndPos |
		| delta |
		delta := startPanAndPos first + ( evt cursorPoint - startPanAndPos second ).
		
		"transform 
			x: delta x;
			y: delta y."
		self changed.
	] 
]

{ #category : #'event handling' }
GdsStructureViewMorph >> mouseMove: anEvent [
	self handleEventsBySelf
		ifFalse: [ ^ super mouseMove: anEvent ].
	self trackingObject
		ifNotNil: [ :track | 
			track currentEvent: anEvent copy.
			track viewMove ]
]

{ #category : #'event handling 2' }
GdsStructureViewMorph >> mouseUp2: evt [

	"self halt."
	
	self resetState: #panning
]

{ #category : #'event handling' }
GdsStructureViewMorph >> mouseUp: anEvent [
	self handleEventsBySelf
		ifFalse: [ ^ super mouseUp: anEvent ].
	self trackingObject
		ifNotNil: [ :track | 
			"'trackEnd' traceCr."
			"self viewport viewCenter: (self viewport viewCenter - (track currentWorldPoint - track startWorldPoint)) ."
			track trackEnd.
			self removeProperty: #gdsTracking ]
]

{ #category : #'event handling 2' }
GdsStructureViewMorph >> mouseWheel2: event [


	"Handle a mouseWheel event."
	
	| center zoom  |
	
	center := "transform inverseTransform: (event cursorPoint - bounds origin)."

	zoom := 1.
	
	event isUp ifTrue: [ zoom := 1.25 ].
	event isDown ifTrue: [ zoom := 1/1.25 ].
	
	
	(self inState: #zooming) ifTrue: [   
		self updateZoom: zoom cursor: event cursorPoint.
	] ifFalse: [
		self startZooming: zoom center: center.
	]  
]

{ #category : #'event handling' }
GdsStructureViewMorph >> mouseWheel: event [
	| center dir localPoint |
	self handleEventsBySelf 
		ifFalse: [ ^  super mouseWheel: event ].
	 self viewport ifNil: [ ^ self ].	
	localPoint := event cursorPoint - self innerBounds origin.
	center := self viewport worldPointFromLocal: localPoint.
	dir := 1.	
	(KFEventSupport isWheelUpEvent: event) ifTrue: [ dir := 1.0 ].
	(KFEventSupport isWheelDownEvent: event) ifTrue: [ dir := -1.0 ].
	self viewport lockUpdateDuring: [
		self viewport portCenter: localPoint.
		self viewport viewCenter: center.
		self viewport zoom: (1.0 + (0.125 * dir)).].
	self fireFirstdrawing.
	
]

{ #category : #private }
GdsStructureViewMorph >> mustBeAllPoints: aPointCollection [
	"Why large positive integer included."
	(aPointCollection allSatisfy: [:each | each isMemberOf: Point ])
		ifFalse: [ 
			thisContext crTrace. 
			^aPointCollection select: [:each | each isMemberOf: Point ]].
	^aPointCollection.
]

{ #category : #initialization }
GdsStructureViewMorph >> normalDrawing [
	fastDrawing := false.
	self removeCachedCanvas.
	self changed
]

{ #category : #viewport }
GdsStructureViewMorph >> peekViewport [
	^self portStack last. 

]

{ #category : #drawing }
GdsStructureViewMorph >> penColor [
	"penColor ifNil: [penColor := self visiblePenColor]."
	^penColor.
	
]

{ #category : #drawing }
GdsStructureViewMorph >> penColor: aColor [
	penColor := aColor.
]

{ #category : #drawing }
GdsStructureViewMorph >> penColor: aColor during: aBlock [
	| savedColor |
	savedColor := self penColor.
	self penColor: aColor.	
	aBlock value.
	self penColor: savedColor.
]

{ #category : #private }
GdsStructureViewMorph >> pixelBounds [
	^self innerBounds
]

{ #category : #'drawing-world' }
GdsStructureViewMorph >> pixelPointsOfDiamondPointAt: aWorldPoint pixelUnit: unit [
	| center p1 p2 p3 p4 points |
	center := self viewport xy2hv: aWorldPoint.
	p1 := center + (0@unit).
	p2 := center + (unit@0).
	p3 := center + (0@unit negated).
	p4 := center + (unit negated@0).
	points := { p1 . p2 . p3  . p4  }.
	^points	
]

{ #category : #viewport }
GdsStructureViewMorph >> popViewport [
	| result |
	result := self portStack last. 
	 portStack := portStack allButLast.
	^result.
]

{ #category : #viewport }
GdsStructureViewMorph >> portStack [
	portStack ifNil: [portStack := OrderedCollection new.].
	^portStack
]

{ #category : #viewport }
GdsStructureViewMorph >> pushViewport: aGdsViewport [
	self assert: aGdsViewport isNil not.
	self portStack add: aGdsViewport.
	"Transcript cr; show: aGdsViewport compositMatrix."
	
]

{ #category : #drawing }
GdsStructureViewMorph >> redraw [
	self removeOffCanvas.
	self changed
	
]

{ #category : #drawing }
GdsStructureViewMorph >> redrawElements [
	colClipBounds ifNil: [^self visibleElements].
	colClipBounds ifEmpty: [^self visibleElements].
	^self clipedElements:  self viewport worldViewBounds.
	
	
]

{ #category : #private }
GdsStructureViewMorph >> referenceEnabledStructureNames [
	^ self model referenceEnabledStructureNames
]

{ #category : #initialization }
GdsStructureViewMorph >> release [
	"self halt."

	self submorphsDo: [ :each | each release ].
	self removeAllMorphs.
	offCanvas := nil.
	viewport := nil.
	colClipBounds := nil.
	GdsFeel dependentEnabled
		ifTrue: [ 
			self dependents
				do: [ :each | 
					self removeDependent: each.
					each release ] ].
	super release
]

{ #category : #initialization }
GdsStructureViewMorph >> releaseViewports [
	viewport := nil.
]

{ #category : #private }
GdsStructureViewMorph >> removeCachedCanvas [
	self removeOffCanvas.

]

{ #category : #private }
GdsStructureViewMorph >> removeOffCanvas [
	offCanvas := nil.

]

{ #category : #'state tracking' }
GdsStructureViewMorph >> resetState: stateName [

	state at: stateName put: nil.

	"receiver's state changed"
	
	self changed.
]

{ #category : #'state tracking' }
GdsStructureViewMorph >> setState: stateName [

	state at: stateName put: true.

	"receiver's state changed"
	
	self changed.
]

{ #category : #'state tracking' }
GdsStructureViewMorph >> setState: stateName value: aValue [

	state at: stateName put: aValue.

	"receiver's state changed"
	
	self changed.
]

{ #category : #'zoom animation' }
GdsStructureViewMorph >> startZooming: zoom center: center [
	| start end |

		
	start := Time millisecondClockValue.
	end := start + 250.

	self setState: #zooming value: {  center. self viewport transform copy. zoom. start. end}.

	self startStepping
]

{ #category : #'zoom animation' }
GdsStructureViewMorph >> stepViewing [

	self inState: #zooming do: [ :zoomState |
		| now start end center targetZoom factor |
		now := Time millisecondClockValue.
		start := zoomState at: 4.
		end := zoomState at: 5.
		
		(now between: start and:end) ifFalse: [ now := end.
			self resetState: #zooming.
			self stopStepping ].
		
		"FIXME: "
		"transform := (zoomState at: 2) copy."
		center := zoomState at: 1.
		
		factor :=  (now-start)/(end - start ).
		targetZoom := zoomState at: 3.
		targetZoom := 1* (1-factor) + (targetZoom * factor).
		"FIXME: "
		"transform
			translateBy: center;
			scaleBy:targetZoom;
			translateBy: center negated."
		
	].
	self changed.

]

{ #category : #drawing }
GdsStructureViewMorph >> strokeOn: aCanvas element: aGdsElement [
	self strokeOn:  aCanvas element: aGdsElement color: nil
]

{ #category : #drawing }
GdsStructureViewMorph >> strokeOn: aCanvas element: aGdsElement  color: aColor [
	| drawer |
	self
		penColor: (aColor ifNil: [(self colorForElement: aGdsElement)] ifNotNil: [aColor])
		during: [
			drawer := GdsElementDrawer 
				fromElement: aGdsElement
				morph: self.
				drawer strokeOutlineOn: aCanvas]
]

{ #category : #accessing }
GdsStructureViewMorph >> structure [
	^self model.
]

{ #category : #accessing }
GdsStructureViewMorph >> structure: aGdsStructure [
	self model: aGdsStructure
]

{ #category : #initialization }
GdsStructureViewMorph >> structureDidBind [
	viewport := self createViewport.
	GdsFeel dependentEnabled
		ifTrue: [			
			self model layers addDependent: self].
	self portStack add: viewport.

]

{ #category : #initialization }
GdsStructureViewMorph >> structureDidChanged [
	self removeOffCanvas.
	self changed.
]

{ #category : #initialization }
GdsStructureViewMorph >> structureDidUnbind [
	self releaseViewports.

]

{ #category : #initialization }
GdsStructureViewMorph >> structureWillChange [
	self model
		ifNotNil: [ 
			GdsFeel dependentEnabled
				ifTrue: [ self model layers removeDependent: self ] ]
]

{ #category : #'event handling' }
GdsStructureViewMorph >> trackingObject [
	^ (self valueOfProperty: #gdsTracking ifAbsent: [])

]

{ #category : #initialization }
GdsStructureViewMorph >> unbindCurrentItemFor: aGdsStructure [
	aGdsStructure currentItem
		ifNotNil: [ :item | item announcer unsubscribe: self ]
]

{ #category : #updating }
GdsStructureViewMorph >> update: anObject [
	(anObject == #newLayer)
		ifTrue: [self changed: #newLayer].
	(anObject == self viewport)
		ifTrue: [
			self removeCachedCanvas.
			^self changed].
	(self isElementCollection: anObject)
		ifTrue: [
			colClipBounds ifNil: [colClipBounds := OrderedCollection new.].
			anObject do: [:each | 
				self invalidBounds: each findBounds.
				colClipBounds add: each findBounds].
			self removeOffCanvas.
			self changed].		
	^super update: anObject.
]

{ #category : #'damage control' }
GdsStructureViewMorph >> updateBoundsFromPoint1: aPoint1 point2: aPoint2 [
	| upBounds p1 p2 left top right bottom |
	p1 := self viewport xy2hv: aPoint1.
	p2 := self viewport xy2hv: aPoint2.
	left := p1 x min: p2 x.
	top := p1 y min: p2 y.
	right := p1 x max: p2 x.
	bottom := p1 y max: p2 y.
	upBounds := Rectangle left: left right: right top: top bottom: bottom.	
	upBounds := upBounds expandBy: 20.
	upBounds := upBounds translateBy: self pixelBounds origin.
	^upBounds
]

{ #category : #'damage control' }
GdsStructureViewMorph >> updateBoundsFromWorldRectangle: aRectangle [
	^self updateBoundsFromPoint1: aRectangle origin point2: aRectangle corner.
]

{ #category : #'zoom animation' }
GdsStructureViewMorph >> updateZoom: zoom cursor: cursorPoint [

	| zoomState targetZoom start end now fraction newCenter |
	zoomState := state at:#zooming.
		
	"change the target zoom and increase time a bit"
	targetZoom := zoomState at: 3.
	
	start := zoomState at: 4.
	end := zoomState at: 5.
		
	now := Time millisecondClockValue.
	
	(now > end) ifTrue: [  now := end ].
	
	 "interpolate linearly the target zoom factor over time start ... end"
	fraction := (now - start) / (end - start).
	
	"zoom goes from 1..target zoom"
	targetZoom := 1*(1-fraction) + (targetZoom * fraction).

	self step. "to update transform"
	zoomState at: 3 put: targetZoom * zoom.
	newCenter :=   self viewport transform inverseTransform: (cursorPoint - bounds origin).
	zoomState at: 1 put: newCenter.
	zoomState at: 2 put: self viewport transform copy.
	zoomState at: 4 put: now.
	zoomState at: 5 put: now + 250 .

]

{ #category : #'viewing navigation' }
GdsStructureViewMorph >> viewFit [
	self viewport ifNil: [^self].
	self viewport viewFit
]

{ #category : #'viewing navigation' }
GdsStructureViewMorph >> viewMoveDown [
	self viewport ifNil: [^self].
	self viewport viewMove: (0.0@self viewMoveRatio negated).

]

{ #category : #'viewing navigation' }
GdsStructureViewMorph >> viewMoveLeft [
	self viewport ifNil: [^self].
	self viewport viewMove: (self viewMoveRatio negated@0.0).

]

{ #category : #'viewing navigation' }
GdsStructureViewMorph >> viewMoveRatio [
	^0.2

]

{ #category : #'viewing navigation' }
GdsStructureViewMorph >> viewMoveRight [
	self viewport ifNil: [^self].
	self viewport viewMove: (self viewMoveRatio@0.0).

]

{ #category : #'viewing navigation' }
GdsStructureViewMorph >> viewMoveUp [
	self viewport ifNil: [^self].
	self viewport viewMove: (0.0@self viewMoveRatio).

]

{ #category : #viewport }
GdsStructureViewMorph >> viewRange [
	^viewRange
	
]

{ #category : #viewport }
GdsStructureViewMorph >> viewRangeFrom: minValue to: maxValue [
	viewRange := Interval from: minValue to: maxValue.
	self changed: #viewRange
]

{ #category : #'viewing navigation' }
GdsStructureViewMorph >> viewZoomDouble [
	self viewport ifNil: [^self].
	self viewport zoom: 2.0
]

{ #category : #'viewing navigation' }
GdsStructureViewMorph >> viewZoomHalf [
	self viewport ifNil: [^self].
	self viewport zoom: 0.5
]

{ #category : #viewport }
GdsStructureViewMorph >> viewport [
	^ viewport 
	
]

{ #category : #utility }
GdsStructureViewMorph >> worldPointOfEvent: event [
	| localPoint worldPoint |	
	localPoint := event cursorPoint - self innerBounds origin.
	worldPoint := self viewport worldPointFromLocal: localPoint.
	^ worldPoint
]
