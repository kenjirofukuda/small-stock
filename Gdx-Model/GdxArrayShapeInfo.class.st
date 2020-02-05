Class {
	#name : #GdxArrayShapeInfo,
	#superclass : #GdxObject,
	#instVars : [
		'columnCount',
		'rowCount',
		'xStep',
		'yStep'
	],
	#category : #'Gdx-Model'
}

{ #category : #accessing }
GdxArrayShapeInfo >> columnCount [
	^ columnCount
]

{ #category : #accessing }
GdxArrayShapeInfo >> columnCount: anObject [
	columnCount := anObject
]

{ #category : #printing }
GdxArrayShapeInfo >> printOn: aStream [
	aStream nextPutAll: 'ASHAPE'.
	aStream nextPut: $(.
	columnCount = 1
		ifFalse: [ 
			aStream nextPutAll: 'C:'.
			columnCount printOn: aStream.
			aStream ensureEndsWith: $,. ].
	rowCount = 1
		ifFalse: [ 
			aStream nextPutAll: 'R:'.
			rowCount printOn: aStream.
			aStream ensureEndsWith: $,. ].
	(xStep closeTo: 0.0)
		ifFalse: [ 
			aStream nextPutAll: 'XS:'.
			xStep printOn: aStream.
			aStream ensureEndsWith: $,. ].
	(yStep closeTo: 0.0)
		ifFalse: [ 
			aStream ensureEndsWith: $,.
			aStream nextPutAll: 'YS:'.
			yStep printOn: aStream. ].
	aStream nextPut: $).	
]

{ #category : #accessing }
GdxArrayShapeInfo >> rowCount [
	^ rowCount
]

{ #category : #accessing }
GdxArrayShapeInfo >> rowCount: anObject [
	rowCount := anObject
]

{ #category : #accessing }
GdxArrayShapeInfo >> xStep [
	^ xStep
]

{ #category : #accessing }
GdxArrayShapeInfo >> xStep: anObject [
	xStep := anObject
]

{ #category : #accessing }
GdxArrayShapeInfo >> yStep [
	^ yStep
]

{ #category : #accessing }
GdxArrayShapeInfo >> yStep: anObject [
	yStep := anObject
]
