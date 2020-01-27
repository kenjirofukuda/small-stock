Class {
	#name : #TwkAngle3,
	#superclass : #Object,
	#instVars : [
		'degress1',
		'degress2',
		'degress3'
	],
	#category : #'TowerKit-Magritte'
}

{ #category : #'as yet unclassified' }
TwkAngle3 >> degress1 [
	^ degress1
]

{ #category : #'as yet unclassified' }
TwkAngle3 >> degress1: aValue [
	degress1 := aValue
]

{ #category : #'as yet unclassified' }
TwkAngle3 >> degress2 [
	^ degress2
]

{ #category : #'as yet unclassified' }
TwkAngle3 >> degress2: aValue [
	degress2 := aValue
]

{ #category : #'as yet unclassified' }
TwkAngle3 >> degress3 [
	^ degress3
]

{ #category : #'as yet unclassified' }
TwkAngle3 >> degress3: aValue [
	degress3 := aValue
]

{ #category : #'as yet unclassified' }
TwkAngle3 >> descriptionAngle [
	<magritteDescription>
	^ MANumberDescription new
		min: 0;
		max: 359;
		priority: 30;
		label: '度';
		accessor: #degress1;
		comment: '電線の取付角度';
		yourself	
]

{ #category : #'as yet unclassified' }
TwkAngle3 >> descriptionAngle2 [
	<magritteDescription>
	^ MANumberDescription new
		min: 0;
		max: 59;
		priority: 31;
		label: '分';
		accessor: #degress2;
		comment: '電線の取付角度';
		yourself	
]

{ #category : #'as yet unclassified' }
TwkAngle3 >> descriptionAngle3 [
	<magritteDescription>
	^ MANumberDescription new
		min: 0;
		max: 59;
		priority: 32;
		label: '秒';
		accessor: #degress3;
		comment: '電線の取付角度';
		yourself	
]

{ #category : #initialization }
TwkAngle3 >> initialize [
	super initialize.
	degress1 := 0.
	degress2 := 0.
	degress3 := 0.
]
