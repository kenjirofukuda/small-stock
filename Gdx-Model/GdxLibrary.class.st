Class {
	#name : #GdxLibrary,
	#superclass : #GdxNode,
	#instVars : [
		'name',
		'structures'
	],
	#category : #'Gdx-Model'
}

{ #category : #visiting }
GdxLibrary >> accept: aGdxVisitor [ 
	aGdxVisitor visitLibrary: self
]

{ #category : #accessing }
GdxLibrary >> children [
	^ self structures
]

{ #category : #accessing }
GdxLibrary >> name [
	^ name
]

{ #category : #accessing }
GdxLibrary >> name: aString [ 
	name := aString.
]

{ #category : #printing }
GdxLibrary >> printOn: aStream [
	super printOn: aStream.
	aStream nextPut: $(.
	aStream nextPutAll: self name.
	aStream nextPut: $).
]

{ #category : #accessing }
GdxLibrary >> structures [
	^ structures
]

{ #category : #accessing }
GdxLibrary >> structures: aCollection [ 
	structures := aCollection
]
