"
A GdsStreamRecord is inner class of GdsStreamFormatReader.

Instance Variables
	bytes:		<ByteArray>
	dataBytes:		<ByteArray>
	type:		<Symbol>

bytes
	- {recordKind, dataType, dataBytes}

dataBytes
	- pure data witout recordKind, dataType

type
	- #XY, #ANGLE, #MAG etc. 

"
Class {
	#name : #GdsStreamRecord,
	#superclass : #Object,
	#instVars : [
		'bytes',
		'type',
		'dataBytes'
	],
	#category : #'GdsFeel-StreamFormat-Atomic'
}

{ #category : #'data format' }
GdsStreamRecord class >> structureElementTypes [

	^ #( BOUNDARY PATH TEXT BOX NODE SREF AREF )
]

{ #category : #converting }
GdsStreamRecord >> asString [

	^ (self dataBytes readStream upTo: 0) asString
]

{ #category : #accessing }
GdsStreamRecord >> bytes: aByteArray [

	bytes := aByteArray
]

{ #category : #private }
GdsStreamRecord >> convertSelector [

	| dType |
	dType := bytes at: 2.
	dType = 1 ifTrue: [ ^ #dataBytes ].
	dType = 2 ifTrue: [ ^ #int2Array ].
	dType = 3 ifTrue: [ ^ #int4Array ].
	dType = 5 ifTrue: [ ^ #real8Array ].
	dType = 6 ifTrue: [ ^ #asString ].
	^ nil
]

{ #category : #accessing }
GdsStreamRecord >> countBytes [

	^ bytes size
]

{ #category : #private }
GdsStreamRecord >> dataBytes [

	dataBytes ifNil: [ dataBytes := self lookupDataBytes ].
	^ dataBytes
]

{ #category : #printing }
GdsStreamRecord >> dateAndTimes [

	^ self dateAndTimes: self int2Array
]

{ #category : #printing }
GdsStreamRecord >> dateAndTimes: aCollection [

	| fixYear |
	self assert: [ aCollection size = 12 ].
	fixYear := [ :yy | 
	           (yy between: 85 and: 99)
		           ifTrue: [ yy + (2000 - 100) ]
		           ifFalse: [ yy + 2000 ] ].
	^ { 
		  (DateAndTime
			   year: (fixYear value: (aCollection at: 1))
			   month: (aCollection at: 2)
			   day: (aCollection at: 3)
			   hour: (aCollection at: 4)
			   minute: (aCollection at: 5)
			   second: (aCollection at: 6)).
		  (DateAndTime
			   year: (fixYear value: (aCollection at: 7))
			   month: (aCollection at: 8)
			   day: (aCollection at: 9)
			   hour: (aCollection at: 10)
			   minute: (aCollection at: 11)
			   second: (aCollection at: 12)) }
]

{ #category : #testing }
GdsStreamRecord >> hasData [

	^ self dataBytes notEmpty
]

{ #category : #converter }
GdsStreamRecord >> int2 [

	^ self int2Array first
]

{ #category : #converter }
GdsStreamRecord >> int2Array [

	| elSize numElements offset |
	elSize := 2.
	numElements := self dataBytes size // elSize.
	^ Array streamContents: [ :s | 
		  1 to: numElements do: [ :index | 
			  offset := index - 1 * elSize + 1.
			  s nextPut: (self dataBytes shortAt: offset bigEndian: true) ] ]
]

{ #category : #converter }
GdsStreamRecord >> int4 [

	^ self int4Array first
]

{ #category : #converter }
GdsStreamRecord >> int4Array [

	| elSize numElements offset |
	elSize := 4.
	numElements := self dataBytes size // elSize.
	^ Array streamContents: [ :s | 
		  1 to: numElements do: [ :index | 
			  offset := index - 1 * elSize + 1.
			  s nextPut: (self dataBytes longAt: offset bigEndian: true) ] ]
]

{ #category : #testing }
GdsStreamRecord >> isAbsAngle [

	^ self type = #STRANS and: [ 
		  ((self dataBytes at: 2) bitAnd: 16r01) ~= 0 ]
]

{ #category : #testing }
GdsStreamRecord >> isAbsMag [

	^ self type = #STRANS and: [ 
		  ((self dataBytes at: 2) bitAnd: 16r02) ~= 0 ]
]

{ #category : #testing }
GdsStreamRecord >> isElementHeader [

	^ self class structureElementTypes includes: self type
]

{ #category : #testing }
GdsStreamRecord >> isReflected [

	^ self type = #STRANS and: [ 
		  ((self dataBytes at: 1) bitAnd: 16r80) ~= 0 ]
]

{ #category : #private }
GdsStreamRecord >> lookupDataBytes [

	^ (bytes allButFirst: 2) asByteArray
]

{ #category : #private }
GdsStreamRecord >> lookupType [

	^ GdsStreamFormatReader typeForCode: (bytes at: 1)
]

{ #category : #accessing }
GdsStreamRecord >> pointsDividedByDatabaseUnit: aDatabaseUnit [

	| items numPoints offsetX offsetY |
	items := self int4Array.
	numPoints := items size / 2.
	^ Array streamContents: [ :s | 
		  | dbPoint userPoint |
		  1 to: numPoints do: [ :index | 
			  offsetX := index - 1 * 2 + 1.
			  offsetY := offsetX + 1.
			  dbPoint := (items at: offsetX) @ (items at: offsetY).
			  userPoint := dbPoint asUserFromDBU: aDatabaseUnit.
			  s nextPut: userPoint ] ]
]

{ #category : #accessing }
GdsStreamRecord >> pointsScaledBy: aFacter [

	| items numPoints offsetX offsetY |
	self deprecated: 'use pointsDividedByDatabaseUnit: '.
	items := self int4Array.
	numPoints := items size / 2.
	^ Array streamContents: [ :s | 
		  | dbPoint userPoint |
		  1 to: numPoints do: [ :index | 
			  offsetX := index - 1 * 2 + 1.
			  offsetY := offsetX + 1.
			  dbPoint := (items at: offsetX) @ (items at: offsetY).
			  userPoint := dbPoint / aFacter reciprocal.
			  s nextPut: userPoint ] ]
]

{ #category : #printing }
GdsStreamRecord >> printOn: aStream [

	aStream nextPutAll: self typeForPrint.
	self hasData ifFalse: [ ^ self ].
	aStream nextPut: $(.
	self representOn: aStream.
	aStream nextPut: $)
]

{ #category : #private }
GdsStreamRecord >> readGdsReal: aByteArray [

	| sign exponent mantissaInt mantissaFloatBitWidth mantissaFloat result |
	self assert: [ aByteArray size = 4 or: [ aByteArray size = 8 ] ].
	sign := (aByteArray at: 1) bitAnd: 16r80.
	exponent := ((aByteArray at: 1) bitAnd: 16r7F) - 64.
	mantissaInt := 0.
	mantissaFloatBitWidth := aByteArray size - 1 * 8.
	2 to: aByteArray size do: [ :i | 
		mantissaInt := mantissaInt << 8.
		mantissaInt := mantissaInt + (aByteArray at: i) ].
	mantissaFloat := mantissaInt
	                 / (2 raisedTo: mantissaFloatBitWidth) asFloat.
	result := mantissaFloat * (16 raisedTo: exponent).
	sign = 1 ifTrue: [ result := result negated ].
	^ result
	"
storage cost: 8byte(4word) 16bit machine

8-byte real:
SEEEEEEE MMMMMMMM MMMMMMMM MMMMMMMM MMMMMMMM MMMMMMMM MMMMMMMM MMMMMMMM
"
]

{ #category : #converter }
GdsStreamRecord >> real8 [

	^ self real8Array first
]

{ #category : #private }
GdsStreamRecord >> real8: aByteArray [

	^ self readGdsReal: aByteArray
]

{ #category : #converter }
GdsStreamRecord >> real8Array [

	| elSize numElements |
	elSize := 8.
	numElements := self dataBytes size // elSize.
	^ Array streamContents: [ :s | 
		  1 to: numElements do: [ :index | 
			  | offset |
			  offset := index - 1 * elSize + 1.
			  s nextPut:
				  (self real8:
					   (self dataBytes copyFrom: offset to: offset + elSize - 1)) ] ]
]

{ #category : #printing }
GdsStreamRecord >> representData [

	| sel data |
	sel := self convertSelector.
	sel ifNil: [ ^ self dataBytes ].
	data := self perform: sel.
	(data isKindOf: Collection) ifTrue: [ 
		data size = 1 ifTrue: [ ^ data first ].
		(#( BGNLIB BGNSTR ) includes: self type) ifTrue: [ 
			^ self dateAndTimes: data ] ].
	^ data
]

{ #category : #printing }
GdsStreamRecord >> representOn: aStream [

	aStream print: self representData
]

{ #category : #accessing }
GdsStreamRecord >> type [

	type ifNil: [ type := self lookupType ].
	^ type
]

{ #category : #printing }
GdsStreamRecord >> typeForPrint [

	self isElementHeader ifTrue: [ ^ self type ].
	^ self type asLowercase
]
