Class {
	#name : #GplASTBuilder,
	#superclass : #GdsObject,
	#instVars : [
		'inputStream',
		'file',
		'scanner',
		'rangeStream',
		'root',
		'currentNode',
		'currentToken',
		'statementCount',
		'operatorGroups',
		'blockStack',
		'variableScopeMap',
		'stilUnresolvedTokens',
		'operandStack',
		'subroutineDeclNodes',
		'inTraceMode'
	],
	#category : #'GdsFeel-CLI-AST'
}

{ #category : #'instance creation' }
GplASTBuilder class >> fromFile: aFileReference [
	^ self new
		file: aFileReference;
		yourself
]

{ #category : #'instance creation' }
GplASTBuilder class >> fromString: aString [
	^ self new
		inputStream: aString readStream;
		yourself
]

{ #category : #'stack operation' }
GplASTBuilder >> addToBlock: aNode [
	self topBlock addSubNode: aNode
]

{ #category : #statement }
GplASTBuilder >> assignStatement [
	^ self assignStatement: nil
]

{ #category : #statement }
GplASTBuilder >> assignStatement: aFollowSet [
	| opNode leftNode rightNode followSet |
	leftNode := self variable.
	':=' = currentToken fragment
		ifFalse: [ #cr = currentToken fragment
				ifTrue: [ self addToBlock: leftNode.
					^ leftNode ] ].
	self expected: ':='.
	opNode := GplDyadicOperatorNode new.
	opNode at: #syntax put: #assignStatement.
	opNode param1: leftNode.
	opNode token: currentToken.
	self nextToken.	"skip :="
	followSet := Set new.
	aFollowSet ifNotNil: [ followSet addAll: aFollowSet ].
	followSet add: #cr.
	rightNode := self expression: aFollowSet.
	opNode param2: rightNode.
	self addToBlock: opNode.
	^ opNode
]

{ #category : #'as yet unclassified' }
GplASTBuilder >> basicNextToken [
	rangeStream ifNil: [ ^ nil ].
	rangeStream atEnd
		ifTrue: [ ^ nil ].
	currentToken := rangeStream next.
	^ currentToken
]

{ #category : #handler }
GplASTBuilder >> block: aFollowSet [
	| temp |
	temp := self statement: aFollowSet.
	^ temp
]

{ #category : #spec }
GplASTBuilder >> bothArgumentFragments [
	^ #('ANGLE' 'ASHAPE' 'CE' 'DATADRAW' 'EXPINPUT' 'GSCALE' 'GRID' 'ITEM' 'NODETYPE' 'PLEX' 'PLEXMODE' 'REFL' 'SDTYPE' 'SKIND' 'VKIND' 'SLAYER' 'TEXTINPUT' 'VLAYER' 'INITLIB' 'VLAYERON' 'SLAYERON' 'VBTYPEON' 'VDTYPEON' 'VTTYPEON' 'VNTYPEON' 'SBTYPEON' 'SDTYPEON' 'STTYPEON' 'SNTYPEON' 'SBTYPE' 'SDTYPE' 'STTYPE' 'SNTYPE' 'VBTYPE' 'VDTYPE' 'VNTYPE' 'VTTYPE' 'SNAME' 'TSTRUCT' 'MAG')
		, self colorFragments , self fillFragments
]

{ #category : #'as yet unclassified' }
GplASTBuilder >> buildTree [
	scanner := GplScanner new splitTokensFrom: inputStream.
	self patchAdditionalMethods.
	rangeStream := scanner ranges readStream.
	self nextTokenIgnoreCr.
	self subroutine
]

{ #category : #spec }
GplASTBuilder >> colorFragments [
	^ #('WHITE' 'RED' 'BLUE' 'YELLOW' 'CYAN' 'MAGENTA' 'GREEN')
]

{ #category : #accessing }
GplASTBuilder >> currentNode [
	^ blockStack top
]

{ #category : #accessing }
GplASTBuilder >> currentToken [
	^ currentToken
]

{ #category : #statement }
GplASTBuilder >> declareStatement [
	| node |
	node := GplDeclNode new.
	self addToBlock: node.
	node kind: #variable.	"default"
	(self isStorageScopeToken: currentToken)
		ifFalse: [ ^ self
				error:
					('{1} expectd'
						format: {(GplToken storageScopeKeywords joinUsing: ', ')}) ].
	node storageScope: currentToken fragment asSymbol.
	self nextToken.

	"has External routine"
	((self isArgumentTypeToken: currentToken)
		and: [ #EXTERNAL = node storageScope ])
		ifTrue: [ node kind: #subroutine.
			self methodModifire: node ].

	"has DataType?"
	(#variable = node kind and: [ self isDataTypeToken: currentToken ])
		ifTrue: [ node at: #dataType put: currentToken fragment asSymbol.
			self nextToken ].
	self pushBlock: node during: [ self nameList ].
	#variable = node kind
		ifTrue:
			[ (variableScopeMap at: node storageScope) addAll: node variableNames ]
		ifFalse: [ node subroutineNames ifNotEmpty: [ subroutineDeclNodes add: node ] ].
	self endStatement
]

{ #category : #handler }
GplASTBuilder >> declareStatements [
	self nextTokenIgnoreCr.
	self declareStatement.
	self nextTokenIgnoreCr.
	[ GplToken storageScopeKeywords
		includes: currentToken fragmentForTest ]
		whileTrue: [ self declareStatement.
			self nextTokenIgnoreCr ].
	self resolveVariableNames.
	self resolveSubroutineNames.
	self postUnresolvedPatch
]

{ #category : #statement }
GplASTBuilder >> doStatement: aFollowSet [
	| doNode followSet |
	doNode := GplDoNode new.
	self addToBlock: doNode.
	('FOR' sameAs: currentToken fragment)
		ifTrue: [ self nextToken.
			doNode forPart eachVariable: self variable.
			('RANGE' sameAs: currentToken fragment)
				ifTrue: [ self nextToken.
					followSet := self followSet: #('WHILE' 'DO') based: aFollowSet.
					doNode forPart range: (self expression: followSet) ] ].
	('WHILE' sameAs: currentToken fragment)
		ifTrue: [ self nextToken.
			followSet := self followSet: 'DO' based: aFollowSet.
			doNode whilePart condition: (self expression: followSet) ].
	self skipTokenExpected: 'DO'.
	followSet := self followSet: #('UNTIL' 'ENDDO') based: aFollowSet.
	self pushBlock: doNode during: [ self block: followSet ].
	('UNTIL' sameAs: currentToken fragment)
		ifTrue: [ self nextToken.
			followSet := self followSet: #(cr 'ENDDO') based: aFollowSet.
			doNode untilPart condition: (self expression: followSet) ].
	self skipCr.
	self skipTokenExpected: 'ENDDO'
]

{ #category : #deprecated }
GplASTBuilder >> doUntilStatement: aFollowSet [
	| loopNode followSet conditionNode |
	self skipTokenExpected: 'DO'.
	loopNode := GplASTNode new.
	loopNode kind: #doUntil.
	self addToBlock: loopNode.
	followSet := Set new.
	aFollowSet ifNotNil: [ followSet addAll: aFollowSet ].
	followSet addAll: #('UNTIL' 'ENDDO').
	self pushBlock: loopNode during: [ self block: followSet ].
	self skipTokenExpected: 'UNTIL'.
	followSet := Set new.
	aFollowSet ifNotNil: [ followSet addAll: aFollowSet ].
	followSet addAll: #(cr 'ENDDO').
	conditionNode := self expression: followSet.
	loopNode at: #condition put: conditionNode.
	self skipCr.
	self skipTokenExpected: 'ENDDO'.
	^ loopNode
]

{ #category : #expression }
GplASTBuilder >> dyadicOperator: aToken [
	| node |
	node := GplDyadicOperatorNode new.
	node token: aToken.
	node param2: operandStack pop.
	node param1: operandStack pop.
	self inTraceMode
		ifTrue: [ {'dyadicCall: '.
			aToken} traceCr ].
	"self currentNode addSubNode: node."
	^ node
]

{ #category : #statement }
GplASTBuilder >> endStatement [
	currentToken type = #cr
		ifFalse: [ ^ self error: '<CR> required.' ]
]

{ #category : #statement }
GplASTBuilder >> endsubStatement: aFollowSet [
	| stNode |
	self expected: 'ENDSUB'.
	stNode := GplASTNode new.
	self addToBlock: stNode.
	stNode at: #kind put: #ENDSUB.
	"self nextToken"
	^ stNode	"NIL TOKEN"
]

{ #category : #handler }
GplASTBuilder >> expected: aFragment [
	self expected: aFragment onSuccess: [  ]
]

{ #category : #handler }
GplASTBuilder >> expected: aFragment onSuccess: aSuccessBlock [
	(aFragment sameAs: currentToken fragment)
		ifFalse: [ self
				error:
					('"{1}" expected but: "{2}"'
						format:
							{aFragment.
							currentToken fragment}) ]
		ifTrue: aSuccessBlock
]

{ #category : #'as yet unclassified' }
GplASTBuilder >> exploreErrorRanges [
	| start end |
	currentToken ifNil: [ ^ self ].
	start := currentToken index - 10 max: 1.
	end := currentToken index + 10 min: rangeStream size.
	(rangeStream contents copyFrom: start to: end) explore
]

{ #category : #expression }
GplASTBuilder >> expression [
	^ self expression: nil
]

{ #category : #expression }
GplASTBuilder >> expression: aFollowSet [
	| temp |
	"self haltIf: [currentToken start = 4250]."
	temp := ';' = currentToken fragment
		ifTrue: [ self listExpression: aFollowSet ]
		ifFalse: [ self term: 1 followSet: aFollowSet ].
	"self subscriptOn: temp."
	^ temp
]

{ #category : #statement }
GplASTBuilder >> expressionStatement: aFollowSet [
	| opNode expressionNode followSet |
	self haltString: 'hoge'.
	opNode := GplStatementNode new.
	self addToBlock: opNode.
	followSet := Set new.
	aFollowSet ifNotNil: [ followSet addAll: aFollowSet ].
	followSet addAll: {#cr}.
	expressionNode := self expression: followSet.
	opNode at: #value put: expressionNode.
	^ opNode
]

{ #category : #expression }
GplASTBuilder >> factor: aFollowSet [
	#variable = currentToken type
		ifTrue: [ ^ self variable ].
	#gdsiiMethod = currentToken type
		ifTrue: [ ^ self gdsiiMethod: aFollowSet ].
	"(#gdsiiMethod = currentToken type)
		ifTrue: [ 
			^ self subroutineCallStatement: aFollowSet].	"
	(self isLiteral: currentToken)
		ifTrue: [ ^ self literal ].
	('(' sameAs: currentToken fragment)
		ifTrue: [ ^ self parlen ].
	self error: ('factor: {1}' format: {currentToken printString})
]

{ #category : #accessing }
GplASTBuilder >> file: aFileReference [
	file := aFileReference.
	self inputStream: file readStream
]

{ #category : #spec }
GplASTBuilder >> fillFragments [
	^ #('FILLB' 'FILLC')
]

{ #category : #'as yet unclassified' }
GplASTBuilder >> followSet: aCurrentSet [
	^ self followSet: aCurrentSet based: nil
]

{ #category : #'as yet unclassified' }
GplASTBuilder >> followSet: aCurrentSet based: aFollowSet [
	| followSet |
	followSet := Set new.
	aFollowSet ifNotNil: [ followSet addAll: aFollowSet ].
	followSet
		addAll:
			((aCurrentSet isKindOf: String)
				ifTrue: [ Array with: aCurrentSet ]
				ifFalse: [ aCurrentSet ]).
	^ followSet
]

{ #category : #accessing }
GplASTBuilder >> foo [
	
]

{ #category : #expression }
GplASTBuilder >> gdsiiMethod: aFollowSet [
	| argcContext methodNode numArgs opToken argVariations |
	self haltString: 'hage'.
	opToken := currentToken.
	self nextToken.
	argcContext := (self isRightStetementSeparator: currentToken)
		ifTrue: [ 0 ]
		ifFalse: [ 1 ].
	argVariations := self numArgsOfToken: opToken.
	argVariations
		ifEmpty: [ self
				error: ('cant detect numArgs of {1}' format: {opToken printString}) ].
	(argVariations includes: argcContext)
		ifFalse: [ argcContext = 0
				ifTrue: [ self
						error: ('NILADIC CONTEXT BUT NILADIC CALL DISALLOW: {1} ' format: {opToken}) ]
				ifFalse: [ self
						error: ('MONADIC CONTEXT BUT MONADIC CALL DISALLOW: {1} ' format: {opToken}) ] ].

	"numArgs := argVariations size = 1
		ifTrue: [ argVariations first ]
		ifFalse: [ self isFunctionContext ifTrue: [ 0 ] ifFalse: [ 1 ]] ."
	numArgs := argcContext.
	0 = numArgs
		ifTrue: [ "NILADIC"
			methodNode := GplNiladicOperatorNode new
			"self nextToken"	"skip MethodName only" ].
	1 = numArgs
		ifTrue: [ "MONADIC"
			methodNode := GplMonadicOperatorNode new.
			"self nextToken"
			methodNode param1: (self expression: aFollowSet)	"skip MethodName" ].
	2 = numArgs
		ifTrue: [ "DYADIC"
			methodNode := GplDyadicOperatorNode new.
			self
				error: ('dyadic {1} must term: context ' format: {currentToken printString}) ].
	methodNode kind: #gdsiiMethod.
	methodNode token: opToken.
	^ methodNode
]

{ #category : #statement }
GplASTBuilder >> gotoStatement: aFollowSet [
	| stNode |
	self expected: 'GOTO'.
	stNode := GplASTNode new.
	self addToBlock: stNode.
	stNode kind: #goto.
	self nextToken.
	"label Part"
	stNode at: #label put: currentToken.
	self nextToken.
	^ stNode
]

{ #category : #statement }
GplASTBuilder >> haltString: aString [
	self haltIf: [ currentToken fragment sameAs: aString ]
]

{ #category : #statement }
GplASTBuilder >> ifStatement: aFollowSet [
	| stNode followSet |
	self expected: 'IF'.
	stNode := GplIfStatementNode new.
	self addToBlock: stNode.
	self nextToken.
	followSet := self
		followSet: stNode ifPart blockCloseFragments , {'THEN'}
		based: aFollowSet.
	stNode ifPart condition: (self expression: followSet).
	self
		expected: 'THEN'
		onSuccess: [ self inTraceMode
				ifTrue: [ 'THEN skiped' traceCr ].
			self nextToken ].
	self pushBlock: stNode ifPart.
	followSet := self
		followSet: stNode ifPart blockCloseFragments
		based: aFollowSet.
	self block: followSet.
	[ 'ELIF' sameAs: currentToken fragment ]
		whileTrue: [ self inTraceMode
				ifTrue: [ ('block closed by: ' , currentToken printString) traceCr ].
			stNode newElif.
			self
				popBlockIf:
					(stNode elifParts nodes size = 1
						ifTrue: [ stNode ifPart ]
						ifFalse: [ stNode elifParts nodes at: stNode elifParts nodes size - 1 ]).
			self nextToken.	"skip ELIF"
			self pushBlock: stNode lastElif.
			followSet := self
				followSet: stNode lastElif blockCloseFragments
				based: aFollowSet.
			stNode lastElif condition: (self expression: followSet).
			self
				expected: 'THEN'
				onSuccess: [ self inTraceMode
						ifTrue: [ 'THEN skiped' traceCr ].
					self nextToken ].
			self block: followSet ].
	('ELSE' sameAs: currentToken fragment)
		ifTrue: [ self inTraceMode
				ifTrue: [ 'skip ELSE' traceCr ].
			self popBlockIf: stNode ifPart.
			stNode elifParts nodes
				ifNotEmpty: [ self popBlockIf: stNode elifParts nodes last ].
			self nextToken.
			self pushBlock: stNode elsePart.
			followSet := self
				followSet: stNode elsePart blockCloseFragments
				based: aFollowSet.
			self block: followSet ].
	('ENDIF' sameAs: currentToken fragment)
		ifTrue: [ self inTraceMode
				ifTrue: [ 'skip ENDIF' traceCr ].
			self popBlockIf: stNode ifPart.
			stNode elifParts nodes
				ifNotEmpty: [ self popBlockIf: stNode elifParts nodes last ].
			self popBlockIf: stNode elsePart.
			self nextToken ].

	"self addToCurrentBlock: ifPart.	"
	^ stNode
]

{ #category : #testing }
GplASTBuilder >> inPrecedenceToken: aGplToken precedence: aPrecedence [
	| assoc |
	assoc := operatorGroups at: aPrecedence.
	assoc ifNil: [ ^ false ].
	assoc key = '[]'
		ifTrue: [ aGplToken fragment = '['
				ifTrue: [ ^ true ] ].
	(assoc value includes: aGplToken fragment)
		ifTrue: [ ^ true ].
	^ false
]

{ #category : #testing }
GplASTBuilder >> inTraceMode [
	^ inTraceMode
]

{ #category : #initialization }
GplASTBuilder >> initialize [
	super initialize.
	self initializeOperatorGroups.
	inTraceMode := false.
	operandStack := Stack new.
	blockStack := Stack new.
	variableScopeMap := Dictionary new.
	variableScopeMap at: #LOCAL put: OrderedCollection new.
	variableScopeMap at: #GLOBAL put: OrderedCollection new.
	variableScopeMap at: #EXTERNAL put: OrderedCollection new.
	subroutineDeclNodes := OrderedCollection new
]

{ #category : #initialization }
GplASTBuilder >> initializeOperatorGroups [
	operatorGroups := OrderedCollection new.
	operatorGroups
		addAll: (GplScanner operatorSpec sort: [ :assoc1 :assoc2 | assoc1 < assoc2 ]).
	operatorGroups := (operatorGroups
		collect: [ :assoc | 
			assoc key
				->
					(assoc value
						collect: [ :opString | 
							| words |
							words := opString findTokens: ' '.
							words size = 1
								ifTrue: [ opString ]
								ifFalse: [ words first ] ]) asSet ]) asArray
]

{ #category : #accessing }
GplASTBuilder >> inputStream [
	^ inputStream
]

{ #category : #accessing }
GplASTBuilder >> inputStream: aStream [
	inputStream := aStream
]

{ #category : #testing }
GplASTBuilder >> isArgumentTypeToken: aGplToken [
	^ GplToken methodTypeKeywords includes: aGplToken fragmentForTest
]

{ #category : #testing }
GplASTBuilder >> isDataTypeToken: aGplToken [
	^ GplToken dataTypeKeywords includes: aGplToken fragmentForTest
]

{ #category : #testing }
GplASTBuilder >> isEffectiveToken: aToken [
	^ self isEffectiveToken: aToken ignoreCr: false
]

{ #category : #testing }
GplASTBuilder >> isEffectiveToken: aToken ignoreCr: aBoolean [
	aToken ifNil: [ ^ false ].
	aToken isComment
		ifTrue: [ ^ false ].
	aToken type = #space
		ifTrue: [ ^ false ].
	aBoolean
		ifTrue: [ aToken type = #cr
				ifTrue: [ ^ false ] ].
	^ true
]

{ #category : #testing }
GplASTBuilder >> isFunctionContext [
	^ self isFunctionContext: currentToken
]

{ #category : #testing }
GplASTBuilder >> isFunctionContext: aGplToken [
	"1. var := BISUB  <- assignment rightValue context "

	"2. (BISUB)       <- inside parlen "

	"3. BISUB arg     <- procedure all "

	"get sameLines tokens "

	| leftToekns |
	leftToekns := self
		leftTokens: aGplToken
		until: [ :tk | self isLeftStetementSeparator: tk ].
	leftToekns := leftToekns
		reject: [ :tk | {#comment . #space . #label} includes: tk type ].
	^ leftToekns notEmpty
]

{ #category : #testing }
GplASTBuilder >> isLeftStetementSeparator: aGplToken [
	#cr = aGplToken type
		ifTrue: [ ^ true ].
	#labelSeparator = aGplToken type
		ifTrue: [ ^ true ].
	^ #('THEN' 'ELSE' 'DO' 'OUT') includes: aGplToken fragment
]

{ #category : #testing }
GplASTBuilder >> isLiteral: aGplToken [
	({#string . #number . #vector} includes: aGplToken type)
		ifTrue: [ ^ true ].
	^ false
]

{ #category : #testing }
GplASTBuilder >> isRightStetementSeparator: aGplToken [
	#cr = aGplToken type
		ifTrue: [ ^ true ].
	#operator = aGplToken type
		ifTrue: [ ^ true ].
	')' = aGplToken fragment
		ifTrue: [ ^ true ].
	'[' = aGplToken fragment
		ifTrue: [ ^ true ].
	']' = aGplToken fragment
		ifTrue: [ ^ true ].
	"#gdsiiMethod = aGplToken type 
		ifTrue: [ ^ true ]."
	^ #('THEN' 'ELSE' 'ELIF' 'ENDIF' 'UNTIL' 'ENDDO' 'OF' 'ENDSWITCH')
		includes: aGplToken fragment
]

{ #category : #testing }
GplASTBuilder >> isStorageScopeToken: aGplToken [
	^ GplToken storageScopeKeywords
		includes: currentToken fragmentForTest
]

{ #category : #testing }
GplASTBuilder >> leftTokens: aGplToken until: aGplTokenBlock [
	| ti done tokens |
	ti := aGplToken index.
	done := false.
	tokens := OrderedCollection new.
	[ ti := ti - 1.
	ti < 1 or: [ done ] ]
		whileFalse: [ | tk |
			tk := scanner ranges at: ti.
			(aGplTokenBlock value: tk)
				ifTrue: [ done := true ]
				ifFalse: [ tokens add: tk ] ].
	^ tokens
]

{ #category : #expression }
GplASTBuilder >> listExpression: aFollowSet [
	| op aPrecedence leftNode rightNode |
	aPrecedence := 2.
	self inTraceMode
		ifTrue: [ {currentToken.
			aPrecedence} traceCr ].
	leftNode := ';' = currentToken fragment
		ifTrue: [ "[ ; right ]"
			"missing left value complement assuume nil "
			GplLiteralNode new
				kind: #nil;
				yourself ]
		ifFalse: [ self term: aPrecedence + 1 followSet: aFollowSet ].
	operandStack push: leftNode.
	[ self inPrecedenceToken: currentToken precedence: aPrecedence ]
		whileTrue: [ self assert: currentToken type = #operator.
			op := currentToken.
			self nextToken.
			rightNode := ']' = currentToken fragment
				ifTrue: [ "[ left ; ]"
					"missing right value complement assuume nil "
					GplLiteralNode new
						kind: #nil;
						yourself ]
				ifFalse: [ "has rightValue" self term: aPrecedence + 1 followSet: aFollowSet ].
			operandStack push: rightNode.
			operandStack push: (self dyadicOperator: op) ].
	^ operandStack pop
]

{ #category : #'syntax parts' }
GplASTBuilder >> literal [
	| node |
	node := GplLiteralNode new.
	node token: currentToken.
	self nextToken.
	^ node
]

{ #category : #handler }
GplASTBuilder >> methodModifire: aNode [
	(GplToken methodTypeKeywords includes: currentToken fragmentForTest)
		ifFalse: [ ^ self error: 'NILADIC, MONADIC, DYADIC expectd' ].
	aNode at: #paramType put: currentToken fragment asSymbol.
	self nextToken.
	(GplToken methodKindKeywords includes: currentToken fragmentForTest)
		ifFalse: [ ^ self error: 'FUNCTION or PROCEDURE expectd' ].
	aNode at: #methodKind put: currentToken fragment asSymbol.
	self nextToken
]

{ #category : #spec }
GplASTBuilder >> monadicFragments [
	^ (self monadicOnlyFragments , self bothArgumentFragments) asSet
]

{ #category : #spec }
GplASTBuilder >> monadicOnlyFragments [
	^ #('BINDATTR' 'BINDFONTS' 'BSTRUCT' 'CALL' 'CSTRUCT' 'CFORMAT' 'DATACOPY' 'DATADELETE' 'DATATYPE' 'DEFMODE' 'DFUNCTION' 'DRAWARROW' 'DRAWSEGS' 'DRAWTEXT' 'DSTRUCT' 'ENTERTEXT' 'EXECUTE' 'FDELETE' 'FETCH' 'FILEINFO' 'FLAYER' 'FONT' 'FORMAT' 'G' 'GEDMODE' 'GET' 'GETEL' 'GPL' 'GSCALE' 'INTERRUPTMODE' 'JOBCREATE' 'LAYER' 'LOAD' 'LOCALTOGLOBAL' 'MAG' 'MARK' 'MINMAX' 'MOVE' 'MSELECT' 'NEWWIDTH' 'ONAME' 'OPENLIB' 'OSTRUCT' 'PATHTYPE' 'POLAR' 'PROPERTY' 'PROPVALUE' 'PUTEL' 'ROUND' 'SETCOLORS' 'SETVIEW' 'STADPYINFO' 'STRUCINFO' 'STRUCLIST' 'T' 'TEXTTYPE' 'TJUST' 'W' 'WIDTH' 'WINOPTIONS' 'WIPE' 'ZOOM')
]

{ #category : #expression }
GplASTBuilder >> monadicOperator: aGplToken [
	| node |
	node := GplMonadicOperatorNode new.
	node token: aGplToken.
	node param1: operandStack pop.
	self inTraceMode
		ifTrue: [ {'monadicCall: '.
			aGplToken} traceCr ].
	"self currentNode addSubNode: node."
	^ node
]

{ #category : #'syntax parts' }
GplASTBuilder >> nameList [
	self currentNode at: #nameList put: OrderedCollection new.
	(self currentNode at: #nameList) add: currentToken fragment.
	self nextToken.
	[ currentToken notNil and: [ currentToken type = #cr ] ]
		whileFalse: [ ';' = currentToken fragment
				ifFalse: [ ^ self error: '; expected' ].
			self nextToken.
			(self currentNode at: #nameList) add: currentToken fragment.
			self nextToken ]
]

{ #category : #tokenizing }
GplASTBuilder >> nextToken [
	| token |
	[ token := self basicNextToken.
	self isEffectiveToken: token ] whileFalse.
	token fragment = nil
		ifTrue: [ self halt ].
	currentToken := token.
	^ token
]

{ #category : #'as yet unclassified' }
GplASTBuilder >> nextTokenIgnoreCr [
	| token |
	[ token := self basicNextToken.
	token isNil or: [ self isEffectiveToken: token ignoreCr: true ] ]
		whileFalse.
	currentToken := token.
	^ token
]

{ #category : #spec }
GplASTBuilder >> niladicFragments [
	^ (self niladicOnlyFragments , self bothArgumentFragments) asSet
]

{ #category : #spec }
GplASTBuilder >> niladicOnlyFragments [
	^ #('ADDRT' 'AREF' 'BOUNDARY' 'BOXTYPE' 'CONTEXT' 'CLOSELIB' 'CLRPROP' 'COORDS' 'CRTTYPE' 'DATAVIEW' 'GEDCOORDS' 'GEDDATATYPE' 'GEDKEY' 'GEDLAYER' 'GEDNAME' 'GEDPLEX' 'GEDSTRING' 'GEDTEXT' 'GEDTEXTTYPE' 'GEDTYPE' 'IDCLEAR' 'IDKEYS' 'NAMESOPEN' 'NODE' 'OCTAGONAL' 'ORTHINT' 'PATH' 'PUT' 'PUTALL' 'REMOVE' 'SBTYPE' 'SCELL' 'SETLEVEL' 'SNTYPE' 'SREF' 'STANUM' 'STRUCOPEN' 'STTYPE' 'TABTYPE' 'TEXT' 'VERTFIRST' 'WASTAT')
]

{ #category : #'syntax parts' }
GplASTBuilder >> numArgsOfToken: aGplToken [
	| col |
	(subroutineDeclNodes
		detect: [ :node | node nameList includes: aGplToken fragment ]
		ifNone: [  ])
		ifNotNil: [ :foundDeclNode | ^ Array with: foundDeclNode numArgs ].
	col := OrderedCollection new.
	(self niladicFragments includes: aGplToken fragment)
		ifTrue: [ col add: 0 ].
	(self monadicFragments includes: aGplToken fragment)
		ifTrue: [ col add: 1 ].
	^ col asArray
]

{ #category : #expression }
GplASTBuilder >> operandSizeOfPrecendence: aPrecedence [
	"see: GplParser>>operatorSpec"

	8r377 = aPrecedence
		ifTrue: [ ^ 1 ].
	8r20 = aPrecedence
		ifTrue: [ ^ 1 ].
	8r17 = aPrecedence
		ifTrue: [ ^ 1 ].
	8r16 = aPrecedence
		ifTrue: [ ^ 2 ].
	8r15 = aPrecedence
		ifTrue: [ ^ 2 ].
	8r13 = aPrecedence
		ifTrue: [ ^ 2 ].
	8r12 = aPrecedence
		ifTrue: [ ^ 2 ].
	8r11 = aPrecedence
		ifTrue: [ ^ 2 ].
	8r10 = aPrecedence
		ifTrue: [ ^ 1 ].
	8r7 = aPrecedence
		ifTrue: [ ^ 2 ].
	8r6 = aPrecedence
		ifTrue: [ ^ 2 ].
	8r5 = aPrecedence
		ifTrue: [ ^ 2 ].
	8r0 = aPrecedence
		ifTrue: [ ^ 2 ].
	^ -1
]

{ #category : #handler }
GplASTBuilder >> paramCheck [
	"(currentToken type = #localVariable)
		ifFalse: [ self error: ('{1} not declare in LOCAL ' format: { currentToken fragment }) ]. "

	
]

{ #category : #handler }
GplASTBuilder >> paramCheckAt: aPropertyName [
	self paramCheck.
	self currentNode at: aPropertyName put: currentToken.
	self nextToken
]

{ #category : #handler }
GplASTBuilder >> paramName [
	self currentNode at: #name put: currentToken fragment.
	self nextToken
]

{ #category : #'syntax parts' }
GplASTBuilder >> parlen [
	| valNode parenNode |
	self nextToken.
	parenNode := GplValueNode new.
	parenNode at: #kind put: #parlen.
	self
		pushBlock: parenNode
		during: [ valNode := self expression: {#cr . 'ENDSUB' . ')'}.
			self skipTokenExpected: ')' ].
	parenNode at: #value put: valNode.
	^ parenNode
]

{ #category : #'as yet unclassified' }
GplASTBuilder >> patchAdditionalMethods [
	scanner ranges
		do: [ :token | 
			(self monadicFragments includes: token fragmentForTest)
				ifTrue: [ token type: #gdsiiMethod ].
			(self niladicFragments includes: token fragmentForTest)
				ifTrue: [ token type: #gdsiiMethod ] ]
]

{ #category : #'stack operation' }
GplASTBuilder >> popBlock [
	^ blockStack pop
]

{ #category : #'stack operation' }
GplASTBuilder >> popBlockIf: anObject [
	blockStack top == anObject
		ifTrue: [ ^ self popBlock ].
	^ nil
]

{ #category : #'as yet unclassified' }
GplASTBuilder >> postUnresolvedPatch [
	self
		unresolvedTokensDo: [ :unresolvedTokens | stilUnresolvedTokens := unresolvedTokens ]
]

{ #category : #testing }
GplASTBuilder >> precedenceOfToken: aGplToken [
	aGplToken fragment = '['
		ifTrue: [ ^ 1 ].
	operatorGroups
		doWithIndex: [ :assoc :precedence | 
			(assoc value includes: aGplToken fragment)
				ifTrue: [ ^ precedence ] ].
	^ 0
]

{ #category : #'stack operation' }
GplASTBuilder >> pushBlock: aNode [
	blockStack push: aNode
]

{ #category : #'stack operation' }
GplASTBuilder >> pushBlock: aNode during: aBlock [
	self pushBlock: aNode.
	aBlock value.
	self popBlockIf: aNode
]

{ #category : #'as yet unclassified' }
GplASTBuilder >> ranges [
	^ scanner ranges
]

{ #category : #'as yet unclassified' }
GplASTBuilder >> resolveSubroutineNames [
	subroutineDeclNodes ifEmpty: [ ^ self ].
	self
		unresolvedTokensDo: [ :unresolvedTokens | 
			unresolvedTokens
				do: [ :unresolvedToken | self resolveTokenAsSubroutine: unresolvedToken ] ]
]

{ #category : #accessing }
GplASTBuilder >> resolveTokenAsSubroutine: aGplToken [
	(subroutineDeclNodes
		detect: [ :node | node nameList includes: aGplToken fragment ]
		ifNone: [  ])
		ifNotNil: [ :foundDeclNode | aGplToken type: #gdsiiMethod ]
]

{ #category : #'as yet unclassified' }
GplASTBuilder >> resolveTokenAsVariable: aGplToken [
	variableScopeMap keys
		do: [ :scope | 
			((variableScopeMap at: scope) includes: aGplToken fragment)
				ifTrue: [ aGplToken type: #variable ] ]
]

{ #category : #'as yet unclassified' }
GplASTBuilder >> resolveVariableNames [
	self
		unresolvedTokensDo:
			[ :unresolvedTokens | unresolvedTokens do: [ :t | self resolveTokenAsVariable: t ] ]
]

{ #category : #testing }
GplASTBuilder >> rightTokens: aGplToken until: aGplTokenBlock [
	| ti done tokens max |
	ti := aGplToken index.
	done := false.
	max := scanner ranges size.
	tokens := OrderedCollection new.
	[ ti := ti + 1.
	ti > max or: [ done ] ]
		whileFalse: [ | tk |
			tk := scanner ranges at: ti.
			(aGplTokenBlock value: tk)
				ifTrue: [ done := true ]
				ifFalse: [ tokens add: tk ] ].
	^ tokens
]

{ #category : #handler }
GplASTBuilder >> routineParams [
	"DYADIC"

	"PARAM1 SUBNAME PARAM2"

	(self currentNode at: #paramType) = #DYADIC
		ifTrue: [ self paramCheckAt: #param1.
			self paramName.
			^ self paramCheckAt: #param2 ].

	"MONADIC"
	"SUBNAME PARAM"
	(self currentNode at: #paramType) = #MONADIC
		ifTrue: [ self paramName.
			^ self paramCheckAt: #param1 ].

	"NILADIC"
	"SUBNAME"
	(self currentNode at: #paramType) = #NILADIC
		ifTrue: [ ^ self paramName ].
	^ self error: 'invalid PARAMETER form'
]

{ #category : #'as yet unclassified' }
GplASTBuilder >> skipCr [
	[ currentToken notNil and: [ currentToken type = #cr ] ]
		whileTrue: [ self nextToken ]
]

{ #category : #expression }
GplASTBuilder >> skipFollowSet: aFollowSet [
	aFollowSet
		ifNotNil: [ | followSet |
			followSet := Set new.
			followSet addAll: aFollowSet.
			[ followSet includes: currentToken fragment ]
				whileFalse: [ | t skiped |
					skiped := currentToken.
					self inTraceMode
						ifTrue: [ {'skiped: '.
							skiped} traceCr ].
					t := self nextToken.
					skiped fragment = #cr
						ifFalse: [ self error: ('skip without <CR> {1} ' format: {skiped}) ] ] ]
]

{ #category : #handler }
GplASTBuilder >> skipTokenExpected: aFragment [
	self expected: aFragment onSuccess: [ self nextToken ]
]

{ #category : #statement }
GplASTBuilder >> statement: aFollowSet [
	| temp labelToken |
	statementCount ifNil: [ statementCount := 0 ].
	statementCount > 700
		ifTrue: [ self halt.
			statementCount := 0 ].
	statementCount := statementCount + 1.
	self inTraceMode
		ifTrue: [ {'statement: '.
			currentToken.
			statementCount} traceCr ].
	#label = currentToken type
		ifTrue: [ labelToken := currentToken.
			self nextToken ].
	temp := self statementSwitch: aFollowSet.
	temp
		ifNil: [ temp := GplASTNode new.
			self addToBlock: temp.
			temp kind: #NOP ].
	labelToken ifNotNil: [ temp at: #label put: labelToken ].
	#cr = currentToken type
		ifTrue: [ ^ self nextTokenIgnoreCr
				ifNil: [ temp ]
				ifNotNil: [ self statement: aFollowSet ] ].
	(aFollowSet notNil
		and: [ aFollowSet includes: currentToken fragment ])
		ifTrue: [ ^ temp ].
	self skipFollowSet: aFollowSet.
	self error: ('Unsupported: {1}' format: {currentToken fragment}).
	^ temp
]

{ #category : #statement }
GplASTBuilder >> statementSwitch: aFollowSet [
	self haltString: 'HOGE'.
	('IF' sameAs: currentToken fragment)
		ifTrue: [ ^ self ifStatement: aFollowSet ].
	('GOTO' sameAs: currentToken fragment)
		ifTrue: [ ^ self gotoStatement: aFollowSet ].
	(#('FOR' 'WHILE' 'DO') includes: currentToken fragment)
		ifTrue: [ ^ self doStatement: aFollowSet ].
	('SWITCH' sameAs: currentToken fragment)
		ifTrue: [ ^ self switchStatement: aFollowSet ].
	('ENDSUB' sameAs: currentToken fragment)
		ifTrue: [ ^ self endsubStatement: aFollowSet ].
	(#cr == currentToken type
		or: [ aFollowSet includes: currentToken fragment ])
		ifFalse: [ ^ self expressionStatement: aFollowSet ].
	^ nil
]

{ #category : #handler }
GplASTBuilder >> subroutine [
	self subroutineHeader.
	self declareStatements.
	self block: #('ENDSUB').
	self expected: 'ENDSUB'
]

{ #category : #deprecated }
GplASTBuilder >> subroutineCallStatement: aFollowSet [
	| tempNode opToken argumentNode subNode |
	self assert: #gdsiiMethod = currentToken type.
	tempNode := GplOperatorNode new.
	opToken := currentToken.
	self nextToken.
	#cr = currentToken type
		ifTrue: [ subNode := GplNiladicOperatorNode new ]
		ifFalse: [ subNode := GplMonadicOperatorNode new.
			argumentNode := self expression: aFollowSet.
			subNode param1: argumentNode ].
	subNode token: opToken.
	self addToBlock: subNode.
	^ subNode
]

{ #category : #handler }
GplASTBuilder >> subroutineHeader [
	| node |
	node := GplASTNode new.
	self pushBlock: node.
	root := node.
	node at: #syntax put: #subroutineHeader.
	node at: #kind put: #sub.
	self methodModifire: node.
	(node at: #methodKind) = #FUNCTION
		ifTrue: [ node at: #resultNode put: currentToken.
			self nextToken.
			currentToken fragment = ':='
				ifFalse: [ ^ self error: ':= expected' ].
			self nextToken ].
	self routineParams.
	self endStatement
]

{ #category : #statement }
GplASTBuilder >> subscriptOn: aGplValueNode [
	| subscriptNode |
	'[' = currentToken fragment
		ifTrue: [ self nextToken.
			subscriptNode := self expression: #(']' cr 'ENDSUB').
			aGplValueNode subscriptExpression: subscriptNode.
			self skipTokenExpected: ']' ]
]

{ #category : #statement }
GplASTBuilder >> switchStatement: aFollowSet [
	| stNode followSet conditionNode literalNode caseNode outNode |
	self expected: 'SWITCH'.
	stNode := GplASTNode new.
	stNode kind: #switch.
	self addToBlock: stNode.
	self nextToken.
	followSet := self followSet: 'OF' based: aFollowSet.
	conditionNode := self expression: followSet.
	stNode condition: conditionNode.
	self expected: 'OF' onSuccess: [ self nextTokenIgnoreCr ].
	stNode at: #cases put: OrderedCollection new.
	[ 'CASE' sameAs: currentToken fragment ]
		whileTrue: [ self nextToken.
			caseNode := GplASTNode new.
			caseNode kind: #case.
			(stNode at: #cases) add: caseNode.
			followSet := self followSet: ':' based: aFollowSet.
			literalNode := self listExpression: aFollowSet.
			caseNode at: #literal put: literalNode.
			self skipTokenExpected: ':'.
			followSet := self
				followSet: #('CASE' 'OUT' 'ENDSWITCH')
				based: aFollowSet.
			self pushBlock: caseNode during: [ self block: followSet ] ].
	('OUT' sameAs: currentToken fragment)
		ifTrue: [ self nextToken.
			outNode := GplASTNode new.
			outNode kind: #out.
			stNode at: #out put: outNode.
			self skipTokenExpected: ':'.
			followSet := self followSet: 'ENDSWITCH' based: aFollowSet.
			self pushBlock: outNode during: [ self block: followSet ] ].
	self skipTokenExpected: 'ENDSWITCH'.
	^ stNode
]

{ #category : #expression }
GplASTBuilder >> term: aPrecedence followSet: aFollowSet [
	| opSize |
	self inTraceMode
		ifTrue: [ {currentToken.
			aPrecedence} traceCr ].
	2 = aPrecedence
		ifTrue: [ ^ self listExpression: aFollowSet ].
	aPrecedence = (operatorGroups size + 1)
		ifTrue: [ "self halt."
			| factor |
			factor := self factor: aFollowSet.
			self subscriptOn: factor.
			^ factor ].
	opSize := self
		operandSizeOfPrecendence: (operatorGroups at: aPrecedence) key.
	opSize negative
		ifTrue: [ ^ self error: 'Fuck' ].
	opSize = 2
		ifTrue: [ | op |
			operandStack
				push: (self term: aPrecedence + 1 followSet: aFollowSet).
			[ self inPrecedenceToken: currentToken precedence: aPrecedence ]
				whileTrue: [ self assert: currentToken type = #operator.
					op := currentToken.
					self nextToken.
					operandStack
						push: (self term: aPrecedence + 1 followSet: aFollowSet).
					operandStack push: (self dyadicOperator: op) ].
			^ operandStack pop ].
	opSize = 1
		ifTrue: [ (self inPrecedenceToken: currentToken precedence: aPrecedence)
				ifTrue: [ | op |
					self assert: currentToken type = #operator.
					op := currentToken.
					self nextToken.
					operandStack
						push: (self term: aPrecedence + 1 followSet: aFollowSet).
					^ self monadicOperator: op ] ].
	^ self term: aPrecedence + 1 followSet: aFollowSet
]

{ #category : #expression }
GplASTBuilder >> termNew: aPrecedence followSet: aFollowSet [
	| opSize |
	self inTraceMode
		ifTrue: [ {currentToken.
			aPrecedence} traceCr ].
	2 = aPrecedence
		ifTrue: [ ^ self listExpression: aFollowSet ].
	aPrecedence = (operatorGroups size + 1)
		ifTrue: [ "self halt."
			| factor |
			factor := self factor: aFollowSet.
			self subscriptOn: factor.
			^ factor ].
	opSize := self
		operandSizeOfPrecendence: (operatorGroups at: aPrecedence) key.
	opSize negative
		ifTrue: [ ^ self error: 'Fuck' ].
	opSize = 2
		ifTrue: [ | op |
			operandStack
				push: (self term: aPrecedence + 1 followSet: aFollowSet).
			[ (self precedenceOfToken: currentToken) > aPrecedence ]
				whileTrue: [ self assert: currentToken type = #operator.
					op := currentToken.
					self nextToken.
					operandStack
						push:
							(self
								term: (self precedenceOfToken: currentToken) + 1
								followSet: aFollowSet).
					operandStack push: (self dyadicOperator: op) ].
			^ operandStack pop ].
	opSize = 1
		ifTrue: [ (self inPrecedenceToken: currentToken precedence: aPrecedence)
				ifTrue: [ | op |
					self assert: currentToken type = #operator.
					op := currentToken.
					self nextToken.
					operandStack
						push: (self term: aPrecedence + 1 followSet: aFollowSet).
					^ self monadicOperator: op ] ].
	^ self term: aPrecedence + 1 followSet: aFollowSet
]

{ #category : #expression }
GplASTBuilder >> termOld: aPrecedence followSet: aFollowSet [
	| opSize |
	self inTraceMode
		ifTrue: [ {currentToken.
			aPrecedence} traceCr ].
	2 = aPrecedence
		ifTrue: [ ^ self listExpression: aFollowSet ].
	aPrecedence = (operatorGroups size + 1)
		ifTrue: [ "self halt."
			| factor |
			factor := self factor: aFollowSet.
			self subscriptOn: factor.
			^ factor ].
	opSize := self
		operandSizeOfPrecendence: (operatorGroups at: aPrecedence) key.
	opSize negative
		ifTrue: [ ^ self error: 'Fuck' ].
	opSize = 2
		ifTrue: [ | op |
			operandStack
				push: (self term: aPrecedence + 1 followSet: aFollowSet).
			[ self inPrecedenceToken: currentToken precedence: aPrecedence ]
				whileTrue: [ self assert: currentToken type = #operator.
					op := currentToken.
					self nextToken.
					operandStack
						push: (self term: aPrecedence + 1 followSet: aFollowSet).
					operandStack push: (self dyadicOperator: op) ].
			^ operandStack pop ].
	opSize = 1
		ifTrue: [ (self inPrecedenceToken: currentToken precedence: aPrecedence)
				ifTrue: [ | op |
					self assert: currentToken type = #operator.
					op := currentToken.
					self nextToken.
					operandStack
						push: (self term: aPrecedence + 1 followSet: aFollowSet).
					^ self monadicOperator: op ] ].
	^ self term: aPrecedence + 1 followSet: aFollowSet
]

{ #category : #'stack operation' }
GplASTBuilder >> topBlock [
	^ blockStack top
]

{ #category : #accessing }
GplASTBuilder >> traceMode: aBoolean [
	inTraceMode := aBoolean
]

{ #category : #'as yet unclassified' }
GplASTBuilder >> unresolvedTokensDo: aTokensBlock [
	| savedPosition |
	savedPosition := rangeStream position.
	[ | restTokens |
	restTokens := rangeStream
		reset;
		upToEnd.
	aTokensBlock
		value: (restTokens select: [ :t | t type = #unresolved ]) ]
		ensure: [ rangeStream position: savedPosition ]
]

{ #category : #'as yet unclassified' }
GplASTBuilder >> upToCr [
	| done token tokens |
	done := false.
	tokens := OrderedCollection new.
	[ token := self basicNextToken.
	token isNil or: [ done ] ]
		whileFalse: [ (self isEffectiveToken: token)
				ifTrue: [ tokens add: token ]
				ifFalse: [ token type = #cr
						ifTrue: [ done := true ] ] ].
	^ tokens
]

{ #category : #'syntax parts' }
GplASTBuilder >> variable [
	| varNode |
	self assert: #variable = currentToken type.
	varNode := GplVariableNode new.
	varNode token: currentToken.
	self nextToken.
	^ varNode
]

{ #category : #deprecated }
GplASTBuilder >> whileDoStatement: aFollowSet [
	| loopNode followSet conditionNode |
	self skipTokenExpected: 'WHILE'.
	loopNode := GplASTNode new.
	loopNode kind: #while.
	self addToBlock: loopNode.
	followSet := Set new.
	aFollowSet ifNotNil: [ followSet addAll: aFollowSet ].
	followSet addAll: #('DO' 'ENDDO').
	conditionNode := self expression: followSet.
	loopNode at: #condition put: conditionNode.
	self skipTokenExpected: 'DO'.
	followSet := Set new.
	aFollowSet ifNotNil: [ followSet addAll: aFollowSet ].
	followSet addAll: #('ENDDO').
	self pushBlock: loopNode during: [ self block: followSet ].
	self skipTokenExpected: 'ENDDO'.
	^ loopNode
]
