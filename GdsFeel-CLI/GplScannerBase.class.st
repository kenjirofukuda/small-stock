"
A GplParser is GPL Parser.

- scanToken: aString
 phase1 parsing.
 no type tag spliter.
 all element class is String. but lineEnding only #cr (Symbol)

TODO: 
build parse tree.

Instance Variables
	colWords:		<Collection<String|Symbol>>
	currentWords:		<Collection<String|Symbol>>
	input:		<ReadStream>
	stack:		<Collection<Collection>>

colWords
	- xxxxx

currentWords
	- current level word collection

input
	- GPL II statement input stream.

stack
	- using pushLevel: popLevel: 

"
Class {
	#name : #GplScannerBase,
	#superclass : #GdsObject,
	#instVars : [
		'input',
		'words'
	],
	#category : #'GdsFeel-CLI-Kernel'
}

{ #category : #testing }
GplScannerBase class >> isLineEndFirst: aCharacter [
	^ aCharacter = Character cr or: [ aCharacter = Character lf ]
]

{ #category : #testing }
GplScannerBase class >> isNameAfterSecond: aCharacter [
	(aCharacter isLetter or: [ aCharacter isDigit ])
		ifTrue: [ ^ true ].
	^ '$_' includes: aCharacter
]

{ #category : #testing }
GplScannerBase class >> isNameFirst: aCharacter [
	aCharacter = $$
		ifTrue: [ ^ true ].
	^ aCharacter isLetter
]

{ #category : #testing }
GplScannerBase class >> isNumberAllowed: aCharacter [
	^ aCharacter isDigit or: [ '#-.E' includes: aCharacter ]
]

{ #category : #testing }
GplScannerBase class >> isNumberFirst: aCharacter [
	^ aCharacter isDigit or: [ '#-.' includes: aCharacter ]
]

{ #category : #testing }
GplScannerBase class >> isTabOrSpace: aCharacter [
	^ aCharacter asciiValue == 32 or: [ aCharacter asciiValue == 9 ]
]

{ #category : #parse }
GplScannerBase class >> splitTokens: aString [
	^ self new splitTokens: aString
]

{ #category : #parse }
GplScannerBase class >> textTookenStream: aString [
	^ ReadStream on: (self splitTokens: aString)
]

{ #category : #parse }
GplScannerBase class >> tokenStream: aString [
	^ ReadStream on: (self splitTokens: aString)
]

{ #category : #accessing }
GplScannerBase >> char2Words [
	^ {':=' . '<>' . '<=' . '>='}
]

{ #category : #private }
GplScannerBase >> handleBlanks [
	self skipBlanks
]

{ #category : #'initialize-release' }
GplScannerBase >> initialize [
	super initialize.
	words := OrderedCollection new
]

{ #category : #private }
GplScannerBase >> passResolveVariableName [
	| local varNames |
	varNames := OrderedCollection new.
	local := 0.
	self tokens
		do: [ :token | 
			(token fragment sameAs: 'LOCAL')
				ifTrue: [ local := local + 1 ].
			token type = #cr
				ifTrue: [ local := 0 ].
			(local > 0 and: [ token type = #unresolved ])
				ifTrue: [ varNames add: token fragment ] ].
	varNames
		do: [ :varName | 
			(self tokens select: [ :token | token fragment sameAs: varName ])
				do: [ :token | token type: #localVariable ] ]
]

{ #category : #private }
GplScannerBase >> peek2 [
	| nextObject |
	nextObject := nil.
	2
		timesRepeat: [ input atEnd
				ifTrue: [ ^ nil ].
			nextObject := input next ].
	input position: input position - 2.
	^ nextObject
]

{ #category : #private }
GplScannerBase >> pushNotEmpty: aWriteStream [
	self pushNotEmpty: aWriteStream start: -1	"ignore -1"
]

{ #category : #private }
GplScannerBase >> pushNotEmpty: aWriteStream start: aInteger [
	aWriteStream contents
		ifNotEmpty: [ self pushWord: aWriteStream contents ]
]

{ #category : #private }
GplScannerBase >> pushWord: aWord [
	words add: aWord
]

{ #category : #private }
GplScannerBase >> scanBlanks [
	| noSpace start s |
	start := input position + 1.
	input atEnd
		ifTrue: [ ^ self ].
	noSpace := false.
	s := self writeStream.
	[ input atEnd or: [ noSpace ] ]
		whileFalse: [ | c |
			c := input next.
			noSpace := (self class isTabOrSpace: c) not.
			noSpace
				ifFalse: [ s nextPut: c ] ].
	input atEnd
		ifTrue: [ noSpace
				ifTrue: [ input skip: -1 ] ]
		ifFalse: [ input skip: -1 ].
	self pushNotEmpty: s start: start
]

{ #category : #'scanning-deprecated' }
GplScannerBase >> scanDigitOnly [
	| digit s start |
	digit := true.
	s := self writeStream.
	start := input position + 1.
	[ input atEnd not and: [ digit ] ]
		whileTrue: [ | c |
			c := input next.
			digit := c isDigit.
			digit
				ifTrue: [ s nextPut: c ] ].
	self pushNotEmpty: s start: start
]

{ #category : #scanning }
GplScannerBase >> scanInlineComment [
	| c endOfLine s start |
	endOfLine := false.
	s := self writeStream.
	start := input position + 1.
	[ input atEnd or: [ endOfLine ] ]
		whileFalse: [ c := input next.
			(self class isLineEndFirst: c)
				ifTrue: [ endOfLine := true.
					input skip: -1 ]
				ifFalse: [ s nextPut: c ] ].
	self pushNotEmpty: s start: start
]

{ #category : #scanning }
GplScannerBase >> scanLineEnd: aCharacter [
	| length |
	length := 0.
	aCharacter = Character cr
		ifTrue: [ self pushWord: #cr.
			length := length + 1.
			self peek2 = Character lf
				ifTrue: [ length := length + 1 ].
			input skip: length.
			^ self ].
	aCharacter = Character lf
		ifTrue: [ length := length + 1.
			input skip: length.
			^ self pushWord: #cr ]
]

{ #category : #scanning }
GplScannerBase >> scanNoSpace [
	| space s start |
	space := false.
	s := self writeStream.
	start := input position + 1.
	[ input atEnd or: [ space ] ]
		whileFalse: [ | c |
			c := input next.
			space := self isTabOrSpace: c.
			space
				ifFalse: [ space := '()' includes: c ].
			space
				ifFalse: [ s nextPut: c ] ].
	self pushNotEmpty: s start: start
]

{ #category : #scanning }
GplScannerBase >> scanNumber [
	"TODO: implements floating point expression. ex. 1E-5"

	| accept s start exponensialCount minusCount |
	accept := true.
	s := self writeStream.
	start := input position + 1.
	exponensialCount := 0.
	minusCount := 0.
	[ input atEnd not and: [ accept ] ]
		whileTrue: [ | c |
			c := input next.
			c = $E
				ifTrue: [ exponensialCount >= 1
						ifTrue: [ self error: 'Illigal Number format' ].
					exponensialCount := exponensialCount + 1 ].
			(c = $- or: [ c = $# ])
				ifTrue: [ s contents
						ifNotEmpty: [ s contents last isDigit
								ifTrue: [ accept := false ] ].
					minusCount := minusCount + 1 ].
			accept
				ifTrue: [ accept := self class isNumberAllowed: c.
					accept
						ifTrue: [ s nextPut: c ] ] ].
	input atEnd
		ifTrue: [ accept
				ifFalse: [ input skip: -1 ] ]
		ifFalse: [ input skip: -1 ].
	self pushNotEmpty: s start: start
]

{ #category : #scanning }
GplScannerBase >> scanRangeComment [
	| c endOfComment s start |
	endOfComment := false.
	s := self writeStream.
	start := input position + 1.
	[ input atEnd or: [ endOfComment ] ]
		whileFalse: [ c := input next.
			c = $'
				ifTrue: [ endOfComment := true ].
			s nextPut: c ].
	self pushNotEmpty: s start: start
]

{ #category : #scanning }
GplScannerBase >> scanString [
	| count s end start |
	count := 0.
	end := false.
	s := self writeStream.
	start := input position + 1.
	[ input atEnd or: [ end ] ]
		whileFalse: [ | c |
			c := input next.
			c = $"
				ifTrue: [ count := count + 1 ].
			c = $"
				ifFalse: [ end := count \\ 2 = 0 ].
			end
				ifFalse: [ s nextPut: c ] ].
	input atEnd
		ifTrue: [ end
				ifTrue: [ input skip: -1 ] ]
		ifFalse: [ input skip: -1 ].
	s contents = '"'
		ifTrue: [ ^ self error: 'MISSING ". STRING NOT TERMINATED.' ].
	s contents last = $"
		ifFalse: [ ^ self error: 'MISSING ". STRING NOT TERMINATED.' ].
	self pushNotEmpty: s start: start
]

{ #category : #accessing }
GplScannerBase >> scanToken [
	| c c2 start |
	input atEnd
		ifTrue: [ ^ self ].
	c := input peek.
	c ifNil: [ ^ self ].
	(self class isTabOrSpace: c)
		ifTrue: [ ^ self handleBlanks ].
	(self class isNameFirst: c)
		ifTrue: [ ^ self scanWord ].
	(self class isNumberFirst: c)
		ifTrue: [ ^ self scanNumber ].
	c = $"
		ifTrue: [ ^ self scanString ].
	c = $|
		ifTrue: [ ^ self scanInlineComment ].
	c = $`
		ifTrue: [ ^ self scanRangeComment ].
	c = $^
		ifTrue: [ 2 timesRepeat: [ c := input next ].
			^ self ].
	"c := input next."
	start := input position + 1.
	self char2Words
		do: [ :each | 
			c = each first
				ifTrue: [ c2 := self peek2.
					c2 = each second
						ifTrue: [ input skip: 2.
							^ self pushNotEmpty: each readStream start: start ] ] ].
	('()[]:;' includes: c)
		ifTrue: [ input skip: 1.
			^ self pushNotEmpty: c asString readStream start: start ].
	c isSpecial
		ifTrue: [ input skip: 1.
			^ self pushNotEmpty: c asString readStream start: start ].
	(self class isLineEndFirst: c)
		ifTrue: [ ^ self scanLineEnd: c ].
	self error: 'USE ILLIGAL CHARACTER: ' , c asString printString
]

{ #category : #scanning }
GplScannerBase >> scanWord [
	| accept s start |
	start := input position.
	accept := true.
	s := self writeStream.
	start := input position + 1.
	[ input atEnd not and: [ accept ] ]
		whileTrue: [ | c |
			c := input next.
			accept := self class isNameAfterSecond: c.
			accept
				ifTrue: [ s nextPut: c ] ].
	s contents size > 32
		ifTrue: [ self error: 'VARIABLE NAME LIMIT 32' ].
	input atEnd
		ifTrue: [ accept
				ifFalse: [ input skip: -1 ] ]
		ifFalse: [ input skip: -1 ].
	self pushNotEmpty: s start: start
]

{ #category : #private }
GplScannerBase >> skipBlanks [
	| noSpace |
	input atEnd
		ifTrue: [ ^ self ].
	noSpace := false.
	[ input atEnd or: [ noSpace ] ]
		whileFalse: [ | c |
			c := input next.
			noSpace := (self class isTabOrSpace: c) not ].
	input atEnd
		ifTrue: [ noSpace
				ifTrue: [ input skip: -1 ] ]
		ifFalse: [ input skip: -1 ]
]

{ #category : #parse }
GplScannerBase >> splitTokens: aString [
	self splitTokensFrom: aString readStream.
	^ words asArray
]

{ #category : #'private-scanning' }
GplScannerBase >> splitTokensFrom: aStream [
	| count infinit lastPos |
	input := aStream.
	infinit := false.
	count := 0.
	lastPos := 0.
	[ input atEnd or: [ infinit ] ]
		whileFalse: [ self scanToken.
			lastPos = input position
				ifTrue: [ count := count + 1.
					count > 1000
						ifTrue: [ infinit := true ] ].
			infinit
				ifTrue: [ Transcript
						cr;
						show: '*** WARNING *** infinit loop in parser'.
					lastPos := input position ] ]
]

{ #category : #private }
GplScannerBase >> writeStream [
	^ WriteStream on: (String new: 1000)
]
