Class {
	#name : #GdaReferenceElement,
	#superclass : #GdaElement,
	#instVars : [
		'strans'
	],
	#category : #'GdsFeel-Model2-Container'
}

{ #category : #testing }
GdaReferenceElement class >> isReference [

	^ true
]

{ #category : #'accessing - basic' }
GdaReferenceElement >> angle [

	^ strans angle
]

{ #category : #'accessing - basic' }
GdaReferenceElement >> angle: aDegees [

	strans angle: aDegees.
	self refreshBounds
]

{ #category : #copying }
GdaReferenceElement >> copyTransform [

	strans := strans copy
]

{ #category : #accessing }
GdaReferenceElement >> dataOutlinePoints [

	^ self lookupExtentPoints
]

{ #category : #initialization }
GdaReferenceElement >> initialize [

	super initialize.
	strans := GdaStructureTransform new
]

{ #category : #testing }
GdaReferenceElement >> isPureTranslation [

	^ self transform isPureTranslation
]

{ #category : #testing }
GdaReferenceElement >> isReflected [

	^ strans isReflected
]

{ #category : #protected }
GdaReferenceElement >> lookupExtentPoints [

	^ #(  )
]

{ #category : #'accessing - basic' }
GdaReferenceElement >> mag [

	^ strans mag
]

{ #category : #'accessing - basic' }
GdaReferenceElement >> mag: aFactor [

	strans mag: aFactor.
	self refreshBounds
]

{ #category : #accessing }
GdaReferenceElement >> moveRelative: aPoint from: aOtherElement [

	| translatedPoint |
	translatedPoint := aOtherElement xy + aPoint.
	self privateWipe.
	self xy: translatedPoint
]

{ #category : #copying }
GdaReferenceElement >> postCopy [

	super postCopy.
	self copyTransform
]

{ #category : #'accessing - basic' }
GdaReferenceElement >> setReflected: aBoolean [

	strans setReflected: aBoolean.
	self refreshBounds
]

{ #category : #accessing }
GdaReferenceElement >> strans [

	^ strans
]

{ #category : #accessing }
GdaReferenceElement >> transform [

	^ strans asMatrix2x3
]

{ #category : #'accessing - basic' }
GdaReferenceElement >> xy [

	^ strans offset
]

{ #category : #'accessing - basic' }
GdaReferenceElement >> xy: aPoint [

	self privateWipe.
	super xy: aPoint.
	strans offset: aPoint.
	self refreshBounds
]
