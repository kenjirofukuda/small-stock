Class {
	#name : #GdxStructure,
	#superclass : #GdxNode,
	#instVars : [
		'name',
		'elements',
		'library'
	],
	#category : #'Gdx-Model'
}

{ #category : #visiting }
GdxStructure >> accept: aGdxVisitor [ 
	aGdxVisitor visitStructure: self
]

{ #category : #accessing }
GdxStructure >> children [ 
	^ self elements
]

{ #category : #'accessing - analisys' }
GdxStructure >> directReferenceElements [
	^ self elements select: [ :e | e isReference ]
]

{ #category : #accessing }
GdxStructure >> elements [
	^ elements
]

{ #category : #accessing }
GdxStructure >> elements: aCollection [
	elements := aCollection asArray.
	elements do: [ :each | each structure: self ]
]

{ #category : #accessing }
GdxStructure >> library [
	^ library
]

{ #category : #accessing }
GdxStructure >> library: aGdsLibrary [
	library := aGdsLibrary
]

{ #category : #'accessing - analisys' }
GdxStructure >> lookupReferencedStructures [
	^ self library structures
		select: [ :each | 
			each directReferenceElements
				anySatisfy: [ :el | el structureName sameAs: self name ] ]
]

{ #category : #accessing }
GdxStructure >> name [
	^ name
]

{ #category : #accessing }
GdxStructure >> name: aStructureName [
	name := aStructureName
]

{ #category : #accessing }
GdxStructure >> parent [ 
	^ self library
]

{ #category : #printing }
GdxStructure >> printOn: aStream [
	super printOn: aStream.
	aStream nextPut: $(.
	aStream nextPutAll: self name.
	aStream nextPut: $).
]
