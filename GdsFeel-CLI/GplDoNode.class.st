Class {
	#name : #GplDoNode,
	#superclass : #GplASTNode,
	#instVars : [
		'forPart',
		'whilePart',
		'untilPart'
	],
	#category : #'GdsFeel-CLI-AST'
}

{ #category : #accesing }
GplDoNode >> forPart [
	^ forPart ifNil: [ forPart := GplForPartNode new ]
]

{ #category : #printing }
GplDoNode >> tagPrefix [
	^ 'DO'
]

{ #category : #accesing }
GplDoNode >> untilPart [
	^ untilPart ifNil: [ untilPart := GplUntilPartNode new ]
]

{ #category : #accesing }
GplDoNode >> whilePart [
	^ whilePart ifNil: [ whilePart := GplWhilePartNode new ]
]
