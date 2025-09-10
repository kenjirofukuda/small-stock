Class {
	#name : #GdaKind,
	#superclass : #GdsState,
	#instVars : [
		'key',
		'description'
	],
	#category : #'GdsFeel-Model2-Container'
}

{ #category : #initalize }
GdaKind >> initWithKey: aKey description: aDescription [
	self initialize.
	key := aKey.
	description := aDescription.
	
]

{ #category : #accessing }
GdaKind >> key [
	^key asString asUppercase.
]

{ #category : #keyboard }
GdaKind >> keyString [
	^ key asString asUppercase.
]

{ #category : #accessing }
GdaKind >> longDescription [
	^description
]

{ #category : #printing }
GdaKind >> printOn: aStream [
	super printOn: aStream.
	aStream nextPut: $(.
	aStream nextPutAll: self keyString.	
	aStream nextPut: $).
	
]
