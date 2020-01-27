"
タブ: '断面性能'
部材制限

"
Class {
	#name : #TwkRegionRestrictionRec,
	#superclass : #TwkExternalRec,
	#instVars : [
		'label',
		'minimumMaterialNumber',
		'countMin16',
		'countMin20',
		'countMin24',
		'countMax16',
		'countMax20',
		'countMax24',
		'saftyRatio',
		'lengthPerRadius',
		'bendForce',
		'deflection'
	],
	#category : #'TowerKit-SandBox'
}

{ #category : #'instance creation' }
TwkRegionRestrictionRec class >> fromArray: array [
	| inst |
	inst := self new.
	inst label: (array at: 1).
	inst minimumMaterialNumber: (array at: 2).
	inst countMin16: (array at: 3).
	inst countMin20: (array at: 4).
	inst countMin24: (array at: 5).
	inst countMax16: (array at: 6).
	inst countMax20: (array at: 7).
	inst countMax24: (array at: 8).
	inst saftyRatio: (array at: 9).
	inst lengthPerRadius: (array at: 10).
	inst bendForce: (array at: 11).
	inst deflection: (array at: 12).
	^ inst
]

{ #category : #constants }
TwkRegionRestrictionRec class >> make [
	<script>
	(((NeoCSVReader on: self tabSeparatedData readStream)
		separator: Character tab;
		upToEnd) collect: [ :array | TwkRegionRestrictionRec fromArray: array ])
		explore
]

{ #category : #constants }
TwkRegionRestrictionRec class >> tabSeparatedData [
^ '地主	5	4	4	4	7	7	99	1.1	200	1000	
電主	5	4	4	4	7	7	99	1.1	200	1000	
支	2	2	2	2	3	4	100	1.1	220	1000	
吊	2	2	2	2	3	4	100	1.1	220		
正面	2	2	2	2	3	4	100	1.1	220		
平面	2	2	2	2	3	4	100	1.1	220	1000	
内主	5	4	4	4	7	7	99	1.1	200	1000	
腕側	3	3	3	3	8	12	100	1.1	220	1000	
吊間	2	2	2	2	3	4	100	1.1	220	1000	
対	2	2	2	2	3	4	100	1.1	220	1000	
補１	2	2	2	2	3	4	100	1.1	220		
補２	2	1	1	1	3	4	100	1.1	250		
補３	2	1	1	1	3	4	100	1.1	250	1000	
'

]

{ #category : #accessing }
TwkRegionRestrictionRec >> bendForce [
	^ bendForce
]

{ #category : #accessing }
TwkRegionRestrictionRec >> bendForce: aString [ 
	bendForce := aString
]

{ #category : #accessing }
TwkRegionRestrictionRec >> countMax16 [
	^ countMax16
]

{ #category : #accessing }
TwkRegionRestrictionRec >> countMax16: aString [ 
	countMax16 := aString
]

{ #category : #accessing }
TwkRegionRestrictionRec >> countMax20 [
	^ countMax20
]

{ #category : #accessing }
TwkRegionRestrictionRec >> countMax20: aString [ 
	countMax20 := aString
]

{ #category : #accessing }
TwkRegionRestrictionRec >> countMax24 [
	^ countMax24
]

{ #category : #accessing }
TwkRegionRestrictionRec >> countMax24: aString [ 
	countMax24 := aString
]

{ #category : #accessing }
TwkRegionRestrictionRec >> countMin16 [
	^ countMin16
]

{ #category : #accessing }
TwkRegionRestrictionRec >> countMin16: aString [ 
	countMin16 := aString
]

{ #category : #accessing }
TwkRegionRestrictionRec >> countMin20 [
	^ countMin20
]

{ #category : #accessing }
TwkRegionRestrictionRec >> countMin20: aString [ 
	countMin20 := aString
]

{ #category : #accessing }
TwkRegionRestrictionRec >> countMin24 [
	^ countMin24
]

{ #category : #accessing }
TwkRegionRestrictionRec >> countMin24: aString [ 
	countMin24 := aString
]

{ #category : #accessing }
TwkRegionRestrictionRec >> deflection [
	^ deflection
]

{ #category : #accessing }
TwkRegionRestrictionRec >> deflection: anUndefinedObject [ 
	deflection := anUndefinedObject
]

{ #category : #accessing }
TwkRegionRestrictionRec >> label [
	^ label
]

{ #category : #accessing }
TwkRegionRestrictionRec >> label: aString [ 
	label := aString
]

{ #category : #accessing }
TwkRegionRestrictionRec >> lengthPerRadius [
	^ lengthPerRadius
]

{ #category : #accessing }
TwkRegionRestrictionRec >> lengthPerRadius: aString [ 
	lengthPerRadius := aString
]

{ #category : #accessing }
TwkRegionRestrictionRec >> minimumMaterialNumber [
	^ minimumMaterialNumber
]

{ #category : #accessing }
TwkRegionRestrictionRec >> minimumMaterialNumber: aString [ 
	minimumMaterialNumber := aString
]

{ #category : #accessing }
TwkRegionRestrictionRec >> saftyRatio [
	^ saftyRatio
]

{ #category : #accessing }
TwkRegionRestrictionRec >> saftyRatio: aString [ 
	saftyRatio := aString
]
