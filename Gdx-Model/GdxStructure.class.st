Class {
	#name : #GdxStructure,
	#superclass : #Object,
	#instVars : [
		'name'
	],
	#category : #'Gdx-Model'
}

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
