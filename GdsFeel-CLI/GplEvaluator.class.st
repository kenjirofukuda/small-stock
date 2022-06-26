"
A GplEvaluter is GPLII Expression evaluter.

Instance Variables
	argStack:		<OrderedCollection>
	history:		<OrderedCollection>
	outTokens:		<OrderedCollection>
	stack:		<OrderedCollection>

argStack
	- postfix notation argument or result value stack

history
	- expression input history

outTokens
	- infix to postfix transform work area

stack
	- infix to postfix transform analysis stack

"
Class {
	#name : #GplEvaluator,
	#superclass : #GplTokenHandler,
	#instVars : [
		'history',
		'argStack',
		'varMap',
		'postfixTokens',
		'suspendContext',
		'resultMap',
		'junction',
		'console'
	],
	#category : #'GdsFeel-CLI-Kernel'
}

{ #category : #'as yet unclassified' }
GplEvaluator class >> arithmeticSelector: aGplToken [
	| sel |
	('POWER' sameAs: aGplToken fragment)
		ifTrue: [ ^ #raisedTo: ].
	sel := aGplToken fragment asSymbol.
	^ sel = #%
		ifTrue: [ #/ ]
		ifFalse: [ sel ]
]

{ #category : #'debug-utility' }
GplEvaluator class >> debugEvaluate: anGplExpression [
	| e tokens |
	e := self new.
	tokens := e tokensFrom: anGplExpression.
	e syntaxCheck: tokens.
	^ e evaluateLine: anGplExpression
]

{ #category : #private }
GplEvaluator >> assertGplTokens: aCollection [
	self
		assert: [ aCollection allSatisfy: [ :each | each isMemberOf: GplToken ] ]
]

{ #category : #private }
GplEvaluator >> assertGplValues: aCollection [
	self
		assert: [ aCollection allSatisfy: [ :each | each isKindOf: GdsDglType ] ]
]

{ #category : #accessing }
GplEvaluator >> console [
	^ console
]

{ #category : #accessing }
GplEvaluator >> console: aGdsConsole [
	console := aGdsConsole
]

{ #category : #'evaluator-inside' }
GplEvaluator >> evaluateArithmetic: aGplToken [
	(aGplToken fragmentForInspect endsWith: '(dyadic)')
		ifTrue: [ ^ self evaluateDyadicArithmetic: aGplToken ].
	(aGplToken fragmentForInspect endsWith: '(monadic)')
		ifTrue: [ ^ self evaluateMonadicArithmetic: aGplToken ].
	(self isDyadic: aGplToken)
		ifTrue: [ ^ self evaluateDyadicArithmetic: aGplToken ].
	^ self error: 'ILLIGAL ARGUMENT SIZE'
]

{ #category : #evaluator }
GplEvaluator >> evaluateAsString: aBlock [
	| result reply |
	result := nil.
	reply := ''.
	[ result := aBlock value ]
		on: Error
		do: [ :ex | 
			(ex isKindOf: GplPromptException)
				ifTrue: [ ex pass ].
			^ ex messageText ].
	result ifNotNil: [ reply := result gplString ].
	^ reply
]

{ #category : #'evaluator-inside' }
GplEvaluator >> evaluateAsVector: aGplToken [
	| arg1 |
	arg1 := self popArg.
	^ arg1 asGplValue asVector
]

{ #category : #'evaluator-inside' }
GplEvaluator >> evaluateAssign: aGplToken [
	| gv1 variableObject valueArg variableArg |
	self assert: [ aGplToken fragment = ':=' ].
	valueArg := self popArg.
	variableArg := self popArg.
	gv1 := valueArg asGplValue copy.
	variableObject := self
		getVariable: variableArg
		wantsStrictDeclare: false.
	variableObject gplValue: gv1.
	(variableArg isMemberOf: GplToken)
		ifTrue: [ variableArg type: #variable ].
	aGplToken == postfixTokens last
		ifTrue: [ ^ self voidReturn ].
	^ variableObject
]

{ #category : #'evaluator-inside' }
GplEvaluator >> evaluateBuiltinDyadic: aGplToken [
	^ self evaluateReshape: aGplToken
]

{ #category : #'evaluator-inside' }
GplEvaluator >> evaluateBuiltinMonadic: aGplToken [
	| sel arg1 gv1 |
	sel := aGplToken fragment asLowercase asSymbol.
	sel := sel = #arctan
		ifTrue: [ #arcTan ]
		ifFalse: [ sel ].	"special case"
	arg1 := self popArg.
	gv1 := arg1 asGplValue.
	^ gv1 perform: sel
]

{ #category : #evaluator }
GplEvaluator >> evaluateConsoleLine: aString [
	| tokens reply result |
	reply := aString.
	result := nil.
	aString
		ifNotEmpty: [ aString first = $\
				ifTrue: [ ^ self
						handleForKey: aString allButFirst
						line: self lastEvaluatedLine ] ].
	history add: aString.
	tokens := self tokensFrom: aString.
	[ self syntaxCheck: tokens ]
		on: Error
		do: [ :ex | ^ ex messageText ].
	^ self evaluateAsString: [ self evaluateLine: aString ]
]

{ #category : #'evaluator-inside' }
GplEvaluator >> evaluateDyadicArithmetic: aGplToken [
	| arg1 arg2 real1 real2 result gv1 gv2 |
	arg2 := self popArg.
	arg1 := self popArg.
	gv1 := arg1 asGplValue.
	gv2 := arg2 asGplValue.
	self
		debugLog:
			{gv1.
			gv2}.
	^ (gv1 rank = 0 and: [ gv2 rank = 0 ])
		ifTrue: [ | sel |
			real1 := gv1 asSmalltalkValue asFloat.
			real2 := gv2 asSmalltalkValue asFloat.
			sel := self class arithmeticSelector: aGplToken.
			result := (real1 perform: sel with: real2) asFloat.
			result asGdsValue ]
		ifFalse: [ | sel |
			sel := self selectorOf: aGplToken.
			result := gv1 perform: sel with: gv2.
			result ]
]

{ #category : #'evaluator-inside' }
GplEvaluator >> evaluateInspectMonadic: aGplToken [
	| sel arg1 gv1 |
	sel := aGplToken fragment asLowercase capitalized.
	sel := ('gplValueOf' , sel) asSymbol.
	arg1 := self popArg.
	gv1 := arg1 asGplValue.
	^ gv1 perform: sel
]

{ #category : #'evaluator-inside' }
GplEvaluator >> evaluateJoinVector: aGplToken [
	| rightArg leftArg leftArray rightArray leftType rightType |
	rightArg := self popArg.
	leftArg := self popArg.
	leftArray := leftArg asGplValue.
	rightArray := rightArg asGplValue.
	leftType := leftArray typeString.
	rightType := rightArray typeString.
	(leftType = 'CHAR' and: [ rightType = 'CHAR' ])
		ifTrue: [ ^ GdsString
				withAll: leftArray asVector elements , rightArray asVector elements ].
	(leftType ~= 'CHAR' and: [ rightType ~= 'CHAR' ])
		ifTrue: [ ^ GdsVector
				withAll: leftArray asVector elements , rightArray asVector elements ].
	^ self runtimeError: 'ILLIGAL TYPE CPNVERSION'
]

{ #category : #evaluator }
GplEvaluator >> evaluateLine: aString [
	| tokens |
	aString ifEmpty: [ ^ GdsNull instance ].
	argStack := nil.
	tokens := self tokensFrom: aString.
	tokens := self vectorAnalysisFromTokens: tokens.
	^ self evaluateTokens: tokens
]

{ #category : #'evaluator-inside' }
GplEvaluator >> evaluateList: aGplToken [
	| rightArg leftArg result leftValue rightValue |
	self fillListRightArgument: aGplToken.
	rightArg := self popArg.
	self fillListLeftArgument: aGplToken.
	leftArg := self popArg.
	result := GdsList new.
	leftValue := leftArg asGplValue.
	rightValue := rightArg asGplValue.
	result add: leftValue.
	result add: rightValue.
	^ result
]

{ #category : #'evaluator-inside' }
GplEvaluator >> evaluateMonadicArithmetic: aGplToken [
	| arg1 gv1 |
	arg1 := self popArg.
	gv1 := arg1 asGplValue.
	aGplToken fragment = '+'
		ifTrue: [ ^ gv1 mostCompactValue ].
	aGplToken fragment = '-'
		ifTrue: [ ^ gv1 negated ].
	aGplToken fragment = '*'
		ifTrue: [ ^ gv1 sign ].
	aGplToken fragment = '%'
		ifTrue: [ ^ gv1 reciprocal ]
]

{ #category : #evaluator }
GplEvaluator >> evaluatePostfixStream: aPostfixStream [
	| token result |
	argStack ifNil: [ argStack := OrderedCollection new ].
	[ aPostfixStream atEnd ]
		whileFalse: [ token := aPostfixStream next.
			self handleToken: token ].
	result := self popArg asGplValue.
	argStack ifNotEmpty: [ self error: 'EXPRESSION PARSED INCORRECTLY' ].
	^ result
]

{ #category : #evaluator }
GplEvaluator >> evaluatePostfixTokens: aGplTokens [
	^ self evaluatePostfixStream: (ReadStream on: aGplTokens)
]

{ #category : #'evaluator-inside' }
GplEvaluator >> evaluateReshape: aGplToken [
	| argRight argLeft gvRight gvLeft columnCount rowCount mustIntegerBlock |
	argRight := self popArg.
	argLeft := self popArg.
	gvLeft := argLeft asGplValue.
	gvRight := argRight asGplValue.
	gvLeft := gvLeft asVector.
	gvRight := gvRight asVector.
	mustIntegerBlock := [ :v | 
	v isInteger
		ifFalse: [ self runtimeError: 'SUBSCRIPT VALUE MUST BE INTEGLAL' ] ].
	gvLeft size = 1
		ifTrue: [ columnCount := (gvLeft at: 1) asSmalltalkValue.
			mustIntegerBlock value: columnCount.
			^ GdsMatrix fromGdsVector: gvRight col: columnCount ].
	gvLeft size = 2
		ifTrue: [ rowCount := (gvLeft at: 1) asSmalltalkValue.
			columnCount := (gvLeft at: 2) asSmalltalkValue.
			mustIntegerBlock value: rowCount.
			mustIntegerBlock value: columnCount.
			^ GdsMatrix fromGdsVector: gvRight row: rowCount col: columnCount ].
	^ self runtimeError: 'INVALID SHAPE FORMAT'
]

{ #category : #'evaluator-inside' }
GplEvaluator >> evaluateSubscript: aGplToken [
	(self hasMoreAssign: aGplToken)
		ifTrue: [ self debugLog: '*** skip subscription return'.
			^ self popArg ].
	^ self evaluateSubscriptReturn: aGplToken
]

{ #category : #'evaluator-inside' }
GplEvaluator >> evaluateSubscriptAssign: aGplToken [
	| assignValue valueArg variableArg subscriptArg subscriptValue target returnValue |
	self assert: [ aGplToken fragment = ':=' ].
	valueArg := self popArg.
	subscriptArg := self popArg.
	variableArg := self popArg.
	assignValue := valueArg asGplValue copy.
	subscriptValue := subscriptArg asGplValue.
	returnValue := assignValue.
	target := (self getVariable: variableArg wantsStrictDeclare: true)
		asGplValue.
	returnValue := target
		atSubscriptWithCheck: subscriptValue
		put: assignValue.
	aGplToken == postfixTokens last
		ifTrue: [ ^ self voidReturn ].
	^ returnValue
]

{ #category : #'evaluator-inside' }
GplEvaluator >> evaluateSubscriptReturn: aGplToken [
	| arg1 arg2 target subscript |
	arg2 := self popArg.
	arg1 := self popArg.
	target := arg1 asGplValue.
	subscript := arg2 asGplValue.
	^ target atSubscriptWithCheck: subscript
]

{ #category : #evaluator }
GplEvaluator >> evaluateTokens: aGplTokens [
	| postfixGenerator |
	postfixGenerator := GplPostfix new.
	postfixGenerator showsLog: self showsLog.
	postfixTokens := postfixGenerator
		translateToPostfixFromTokens: aGplTokens.
	self debugLog: postfixTokens printString.
	^ self evaluatePostfixTokens: postfixTokens
]

{ #category : #'evaluator-inside' }
GplEvaluator >> evaluateVector: aGplToken [
	(aGplToken fragmentForInspect endsWith: '(dyadic)')
		ifTrue: [ ^ self evaluateJoinVector: aGplToken ].
	(aGplToken fragmentForInspect endsWith: '(monadic)')
		ifTrue: [ ^ self evaluateAsVector: aGplToken ].
	^ self error: 'ILLIGAL ARGUMENT SIZE'
]

{ #category : #'evaluator-inside' }
GplEvaluator >> fillListLeftArgument: aGplToken [
	| leftTokens missingLeft |
	leftTokens := aGplToken leftTokens.
	missingLeft := leftTokens
		ifEmpty: [ true ]
		ifNotEmpty: [ '([' includes: leftTokens last fragment first ].
	missingLeft
		ifTrue: [ self pushArg: GdsNull instance ]
]

{ #category : #'evaluator-inside' }
GplEvaluator >> fillListRightArgument: aGplToken [
	| rightTokens missingRight |
	rightTokens := aGplToken rightTokens.
	missingRight := rightTokens
		ifEmpty: [ true ]
		ifNotEmpty: [ '])' includes: rightTokens first fragment first ].
	missingRight
		ifTrue: [ self pushArg: GdsNull instance ]
]

{ #category : #'context stack' }
GplEvaluator >> flushContextStacks [
	resultMap := nil.
	suspendContext := nil
]

{ #category : #'evaluator-inside' }
GplEvaluator >> getVariable: variableArg wantsStrictDeclare: aBoolean [
	| variableObject varName |
	varName := (variableArg isKindOf: GplAtomicToken)
		ifTrue: [ variableArg fragment ]
		ifFalse: [ variableArg name ].
	aBoolean
		ifTrue: [ (self hasVariableName: varName)
				ifFalse: [ ^ self error: 'VARIABLE NOT DECLEARED' ] ].
	variableArg isVariableAllowed
		ifFalse: [ ^ self error: 'CAN''T ASSIGN TO:' , varName ].
	variableObject := self variableNamed: varName.
	^ variableObject
]

{ #category : #analysis }
GplEvaluator >> gplValueFromGplValues: aGplValues [
	aGplValues size = 1
		ifTrue: [ ^ aGplValues first ].
	^ GdsVector withAll: aGplValues asArray
]

{ #category : #analysis }
GplEvaluator >> handleForKey: aKey line: aString [
	| sel |
	sel := aKey , ':'.
	sel := sel asSymbol.
	(self class selectors includes: sel)
		ifTrue: [ ^ self perform: sel with: aString ].
	^ 'Not found: ' , aKey
]

{ #category : #evaluator }
GplEvaluator >> handleToken: aToken [
	| result |
	self showsLog
		ifTrue: [ self printArgStack: aToken ].
	result := self handleTokenResult: aToken.
	result isSymbol
		ifTrue: [ ^ self error: (self notImplementedToken: aToken) ].
	self pushArg: result
]

{ #category : #evaluator }
GplEvaluator >> handleTokenResult: aToken [
	| handler |
	handler := GplHandler fromCommand: aToken fragment evaluator: self.
	handler ifNotNil: [ ^ handler evaluateToken: aToken ].
	(self isOperandToken: aToken)
		ifTrue: [ ^ aToken ].
	aToken isArithmeticOperator
		ifTrue: [ ^ self evaluateArithmetic: aToken ].
	self isInteractive
		ifTrue: [ aToken isVariableAllowed
				ifTrue: [ ^ aToken ] ].
	aToken fragment = '['
		ifTrue: [ ^ self evaluateSubscript: aToken ].
	aToken fragmentForInspect = '[]:='
		ifTrue: [ ^ self evaluateSubscriptAssign: aToken ].
	aToken fragment = ':='
		ifTrue: [ ^ self evaluateAssign: aToken ].
	aToken fragment = ','
		ifTrue: [ ^ self evaluateVector: aToken ].
	aToken fragment = ';'
		ifTrue: [ ^ self evaluateList: aToken ].
	aToken isBuiltinMonadic
		ifTrue: [ ^ self evaluateBuiltinMonadic: aToken ].
	aToken isBuiltinDyadic
		ifTrue: [ ^ self evaluateBuiltinDyadic: aToken ].
	aToken isInspectMonadic
		ifTrue: [ ^ self evaluateInspectMonadic: aToken ].
	aToken fragment = #cr
		ifTrue: [ ^ self voidReturn ].
	^ #notImplemented
]

{ #category : #'evaluator-inside' }
GplEvaluator >> hasMoreAssign: aGplToken [
	"^((outTokens last fragment = ':=') and: [aGplToken start < outTokens last start  ])"

	| tokens closeToken level |
	tokens := aGplToken rightTokens.
	tokens ifEmpty: [ ^ false ].
	closeToken := nil.
	level := 1.
	tokens
		do: [ :each | 
			each fragment = '['
				ifTrue: [ level := level + 1 ].
			each fragment = ']'
				ifTrue: [ level := level - 1.
					(level = 0 and: [ closeToken isNil ])
						ifTrue: [ closeToken := each ] ] ].
	closeToken ifNotNil: [ tokens := tokens := closeToken rightTokens ].
	^ (tokens detect: [ :each | each fragment = ':=' ] ifNone: [ nil ])
		isNil not
]

{ #category : #'context stack' }
GplEvaluator >> hasSuspendContext [
	suspendContext ifNil: [ suspendContext := OrderedCollection new ].
	^ suspendContext isEmpty not
]

{ #category : #evaluator }
GplEvaluator >> hasVariableName: aVariableName [
	varMap ifNil: [ ^ false ].
	^ varMap includesKey: aVariableName
]

{ #category : #command }
GplEvaluator >> history: aInputString [
	| digitLength num |
	digitLength := history size asString.
	num := 0.
	^ (history
		collect: [ :line | 
			num := num + 1.
			' ' , num asString , ' ' , line ]) asArray joinUsing: String cr
]

{ #category : #private }
GplEvaluator >> indexes: aGplTokens ofType: aSymbol [
	^ Array
		streamContents: [ :s | 
			aGplTokens
				doWithIndex: [ :token :index | 
					token type = aSymbol
						ifTrue: [ s nextPut: index ] ] ]
]

{ #category : #initialization }
GplEvaluator >> initialize [
	super initialize.
	history := OrderedCollection new.
	showsLog := false
]

{ #category : #command }
GplEvaluator >> inspect: aInputString [
	^ (self evaluateLine: aInputString) printString
]

{ #category : #analysis }
GplEvaluator >> inspectConsoleLine: aString [
	| tokens parser |
	parser := GplScanner new.
	parser source: aString.
	tokens := parser tokens.
	^ tokens printString
]

{ #category : #command }
GplEvaluator >> inspectPostfix: aInputString [
	^ (self translateToPostfix: aInputString) printString
]

{ #category : #command }
GplEvaluator >> inspectToken: aInputString [
	^ (GplScanner splitTokens: aInputString) printString
]

{ #category : #command }
GplEvaluator >> inspectTokens: aInputString [
	^ (self tokensFrom: aInputString) printString
]

{ #category : #testing }
GplEvaluator >> isDefined: aWord [
	aWord = #cr
		ifTrue: [ ^ true ].
	aWord trimBoth ifEmpty: [ ^ true ].
	(self hasVariableName: aWord)
		ifTrue: [ ^ true ].
	^ self isOperator: aWord
]

{ #category : #testing }
GplEvaluator >> isDyadic: aGplTokenOrString [
	| fragment |
	(self isOperator: aGplTokenOrString)
		ifFalse: [ ^ false ].
	fragment := (aGplTokenOrString isKindOf: GplAtomicToken)
		ifTrue: [ aGplTokenOrString fragmentForInspect ]
		ifFalse: [ aGplTokenOrString ].
	(fragment endsWith: '(dyadic)')
		ifTrue: [ ^ true ].
	^ #(#RESHAPE ':=' 'POWER') includes: fragment
]

{ #category : #testing }
GplEvaluator >> isInteractive [
	^ true
]

{ #category : #testing }
GplEvaluator >> isNumber: aString [
	^ GplScanner isNumberFragment: aString
]

{ #category : #testing }
GplEvaluator >> isOperandToken: aGplToken [
	^ #(number string vector unresolved) includes: aGplToken type
]

{ #category : #testing }
GplEvaluator >> isOperator: aGplTokenOrString [
	^ GplPostfix isOperator: aGplTokenOrString
]

{ #category : #testing }
GplEvaluator >> isScalarToken: aGplToken [
	(self isVariableRegistered: aGplToken fragment)
		ifTrue: [ ^ (self variableNamed: aGplToken fragment) rank = 0 ].
	^ aGplToken type = #number
]

{ #category : #testing }
GplEvaluator >> isVariableRegistered: aWord [
	^ false
]

{ #category : #accessing }
GplEvaluator >> junction [
	^ junction
]

{ #category : #accessing }
GplEvaluator >> junction: aPipeJunction [
	junction := aPipeJunction
]

{ #category : #analysis }
GplEvaluator >> lastEvaluatedLine [
	history isEmpty
		ifTrue: [ ^ '' ]
		ifFalse: [ ^ history last ]
]

{ #category : #evaluator }
GplEvaluator >> notConsumedTokens: aGplToken [
	| restSize ownPos depth |
	depth := aGplToken depth.
	ownPos := self postfixIndexOf: aGplToken.
	restSize := postfixTokens size - ownPos.
	restSize = 0
		ifTrue: [ ^ #() copy ].
	^ (postfixTokens allButFirst: ownPos)
		select: [ :each | each depth = depth and: [ self isDyadic: each ] ]
]

{ #category : #evaluator }
GplEvaluator >> numArgs: aGplToken [
	^ self numPushed + (self numReturn: aGplToken)
		- (self notConsumedTokens: aGplToken) size
]

{ #category : #evaluator }
GplEvaluator >> numPushed [
	argStack ifNil: [ argStack := OrderedCollection new ].
	^ argStack size
]

{ #category : #evaluator }
GplEvaluator >> numReturn: aGplToken [
	(GplHandler isVoid: aGplToken fragment)
		ifTrue: [ ^ 0 ].
	^ aGplToken leftTokens isEmpty
		ifTrue: [ 0 ]
		ifFalse: [ 1 ]
]

{ #category : #private }
GplEvaluator >> numberTokens: aGplTokens [
	^ aGplTokens select: [ :token | token isNumber ]
]

{ #category : #'context stack' }
GplEvaluator >> peekSuspendContext [
	suspendContext ifNil: [ suspendContext := OrderedCollection new ].
	^ suspendContext last
]

{ #category : #evaluator }
GplEvaluator >> popArg [
	| result |
	argStack ifEmpty: [ self runtimeError: 'Missing argument' ].
	result := argStack last.
	((result isKindOf: GplAtomicToken)
		and: [ result isVariableAllowed
				and: [ self hasVariableName: result fragment ] ])
		ifTrue: [ result := self variableNamed: result fragment ].
	argStack := argStack allButLast.
	^ result
]

{ #category : #'context stack' }
GplEvaluator >> popResult [
	| lastContext result |
	self hasSuspendContext
		ifFalse: [ ^ nil ].
	lastContext := self popSuspendContext.
	result := self resultAt: lastContext.
	resultMap removeKey: lastContext.
	^ result
]

{ #category : #'context stack' }
GplEvaluator >> popSuspendContext [
	| result |
	suspendContext ifNil: [ suspendContext := OrderedCollection new ].
	result := suspendContext last.
	suspendContext := suspendContext allButLast.
	^ result
]

{ #category : #command }
GplEvaluator >> postfix: aInputString [
	^ ((self translateToPostfix: aInputString)
		collect: [ :token | token postfixExpr ]) printString
]

{ #category : #evaluator }
GplEvaluator >> postfixIndexOf: aGplToken [
	^ postfixTokens indexOf: aGplToken
]

{ #category : #debug }
GplEvaluator >> printArgStack: aToken [
	argStack ifNil: [ ^ self ].
	Transcript
		cr;
		show: aToken -> argStack
]

{ #category : #evaluator }
GplEvaluator >> pushArg: aToken [
	self assert: (aToken isMemberOf: GplEvaluator) not.
	argStack ifNil: [ argStack := OrderedCollection new ].
	argStack add: aToken
]

{ #category : #'context stack' }
GplEvaluator >> pushResult: aObject [
	self assert: aObject isNil not.
	self hasSuspendContext
		ifTrue: [ | lastContext |
			lastContext := self peekSuspendContext.
			self registerResult: aObject at: lastContext ]
]

{ #category : #'context stack' }
GplEvaluator >> pushSuspendContext: aContext [
	suspendContext ifNil: [ suspendContext := OrderedCollection new ].
	suspendContext add: aContext
]

{ #category : #'context stack' }
GplEvaluator >> registerResult: aResultValue at: aContext [
	self assert: (aContext isMemberOf: Context).
	resultMap ifNil: [ resultMap := Dictionary new ].
	resultMap at: aContext put: aResultValue
]

{ #category : #evaluator }
GplEvaluator >> resolveVariableNameFromTokens: aGplTokens [
	GplScanner assertGplTokens: aGplTokens.
	^ aGplTokens
]

{ #category : #'context stack' }
GplEvaluator >> resultAt: aContext [
	self assert: (aContext isMemberOf: Context).
	resultMap ifNil: [ resultMap := Dictionary new ].
	^ resultMap at: aContext
]

{ #category : #'context stack' }
GplEvaluator >> resume [
	| context suspendedToken suspendPc skippedStream |
	self hasSuspendContext
		ifFalse: [ ^ self ].
	context := self peekSuspendContext.
	suspendedToken := context tempAt: 1.
	suspendPc := self postfixIndexOf: suspendedToken.
	skippedStream := ReadStream on: postfixTokens.
	skippedStream skip: suspendPc - 1.
	^ self evaluatePostfixStream: skippedStream
]

{ #category : #private }
GplEvaluator >> selectorOf: aGplToken [
	self assert: #operator = aGplToken type.
	aGplToken fragment isAllAlphaNumerics
		ifTrue: [ ^ (aGplToken fragment asLowercase , ':') asSymbol ].
	^ aGplToken fragment asSymbol
]

{ #category : #accessing }
GplEvaluator >> stderr [
	^ self junction errorPipelineStream
]

{ #category : #accessing }
GplEvaluator >> stdin [
	^ self junction pipeToInput
]

{ #category : #accessing }
GplEvaluator >> stdout [
	^ self junction pipeFromOutput
]

{ #category : #evaluator }
GplEvaluator >> syntaxCheck: aGplTokens [
	| checker |
	checker := GplSyntax new.
	checker model: self.
	checker checkFromTokens: aGplTokens
]

{ #category : #command }
GplEvaluator >> tokens: aInputString [
	^ ((GplScanner tokensFrom: aInputString)
		collect: [ :token | token fragment ]) asArray printString
]

{ #category : #evaluator }
GplEvaluator >> tokensFrom: aString [
	| tokens |
	tokens := GplScanner tokensFrom: aString.
	(tokens select: [ :each | each type = #unresolved ])
		do: [ :each | 
			(GplHandler hasCommandName: each fragment asUppercase)
				ifTrue: [ each type: #method ] ].
	tokens := self resolveVariableNameFromTokens: tokens.
	^ tokens
]

{ #category : #'analysis-postfix' }
GplEvaluator >> translateToPostfix: aSourceCode [
	^ GplPostfix new
		translateToPostfixFromTokens: (self tokensFrom: aSourceCode)
]

{ #category : #evaluator }
GplEvaluator >> variableNamed: aVariableName [
	varMap ifNil: [ varMap := Dictionary new ].
	^ varMap
		at: aVariableName
		ifAbsentPut: [ GplVariable named: aVariableName ]
]

{ #category : #analysis }
GplEvaluator >> vectorAnalysisFromTokens: aGplTokens [
	"TODO: remove duplicate flavor GplParser's "

	| stream vectorTokens token newOutput |
	self assertGplTokens: aGplTokens.
	stream := ReadStream on: aGplTokens.
	newOutput := OrderedCollection new.
	vectorTokens := OrderedCollection new.
	[ stream atEnd ]
		whileFalse: [ token := stream next.
			(self isScalarToken: token)
				ifTrue: [ vectorTokens add: token ]
				ifFalse: [ vectorTokens
						ifNotEmpty: [ | newToken |
							newToken := GplToken newFromTokens: vectorTokens.
							newOutput add: newToken.
							vectorTokens := OrderedCollection new ].
					newOutput add: token ] ].
	vectorTokens
		ifNotEmpty: [ | newToken |
			newToken := GplToken newFromTokens: vectorTokens.
			newOutput add: newToken.
			vectorTokens := OrderedCollection new ].
	^ newOutput asArray
]

{ #category : #private }
GplEvaluator >> voidReturn [
	^ GdsNull instance
]
