Class {
	#name : #TwkArm,
	#superclass : #TwkNode,
	#instVars : [
		'length',
		'masterWidth',
		'slaveWidth',
		'height',
		'phase',
		'leftCableMounts',
		'rightCableMounts',
		'nodeCenter',
		'endWidth'
	],
	#category : #'TowerKit-SandBox'
}

{ #category : #example }
TwkArm class >> example [
	<example>
	(TwkArm new
		phase: 1;
		name: 'C1L';
		length: 4400 mm / 2;
		height: 800 mm;
		masterWidth: 921 mm;
		slaveWidth: 878 mm;	
		fillNormalCableMounts;	
		yourself)  explore.
		
]

{ #category : #example }
TwkArm class >> example2 [
	<example>
	(TwkArm new
		phase: 1;
		name: 'C1L';
		length: 4400 mm / 2;
		height: 800 mm;
		masterWidth: 921 mm;
		slaveWidth: 915 mm;	
		fillNormalCableMounts;	
		yourself)  explore.
		
]

{ #category : #'instance creation' }
TwkArm class >> newSimplePhase: aNumber totalLength: aUnitValue [
	^ #('L'  'R')
		collect: [ :label |
			TwkArm new 
				phase: aNumber;
				name: ('C', aNumber asString, label);
				length: aUnitValue / 2;
				yourself.
			 ]
]

{ #category : #private }
TwkArm >> clearNodeCenter [
	nodeCenter := nil.
	 
]

{ #category : #private }
TwkArm >> createPanelFaceXZ [
	| face |
	face := TwkFace  new.
	face direction: #front.
	face spanValues: (Array with: self height value).
	face crossValues: #(#cross).
	face addWidth: self masterWidth value.
	face skipSpans: 1.
	face addWidth: self slaveWidth value .
	face fillActivePlane.
	face brickStack planeSpans do: [ :span | span realMaterial: true]. 
	^ face
]

{ #category : #accessing }
TwkArm >> endWidth [
	^ endWidth value
]

{ #category : #accessing }
TwkArm >> endWidth: aUnitValue [
	self onlyUnitValue: aUnitValue.
	endWidth value: aUnitValue.
]

{ #category : #private }
TwkArm >> fillNormalCableMounts [
	leftCableMounts
		add:
			(TwkCableMount new
				parent: self;
				offset: self length;
				yourself).
				
	rightCableMounts
		add:
			(TwkCableMount new
				parent: self;
				offset: self length;
				yourself).
							
]

{ #category : #accessing }
TwkArm >> height [
	^ height value
]

{ #category : #accessing }
TwkArm >> height: aUnitValue [
	self onlyUnitValue: aUnitValue.
	height value: aUnitValue
]

{ #category : #accessing }
TwkArm >> heightMM [
	^ (self height as: #mm) value 
]

{ #category : #initialization }
TwkArm >> initialize [
	length := TwkLengthItem new.
	masterWidth := TwkLengthItem new.
	slaveWidth := TwkLengthItem new.
	height := TwkLengthItem new.
	leftCableMounts := OrderedCollection new.
	rightCableMounts := OrderedCollection new.
	endWidth := TwkLengthItem new value: 0 mm.


]

{ #category : #accessing }
TwkArm >> length [
	^ length value
]

{ #category : #accessing }
TwkArm >> length: aUnitValue [
	self onlyUnitValue: aUnitValue.
	length value: aUnitValue
]

{ #category : #accessing }
TwkArm >> lengthMM [
	^ (self length as: #mm) value
]

{ #category : #accessing }
TwkArm >> masterPlanePoints [
	^ self squarePointsOfWidth: (self masterWidth convertTo: #mm) value .
]

{ #category : #accessing }
TwkArm >> masterWidth [
	^ masterWidth value
]

{ #category : #accessing }
TwkArm >> masterWidth: aUnitValue [
	self onlyUnitValue: aUnitValue.
	masterWidth value: aUnitValue
]

{ #category : #accessing }
TwkArm >> masterWidthMM [
	^ (self masterWidth as: #mm) value
]

{ #category : #accessing }
TwkArm >> nodeCenter [
	^ nodeCenter ifNil: [ nodeCenter := TwkStanNodeCenter new. ]
]

{ #category : #accessing }
TwkArm >> onlyUnitValue: aUnitValue [
	self assert: (aUnitValue isKindOf: UnitValue).
]

{ #category : #accessing }
TwkArm >> phase [
	^ phase
	
]

{ #category : #accessing }
TwkArm >> phase: aNumber [
	self assert: ((0 to: 6)includes: aNumber).
	phase := aNumber.
	
]

{ #category : #private }
TwkArm >> registerPoints [
	self masterPlanePoints do: [ :each |
		self nodeCenter forPoint3d:  { each x . each y . 0 }.		
		 ].
	self slavePlanePoints do: [ :each |
		self nodeCenter forPoint3d:  { each x . each y . (self height as: #mm) value }.		
		 ].
	 
]

{ #category : #accessing }
TwkArm >> slavePlanePoints [
	^ self squarePointsOfWidth: (self slaveWidth as: #mm) value .
]

{ #category : #accessing }
TwkArm >> slaveWidth [
	^ slaveWidth value
]

{ #category : #accessing }
TwkArm >> slaveWidth: aUnitValue [
	self onlyUnitValue: aUnitValue.
	slaveWidth value: aUnitValue
]

{ #category : #accessing }
TwkArm >> slaveWidthMM [
	^ (self slaveWidth as: #mm) value
]

{ #category : #utility }
TwkArm >> squarePointsOfWidth: aNumber [
	| rationalPoints |
	rationalPoints := { (0.5 @ -0.5) . (-0.5 @ -0.5) . ( -0.5 @ 0.5 ) . (0.5 @ 0.5)  }.
	^ rationalPoints * aNumber
]

{ #category : #testing }
TwkArm >> steeply [
	^ (self endWidth as: #mm) value closeTo: 0.0.
	
]
