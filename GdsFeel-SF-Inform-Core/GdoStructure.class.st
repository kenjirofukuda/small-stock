Class {
	#name : #GdoStructure,
	#superclass : #Object,
	#instVars : [
		'library',
		'name',
		'elements'
	],
	#category : #'GdsFeel-SF-Inform-Core'
}

{ #category : #'adding/removing protocols' }
GdoStructure >> addElement: aGdoElement [ 
	elements add: aGdoElement.
]

{ #category : #accessing }
GdoStructure >> elements [

	^ elements
]

{ #category : #accessing }
GdoStructure >> elements: anObject [

	^ elements := anObject
]

{ #category : #initialization }
GdoStructure >> initialize [
	elements := OrderedCollection new.
]

{ #category : #accessing }
GdoStructure >> library [

	^ library
]

{ #category : #accessing }
GdoStructure >> library: aGdoLibrary [ 
	library := aGdoLibrary
]

{ #category : #accessing }
GdoStructure >> name [

	^ name
]

{ #category : #accessing }
GdoStructure >> name: aString [ 
	name := aString
]
