Class {
	#name : #GplScannerTest,
	#superclass : #GdsTestCase,
	#category : #'GdsFeel-CLI-Test'
}

{ #category : #tests }
GplScannerTest >> testSplitTokens [
	| input result expResult |

	input := '5 - 9'.
	expResult := #('5' '-' '9').
	result := GplScanner splitTokens: input.
	self assert: result = expResult.

	input := '5- 9'.
	expResult := #('5' '-' '9').
	result := GplScanner splitTokens: input.
	self assert: result = expResult.


]

{ #category : #tests }
GplScannerTest >> testSplitTokens1 [
	| input result expResult |
	input := 'var$1:=-5 + 3 + 4 + 6 - 10.'.
	expResult := { 'var$1' . ':=' . '-5' . '+' . '3' . '+' . '4' . '+' . '6' . '-' . '10.'}.
	result := GplScanner splitTokens: input.
	self assert: result = expResult.
]

{ #category : #tests }
GplScannerTest >> testSplitTokens10 [
	| input result expResult |

	input := '(1234 1235 1236)[6] ` Oh Bad Access!!'''.
	expResult := #('(' '1234' '1235' '1236' ')' '[' '6' ']' '` Oh Bad Access!!''').
	result := GplScanner splitTokens: input.
	self assert: result = expResult.


]

{ #category : #tests }
GplScannerTest >> testSplitTokens11 [
	| input result expResult |

	input := 'IF LIB="" THEN "<BEL>"'.
	expResult := #('IF' 'LIB' '=' '""' 'THEN' '"<BEL>"').
	result := GplScanner splitTokens: input.
	self assert: result = expResult.



]

{ #category : #tests }
GplScannerTest >> testSplitTokens12 [
	| input result expResult |

	input := '5-9'.
	expResult := #('5' '-9').
	result := GplScanner splitTokens: input.
	self assert: result = expResult.

]

{ #category : #tests }
GplScannerTest >> testSplitTokens13 [
	| input result expResult |

	input := '5 - 9'.
	expResult := #('5' '-' '9').
	result := GplScanner splitTokens: input.
	self assert: result = expResult.

]

{ #category : #tests }
GplScannerTest >> testSplitTokens14 [
	| input result expResult |

	input := '5- 9'.
	expResult := #('5' '-' '9').
	result := GplScanner splitTokens: input.
	self assert: result = expResult.


]

{ #category : #tests }
GplScannerTest >> testSplitTokens15 [
	| input result expResult |

	input := 'LABEL:K:=K-1'.
	expResult := #('LABEL:' 'K' ':=' 'K' '-' '1').
	result := GplScanner splitTokens: input.
	self assert: result = expResult.

]

{ #category : #tests }
GplScannerTest >> testSplitTokens2 [
	| input result expResult |

	input := 'var$1 := 1 + 1'.
	expResult := { 'var$1' . ':=' . '1' . '+' . '1'}.
	result := GplScanner splitTokens: input.
	self assert: result = expResult.
]

{ #category : #tests }
GplScannerTest >> testSplitTokens3 [
	| input result expResult |

	input := 'foo[;6]:=1+1'.
	expResult := { 'foo' . '[' . ';' . '6' . ']' . ':=' . '1' . '+' . '1'}.
	result := GplScanner splitTokens: input.
	self assert: result = expResult.


]

{ #category : #tests }
GplScannerTest >> testSplitTokens4 [
	| input result expResult |

	input := '(1234 1235 1236)[6] | Oh Bad Access!!'.
	expResult := #('(' '1234' '1235' '1236' ')' '[' '6' ']' '| Oh Bad Access!!').
	result := GplScanner splitTokens: input.
	self assert: result = expResult.


]

{ #category : #tests }
GplScannerTest >> testSplitTokens5 [
	| input result expResult |

	input := 'LABEL:K:=K+1'.
	expResult := #('LABEL:' 'K' ':=' 'K' '+' '1').
	result := GplScanner splitTokens: input.
	self assert: result = expResult.

]

{ #category : #tests }
GplScannerTest >> testSplitTokens6 [
	| input result expResult |

	input := 'IF 1 <> 2 THEN'.
	expResult := #('IF' '1' '<>' '2' 'THEN').
	result := GplScanner splitTokens: input.
	self assert: result = expResult.

]

{ #category : #tests }
GplScannerTest >> testSplitTokens7 [
	| input result expResult |

	input := '"this is a basic" INDECES_OF "fuck"    '.
	expResult := #('"this is a basic"' 'INDECES_OF' '"fuck"').
	result := GplScanner splitTokens: input.
	self assert: result = expResult.

]

{ #category : #tests }
GplScannerTest >> testSplitTokens8 [
	| input result expResult |

	input := 
'IF FOO = BAR THEN
  BAZ
ENDIF'.
	expResult := #('IF' 'FOO' '=' 'BAR' 'THEN' #cr 'BAZ' #cr 'ENDIF').
	result := GplScanner splitTokens: input.
	self assert: result = expResult.



]

{ #category : #tests }
GplScannerTest >> testSplitTokens9 [
	| input result expResult |

	input := 
'1 1 1 ^
+ 2 2 2'.
	expResult := #('1' '1' '1' '+' '2' '2' '2').
	result := GplScanner splitTokens: input.
	self assert: result = expResult 
	     description: 'can''t eat lineEnding escape character ^'.


]
