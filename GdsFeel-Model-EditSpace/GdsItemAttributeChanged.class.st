Class {
	#name : #GdsItemAttributeChanged,
	#superclass : #Announcement,
	#instVars : [
		'item',
		'attribute',
		'oldValue',
		'newValue'
	],
	#category : #'GdsFeel-Model-EditSpace'
}

{ #category : #'as yet unclassified' }
GdsItemAttributeChanged class >> from: anObject1 to: anObject2 [
	^ self new 
		oldValue: anObject1; 
		newValue: anObject2;
		yourself. 
]

{ #category : #accessing }
GdsItemAttributeChanged >> attribute [
	^attribute
	
]

{ #category : #accessing }
GdsItemAttributeChanged >> attribute: aSymbol [
	attribute := aSymbol.
	
]

{ #category : #accessing }
GdsItemAttributeChanged >> item [
	^item
	
]

{ #category : #accessing }
GdsItemAttributeChanged >> item: anGdsItemContext [
	item := anGdsItemContext.
	
]

{ #category : #accessing }
GdsItemAttributeChanged >> newValue [
	^newValue
]

{ #category : #accessing }
GdsItemAttributeChanged >> newValue: anObject [
	newValue := anObject.
]

{ #category : #accessing }
GdsItemAttributeChanged >> oldValue [
	^oldValue
]

{ #category : #accessing }
GdsItemAttributeChanged >> oldValue: anObject [
	oldValue := anObject.
]

{ #category : #printing }
GdsItemAttributeChanged >> printOn: aStream [
	super printOn: aStream.
	aStream nextPut: $(.
	self item printOn: aStream.
	aStream nextPut: $,.
	aStream nextPutAll: attribute printString.
	self oldValue
		ifNotNil: [
			aStream nextPut: $,.
			aStream nextPutAll: 'from: '.
			aStream nextPutAll: self oldValue printString].
	self newValue
		ifNotNil: [
			aStream nextPut: $,.
			aStream nextPutAll: 'to: '.
			aStream nextPutAll: self newValue printString].
	aStream nextPut: $).
	
]
