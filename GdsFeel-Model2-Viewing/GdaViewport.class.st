Class {
	#name : #GdaViewport,
	#superclass : #GdaModel,
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
	#category : #'GdsFeel-Model2-Viewing'
}

{ #category : #'as yet unclassified' }
GdaViewport class >> defaultFittingRatio [

	^ 0.98
]

{ #category : #accessing }
GdaViewport >> absoluteScale [

	^ self transform a11 abs
]

{ #category : #transforms }
GdaViewport >> basicTransform [

	^ basicTransform ifNil: [ 
		  basicTransform := self lookupBasicTransform ]
]

{ #category : #testing }
GdaViewport >> canGridDraw [

	^ self grid displayMultiply ~= 0 and: [ 
		  (self gridScale x * self absoluteScale) asFloat
		  * self grid displayMultiply > 8.0 ]
]

{ #category : #private }
GdaViewport >> damageTransform [

	lockUpdate ifTrue: [ 
		updateCount := updateCount + 1.
		^ self ].
	basicTransform := nil.
	transform := nil.
	self changed.
	"self announcer announce: #viewTransformChanged"
]

{ #category : #defaults }
GdaViewport >> defaultFittingRatio [

	^ 0.98
]

{ #category : #accessing }
GdaViewport >> extent [

	^ extent
]

{ #category : #drawing }
GdaViewport >> extent: aPoint [

	aPoint = aPoint ifTrue: [ ^ self ].
	extent := aPoint.
	self damageTransform
]

{ #category : #accessing }
GdaViewport >> fittingRatio [

	^ fittingRatio
]

{ #category : #accessing }
GdaViewport >> fittingRatio: aFloat [

	fittingRatio = aFloat ifTrue: [ ^ self ].
	fittingRatio := (aFloat > 1.0 or: [ aFloat < 0.5 ])
		                ifTrue: [ self defaultFittingRatio ]
		                ifFalse: [ aFloat ].
	self damageTransform
]

{ #category : #accessing }
GdaViewport >> grid [

	grid ifNil: [ grid := GdaGrid new ].
	^ grid
]

{ #category : #accessing }
GdaViewport >> grid: aGrid [

	grid := aGrid.
	self changed
]

{ #category : #accessing }
GdaViewport >> gridOffset [

	^ self grid offset
]

{ #category : #accessing }
GdaViewport >> gridScale [

	^ self grid scale
]

{ #category : #initialization }
GdaViewport >> initialize [

	super initialize.
	fittingRatio := self defaultFittingRatio.
	transformStack := OrderedCollection new.
	lockUpdate := false.
	scale := 1.0.
	viewCenter := 0 @ 0.
	portCenter := 0 @ 0
]

{ #category : #accessing }
GdaViewport >> lockUpdateDuring: aBlock [

	updateCount := 0.
	lockUpdate := true.
	aBlock value.
	lockUpdate := false.
	updateCount > 0 ifTrue: [ self damageTransform ].
	updateCount := 0
]

{ #category : #lookup }
GdaViewport >> lookupBasicTransform [

	| m |
	m := self transformClass new.
	m setScale: 1 @ -1.
	m setOffset: 0 @ self pixelBounds extent y.
	m := m composedWithLocal:
		     (self transformClass withOffset: self portCenter).
	m := m composedWithLocal:
		     (self transformClass withScale: self viewScale asPoint).
	m := m composedWithLocal:
		     (self transformClass withOffset: self viewCenter negated).
	^ m
]

{ #category : #lookup }
GdaViewport >> lookupHorizontalGridSteps [

	^ self grid
		  lookupGridStepsMin: self worldViewMinX
		  max: self worldViewMaxX
		  gridScale: self gridScale x * self grid displayMultiply
		  gridOffset: self gridOffset x
]

{ #category : #lookup }
GdaViewport >> lookupTransform [

	| newTransform |
	newTransform := self transformClass identity.
	newTransform := newTransform composedWithLocal: self basicTransform.
	transformStack do: [ :tx | 
		newTransform := newTransform composedWithLocal: tx ].
	"self announcer announce: #viewTransformChanged."
	^ newTransform
]

{ #category : #lookup }
GdaViewport >> lookupVerticalGridSteps [

	^ self grid
		  lookupGridStepsMin: self worldViewMinY
		  max: self worldViewMaxY
		  gridScale: self gridScale y * self grid displayMultiply
		  gridOffset: self gridOffset y
]

{ #category : #viewing }
GdaViewport >> marginBounds: aBaseBounds [

	| growFactor growWidth growHeight |
	growFactor := self fittingRatio reciprocal - 1.0.
	growWidth := aBaseBounds width * growFactor * 0.5.
	growHeight := aBaseBounds height * growFactor * 0.5.
	^ aBaseBounds expandBy: growWidth @ growHeight
]

{ #category : #viewing }
GdaViewport >> maxScaleLimit [

	^ 1000
]

{ #category : #viewing }
GdaViewport >> minScaleLimit [

	^ self maxScaleLimit reciprocal asFloat
]

{ #category : #initialization }
GdaViewport >> model: aModel [

	model := aModel
]

{ #category : #transforms }
GdaViewport >> morphicPointFromGlobal: aGlobalPoint [

	^ aGlobalPoint - self pixelBounds origin
]

{ #category : #private }
GdaViewport >> pixelBounds [

	^ pixelBoundsTarget perform: pixelBoundsSelector
]

{ #category : #initialization }
GdaViewport >> pixelBoundsSelector: aSelector [

	pixelBoundsSelector := aSelector
]

{ #category : #initialization }
GdaViewport >> pixelBoundsTarget: aTarget [

	self assert: [ aTarget isNil not ].
	pixelBoundsTarget := aTarget
]

{ #category : #transforms }
GdaViewport >> pixelSize: aWorldSize [

	^ (self xy2hv: aWorldSize asPoint) distanceTo:
		  (self xy2hv: 0 asPoint)
]

{ #category : #private }
GdaViewport >> popTransform [

	| result |
	result := transformStack last.
	transformStack := transformStack allButLast.
	transform := nil.
	^ result
]

{ #category : #accessing }
GdaViewport >> portCenter [

	^ portCenter
]

{ #category : #accessing }
GdaViewport >> portCenter: aPoint [
	portCenter = aPoint ifTrue: [ ^ self ].
	portCenter := aPoint x @ (self pixelBounds extent y - aPoint y).
	self damageTransform
]

{ #category : #private }
GdaViewport >> pushTransform: aMatrixTransform2x3 [

	self assert: aMatrixTransform2x3 isNil not.
	transformStack add: aMatrixTransform2x3.
	transform := nil
]

{ #category : #drawing }
GdaViewport >> pushTransform: aMatrixTransform2x3 during: aBlock [

	self pushTransform: aMatrixTransform2x3.
	aBlock value.
	self popTransform
]

{ #category : #initialization }
GdaViewport >> release [
	scale := nil.
	grid := nil.
	viewCenter := nil.
	pixelBoundsSelector := nil.
	pixelBoundsTarget := nil.
	model := nil.
	fittingRatio := nil.
	portCenter := nil.
	transformStack := nil.
	basicTransform := nil.
	transform := nil.
	extent := nil.
	lockUpdate := nil.
	updateCount := nil.
	super release 
]

{ #category : #viewing }
GdaViewport >> resetPortCenter [

	self portCenter: self pixelBounds extent / 2.0.
	self viewScale: 1.0.
	self viewCenter: 0 @ 0
]

{ #category : #transforms }
GdaViewport >> snapedWorldPoint: aWorldPoint [

	^ (GeometryUtils point: aWorldPoint roundTo: self gridScale)
	  + self gridOffset
]

{ #category : #transforms }
GdaViewport >> snapedWorldPointFromGlobal: aGlobalPoint [

	^ self snapedWorldPoint: (self worldPointFromGlobal: aGlobalPoint)
]

{ #category : #transforms }
GdaViewport >> transform [

	transform ifNil: [ transform := self lookupTransform ].
	^ transform
]

{ #category : #defaults }
GdaViewport >> transformClass [
	^ MatrixTransform2x3 
]

{ #category : #accessing }
GdaViewport >> updatePortBy: aGdsViewport [

	self portCenter: aGdsViewport portCenter.
	self viewCenter: aGdsViewport viewCenter.
	self viewScale: aGdsViewport viewScale
]

{ #category : #accessing }
GdaViewport >> viewBounds: aWorldBounds [

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
GdaViewport >> viewCenter [

	^ viewCenter
]

{ #category : #accessing }
GdaViewport >> viewCenter: aPoint [

	viewCenter = aPoint ifTrue: [ ^ self ].
	viewCenter := aPoint.
	self damageTransform
]

{ #category : #viewing }
GdaViewport >> viewFit [

	self viewBounds: (self marginBounds: model dataExtentForFittingView)
]

{ #category : #viewing }
GdaViewport >> viewMove: aFractionPoint [

	self viewMoveFractionX: aFractionPoint x y: aFractionPoint y
]

{ #category : #viewing }
GdaViewport >> viewMoveFractionX: aXfraction y: aYfraction [

	| xDelta yDelta newCenter |
	xDelta := self worldViewWidth * aXfraction.
	yDelta := self worldViewHeight * aYfraction.
	newCenter := self viewCenter + (xDelta @ yDelta).
	self viewCenter: newCenter
]

{ #category : #accessing }
GdaViewport >> viewScale [

	^ scale
]

{ #category : #accessing }
GdaViewport >> viewScale: aScale [
	scale = aScale ifTrue: [ ^ self ].
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
	scale := aScale.
	self damageTransform.
]

{ #category : #transforms }
GdaViewport >> worldPointFromGlobal: aGlobalPoint [

	^ self transform invertPoint:
		  (self morphicPointFromGlobal: aGlobalPoint)
]

{ #category : #transforms }
GdaViewport >> worldPointFromLocal: aMorphcLocalPoint [

	^ self transform invertPoint: aMorphcLocalPoint
]

{ #category : #'world-geometry' }
GdaViewport >> worldViewBounds [

	^ Rectangle origin: self worldViewOrigin corner: self worldViewCorner
]

{ #category : #'world-geometry' }
GdaViewport >> worldViewCorner [

	| globalPoint |
	globalPoint := self pixelBounds right @ self pixelBounds top.
	^ self worldPointFromGlobal: globalPoint
]

{ #category : #'world-geometry' }
GdaViewport >> worldViewHeight [

	^ self worldViewMaxY - self worldViewMinY
]

{ #category : #'world-geometry' }
GdaViewport >> worldViewMaxX [

	^ self worldViewCorner x
]

{ #category : #'world-geometry' }
GdaViewport >> worldViewMaxY [

	^ self worldViewCorner y
]

{ #category : #'world-geometry' }
GdaViewport >> worldViewMinX [

	^ self worldViewOrigin x
]

{ #category : #'world-geometry' }
GdaViewport >> worldViewMinY [

	^ self worldViewOrigin y
]

{ #category : #'world-geometry' }
GdaViewport >> worldViewOrigin [

	| globalPoint |
	globalPoint := self pixelBounds left @ self pixelBounds bottom.
	^ self worldPointFromGlobal: globalPoint
]

{ #category : #'world-geometry' }
GdaViewport >> worldViewWidth [

	^ self worldViewMaxX - self worldViewMinX
]

{ #category : #transforms }
GdaViewport >> xy2hv: aWorldPoint [

	^ self xy2hv: aWorldPoint transform: self transform
]

{ #category : #transforms }
GdaViewport >> xy2hv: aWorldPoint transform: aMatrixTransform2x3 [

	| np1 |
	aWorldPoint isPoint ifFalse: [  ].
	np1 := aMatrixTransform2x3 localPointToGlobal: aWorldPoint. "np1 := GeometryUtils point: np1 roundTo: 1.0."
	^ GeometryUtils limitedPoint: np1 rounded
]

{ #category : #transforms }
GdaViewport >> xy2hvPoints: aPointArray [

	^ aPointArray collect: [ :each | self xy2hv: each ]
]

{ #category : #viewing }
GdaViewport >> zoom: aNumber [

	self viewScale: self viewScale * aNumber
]
