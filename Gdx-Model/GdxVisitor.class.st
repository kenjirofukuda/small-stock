Class {
	#name : #GdxVisitor,
	#superclass : #GdxObject,
	#instVars : [
		'deepIntoReference',
		'depth'
	],
	#category : #'Gdx-Model'
}

{ #category : #examples }
GdxVisitor class >> exampleVisitor [
	^ self sampleVisitor inspect.
]

{ #category : #'instance creation' }
GdxVisitor class >> on: aGdxLibrary [
	^ self on: aGdxLibrary deepIntoReference: false
]

{ #category : #'instance creation' }
GdxVisitor class >> on: aGdxLibrary deepIntoReference: aBoolean [
	| visitor |
	visitor := self new.
	visitor deepIntoReference: aBoolean.
	aGdxLibrary accept: visitor.
	^ visitor
]

{ #category : #examples }
GdxVisitor class >> sampleEntry [
	^ self subclassResponsibility
]

{ #category : #examples }
GdxVisitor class >> sampleLibrary [
	^ GdxLibrary sampleLibrary
]

{ #category : #'as yet unclassified' }
GdxVisitor class >> sampleStructure [
	^ self sampleLibrary structureNamed: 'BANDGAP'
]

{ #category : #'as yet unclassified' }
GdxVisitor class >> sampleVisitor [
	"self exampleVisitor inspect."
	^ self on: self sampleEntry deepIntoReference: true.
]

{ #category : #accessing }
GdxVisitor >> deepIntoReference [
	^ deepIntoReference
]

{ #category : #accessing }
GdxVisitor >> deepIntoReference: aBoolean [
	deepIntoReference := aBoolean
]

{ #category : #initialization }
GdxVisitor >> initialize [
	super initialize.
	depth := 0.
	deepIntoReference := false
]

{ #category : #visiting }
GdxVisitor >> pushDepthDuring: aBlock [
	depth := depth + 1.
	aBlock value.
	depth := depth - 1.
]

{ #category : #visiting }
GdxVisitor >> visitAref: aGdxArrayedStructureReference [
]

{ #category : #visiting }
GdxVisitor >> visitBoundary: aGdxBoundary [
	self visitElement: aGdxBoundary.
]

{ #category : #visiting }
GdxVisitor >> visitBoxText: aGdxBoxText [
	self visitElement: aGdxBoxText.
]

{ #category : #visiting }
GdxVisitor >> visitElement: aGdxElement [
]

{ #category : #visiting }
GdxVisitor >> visitPath: aGdxPath [
	self visitElement: aGdxPath.
]

{ #category : #visiting }
GdxVisitor >> visitSref: aGdxStructureReference [
]
