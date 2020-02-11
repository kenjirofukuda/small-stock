Class {
	#name : #GdxStructureRenderer,
	#superclass : #GdxVisitor,
	#instVars : [
		'canvas',
		'transforms',
		'composits'
	],
	#category : #'Gdx-Roassal3'
}

{ #category : #examples }
GdxStructureRenderer class >> example [
	<script: 'self example open'>
	^ self sampleVisitor canvas.
]

{ #category : #'as yet unclassified' }
GdxStructureRenderer class >> exampleNestedCompost [
	"self exampleNestedCompost inspect"
	<script: 'self  exampleNestedCompost open'>
	| canvas cmp cmp2 line |
	canvas := RSCanvas new.
	cmp := RSComposite new.
	line := RSLine new.
	line withBorder.
	"line border width: 0.1."
	line startPoint: 0 @ 0.
	line endPoint: 1 @ 1.
	cmp add: line.
	"	c add: cmp."
		cmp2 := cmp copy.
		cmp2 matrix rotateByDegrees: 90.
	canvas add: cmp.
	canvas add: cmp2.
	cmp updateBaseRectangle.
	cmp2 updateBaseRectangle.
	"line @ RSKeepMarkersSizeRatio."
	"canvas shapes do: [:shape | shape  @ RSKeepBorderWidthRatio ]."
	canvas newAnimation
		repeat;
		duration: 5 seconds;
		onStepDo:
				[ :t | canvas shapes do: [ :shape | self setCosmetic: shape ] ].
	canvas when: RSExtentChangedEvent do: [ canvas zoomToFit ].
	^ canvas
]

{ #category : #examples }
GdxStructureRenderer class >> sampleEntry [
	^ self sampleLibrary structureNamed: 'BANDGAP'
]

{ #category : #examples }
GdxStructureRenderer class >> sampleVisitor [
	"self exampleVisitor inspect."
	^ self on: self sampleEntry deepIntoReference: true.
]

{ #category : #utilities }
GdxStructureRenderer class >> setCosmetic: aRSShape [
	(aRSShape isKindOf: RSComposite)
		ifTrue: [ ^ aRSShape children do: [ :each | self setCosmetic: each ] ].
	aRSShape canvas
		ifNotNil: [ | scale |
			scale := aRSShape canvas camera scale.
			aRSShape border ifNil: [ aRSShape withBorder ].
			aRSShape border width: 1.0 / scale ]
]

{ #category : #accessing }
GdxStructureRenderer >> canvas [
	^ canvas
]

{ #category : #accessing }
GdxStructureRenderer >> composit [
	^ composits last
]

{ #category : #initialization }
GdxStructureRenderer >> initialize [
	super initialize.
	canvas := RSCanvas new.
	canvas @ RSCanvasController.
	transforms := OrderedCollection new.
	composits := OrderedCollection new.
]

{ #category : #visiting }
GdxStructureRenderer >> pushTransform: anAthensAffineTransform during: aBlock [
	| currentTransform |
	transforms add: anAthensAffineTransform copy.
	currentTransform := AthensAffineTransform new.
	transforms do: [ :t | currentTransform multiplyBy: t ].
	[ aBlock value: currentTransform ]
		ensure: [ transforms := transforms allButLast ]
]

{ #category : #utilities }
GdxStructureRenderer >> setCosmetic: aRSShape [
	self class setCosmetic: aRSShape
]

{ #category : #visiting }
GdxStructureRenderer >> visitAref: aGdxStructureReference [
	"self visitSref: aGdxStructureReference."
	aGdxStructureReference athensTransforms
		do: [ :transform | 
			self visitReference: aGdxStructureReference transform: transform ]
]

{ #category : #visiting }
GdxStructureRenderer >> visitElement: aGdxElement [
	| shape |
	aGdxElement vertices size < 2
		ifTrue: [ ^ self ].
	shape := (RSPolyline new controlPoints: aGdxElement vertices)
		withBorder;
		model: aGdxElement;
		yourself.
	shape border color: Color blue.
	self composit add: shape.

]

{ #category : #visiting }
GdxStructureRenderer >> visitReference: aGdxStructureReference transform: aTransform [
	self
		pushTransform: aTransform
		during: [ :transform | 
			self composit matrix: transform.
			self deepIntoReference
				ifTrue: [ aGdxStructureReference referencedStructure accept: self ] ]
]

{ #category : #visiting }
GdxStructureRenderer >> visitSref: aGdxStructureReference [
	self visitReference: aGdxStructureReference transform: aGdxStructureReference athensTransform.
]

{ #category : #visiting }
GdxStructureRenderer >> visitStructure: aGdxStructure [
	| c |
	self
		pushDepthDuring: [ 
			self assert: aGdxStructure class == GdxStructure.
			c := HgRSComposite new.
			c model: aGdxStructure.
			composits add: c.
			aGdxStructure elements do: [ :each | each accept: self ].
			self composit updateBaseRectangle.
			canvas add: self composit.
			composits := composits allButLast ].
	depth = 0
		ifTrue: [ 
			canvas newAnimation
				repeat;
				duration: 5 seconds;
				onStepDo: [ :t | canvas shapes do: [ :shape | self setCosmetic: shape ] ] ]
]
