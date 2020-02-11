Class {
	#name : #GdxArrayedStructureReference,
	#superclass : #GdxStructureReference,
	#instVars : [
		'arrayShapeInfo'
	],
	#category : #'Gdx-Model'
}

{ #category : #visiting }
GdxArrayedStructureReference >> accept: aGdxVisitor [ 
	aGdxVisitor visitAref: self
]

{ #category : #accessing }
GdxArrayedStructureReference >> arrayShapeInfo [
	^ arrayShapeInfo
]

{ #category : #accessing }
GdxArrayedStructureReference >> arrayShapeInfo: aGdxArrayShapeInfo [
	arrayShapeInfo := aGdxArrayShapeInfo
]

{ #category : #accessing }
GdxArrayedStructureReference >> athensTransforms [
	^ self arrayShapeInfo relativeTransforms
		collect:
			[ :mat2x3 | self athensTransform copy multiplyBy: mat2x3 asAthensAT ]
]

{ #category : #initialization }
GdxArrayedStructureReference >> initialize [ 
	super initialize.
	arrayShapeInfo := GdxArrayShapeInfo new.
]

{ #category : #accessing }
GdxArrayedStructureReference >> typeString [
	^ 'AREF'
]
