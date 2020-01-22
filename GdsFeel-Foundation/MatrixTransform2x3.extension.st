Extension { #name : #MatrixTransform2x3 }

{ #category : #'*GdsFeel-Foundation' }
MatrixTransform2x3 >> a [
	^ self a11
]

{ #category : #'*GdsFeel-Foundation' }
MatrixTransform2x3 >> a: aNumber [
	self a11: aNumber
]

{ #category : #'*GdsFeel-Foundation' }
MatrixTransform2x3 >> abcdef [
	^ { self a . self b . self c . self d . self e. self f }
]

{ #category : #'*GdsFeel-Foundation' }
MatrixTransform2x3 >> b [
	^ self a21
]

{ #category : #'*GdsFeel-Foundation' }
MatrixTransform2x3 >> b: aNumber [
	self a21: aNumber
]

{ #category : #'*GdsFeel-Foundation' }
MatrixTransform2x3 >> c [
	^ self a12
]

{ #category : #'*GdsFeel-Foundation' }
MatrixTransform2x3 >> c: aNumber [
	self a12: aNumber
]

{ #category : #'*GdsFeel-Foundation' }
MatrixTransform2x3 >> d [
	^ self a22
]

{ #category : #'*GdsFeel-Foundation' }
MatrixTransform2x3 >> d: aNumber [
	self a22: aNumber
]

{ #category : #'*GdsFeel-Foundation' }
MatrixTransform2x3 >> e [
	^ self a13
]

{ #category : #'*GdsFeel-Foundation' }
MatrixTransform2x3 >> e: aNumber [
	self a13: aNumber
]

{ #category : #'*GdsFeel-Foundation' }
MatrixTransform2x3 >> f [
	^ self a23
]

{ #category : #'*GdsFeel-Foundation' }
MatrixTransform2x3 >> f: aNumber [
	self a23: aNumber
]
