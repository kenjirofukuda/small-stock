Class {
	#name : 'GplIfPartNode',
	#superclass : 'GplElsePartNode',
	#instVars : [
		'condition'
	],
	#category : 'GdsFeel-CLI-AST',
	#package : 'GdsFeel-CLI',
	#tag : 'AST'
}

{ #category : 'as yet unclassified' }
GplIfPartNode >> blockCloseFragments [
	^ #('ELIF' 'ELSE' 'ENDIF')
]

{ #category : 'printing' }
GplIfPartNode >> inspectString [
	^ self condition printString
]

{ #category : 'printing' }
GplIfPartNode >> tagPrefix [
	^ 'IF'
]
