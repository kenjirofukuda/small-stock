Class {
	#name : #GplLiteralNode,
	#superclass : #GplValueNode,
	#category : #'GdsFeel-CLI-AST'
}

{ #category : #initialize }
GplLiteralNode >> initialize [
	super initialize.
	self kind: #literal
]

{ #category : #printing }
GplLiteralNode >> inspectString [
	^ [ self token fragment ]
		on: Error
		do: [ '"" (Fixed)' ]
]

{ #category : #printing }
GplLiteralNode >> tagPrefix [
	^ 'Literal'
]
