Class {
	#name : #GdsAcPointDrawer,
	#superclass : #GdsPrimitiveDrawer,
	#category : #'GdsFeel-UI-ElementAddition'
}

{ #category : #testing }
GdsAcPointDrawer >> canDisplayPoint [
	^ self canDisplayKindForKey: 'PT'
]

{ #category : #testing }
GdsAcPointDrawer >> canDisplayPointLocation [
	^ self canDisplayKindForKey: 'PL'
]

{ #category : #drawing }
GdsAcPointDrawer >> drawPointLocationOn: aCanvas [
	| text center |
	center := self element centerPoint.
	text := '(<1s>, <2s>)' expandMacrosWith: center x asString with: center y asString.
	morph drawOn: aCanvas text: text asString at: center.
]

{ #category : #drawing }
GdsAcPointDrawer >> fillOutlineOn: aCanvas [ 
]

{ #category : #testing }
GdsAcPointDrawer >> isDrawable [
	^ true
]

{ #category : #drawing }
GdsAcPointDrawer >> optionalDrawOn: aCanvas [
	super optionalDrawOn: aCanvas.
	self canDisplayPointLocation
		ifTrue: [self drawPointLocationOn: aCanvas].
]

{ #category : #drawing }
GdsAcPointDrawer >> strokeOutlineOn: aCanvas [
	self canDisplayPoint ifFalse: [ ^ self ].
	morph drawOn: aCanvas centerCrossAt: element centerPoint pixelUnit: 3 width: 1.
]
