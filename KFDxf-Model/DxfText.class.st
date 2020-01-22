Class {
	#name : #DxfText,
	#superclass : #DxfMtext,
	#category : #'KFDxf-Model'
}

{ #category : #constants }
DxfText class >> hAlignSymbols [
	^ #(#left #center #right #both #middle #fit)
]

{ #category : #constants }
DxfText class >> vAlignSymbols [
	^ #(#baseline #bottom #middle #top)
]

{ #category : #accessing }
DxfText >> centerX: aNumber [
	self secondaryX: aNumber
]

{ #category : #accessing }
DxfText >> centerY: aNumber [
	self secondaryY: aNumber
]

{ #category : #accessing }
DxfText >> centerZ: aNumber [
	self secondaryZ: aNumber
]

{ #category : #accessing }
DxfText >> contents: aString [
	self setCode: 1 data: aString
]

{ #category : #accessing }
DxfText >> hAlign: aSymbol [
	| code |
	self assert: (self class hAlignSymbols includes: aSymbol).
	code := (self class hAlignSymbols indexOf: aSymbol) - 1.
	self setCode: 72 data: code. 
]

{ #category : #accessing }
DxfText >> height: aNumber [
	self setCode: 40 data: aNumber
]

{ #category : #accessing }
DxfText >> primaryX: aNumber [
	self setCode: 10 data: aNumber
]

{ #category : #accessing }
DxfText >> primaryY: aNumber [
	self setCode: 20 data: aNumber
]

{ #category : #accessing }
DxfText >> primaryZ: aNumber [
	self setCode: 30 data: aNumber
]

{ #category : #accessing }
DxfText >> secondaryX: aNumber [
	self setCode: 11 data: aNumber
]

{ #category : #accessing }
DxfText >> secondaryY: aNumber [
	self setCode: 21 data: aNumber
]

{ #category : #accessing }
DxfText >> secondaryZ: aNumber [
	self setCode: 31 data: aNumber
]

{ #category : #accessing }
DxfText >> vAlign: aSymbol [
	| code |
	self assert: (self class vAlignSymbols includes: aSymbol).
	code := (self class vAlignSymbols indexOf: aSymbol) - 1.
	self setCode: 73 data: code. 
]
