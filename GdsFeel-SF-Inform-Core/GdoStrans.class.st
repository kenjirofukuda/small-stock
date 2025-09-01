Class {
	#name : #GdoStrans,
	#superclass : #Object,
	#instVars : [
		'reflected',
		'magAbsolute',
		'angleAbsolute',
		'matrix',
		'angle',
		'mag',
		'offset',
		'absAngle',
		'absMag'
	],
	#category : #'GdsFeel-SF-Inform-Core'
}

{ #category : #accessing }
GdoStrans >> angle [
	^ angle
]

{ #category : #accessing }
GdoStrans >> angle: aDegrees [
	angle = aDegrees
		ifTrue: [ ^ self ].
	angle := aDegrees.
	matrix := nil
]

{ #category : #accessing }
GdoStrans >> asMatrix2x3 [
	matrix ifNil: [ matrix := self lookupMatrix2x3 ].
	^ matrix.
]

{ #category : #initialization }
GdoStrans >> initialize [ 
	offset := 0.0 @ 0.0.
	mag := 1.0.
	angle := 0.0.
	absAngle := false.
	absMag := false.
	reflected := false
]

{ #category : #testing }
GdoStrans >> isAbsAngle [

	^ angleAbsolute
]

{ #category : #testing }
GdoStrans >> isAbsMag [

	^ magAbsolute
]

{ #category : #testing }
GdoStrans >> isReflected [

	^ reflected
]

{ #category : #accessing }
GdoStrans >> lookupMatrix2x3 [
	| t rad radCos radSin |
	t := MatrixTransform2x3 identity.
	rad := angle degreesToRadians.
	radCos := rad cos.
	radSin := rad sin.
	t a11: mag * radCos.
	t a12: mag negated * radSin.
	t a13: self offset x.
	t a21: mag * radSin.
	t a22: mag * radCos.
	t a23: self offset y.
	reflected
		ifTrue: [ t a12: t a12 negated.
			t a22: t a22 negated ].
	^ t
]

{ #category : #accessing }
GdoStrans >> mag [
	^ mag
]

{ #category : #accessing }
GdoStrans >> mag: aFactor [
	mag = aFactor
		ifTrue: [ ^ self ].
	mag := aFactor.
	matrix := nil
]

{ #category : #accessing }
GdoStrans >> offset [
	^ offset
]

{ #category : #accessing }
GdoStrans >> offset: aPoint [
	offset = aPoint
		ifTrue: [ ^ self ].
	offset := aPoint.
	matrix := nil
]

{ #category : #accessing }
GdoStrans >> setAngleAbsolute: aBoolean [ 
	absAngle := aBoolean
]

{ #category : #accessing }
GdoStrans >> setMagAbsolute: aBoolean [ 
	absMag := aBoolean
]

{ #category : #accessing }
GdoStrans >> setReflected: aBoolean [ 
	reflected := aBoolean
]
