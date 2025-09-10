Class {
	#name : #GdaState,
	#superclass : #Model,
	#traits : 'TGdsExchange + TGdsPropertiesOwner',
	#classTraits : 'TGdsExchange classTrait + TGdsPropertiesOwner classTrait',
	#instVars : [
		'selectable',
		'visible',
		'properties'
	],
	#category : #'GdsFeel-Model2-Container'
}

{ #category : #'objects from disk' }
GdaState >> attributesFrom: aDictionary [
	self setSelectable: (aDictionary at: 'selectable' ifAbsent: ['true']) = 'true'.  
	self setVisible: (aDictionary at: 'visible' ifAbsent: ['true']) = 'true'.  
]

{ #category : #'xml/json data exchange' }
GdaState >> attributesOn: aDictionary [
	self isSelectable
		ifFalse: [
			aDictionary at: 'selectable' put: self isSelectable].
	self isVisible 
		ifFalse: [	
			aDictionary at: 'visible' put: self isVisible].
]

{ #category : #initialization }
GdaState >> initialize [
	super initialize.
	selectable := true asValueHolder.
	visible := true asValueHolder.
	
]

{ #category : #testing }
GdaState >> isSelectable [
	^ selectable value
	
]

{ #category : #testing }
GdaState >> isVisible [
	^ visible value
	
]

{ #category : #'xml/json data exchange' }
GdaState >> jsonOn: aStream [
	| map |
	map := Dictionary new.
	self attributesOn: map.
	self jsonElementsOn: map.
	map jsonOn: aStream.
	
]

{ #category : #private }
GdaState >> properties [
	^ properties ifNil: [ properties := IdentityDictionary new ]
]

{ #category : #'api-valueHolder' }
GdaState >> selectableProperty [
	^ selectable
	
	
]

{ #category : #testing }
GdaState >> setSelectable: aBoolean [
	selectable value:  aBoolean.
	
	
]

{ #category : #testing }
GdaState >> setVisible: aBoolean [
	visible value: aBoolean.
	
	
]

{ #category : #accessing }
GdaState >> stateLetter [
	(self isVisible and: [self isSelectable]) ifTrue: [^$@].
	(self isVisible) ifTrue: [^$O].	
	(self isSelectable) ifTrue: [^$+].
	^$-.
			
]

{ #category : #'api-valueHolder' }
GdaState >> visibleProperty [
	^ visible
	
	
]
