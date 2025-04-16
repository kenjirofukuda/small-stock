Class {
	#name : #GdsStateMorph,
	#superclass : #MophicModel,
	#instVars : [
		'labelMorph'
	],
	#category : 'GdsFeel-UI-Morph'
}

{ #category : #'as yet unclassified' }
GdsStateMorph >> addLabelMorph [
	| cellSize |
	cellSize := 16.
	labelMorph := StringMorph new
		contents: '--';
		extent: cellSize asPoint;
		yourself.
	"GdsToolsBuilder changeControlCaptionFont: labelMorph."
	self addMorphBack: labelMorph.

]

{ #category : #'as yet unclassified' }
GdsStateMorph >> addStateCheckBoxes [
	| outerMorph button |
	outerMorph := self newOuterMorph.
	button := self visibleCheckbox.
	outerMorph addMorphBack: button.	
	self usingSelectable
		ifTrue: [
			button := self selectableCheckbox.
			outerMorph addMorphBack: button].	
	self addMorphBack: outerMorph
]

{ #category : #'as yet unclassified' }
GdsStateMorph >> bold: aBoolean [
	labelMorph emphasis:  (aBoolean ifTrue: [2] ifFalse: [0])
]

{ #category : #accessing }
GdsStateMorph >> defaultBorderColor [
	"answer the default border color/fill style for the receiver"
	^ Color black
]

{ #category : #accessing }
GdsStateMorph >> fontUseButtonFont [
	(self findDeeplyA: StringMorph)
		ifNotNil: [ :morph | morph font: StandardFonts buttonFont]
]

{ #category : #'as yet unclassified' }
GdsStateMorph >> initialize [
	super initialize.
	self changeTableLayout.
	self listDirection: #leftToRight.
	self hResizing: #spaceFill.
	self vResizing: #shrinkWrap.	
	self borderWidth: 1.	
	self color: Color white.
]

{ #category : #'as yet unclassified' }
GdsStateMorph >> labelString [
	^model asString.
]

{ #category : #'as yet unclassified' }
GdsStateMorph >> newOuterMorph [
	| outerMorph |
	outerMorph := AlignmentMorph newRow.
	outerMorph hResizing: #shrinkWrap.
	outerMorph vResizing: #shrinkWrap.	
	outerMorph color: Color white.
	^outerMorph

]

{ #category : #'as yet unclassified' }
GdsStateMorph >> newSelectableCheckbox [
	^self theme 
		newCheckboxIn: self 
		for: self 
		getSelected: #selectableValue 
		setSelected: #selectableValue: 
		getEnabled: nil 
		label: ''
		help: nil
]

{ #category : #'as yet unclassified' }
GdsStateMorph >> newVisibleCheckbox [
	^self theme 
		newCheckboxIn: self 
		for: self 
		getSelected: #visibleValue 
		setSelected: #visibleValue: 
		getEnabled: nil 
		label: ''
		help: nil
]

{ #category : #'as yet unclassified' }
GdsStateMorph >> selectableCheckbox [
	^ self newSelectableCheckbox
]

{ #category : #'as yet unclassified' }
GdsStateMorph >> selectableValue [
	model ifNil: [^false].
	^model isSelectable.
	
]

{ #category : #'as yet unclassified' }
GdsStateMorph >> selectableValue: aBoolean [
	model ifNil: [^self].
	model setSelectable: aBoolean.
	self changed: self updateSelector.
]

{ #category : #'as yet unclassified' }
GdsStateMorph >> toggleSelectableValue [
	model ifNil: [^self].
	model setSelectable: model isSelectable not.
	self changed: self updateSelector.
]

{ #category : #'as yet unclassified' }
GdsStateMorph >> toggleVisibleValue [
	model ifNil: [^self].
	model setVisible: model isVisible not.
	self changed: self updateSelector.
]

{ #category : #'as yet unclassified' }
GdsStateMorph >> update [
	model ifNil: [ ^ self ].
	labelMorph contents: self labelString.
	self fontUseButtonFont.
	self changed: #visibleValue.
	self changed: #selectableValue
]

{ #category : #'as yet unclassified' }
GdsStateMorph >> updateSelector [
	^self subclassResponsibility.
]

{ #category : #'as yet unclassified' }
GdsStateMorph >> usingSelectable [
	^false
]

{ #category : #'as yet unclassified' }
GdsStateMorph >> visibleCheckbox [
	^ self newVisibleCheckbox
]

{ #category : #'as yet unclassified' }
GdsStateMorph >> visibleValue [
	model ifNil: [^false].
	^model isVisible.
	
]

{ #category : #'as yet unclassified' }
GdsStateMorph >> visibleValue: aBoolean [
	model ifNil: [^self].
	model setVisible: aBoolean.
	self changed: self updateSelector.
]
