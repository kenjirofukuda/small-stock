Class {
	#name : #GplForPartNode,
	#superclass : #GplASTNode,
	#category : #'GdsFeel-CLI-AST'
}

{ #category : #'as yet unclassified' }
GplForPartNode >> eachVariable [
	^ self at: #eachVariable
]

{ #category : #'as yet unclassified' }
GplForPartNode >> eachVariable: aGplASTNode [
	self at: #eachVariable put: aGplASTNode
]

{ #category : #'as yet unclassified' }
GplForPartNode >> initialize [
	super initialize.
	self eachVariable: nil.
	self range: nil.
]

{ #category : #'as yet unclassified' }
GplForPartNode >> range [
	^ self at: #range
]

{ #category : #'as yet unclassified' }
GplForPartNode >> range: aGplASTNode [
	self at: #range put: aGplASTNode
]

{ #category : #'as yet unclassified' }
GplForPartNode >> tagPrefix [
	^ 'FOR'
]
