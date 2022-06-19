Class {
	#name : #GplIfStatementNode,
	#superclass : #GplASTNode,
	#instVars : [
		'ifPart',
		'elifParts',
		'elsePart'
	],
	#category : #'GdsFeel-CLI-AST'
}

{ #category : #'as yet unclassified' }
GplIfStatementNode >> elifParts [
	^ elifParts ifNil: [ elifParts := GplASTNode new kind: #elifs ]
]

{ #category : #'as yet unclassified' }
GplIfStatementNode >> elsePart [
	^ elsePart ifNil: [ elsePart := GplElsePartNode new ]
]

{ #category : #'as yet unclassified' }
GplIfStatementNode >> ifPart [
	^ ifPart ifNil: [ ifPart := GplIfPartNode new ]
]

{ #category : #'as yet unclassified' }
GplIfStatementNode >> initialize [
	super initialize.
	ifPart := GplIfPartNode new
]

{ #category : #'as yet unclassified' }
GplIfStatementNode >> inspectString [
	^ self ifPart condition printString
]

{ #category : #'as yet unclassified' }
GplIfStatementNode >> lastElif [
	self elifParts nodes ifEmpty: [ ^ self newElif ].
	^ self elifParts nodes last
]

{ #category : #'as yet unclassified' }
GplIfStatementNode >> newElif [
	self elifParts addSubNode: GplElifPartNode new.
	^ self elifParts nodes last
]

{ #category : #'as yet unclassified' }
GplIfStatementNode >> tagPrefix [
	^ 'ifSt'
]
