Class {
	#name : #GdaTracking,
	#superclass : #Object,
	#instVars : [
		'event',
		'currentEvent',
		'points'
	],
	#category : #'GdsFeel-UI2-Morph'
}

{ #category : #accessing }
GdaTracking >> currentEvent: aMouseMoveEvent [

	currentEvent := aMouseMoveEvent.
	points add: currentEvent cursorPoint copy.
	self structureMorph fireFirstdrawing
]

{ #category : #accessing }
GdaTracking >> currentWorldPoint [

	^ self viewport worldPointFromGlobal: currentEvent cursorPoint
]

{ #category : #accessing }
GdaTracking >> event [

	^ event
]

{ #category : #accessing }
GdaTracking >> event: aMouseButtonEvent [

	event := aMouseButtonEvent.
	points add: event cursorPoint copy
]

{ #category : #initialization }
GdaTracking >> initialize [

	points := OrderedCollection new
]

{ #category : #accessing }
GdaTracking >> localPixelPoint [

	^ self viewport morphicPointFromGlobal: event cursorPoint
]

{ #category : #private }
GdaTracking >> noDragAction [

	self structureMorph contextMenu ifNotNil: [ :menuBlock | 
		menuBlock value: self ]
]

{ #category : #accessing }
GdaTracking >> offset [

	| p1 p2 |
	p1 := self viewport worldPointFromGlobal: event cursorPoint.
	p2 := self viewport worldPointFromGlobal: currentEvent cursorPoint.
	^ p2 - p1
]

{ #category : #accessing }
GdaTracking >> offsetPixelPoint [

	^ currentEvent cursorPoint - event cursorPoint
]

{ #category : #'menu - deprecated' }
GdaTracking >> setupEditorMenu: aMenuGroupModel [

	self structureMorph idNotEmpty ifTrue: [ 
		self setupIdSelectionMenu: aMenuGroupModel ]
]

{ #category : #'menu - deprecated' }
GdaTracking >> setupIdSelectionMenu: aMenuGroupModel [

	aMenuGroupModel addItem: [ :item | 
		item
			name: 'Fit selection' translated;
			action: [ 
				self structureMorph viewport viewBounds:
						event handler structure dataExtentForIdElements ] ].
	aMenuGroupModel addItem: [ :item | 
		item
			name: 'Clear selection' translated;
			action: [ self structureMorph structure idSelection idClear ] ].
	aMenuGroupModel addItem: [ :item | 
		item
			name: 'Inspect selection' translated;
			action: [ 
				| elements |
				elements := self structureMorph structure idSelection elements.
				(elements size = 1
					 ifTrue: [ elements first ]
					 ifFalse: [ elements ]) inspect ] ].
	aMenuGroupModel addItem: [ :item | item name: '-' ].
	aMenuGroupModel addItem: [ :item | 
		item
			name: 'Delete' translated;
			action: [ self structureMorph structure idSelection idDelete ] ]
]

{ #category : #'menu - deprecated' }
GdaTracking >> setupMenu: aMenuGroupModel [

	self structureMorph class = GdsStructureEditorMorph ifTrue: [ 
		self setupEditorMenu: aMenuGroupModel ].
	aMenuGroupModel addItem: [ :item | 
		item
			name: 'Clear markers';
			action: [ self structureMorph clearMarker ] ].
	aMenuGroupModel addItem: [ :item | 
		item
			name: 'Fit';
			shortcut: $f command;
			action: [ self viewport viewFit ] ]
]

{ #category : #accessing }
GdaTracking >> startWorldPoint [

	^ self viewport worldPointFromGlobal: event cursorPoint
]

{ #category : #accessing }
GdaTracking >> structureMorph [

	^ event handler
]

{ #category : #'event handler' }
GdaTracking >> trackEnd [

	points size = 1 ifTrue: [ self noDragAction ]
]

{ #category : #'event handler' }
GdaTracking >> viewMove [

	| p1 p2 lp1 lp2 |
	points size < 2 ifTrue: [ ^ self ].
	lp1 := points at: points size - 1.
	lp2 := points last.
	p2 := self viewport worldPointFromGlobal: lp2.
	p1 := self viewport worldPointFromGlobal: lp1.
	self viewMoveFrom: p1 to: p2
]

{ #category : #private }
GdaTracking >> viewMoveFrom: aPoint1 to: aPoint2 [

	self viewport viewCenter:
		self viewport viewCenter - (aPoint2 - aPoint1)
]

{ #category : #private }
GdaTracking >> viewport [

	^ self structureMorph viewport
]
