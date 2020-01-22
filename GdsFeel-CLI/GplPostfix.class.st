Class {
	#name : #GplPostfix,
	#superclass : #GplTokenHandler,
	#instVars : [
		'outTokens'
	],
	#category : #'GdsFeel-CLI-Kernel'
}

{ #category : #'as yet unclassified' }
GplPostfix class >> isOperator: aGplTokenOrString [
	| fragment |
	fragment := (aGplTokenOrString isKindOf: GplAtomicToken)
		ifTrue: [ aGplTokenOrString fragment ]
		ifFalse: [ aGplTokenOrString ].
	(GplHandler hasCommandName: fragment asUppercase)
		ifTrue: [ ^ true ].
	^ GplScanner isOperatorFragment: fragment
]

{ #category : #'analysis-postfix' }
GplPostfix >> gotOperator: aToken [
	| done |
	self precedenceOf: aToken.
	done := false.
	[stack isEmpty or: [done]]
		whileFalse: [
			| topToken |
			topToken := self pop.
			(topToken fragment = '(' or: [topToken fragment = '['])
				ifTrue: [self push: topToken. done := true]
				ifFalse: [
					((self precedenceOf: topToken) < (self precedenceOf: aToken))
						ifTrue: [self push: topToken. done := true]
						ifFalse: [outTokens add: topToken]]].
	self push: aToken.
]

{ #category : #'analysis-postfix' }
GplPostfix >> gotParen: aToken [
	| done |
	done := false.
	[stack isEmpty or: [done]]
		whileFalse: [
			| topToken |
			topToken := self pop.
			topToken fragment = '('
				ifTrue: [done := true.]
				ifFalse: [outTokens add: topToken]]
]

{ #category : #'analysis-postfix' }
GplPostfix >> gotSlice: aToken [
	| done |
	done := false.
	[stack isEmpty or: [done]]
		whileFalse: [
			| topToken |
			topToken := self pop.
			outTokens add: topToken.
			topToken fragment = '['
				ifTrue: [
					done := true.]]
]

{ #category : #'analysis-postfix' }
GplPostfix >> guessAgumentType: aToken monadicBlock: aMonadicBlock dyadicBlock: aDyadicBlock [
	| leftTokens |
	leftTokens := aToken leftTokens.
	"leftTokens explore."
	leftTokens ifNotEmpty: [
		(self returnValueEnabled: leftTokens last)
			ifTrue: [
				aToken  argumentType:  #dyadic.
				^aDyadicBlock value]].
	aToken  argumentType: #monadic.
	^aMonadicBlock value.	

]

{ #category : #'initialize-release' }
GplPostfix >> initialize [
	super initialize.

]

{ #category : #'analysis-postfix' }
GplPostfix >> operatorSwitch: aGplToken [
	(aGplToken fragment = ':=')
		ifTrue: [self push: aGplToken. ^self].
	(aGplToken fragment = '(')
		ifTrue: [self push: aGplToken. ^self].
	(aGplToken fragment = '[')
		ifTrue: [self push: aGplToken. ^self].
	(aGplToken fragment = ')')
		ifTrue: [self gotParen: aGplToken. ^self].
	(aGplToken fragment = ']')
		ifTrue: [self gotSlice: aGplToken. ^self].
	(self class isOperator: aGplToken fragment)
		ifTrue: [self gotOperator: aGplToken. ^self].
	outTokens add: aGplToken.
	^self.	
]

{ #category : #'analysis-postfix' }
GplPostfix >> precedenceOf: aToken [
	GplScanner operatorSpec do: [:assoc |
		(assoc value includes: aToken fragment asUppercase)
			ifTrue: [^assoc key]].
	aToken fragment size = 1
		ifTrue: [
			('[]' includes: aToken fragment first)
				ifTrue: [^8r377].
			('*%' includes: aToken fragment first)
				ifTrue: [
					^self 
						guessAgumentType: aToken 
						monadicBlock: [8r20] 
						dyadicBlock: [8r16]].
			('+-' includes: aToken fragment first)
				ifTrue: [
					^self 
						guessAgumentType: aToken 
						monadicBlock: [8r20] 
						dyadicBlock: [8r15]].
			(',' includes: aToken fragment first)
				ifTrue: [
					^self 
						guessAgumentType: aToken 
						monadicBlock: [8r10] 
						dyadicBlock: [8r6]]].
	(GplBiContextHandler hasCommandName: aToken fragment)
		ifTrue: [aToken isProcedureCall ifTrue: [^8r-1]].
	(GplHandler isVoid: aToken fragment)
		ifTrue: [^8r-1].
	^8r555

]

{ #category : #'analysis-postfix' }
GplPostfix >> returnValueEnabled: aToken [
	('([' includes: aToken fragment first)
		ifTrue: [^false].
	(')]' includes: aToken fragment first)
		ifTrue: [^true].
	(GplHandler noArgReturnValueEnabled: aToken fragment)
		ifTrue: [^true].
	^aToken isOperator not
]

{ #category : #'analysis-postfix' }
GplPostfix >> translateToPostfixFromTokens: aGplTokens [
	self beforeEvaluateTokens: aGplTokens.
	outTokens := OrderedCollection new.
	aGplTokens do: [:token |
		self operatorSwitch: token].
	[stack isEmpty]
		whileFalse: [outTokens add: self pop].
	^outTokens asArray.
]
