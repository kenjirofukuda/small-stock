Class {
	#name : #GdsTracking,
	#superclass : #Object,
	#instVars : [
		'event',
		'currentEvent',
		'points'
	],
	#category : #'GdsFeel-UI-Morph'
}

{ #category : #accessing }
GdsTracking >> currentEvent: aMouseMoveEvent [ 
	currentEvent := aMouseMoveEvent.
	points add: currentEvent cursorPoint copy.
	self structureMorph fireFirstdrawing .
]

{ #category : #accessing }
GdsTracking >> currentWorldPoint [
	^ self viewport worldPointFromGlobal: currentEvent cursorPoint. 

]

{ #category : #accessing }
GdsTracking >> event [
	^ event
]

{ #category : #accessing }
GdsTracking >> event: aMouseButtonEvent [ 
	event := aMouseButtonEvent.
	points add: event cursorPoint copy.
]

{ #category : #initialization }
GdsTracking >> initialize [
	points := OrderedCollection new.
]

{ #category : #accessing }
GdsTracking >> localPixelPoint [
	^ self viewport morphicPointFromGlobal: event cursorPoint
]

{ #category : #private }
GdsTracking >> noDragAction [

	self structureMorph contextMenu
		ifNotNil: [ :menuBlock | menuBlock value: self ]
]

{ #category : #accessing }
GdsTracking >> offset [
	| p1 p2|
	p1 := self viewport worldPointFromGlobal: event cursorPoint. 
	p2 := self viewport worldPointFromGlobal: currentEvent cursorPoint. 
	^ p2 - p1.	
]

{ #category : #accessing }
GdsTracking >> offsetPixelPoint [
	^ (currentEvent cursorPoint - event cursorPoint)
]

{ #category : #'menu - deprecated' }
GdsTracking >> setupEditorMenu: aMenuGroupModel [
	self structureMorph idNotEmpty
		ifTrue: [ 
			self setupIdSelectionMenu: aMenuGroupModel ].

]

{ #category : #'menu - deprecated' }
GdsTracking >> setupIdSelectionMenu: aMenuGroupModel [
	aMenuGroupModel
		addItem: [ :item | 
			item
				name: 'Fit selection' translated;
				action: [ self structureMorph viewport
						viewBounds: event handler structure dataExtentForIdElements ] ].
	aMenuGroupModel
		addItem: [ :item | 
			item
				name: 'Clear selection' translated;
				action: [ self structureMorph structure idSelection idClear ] ].
	aMenuGroupModel
		addItem: [ :item | 
			item
				name: 'Inspect selection' translated;
				action: [ | elements |
					elements := self structureMorph structure idSelection elements.
					(elements size = 1
						ifTrue: [ elements first ]
						ifFalse: [ elements ]) inspect ] ].
	aMenuGroupModel addItem: [ :item | item name: '-' ].
	aMenuGroupModel
		addItem: [ :item | 
			item
				name: 'Delete' translated;
				action: [ self structureMorph structure idSelection idDelete ] ]
]

{ #category : #'menu - deprecated' }
GdsTracking >> setupMenu: aMenuGroupModel [
	self structureMorph class = GdsStructureEditorMorph 
		ifTrue: [ self setupEditorMenu: aMenuGroupModel ].
	aMenuGroupModel
		addItem: [ :item | 
			item
				name: 'Clear markers';
				action: [ self structureMorph clearMarker] ].
	aMenuGroupModel
		addItem: [ :item | 
			item
				name: 'Fit';
				shortcut: $f command;
				action: [ self viewport viewFit ] ].			
]

{ #category : #accessing }
GdsTracking >> startWorldPoint [
	^ self viewport worldPointFromGlobal: event cursorPoint. 

]

{ #category : #accessing }
GdsTracking >> structureMorph [
	^ event handler
]

{ #category : #'event handler' }
GdsTracking >> trackEnd [
	points size = 1
		ifTrue: [ self noDragAction ]
]

{ #category : #'event handler' }
GdsTracking >> viewMove [
	| p1 p2 lp1 lp2 |
	points size < 2 ifTrue: [ ^ self ].
	lp1 := points at: (points size - 1).
	lp2 := points last.
	p2 := self viewport worldPointFromGlobal: lp2.
	p1 := self viewport worldPointFromGlobal: lp1.
	self viewMoveFrom: p1 to: p2. 
]

{ #category : #private }
GdsTracking >> viewMoveFrom: aPoint1 to: aPoint2 [
	self viewport viewCenter: (self viewport viewCenter - (aPoint2 - aPoint1)) .

]

{ #category : #private }
GdsTracking >> viewport [
	^ self structureMorph viewport

]
