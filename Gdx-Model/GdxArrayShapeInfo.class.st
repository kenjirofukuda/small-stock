Class {
	#name : #GdxArrayShapeInfo,
	#superclass : #GdxObject,
	#instVars : [
		'columnCount',
		'rowCount',
		'xStep',
		'yStep',
		'transforms',
		'offsets'
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

{ #category : #'as yet unclassified' }
GdxArrayShapeInfo >> lookupOffsets [
	^ Array streamContents: [ :s |
		0 to: self columnCount - 1  do: [:xIndex |
			0 to: self rowCount - 1 do: [:yIndex |
				s nextPut: (xIndex * self xStep) @ (yIndex * self yStep) ] ] ]
]

{ #category : #'as yet unclassified' }
GdxArrayShapeInfo >> lookupTransforms [
	^ self offsets collect: [ :offset | MatrixTransform2x3 withOffset: offset ]
]

{ #category : #'as yet unclassified' }
GdxArrayShapeInfo >> offsets [
	^ offsets ifNil: [offsets := self lookupOffsets].
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

{ #category : #'as yet unclassified' }
GdxArrayShapeInfo >> relativeTransforms [
	transforms ifNil: [ transforms := self lookupTransforms ].
	^ transforms
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
