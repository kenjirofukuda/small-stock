"
A GplSyntax is GPLII syntax checker.

Instance Variables

"
Class {
	#name : #GplSyntax,
	#superclass : #GplTokenHandler,
	#instVars : [
		'model'
	],
	#category : #'GdsFeel-CLI-Kernel'
}

{ #category : #'as yet unclassified' }
GplSyntax class >> check: aString [
	| tokens |
	tokens := GplScanner tokensFrom: aString.
	self new checkFromTokens: tokens.
	
]

{ #category : #'private check' }
GplSyntax >> assignCheck: aGplTokens [
	| assignToken leftTokens keywordToken |
	assignToken := aGplTokens detect: [:each | each fragment = ':='] ifNone: [nil].
	assignToken ifNil: [^self].

	leftTokens := self leftCheckFor: assignToken.
	self rightCheckFor: assignToken.

	keywordToken := leftTokens detect: [:each | 
		GplHandler hasCommandName: each fragment] ifNone: [nil].
	keywordToken 
		ifNotNil: [
			^self
				syntaxError: 'VARIABLE CAN''T ASSIGND TO PROCEDURE OR FUNCTION'
				token: keywordToken]
]

{ #category : #private }
GplSyntax >> betweenCheck: aGplTokens openFragment: aOpenFragment closeFragment: aCloseFragment [
	| openParlens closeParlens |
	openParlens := aGplTokens select: [:each | each fragment = aOpenFragment].
	closeParlens := aGplTokens select: [:each | each fragment = aCloseFragment].
	(openParlens size + closeParlens size) = 0 ifTrue: [^self.].
	(openParlens size > closeParlens size)
		ifTrue: [^self syntaxError: ('EXTRA ') token: openParlens first].
	(openParlens size < closeParlens size)
		ifTrue: [^self syntaxError: ('EXTRA ') token: closeParlens last.]
		
]

{ #category : #'private check' }
GplSyntax >> cantUseCheck: aGplTokens [ 
	self isInteractive ifFalse: [^self].	
	aGplTokens do: [:each |
		(GplToken isProgramOnlyKeyword: each fragment )
				ifTrue: [^self syntaxError: 'KEYWORD NOT LEAGAL IN THIS CONTEXT' token: each]].

]

{ #category : #check }
GplSyntax >> checkFromTokens: aGplTokens [ 
	self beforeEvaluateTokens: aGplTokens.
	self depthCheck: aGplTokens.
	self numberLiteralCheck: aGplTokens.
	self declareCheck: aGplTokens.
	self assignCheck: aGplTokens.
	self cantUseCheck: aGplTokens.	

]

{ #category : #'private check' }
GplSyntax >> declareCheck: aGplTokens [
	self methodDeclareCheck: aGplTokens.
	self variableDeclareCheck: aGplTokens.		
]

{ #category : #'private check' }
GplSyntax >> depthCheck: aGplTokens [ 
	self parlenDepthCheck: aGplTokens.
	self subscriptDepthCheck: aGplTokens.
	self 
		missMatchCheck: aGplTokens 
		openFragments: { '(' . '[' } closeFragments: { ')' . ']' }
]

{ #category : #testing }
GplSyntax >> hasVariableName: aWord [
	model ifNil: [^false].
	^model hasVariableName: aWord
]

{ #category : #private }
GplSyntax >> insideEmptyCheck: aGplTokens openFragment: aOpenFragment closeFragment: aCloseFragment [
	| openParlens |
	openParlens := aGplTokens select: [:each | each fragment = aOpenFragment].
	openParlens do: [:each |
		|rightTokens |
		rightTokens := each rightTokens.
		rightTokens
			ifNotEmpty: [
				(rightTokens first fragment = aCloseFragment)
					ifTrue: [^each]]].
	^nil.
]

{ #category : #testing }
GplSyntax >> isDefined: aWord [
	model ifNil: [^false].
	^model isDefined: aWord
]

{ #category : #testing }
GplSyntax >> isInteractive [
	model ifNil: [^true].
	^model isInteractive
]

{ #category : #'private check' }
GplSyntax >> leftCheckFor: anAssignToken [
	| leftTokens expressionToken |
	leftTokens := anAssignToken leftTokens
		select: [:each | each depthOfSubscript = anAssignToken depthOfSubscript].
	expressionToken := leftTokens
		 detect: [:each | each fragment =')'] ifNone: [nil].
	expressionToken
		ifNotNil: [^self syntaxError: 'ILLIGAL STORE OPERATION'].
		
	leftTokens := anAssignToken leftTokensOfSameDepth .
	leftTokens
		ifEmpty: [^self syntaxError: 'MISSING LEFT VARIABLE FOR' token: anAssignToken].
	^leftTokens
]

{ #category : #'private check' }
GplSyntax >> methodDeclareCheck: aGplTokens [
	| voidToken voidTokens |
	voidTokens := aGplTokens
		select: [:each | 
			(each fragment first isLetter 
			and: [ (self hasVariableName:  each fragment) not])
			and: [ GplHandler isVoid: each fragment]].
	voidTokens ifEmpty: [^self].
	voidToken := voidTokens first.
	voidToken leftTokens isEmpty 
		ifFalse: [
			^self 
				syntaxError: 'NOT A VALUEABLE PROCEDURE CALL'  token: voidToken].
	
]

{ #category : #private }
GplSyntax >> missMatchCheck: aGplTokens openFragments: aOpenFragments closeFragments: aCloseFragments [
	| topToken |
	self resetStack.
	aGplTokens
		do: [:each |
			each fragment = aOpenFragments first
				ifTrue: [self push: each].
			each fragment = aOpenFragments second
				ifTrue: [self push: each].	
			each fragment = aCloseFragments first
				ifTrue: [
					topToken := self pop.
					topToken fragment = aOpenFragments first
						ifFalse: [
							^self 
								syntaxError: 'MISS MATCH MUST: ', aCloseFragments second, ' BUT'
								token: each].].
			each fragment = aCloseFragments second
				ifTrue: [
					topToken := self pop.
					topToken fragment = aOpenFragments second
						ifFalse: [
							^self
								syntaxError: ('MISS MATCH MUST: ', aCloseFragments first, ' BUT')
								token: each].].]
				
]

{ #category : #accessing }
GplSyntax >> model: aModel [
	model := aModel
]

{ #category : #'private check' }
GplSyntax >> numberLiteralCheck: aGplTokens [
	| unresolvedTokens |
	unresolvedTokens := aGplTokens select: [:each | 
			(each type =  #unresolved 
		and: [(GplScannerBase isNameFirst: each fragment first) not])
		and: [GplScanner isNumberFragment: each fragment]].
	unresolvedTokens ifEmpty: [^self].
		
	^self 
		syntaxError: 'INVALID NUMERIC FORMAT'
		token: unresolvedTokens first.
]

{ #category : #'private check' }
GplSyntax >> parlenDepthCheck: aGplTokens [ 
	| emptyToken |
	self betweenCheck:  aGplTokens openFragment:  '(' closeFragment:  ')' .
	emptyToken := self insideEmptyCheck: aGplTokens openFragment:  '('  closeFragment:  ')'.
	emptyToken
		ifNotNil: [^self syntaxError: 'EMPTY EXPRESSION ()'].
]

{ #category : #'private check' }
GplSyntax >> rightCheckFor: anAssignToken [
	| rightTokens voidToken |		
	rightTokens := anAssignToken rightTokens.
	rightTokens
		ifEmpty: [^self syntaxError: 'MISSING RIGHT EXPRESSION FOR' token: anAssignToken].
	voidToken := anAssignToken 
		rightTokens
			detect: [:each | 
				((each type ~= #number
				and: [each fragment first isLetter ])
				and: [ (self hasVariableName:  each fragment) not])
				and: [GplHandler isVoid: each fragment]] 
			ifNone: [nil].
	voidToken
		ifNotNil: [
			^self 
				syntaxError: 'NOT A VALUEABLE PROCEDURE CALL' 
				token: voidToken ].
]

{ #category : #'private check' }
GplSyntax >> subscriptDepthCheck: aGplTokens [ 
	| emptyToken |
	self betweenCheck:  aGplTokens openFragment:  '[' closeFragment:  ']'.
	emptyToken := self insideEmptyCheck: aGplTokens openFragment:  '['  closeFragment:  ']'.
	emptyToken
		ifNotNil: [^self syntaxError: 'EMPTY SUBSCRIPT EXPRESSION []'].	 			
]

{ #category : #private }
GplSyntax >> syntaxError: aMessage token: aGplToken [
	^self syntaxError: (self syntaxMessage: aMessage token: aGplToken)
]

{ #category : #'private check' }
GplSyntax >> variableDeclareCheck: aGplTokens [
	"allow undefined "
	"left operand and isInteractive"
	| unresolvedTokens |
	unresolvedTokens := aGplTokens select: [:each | 
		each type =  #unresolved and: [(self isDefined: each fragment) not]].
	unresolvedTokens ifEmpty: [^self].
	self isInteractive
		ifFalse: [
			^self 
				syntaxError: 'VARIABLE NOT DEFINED'
				token: unresolvedTokens first].
	
	unresolvedTokens do: [:each |
		(each rightTokens isEmpty not 
				and: [each rightTokens first fragment = ':='])
			ifFalse: [
				^self 
					syntaxError: 'VARIABLE NOT DEFINED'
					token: each]].
]
