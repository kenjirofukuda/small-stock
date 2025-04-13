"
A TGdsStructureDrawable is structure drawing shared protcol.

"
Trait {
	#name : #TGdsStructureDrawable,
	#category : 'GdsFeel-UI-Morph'
}

{ #category : #appearance }
TGdsStructureDrawable >> backgroundColor [

	^ self shouldBeImplemented
]

{ #category : #accessing }
TGdsStructureDrawable >> clipedElements [
	"Array of GdsElement"
	^ self shouldBeImplemented
]

{ #category : #drawing }
TGdsStructureDrawable >> colorForElement: aGdsElement [

	| fixPureWhite |
	fixPureWhite := [ :color | 
	                color = Color white
		                ifTrue: [ self visiblePenColor ]
		                ifFalse: [ color ] ].
	aGdsElement state = #inStructure ifTrue: [ 
		aGdsElement ownColor ifNotNil: [ :ownColor | 
			^ fixPureWhite value: ownColor ].
		aGdsElement hasLayer ifTrue: [ 
			^ self colorForLayer: aGdsElement layerNumber ] ].
	^ self visiblePenColor
]

{ #category : #drawing }
TGdsStructureDrawable >> colorForLayer: aLayerNumber [

	| usingColor |
	usingColor := (self structure layers atNumber: aLayerNumber) color.
	usingColor = Color white ifTrue: [ ^ self visiblePenColor ].
	usingColor = #white ifTrue: [ ^ self visiblePenColor ].
	^ usingColor
]

{ #category : #accessing }
TGdsStructureDrawable >> structure [
	"instance of GdsStructure"
	^ self shouldBeImplemented
]

{ #category : #drawing }
TGdsStructureDrawable >> visibleElements [

	^ self clipedElements select: [ :el | el isVisible ]
]

{ #category : #appearance }
TGdsStructureDrawable >> visibleGridColor [

	^ self backgroundColor luminance > 0.7
		  ifTrue: [ Color black ]
		  ifFalse: [ Color white ]
]

{ #category : #appearance }
TGdsStructureDrawable >> visibleLocationColor [

	| test |
	test := self backgroundColor luminance < 0.7.
	GdsFeelMorphic borderedSensorDisplay ifTrue: [ test := test not ].
	^ test
		  ifTrue: [ Color white ]
		  ifFalse: [ Color black ]
]

{ #category : #appearance }
TGdsStructureDrawable >> visibleMarkerColor [

	^ self visibleGridColor
]

{ #category : #appearance }
TGdsStructureDrawable >> visiblePenColor [

	^ self backgroundColor luminance > 0.7
		  ifTrue: [ Color black ]
		  ifFalse: [ Color lightGray ]
]

{ #category : #appearance }
TGdsStructureDrawable >> visiblePickingColor [

	^ self backgroundColor luminance > 0.7
		  ifTrue: [ Color darkGray ]
		  ifFalse: [ Color white ]
]
