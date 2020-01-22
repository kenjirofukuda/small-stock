Class {
	#name : #GplListLib,
	#superclass : #GplSingleHandler,
	#category : #'GdsFeel-CLI-Commands'
}

{ #category : #accessing }
GplListLib class >> methodName [
	^'LISTLIB'
]

{ #category : #handler }
GplListLib >> evaluateToken: aToken [
	| arg1 gdsPattern sqPattern names |
	names := self library structureNames.
	((evaluator numArgs: aToken) > 0)
		ifTrue: [
			arg1 := evaluator popArg asGplValue.
			self mustbeString: arg1.
			gdsPattern := arg1 gplString.
			"TODO: real implements"
			sqPattern := gdsPattern copyReplaceAll: '-' with: '*'.
			names := names select: [: each | sqPattern match: each ].].		
	^self strings: names.
	
]
