Class {
	#name : #GdsProperty,
	#superclass : #Object,
	#instVars : [
		'owner',
		'valueHolder',
		'name'
	],
	#category : #'GdsFeel-Foundation-Notification'
}

{ #category : #'as yet unclassified' }
GdsProperty class >> autoNotificationNameBy: aClass propertyName: aPropertyName [
	^String streamContents: [:s |
		s nextPutAll: aClass asString.
		s nextPutAll: aPropertyName capitalized.
		s nextPutAll: 'DidChangeNotification'.
	]
]

{ #category : #'as yet unclassified' }
GdsProperty class >> name: aPropertySymbol owner: anObject [
	^self new initWithName: aPropertySymbol owner: anObject
]

{ #category : #'as yet unclassified' }
GdsProperty >> autoNotificationNameBy: anObject propertyName: aPropertyName [
	^GdsProperty autoNotificationNameBy: anObject class  propertyName: #width
]

{ #category : #'as yet unclassified' }
GdsProperty >> getValue [
	^valueHolder
]

{ #category : #'as yet unclassified' }
GdsProperty >> initWithName: aPropertySymbol owner: anObject [
	name := aPropertySymbol asSymbol.
	owner := anObject.
	
]

{ #category : #'as yet unclassified' }
GdsProperty >> owner: anObject [
	owner := anObject
]

{ #category : #'as yet unclassified' }
GdsProperty >> postNotificationProperty: aPropertyName oldValue: aOldValue newValue: aNewValue [
	aOldValue = aNewValue ifTrue: [^self].
	GdsNotificationCenter defaultCenter 
		postNotificationName: (self autoNotificationNameBy: owner propertyName: aPropertyName)
		object:  owner
		userInfo: (Dictionary newFrom: {#oldValue->aOldValue . #newValue->aNewValue})
]

{ #category : #'as yet unclassified' }
GdsProperty >> printOn: aStream [
	aStream nextPutAll: name asString.
	aStream nextPutAll: ': '.
	aStream nextPutAll: valueHolder printString.
	
]

{ #category : #'as yet unclassified' }
GdsProperty >> setValue: anObject [
	| oldValue |
	oldValue := valueHolder.
	valueHolder := anObject.
	oldValue = anObject ifTrue: [^self].
	self postNotificationProperty: name oldValue: oldValue newValue: valueHolder
]
