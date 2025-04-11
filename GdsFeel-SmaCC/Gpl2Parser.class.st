Class {
	#name : #Gpl2Parser,
	#superclass : #SmaCCGLRParser,
	#category : #'GdsFeel-SmaCC'
}

{ #category : #'generated-accessing' }
Gpl2Parser class >> cacheId [
	^'2022-06-26T16:29:27.843134+09:00'
]

{ #category : #generated }
Gpl2Parser class >> definitionComment [
"%glr;

# %left ""+"" ""-"";
# %left ""*"" ""/"";

%root Expression;
%prefix Gpl2;
%suffix Node;
%id <number> <name>;
%annotate_tokens;
# %ignore_variables whiteToken;
%hierarchy Expression (
 MonadicExpression);
 
<bit> : [01] ;
<white> : [\s\t] ;
<white_plus> : <white>+;
<positive_integer> : 0 | [1-9] \d*;
<integer> : \-? <positive_integer>; 
<point_float> : (\d+ \. \d*) | (\. \d+) ; 
<exponent_float> : (\d+ | <point_float>) E (\+|\-)? \d+ ;
<float_number> : \-? ( <point_float> | <exponent_float> );
<whitespace> : \s+;
<number> : <bit> | <integer> | <float_number>;
# <bit_vector> : <bit>(<white>+ <bit>)*;
# <number_vector> : <number>(<white>+ <number>)*;
# <vector> : <bit_vector> | <number_vector> ;
<name> : [A-Z][A-Z_$\d]{0,31};
 
# Monadic Operaters
<negate> : \- ;
<signum> : \* ;
<identity> : \+ ;
<ravel> : \, ;
<ratiprocal> : \% ;
<size> : SIZE ;

# Dyadic Operaters
<add> : \+ ;
<sub> : \- ;
<mul> : \* ;
<div> : \% ;

 
Expression
 : array {{}}
 | <name> 'name' {{}}
 | MonadicExpression
 ;


MonadicExpression
 : <negate> 'operator' <white>+ Expression 'rhs' {{}}
 | <identity> 'operator' <white>* Expression 'rhs' {{}}
 | <ravel> 'operator' <white>* Expression 'rhs' {{}}
 | <signum> 'operator' <white>* Expression 'rhs' {{}}
 | <ratiprocal> 'operator' <white>* Expression 'rhs' {{}}
 | <size> 'operator' Expression 'rhs' {{}}
 ;

number : <number> 'value' {{Number}} ;

array 
 : number
 | number 'number' (<white>+ number 'number')+ {{Vector}}
 ;"
]

{ #category : #generated }
Gpl2Parser class >> reduceTable [
^#(
	#(16 1 #reduceActionFornumber1: 1377281 false) 
	#(12 1 #reduceActionForExpression2: 954370 false) 
	#(15 0 #reduceActionFor_white__1: 1128449 false) 
	#(12 1 #liftFirstValue: 954371 false) 
	#(17 1 #liftFirstValue: 1418241 false) 
	#(12 1 #reduceActionForExpression1: 954369 false) 
	#(14 1 #reduceActionFor_white__1_: 1071105 false) 
	#(13 2 #reduceActionForMonadicExpression6: 1029126 false) 
	#(19 1 #reduceActionFor__white___number__number___1: 1455105 false) 
	#(17 2 #reduceActionForarray2: 1418242 false) 
	#(14 2 #reduceActionFor_white__2: 1071106 false) 
	#(13 3 #reduceActionForMonadicExpression1: 1029121 false) 
	#(15 2 #reduceActionFor_white__2: 1128450 false) 
	#(13 3 #reduceActionForMonadicExpression1: 1029124 false) 
	#(13 3 #reduceActionForMonadicExpression1: 1029122 false) 
	#(13 3 #reduceActionForMonadicExpression1: 1029123 false) 
	#(13 3 #reduceActionForMonadicExpression1: 1029125 false) 
	#(18 2 #reduceActionFor__white___number__number__1: 1455105 false) 
	#(19 2 #reduceActionFor__white___number__number___2: 1455106 false)
	).
]

{ #category : #'generated-accessing' }
Gpl2Parser class >> scannerClass [
	^Gpl2Scanner
]

{ #category : #generated }
Gpl2Parser class >> startingStateForExpression [

	^ 1
]

{ #category : #generated }
Gpl2Parser class >> symbolNames [

	^ #( '<white>' '<whitespace>' '<number>' '<name>' '<negate>'
	     '<signum>' '<identity>' '<ravel>' '<ratiprocal>' '<size>'
	     'B e g i n' 'Expression' 'MonadicExpression' '<white>+'
	     '<white>*' 'number' 'array' '(<white>+ number ''number'')'
	     '(<white>+ number ''number'')+' 'E O F' 'error' )
]

{ #category : #generated }
Gpl2Parser class >> symbolTypes [

	^ #( #SmaCCToken #SmaCCToken #SmaCCToken #SmaCCToken #SmaCCToken
	     #SmaCCToken #SmaCCToken #SmaCCToken #SmaCCToken #SmaCCToken
	     #Gpl2ExpressionNode #Gpl2ExpressionNode #Gpl2MonadicExpressionNode
	     #OrderedCollection #OrderedCollection #Gpl2NumberNode
	     #Gpl2ExpressionNode #OrderedCollection #OrderedCollection
	     #SmaCCToken #SmaCCErrorNode )
]

{ #category : #generated }
Gpl2Parser class >> transitionTable [
^#(
#[1 0 9 0 3 0 13 0 4 0 17 0 5 0 21 0 6 0 25 0 7 0 29 0 8 0 33 0 9 0 37 0 10 0 41 0 12 0 41 0 13 0 49 0 16 0 53 0 17] 
#[0 0 6 0 1 0 20] 
#[0 0 10 0 20] 
#[1 0 57 0 1 0 61 0 14] 
#[1 0 14 0 1 0 14 0 3 0 14 0 4 0 14 0 5 0 14 0 6 0 14 0 7 0 14 0 8 0 14 0 9 0 14 0 10 0 65 0 15] 
#[1 0 14 0 1 0 14 0 3 0 14 0 4 0 14 0 5 0 14 0 6 0 14 0 7 0 14 0 8 0 14 0 9 0 14 0 10 0 69 0 15] 
#[1 0 14 0 1 0 14 0 3 0 14 0 4 0 14 0 5 0 14 0 6 0 14 0 7 0 14 0 8 0 14 0 9 0 14 0 10 0 73 0 15] 
#[1 0 14 0 1 0 14 0 3 0 14 0 4 0 14 0 5 0 14 0 6 0 14 0 7 0 14 0 8 0 14 0 9 0 14 0 10 0 77 0 15] 
#[1 0 9 0 3 0 13 0 4 0 17 0 5 0 21 0 6 0 25 0 7 0 29 0 8 0 33 0 9 0 37 0 10 0 81 0 12 0 81 0 13 0 49 0 16 0 53 0 17] 
#[0 0 0 0 20] 
#[0 0 18 0 20] 
#[1 0 57 0 1 0 85 0 14 0 89 0 18 0 93 0 19 0 22 0 20] 
#[0 0 26 0 20] 
#[0 0 30 0 1 0 3 0 4 0 5 0 6 0 7 0 8 0 9 0 10] 
#[1 0 97 0 1 0 9 0 3 0 13 0 4 0 17 0 5 0 21 0 6 0 25 0 7 0 29 0 8 0 33 0 9 0 37 0 10 0 101 0 12 0 101 0 13 0 49 0 16 0 53 0 17] 
#[1 0 105 0 1 0 9 0 3 0 13 0 4 0 17 0 5 0 21 0 6 0 25 0 7 0 29 0 8 0 33 0 9 0 37 0 10 0 109 0 12 0 109 0 13 0 49 0 16 0 53 0 17] 
#[1 0 105 0 1 0 9 0 3 0 13 0 4 0 17 0 5 0 21 0 6 0 25 0 7 0 29 0 8 0 33 0 9 0 37 0 10 0 113 0 12 0 113 0 13 0 49 0 16 0 53 0 17] 
#[1 0 105 0 1 0 9 0 3 0 13 0 4 0 17 0 5 0 21 0 6 0 25 0 7 0 29 0 8 0 33 0 9 0 37 0 10 0 117 0 12 0 117 0 13 0 49 0 16 0 53 0 17] 
#[1 0 105 0 1 0 9 0 3 0 13 0 4 0 17 0 5 0 21 0 6 0 25 0 7 0 29 0 8 0 33 0 9 0 37 0 10 0 121 0 12 0 121 0 13 0 49 0 16 0 53 0 17] 
#[0 0 34 0 20] 
#[1 0 97 0 1 0 9 0 3 0 125 0 16] 
#[0 0 38 0 1 0 20] 
#[1 0 57 0 1 0 85 0 14 0 129 0 18 0 42 0 20] 
#[0 0 46 0 1 0 3 0 4 0 5 0 6 0 7 0 8 0 9 0 10] 
#[0 0 50 0 20] 
#[0 0 54 0 1 0 3 0 4 0 5 0 6 0 7 0 8 0 9 0 10] 
#[0 0 58 0 20] 
#[0 0 62 0 20] 
#[0 0 66 0 20] 
#[0 0 70 0 20] 
#[0 0 74 0 1 0 20] 
#[0 0 78 0 1 0 20]
	).
]

{ #category : #'generated-reduction actions' }
Gpl2Parser >> reduceActionForExpression1: nodes [

	| result |
	result := nodes at: 1.
	^ result
]

{ #category : #'generated-reduction actions' }
Gpl2Parser >> reduceActionForExpression2: nodes [

	| result |
	result := Gpl2ExpressionNode new.
	result name: (nodes at: 1).
	^ result
]

{ #category : #'generated-reduction actions' }
Gpl2Parser >> reduceActionForMonadicExpression1: nodes [

	| result |
	result := Gpl2MonadicExpressionNode new.
	result operator: (nodes at: 1).
	result addTokens: (nodes at: 2) to: result whiteTokens.
	result rhs: (nodes at: 3).
	^ result
]

{ #category : #'generated-reduction actions' }
Gpl2Parser >> reduceActionForMonadicExpression6: nodes [

	| result |
	result := Gpl2MonadicExpressionNode new.
	result operator: (nodes at: 1).
	result rhs: (nodes at: 2).
	^ result
]

{ #category : #'generated-reduction actions' }
Gpl2Parser >> reduceActionFor__white___number__number__1: nodes [

	| result |
	result := Array new: 2.
	result at: 1 put: (OrderedCollection new: 2).
	self addAll: (nodes at: 1) to: (result at: 1).
	result at: 2 put: (nodes at: 2).
	^ result
]

{ #category : #'generated-reduction actions' }
Gpl2Parser >> reduceActionFor__white___number__number___1: nodes [

	| result |
	result := Array new: 2.
	result at: 1 put: (OrderedCollection new: 2).
	result at: 2 put: (OrderedCollection new: 2).
	self addAll: ((nodes at: 1) at: 1) to: (result at: 1).
	self add: ((nodes at: 1) at: 2) to: (result at: 2).
	^ result
]

{ #category : #'generated-reduction actions' }
Gpl2Parser >> reduceActionFor__white___number__number___2: nodes [

	| result |
	result := nodes at: 1.
	self addAll: ((nodes at: 2) at: 1) to: (result at: 1).
	self add: ((nodes at: 2) at: 2) to: (result at: 2).
	^ result
]

{ #category : #'generated-reduction actions' }
Gpl2Parser >> reduceActionFor_white__1: nodes [

	| result |
	result := OrderedCollection new: 2.
	^ result
]

{ #category : #'generated-reduction actions' }
Gpl2Parser >> reduceActionFor_white__1_: nodes [

	| result |
	result := OrderedCollection new: 2.
	self add: (nodes at: 1) to: result.
	^ result
]

{ #category : #'generated-reduction actions' }
Gpl2Parser >> reduceActionFor_white__2: nodes [

	| result |
	result := nodes at: 1.
	self add: (nodes at: 2) to: result.
	^ result
]

{ #category : #'generated-reduction actions' }
Gpl2Parser >> reduceActionForarray2: nodes [

	| result |
	result := Gpl2VectorNode new.
	result addNode: (nodes at: 1) to: result numbers.
	result addTokens: ((nodes at: 2) at: 1) to: result whiteTokens.
	result addNodes: ((nodes at: 2) at: 2) to: result numbers.
	^ result
]

{ #category : #'generated-reduction actions' }
Gpl2Parser >> reduceActionFornumber1: nodes [

	| result |
	result := Gpl2NumberNode new.
	result value: (nodes at: 1).
	^ result
]
