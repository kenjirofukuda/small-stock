"
A GdsStructureTransform is transform information.

Instance Variables

"
Class {
	#name : #GdsStructureTransform,
	#superclass : #Model,
	#instVars : [
		'offset',
		'mag',
		'angle',
		'reflected',
		'absAngle',
		'absMag',
		'matrix'
	],
	#category : #'GdsFeel-Model-Private'
}

{ #category : #accessing }
GdsStructureTransform >> angle [
	^ angle
]

{ #category : #accessing }
GdsStructureTransform >> angle: aDegrees [
	angle = aDegrees
		ifTrue: [ ^ self ].
	angle := aDegrees.
	matrix := nil
]

{ #category : #convertor }
GdsStructureTransform >> asMatrix2x3 [
	matrix ifNil: [ matrix := self lookupMatrix2x3 ].
	^ matrix
]

{ #category : #printing }
GdsStructureTransform >> consoleStringOn: aStream [
	aStream nextPutAll: 'MAG: '.
	aStream print: self mag.
	aStream cr.
	aStream nextPutAll: 'ANGLE: '.
	aStream print: self angle.
	aStream cr.
	aStream nextPutAll: 'REFL: '.
	aStream
		print:
			(self isReflected
				ifTrue: [ 'Y' ]
				ifFalse: [ 'N' ])
]

{ #category : #copying }
GdsStructureTransform >> copy [
	^ super copy copyTransform
]

{ #category : #copying }
GdsStructureTransform >> copyTransform [
	angle := angle deepCopy.
	offset := offset deepCopy.
	mag := mag deepCopy
]

{ #category : #'initialize-release' }
GdsStructureTransform >> initialize [
	super initialize.
	self safeReset
]

{ #category : #testing }
GdsStructureTransform >> isAbsAngle [
	^ absAngle
]

{ #category : #testing }
GdsStructureTransform >> isAbsMag [
	^ absMag
]

{ #category : #testing }
GdsStructureTransform >> isReflected [
	^ reflected
]

{ #category : #convertor }
GdsStructureTransform >> lookupMatrix2x3 [
	| t rad radCos radSin |
	t := GeometryUtils transformClass identity.
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
GdsStructureTransform >> mag [
	^ mag
]

{ #category : #accessing }
GdsStructureTransform >> mag: aFactor [
	mag = aFactor
		ifTrue: [ ^ self ].
	mag := aFactor.
	matrix := nil
]

{ #category : #accessing }
GdsStructureTransform >> offset [
	^ offset
]

{ #category : #accessing }
GdsStructureTransform >> offset: aPoint [
	offset = aPoint
		ifTrue: [ ^ self ].
	offset := aPoint.
	matrix := nil
]

{ #category : #printing }
GdsStructureTransform >> printOn: aStream [
	aStream nextPutAll: 'STRANS'.
	aStream nextPut: $(.
	aStream nextPut: $[.
	self offset x printOn: aStream.
	aStream nextPut: $,.
	self offset y printOn: aStream.
	aStream nextPut: $].	
	(self mag closeTo: 1.0)
		ifFalse: [
			aStream ensureEndsWith: $,. 
			aStream nextPutAll: 'M:'. 
			aStream print: self mag ].
	(self angle closeTo: 0.0)
		ifFalse: [ 
			aStream ensureEndsWith: $,. 
			aStream nextPutAll: 'A:'. 
			aStream print: self angle ].
	self isReflected
		ifTrue: [
			aStream ensureEndsWith: $,. 
			 aStream nextPutAll: 'REFL' ].
	aStream nextPut: $)
]

{ #category : #'initialize-release' }
GdsStructureTransform >> safeReset [
	offset := 0.0 @ 0.0.
	mag := 1.0.
	angle := 0.0.
	absAngle := false.
	absMag := false.
	reflected := false
]

{ #category : #testing }
GdsStructureTransform >> setAngleAbsolute: aBoolean [
	absAngle := aBoolean.
	matrix := nil
]

{ #category : #testing }
GdsStructureTransform >> setMagAbsolute: aBoolean [
	absMag := aBoolean.
	matrix := nil
]

{ #category : #testing }
GdsStructureTransform >> setReflected: aBoolean [
	reflected = aBoolean
		ifTrue: [ ^ self ].
	reflected := aBoolean.
	matrix := nil
]
