"
A GplVariable is assigneable Variable in GDSII.

Instance Variables
	varName:		<String>

varName
	- unique name in GPL evaluter memory space.
	- regex: '^[A-Z$][A-Z0-9$_]*$' max 32byte

"
Class {
	#name : #GplVariable,
	#superclass : #GdsDataStructure,
	#instVars : [
		'varName',
		'gplValue'
	],
	#category : #'GdsFeel-CLI-Kernel'
}

{ #category : #'as yet unclassified' }
GplVariable class >> named: aVariableName [
	^self new name: aVariableName.
]

{ #category : #accessing }
GplVariable >> asGplValue [
	^gplValue
]

{ #category : #convert }
GplVariable >> asSmalltalkValue [
	^gplValue asSmalltalkValue.
]

{ #category : #'error handling' }
GplVariable >> doesNotUnderstand: aMessage [
	gplValue perform: aMessage selector withArguments: aMessage arguments.
]

{ #category : #accessing }
GplVariable >> gplValue: aGdsDataStructure [
	gplValue := aGdsDataStructure.
]

{ #category : #testing }
GplVariable >> isVariableAllowed [
	^true
]

{ #category : #accessing }
GplVariable >> name [
	^varName
	
]

{ #category : #accessing }
GplVariable >> name: aVariableName [
	varName := aVariableName.
]

{ #category : #printing }
GplVariable >> printOn: aStream [
	super printOn: aStream.
	aStream nextPutAll: '('.
	aStream nextPutAll: varName.
	aStream nextPutAll: ','.
	aStream nextPutAll: gplValue gplString.	
	aStream nextPutAll: ')'.
	
]

{ #category : #accessing }
GplVariable >> rank [
	^gplValue rank
]
