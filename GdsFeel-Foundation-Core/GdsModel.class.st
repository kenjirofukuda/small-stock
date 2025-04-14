Class {
	#name : #GdsModel,
	#superclass : #Model,
	#traits : 'TGdsPropertyFactory + TGdsModel + TGdsPropertiesOwner',
	#classTraits : 'TGdsPropertyFactory classTrait + TGdsModel classTrait + TGdsPropertiesOwner classTrait',
	#instVars : [
		'properties',
		'announcer2'
	],
	#category : #'GdsFeel-Foundation-Core'
}

{ #category : #accessing }
GdsModel >> announcer [
	"Answer the announcer of the receiver."
	[ self instVarNamed: #announcer ]
		on: Error
		do: [ :ex | ^ announcer2 ifNil: [ announcer2 := Announcer new ] ].
	^ super announcer
]

{ #category : #testing }
GdsModel >> isElement [
	^ false
]

{ #category : #testing }
GdsModel >> isLibrary [
	^ false
]

{ #category : #testing }
GdsModel >> isStation [
	^ false
]

{ #category : #testing }
GdsModel >> isStructure [
	^ false
]

{ #category : #private }
GdsModel >> properties [
	^ properties ifNil: [ properties := IdentityDictionary new ]
	
]
