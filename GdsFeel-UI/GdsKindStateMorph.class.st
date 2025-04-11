Class {
	#name : 'GdsKindStateMorph',
	#superclass : 'GdsStateMorph',
	#category : 'GdsFeel-UI-Morph',
	#package : 'GdsFeel-UI',
	#tag : 'Morph'
}

{ #category : 'initialization' }
GdsKindStateMorph >> initialize [
	super initialize.
	self addLabelMorph.
	self addStateCheckBoxes.
]

{ #category : 'as yet unclassified' }
GdsKindStateMorph >> kind: aGdsKind [
	super model: aGdsKind.
	labelMorph setBalloonText: aGdsKind longDescription.
	aGdsKind visibleProperty whenChangedDo: [  ].
	aGdsKind selectableProperty whenChangedDo: [  ].
	self update.
]

{ #category : 'as yet unclassified' }
GdsKindStateMorph >> labelString [
	^ model key asString padLeftTo: 3.
		
]

{ #category : 'as yet unclassified' }
GdsKindStateMorph >> updateSelector [
	^#kindState.
]
