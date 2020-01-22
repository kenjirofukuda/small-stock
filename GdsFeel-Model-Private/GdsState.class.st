"
Abstract class for Kind and Layer
"
Class {
	#name : #GdsState,
	#superclass : #Model,
	#traits : 'TGdsExchange + TGdsPropertiesOwner',
	#classTraits : 'TGdsExchange classTrait + TGdsPropertiesOwner classTrait',
	#instVars : [
		'selectable',
		'visible',
		'properties'
	],
	#category : #'GdsFeel-Model-Private'
}

{ #category : #'objects from disk' }
GdsState >> attributesFrom: aDictionary [
	self setSelectable: (aDictionary at: 'selectable' ifAbsent: ['true']) = 'true'.  
	self setVisible: (aDictionary at: 'visible' ifAbsent: ['true']) = 'true'.  
]

{ #category : #'xml/json data exchange' }
GdsState >> attributesOn: aDictionary [
	self isSelectable
		ifFalse: [
			aDictionary at: 'selectable' put: self isSelectable].
	self isVisible 
		ifFalse: [	
			aDictionary at: 'visible' put: self isVisible].
]

{ #category : #initialization }
GdsState >> initialize [
	super initialize.
	selectable := true asValueHolder.
	visible := true asValueHolder.
	
]

{ #category : #testing }
GdsState >> isSelectable [
	^ selectable value
	
]

{ #category : #testing }
GdsState >> isVisible [
	^ visible value
	
]

{ #category : #'xml/json data exchange' }
GdsState >> jsonOn: aStream [
	| map |
	map := Dictionary new.
	self attributesOn: map.
	self jsonElementsOn: map.
	map jsonOn: aStream.
	
]

{ #category : #private }
GdsState >> properties [
	^ properties ifNil: [ properties := IdentityDictionary new ]
]

{ #category : #'api-valueHolder' }
GdsState >> selectableProperty [
	^ selectable
	
	
]

{ #category : #testing }
GdsState >> setSelectable: aBoolean [
	selectable value:  aBoolean.
	
	
]

{ #category : #testing }
GdsState >> setVisible: aBoolean [
	visible value: aBoolean.
	
	
]

{ #category : #accessing }
GdsState >> stateLetter [
	(self isVisible and: [self isSelectable]) ifTrue: [^$@].
	(self isVisible) ifTrue: [^$O].	
	(self isSelectable) ifTrue: [^$+].
	^$-.
			
]

{ #category : #'api-valueHolder' }
GdsState >> visibleProperty [
	^ visible
	
	
]
