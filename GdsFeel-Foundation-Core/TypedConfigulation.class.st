Class {
	#name : #TypedConfigulation,
	#superclass : #Object,
	#instVars : [
		'booleanMap',
		'numberMap',
		'pointMap',
		'stringMap',
		'colorMap'
	],
	#category : #'GdsFeel-Foundation-Core'
}

{ #category : #'as yet unclassified' }
TypedConfigulation >> booleanFor: aSymbol [
	^self booleanFor: aSymbol default: false.
]

{ #category : #'as yet unclassified' }
TypedConfigulation >> booleanFor: aSymbol default: aValue [
	booleanMap ifNil: [booleanMap := Dictionary new].
	^booleanMap at: aSymbol ifAbsentPut: [aValue].
]

{ #category : #'as yet unclassified' }
TypedConfigulation >> booleanFor: aSymbol value: aBoolean [
	booleanMap ifNil: [booleanMap := Dictionary new].
	booleanMap at: aSymbol put: aBoolean.
]

{ #category : #'as yet unclassified' }
TypedConfigulation >> colorFor: aSymbol [ 
	^ self colorFor: aSymbol default: Color black.
]

{ #category : #'as yet unclassified' }
TypedConfigulation >> colorFor: aSymbol default: aValue [
	| aVal |
	colorMap ifNil: [ colorMap := Dictionary new ].
	aVal := colorMap at: aSymbol ifAbsentPut: [ aValue ].
	^ aVal ifNil: [ Color black ] ifNotNil: [ aVal ]
]

{ #category : #'as yet unclassified' }
TypedConfigulation >> colorFor: aSymbol value: aColor [
	self assert: (aColor isMemberOf: Color).
	colorMap ifNil: [colorMap := Dictionary new].
	colorMap at: aSymbol put: aColor.
]

{ #category : #'as yet unclassified' }
TypedConfigulation >> numberFor: aSymbol [
	^self numberFor: aSymbol default: 0.
]

{ #category : #'as yet unclassified' }
TypedConfigulation >> numberFor: aSymbol default: aValue [
	numberMap ifNil: [numberMap := Dictionary new].
	^numberMap at: aSymbol ifAbsentPut: [aValue].
]

{ #category : #'as yet unclassified' }
TypedConfigulation >> numberFor: aSymbol value: aNumber [
	self assert: [aNumber isNumber].
	numberMap ifNil: [numberMap := Dictionary new].
	numberMap at: aSymbol put: aNumber.
]

{ #category : #'as yet unclassified' }
TypedConfigulation >> pointFor: aString [ 
	^self pointFor: aString default: 0@0 copy
]

{ #category : #'as yet unclassified' }
TypedConfigulation >> pointFor: aString default: aValue [ 
	pointMap ifNil: [ pointMap := Dictionary new ].
	^ pointMap 
		at: aString
		ifAbsentPut: [ aValue ]
]

{ #category : #'as yet unclassified' }
TypedConfigulation >> pointFor: aString value: aPoint [ 
	pointMap ifNil: [ pointMap := Dictionary new ].
	pointMap 
		at: aString
		put: aPoint
]

{ #category : #'as yet unclassified' }
TypedConfigulation >> stringFor: aSymbol [ 
	^self stringFor:  aSymbol default: ''.
]

{ #category : #'as yet unclassified' }
TypedConfigulation >> stringFor: aSymbol default: aValue [

	| aVal |
	stringMap ifNil: [ stringMap := Dictionary new ].
	aVal := stringMap at: aSymbol ifAbsentPut: [ aValue ].
	aVal ifNil: [ aVal := stringMap at: aSymbol put: aValue ].
	^ aVal asString
]

{ #category : #'as yet unclassified' }
TypedConfigulation >> stringFor: aSymbol value: aBoolean [
	stringMap ifNil: [stringMap := Dictionary new].
	stringMap at: aSymbol put: aBoolean.
]
