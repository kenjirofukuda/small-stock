Class {
	#name : #GdsStateSpecView,
	#superclass : #ComposableModel,
	#instVars : [
		'labelModel',
		'visibleModel',
		'selectableModel',
		'model'
	],
	#category : #'GdsFeel-UI-Spec'
}

{ #category : #initialization }
GdsStateSpecView >> activateNewState: newState [
	self enabledModels.
	selectableModel state: newState isSelectable.
	visibleModel state: newState isVisible.
	selectableModel whenChangedDo: [ :newBoolean | newState setSelectable: newBoolean ].
	visibleModel whenChangedDo: [ :newBoolean | newState setVisible: newBoolean ].
	newState selectableProperty whenChangedDo: [ :newBoolean | selectableModel state: newBoolean ].
	newState visibleProperty whenChangedDo: [ :newBoolean | visibleModel state: newBoolean ]
]

{ #category : #initialization }
GdsStateSpecView >> disableModels [
	labelModel enabled: false.
	selectableModel enabled: false.
	visibleModel enabled: false
]

{ #category : #initialization }
GdsStateSpecView >> enabledModels [
	labelModel enabled: true.
	selectableModel enabled: true.
	visibleModel enabled: true
]

{ #category : #initialization }
GdsStateSpecView >> initializePresenter [
	self initializePresenterForState: self stateProperty.
]

{ #category : #initialization }
GdsStateSpecView >> initializePresenterForState: aGdsState [
	aGdsState
		whenChangedDo: [ :newState | newState 
			ifNil: [ self disableModels ] 
			ifNotNil: [ self activateNewState: newState ] ]
]

{ #category : #'as yet unclassified' }
GdsStateSpecView >> initializeWidgets [
	labelModel := self newLabel.
	visibleModel := self newCheckBox.
	selectableModel := self newCheckBox.
	labelModel label: ''.
	visibleModel label: ''.
	selectableModel label: ''.

	model := nil asValueHolder.
	
	
]

{ #category : #accessing }
GdsStateSpecView >> labelModel [
	^ labelModel
]

{ #category : #'as yet unclassified' }
GdsStateSpecView >> model [
	^ model value
]

{ #category : #'as yet unclassified' }
GdsStateSpecView >> model: aGdsState [
	^ model value: aGdsState
]

{ #category : #accessing }
GdsStateSpecView >> selectableModel [
	^ selectableModel
]

{ #category : #accessing }
GdsStateSpecView >> stateProperty [
	^ model
]

{ #category : #accessing }
GdsStateSpecView >> visibleModel [
	^ visibleModel
]
