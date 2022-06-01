"
A GdsStructureView is Athens based gds structure view.

Instance Variables
	structure:		<GdsStructure>
	viewport:		<GdsViewport>

"
Class {
	#name : #GdsAthensStructureDrawer,
	#superclass : #Object,
	#traits : 'TGdsStructureDrawable',
	#classTraits : 'TGdsStructureDrawable classTrait',
	#instVars : [
		'structure',
		'viewport',
		'solidPenWidth',
		'morph'
	],
	#category : #'GdsFeel-UI-Athens'
}

{ #category : #rendering }
GdsAthensStructureDrawer class >> athensTransformFromMatrix2x3: aMatrixTransform2x3 [
	| athensAT |
	athensAT := AthensAffineTransform new.
	athensAT x: aMatrixTransform2x3 a13.
	athensAT y: aMatrixTransform2x3 a23.

	athensAT sx: aMatrixTransform2x3 a11.
	athensAT sy: aMatrixTransform2x3 a22.

	athensAT shx: aMatrixTransform2x3 a12.
	athensAT shy: aMatrixTransform2x3 a21.
	^ athensAT
	 
]

{ #category : #'as yet unclassified' }
GdsAthensStructureDrawer class >> openMorphWithStructure: aGdsStructure [
	| scene |
	scene := self new initWithStructure: aGdsStructure.
	^ GdsSceneView  new
		scene: scene;
		yourself.

]

{ #category : #'as yet unclassified' }
GdsAthensStructureDrawer class >> openStructure: aGdsStructure [
	^ (self openMorphWithStructure: aGdsStructure)
		openInWindow
]

{ #category : #appearance }
GdsAthensStructureDrawer >> backgroundColor [
	"implements TGdsStructureDrawable"
	^ Color black
]

{ #category : #'as yet unclassified' }
GdsAthensStructureDrawer >> canDisplayKindForKey: aKey element: aGdsElement [
	^ (aGdsElement structure kinds atKey: aKey) isVisible
]

{ #category : #accessing }
GdsAthensStructureDrawer >> clipedElements [
	"implements: TGdsStructureDrawable"
	^ self structure elements
]

{ #category : #'event handling' }
GdsAthensStructureDrawer >> handleEvent: event in: sceneView at: position [
	event traceCr.
	position traceCr.
	^ false
]

{ #category : #'initialize - release' }
GdsAthensStructureDrawer >> initWithStructure: aGdsStructure [
	structure := aGdsStructure.

]

{ #category : #rendering }
GdsAthensStructureDrawer >> lookupSolidPenWidth: aCanvas [
	| x y tr |
	x := ByteArray new: 8.
	y := ByteArray new: 8.
	x doubleAt: 1 put: 1.
	y doubleAt: 1 put: 1.
			
	tr := AthensCairoTransform new canvas: aCanvas.
	tr primInverseDistanceTransformX: x Y: y.
	^ x  doubleAt: 1
	
]

{ #category : #rendering }
GdsAthensStructureDrawer >> pathBuilder: pb points: aPointArray [
	| points |
	"points := aPointArray collect: [ :each | each + 0.5 ]."
	points := aPointArray .
	pb absolute.
	pb moveTo: points first.
	points allButFirstDo: [ :pt | pb lineTo: pt]
]

{ #category : #rendering }
GdsAthensStructureDrawer >> renderOn: aCanvas [
	|    |
	"aCanvas pathTransform scaleBy: (1@ -1)."
	"aCanvas drawShape: (aCanvas createPath: [ :pb | 
			pb moveTo: (-1 @ -1).
			pb lineTo: (1 @ 1).
		]).
	(aCanvas setStrokePaint: Color white)
		width: (self lookupSolidPenWidth: aCanvas)."
	self renderStructure: self structure on: aCanvas 
	
]

{ #category : #rendering }
GdsAthensStructureDrawer >> renderStructure: aGdsStructure on: aCanvas [
	aGdsStructure elements 
		do: [ :el | 
			aCanvas pathTransform
				restoreAfter: [
					self strokeElement: el on: aCanvas] ]
	
	
]

{ #category : #accessing }
GdsAthensStructureDrawer >> sceneView: aSeneView [
	morph := aSeneView.
	morph viewport viewFit.
]

{ #category : #rendering }
GdsAthensStructureDrawer >> strokeAref: aGdsElement on: aCanvas [
	|  |
	aGdsElement refStructure ifNil: [ ^self ].
	aCanvas pathTransform restoreAfter: [
		"pt multiplyBy: aGdsElement transform asAthensAT."
		aGdsElement repeatTransforms do: [ :mat |
			aCanvas pathTransform restoreAfter: [
				aCanvas pathTransform multiplyBy:  mat asAthensAT. 
				self renderStructure: aGdsElement refStructure on: aCanvas ] ] ]
]

{ #category : #rendering }
GdsAthensStructureDrawer >> strokeBoundary: aGdsElement on: aCanvas [
	| path |
	path := aCanvas cacheAt: aGdsElement ifAbsentPut: [ 
		aCanvas createPath: [ :pb | 
			self pathBuilder: pb points: aGdsElement vertices]].
	self strokePaintFor: aGdsElement on: aCanvas.
	aCanvas drawShape: path.
]

{ #category : #rendering }
GdsAthensStructureDrawer >> strokeBoxtext: aGdsElement on: aCanvas [
	| font scale savedPaint |
	(self canDisplayKindForKey: 'TX' element: aGdsElement)
		ifFalse: [ ^ self ].
	aCanvas pathTransform
		restoreAfter: [ 
			savedPaint := aCanvas paint.
			font := TextStyle defaultFont realFont.
			scale := aGdsElement dataBounds height / font pixelSize.
			aCanvas setFont: font.
			aCanvas pathTransform translateX: aGdsElement xy x Y: aGdsElement xy y.
			aCanvas pathTransform scaleBy: scale @ scale negated.
			aCanvas setPaint: (self colorForElement: aGdsElement).
			aCanvas drawString: 'abc'.
			"aCanvas drawString: ([aGdsElement contents asString] on: Error do: [:ex | ex return: 'abc'])."
			savedPaint ifNotNil: [ aCanvas setPaint: savedPaint ]
			 ]	
]

{ #category : #rendering }
GdsAthensStructureDrawer >> strokeElement: aGdsElement on: aCanvas [
	(#boundary == aGdsElement type)
		ifTrue: [ 
			^ self strokeBoundary: aGdsElement on: aCanvas ]. 
			
	(#path == aGdsElement type)
		ifTrue: [ 
			^ self strokePath: aGdsElement on: aCanvas ]. 

	(#boxtext == aGdsElement type)
		ifTrue: [ 
			^ self strokeBoxtext: aGdsElement on: aCanvas ]. 
			
	(#sref == aGdsElement type)
		ifTrue: [ 
			^ self strokeSref: aGdsElement on: aCanvas ]. 

	(#aref == aGdsElement type)
		ifTrue: [ 
			^ self strokeAref: aGdsElement on: aCanvas ].

]

{ #category : #rendering }
GdsAthensStructureDrawer >> strokePaintFor: aGdsElement on: aCanvas [
	(aCanvas setStrokePaint: (self colorForElement: aGdsElement)) 
		width: (self lookupSolidPenWidth: aCanvas).

]

{ #category : #rendering }
GdsAthensStructureDrawer >> strokePath: aGdsElement on: aCanvas [
	| path |
	path := aCanvas cacheAt: aGdsElement ifAbsentPut: [ 
		aCanvas createPath: [ :pb | 
			self pathBuilder: pb points: aGdsElement dataOutlinePoints]].
	self strokePaintFor: aGdsElement on: aCanvas.
	aCanvas drawShape: path.
]

{ #category : #rendering }
GdsAthensStructureDrawer >> strokeSref: aGdsElement on: aCanvas [
	|  |
	aGdsElement refStructure ifNil: [ ^self ].
	aCanvas pathTransform restoreAfter: [
		aCanvas pathTransform multiplyBy: aGdsElement transform asAthensAT.
		self renderStructure: aGdsElement refStructure on: aCanvas ]
]

{ #category : #accessing }
GdsAthensStructureDrawer >> structure [
	^ structure
]
