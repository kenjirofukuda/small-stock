Class {
	#name : #GdxLibrary,
	#superclass : #GdxNode,
	#instVars : [
		'name',
		'structures'
	],
	#category : #'Gdx-Model'
}

{ #category : #'development support' }
GdxLibrary class >> sampleClassicLibrary [
	"self sampleLibrary inspect."
	^ #GdsLibrary asClass fromFile: self sampleClassicLibraryPath asFileReference
]

{ #category : #'development support' }
GdxLibrary class >> sampleClassicLibraryPath [
	"self inform: self sampleLibraryPath"
	^ './sampleLibraryPath.txt' asFileReference readStream contents
]

{ #category : #'development support' }
GdxLibrary class >> sampleLibrary [ 
	^ self sampleClassicLibrary asGdxObject
]

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

{ #category : #accessing }
GdxLibrary >> parent [ 
	^ nil
]

{ #category : #printing }
GdxLibrary >> printOn: aStream [
	super printOn: aStream.
	aStream nextPut: $(.
	aStream nextPutAll: self name.
	aStream nextPut: $).
]

{ #category : #'structure control' }
GdxLibrary >> structureNamed: aStructureName [
	^ self structures
		detect: [ :each | each name sameAs: aStructureName ]
		ifFound: [ :each | each ]
		ifNone: [ nil ]
]

{ #category : #accessing }
GdxLibrary >> structures [
	^ structures
]

{ #category : #accessing }
GdxLibrary >> structures: aCollection [ 
	structures := aCollection asArray.
	structures do: [ :each | each library: self ]
]
