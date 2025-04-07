Class {
	#name : #GdsStatesSpecView,
	#superclass : #ComposablePresenter,
	#instVars : [
		'listModel',
		'viewMap',
		'model'
	],
	#category : #'GdsFeel-UI-Spec'
}

{ #category : #'as yet unclassified' }
GdsStatesSpecView class >> defaultSpec [
	<spec: #default>
	^ SpecLayout composed
		newRow: [:r |
			r add: #listModel.
			];
		yourself
]

{ #category : #'as yet unclassified' }
GdsStatesSpecView class >> open [
	self subclassResponsibility
]

{ #category : #initialization }
GdsStatesSpecView >> initializeWidgets [
	listModel := self newList.
	listModel displayBlock: [ :element | self viewForItem: element ].
	model := nil asValueHolder.
	model
		whenChangedDo: [ :newStates | 
			newStates
				ifNil: [ listModel items: #() ]
				ifNotNil: [ 
					listModel items: newStates all.
					 ] ]
]

{ #category : #accessing }
GdsStatesSpecView >> kinds: aGdsKinds [
	self subclassResponsibility
]

{ #category : #accessing }
GdsStatesSpecView >> listModel [
	^ listModel
]

{ #category : #accessing }
GdsStatesSpecView >> model [
	^ model value
]

{ #category : #accessing }
GdsStatesSpecView >> model: aGdsStatesModel [
	model value: aGdsStatesModel
]

{ #category : #'as yet unclassified' }
GdsStatesSpecView >> viewForItem: aGdsKind [
	self subclassResponsibility
]
