"
WC	架渉線重量
VA	垂直角度荷重
HC	架渉線風圧
HG	碍子風圧
HA	水平角度荷重
PN	常時不平均張力
PA	異常時不平均張力
P1	全相不平均張力
QN	常時ねじり力
QA	異常時ねじり力
Q1	全相ねじり力

"
Class {
	#name : #TwkCalcGroup,
	#superclass : #TwkNode,
	#instVars : [
		'shortName',
		'longName'
	],
	#category : #'TowerKit-SandBox'
}

{ #category : #'as yet unclassified' }
TwkCalcGroup class >> instances [
	"self instances explore."
	^ Array streamContents: [ :s |
	(NeoJSONReader fromString: self specJson)
			keysAndValuesDo: [ :key :value |
				s nextPut: (TwkCalcGroup new 
					name: key;
					shortName: key;
					longName: value;
					yourself)
				 ]  ]
]

{ #category : #'as yet unclassified' }
TwkCalcGroup class >> specJson [
	"(NeoJSONReader fromString: self specJson) explore"
^
'{
"WC":	"架渉線重量",
"VA":	"垂直角度荷重",
"HC":	"架渉線風圧",
"HG":	"碍子風圧",
"HA":	"水平角度荷重",
"PN":	"常時不平均張力",
"PA":	"異常時不平均張力",
"P1":	"全相不平均張力",
"QN":	"常時ねじり力",
"QA":	"異常時ねじり力",
"Q1":	"全相ねじり力"
}'
]

{ #category : #'as yet unclassified' }
TwkCalcGroup >> foo [
]

{ #category : #'as yet unclassified' }
TwkCalcGroup >> longName: aString [ 
	longName := aString.
]

{ #category : #'as yet unclassified' }
TwkCalcGroup >> shortName: aString [ 
	shortName := aString.
]
