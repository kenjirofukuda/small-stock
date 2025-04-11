Class {
	#name : #CalcParser,
	#superclass : #SmaCCParser,
	#category : #'GdsFeel-SmaCC'
}

{ #category : #'generated-accessing' }
CalcParser class >> cacheId [
	^'2022-06-23T19:52:05.889384+09:00'
]

{ #category : #generated }
CalcParser class >> definitionComment [
"<number>        :       [0-9]+ (\. [0-9]*) ? ;
<whitespace> :  \s+;

Expression 
	: Expression ""+"" Number
	| Number
	;
Number 
	: <number>
	;"
]

{ #category : #'generated-accessing' }
CalcParser class >> scannerClass [
	^CalcScanner
]

{ #category : #generated }
CalcParser class >> startingStateForExpression [
	^ 1
]

{ #category : #generated }
CalcParser >> reduceTable [
^#(
	#(4 1 #reduceFor:) 
	#(5 1 #reduceFor:) 
	#(5 3 #reduceFor:)
	).
]

{ #category : #generated }
CalcParser >> symbolNames [
	^ #('"+"' '<number>' '<whitespace>' 'Number' 'Expression' 'E O F' 'error' 'B e g i n')
]

{ #category : #generated }
CalcParser >> transitionTable [
^#(
#[1 0 9 0 2 0 13 0 4 0 17 0 5] 
#[0 0 6 0 1 0 6] 
#[0 0 10 0 1 0 6] 
#[1 0 21 0 1 0 0 0 6] 
#[1 0 9 0 2 0 25 0 4] 
#[0 0 14 0 1 0 6]
	).
]
