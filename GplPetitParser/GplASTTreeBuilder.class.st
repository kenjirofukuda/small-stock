Class {
	#name : #GplASTTreeBuilder,
	#superclass : #GplSubroutineGrammar,
	#category : #'GplPetitParser-Grammar'
}

{ #category : #accessing }
GplASTTreeBuilder >> assignVariableNameExpr [
	^ super assignVariableNameExpr gplPPToken
]

{ #category : #'as yet unclassified' }
GplASTTreeBuilder >> buildBinaryNode: aPPToken [
	| ast |
	ast := GplASTBinaryNode new.
	ast start: aPPToken start.
	ast stop: aPPToken stop.
	ast
		left:
			(aPPToken parsedValue first
				parent: ast;
				yourself).
	ast
		operator:
			(GplASTOperatorNode new
				operator: aPPToken parsedValue second inputValue;
				parent: ast;
				yourself).
	ast
		right:
			(aPPToken parsedValue last
				parent: ast;
				yourself).
	^ ast
]

{ #category : #'as yet unclassified' }
GplASTTreeBuilder >> buildGplScalar: aPPToken [
	| gplObject |
	gplObject := aPPToken parsedValue
		ifEmpty: [ GdsNull instance ]
		ifNotEmpty: [ GdsScalar fromLiteral: aPPToken inputValue ].
	^ gplObject
]

{ #category : #'as yet unclassified' }
GplASTTreeBuilder >> buildGplString: aPPToken [
	| gplObject |
	gplObject := aPPToken parsedValue second
		ifEmpty: [ GdsNull instance ]
		ifNotEmpty: [ GdsString
				withAll:
					(aPPToken parsedValue second
						collect: [ :cl | 
							GdsCharacter
								fromAsciiValue:
									((cl isKindOf: Character)
										ifTrue: [ "{ $< . 'CR' . $> }" cl asciiValue ]
										ifFalse: [ GdsCharacter asciiValueInsideCharMarkLiteral: (cl at: 2) ])
							"$a ..." ]) ].
	^ gplObject
]

{ #category : #'as yet unclassified' }
GplASTTreeBuilder >> buildGplVector: aPPToken [
	| gplObject |
	gplObject := aPPToken parsedValue
		ifEmpty: [ GdsNull instance ]
		ifNotEmpty: [ | g |
			g := GdsVector fromLiteral: aPPToken inputValue.
			g size = 1
				ifTrue: [ g at: 1 ]
				ifFalse: [ g ] ].
	^ gplObject
]

{ #category : #accessing }
GplASTTreeBuilder >> expression [
	^ [ :stream | stream collection ] asParser and , super expression
		map: [ :source :node | node source: source ]
]

{ #category : #private }
GplASTTreeBuilder >> left: aLargerPrecParser op: op right: aOwnPrecParser [
	^ (super left: aLargerPrecParser op: op right: aOwnPrecParser)
		gplPPToken
		==> [ :token | 
			| ast |
			ast := [ self buildBinaryNode: token ]
				on: Error
				do: [ :ex | 
					token explore.
					ex signal ].
			ast ]
]

{ #category : #accessing }
GplASTTreeBuilder >> numberVectorLiteral [
	^ super numberVectorLiteral gplPPToken
		==> [ :token | 
			| gplObject ast |
			gplObject := self buildGplVector: token.
			ast := GplASTLiteralNode new.
			ast start: token start.
			ast stop: token stop.
			ast gplValue: gplObject.
			ast ]
]

{ #category : #accessing }
GplASTTreeBuilder >> parenthesis [
	^ super parenthesis
		==>
			[ :token | (token at: 3) addParenthesis: (token first start to: token last start) ]
]

{ #category : #accessing }
GplASTTreeBuilder >> scalarLiteral [
	^ super scalarLiteral	"gplPPToken ==> [ :token |
		| gplObject ast |
		gplObject := self buildGplScalar: token.
		ast := GplASTLiteralNode new.
		ast start: token start.
		ast stop: token stop.
		ast gplValue: gplObject.
		ast.
	]"
]

{ #category : #accessing }
GplASTTreeBuilder >> stringLiteral [
	"GplExpressionTreeBuilder new stringLiteral parse: '""*** <BRON>ERROR<BROFF>***""' "

	^ super stringLiteral gplPPToken
		==> [ :token | 
			| gplObject ast |
			gplObject := self buildGplString: token.
			ast := GplASTLiteralNode new.
			ast start: token start.
			ast stop: token stop.
			ast gplValue: gplObject.
			ast ]
]
