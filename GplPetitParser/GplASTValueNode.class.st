Class {
	#name : #GplASTValueNode,
	#superclass : #GplPPASTNode,
	#category : #'GplPetitParser-AST'
}

{ #category : #accessing }
GplASTValueNode >> addParenthesis: anInterval [
	parentheses ifNil: [ parentheses := OrderedCollection new: 1 ].
	parentheses add: anInterval
]

{ #category : #accessing }
GplASTValueNode >> parentheses [
	^ parentheses ifNil: [ #() ] ifNotNil: [ parentheses ]
]

{ #category : #accessing }
GplASTValueNode >> start [
	^ parentheses
		ifNil: [ self startWithoutParentheses ]
		ifNotNil: [ parentheses last first ]
]

{ #category : #accessing }
GplASTValueNode >> startWithoutParentheses [
	^ start
]

{ #category : #accessing }
GplASTValueNode >> stop [
	^ parentheses
		ifNil: [ self stopWithoutParentheses ]
		ifNotNil: [ parentheses last last ]
]

{ #category : #accessing }
GplASTValueNode >> stopWithoutParentheses [
	^ stop
]
