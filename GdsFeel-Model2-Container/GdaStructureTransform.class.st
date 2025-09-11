Class {
	#name : #GdaStructureTransform,
	#superclass : #Object,
	#instVars : [
		'offset',
		'mag',
		'angle',
		'reflected',
		'absAngle',
		'absMag',
		'matrix'
	],
	#category : #'GdsFeel-Model2-Container'
}

{ #category : #accessing }
GdaStructureTransform >> angle [

	^ angle
]

{ #category : #accessing }
GdaStructureTransform >> angle: aDegrees [

	angle = aDegrees ifTrue: [ ^ self ].
	angle := aDegrees.
	matrix := nil
]

{ #category : #convertor }
GdaStructureTransform >> asMatrix2x3 [

	matrix ifNil: [ matrix := self lookupMatrix2x3 ].
	^ matrix
]

{ #category : #printing }
GdaStructureTransform >> consoleStringOn: aStream [

	aStream nextPutAll: 'MAG: '.
	aStream print: self mag.
	aStream cr.
	aStream nextPutAll: 'ANGLE: '.
	aStream print: self angle.
	aStream cr.
	aStream nextPutAll: 'REFL: '.
	aStream print: (self isReflected
			 ifTrue: [ 'Y' ]
			 ifFalse: [ 'N' ])
]

{ #category : #copying }
GdaStructureTransform >> copy [

	^ super copy copyTransform
]

{ #category : #copying }
GdaStructureTransform >> copyTransform [

	angle := angle deepCopy.
	offset := offset deepCopy.
	mag := mag deepCopy
]

{ #category : #'initialize-release' }
GdaStructureTransform >> initialize [

	super initialize.
	self safeReset
]

{ #category : #testing }
GdaStructureTransform >> isAbsAngle [

	^ absAngle
]

{ #category : #testing }
GdaStructureTransform >> isAbsMag [

	^ absMag
]

{ #category : #testing }
GdaStructureTransform >> isReflected [

	^ reflected
]

{ #category : #convertor }
GdaStructureTransform >> lookupMatrix2x3 [

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
	reflected ifTrue: [ 
		t a12: t a12 negated.
		t a22: t a22 negated ].
	^ t
]

{ #category : #accessing }
GdaStructureTransform >> mag [

	^ mag
]

{ #category : #accessing }
GdaStructureTransform >> mag: aFactor [

	mag = aFactor ifTrue: [ ^ self ].
	mag := aFactor.
	matrix := nil
]

{ #category : #accessing }
GdaStructureTransform >> offset [

	^ offset
]

{ #category : #accessing }
GdaStructureTransform >> offset: aPoint [

	offset = aPoint ifTrue: [ ^ self ].
	offset := aPoint.
	matrix := nil
]

{ #category : #printing }
GdaStructureTransform >> printOn: aStream [

	aStream nextPutAll: 'STRANS'.
	aStream nextPut: $(.
	aStream nextPut: $[.
	self offset x printOn: aStream.
	aStream nextPut: $,.
	self offset y printOn: aStream.
	aStream nextPut: $].
	(self mag closeTo: 1.0) ifFalse: [ 
		aStream ensureEndsWith: $,.
		aStream nextPutAll: 'M:'.
		aStream print: self mag ].
	(self angle closeTo: 0.0) ifFalse: [ 
		aStream ensureEndsWith: $,.
		aStream nextPutAll: 'A:'.
		aStream print: self angle ].
	self isReflected ifTrue: [ 
		aStream ensureEndsWith: $,.
		aStream nextPutAll: 'REFL' ].
	aStream nextPut: $)
]

{ #category : #'initialize-release' }
GdaStructureTransform >> release [
	offset := nil.
	mag := nil.
	angle := nil.
	reflected := nil.
	absAngle := nil.
	absMag := nil.
	matrix := nil.
	super release
]

{ #category : #'initialize-release' }
GdaStructureTransform >> safeReset [

	offset := 0.0 @ 0.0.
	mag := 1.0.
	angle := 0.0.
	absAngle := false.
	absMag := false.
	reflected := false
]

{ #category : #testing }
GdaStructureTransform >> setAngleAbsolute: aBoolean [

	absAngle := aBoolean.
	matrix := nil
]

{ #category : #testing }
GdaStructureTransform >> setMagAbsolute: aBoolean [

	absMag := aBoolean.
	matrix := nil
]

{ #category : #testing }
GdaStructureTransform >> setReflected: aBoolean [

	reflected = aBoolean ifTrue: [ ^ self ].
	reflected := aBoolean.
	matrix := nil
]
