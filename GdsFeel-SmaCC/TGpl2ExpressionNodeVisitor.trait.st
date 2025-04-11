Trait {
	#name : #TGpl2ExpressionNodeVisitor,
	#traits : 'TSmaCCParseNodeVisitor',
	#classTraits : 'TSmaCCParseNodeVisitor classTrait',
	#category : #'GdsFeel-SmaCC'
}

{ #category : #generated }
TGpl2ExpressionNodeVisitor >> visitExpression: anExpression [

	^ self visitSmaCCParseNode: anExpression
]

{ #category : #generated }
TGpl2ExpressionNodeVisitor >> visitMonadicExpression: aMonadicExpression [

	^ self visitExpression: aMonadicExpression
]

{ #category : #generated }
TGpl2ExpressionNodeVisitor >> visitNumber: aNumber [

	^ self visitExpression: aNumber
]

{ #category : #generated }
TGpl2ExpressionNodeVisitor >> visitVector: aVector [

	^ self visitExpression: aVector
]
