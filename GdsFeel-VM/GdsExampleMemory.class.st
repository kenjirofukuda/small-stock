Class {
	#name : #GdsExampleMemory,
	#superclass : #Object,
	#instVars : [
		'memory',
		'maxLoc',
		'minLoc',
		'pc',
		'fixedInstractionMap'
	],
	#category : #'GdsFeel-VM'
}

{ #category : #'as yet unclassified' }
GdsExampleMemory class >> exampleListing [
"	(StringHolder new contents: GdsExampleMemory exampleListing)
		openLabel: 'ILLGOTO listing'.
"
^'
000240 B000 null
000241 3315 char vec "THIS IS THE BEGINING" (21,000000)
000242 0000
000243 7000 output
000244 B001 eos
000245 1000 push FLG1
000246 0003
000247 0001 1
000250 2000 :=
000251 B001 eos
000252 3311 char vec "BEGINING OF THE LOOP" (17,000014)
000253 000C
000254 7000 output
000255 B001 eos
000256 1000 push FLG1
000257 0003
000260 8001 teqz 000264
000261 0004
000262 8000 jmp 000241
000263 FFEF 
000264 3317 char vec "THIS IS INSIDE THE LOOP" (23,000025)
000265 0015
000266 7000 output
000267 B001 eos
000270 0001 1
000271 8001 teqz 00252
000272 FFF1
000273 3316 har vec "THIS IS AFTER THE LOOP" (22,000042)
000274 0022
000275 7000 output
000276 B001 eos
000277 3300 char vec "" (0,000000)
000300 0000
000301 7000 output
000302 B001 eos
000303 8000 jmp 000241
000304 FFDE
000305 B002 eop
'
]

{ #category : #'as yet unclassified' }
GdsExampleMemory class >> exampleSource [
"	(StringHolder new contents: GdsExampleMemory exampleSource)
		openLabel: 'ILLGOTO sourcs'.
"^'
NILADIC PROCEDURE ILLGOTO

EXTERNAL FLG1

BEGIN:
"THIS IS THE BEGINING"
FLG := 1
|CODE

DO
  "BEGINING OF THE LOOP"
  |CODE
  IF FLG1 THEN
    |CODE
    GOTO INLOOP
  ENDIF
  |CODE
  INLOOP:
  "THIS IS INSIDE THE LOOP"
  |CODE
UNTIL 1 ENDDO

|CODE
"THIS IS AFTER THE LOOP"
|CODE
""
GOTO BEGIN

ENDSUB

'
]

{ #category : #'as yet unclassified' }
GdsExampleMemory >> InstractionOfLine: aString [
	| hexExpr |
	self assert: aString size >= 11.
	hexExpr := (aString findTokens: ' ') second.
	self assert: (hexExpr size = 4 and: [hexExpr isAllHex]).
	^Integer readFrom: hexExpr readStream base: 16.
	
]

{ #category : #'as yet unclassified' }
GdsExampleMemory >> buildImage [
	"GdsExampleMemory new buildImage."
	| lines   |
	lines := self class exampleListing lines reject: [:line | line isEmpty].
	minLoc := self locationOfLine: lines first.
	maxLoc := self locationOfLine: lines last.
	memory := IntegerArray new: maxLoc + 1.
	lines do: [:line | | loc inst |
		loc :=  self locationOfLine: line.
		inst :=  self InstractionOfLine: line.
		memory at: loc put: inst.].	
]

{ #category : #'as yet unclassified' }
GdsExampleMemory >> dump [
	"GdsExampleMemory new dump"
	self indexedLoop: [:i | | log |
		log := String streamContents: [:s |
			s nextPutAll: (i  printStringBase: 8 length: 6 padded: true).
			s space.
			s nextPutAll: ((memory at: i)  printStringBase: 16 length: 4 padded: true).
			s space.
			s nextPutAll: (self instractionType: (memory at: i)) ].
		Transcript cr; show: log.]	
	
]

{ #category : #'as yet unclassified' }
GdsExampleMemory >> dump2 [
	"GdsExampleMemory new dump2"
	self runLoopInstractions: [:instArray | | log |
		instArray doWithIndex: [:inst :index |
			log := String streamContents: [:s |
				s nextPutAll: (self octalLocation: (pc - (instArray size) + index) ).
				s space.
				s nextPutAll: (self hexInstraction: inst).
				s space.
				index = 1
					ifTrue: [
						s nextPutAll: (self instractionType: inst) ]]].
		Transcript cr; show: log.]	
	
]

{ #category : #'as yet unclassified' }
GdsExampleMemory >> dump3 [
	"GdsExampleMemory new dump3"
	self runLoopInstractions: [:instArray | 
		(Array streamContents: [ :s |
			s nextPut: (self octalLocation: pc - instArray size).
			s nextPut: (instArray collect: [:each | self hexInstraction: each]).
			s nextPut: (self instractionType: instArray first)]) traceCr]	
	
]

{ #category : #'as yet unclassified' }
GdsExampleMemory >> hexInstraction: anInteger [
	^anInteger  printStringBase: 16 length: 4 padded: true
]

{ #category : #'as yet unclassified' }
GdsExampleMemory >> indexedLoop: aIndexBlock [ 
	self assert: memory notNil.
	self assert: minLoc < maxLoc.
	minLoc to: maxLoc do: [:i |
		aIndexBlock value: i]	
	
]

{ #category : #'as yet unclassified' }
GdsExampleMemory >> initialize [
	fixedInstractionMap := Dictionary new.
	self  instractionMapInto: fixedInstractionMap.
	pc := 1.
	self buildImage.
	
	
]

{ #category : #'as yet unclassified' }
GdsExampleMemory >> instractionMapInto: aMap [
	aMap at: 16r0001 put: #pushOne.
	aMap at: 16r0010 put: #pushInteger:. "nextWord: 16bit Integer"
	aMap at: 16r0020 put: #pushReal:a:b:c:d:. "next 4word: 32bit not IEEE Real"
	aMap at: 16r2000 put: #assin. ":="
	aMap at: 16r7000 put: #output.	
	aMap at: 16r1000 put: #pushVar:. "next word: Variable Index"
	aMap at: 16r4000 put: #slice.	

	"50 external call"
	"  2x: Procedure Call"
	"  3x: Function Call"
	"   0: niladic"	
	"   1: monadic"	
	"   2: dyadic"	
	aMap at: 16r5020 put: #callNiladicProcedure:.	
	aMap at: 16r5021 put: #callMonadicProcedure:.	
	aMap at: 16r5022 put: #callDyadicProcedure:.	
		
	aMap at: 16r5030 put: #callNiladicProcedure:.	
	aMap at: 16r5031 put: #callMonadicProcedure:.	
	aMap at: 16r5032 put: #callDyadicProcedure:.	

	"branch"
	aMap at: 16r8000 put: #jmp:.
	aMap at: 16r8001 put: #teqz:.	
	aMap at: 16r8002 put: #teqpg:.	
	aMap at: 16r8003 put: #teqnpg:.	

	"start stop marker"
	aMap at: 16rB000 put: #null.
	aMap at: 16rB001 put: #eos.
	aMap at: 16rB002 put: #eop.

	"C7 builtin functions"
	aMap at: 16rC700 put: #cos.          "COS"
	aMap at: 16rC70C put: #sin.          "SIN"	
	aMap at: 16rC711 put: #monadicMinus.	"-n"
		
	aMap at: 16rC740 put: #add.           "a + b"	
	aMap at: 16rC741 put: #subtract.      "a - b"	
	aMap at: 16rC742 put: #multiply.      "a * b"	
	aMap at: 16rC743 put: #divide.        "a % b"	

	aMap at: 16rC746 put: #power.	         "a ^ 2" 

	aMap at: 16rC753 put: #ltSlice.       "<[]"	
	aMap at: 16rC755 put: #gtSlice.	      ">[]"
	aMap at: 16rC757 put: #neSlice.	      "<>[]"
	
]

{ #category : #utility }
GdsExampleMemory >> instractionSpecText [
	^String streamContents: [:s |
		fixedInstractionMap keys asArray sort do: [:keyInteger | |instractionSymbol |
			instractionSymbol := fixedInstractionMap at: keyInteger.
			s nextPutAll: (self hexInstraction: keyInteger).
			s space.
			s nextPutAll: instractionSymbol printString.
			s cr.]
		]
]

{ #category : #'as yet unclassified' }
GdsExampleMemory >> instractionType: aShortInteger [
	| type hiByteMasked|
	hiByteMasked := aShortInteger bitAnd: 16rFF00.
	hiByteMasked = 16r3300
		ifTrue: [^#pushCharVec:].
	hiByteMasked = 16r5000
		ifTrue: [^#callExternal].
		
	type := fixedInstractionMap at: aShortInteger ifAbsentPut: [#undefined]. 
	^type.
	
	
]

{ #category : #'as yet unclassified' }
GdsExampleMemory >> locationOfLine: aString [
	| octalExpr |
	self assert: aString size >= 6.
	octalExpr := (aString findTokens: ' ') first.
	self assert: (octalExpr size = 6 and: [octalExpr isAllOctal]).
	^Integer readFrom: octalExpr readStream base: 8.
	
]

{ #category : #'as yet unclassified' }
GdsExampleMemory >> nextInstraction [
	| v |
	pc > maxLoc ifTrue: [^nil].
	v := memory at: pc.
	pc := pc + 1.
	^v.
	
	
]

{ #category : #'as yet unclassified' }
GdsExampleMemory >> octalLocation: anInteger [
	^anInteger  printStringBase: 8 length: 6 padded: true.
]

{ #category : #utility }
GdsExampleMemory >> openInstractionSpecText [
	(StringHolder new contents: self  instractionSpecText )
		openLabel: 'G op code specification'.
]

{ #category : #'as yet unclassified' }
GdsExampleMemory >> reset [
	pc := minLoc.
	
	
]

{ #category : #'as yet unclassified' }
GdsExampleMemory >> runLoopInstractions: anInstArrayArgBlock [
	| inst type nextInst instArray|
	self reset.
	[inst := self nextInstraction.
	inst notNil]
		whileTrue: [
			instArray := OrderedCollection new.
			instArray add: inst.
			type := self instractionType: inst.
			type numArgs timesRepeat:[
				nextInst := self nextInstraction.
				instArray add: nextInst.].
			anInstArrayArgBlock value: instArray asArray]
	
]
