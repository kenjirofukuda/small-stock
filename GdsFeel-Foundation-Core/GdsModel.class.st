Class {
	#name : #GdsModel,
	#superclass : #Model,
	#traits : 'TGdsPropertyFactory + TGdsModel + TGdsPropertiesOwner',
	#classTraits : 'TGdsPropertyFactory classTrait + TGdsModel classTrait + TGdsPropertiesOwner classTrait',
	#instVars : [
		'announcer',
		'properties'
	],
	#category : #'GdsFeel-Foundation-Core'
}

{ #category : #accessing }
GdsModel >> announcer [
	^announcer ifNil: [ announcer := Announcer new.]
]

{ #category : #private }
GdsModel >> properties [
	^ properties ifNil: [ properties := IdentityDictionary new ]
	
]
