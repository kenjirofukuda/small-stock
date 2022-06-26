Class {
	#name : #GplOperatorNode,
	#superclass : #GplValueNode,
	#category : #'GdsFeel-CLI-AST'
}

{ #category : #'as yet unclassified' }
GplOperatorNode >> initialize [
	super initialize.
	self kind: #op
]

{ #category : #accessing }
GplOperatorNode >> numArgs [
	^ self at: #numArgs
]

{ #category : #accessing }
GplOperatorNode >> opName [
	^ self token fragment
]

{ #category : #'as yet unclassified' }
GplOperatorNode >> param1 [
	^ self at: #param1
]

{ #category : #'as yet unclassified' }
GplOperatorNode >> param1: aNode [
	self at: #param1 put: aNode
]

{ #category : #'as yet unclassified' }
GplOperatorNode >> param2 [
	^ self at: #param2
]

{ #category : #'as yet unclassified' }
GplOperatorNode >> param2: aNode [
	self at: #param2 put: aNode
]
