Class {
	#name : #TwkSection,
	#superclass : #TwkNode,
	#instVars : [
		'crossDelegate',
		'crossValues',
		'depthSplit',
		'dummyCross',
		'insertSpecs'
	],
	#classVars : [
		'DepthDummySection',
		'PlaneDummySection'
	],
	#category : #'TowerKit-Core'
}

{ #category : #'instance creation' }
TwkSection class >> createDepthDummySection [
	^ self new 
		dummyCross: true;
		depthSplit: true;
		crossValues: #(diamond);
		name: '__DUMMY__DEPTH';
		yourself.
]

{ #category : #'instance creation' }
TwkSection class >> createPlaneDummySection [
	^ self new 
		dummyCross: true;
		depthSplit: false;
		crossValues: #(diamond);
		name: '__DUMMY__PLANE';
		yourself.
]

{ #category : #'instance creation' }
TwkSection class >> depthDummySection [
	^ DepthDummySection ifNil: [ DepthDummySection := self createDepthDummySection ]
]

{ #category : #'class initialization' }
TwkSection class >> initialize [
	"self initialize"
	DepthDummySection := nil.
	PlaneDummySection := nil.	
]

{ #category : #'instance creation' }
TwkSection class >> planeDummySection [
	^ PlaneDummySection ifNil: [ PlaneDummySection := self createPlaneDummySection ]
]

{ #category : #accessing }
TwkSection >> crossDelegate [
	^ crossDelegate
		ifNil: [ 
			crossDelegate := TwkCross new.
			crossDelegate parent: self ]
]

{ #category : #accessing }
TwkSection >> crossValues [
	^ self crossDelegate crossValues
]

{ #category : #accessing }
TwkSection >> crossValues: aCollection [
	crossValues := aCollection. 
	self crossDelegate crossValues: aCollection 
]

{ #category : #accessing }
TwkSection >> depthSplit [
	^ depthSplit
]

{ #category : #accessing }
TwkSection >> depthSplit: aBoolean [
	depthSplit := aBoolean
]

{ #category : #accessing }
TwkSection >> dummyCross [
	^ dummyCross
]

{ #category : #accessing }
TwkSection >> dummyCross: aBoolean [
	dummyCross := aBoolean
]

{ #category : #initialization }
TwkSection >> initialize [
	super initialize.
	depthSplit := false.
	dummyCross := false.
	insertSpecs := OrderedCollection new.
]

{ #category : #accessing }
TwkSection >> insertPointOffset: aOffset faceAt: aFaceSymbol [
	| map |
	map := Dictionary new.
	map at: #offset put: aOffset.
	map at: #face put: aFaceSymbol.
	insertSpecs add: map. 
]

{ #category : #'as yet unclassified' }
TwkSection >> insertSpecsOfDirection: aDirection [
	^ (insertSpecs select: [ :map | (map at: #face) = aDirection ]) sort: [ :a :b  | (a at: #offset) >  (b at: #offset)]
]

{ #category : #'objects from disk' }
TwkSection >> jsonKeysForDirect [
	^ super jsonKeysForDirect addAll: #(#depthSplit crossValues); yourself
]

{ #category : #'objects from disk' }
TwkSection >> postFixJsonRestore [
	super postFixJsonRestore.
	crossValues 
		ifNotNil: [
			self crossValues: crossValues]
]

{ #category : #'as yet unclassified' }
TwkSection >> wallSideInsertPointsOnDirection: aDirection [
	^ (insertSpecs
		select: [ :map | (map at: #face) = aDirection ]
		thenCollect: [ :map2 | parent pointOffset: (map2 at: #offset) ]) sort: [ :a :b | a x > b x ]
]
