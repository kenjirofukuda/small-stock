Class {
	#name : #GplTextInput,
	#superclass : #GplSingleHandler,
	#category : #'GdsFeel-CLI-Commands'
}

{ #category : #'as yet unclassified' }
GplTextInput class >> isFunctionAllowed [
	^true.
	
]

{ #category : #'as yet unclassified' }
GplTextInput class >> methodName [
	^'TEXTINPUT'
]

{ #category : #handler }
GplTextInput >> evaluateToken: aToken [ 
	evaluator hasSuspendContext
		ifFalse: [
			^self signalPrompt: thisContext].
	^self signalResult.
]

{ #category : #handler }
GplTextInput >> signalPrompt: aContext [
	| arg1 gv1 |
	arg1 := evaluator popArg.
	gv1 := arg1 asGplValue.
	gv1 isCharVector
		ifFalse: [^self error: 'PROMPT MUST BE STRING'].
	evaluator pushSuspendContext: aContext.	
	^GplPromptException new signal: 	gv1 gplString

]

{ #category : #handler }
GplTextInput >> signalResult [
	| smPrompt |
	smPrompt := evaluator popResult.
	self assert: smPrompt isNil not.
	"lastContext explore."
	^smPrompt asGdsValue.

]
