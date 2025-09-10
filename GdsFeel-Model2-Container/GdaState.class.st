Class {
	#name : #GdaState,
	#superclass : #Model,
	#instVars : [
		'selectable',
		'visible',
		'properties'
	],
	#category : #'GdsFeel-Model2-Container'
}

{ #category : #initialization }
GdaState >> initialize [

	super initialize.
	selectable := true.
	visible := true
]

{ #category : #testing }
GdaState >> isSelectable [
	^ selectable
	
]

{ #category : #testing }
GdaState >> isVisible [
	^ visible
	
]

{ #category : #private }
GdaState >> properties [
	^ properties ifNil: [ properties := IdentityDictionary new ]
]

{ #category : #testing }
GdaState >> setSelectable: aBoolean [
	selectable := aBoolean
	
	
]

{ #category : #testing }
GdaState >> setVisible: aBoolean [
	visible := aBoolean
	
	
]

{ #category : #accessing }
GdaState >> stateLetter [

	(self isVisible and: [ self isSelectable ]) ifTrue: [ ^ $@ ].
	self isVisible ifTrue: [ ^ $O ].
	self isSelectable ifTrue: [ ^ $+ ].
	^ $-
]
