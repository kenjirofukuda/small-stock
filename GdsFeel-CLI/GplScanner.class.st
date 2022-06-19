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
	#name : #GplScanner,
	#superclass : #GplScannerBase,
	#instVars : [
		'source',
		'ranges',
		'mergeAsVector'
	],
	#classVars : [
		'OperatorSpec',
		'OperatorStrings'
	],
	#category : #'GdsFeel-CLI-Kernel'
}

{ #category : #private }
GplScanner class >> assertGplTokens: aCollection [
	self
		assert: [ aCollection allSatisfy: [ :each | each isMemberOf: GplToken ] ]
]

{ #category : #'instance creation' }
GplScanner class >> fromFile: aFileReference [
	^ (self new
		source: aFileReference asFileReference readStream contents)
		splitRanges;
		yourself
]

{ #category : #private }
GplScanner class >> initialize [
	"self initialize."

	| firstWordBlock |
	OperatorSpec := nil.
	firstWordBlock := [ :str | 
	| col |
	col := str findTokens: ' '.
	col size = 1
		ifTrue: [ str ]
		ifFalse: [ col first ] ].
	OperatorStrings := (Array
		streamContents: [ :s | 
			self operatorSpec
				do: [ :assoc | 
					s
						nextPutAll: (assoc value collect: [ :key | firstWordBlock value: key ]) ] ])
		asSet
]

{ #category : #testing }
GplScanner class >> isNumberFragment: aString [
	^ (GdsDglType bestClassOfStatement: aString) isNil not
]

{ #category : #testing }
GplScanner class >> isOperatorFragment: aString [
	| upStr |
	upStr := aString asUppercase.
	(OperatorStrings includes: upStr)
		ifTrue: [ ^ true ].
	aString size = 1
		ifTrue: [ ^ '+-*%;,[]' includes: aString first ].
	^ false
]

{ #category : #specification }
GplScanner class >> lookupOperatorSpec [
	"GplParser operatorSpec explore."

	^ {(8r377 -> #('[]')).
	(8r20
		->
			#('ABS' 'ARCTAN' 'CEILING' 'COS' 'FLOOR' 'GRADEDOWN' 'GRADEUP' 'LN' 'NOT' 'PI' 'SIN' 'SORT' 'SORTDOWN' 'TAN' '+ (monadic)' '- (monadic)' '* (monadic)' '% (monadic)')).
	(8r17 -> #('LOGBASE' 'POWER')).
	(8r16 -> #('MAX' 'MIN' 'MOD' '* (dyadic)' '% (dyadic)')).
	(8r15 -> #('+ (dyadic)' '- (dyadic)')).
	(8r13
		-> #('EQ' 'GEQ' 'GT' 'IN' 'LEQ' 'NEQ' '=' '<' '>' '<=' '>=' '<>')).
	(8r12 -> #('OR' 'XOR' 'NOR')).
	(8r11 -> #('AND' 'NAND')).
	(8r10
		-> #('IOTA' 'SHAPE' 'LENGTH' 'SIZE' 'TYPEOF' 'RANK' ', (monadic)')).
	(8r7
		->
			#('INDEXOF' 'RESHAPE' 'DROP' 'SAVE' 'SUBSTRING' 'DSELECT' 'INDICES_OF')).
	(8r6 -> #(', (dyadic)')).
	(8r5 -> #(';')).
	(8r0 -> #(':='))}
]

{ #category : #specification }
GplScanner class >> operatorSpec [
	^ OperatorSpec
		ifNil: [ OperatorSpec := (self lookupOperatorSpec
				collect: [ :assoc | assoc key -> assoc value asSet ]) asArray ]
]

{ #category : #evaluter }
GplScanner class >> splitTokens: aString [
	| parser |
	parser := self new source: aString.
	parser mergeAsVector: false.
	parser splitRanges.
	^ (parser tokens collect: [ :r | r fragment ]) asArray
]

{ #category : #evaluter }
GplScanner class >> tokensFrom: aString [
	| parser |
	parser := self new source: aString.
	parser splitRanges.
	^ parser tokens
]

{ #category : #private }
GplScanner >> assertGplTokens: aCollection [
	self class assertGplTokens: aCollection
]

{ #category : #accessing }
GplScanner >> decodeSource [
	| prevRange |
	^ self tokens
		do: [ :r | 
			self fragmentOfRange: r.
			prevRange := r ]
]

{ #category : #accessing }
GplScanner >> fragmentOfRange: aGplRange [
	| s |
	s := (self source isKindOf: String)
		ifTrue: [ self source copyFrom: aGplRange start to: aGplRange end ]
		ifFalse: [ self source contents copyFrom: aGplRange start to: aGplRange end ].
	(s
		anySatisfy: [ :each | 
			{Character cr.
			Character lf} includes: each ])
		ifTrue: [ ^ #cr ].
	^ s
]

{ #category : #private }
GplScanner >> handleBlanks [
	self scanBlanks
]

{ #category : #initialization }
GplScanner >> initialize [
	super initialize.
	ranges := OrderedCollection new
]

{ #category : #testing }
GplScanner >> mergeAsVector [
	^ mergeAsVector ifNil: [ mergeAsVector := true ]
]

{ #category : #accessing }
GplScanner >> mergeAsVector: aBoolean [
	mergeAsVector := aBoolean
]

{ #category : #analysis }
GplScanner >> negativeToSubtractTokens: aGplTokens rejectAfter: aRemoveCollection [
	| prevToken newTokens extracted |
	newTokens := OrderedCollection new.
	extracted := #().
	prevToken := nil.
	(aGplTokens reject: [ :token | token isSpace ])
		do: [ :token | 
			token isNegativeNumber
				ifTrue: [ prevToken
						ifNotNil: [ prevToken isBreakNegativeNumber
								ifTrue: [ extracted := token extractNegativeNumber.
									aRemoveCollection add: token -> extracted ] ] ].
			newTokens
				addAll: (extracted ifEmpty: [ Array with: token ] ifNotEmpty: [ extracted ]).
			extracted := #().
			prevToken := token ].
	^ newTokens
]

{ #category : #private }
GplScanner >> pushNotEmpty: aWriteStream start: aInteger [
	aWriteStream contents ifEmpty: [ ^ self ].
	self start: aInteger length: aWriteStream contents size
]

{ #category : #'range recording' }
GplScanner >> rangeType: aSymbol start: s end: e [
	^ ranges
		add:
			(GplToken
				start: s
				end: e
				type: aSymbol
				parser: self)
]

{ #category : #accessing }
GplScanner >> ranges [
	^ ranges
]

{ #category : #analysis }
GplScanner >> resolveLabelFromTokens: aGplTokens [
	| prevToken removeTokens |
	removeTokens := OrderedCollection new.
	prevToken := nil.
	(aGplTokens reject: [ :token | token type = #space ])
		do: [ :token | 
			token fragment = ':'
				ifTrue: [ prevToken
						ifNotNil: [ #unresolved = prevToken type
								ifTrue: [ prevToken end: token end.
									removeTokens add: token ] ] ].
			prevToken := token ].
	^ aGplTokens reject: [ :token | removeTokens includes: token ]
]

{ #category : #scanning }
GplScanner >> scanLineEnd: aCharacter [
	| start length |
	start := input position + 1.
	length := 0.
	aCharacter = Character cr
		ifTrue: [ length := 1.
			self pushWord: #cr.
			input peek = Character lf
				ifTrue: [ length := length + 1 ].
			input skip: length.
			self rangeType: #cr start: start end: start + length - 1.
			^ self ].
	aCharacter = Character lf
		ifTrue: [ length := 1.
			input skip: 1.
			self rangeType: #cr start: start end: start + length - 1.
			^ self pushWord: #cr ]
]

{ #category : #accessing }
GplScanner >> source [
	^ source
]

{ #category : #accessing }
GplScanner >> source: aString [
	source := aString
]

{ #category : #private }
GplScanner >> splitRanges [
	super splitTokens: source
]

{ #category : #parse }
GplScanner >> splitTokens: aString [
	^ self splitTokens: aString withSpace: false
]

{ #category : #private }
GplScanner >> splitTokens: aString withSpace: aBoolean [
	| result |
	self source: aString.
	self splitRanges.
	result := self tokens collect: [ :r | r fragment ].
	aBoolean
		ifFalse: [ result := (self tokens reject: [ :r | r type = #space ])
				collect: [ :r | r fragment ] ].
	^ result
]

{ #category : #private }
GplScanner >> splitTokensFrom: aStream [
	| result p1 p2 p3 p4 newRanges vectorRanges colAssoc |
	self source: aStream contents.
	result := super splitTokensFrom: aStream.
	p1 := (self ranges reject: [ :t | t type = #space ]) asArray.
	colAssoc := OrderedCollection new.
	p2 := self negativeToSubtractTokens: p1 rejectAfter: colAssoc.
	colAssoc
		ifNotEmpty: [ newRanges := OrderedCollection new.
			ranges
				do: [ :t | 
					(colAssoc detect: [ :assoc | assoc key == t ] ifNone: [  ])
						ifNotNil: [ :assoc | newRanges addAll: assoc value ]
						ifNil: [ newRanges add: t ].
					ranges := newRanges ] ].
	self mergeAsVector
		ifTrue: [ p3 := self vectorAnalysisFromTokens: p2.
			p4 := (self ranges , p3) asSet asArray
				sort: [ :t1 :t2 | t1 start < t2 start ].
			vectorRanges := p4 select: [ :t | t type = #vector ].
			newRanges := p4
				reject: [ :t | 
					vectorRanges
						anySatisfy:
							[ :vt | t ~~ vt and: [ t start >= vt start and: [ t end <= vt end ] ] ] ] ]
		ifFalse: [ newRanges := ranges ].
	ranges := self resolveLabelFromTokens: newRanges
]

{ #category : #accessing }
GplScanner >> splitedWords [
	^ self tokens collect: [ :r | r fragment ]
]

{ #category : #'range recording' }
GplScanner >> start: s end: e [
	^ self rangeType: #unresolved start: s end: e
]

{ #category : #'range recording' }
GplScanner >> start: s length: l [
	^ self start: s end: s + l - 1
]

{ #category : #accessing }
GplScanner >> tokens [
	^ self tokensIgnoreSpace: true
]

{ #category : #accessing }
GplScanner >> tokensIgnoreSpace: aBoolean [
	aBoolean
		ifTrue: [ ^ (ranges reject: [ :r | r fragment trimBoth isEmpty ]) asArray ].
	^ ranges asArray
]

{ #category : #analysis }
GplScanner >> vectorAnalysisFromTokens: aGplTokens [
	"TODO: remove duplicate flavor GplEvaluator's "

	| stream vectorTokens pushToken token newOutput |
	self assertGplTokens: aGplTokens.
	newOutput := OrderedCollection new.
	vectorTokens := OrderedCollection new.
	pushToken := [ vectorTokens
		ifNotEmpty: [ | newToken |
			newToken := GplToken newFromTokens: vectorTokens.
			newOutput add: newToken.
			vectorTokens := OrderedCollection new ] ].
	stream := ReadStream on: aGplTokens.
	[ stream atEnd ]
		whileFalse: [ token := stream next.
			token type = #number
				ifTrue: [ vectorTokens add: token ]
				ifFalse: [ pushToken value.
					newOutput add: token ] ].
	pushToken value.
	^ newOutput asArray
]
