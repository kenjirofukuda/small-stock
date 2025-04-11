Class {
	#name : 'GplVariableNode',
	#superclass : 'GplValueNode',
	#category : 'GdsFeel-CLI-AST',
	#package : 'GdsFeel-CLI',
	#tag : 'AST'
}

{ #category : 'initialize' }
GplVariableNode >> initialize [
	super initialize.
	self kind: #variable
]

{ #category : 'printing' }
GplVariableNode >> inspectString [
	([ self token ]
		on: Error
		do: [ nil ])
		ifNil: [ ^ super inspectString ]
		ifNotNil: [ :t | ^ t fragment ]
]

{ #category : 'printing' }
GplVariableNode >> tagPrefix [
	^ 'VAR'
]
