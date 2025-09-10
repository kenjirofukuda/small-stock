Class {
	#name : #GdsLayerStateMorph,
	#superclass : #GdsStateMorph,
	#category : #'GdsFeel-UI-Morph'
}

{ #category : #'as yet unclassified' }
GdsLayerStateMorph >> colorSwatch [

	^ (self theme
		   newColorChooserIn: self
		   for: self
		   getColor: #colorValue
		   setColor: #colorValue:
		   getEnabled: nil
		   help: 'click here to change the color' translated)
		  minWidth: 16;
		  width: 16;
		  minHeight: 16;
		  height: 16;
		  yourself
]

{ #category : #accessing }
GdsLayerStateMorph >> colorValue [

	model ifNil: [ ^ self missingColor ].
	^ model color
]

{ #category : #accessing }
GdsLayerStateMorph >> colorValue: aColor [

	| newColor |
	model ifNil: [ ^ self ].
	model color = aColor ifTrue: [ ^ self ].
	newColor := self perfectWhiteAllowed
		            ifTrue: [ aColor ]
		            ifFalse: [ 
			            aColor = Color white
				            ifTrue: [ self missingColor ]
				            ifFalse: [ aColor ] ].
	model color: newColor.
	self changed: self updateSelector
]

{ #category : #'as yet unclassified' }
GdsLayerStateMorph >> enabled [

	^ true
]

{ #category : #'as yet unclassified' }
GdsLayerStateMorph >> initialize [

	super initialize.
	self addLabelMorph.
	self addStateCheckBoxes.
	self addMorphBack: self colorSwatch
]

{ #category : #'as yet unclassified' }
GdsLayerStateMorph >> labelString [

	^ model layerNumber asString padLeftTo: 3
]

{ #category : #'as yet unclassified' }
GdsLayerStateMorph >> layer: aGdsLayer [

	super model: aGdsLayer.
	self changed: #colorValue.
	self update
]

{ #category : #'as yet unclassified' }
GdsLayerStateMorph >> missingColor [

	^ Color lightGray
]

{ #category : #testing }
GdsLayerStateMorph >> perfectWhiteAllowed [

	^ false
]

{ #category : #'as yet unclassified' }
GdsLayerStateMorph >> updateSelector [

	^ #layerState
]
