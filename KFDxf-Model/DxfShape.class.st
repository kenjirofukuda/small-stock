Class {
	#name : #DxfShape,
	#superclass : #DxfDataGroups,
	#instVars : [
		'layerName'
	],
	#category : #'KFDxf-Model'
}

{ #category : #accessing }
DxfShape class >> typeString [
	^ (self name asString allButFirst: 3) asUppercase 
]

{ #category : #accessing }
DxfShape >> angleDegress [
	^ self numberByNumber: 50 default: 0.0
]

{ #category : #accessing }
DxfShape >> angleDegress: aNumber [
	self setCode: 50 data: aNumber
]

{ #category : #accessing }
DxfShape >> centerX [
	^ self firstX
]

{ #category : #accessing }
DxfShape >> centerY [
	^ self firstY
]

{ #category : #accessing }
DxfShape >> centerZ [
	^ self firstZ
]

{ #category : #accessing }
DxfShape >> color [
	^ DxfLayer colorOfIndex: self colorNumber 
]

{ #category : #accessing }
DxfShape >> colorNumber [
	^ self numberByNumber: 62 default: 256
]

{ #category : #accessing }
DxfShape >> colorNumber: aNumber [
	self setCode: 62 data: aNumber
]

{ #category : #accessing }
DxfShape >> firstX [
	^ self numberByNumber: 10 default: 0.0
]

{ #category : #accessing }
DxfShape >> firstX: aNumber [
	self setCode: 10 data: aNumber
]

{ #category : #accessing }
DxfShape >> firstY [
	^ self numberByNumber: 20 default: 0.0
]

{ #category : #accessing }
DxfShape >> firstY: aNumber [
	self setCode: 20 data: aNumber

]

{ #category : #accessing }
DxfShape >> firstZ [
	^ self numberByNumber: 30 default: 0.0
]

{ #category : #accessing }
DxfShape >> firstZ: aNumber [
	self setCode: 30 data: aNumber

]

{ #category : #accessing }
DxfShape >> height [
	^ self numberByNumber: 40 default: 0.0.  
]

{ #category : #private }
DxfShape >> initializeDefaults [
	self setTypeString.
	self setBeginEntity.
	self setHandleNumber.
	self setSoftPointerHandle.
	
]

{ #category : #testing }
DxfShape >> isColorByBlock [
	^ self colorNumber = 0
]

{ #category : #testing }
DxfShape >> isColorByLayer [
	^ self colorNumber = 256
]

{ #category : #testing }
DxfShape >> isColorByOffLayer [
	^ self colorNumber negative
]

{ #category : #testing }
DxfShape >> isSelfColor [
	self isColorByLayer ifTrue: [ ^ false ].	
	self isColorByBlock ifTrue: [ ^ false ].
	^ true
]

{ #category : #private }
DxfShape >> layerName [
	^ self encodedStringByNumber: 8 default: '###ERROR###'
]

{ #category : #private }
DxfShape >> layerName: aString [
	self setCode: 8 data: aString

]

{ #category : #accessing }
DxfShape >> points [
	^ #()
]

{ #category : #private }
DxfShape >> setBeginEntity [
	self addCode: 100 data: 'AcDbEntity'.

]

{ #category : #private }
DxfShape >> setHandleNumber [
	self setCode: 5 data: self hash printStringHex
]

{ #category : #private }
DxfShape >> setLineStyleToByLayer [
	self setCode: 6 data: 'ByLayer'.
]

{ #category : #private }
DxfShape >> setSoftPointerHandle [
	self setCode: 330 data: ' 1F'
]

{ #category : #private }
DxfShape >> setTypeString [
	self setCode: 0 data: self typeString. 
]

{ #category : #accessing }
DxfShape >> typeString [
	^ self class typeString
]
