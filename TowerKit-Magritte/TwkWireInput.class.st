Class {
	#name : #TwkWireInput,
	#superclass : #Object,
	#instVars : [
		'dateCreated',
		'distance',
		'degress1',
		'degress2',
		'degress3',
		'down',
		'up',
		'wireKind',
		'countWire',
		'tension',
		'gaishiWeight',
		'wireWind',
		'gaishiWind',
		'snowDepth',
		'snowDensity',
		'wireParam',
		'horizontalAngleParam',
		'gaishiWeightParam',
		'gaishiWindParam'
	],
	#category : #'TowerKit-Magritte'
}

{ #category : #accessing }
TwkWireInput >> countWire [
	^ countWire
]

{ #category : #accessing }
TwkWireInput >> countWire: aNumber [
	countWire := aNumber asNumber.
]

{ #category : #accessing }
TwkWireInput >> dateCreated [
	^ dateCreated
]

{ #category : #accessing }
TwkWireInput >> dateCreated: aDateAndTime [
	dateCreated := aDateAndTime asDate.
]

{ #category : #accessing }
TwkWireInput >> degress1 [
	^ degress1
]

{ #category : #accessing }
TwkWireInput >> degress1: aValue [
	degress1 := aValue
]

{ #category : #accessing }
TwkWireInput >> degress2 [
	^ degress2
]

{ #category : #accessing }
TwkWireInput >> degress2: aValue [
	degress2 := aValue
]

{ #category : #accessing }
TwkWireInput >> degress3 [
	^ degress3
]

{ #category : #accessing }
TwkWireInput >> degress3: aValue [
	degress3 := aValue
]

{ #category : #'as yet unclassified' }
TwkWireInput >> descriptionAngle [
	<magritteDescription>
	^ MANumberDescription new
		min: 0;
		max: 359;
		priority: 20;
		label: '度';
		accessor: #degress1;
		comment: '電線の取付角度';
		yourself	
]

{ #category : #'as yet unclassified' }
TwkWireInput >> descriptionAngle2 [
	<magritteDescription>
	^ MANumberDescription new
		min: 0;
		max: 59;
		priority: 21;
		label: '分';
		accessor: #degress2;
		comment: '電線の取付角度';
		yourself	
]

{ #category : #'as yet unclassified' }
TwkWireInput >> descriptionAngle3 [
	<magritteDescription>
	^ MANumberDescription new
		min: 0;
		max: 59;
		priority: 22;
		label: '秒';
		accessor: #degress3;
		comment: '電線の取付角度';
		yourself	
]

{ #category : #'as yet unclassified' }
TwkWireInput >> descriptionCountWire [
	<magritteDescription>
	^ MANumberDescription new
		priority: 50;
		label: '条数/導体数';
		accessor: #countWire;
		comment: '条数/導体数';
		yourself	
]

{ #category : #'as yet unclassified' }
TwkWireInput >> descriptionDateCreated [
	<magritteDescription>
	^ MADateDescription new
		priority: 10;
		label: '生成日付';
		accessor: #dateCreated;
		comment: '生成日付';
		yourself	
]

{ #category : #'as yet unclassified' }
TwkWireInput >> descriptionDistance [
	<magritteDescription>
	^ MANumberDescription new
		min: 0;
		max: 359;
		priority: 10;
		label: '荷重径間';
		accessor: #distance;
		comment: 'Sm: 塔体間距離の半分 メートル';
		yourself	
]

{ #category : #'as yet unclassified' }
TwkWireInput >> descriptionDown [
	<magritteDescription>
	^ MANumberDescription new
		priority: 30;
		label: '引下げ';
		accessor: #down;
		comment: '電線の引下げ (VA)';
		yourself	
]

{ #category : #'as yet unclassified' }
TwkWireInput >> descriptionGaishiWeight [
	<magritteDescription>
	^ MANumberDescription new
		priority: 70;
		label: '碍子重量';
		accessor: #gaishiWeight;
		comment: '碍子重量 Kg';
		yourself	
]

{ #category : #'as yet unclassified' }
TwkWireInput >> descriptionTension [
	<magritteDescription>
	^ MANumberDescription new
		priority: 60;
		label: '想定張力';
		accessor: #tension;
		comment: '想定張力 N';
		yourself	
]

{ #category : #'as yet unclassified' }
TwkWireInput >> descriptionUp [
	<magritteDescription>
	^ MANumberDescription new
		priority: 30;
		label: '引揚げ';
		accessor: #up;
		comment: '電線の引揚げ (-VA)';
		yourself	
]

{ #category : #accessing }
TwkWireInput >> distance [
	^ distance
]

{ #category : #accessing }
TwkWireInput >> distance: aNumber [
	distance := aNumber
]

{ #category : #accessing }
TwkWireInput >> down [
	^ down
]

{ #category : #accessing }
TwkWireInput >> down: aNumber [
	down := aNumber asFloat.
]

{ #category : #accessing }
TwkWireInput >> gaishiWeight [
	^ gaishiWeight
]

{ #category : #accessing }
TwkWireInput >> gaishiWeight: aNumber [
	gaishiWeight := aNumber
]

{ #category : #initialization }
TwkWireInput >> initialize [
	super initialize.
	dateCreated := Date today.
	degress1 := 0.
	degress2 := 0.
	degress3 := 0.
	distance := 0.
	wireKind := nil.
	down := 0.
	up := 0.
	countWire := 1.
	gaishiWeight := 0.
	gaishiWeightParam := 2.
	gaishiWind := 0.
	gaishiWindParam := 1.
	horizontalAngleParam := 2.
	snowDensity := 0.
	snowDepth := 0.
	tension := 0.
	wireParam := 2.
	wireWind := 0.
	
"
線種番号	
荷重径間
度	分	秒	
引下げ
引揚げ
線種
外径
単位重量
条数
想定張力
碍子重量
架渉線風圧
碍子風圧
着雪厚み
着雪密度
架線両片
水平角度両片
碍子重量連支
碍子風圧連支
"

]

{ #category : #accessing }
TwkWireInput >> tension [
	^ tension
]

{ #category : #accessing }
TwkWireInput >> tension: aNumber [
	tension := aNumber
]

{ #category : #accessing }
TwkWireInput >> up [
	^ up
]

{ #category : #accessing }
TwkWireInput >> up: aNumber [
	up := aNumber asFloat.
]
