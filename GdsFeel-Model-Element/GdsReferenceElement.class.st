"
A GdsReferenceElement is abstract class for: 

- GdsStructureReference known as SREF
- GdsArrayedStructureReference known as AREF 

"
Class {
	#name : #GdsReferenceElement,
	#superclass : #GdsElement,
	#instVars : [
		'strans'
	],
	#category : #'GdsFeel-Model-Element'
}

{ #category : #'as yet unclassified' }
GdsReferenceElement class >> fromItemContext: aGdsEditorContext atIndex: anIndex [
	^ self basicNew initialize fromItemContext: aGdsEditorContext atIndex: anIndex.
]

{ #category : #'as yet unclassified' }
GdsReferenceElement class >> isReference [
	^true
]

{ #category : #visiting }
GdsReferenceElement >> accept: aVisitor [
	^ aVisitor visitReferenceElement: self
]

{ #category : #accessing }
GdsReferenceElement >> angle [
	^strans angle
]

{ #category : #accessing }
GdsReferenceElement >> angle: aDegees [
	strans angle: aDegees.
	self refreshBounds.	
]

{ #category : #copying }
GdsReferenceElement >> copyTransform [
	strans := strans copy.

]

{ #category : #accessing }
GdsReferenceElement >> dataOutlinePoints [
	^self lookupExtentPoints
]

{ #category : #initialization }
GdsReferenceElement >> fromItemContext: aGdsItemContext [
	self fromItemContext: aGdsItemContext atIndex: 1.
	 	

]

{ #category : #initialization }
GdsReferenceElement >> fromItemContext: aGdsItemContext atIndex: aVerticesIndex [
	| location |
	self assert: aGdsItemContext structureName isNotEmpty.
	location := aGdsItemContext vertices at: aVerticesIndex.
	self xy: location.
	self angle: aGdsItemContext angle.
	self mag: aGdsItemContext mag.
	self setReflected: aGdsItemContext isReflected.
	self statusNumber: aGdsItemContext number
]

{ #category : #initialization }
GdsReferenceElement >> initialize [
	super initialize.
	strans := GdsStructureTransform new.
	
]

{ #category : #testing }
GdsReferenceElement >> isPureTranslation [
	^self transform isPureTranslation
]

{ #category : #testing }
GdsReferenceElement >> isReflected [
	^strans isReflected
]

{ #category : #protected }
GdsReferenceElement >> lookupExtentPoints [
	^ #()
]

{ #category : #accessing }
GdsReferenceElement >> mag [
	^strans mag
]

{ #category : #accessing }
GdsReferenceElement >> mag: aFactor [
	strans mag: aFactor.
	self refreshBounds.	
]

{ #category : #accessing }
GdsReferenceElement >> moveRelative: aPoint from: aOtherElement [
	| translatedPoint |
	translatedPoint := aOtherElement xy+ aPoint.
	self privateWipe.
	self xy: translatedPoint.
]

{ #category : #copying }
GdsReferenceElement >> postCopy [
	super postCopy. 
	self copyTransform.
	

]

{ #category : #testing }
GdsReferenceElement >> setReflected: aBoolean [
	strans setReflected: aBoolean.
	self refreshBounds.	
]

{ #category : #accessing }
GdsReferenceElement >> strans [
	^strans
]

{ #category : #accessing }
GdsReferenceElement >> transform [
	^strans asMatrix2x3
]

{ #category : #accessing }
GdsReferenceElement >> xy [
	^strans offset
]

{ #category : #accessing }
GdsReferenceElement >> xy: aPoint [
	self privateWipe.
	super xy: aPoint.
	strans offset: aPoint.
	self refreshBounds.
]
