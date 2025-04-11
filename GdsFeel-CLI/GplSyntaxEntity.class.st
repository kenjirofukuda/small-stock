Class {
	#name : 'GplSyntaxEntity',
	#superclass : 'Object',
	#instVars : [
		'symbol',
		'string'
	],
	#category : 'GdsFeel-CLI-AST',
	#package : 'GdsFeel-CLI',
	#tag : 'AST'
}

{ #category : 'instance creation' }
GplSyntaxEntity class >> fromString: aString [
	^ self new string: aString
]

{ #category : 'accesing' }
GplSyntaxEntity >> string [
	^ string
]

{ #category : 'accesing' }
GplSyntaxEntity >> string: aString [
	string := aString
]

{ #category : 'accessing' }
GplSyntaxEntity >> symbol [
	^ symbol ifNil: [ symbol := self string asLowercase asSymbol ]
]

{ #category : 'accessing' }
GplSyntaxEntity >> symbol: anObject [
	symbol := anObject
]
