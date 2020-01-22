Class {
	#name : #GdsKind,
	#superclass : #GdsState,
	#instVars : [
		'key',
		'description'
	],
	#category : #'GdsFeel-Model-Private'
}

{ #category : #initalize }
GdsKind >> initWithKey: aKey description: aDescription [
	self initialize.
	key := aKey.
	description := aDescription.
	
]

{ #category : #accessing }
GdsKind >> key [
	^key asString asUppercase.
]

{ #category : #keyboard }
GdsKind >> keyString [
	^ key asString asUppercase.
]

{ #category : #accessing }
GdsKind >> longDescription [
	^description
]

{ #category : #printing }
GdsKind >> printOn: aStream [
	super printOn: aStream.
	aStream nextPut: $(.
	aStream nextPutAll: self keyString.	
	aStream nextPut: $).
	
]
