Class {
	#name : #GdxPrintTreeVisitor,
	#superclass : #GdxVisitor,
	#instVars : [
		'debugStream',
		'nameBag'
	],
	#category : #'Gdx-Model'
}

{ #category : #'as yet unclassified' }
GdxPrintTreeVisitor class >> sampleEntry [
	^ self sampleLibrary 
]

{ #category : #accessing }
GdxPrintTreeVisitor >> contents [
	^ debugStream contents
]

{ #category : #initialization }
GdxPrintTreeVisitor >> initialize [
	super initialize.
	debugStream := WriteStream on: WideString new.
	nameBag := Bag new.
]

{ #category : #visiting }
GdxPrintTreeVisitor >> insertIndent [
	depth * 2 timesRepeat: [ debugStream nextPut: Character space ]
]

{ #category : #visiting }
GdxPrintTreeVisitor >> visitAref: aGdxArrayedStructureReference [
	self visitSref: aGdxArrayedStructureReference.
]

{ #category : #visiting }
GdxPrintTreeVisitor >> visitContainer: aGdxObject [
	self insertIndent.
	aGdxObject printOn: debugStream.
	debugStream ensureCr.
	self
		pushDepthDuring: [ aGdxObject children do: [ :each | each accept: self ] ]
]

{ #category : #visiting }
GdxPrintTreeVisitor >> visitElement: aGdxElement [
	self insertIndent.
	aGdxElement printOn: debugStream.
	debugStream ensureCr.
]

{ #category : #visiting }
GdxPrintTreeVisitor >> visitLibrary: aGdxLibrary [
	self visitContainer: aGdxLibrary
		
]

{ #category : #visiting }
GdxPrintTreeVisitor >> visitSref: aGdxStructureReference [
	self visitElement: aGdxStructureReference.
	nameBag add: aGdxStructureReference referenceName.
	self deepIntoReference
		ifTrue: [ aGdxStructureReference referencedStructure accept: self ]
]

{ #category : #visiting }
GdxPrintTreeVisitor >> visitStructure: aGdxStructure [
	self visitContainer: aGdxStructure

]
