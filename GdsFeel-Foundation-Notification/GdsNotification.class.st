Class {
	#name : #GdsNotification,
	#superclass : #Object,
	#instVars : [
		'name',
		'object',
		'userInfo'
	],
	#category : #'GdsFeel-Foundation-Notification'
}

{ #category : #'as yet unclassified' }
GdsNotification class >> notificationWithName: aName object: anObject userInfo: aDictionary [
	^self new name: aName object: anObject userInfo: aDictionary. 
]

{ #category : #'as yet unclassified' }
GdsNotification >> name [
	^name
	
]

{ #category : #'as yet unclassified' }
GdsNotification >> name: aName object: anObject [
	self name: aName object:  anObject userInfo: nil.
]

{ #category : #'as yet unclassified' }
GdsNotification >> name: aName object: anObject userInfo: aDictionary [
	aDictionary
		ifNotNil: [self assert: (aDictionary isKindOf: Dictionary)].
	name := aName.
	object := anObject.
	userInfo := aDictionary.
]

{ #category : #'as yet unclassified' }
GdsNotification >> object [
	^object
	
]

{ #category : #'as yet unclassified' }
GdsNotification >> printOn: aStream [
	super printOn: aStream.
	aStream nextPutAll: '('.
	name printOn: aStream.
	aStream nextPutAll: ','.
	object printOn: aStream.
	aStream nextPutAll: ','.
	userInfo printOn: aStream.
	aStream nextPutAll: ')'.	
]

{ #category : #'as yet unclassified' }
GdsNotification >> userInfo [
	^userInfo
	
]
