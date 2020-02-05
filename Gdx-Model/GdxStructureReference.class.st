Class {
	#name : #GdxStructureReference,
	#superclass : #GdxReferenceElement,
	#instVars : [
		'referenceName',
		'referencedStructure',
		'structureTransform'
	],
	#category : #'Gdx-Model'
}

{ #category : #visiting }
GdxStructureReference >> accept: aGdxVisitor [ 
	aGdxVisitor visitSref: self
]

{ #category : #printing }
GdxStructureReference >> printSelfOn: aStream [
	referenceName
		ifNotNil: [ 
			aStream ensureEndsWith: $,.
			aStream nextPutAll: referenceName ]
]

{ #category : #accessing }
GdxStructureReference >> referenceName [
	^ referenceName
]

{ #category : #accessing }
GdxStructureReference >> referenceName: aString [
	referenceName := aString
]

{ #category : #accessing }
GdxStructureReference >> referencedStructure [
	^ referencedStructure
		ifNil: [ 
			referencedStructure := self structure library
				structureNamed: self referenceName ]
]

{ #category : #accessing }
GdxStructureReference >> structureTransform [
	^ structureTransform
]

{ #category : #accessing }
GdxStructureReference >> structureTransform: aGdsStructureTransform [
	structureTransform := aGdsStructureTransform copy
]

{ #category : #accessing }
GdxStructureReference >> typeString [
	^ 'SREF'
]
