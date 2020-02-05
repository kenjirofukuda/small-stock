Class {
	#name : #GdxStructureReference,
	#superclass : #GdxReferenceElement,
	#instVars : [
		'referenceName'
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
GdxStructureReference >> typeString [
	^ 'SREF'
]
