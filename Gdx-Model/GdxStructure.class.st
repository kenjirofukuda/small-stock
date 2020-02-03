Class {
	#name : #GdxStructure,
	#superclass : #Object,
	#instVars : [
		'name',
		'elements'
	],
	#category : #'Gdx-Model'
}

{ #category : #visiting }
GdxStructure >> accept: aGdxVisitor [ 
	aGdxVisitor visitStructure: self
]

{ #category : #accessing }
GdxStructure >> elements [
	^ elements
]

{ #category : #accessing }
GdxStructure >> elements: aCollection [
	elements := aCollection copy
]

{ #category : #accessing }
GdxStructure >> name [
	^ name
]

{ #category : #accessing }
GdxStructure >> name: aStructureName [
	name := aStructureName
]

{ #category : #printing }
GdxStructure >> printOn: aStream [
	super printOn: aStream.
	aStream nextPut: $(.
	aStream nextPutAll: self name.
	aStream nextPut: $).
]
