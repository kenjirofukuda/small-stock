Class {
	#name : #GdsExpressionEvaluator,
	#superclass : #ExpressionEvaluator,
	#instVars : [
		'gplEvaluator'
	],
	#category : #'GdsFeel-CLI-CommandShell'
}

{ #category : #evaluating }
GdsExpressionEvaluator >> blockString [
	"Answer source code for a block to execute my expression. Attempt to give it the correct
	number of parameters based on scanning expression for use of #args, #stderr, #stdout,
	and #stdin tokens."

	"self new expression: 'A := 1'; blockString"
	"self new expression: 'A := 1'; evaluationBlock"
	"self new expression: 'IOTA 10'; gplEvaluator: GplEvaluator new;  blockValue"
	

	| prefix |
	self expression isNil
		ifTrue:
			[^ '[]']
		ifFalse:
			[
			prefix := '[ :evaluator |'.
			^ prefix, ' evaluator evaluateConsoleLine: ', self expression printString, ' ]']

]

{ #category : #evaluating }
GdsExpressionEvaluator >> blockValue [
	"Evaluate my evaluationBlock. For a smart block, answer self. For a dumb
	block, answer the result of evaluating it. Heuristic: If the block receives
	two or more arguments, then assume that it was smart enough to write
	output to stdout. Otherwise, assume that it was a dumb block."

	| |
	self evaluationBlock ifNil: [^ nil].
	^self evaluationBlock value: gplEvaluator.
]

{ #category : #accessing }
GdsExpressionEvaluator >> gplEvaluator: aGplEvaluator [
	gplEvaluator := aGplEvaluator.
	aGplEvaluator junction: self.
]

{ #category : #evaluating }
GdsExpressionEvaluator >> value [
	"Evaluate my evaluationBlock. If the block evaluates to anything other
	than self, then print the result on pipeFromOutput as output. Otherwise,
	assume that the block was smart enough to have written its own output.
	For a block which does not write its own output, add a trailing line
	terminator after the evaluation if needed. Answer self as the result of
	the evaluation."

	| result resultString |
	self success. "Hope for the best, send #fail if something goes wrong"
	self isNotYetRunning ifTrue:
		[self ensurePipeFromOutput.
		self running.
		self evaluationBlock notNil
			ifTrue:
				[result := [self blockValue]
					on: Error
					do: [:e |
						self errorPipelineStream nextPutAll: e description; nextPut: Character lf.
						self fail].
				(result == self)
					ifFalse:
						[resultString := result asString.
						pipeFromOutput nextPutAll: resultString.
						(resultString isEmpty not and:
							[(resultString last ~= Character cr) and:
								[resultString last ~= Character lf]])
							ifTrue: [pipeFromOutput nextPut: Character lf]]]
			ifFalse:
				[self fail].
		self complete]

]
