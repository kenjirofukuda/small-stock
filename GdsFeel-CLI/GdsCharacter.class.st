"
A GdsCharacter is Character on GDSII.

Character literal expression is not GPL.

""A"" is a shpe 1 vector.
real character represents ""A""[1].

special characters are:

readable notation           octal notation
""<NUL>""          equivarent ""<0>""
""<BEL>""          equivarent ""<7>""
""<TAB>""          equivarent ""<11>""
""<LF>""           equivarent ""<12>""
""<FF>""           equivarent ""<14>""
""<CR>""           equivarent ""<15>""
""<NL>""           equivarent ""<15>""
""<ESC>""          equivarent ""<33>""
""<BROFF>""        equivarent ""<36>""
""<BRON>""         equivarent ""<37>""
""<QT>""           equivarent ""<42>""
                            ""<74>""   less than
                            ""<75>""   grator than
""<DEL>""          equivarent ""<177>""


 


"
Class {
	#name : #GdsCharacter,
	#superclass : #GdsDglType,
	#classVars : [
		'KeyToOctalMap'
	],
	#category : #'GdsFeel-CLI-DGL'
}

{ #category : #accessing }
GdsCharacter class >> acceptRegexPattern [
	^'[0-9]+'
]

{ #category : #testing }
GdsCharacter class >> acceptableExpression: aString [
	^false.
]

{ #category : #accessing }
GdsCharacter class >> asciiValueInsideCharMarkLiteral: aCharMarkLiteral [
	| map octString v|
	self assert: aCharMarkLiteral notEmpty.
	map := self specialLiteralToOctalExprMap .
	octString := map at: aCharMarkLiteral asUppercase  ifAbsent:[aCharMarkLiteral].
	octString isAllOctal
		ifFalse: [^self syntaxError: #octalExprError].
	v := Integer readFrom: octString readStream radix: 8.
	((0 to: 255) includes: v) ifFalse:[^self syntaxError:#characterRangeError].
	^v
]

{ #category : #constans }
GdsCharacter class >> bel [
	^ self fromCharMarkLiteral: 'BEL'.
]

{ #category : #constans }
GdsCharacter class >> broff [
	^ self fromCharMarkLiteral: 'BROFF'.
]

{ #category : #constans }
GdsCharacter class >> bron [
	^ self fromCharMarkLiteral: 'BRON'.
]

{ #category : #constans }
GdsCharacter class >> cr [
	^ self fromCharMarkLiteral: 'CR'.
]

{ #category : #constans }
GdsCharacter class >> del [
	^ self fromCharMarkLiteral: 'DEL'.
]

{ #category : #constans }
GdsCharacter class >> esc [
	^ self fromCharMarkLiteral: 'ESC'.
]

{ #category : #constans }
GdsCharacter class >> ff [
	^ self fromCharMarkLiteral: 'FF'.
]

{ #category : #'instance creation' }
GdsCharacter class >> fromAsciiValue: asciiValue [
	^self new stringValue: asciiValue
]

{ #category : #'instance creation' }
GdsCharacter class >> fromCharMarkLiteral: octalExprOrCharSymbol [
	^ GdsCharacter fromAsciiValue: 
		(self asciiValueInsideCharMarkLiteral: octalExprOrCharSymbol).
]

{ #category : #'instance creation' }
GdsCharacter class >> fromLiteral: aString [
	^self error: 'GdsCharacter can''t instanciate by #fromLiteral:'
]

{ #category : #'instance creation' }
GdsCharacter class >> fromSmalltalk: aObject [
	^self fromAsciiValue: aObject asciiValue 
]

{ #category : #'instance creation' }
GdsCharacter class >> initialize [
	"GdsCharacter initialize."
	super initialize.
	KeyToOctalMap := self lookuplToOctalExprMap. 
]

{ #category : #testing }
GdsCharacter class >> isAcceptableSmalltalkObject: anObject [
	^anObject isCharacter and: [anObject isOctetCharacter]
]

{ #category : #constans }
GdsCharacter class >> lf [
	^ self fromCharMarkLiteral: 'LF'.
]

{ #category : #private }
GdsCharacter class >> lookuplToOctalExprMap [
	"return ocatal expr String"
	
	^Dictionary newFrom: {
	'NUL' -> '0' .
	'BEL' -> '7' .
	'TAB' -> '11' .
	'LF' -> '12' .
	'FF' -> '14' .
	'CR' -> '15' .
	'NL' -> '15' .
	'ESC' -> '33' .
	'BROFF' -> '36' .
	'BRON' -> '37' .
	'QT' -> '42' .
	'DEL' -> '177' .
	}.

]

{ #category : #accessing }
GdsCharacter class >> maxValue [
	^255
]

{ #category : #accessing }
GdsCharacter class >> minValue [
	^0
]

{ #category : #accessing }
GdsCharacter class >> mode [
	^4
]

{ #category : #constans }
GdsCharacter class >> nl [
	^ self fromCharMarkLiteral: 'NL'.
]

{ #category : #constans }
GdsCharacter class >> nul [
	^ self fromCharMarkLiteral: 'NUL'.
]

{ #category : #constans }
GdsCharacter class >> qt [
	^ self fromCharMarkLiteral: 'QT'.
]

{ #category : #accessing }
GdsCharacter class >> specialLiteralToOctalExprMap [
	KeyToOctalMap ifNil: [KeyToOctalMap := self lookuplToOctalExprMap].
	^KeyToOctalMap.
]

{ #category : #accessing }
GdsCharacter class >> storageCost [
	^ 1
]

{ #category : #constans }
GdsCharacter class >> tab [
	^ self fromCharMarkLiteral: 'TAB'.
]

{ #category : #accessing }
GdsCharacter class >> typeString [
	^'CHAR'
]

{ #category : #'as yet unclassified' }
GdsCharacter >> asSmalltalkCharacter [
	^Character value: self asciiValue
]

{ #category : #'as yet unclassified' }
GdsCharacter >> asciiValue [
	^self asSmalltalkValue asInteger.
]

{ #category : #'as yet unclassified' }
GdsCharacter >> gplString [
	^(Character value: (self asSmalltalkValue asInteger)) asString
]
