Class {
	#name : #GdsLayerSpecView,
	#superclass : #GdsStateSpecView,
	#instVars : [
		'colorChooserMorph',
		'layerNumberModel'
	],
	#category : #'GdsFeel-UI-Spec'
}

{ #category : #'as yet unclassified' }
GdsLayerSpecView class >> defaultSpec [
	<spec: #default>
	^ SpecLayout composed
		newRow: [:r |
			r add: #visibleModel width: 16.
			r add: #selectableModel width: 16.
			r add: #layerNumberModel width: 26.
			r add: #colorChooser width: 60.
			r add: #labelModel.
			];
		yourself
]

{ #category : #'as yet unclassified' }
GdsLayerSpecView class >> example [
	| layer |
	layer := GdsLayer new name: 'Hage'; layerNumber: 1; color: Color blue; yourself. 
	self new layer: layer; openWithSpec.
	"layer explore."
]

{ #category : #initialization }
GdsLayerSpecView >> activateNewState: newState [
	layerNumberModel label: (newState layerNumber asString padLeftTo: 2).
	
	labelModel label: newState name.
	self color: newState color.

	"model to view"	
	newState colorProperty whenChangedDo: [ :newColor | self color: newColor ].
	super activateNewState: newState.
	colorChooserMorph changed.
]

{ #category : #accessing }
GdsLayerSpecView >> color [
	self layer ifNil: [^ self missingColor].
	^ self layer color
]

{ #category : #accessing }
GdsLayerSpecView >> color: aColor [
	| newColor |
	self layer ifNil: [^ self].
	newColor := self perfectWhiteAllowed 
		ifTrue: [aColor] ifFalse: [aColor = Color white ifTrue: [self missingColor ] ifFalse: [aColor]].
	self layer color: newColor.
	colorChooserMorph submorphsDo: [ :each | each updateColor ] .
	
]

{ #category : #'as yet unclassified' }
GdsLayerSpecView >> colorChooser [
	^ colorChooserMorph asSpecAdapter.
]

{ #category : #initialization }
GdsLayerSpecView >> initializeWidgets [
	| swatch |
	super initializeWidgets.
	layerNumberModel := self newLabel.
	colorChooserMorph := BorderedMorph new 
	"	borderWidth: 1;
		borderColor: Color red;"
		changeTableLayout;
		hResizing: #spaceFill; 
		vResizing: #shrinkWrap; 
		clipSubmorphs: true;
		"color: Color blue ;"
		yourself .
	swatch := (colorChooserMorph theme 
		newColorChooserIn: colorChooserMorph
		for: self
		getColor: #color
		setColor: #color:
		getEnabled: nil 
		help: 'click here to change the color' translated) 
			minWidth: 16; width: 16;
			minHeight: 16; height: 16; yourself.
	colorChooserMorph addMorphCentered: swatch .
]

{ #category : #accessing }
GdsLayerSpecView >> layer [
	^ self model
]

{ #category : #accessing }
GdsLayerSpecView >> layer: aGdsLayer [
	self model: aGdsLayer.
]

{ #category : #accessing }
GdsLayerSpecView >> layerNumberModel [
	^ layerNumberModel
]

{ #category : #'as yet unclassified' }
GdsLayerSpecView >> missingColor [
	^ Color lightGray.
]

{ #category : #testing }
GdsLayerSpecView >> perfectWhiteAllowed [
	^ false
]
