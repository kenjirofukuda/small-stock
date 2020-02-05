Class {
	#name : #GdxVisitor,
	#superclass : #GdxObject,
	#instVars : [
		'depth',
		'debugStream',
		'deepIntoReference',
		'nameBag'
	],
	#category : #'Gdx-Model'
}

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

{ #category : #accessing }
GdxVisitor >> contents [
	^ debugStream contents
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
	debugStream := WriteStream on: WideString new.
	nameBag := Bag new.
]

{ #category : #visiting }
GdxVisitor >> insertIndent [
	depth * 2 timesRepeat: [ debugStream nextPut: Character space ]
]

{ #category : #visiting }
GdxVisitor >> pushDepthDuring: aBlock [
	depth := depth + 1.
	aBlock value.
	depth := depth - 1.
]

{ #category : #visiting }
GdxVisitor >> visitAref: aGdxArrayedStructureReference [
	self visitSref: aGdxArrayedStructureReference.
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
GdxVisitor >> visitContainer: aGdxObject [
	self insertIndent.
	aGdxObject printOn: debugStream.
	debugStream ensureCr.
	self
		pushDepthDuring: [ aGdxObject children do: [ :each | each accept: self ] ]
]

{ #category : #visiting }
GdxVisitor >> visitElement: aGdxElement [
	self insertIndent.
	aGdxElement printOn: debugStream.
	debugStream ensureCr.
]

{ #category : #visiting }
GdxVisitor >> visitLibrary: aGdxLibrary [
	self visitContainer: aGdxLibrary
		
]

{ #category : #visiting }
GdxVisitor >> visitPath: aGdxPath [
	self visitElement: aGdxPath.
]

{ #category : #visiting }
GdxVisitor >> visitSref: aGdxStructureReference [
	self visitElement: aGdxStructureReference.
	nameBag add: aGdxStructureReference referenceName.
	self deepIntoReference
		ifTrue: [ aGdxStructureReference referencedStructure accept: self ]
]

{ #category : #visiting }
GdxVisitor >> visitStructure: aGdxStructure [
	self visitContainer: aGdxStructure

]
