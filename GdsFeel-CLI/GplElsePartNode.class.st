Class {
	#name : 'GplElsePartNode',
	#superclass : 'GplASTNode',
	#category : 'GdsFeel-CLI-AST',
	#package : 'GdsFeel-CLI',
	#tag : 'AST'
}

{ #category : 'as yet unclassified' }
GplElsePartNode >> blockCloseFragments [
	^ #('ENDIF')
]

{ #category : 'printing' }
GplElsePartNode >> tagPrefix [
	^ 'ELSE'
]
