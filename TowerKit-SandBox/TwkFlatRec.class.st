Class {
	#name : #TwkFlatRec,
	#superclass : #TwkExternalRec,
	#instVars : [
		'part',
		'armLabel',
		'h',
		'v',
		'hvCode',
		'part2',
		'ahpv',
		'forceKind',
		'dir',
		'val',
		'sign',
		'val2',
		'ct',
		'col',
		'effect1',
		'ct11',
		'ct12',
		'effect2',
		'ct21',
		'ct22'
	],
	#category : #'TowerKit-SandBox'
}

{ #category : #'as yet unclassified' }
TwkFlatRec class >> sampleData1 [
	^ '部	腕	H	V				応	方	値	符	被	圧	識	影					
内主	L	0	2	D02	直	AH	HG	Y	0.3	0	0.3	CT	支	上	C	T			
内主	U	0	2	D02		AP	PN	X	10.1	1	10.1	CT	若2	上	C	T			
内主	U	0	2	D02	斜	AV	VA	Z	30.6	1	30.6		若2	上		T			
内主	U	0	2	D02	斜	AV	WC	Z	2.5	1	2.5		若2	上		T			
内主	L	0	1	D01	斜	AH	HC	X	3.1	0	3.1	CT	老2	下	C	T			
内主	L	0	1	D01	斜	AH	HG	X	0.2	0	0.2	CT	老2	下	C	T			
内主	L	0	1	D01	斜	AH	HG	X	0.2	0	0.2	CT	支	下	C	T			
内主	D	2	0	D20		AP	PN	X	3.4	-1	-3.4	CT	老2	下	C	T			
内主	D	2	0	D20		AP	PN	X	10.1	1	10.1	CT	若2	下	C	T			
内主	L	0	1	D01		AP	PN	Y	14.1	-1	-14.1	CT	老2	下	C	T	上	T	C
内主	L	0	1	D01	斜	AV	VA	Z	7.8	1	7.8		老2	下	C				
内主	L	0	1	D01	斜	AV	WC	Z	3.5	1	3.5		老2	下	C				
内主	L	0	1	D01	斜	AV	WC	Z	1	1	1		支	下	C				
内主	L	0	1	D01	斜	AH	PN	X	6.8	-1	-6.8	T	老2	下		T			
内主	L	0	1	D01	斜	AV	VA	Z	12.2	1	12.2		老2	下		T			
内主	D	2	0	D20	斜	AV	VA	Z	30.6	1	30.6		若2	下		T			
内主	D	1	0	D10	斜	AV	WC	Z	1.1	1	1.1		支	下		T			
内主	D	1	0	D10	斜	AV	WC	Z	2.5	1	2.5		若2	下		T			
内主	D	1	0	D10	斜	AV	WC	Z	5.4	1	5.4		若2	下		T			
内主	D	1	0	D10		AP	PA	X	11.5		11.5		若2						
内主	D	1	0	D10		AP	PA	Y	11.5		11.5		老2						
'
]

{ #category : #'as yet unclassified' }
TwkFlatRec class >> sampleObjects1 [
	| recs |
	recs := self sampleRecords1
		collect: [ :arr | 
			| obj |
			obj := self new.
			self instVarNames
				doWithIndex: [ :each :index | obj perform: (each , #':') asSymbol with: (arr at: index) ].
			obj ].
	^ recs sort: [ :a :b | a compare: a and: b ]
]

{ #category : #'as yet unclassified' }
TwkFlatRec class >> sampleRecords1 [
	| recs |
	recs := ((NeoCSVReader on: self sampleData1 readStream)
		separator: Character tab;
		skipHeader;
		emptyFieldValue: '';
		upToEnd) reject: [ :each | each isEmpty ].
	^ recs 
]

{ #category : #'as yet unclassified' }
TwkFlatRec class >> split: aCollection [
	^ #('HCX' 'HCY' 'HGX' 'HGY' 'PNX' 'PNY' 'PAX' 'PAY' 'WCZ' 'VAZ')
		collect: [ :kind |
			aCollection select: [ :each | each forceKind2 = kind ]  ] 
	
]

{ #category : #'as yet unclassified' }
TwkFlatRec class >> summary: aCollection effect: aEffect ct: aCtCode [
	| code |
	code := aCtCode = 'C'
		ifTrue: [ #ct11 ]
		ifFalse: [ #ct12 ].
	^ aCollection
		select: [ :flat | flat effect1 = aEffect and: [ (flat perform: code) = aCtCode ] ]
]

{ #category : #'as yet unclassified' }
TwkFlatRec class >> workSheet1 [
	<script>
	self sampleObjects1 explore.
]

{ #category : #'as yet unclassified' }
TwkFlatRec class >> workSheet2 [
	"self workSheet2"
	<script>
	| objs |
	objs := self sampleObjects1.
	(self split: (self summary: objs effect: '下' ct: 'C')) explore.
]

{ #category : #'accessing - fields' }
TwkFlatRec >> ahpv [
	^ ahpv
]

{ #category : #'accessing - fields' }
TwkFlatRec >> ahpv: anObject [
	ahpv := anObject
]

{ #category : #'accessing - fields' }
TwkFlatRec >> armLabel [
	^ armLabel
]

{ #category : #'accessing - fields' }
TwkFlatRec >> armLabel: anObject [
	armLabel := anObject
]

{ #category : #'accessing - fields' }
TwkFlatRec >> col [
	^ col
]

{ #category : #'accessing - fields' }
TwkFlatRec >> col: anObject [
	col := anObject
]

{ #category : #'as yet unclassified' }
TwkFlatRec >> compare: a and: b [
	^ (a label) < (b label)
]

{ #category : #'accessing - fields' }
TwkFlatRec >> ct [
	^ ct
]

{ #category : #'accessing - fields' }
TwkFlatRec >> ct11 [
	^ ct11
]

{ #category : #'accessing - fields' }
TwkFlatRec >> ct11: anObject [
	ct11 := anObject
]

{ #category : #'accessing - fields' }
TwkFlatRec >> ct12 [
	^ ct12
]

{ #category : #'accessing - fields' }
TwkFlatRec >> ct12: anObject [
	ct12 := anObject
]

{ #category : #'accessing - fields' }
TwkFlatRec >> ct21 [
	^ ct21
]

{ #category : #'accessing - fields' }
TwkFlatRec >> ct21: anObject [
	ct21 := anObject
]

{ #category : #'accessing - fields' }
TwkFlatRec >> ct22 [
	^ ct22
]

{ #category : #'accessing - fields' }
TwkFlatRec >> ct22: anObject [
	ct22 := anObject
]

{ #category : #'accessing - fields' }
TwkFlatRec >> ct: anObject [
	ct := anObject
]

{ #category : #'accessing - fields' }
TwkFlatRec >> dir [
	^ dir
]

{ #category : #'accessing - fields' }
TwkFlatRec >> dir: anObject [
	dir := anObject
]

{ #category : #'accessing - fields' }
TwkFlatRec >> effect1 [
	^ effect1
]

{ #category : #'accessing - fields' }
TwkFlatRec >> effect1: anObject [
	effect1 := anObject
]

{ #category : #'accessing - fields' }
TwkFlatRec >> effect2 [
	^ effect2
]

{ #category : #'accessing - fields' }
TwkFlatRec >> effect2: anObject [
	effect2 := anObject
]

{ #category : #'accessing - fields' }
TwkFlatRec >> forceKind [
	^ forceKind
]

{ #category : #accessing }
TwkFlatRec >> forceKind2 [
	^ self forceKind, self dir
]

{ #category : #'accessing - fields' }
TwkFlatRec >> forceKind: anObject [
	forceKind := anObject
]

{ #category : #'accessing - fields' }
TwkFlatRec >> h [
	^ h
]

{ #category : #'accessing - fields' }
TwkFlatRec >> h: anObject [
	h := anObject
]

{ #category : #'accessing - fields' }
TwkFlatRec >> hvCode [
	^ hvCode
]

{ #category : #'accessing - fields' }
TwkFlatRec >> hvCode: anObject [
	hvCode := anObject
]

{ #category : #accessing }
TwkFlatRec >> label [
	^ ' ' join: {self col asString . self forceKind asString . self val asString}
]

{ #category : #'accessing - fields' }
TwkFlatRec >> part [
	^ part
]

{ #category : #'accessing - fields' }
TwkFlatRec >> part2 [
	^ part2
]

{ #category : #'accessing - fields' }
TwkFlatRec >> part2: anObject [
	part2 := anObject
]

{ #category : #'accessing - fields' }
TwkFlatRec >> part: anObject [
	part := anObject
]

{ #category : #'accessing - fields' }
TwkFlatRec >> sign [
	^ sign
]

{ #category : #'accessing - fields' }
TwkFlatRec >> sign: anObject [
	sign := anObject
]

{ #category : #'accessing - fields' }
TwkFlatRec >> v [
	^ v
]

{ #category : #'accessing - fields' }
TwkFlatRec >> v: anObject [
	v := anObject
]

{ #category : #'accessing - fields' }
TwkFlatRec >> val [
	^ val
]

{ #category : #'accessing - fields' }
TwkFlatRec >> val2 [
	^ val2
]

{ #category : #'accessing - fields' }
TwkFlatRec >> val2: anObject [
	val2 := anObject
]

{ #category : #'accessing - fields' }
TwkFlatRec >> val: anObject [
	val := anObject
]
