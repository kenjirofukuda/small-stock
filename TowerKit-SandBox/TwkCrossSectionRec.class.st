"
タブ: '断面性能'

"
Class {
	#name : #TwkCrossSectionRec,
	#superclass : #TwkExternalRec,
	#instVars : [
		'id',
		'label',
		'material',
		'area',
		'weight',
		'interiaMoment',
		'rv',
		'rx',
		'z',
		'tickness',
		'rejectCountB',
		'rejectCountC'
	],
	#category : #'TowerKit-SandBox'
}

{ #category : #examples }
TwkCrossSectionRec class >> exampleRecords [
	self recordsFromTabSeparatedData explore
]

{ #category : #'instance creation' }
TwkCrossSectionRec class >> recordsFromTabSeparatedData [
	^ ((NeoCSVReader on: self tabSeparatedData readStream)
		separator: Character tab;
		skipHeader;
		skipHeader;
		recordClass: self;
		emptyFieldValue: 0;
		addIntegerField: #id:;
		addField: #label:;
		addField: #material:;
		addFloatField: #area:;
		addFloatField: #weight:;
		addFloatField: #interiaMoment:;
		addFloatField: #rv:;
		addFloatField: #rx:;
		addFloatField: #z:;
		addFloatField: #tickness:;
		addIntegerField: #rejectCountB:;
		addIntegerField: #rejectCountC:;
		upToEnd) reject: [ :each | each isEmpty ]
]

{ #category : #'as yet unclassified' }
TwkCrossSectionRec class >> sampleCreateTableSql [
	^ 'CREATE TABLE `cross_sections` (
	`id`	INTEGER NOT NULL UNIQUE,
	`label`	TEXT,
	`material`	TEXT,
	`area`	REAL,
	`weight`	REAL,
	`interiaMoment`	REAL,
	`rv`	REAL,
	`rx`	REAL,
	`z`	REAL,
	`tickness`	REAL,
	`reject_count_b`	INTEGER,
	`reject_count_c`	INTEGER,
	PRIMARY KEY(`id`)
);'
]

{ #category : #constants }
TwkCrossSectionRec class >> tabSeparatedData [
^ '番号	部材サイズ	材質	断面積	質量	二次ﾓｰﾒﾝﾄ	　 　回転半径		断面係数	厚み	控除本数	
	(mm)		A(cm2)	W(kg/m)	I(cm4)	Rv(cm)	Rx(cm)	Z(cm3)	t(cm)	B	C
1	L 45 x 4	SS400	3.492	2.74	6.5	0.88	1.36	2	0.4	2	1
2	L 50 x 4	SS400	3.892	3.06	9.06	0.983	1.53	2.49	0.4	2	1
3	L 60 x 4	SS400	4.692	3.68	16	1.19	1.85	3.66	0.4	2	1
4	L 60 x 5	SS400	5.802	4.55	19.6	1.18	1.84	4.52	0.5	2	1
5	L 65 x 6	SS400	7.527	5.91	29.4	1.27	1.98	6.26	0.6	2	1
6	L 70 x 6	SS400	8.127	6.38	37.1	1.37	2.14	7.33	0.6	2	1
7	L 75 x 6	SS400	8.727	6.85	46.1	1.48	2.3	8.47	0.6	2	1
8	L 80 x 6	SS400	9.327	7.32	56.4	1.58	2.46	9.7	0.6	2	1
9	L 90 x 6	SS400	10.55	8.28	80.7	1.78	2.77	12.3	0.6	2	1
10	L 90 x 7	SS400	12.22	9.59	93	1.77	2.76	14.2	0.7	2	1
11	L 100 x 7	SS400	13.62	10.7	129	1.98	3.08	17.7	0.7	2	1
12	L 100 x 10	SS400	19	14.9	175	1.95	3.04	24.4	1	2	1
13	L 120 x 8	SS540	18.76	14.7	258	2.38	3.71	29.5	0.8	3	2
14	L 130 x 9	SS540	22.74	17.9	366	2.57	4.01	38.7	0.9	3	2
15	L 150 x 10	SS540	29.21	22.9	627	2.97	4.63	57.3	1	3	2
16	L 150 x 12	SS540	34.77	27.3	740	2.96	4.61	68.1	1.2	3	2
17	L 175 x 12	SS540	40.52	31.8	1170	3.44	5.38	91.8	1.2	3	2
18	L 175 x 15	SS540	50.21	39.4	1440	3.42	5.35	114	1.5	3	2
19	L 200 x 15	SS540	57.75	45.3	2180	3.93	6.14	150	1.5	3	2
20	L 200 x 20	SS540A	76	59.7	2820	3.9	6.09	197	2	3	2
21	L 200 x 25	SS540A	93.75	73.6	3420	3.88	6.04	242	2.5	3	2
22	L 250 x 25	SS540A	119.4	93.7	6950	4.9	7.63	388	2.5	4	2
23	L 250 x 35	SS540A	162.6	128	9110	4.83	7.49	519	3.5	4	2
24	L 130 x 9	SS400	22.74	17.9	366	2.57	4.01	38.7	0.9	3	2
25
26
27
28
29
30
31	TL 65 x 6 	SS400	15.05	11.82	58.8	2.68	1.98	12.5	1.2	2	1
32	2L 60 x 4 	SS400	4.692	3.68	16	1.19	1.85	3.66	0.4	2	1
33
34
35
36
37
38
39
40
41
42
43
44
45
46
47
48
49
50
51
52
53
54
55
56
57
58
59
60
61
62
63
64
65
66
67
68
69
70
71
72
73
74	φ60.5X2.3	STK400	4.205	3.3	17.8	2.06	2.06	5.9	0.9
75	φ76.3X2.8	STK400	6.465	5.08	43.7	2.6	2.6	11.5	0.9
76
77
78
79
80
81
82
83
84
85
86
87
88
89
90
91
92
93
94
95
96
97
98
99
100
'

]

{ #category : #accessing }
TwkCrossSectionRec >> area [
	^ area
]

{ #category : #accessing }
TwkCrossSectionRec >> area: anObject [
	area := anObject
]

{ #category : #'magritte descriptions' }
TwkCrossSectionRec >> descriptionArea [
	<magritteDescription>
	^ MANumberDescription new
		priority: 4;
		readonly: area notNil;		
		label: '断面積';
		accessor: #area;
		comment: 'A(cm2)';
		yourself		
	
]

{ #category : #'magritte descriptions' }
TwkCrossSectionRec >> descriptionId [
	<magritteDescription>
	^ MANumberDescription new
		priority: 1;
		readonly: id notNil;		
		label: '番号';
		accessor: #id;
		comment: 'Excel互換部材番号';
		yourself		
	
]

{ #category : #'magritte descriptions' }
TwkCrossSectionRec >> descriptionInteriaMoment [
	<magritteDescription>
	^ MANumberDescription new
		priority: 6;
		readonly: interiaMoment notNil;		
		label: '二次モーメント';
		accessor: #interiaMoment;
		comment: 'I(cm4)';
		yourself		
	
]

{ #category : #'magritte descriptions' }
TwkCrossSectionRec >> descriptionLabel [
	<magritteDescription>
	^ MAStringDescription new
		priority: 2;
		readonly: label notNil;		
		label: '部材サイズ';
		accessor: #label;
		comment: '山形鋼,または鋼管の部材サイズ名称';
		yourself		
	
]

{ #category : #'magritte descriptions' }
TwkCrossSectionRec >> descriptionMaterial [
	<magritteDescription>
	^ MANumberDescription new
		priority: 3;
		readonly: material notNil;		
		label: '部材';
		accessor: #material;
		comment: '';
		yourself		
	
]

{ #category : #'magritte descriptions' }
TwkCrossSectionRec >> descriptionRejectCountB [
	<magritteDescription>
	^ MANumberDescription new
		priority: 11;
		readonly: rejectCountB  notNil;		
		label: '控除本数 B';
		accessor: #rejectCountB;
		comment: 'B 控除本数';
		yourself		
	
]

{ #category : #'magritte descriptions' }
TwkCrossSectionRec >> descriptionRejectCountC [
	<magritteDescription>
	^ MANumberDescription new
		priority: 12;
		readonly: rejectCountC  notNil;		
		label: '控除本数 C';
		accessor: #rejectCountC;
		comment: 'C 控除本数';
		yourself		
	
]

{ #category : #'magritte descriptions' }
TwkCrossSectionRec >> descriptionRv [
	<magritteDescription>
	^ MANumberDescription new
		priority: 7;
		readonly: rv notNil;		
		label: '回転半径 V';
		accessor: #rv;
		comment: 'Rv(cm)';
		yourself		
	
]

{ #category : #'magritte descriptions' }
TwkCrossSectionRec >> descriptionRx [
	<magritteDescription>
	^ MANumberDescription new
		priority: 8;
		readonly: rx notNil;		
		label: '回転半径 X';
		accessor: #rx;
		comment: 'Rx(cm)';
		yourself		
	
]

{ #category : #'magritte descriptions' }
TwkCrossSectionRec >> descriptionThickness [
	<magritteDescription>
	^ MANumberDescription new
		priority: 10;
		readonly: tickness  notNil;		
		label: '厚み';
		accessor: #z;
		comment: 't(cm)';
		yourself		
	
]

{ #category : #'magritte descriptions' }
TwkCrossSectionRec >> descriptionWeight [
	<magritteDescription>
	^ MANumberDescription new
		priority: 5;
		readonly: weight notNil;		
		label: '質量';
		accessor: #weight;
		comment: 'W(kg/m)';
		yourself		
	
]

{ #category : #'magritte descriptions' }
TwkCrossSectionRec >> descriptionZ [
	<magritteDescription>
	^ MANumberDescription new
		priority: 9;
		readonly: z notNil;		
		label: '断面係数';
		accessor: #z;
		comment: 'Z(cm3)';
		yourself		
	
]

{ #category : #accessing }
TwkCrossSectionRec >> id [
	^ id
]

{ #category : #accessing }
TwkCrossSectionRec >> id: anObject [
	id := anObject
]

{ #category : #accessing }
TwkCrossSectionRec >> interiaMoment [
	^ interiaMoment
]

{ #category : #accessing }
TwkCrossSectionRec >> interiaMoment: anObject [
	interiaMoment := anObject
]

{ #category : #testing }
TwkCrossSectionRec >> isEmpty [
	^ self label isNil
]

{ #category : #accessing }
TwkCrossSectionRec >> label [
	^ label
]

{ #category : #accessing }
TwkCrossSectionRec >> label: anObject [
	label := anObject
]

{ #category : #accessing }
TwkCrossSectionRec >> material [
	^ material
]

{ #category : #accessing }
TwkCrossSectionRec >> material: anObject [
	material := anObject
]

{ #category : #accessing }
TwkCrossSectionRec >> rejectCountB [
	^ rejectCountB
]

{ #category : #accessing }
TwkCrossSectionRec >> rejectCountB: anObject [
	rejectCountB := anObject
]

{ #category : #accessing }
TwkCrossSectionRec >> rejectCountC [
	^ rejectCountC
]

{ #category : #accessing }
TwkCrossSectionRec >> rejectCountC: anObject [
	rejectCountC := anObject
]

{ #category : #accessing }
TwkCrossSectionRec >> rv [
	^ rv
]

{ #category : #accessing }
TwkCrossSectionRec >> rv: anObject [
	rv := anObject
]

{ #category : #accessing }
TwkCrossSectionRec >> rx [
	^ rx
]

{ #category : #accessing }
TwkCrossSectionRec >> rx: anObject [
	rx := anObject
]

{ #category : #accessing }
TwkCrossSectionRec >> tickness [
	^ tickness
]

{ #category : #accessing }
TwkCrossSectionRec >> tickness: anObject [
	tickness := anObject
]

{ #category : #accessing }
TwkCrossSectionRec >> weight [
	^ weight
]

{ #category : #accessing }
TwkCrossSectionRec >> weight: anObject [
	weight := anObject
]

{ #category : #accessing }
TwkCrossSectionRec >> z [
	^ z
]

{ #category : #accessing }
TwkCrossSectionRec >> z: anObject [
	z := anObject
]
