Class {
	#name : 'GdsKindSpecView',
	#superclass : 'GdsStateSpecView',
	#category : 'GdsFeel-UI-Spec',
	#package : 'GdsFeel-UI-Spec'
}

{ #category : 'specs' }
GdsKindSpecView class >> defaultSpec [
	<spec: #default>
	^ SpecLayout composed
		newRow: [:r |
			r add: #labelModel.
			r add: #visibleModel.
			r add: #selectableModel.
			];
		yourself
]

{ #category : 'specs' }
GdsKindSpecView class >> example [
	| kind |
	kind := GdsKind new initWithKey: 'PT' description: 'Point'. 
	self new kind: kind; openWithSpec.
	kind explore.
]

{ #category : 'initialization' }
GdsKindSpecView >> activateNewState: newState [
	labelModel label: newState keyString.
	super activateNewState: newState.
]

{ #category : 'initialization' }
GdsKindSpecView >> initializeWidgets [
	super initializeWidgets.

]

{ #category : 'accessing' }
GdsKindSpecView >> kind [
	^ self model
]

{ #category : 'accessing' }
GdsKindSpecView >> kind: aGdsKind [
	self model: aGdsKind
]
