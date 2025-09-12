"
A GdsViewport is Pluggable coordinate transformer.

Instance Variables
	grid:		<GdsGrid>
	lastPoint:		<Object>
	model:		<Object>
	pixelBoundsSelector:		<Symbol>
	pixelBoundsTarget:		<Object>
	scale:		<Float>
	viewCenter:		<Point>
	wTrans:		<MatrixTransform2x3>

grid
	- xxxxx

lastPoint
	- xxxxx

model
	- xxxxx

pixelBoundsSelector
	- xxxxx

pixelBoundsTarget
	- xxxxx

scale
	- xxxxx

viewCenter
	- xxxxx

wTrans
	- xxxxx

"
Class {
	#name : #GdsViewport,
	#superclass : #GdsModel,
	#instVars : [
		'scale',
		'grid',
		'viewCenter',
		'pixelBoundsSelector',
		'pixelBoundsTarget',
		'model',
		'fittingRatio',
		'portCenter',
		'transformStack',
		'basicTransform',
		'transform',
		'extent',
		'lockUpdate',
		'updateCount'
	],
	#category : #'GdsFeel-Model-Viewing'
}

{ #category : #'as yet unclassified' }
GdsViewport class >> defaultFittingRatio [

	^ 0.98
]

{ #category : #accessing }
GdsViewport >> absoluteScale [

	^ self transform a11 abs
]

{ #category : #transforms }
GdsViewport >> basicTransform [

	^ basicTransform ifNil: [ 
		  basicTransform := self lookupBasicTransform ]
]

{ #category : #testing }
GdsViewport >> canGridDraw [

	^ self grid displayMultiply ~= 0 and: [ 
		  (self gridScale x * self absoluteScale) asFloat
		  * self grid displayMultiply > 8.0 ]
]

{ #category : #private }
GdsViewport >> damageTransform [

	lockUpdate ifTrue: [ 
		updateCount := updateCount + 1.
		^ self ].
	basicTransform := nil.
	transform := nil.
	self announcer announce: #viewTransformChanged
]

{ #category : #defaults }
GdsViewport >> defaultFittingRatio [

	^ GdsFeel fittingRatio
]

{ #category : #accessing }
GdsViewport >> extent [

	^ extent
]

{ #category : #drawing }
GdsViewport >> extent: aPoint [

	extent := aPoint.
	self damageTransform
]

{ #category : #accessing }
GdsViewport >> fittingRatio [

	^ fittingRatio
]

{ #category : #accessing }
GdsViewport >> fittingRatio: aFloat [

	fittingRatio := (aFloat > 1.0 or: [ aFloat < 0.5 ])
		                ifTrue: [ self defaultFittingRatio ]
		                ifFalse: [ aFloat ]
]

{ #category : #accessing }
GdsViewport >> grid [

	grid ifNil: [ grid := GdsGrid new ].
	^ grid
]

{ #category : #accessing }
GdsViewport >> grid: aGrid [

	grid := aGrid.
	self changed
]

{ #category : #accessing }
GdsViewport >> gridOffset [

	^ self grid offset
]

{ #category : #accessing }
GdsViewport >> gridScale [

	^ self grid scale
]

{ #category : #initialization }
GdsViewport >> initialize [

	super initialize.
	fittingRatio := self defaultFittingRatio.
	transformStack := OrderedCollection new.
	lockUpdate := false.
	scale := (self floatNamed: 'scale')
		         initialValue: 1.0;
		         yourself.
	viewCenter := (GdsObjectProperty
		               named: 'viewCenter'
		               type: Point
		               owner: self)
		              initialValue: 0 @ 0;
		              yourself.
	portCenter := (GdsObjectProperty
		               named: 'portCenter'
		               type: Point
		               owner: self)
		              initialValue: 0 @ 0;
		              yourself.

	{ 
		portCenter.
		scale.
		viewCenter } do: [ :slot | 
		slot whenChangedDo: [ :prop | self damageTransform ] ].
	self endProperties
]

{ #category : #accessing }
GdsViewport >> lockUpdateDuring: aBlock [

	updateCount := 0.
	lockUpdate := true.
	aBlock value.
	lockUpdate := false.
	updateCount > 0 ifTrue: [ self damageTransform ].
	updateCount := 0
]

{ #category : #lookup }
GdsViewport >> lookupBasicTransform [

	| m |
	m := GeometryUtils transformClass new.
	m setScale: 1 @ -1.
	m setOffset: 0 @ self pixelBounds extent y.
	m := m composedWithLocal:
		     (GeometryUtils transformClass withOffset: self portCenter).
	m := m composedWithLocal:
		     (GeometryUtils transformClass withScale: self viewScale asPoint).
	m := m composedWithLocal:
		     (GeometryUtils transformClass withOffset: self viewCenter negated).
	^ m
]

{ #category : #lookup }
GdsViewport >> lookupHorizontalGridSteps [

	^ self grid
		  lookupGridStepsMin: self worldViewMinX
		  max: self worldViewMaxX
		  gridScale: self gridScale x * self grid displayMultiply
		  gridOffset: self gridOffset x
]

{ #category : #lookup }
GdsViewport >> lookupTransform [

	| newTransform |
	newTransform := GeometryUtils transformClass identity.
	newTransform := newTransform composedWithLocal: self basicTransform.
	transformStack do: [ :tx | 
		newTransform := newTransform composedWithLocal: tx ].
	"self announcer announce: #viewTransformChanged."
	^ newTransform
]

{ #category : #lookup }
GdsViewport >> lookupVerticalGridSteps [

	^ self grid
		  lookupGridStepsMin: self worldViewMinY
		  max: self worldViewMaxY
		  gridScale: self gridScale y * self grid displayMultiply
		  gridOffset: self gridOffset y
]

{ #category : #viewing }
GdsViewport >> marginBounds: aBaseBounds [

	| growFactor growWidth growHeight |
	growFactor := self fittingRatio reciprocal - 1.0.
	growWidth := aBaseBounds width * growFactor * 0.5.
	growHeight := aBaseBounds height * growFactor * 0.5.
	^ aBaseBounds expandBy: growWidth @ growHeight
]

{ #category : #viewing }
GdsViewport >> maxScaleLimit [

	^ 1000
]

{ #category : #viewing }
GdsViewport >> minScaleLimit [

	^ self maxScaleLimit reciprocal asFloat
]

{ #category : #initialization }
GdsViewport >> model: aModel [

	model := aModel
]

{ #category : #transforms }
GdsViewport >> morphicPointFromGlobal: aGlobalPoint [

	^ aGlobalPoint - self pixelBounds origin
]

{ #category : #private }
GdsViewport >> pixelBounds [

	^ pixelBoundsTarget perform: pixelBoundsSelector
]

{ #category : #initialization }
GdsViewport >> pixelBoundsSelector: aSelector [

	pixelBoundsSelector := aSelector
]

{ #category : #initialization }
GdsViewport >> pixelBoundsTarget: aTarget [

	self assert: [ aTarget isNil not ].
	pixelBoundsTarget := aTarget
]

{ #category : #transforms }
GdsViewport >> pixelSize: aWorldSize [

	^ (self xy2hv: aWorldSize asPoint) distanceTo:
		  (self xy2hv: 0 asPoint)
]

{ #category : #private }
GdsViewport >> popTransform [

	| result |
	result := transformStack last.
	transformStack := transformStack allButLast.
	transform := nil.
	^ result
]

{ #category : #accessing }
GdsViewport >> portCenter [

	^ portCenter getValue
]

{ #category : #accessing }
GdsViewport >> portCenter: aPoint [

	portCenter setValue:
		aPoint x @ (self pixelBounds extent y - aPoint y)
]

{ #category : #private }
GdsViewport >> pushTransform: aMatrixTransform2x3 [

	self assert: aMatrixTransform2x3 isNil not.
	transformStack add: aMatrixTransform2x3.
	transform := nil
]

{ #category : #drawing }
GdsViewport >> pushTransform: aMatrixTransform2x3 during: aBlock [

	self pushTransform: aMatrixTransform2x3.
	aBlock value.
	self popTransform
]

{ #category : #viewing }
GdsViewport >> resetPortCenter [

	self portCenter: self pixelBounds extent / 2.0.
	self viewScale: 1.0.
	self viewCenter: 0 @ 0
]

{ #category : #initialization }
GdsViewport >> scaleProperty [

	^ scale
]

{ #category : #transforms }
GdsViewport >> snapedWorldPoint: aWorldPoint [

	^ (GeometryUtils point: aWorldPoint roundTo: self gridScale)
	  + self gridOffset
]

{ #category : #transforms }
GdsViewport >> snapedWorldPointFromGlobal: aGlobalPoint [

	^ self snapedWorldPoint: (self worldPointFromGlobal: aGlobalPoint)
]

{ #category : #transforms }
GdsViewport >> transform [

	transform ifNil: [ transform := self lookupTransform ].
	^ transform
]

{ #category : #accessing }
GdsViewport >> updatePortBy: aGdsViewport [

	self portCenter: aGdsViewport portCenter.
	self viewCenter: aGdsViewport viewCenter.
	self viewScale: aGdsViewport viewScale
]

{ #category : #accessing }
GdsViewport >> viewBounds: aWorldBounds [

	| hRatio vRatio scalingFactor centerPoint |
	scalingFactor := 1.
	hRatio := [ (self pixelBounds width / aWorldBounds width) asFloat ]
		          on: Error
		          do: [ :ex | ex return: 1 ].
	vRatio := [ (self pixelBounds height / aWorldBounds height) asFloat ]
		          on: Error
		          do: [ :ex | ex return: 1 ].
	scalingFactor := hRatio min: vRatio.
	centerPoint := aWorldBounds origin + aWorldBounds corner / 2.0.
	self lockUpdateDuring: [ 
		self portCenter: self pixelBounds extent / 2.0.
		self viewScale: scalingFactor.
		self viewCenter: centerPoint ]
]

{ #category : #accessing }
GdsViewport >> viewCenter [

	^ viewCenter getValue
]

{ #category : #accessing }
GdsViewport >> viewCenter: aPoint [

	viewCenter setValue: aPoint
]

{ #category : #viewing }
GdsViewport >> viewFit [

	self viewBounds: (self marginBounds: model dataExtentForFittingView)
]

{ #category : #viewing }
GdsViewport >> viewMove: aFractionPoint [

	self viewMoveFractionX: aFractionPoint x y: aFractionPoint y
]

{ #category : #viewing }
GdsViewport >> viewMoveFractionX: aXfraction y: aYfraction [

	| xDelta yDelta newCenter |
	xDelta := self worldViewWidth * aXfraction.
	yDelta := self worldViewHeight * aYfraction.
	newCenter := self viewCenter + (xDelta @ yDelta).
	self viewCenter: newCenter
]

{ #category : #accessing }
GdsViewport >> viewScale [

	^ scale getValue
]

{ #category : #accessing }
GdsViewport >> viewScale: aScale [

	aScale < self minScaleLimit ifTrue: [ 
		Transcript
			cr;
			show: '*** WARNING *** minimam scale limit.'.
		^ self ].
	aScale > self maxScaleLimit ifTrue: [ 
		Transcript
			cr;
			show: '*** WARNING *** maximam scale limit.'.
		^ self ].
	scale setValue: aScale
]

{ #category : #transforms }
GdsViewport >> worldPointFromGlobal: aGlobalPoint [

	^ self transform invertPoint:
		  (self morphicPointFromGlobal: aGlobalPoint)
]

{ #category : #transforms }
GdsViewport >> worldPointFromLocal: aMorphcLocalPoint [

	^ self transform invertPoint: aMorphcLocalPoint
]

{ #category : #'world-geometry' }
GdsViewport >> worldViewBounds [

	^ Rectangle origin: self worldViewOrigin corner: self worldViewCorner
]

{ #category : #'world-geometry' }
GdsViewport >> worldViewCorner [

	| globalPoint |
	globalPoint := self pixelBounds right @ self pixelBounds top.
	^ self worldPointFromGlobal: globalPoint
]

{ #category : #'world-geometry' }
GdsViewport >> worldViewHeight [

	^ self worldViewMaxY - self worldViewMinY
]

{ #category : #'world-geometry' }
GdsViewport >> worldViewMaxX [

	^ self worldViewCorner x
]

{ #category : #'world-geometry' }
GdsViewport >> worldViewMaxY [

	^ self worldViewCorner y
]

{ #category : #'world-geometry' }
GdsViewport >> worldViewMinX [

	^ self worldViewOrigin x
]

{ #category : #'world-geometry' }
GdsViewport >> worldViewMinY [

	^ self worldViewOrigin y
]

{ #category : #'world-geometry' }
GdsViewport >> worldViewOrigin [

	| globalPoint |
	globalPoint := self pixelBounds left @ self pixelBounds bottom.
	^ self worldPointFromGlobal: globalPoint
]

{ #category : #'world-geometry' }
GdsViewport >> worldViewWidth [

	^ self worldViewMaxX - self worldViewMinX
]

{ #category : #transforms }
GdsViewport >> xy2hv: aWorldPoint [

	^ self xy2hv: aWorldPoint transform: self transform
]

{ #category : #transforms }
GdsViewport >> xy2hv: aWorldPoint transform: aMatrixTransform2x3 [

	| np1 |
	aWorldPoint isPoint ifFalse: [  ].
	np1 := aMatrixTransform2x3 localPointToGlobal: aWorldPoint. "np1 := GeometryUtils point: np1 roundTo: 1.0."
	^ GeometryUtils limitedPoint: np1 rounded
]

{ #category : #transforms }
GdsViewport >> xy2hvPoints: aPointArray [

	^ aPointArray collect: [ :each | self xy2hv: each ]
]

{ #category : #viewing }
GdsViewport >> zoom: aNumber [

	self viewScale: self viewScale * aNumber
]
