Class {
	#name : 'GdsPropertyChanged',
	#superclass : 'Announcement',
	#instVars : [
		'oldValue',
		'property',
		'newValue'
	],
	#category : 'GdsFeel-Foundation-Property',
	#package : 'GdsFeel-Foundation-Property'
}

{ #category : 'as yet unclassified' }
GdsPropertyChanged class >> from: anObject1 to: anObject2 [
	^self new oldValue: anObject1; newValue: anObject2. 
]

{ #category : 'accessing' }
GdsPropertyChanged >> newValue [
	^newValue
]

{ #category : 'accessing' }
GdsPropertyChanged >> newValue: anObject [
	newValue := anObject.
]

{ #category : 'accessing' }
GdsPropertyChanged >> oldValue [
	^oldValue
]

{ #category : 'accessing' }
GdsPropertyChanged >> oldValue: anObject [
	oldValue := anObject.
]

{ #category : 'printing' }
GdsPropertyChanged >> printOn: aStream [
	super printOn: aStream.
	aStream nextPut: $(.
	aStream nextPutAll: property propertyName.
	self newValue
		ifNotNil: [
			aStream nextPut: $,.
			aStream nextPutAll: 'to: '.
			aStream nextPutAll: self newValue printString].
	self oldValue
		ifNotNil: [
			aStream nextPut: $,.
			aStream nextPutAll: 'from: '.
			aStream nextPutAll: self oldValue printString].
	aStream nextPut: $).
	
]

{ #category : 'accessing' }
GdsPropertyChanged >> property [
	^property
	
	
]

{ #category : 'accessing' }
GdsPropertyChanged >> property: aGdsPropertySlot [
	property := aGdsPropertySlot.
	
	
]

{ #category : 'accessing' }
GdsPropertyChanged >> propertyName [
	^self property propertyName
	
	
]
