Class {
	#name : #GdaStructureViewMorph,
	#superclass : #PluggableLayersMorph,
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
	#category : #'GdsFeel-UI2-Morph'
}

{ #category : #accessing }
GdaStructureViewMorph >> autoFitOnResize [

	^ autoFitOnResize ifNil: [ autoFitOnResize := false ]
]

{ #category : #accessing }
GdaStructureViewMorph >> autoFitOnResize: aBoolean [

	autoFitOnResize := aBoolean
]

{ #category : #accessing }
GdaStructureViewMorph >> backgroundColor [

	^ Color black
]

{ #category : #accessing }
GdaStructureViewMorph >> backgroundColor: aColor [

	self color: aColor
]

{ #category : #drawing }
GdaStructureViewMorph >> clipedElements [

	"^ self structure elements"

	^ self clipedElements: self viewport worldViewBounds
]

{ #category : #drawing }
GdaStructureViewMorph >> clipedElements: viewBounds [

	^ model liveElements select: [ :each | 
		  each findBounds intersects: viewBounds ]
]

{ #category : #accessing }
GdaStructureViewMorph >> color: aColor [

	super color: aColor.
	self removeCachedCanvas.
	self invalidRect: self bounds
]

{ #category : #'traits - extracted' }
GdaStructureViewMorph >> colorForElement: aGdsElement [

	| fixPureWhite |
	fixPureWhite := [ :c | 
	                color = Color white
		                ifTrue: [ self visiblePenColor ]
		                ifFalse: [ c ] ].
	aGdsElement state = #inStructure ifTrue: [ 
		aGdsElement ownColor ifNotNil: [ :ownColor | 
			^ fixPureWhite value: ownColor ].
		aGdsElement hasLayer ifTrue: [ 
			^ self colorForLayer: aGdsElement layerNumber ] ].
	^ self visiblePenColor
]

{ #category : #'traits - extracted' }
GdaStructureViewMorph >> colorForLayer: aLayerNumber [

	| usingColor |
	usingColor := (self structure layers atNumber: aLayerNumber) color.
	usingColor = Color white ifTrue: [ ^ self visiblePenColor ].
	usingColor = #white ifTrue: [ ^ self visiblePenColor ].
	^ usingColor
]

{ #category : #accessing }
GdaStructureViewMorph >> contextMenu [

	^ contextMenu
]

{ #category : #accessing }
GdaStructureViewMorph >> contextMenu: aGdsTrackingValueBlock [

	"EXAMPLE:
		self contextMenu: [ :tracking | tracking event cursorPoint. ... ]"

	contextMenu := aGdsTrackingValueBlock
]

{ #category : #viewport }
GdaStructureViewMorph >> createViewport [

	| vp |
	vp := GdaViewport new.
	vp model: self model.
	vp pixelBoundsSelector: #innerBounds.
	vp pixelBoundsTarget: self.
	vp addDependent: self.
	^ vp
]

{ #category : #defaults }
GdaStructureViewMorph >> defaultOffCanvasDepth [

	^ 32
]

{ #category : #drawing }
GdaStructureViewMorph >> drawInlineOn: aCanvas [

	super drawOn: aCanvas.
	self drawOffOn: aCanvas
]

{ #category : #drawing }
GdaStructureViewMorph >> drawLocalIgnoreItemOn: aLocalCanvas [

	self
		drawLocalIgnoreItemOn: aLocalCanvas
		elements: self visibleElements
]

{ #category : #drawing }
GdaStructureViewMorph >> drawLocalIgnoreItemOn: aLocalCanvas elements: aElements [

	self
		drawLocalIgnoreItemOn: aLocalCanvas
		elements: aElements
		drawBlock: [ :canvas :element | 
		self drawOn: canvas element: element ]
]

{ #category : #drawing }
GdaStructureViewMorph >> drawLocalIgnoreItemOn: aLocalCanvas elements: aElements drawBlock: aDrawBlock [

	| sElements pElements consumed |
	self fastDrawing ifTrue: [ "skip layer orderd drawing"
		^ aElements asArray do: [ :e | 
			  aDrawBlock value: aLocalCanvas value: e ] ].
	sElements := OrderedCollection new.
	pElements := OrderedCollection new.
	aElements do: [ :each | 
		each hasLayer
			ifTrue: [ pElements add: each ]
			ifFalse: [ sElements add: each ] ].

	sElements asArray do: [ :e | aDrawBlock value: aLocalCanvas value: e ].

	consumed := Set new.
	pElements := pElements asArray.
	self structure layers numbers do: [ :each | 
		pElements asArray do: [ :e | 
			((consumed includes: e keyNumber) not and: [ e layerNumber = each ]) 
				ifTrue: [ 
					aDrawBlock value: aLocalCanvas value: e.
					consumed add: e keyNumber ] ] ]
]

{ #category : #drawing }
GdaStructureViewMorph >> drawOffOn: aCanvas [

	model ifNil: [ ^ self ].
	offCanvas ifNil: [ 
		offCanvas := FormCanvas
			             extent: self pixelBounds extent
			             depth: self defaultOffCanvasDepth.
		offCanvas fillColor: self backgroundColor.
		self drawLocalIgnoreItemOn: offCanvas ].
	offCanvas ifNotNil: [ 
		aCanvas drawImage: offCanvas form at: self pixelBounds origin ]
]

{ #category : #drawing }
GdaStructureViewMorph >> drawOn: aCanvas [

	self viewport ifNil: [ ^ super drawOn: aCanvas ].
	self drawInlineOn: aCanvas
]

{ #category : #'drawing-world' }
GdaStructureViewMorph >> drawOn: aCanvas centerCircleAt: aWorldPoint [

	self drawOn: aCanvas centerCircleAt: aWorldPoint pixelUnit: 5
]

{ #category : #'drawing-world' }
GdaStructureViewMorph >> drawOn: aCanvas centerCircleAt: aWorldPoint pixelUnit: unit [

	self
		drawOn: aCanvas
		centerCircleAt: aWorldPoint
		pixelUnit: unit
		width: 1
]

{ #category : #'drawing-world' }
GdaStructureViewMorph >> drawOn: aCanvas centerCircleAt: aWorldPoint pixelUnit: unit width: width [

	| np1 box |
	np1 := self viewport xy2hv: aWorldPoint.
	box := Rectangle center: np1 extent: unit * 2 @ (unit * 2).
	aCanvas frameOval: box width: width color: self penColor
]

{ #category : #'drawing-world' }
GdaStructureViewMorph >> drawOn: aCanvas centerCrossAt: aWorldPoint pixelUnit: unit width: width [

	| np1 |
	np1 := self viewport xy2hv: aWorldPoint.
	aCanvas
		line: np1 + (unit negated @ 0)
		to: np1 + (unit @ 0)
		width: width
		color: self penColor.
	aCanvas
		line: np1 + (0 @ unit negated)
		to: np1 + (0 @ unit)
		width: width
		color: self penColor
]

{ #category : #drawing }
GdaStructureViewMorph >> drawOn: aCanvas element: aGdsElement [

	self
		drawOn: aCanvas
		element: aGdsElement
		color: (self colorForElement: aGdsElement)
]

{ #category : #drawing }
GdaStructureViewMorph >> drawOn: aCanvas element: aGdsElement color: aColor [

	| drawer |
	self penColor: aColor during: [ 
		drawer := GdsElementDrawer fromElement: aGdsElement morph: self.
		drawer fullDrawOn: aCanvas ]
]

{ #category : #'drawing-world' }
GdaStructureViewMorph >> drawOn: aLocalCanvas elements: elements drawingSelector: aDrawSel [

	elements ifNil: [ ^ self ].
	elements ifEmpty: [ ^ self ].
	elements do: [ :el | 
		| drawer |
		drawer := GdsElementDrawer fromElement: el morph: self.
		drawer perform: aDrawSel with: aLocalCanvas ]
]

{ #category : #'drawing-world' }
GdaStructureViewMorph >> drawOn: aCanvas fillPolyLineVertices: aPointArray [

	| hvPoins |
	aPointArray isEmpty ifTrue: [ ^ self ].
	hvPoins := self viewport xy2hvPoints: aPointArray.
	aCanvas
		drawPolygon: hvPoins
		color: self penColor
		borderWidth: 0
		borderColor: nil
]

{ #category : #'drawing-world' }
GdaStructureViewMorph >> drawOn: aCanvas fittingFillString: aObject at: aWorldPoint extent: aWorldExtent [

	self
		drawOn: aCanvas
		fittingString: aObject
		at: aWorldPoint
		extent: aWorldExtent
		pointsBlock: [ :ptArray | 
		self drawOn: aCanvas fillPolyLineVertices: ptArray ]
]

{ #category : #'drawing-world' }
GdaStructureViewMorph >> drawOn: aCanvas fittingString: aObject at: aWorldPoint extent: aWorldExtent pointsBlock: aBlock [

	| defaultFTDesc glyph translatedContours finalTransform scaleTransform locationTransform heightRatio widthRatio ttBounds string xStart colPoints np1 skipBlock |
	defaultFTDesc := FTBoxTextPrimitive defaultFont.
	defaultFTDesc ifNil: [ ^ self ].
	string := aObject asString.
	ttBounds := FTBoxTextPrimitive
		            calcBoundsString: string
		            fontDescription: defaultFTDesc.
	widthRatio := aWorldExtent x asFloat / ttBounds width asFloat.
	heightRatio := aWorldExtent y asFloat / ttBounds height asFloat.
	scaleTransform := self transformClass withScale:
		                  widthRatio @ heightRatio.
	locationTransform := self transformClass withOffset: aWorldPoint.
	finalTransform := self transformClass identity.
	finalTransform := finalTransform composedWithLocal: locationTransform.
	finalTransform := finalTransform composedWithLocal: scaleTransform.
	"finalTransform := finalTransform composedWithLocal: (MatrixTransform2x3 withAngle: 45)."
	xStart := 0.0.
	skipBlock := [ :ptArray | 
	             Array streamContents: [ :s | 
		             1 to: ptArray size by: 3 do: [ :i | 
			             s nextPut: (ptArray at: i).
			             s nextPut: (ptArray at: i + 2) ] ] ].
	string do: [ :ch | 
		glyph := defaultFTDesc face glyphOfCharacter: ch.
		translatedContours := glyph outline contoursCollection collect: [ 
			                      :assoc | assoc value , { assoc value first } ].
		translatedContours := translatedContours collect: [ :ptArray | 
			                      | points |
			                      "points := skipBlock value: ptArray."
			                      points := ptArray.
			                      self mustBeAllPoints: points.
			                      colPoints := OrderedCollection new.
			                      colPoints addAll: (points collect: [ :pt | 
					                       | newPt |
					                       newPt := pt x asFloat @ pt y asFloat.
					                       newPt := newPt + (xStart @ 0.0)
					                                - ttBounds origin.
					                       np1 := finalTransform localPointToGlobal:
						                              newPt ]).
			                      colPoints add: colPoints first copy.
			                      self mustBeAllPoints: colPoints.
			                      colPoints ].
		translatedContours do: [ :ptArray | 
			self mustBeAllPoints: ptArray.
			aBlock value: ptArray ].
		xStart := xStart + glyph advanceX asFloat ]
]

{ #category : #'drawing-world' }
GdaStructureViewMorph >> drawOn: aCanvas fittingStrokeString: aObject at: aWorldPoint extent: aWorldExtent [

	self
		drawOn: aCanvas
		fittingString: aObject
		at: aWorldPoint
		extent: aWorldExtent
		pointsBlock: [ :ptArray | 
		self drawOn: aCanvas polyLineVertices: ptArray ]
]

{ #category : #'drawing-world' }
GdaStructureViewMorph >> drawOn: aCanvas fittingStrokeString: aObject bounds: aWorldBounds [

	self
		drawOn: aCanvas
		fittingStrokeString: aObject
		at: aWorldBounds origin
		extent: aWorldBounds extent
]

{ #category : #'drawing-world' }
GdaStructureViewMorph >> drawOn: aCanvas fittingStrokeStringOrig: aObject at: aWorldPoint extent: aWorldExtent [

	| origin extent string morphicBounds ttbox |
	string := aObject asString.
	extent := (self viewport transform a11 * aWorldExtent) rounded.
	origin := (self viewport xy2hv: aWorldPoint) - (0 @ extent y).
	morphicBounds := origin extent: extent.
	"string isWideString 
		ifTrue: 
			[ ^ aCanvas drawString: string at: origin font: nil color: self penColor ]."
	ttbox := FTBoxTextContext new.
	ttbox aaLevel: 2.
	ttbox fillColor: self penColor.
	ttbox borderWidth: 0.
	ttbox borderColor: self penColor.
	ttbox drawOn: aCanvas string: string bounds: morphicBounds
]

{ #category : #'drawing-world' }
GdaStructureViewMorph >> drawOn: aCanvas fittingStrokeStringOrig: aObject bounds: aWorldBounds [

	self
		drawOn: aCanvas
		fittingStrokeStringOrig: aObject
		at: aWorldBounds origin
		extent: aWorldBounds extent
]

{ #category : #'drawing-world' }
GdaStructureViewMorph >> drawOn: aCanvas lineFrom: aWorldPoint1 to: aWorldPoint2 [

	self
		drawOn: aCanvas
		lineFrom: aWorldPoint1
		to: aWorldPoint2
		width: 1
]

{ #category : #'drawing-world' }
GdaStructureViewMorph >> drawOn: aCanvas lineFrom: aWorldPoint1 to: aWorldPoint2 width: width [

	| np1 np2 |
	np1 := self viewport xy2hv: aWorldPoint1.
	np2 := self viewport xy2hv: aWorldPoint2.
	aCanvas
		line: np1
		to: np2
		width: width
		color: self penColor
]

{ #category : #'drawing-world' }
GdaStructureViewMorph >> drawOn: aCanvas lineSegment: aLineSegment [

	self drawOn: aCanvas lineSegment: aLineSegment width: 1
]

{ #category : #'drawing-world' }
GdaStructureViewMorph >> drawOn: aCanvas lineSegment: aLineSegment width: width [

	self
		drawOn: aCanvas
		lineFrom: aLineSegment start
		to: aLineSegment end
		width: width
]

{ #category : #'drawing-world' }
GdaStructureViewMorph >> drawOn: aCanvas markDiamondPointAt: aWorldPoint [

	self drawOn: aCanvas markDiamondPointAt: aWorldPoint pixelUnit: 5
]

{ #category : #'drawing-world' }
GdaStructureViewMorph >> drawOn: aCanvas markDiamondPointAt: aWorldPoint pixelUnit: unit [

	| points |
	points := self
		          pixelPointsOfDiamondPointAt: aWorldPoint
		          pixelUnit: unit.
	aCanvas
		drawPolygon: points
		color: nil
		borderWidth: 1
		borderColor: self penColor
]

{ #category : #'drawing-world' }
GdaStructureViewMorph >> drawOn: aCanvas markPointAt: aWorldPoint [

	self drawOn: aCanvas markPointAt: aWorldPoint pixelUnit: 4
]

{ #category : #'drawing-world' }
GdaStructureViewMorph >> drawOn: aCanvas markPointAt: aWorldPoint pixelUnit: unit [

	| center p1 p2 p3 p4 |
	center := self viewport xy2hv: aWorldPoint.
	p1 := center + (unit negated @ unit negated).
	p2 := center + (unit @ unit).
	p3 := center + (unit @ unit negated).
	p4 := center + (unit negated @ unit).
	aCanvas
		line: p1
		to: p2
		width: 1
		color: self penColor.
	aCanvas
		line: p3
		to: p4
		width: 1
		color: self penColor
]

{ #category : #'drawing-world' }
GdaStructureViewMorph >> drawOn: aCanvas pointAt: aWorldPoint [

	| np1 |
	np1 := self viewport xy2hv: aWorldPoint.
	aCanvas
		line: np1
		to: np1
		width: 1
		color: self penColor
]

{ #category : #'drawing-world' }
GdaStructureViewMorph >> drawOn: aCanvas polyLineVertices: aPointArray [

	self drawOn: aCanvas polyLineVertices: aPointArray width: 1
]

{ #category : #'drawing-world' }
GdaStructureViewMorph >> drawOn: aCanvas polyLineVertices: aPointArray width: aWidth [

	| p1 p2 |
	aPointArray ifEmpty: [ ^ self ].
	1 to: aPointArray size - 1 do: [ :index | 
		p1 := aPointArray at: index.
		p2 := aPointArray at: index + 1.
		self
			drawOn: aCanvas
			lineFrom: p1
			to: p2
			width: aWidth ]
]

{ #category : #'drawing-world' }
GdaStructureViewMorph >> drawOn: aCanvas strokeBounds: aBounds [

	self
		drawOn: aCanvas
		polyLineVertices: (GeometryUtils verticesFromBounds: aBounds)
]

{ #category : #'drawing-world' }
GdaStructureViewMorph >> drawOn: aCanvas text: aObject at: aWorldPoint [

	| center |
	center := self viewport xy2hv: aWorldPoint.
	aCanvas
		drawString: aObject asString
		at: center
		font: nil
		color: self penColor
]

{ #category : #geometry }
GdaStructureViewMorph >> extent: aPoint [

	super extent: aPoint.
	self removeCachedCanvas.
	self viewport ifNotNil: [ 
		self viewport extent: aPoint.
		self autoFitOnResize ifTrue: [ self viewport viewFit ] ]
]

{ #category : #initialization }
GdaStructureViewMorph >> fastDrawing [

	^ fastDrawing
]

{ #category : #updating }
GdaStructureViewMorph >> findNearestElementByPoint: aPoint [

	^ self structure
		  findNearestElementByPoint: aPoint
		  elements: self visibleElements
]

{ #category : #initialization }
GdaStructureViewMorph >> fireFirstdrawing [

	fastDrawing := true.
	processFirstDrawing ifNotNil: [ processFirstDrawing terminate ].
	processFirstDrawing := [ self normalDrawing ] valueAfterWaiting:
		                       (Delay forMilliseconds: 500)
]

{ #category : #testing }
GdaStructureViewMorph >> handleEventsBySelf [

	^ handleEventsBySelf ifNil: [ handleEventsBySelf := true ]
]

{ #category : #testing }
GdaStructureViewMorph >> handleEventsBySelf: aBoolean [

	handleEventsBySelf := aBoolean
]

{ #category : #'event handling' }
GdaStructureViewMorph >> handlesKeyboard: anEvent [

	self viewport ifNil: [ ^ false ].
	^ self handleEventsBySelf
]

{ #category : #'event handling' }
GdaStructureViewMorph >> handlesMouseDown: anEvent [

	self viewport ifNil: [ ^ false ].
	^ self handleEventsBySelf and: [ 
		  self pixelBounds containsPoint: anEvent cursorPoint ]
]

{ #category : #'event handling' }
GdaStructureViewMorph >> handlesMouseOver: anEvent [

	self viewport ifNil: [ ^ false ].
	^ self handleEventsBySelf
]

{ #category : #'events - processing' }
GdaStructureViewMorph >> handlesMouseWheel: event [

	^ self handleEventsBySelf
]

{ #category : #'state tracking' }
GdaStructureViewMorph >> inState: stateName [

	^ (state at: stateName ifAbsent: nil) notNil
]

{ #category : #'state tracking' }
GdaStructureViewMorph >> inState: stateName do: aBlock [

	^ (state at: stateName ifAbsent: nil) ifNotNil: aBlock
]

{ #category : #initialization }
GdaStructureViewMorph >> initialize [

	super initialize.
	self clipSubmorphs: true.
	self borderWidth: 0.
	self color: Color black.
	fastDrawing := false.
	state := Dictionary new
]

{ #category : #initialization }
GdaStructureViewMorph >> initializeLayers [

	
]

{ #category : #viewport }
GdaStructureViewMorph >> insideViewLevels [

	viewRange ifNil: [ ^ true ].
	^ self viewRange includes: self portStack size - 1
]

{ #category : #'damage control' }
GdaStructureViewMorph >> invalidBounds: aRectangle [

	false ifTrue: [ ^ self invalidRect: self bounds ].
	self invalidRect: (self updateBoundsFromWorldRectangle: aRectangle)
]

{ #category : #'damage control' }
GdaStructureViewMorph >> invalidBoundsForSegment: aLineSegment [

	self
		invalidBoundsFromPoint1: aLineSegment start
		point2: aLineSegment end
]

{ #category : #'damage control' }
GdaStructureViewMorph >> invalidBoundsFromPoint1: aPoint1 point2: aPoint2 [

	false ifTrue: [ ^ self invalidRect: self bounds ].
	self invalidRect:
		(self updateBoundsFromPoint1: aPoint1 point2: aPoint2)
]

{ #category : #'damage control' }
GdaStructureViewMorph >> invalidMarkDiamondAt: aWorldPoint [

	| aRectangle |
	aRectangle := GeometryUtils lookupDataBounds:
		              (self
			               pixelPointsOfDiamondPointAt: aWorldPoint
			               pixelUnit: 10).
	self invalidRect: aRectangle
]

{ #category : #updating }
GdaStructureViewMorph >> isElementCollection: anObject [

	^ (anObject isKindOf: Collection) and: [ 
		  anObject notEmpty and: [ anObject first isKindOf: GdaElement ] ]
]

{ #category : #'tests-as yet unclassified' }
GdaStructureViewMorph >> isNavigarionClick: aMouseButtonEvent [

	^ aMouseButtonEvent yellowButtonPressed
]

{ #category : #'event handling' }
GdaStructureViewMorph >> mouseDown: anEvent [

	| track |
	self handleEventsBySelf ifFalse: [ ^ super mouseDown: anEvent ].
	(self isNavigarionClick: anEvent) ifFalse: [ ^ self ].
	track := GdaTracking new event: anEvent copy.
	self setProperty: #gdsTracking toValue: track
]

{ #category : #'event handling' }
GdaStructureViewMorph >> mouseEnter: anEvent [

	self handleEventsBySelf ifFalse: [ ^ super mouseEnter: anEvent ].
	anEvent hand newKeyboardFocus: self
]

{ #category : #'event handling' }
GdaStructureViewMorph >> mouseLeave: anEvent [

	self handleEventsBySelf ifFalse: [ ^ super mouseLeave: anEvent ].
	anEvent hand newKeyboardFocus: nil
]

{ #category : #'event handling' }
GdaStructureViewMorph >> mouseMove: anEvent [

	self handleEventsBySelf ifFalse: [ ^ super mouseMove: anEvent ].
	self trackingObject ifNotNil: [ :track | 
		track currentEvent: anEvent copy.
		track viewMove ]
]

{ #category : #'event handling' }
GdaStructureViewMorph >> mouseUp: anEvent [

	self handleEventsBySelf ifFalse: [ ^ super mouseUp: anEvent ].
	self trackingObject ifNotNil: [ :track | "'trackEnd' traceCr.""self viewport viewCenter: (self viewport viewCenter - (track currentWorldPoint - track startWorldPoint)) ."
		track trackEnd.
		self removeProperty: #gdsTracking ]
]

{ #category : #'event handling' }
GdaStructureViewMorph >> mouseWheel: event [

	| center dir localPoint |
	self handleEventsBySelf ifFalse: [ ^ super mouseWheel: event ].
	self viewport ifNil: [ ^ self ].
	localPoint := event cursorPoint - self innerBounds origin.
	center := self viewport worldPointFromLocal: localPoint.
	dir := 1.
	(KFEventSupport isWheelUpEvent: event) ifTrue: [ dir := 1.0 ].
	(KFEventSupport isWheelDownEvent: event) ifTrue: [ dir := -1.0 ].
	self viewport lockUpdateDuring: [ 
		self viewport portCenter: localPoint.
		self viewport viewCenter: center.
		self viewport zoom: 1.0 + (0.125 * dir) ].
	self fireFirstdrawing
]

{ #category : #private }
GdaStructureViewMorph >> mustBeAllPoints: aPointCollection [

	"Why large positive integer included."

	(aPointCollection allSatisfy: [ :each | each isMemberOf: Point ]) 
		ifFalse: [ 
			thisContext crTrace.
			^ aPointCollection select: [ :each | each isMemberOf: Point ] ].
	^ aPointCollection
]

{ #category : #initialization }
GdaStructureViewMorph >> normalDrawing [

	fastDrawing := false.
	self removeCachedCanvas.
	self changed
]

{ #category : #viewport }
GdaStructureViewMorph >> peekViewport [

	^ self portStack last
]

{ #category : #drawing }
GdaStructureViewMorph >> penColor [

	"penColor ifNil: [penColor := self visiblePenColor]."

	^ penColor
]

{ #category : #drawing }
GdaStructureViewMorph >> penColor: aColor [

	penColor := aColor
]

{ #category : #drawing }
GdaStructureViewMorph >> penColor: aColor during: aBlock [

	| savedColor |
	savedColor := self penColor.
	self penColor: aColor.
	aBlock value.
	self penColor: savedColor
]

{ #category : #private }
GdaStructureViewMorph >> pixelBounds [

	^ self innerBounds
]

{ #category : #'drawing-world' }
GdaStructureViewMorph >> pixelPointsOfDiamondPointAt: aWorldPoint pixelUnit: unit [

	| center p1 p2 p3 p4 points |
	center := self viewport xy2hv: aWorldPoint.
	p1 := center + (0 @ unit).
	p2 := center + (unit @ 0).
	p3 := center + (0 @ unit negated).
	p4 := center + (unit negated @ 0).
	points := { 
		          p1.
		          p2.
		          p3.
		          p4 }.
	^ points
]

{ #category : #viewport }
GdaStructureViewMorph >> popViewport [

	| result |
	result := self portStack last.
	portStack := portStack allButLast.
	^ result
]

{ #category : #viewport }
GdaStructureViewMorph >> portStack [

	portStack ifNil: [ portStack := OrderedCollection new ].
	^ portStack
]

{ #category : #viewport }
GdaStructureViewMorph >> pushViewport: aGdsViewport [

	self assert: aGdsViewport isNil not.
	self portStack add: aGdsViewport
	"Transcript cr; show: aGdsViewport compositMatrix."
]

{ #category : #drawing }
GdaStructureViewMorph >> redraw [

	self removeOffCanvas.
	self changed
]

{ #category : #drawing }
GdaStructureViewMorph >> redrawElements [

	colClipBounds ifNil: [ ^ self visibleElements ].
	colClipBounds ifEmpty: [ ^ self visibleElements ].
	^ self clipedElements: self viewport worldViewBounds
]

{ #category : #private }
GdaStructureViewMorph >> referenceEnabledStructureNames [

	^ self model referenceEnabledStructureNames
]

{ #category : #initialization }
GdaStructureViewMorph >> release [

	"self halt."

	self submorphsDo: [ :each | each release ].
	self removeAllMorphs.
	offCanvas := nil.
	viewport := nil.
	colClipBounds := nil.

		self dependents do: [ :each | 
			self removeDependent: each.
			each release ].
	super release
]

{ #category : #initialization }
GdaStructureViewMorph >> releaseViewports [

	viewport := nil
]

{ #category : #private }
GdaStructureViewMorph >> removeCachedCanvas [

	self removeOffCanvas
]

{ #category : #private }
GdaStructureViewMorph >> removeOffCanvas [

	offCanvas := nil
]

{ #category : #'state tracking' }
GdaStructureViewMorph >> resetState: stateName [

	state at: stateName put: nil.

	"receiver's state changed"

	self changed
]

{ #category : #'state tracking' }
GdaStructureViewMorph >> setState: stateName [

	state at: stateName put: true.

	"receiver's state changed"

	self changed
]

{ #category : #'state tracking' }
GdaStructureViewMorph >> setState: stateName value: aValue [

	state at: stateName put: aValue.

	"receiver's state changed"

	self changed
]

{ #category : #'zoom animation' }
GdaStructureViewMorph >> startZooming: zoom center: center [

	| start end |
	start := Time millisecondClockValue.
	end := start + 250.

	self setState: #zooming value: { 
			center.
			self viewport transform copy.
			zoom.
			start.
			end }.

	self startStepping
]

{ #category : #'zoom animation' }
GdaStructureViewMorph >> stepViewing [

	self inState: #zooming do: [ :zoomState | 
		| now start end center targetZoom factor |
		now := Time millisecondClockValue.
		start := zoomState at: 4.
		end := zoomState at: 5.

		(now between: start and: end) ifFalse: [ 
			now := end.
			self resetState: #zooming.
			self stopStepping ].

		"FIXME: "
		"transform := (zoomState at: 2) copy."
		center := zoomState at: 1.

		factor := now - start / (end - start).
		targetZoom := zoomState at: 3.
		targetZoom := 1 * (1 - factor) + (targetZoom * factor)
		"FIXME: "
		"transform
			translateBy: center;
			scaleBy:targetZoom;
			translateBy: center negated." ].
	self changed
]

{ #category : #drawing }
GdaStructureViewMorph >> strokeOn: aCanvas element: aGdsElement [

	self strokeOn: aCanvas element: aGdsElement color: nil
]

{ #category : #drawing }
GdaStructureViewMorph >> strokeOn: aCanvas element: aGdsElement color: aColor [

	| drawer |
	self
		penColor: (aColor
				 ifNil: [ self colorForElement: aGdsElement ]
				 ifNotNil: [ aColor ])
		during: [ 
			drawer := GdsElementDrawer fromElement: aGdsElement morph: self.
			drawer strokeOutlineOn: aCanvas ]
]

{ #category : #accessing }
GdaStructureViewMorph >> structure [

	^ self model
]

{ #category : #accessing }
GdaStructureViewMorph >> structure: aGdsStructure [

	self model: aGdsStructure.
	aGdsStructure ifNil: [  ] ifNotNil: [ 
		viewport := self createViewport.
		viewport viewFit ]
]

{ #category : #'event handling' }
GdaStructureViewMorph >> trackingObject [

	^ self valueOfProperty: #gdsTracking ifAbsent: [  ]
]

{ #category : #updating }
GdaStructureViewMorph >> update: anObject [

	anObject == #newLayer ifTrue: [ self changed: #newLayer ].
	anObject == self viewport ifTrue: [ 
		self removeCachedCanvas.
		^ self changed ].
	(self isElementCollection: anObject) ifTrue: [ 
		colClipBounds ifNil: [ colClipBounds := OrderedCollection new ].
		anObject do: [ :each | 
			self invalidBounds: each findBounds.
			colClipBounds add: each findBounds ].
		self removeOffCanvas.
		self changed ].
	^ super update: anObject
]

{ #category : #'damage control' }
GdaStructureViewMorph >> updateBoundsFromPoint1: aPoint1 point2: aPoint2 [

	| upBounds p1 p2 left top right bottom |
	p1 := self viewport xy2hv: aPoint1.
	p2 := self viewport xy2hv: aPoint2.
	left := p1 x min: p2 x.
	top := p1 y min: p2 y.
	right := p1 x max: p2 x.
	bottom := p1 y max: p2 y.
	upBounds := Rectangle
		            left: left
		            right: right
		            top: top
		            bottom: bottom.
	upBounds := upBounds expandBy: 20.
	upBounds := upBounds translateBy: self pixelBounds origin.
	^ upBounds
]

{ #category : #'damage control' }
GdaStructureViewMorph >> updateBoundsFromWorldRectangle: aRectangle [

	^ self
		  updateBoundsFromPoint1: aRectangle origin
		  point2: aRectangle corner
]

{ #category : #'zoom animation' }
GdaStructureViewMorph >> updateZoom: zoom cursor: cursorPoint [

	| zoomState targetZoom start end now fraction newCenter |
	zoomState := state at: #zooming.

	"change the target zoom and increase time a bit"
	targetZoom := zoomState at: 3.

	start := zoomState at: 4.
	end := zoomState at: 5.

	now := Time millisecondClockValue.

	now := now min: end.
	fraction := now - start / (end - start).

	"zoom goes from 1..target zoom"
	targetZoom := 1 * (1 - fraction) + (targetZoom * fraction).

	self step. "to update transform"
	zoomState at: 3 put: targetZoom * zoom.
	newCenter := self viewport transform inverseTransform:
		             cursorPoint - bounds origin.
	zoomState at: 1 put: newCenter.
	zoomState at: 2 put: self viewport transform copy.
	zoomState at: 4 put: now.
	zoomState at: 5 put: now + 250
]

{ #category : #'viewing navigation' }
GdaStructureViewMorph >> viewFit [

	self viewport ifNil: [ ^ self ].
	self viewport viewFit
]

{ #category : #'viewing navigation' }
GdaStructureViewMorph >> viewMoveDown [

	self viewport ifNil: [ ^ self ].
	self viewport viewMove: 0.0 @ self viewMoveRatio negated
]

{ #category : #'viewing navigation' }
GdaStructureViewMorph >> viewMoveLeft [

	self viewport ifNil: [ ^ self ].
	self viewport viewMove: self viewMoveRatio negated @ 0.0
]

{ #category : #'viewing navigation' }
GdaStructureViewMorph >> viewMoveRatio [

	^ 0.2
]

{ #category : #'viewing navigation' }
GdaStructureViewMorph >> viewMoveRight [

	self viewport ifNil: [ ^ self ].
	self viewport viewMove: self viewMoveRatio @ 0.0
]

{ #category : #'viewing navigation' }
GdaStructureViewMorph >> viewMoveUp [

	self viewport ifNil: [ ^ self ].
	self viewport viewMove: 0.0 @ self viewMoveRatio
]

{ #category : #viewport }
GdaStructureViewMorph >> viewRange [

	^ viewRange
]

{ #category : #viewport }
GdaStructureViewMorph >> viewRangeFrom: minValue to: maxValue [

	viewRange := Interval from: minValue to: maxValue.
	self changed: #viewRange
]

{ #category : #'viewing navigation' }
GdaStructureViewMorph >> viewZoomDouble [

	self viewport ifNil: [ ^ self ].
	self viewport zoom: 2.0
]

{ #category : #'viewing navigation' }
GdaStructureViewMorph >> viewZoomHalf [

	self viewport ifNil: [ ^ self ].
	self viewport zoom: 0.5
]

{ #category : #viewport }
GdaStructureViewMorph >> viewport [

	^ viewport
]

{ #category : #'traits - extracted' }
GdaStructureViewMorph >> visibleElements [

	^ self clipedElements select: [ :el | el isVisible ]
]

{ #category : #'traits - extracted' }
GdaStructureViewMorph >> visibleGridColor [

	^ self backgroundColor luminance > 0.7
		  ifTrue: [ Color black ]
		  ifFalse: [ Color white ]
]

{ #category : #'traits - extracted' }
GdaStructureViewMorph >> visibleLocationColor [

	| test |
	test := self backgroundColor luminance < 0.7.
	"GdsFeelMorphic borderedSensorDisplay" 
	false ifTrue: [ test := test not ].
	^ test
		  ifTrue: [ Color white ]
		  ifFalse: [ Color black ]
]

{ #category : #'traits - extracted' }
GdaStructureViewMorph >> visibleMarkerColor [

	^ self visibleGridColor
]

{ #category : #'traits - extracted' }
GdaStructureViewMorph >> visiblePenColor [

	^ self backgroundColor luminance > 0.7
		  ifTrue: [ Color black ]
		  ifFalse: [ Color lightGray ]
]

{ #category : #utility }
GdaStructureViewMorph >> worldPointOfEvent: event [

	| localPoint worldPoint |
	localPoint := event cursorPoint - self innerBounds origin.
	worldPoint := self viewport worldPointFromLocal: localPoint.
	^ worldPoint
]
