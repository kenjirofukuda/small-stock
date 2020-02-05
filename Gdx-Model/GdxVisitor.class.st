Class {
	#name : #GdxVisitor,
	#superclass : #GdxObject,
	#instVars : [
		'depth',
		'debugStream'
	],
	#category : #'Gdx-Model'
}

{ #category : #'instance creation' }
GdxVisitor class >> on: aGdxLibrary [
	| visitor |
	visitor := self new.
	aGdxLibrary accept: visitor.
	^ visitor
]

{ #category : #accessing }
GdxVisitor >> contents [
	^ debugStream contents
]

{ #category : #initialization }
GdxVisitor >> initialize [
	super initialize.
	depth := 0.
	debugStream := WriteStream on: WideString new.
]

{ #category : #visiting }
GdxVisitor >> insertIndent [
	depth * 2 timesRepeat: [ debugStream nextPut: Character space ]
]

{ #category : #visiting }
GdxVisitor >> visitAref: aGdxArrayedStructureReference [
	self visitElement: aGdxArrayedStructureReference.
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
	depth := depth + 1.
	aGdxObject children do: [ :each | each accept: self ].
	depth := depth - 1.
		
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
]

{ #category : #visiting }
GdxVisitor >> visitStructure: aGdxStructure [
	self visitContainer: aGdxStructure

]
