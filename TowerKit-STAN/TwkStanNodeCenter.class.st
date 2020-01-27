Class {
	#name : #TwkStanNodeCenter,
	#superclass : #TwkNode,
	#instVars : [
		'locationToNodeMap',
		'idSeed',
		'keyToSegmentMap'
	],
	#category : #'TowerKit-STAN'
}

{ #category : #initialization }
TwkStanNodeCenter >> forPoint3d: aArray3 [
	^ locationToNodeMap
		at: aArray3
		ifAbsentPut: [ 
			idSeed := idSeed + 1.
			TwkStanNode new
				name: ('_UNKNOWN_', idSeed asString);
				point3d: aArray3;
				sequenceId: idSeed;
				yourself ]
]

{ #category : #initialization }
TwkStanNodeCenter >> initialize [
	super initialize.
	idSeed := 0.
	locationToNodeMap := Dictionary new.
	keyToSegmentMap := Dictionary new.
	
]

{ #category : #accessing }
TwkStanNodeCenter >> maxNodeNumber [
	^ self stanNodes ifNotEmpty: [ :nodes | nodes last number ] ifEmpty: [ 1 ].

]

{ #category : #accessing }
TwkStanNodeCenter >> maxNodeNumberOfBrick: aAbstractBrick [
	^ self stanNodes 
		ifNotEmpty: [ :nodes | 
			| selected |
			selected := nodes select: [ :each | each parent = aAbstractBrick ].
			selected 
				ifEmpty: [ self maxNodeNumber ] 
				ifNotEmpty: [ selected last number ] ] 
		ifEmpty: [ 1 ].

]

{ #category : #accessing }
TwkStanNodeCenter >> maxSegmentNumber [
	^ self stanSegments ifNotEmpty: [ :segs | segs last number ] ifEmpty: [ 1 ].
	 
]

{ #category : #initialization }
TwkStanNodeCenter >> nodesFromPoints: points nodeTopNmber: nodeTopNumber parent: aParent type: aType subType: aType2 [
	| nodes nodeNumber |
	nodes := OrderedCollection new.
	nodeNumber := nodeTopNumber.
	points doWithIndex: [ :array3 :index | 
		| node |
			node := self forPoint3d: array3.
			node type ifNil: [ node type: aType ].
			node subType ifNil: [ aType2 ifNotNil: [node subType: aType2] ].
			node addTag: aParent name.
			node parent 
				ifNil: [
					node parent: aParent].
			node addTag: aParent name.
			node number < 0
				ifTrue: [ 
					node number: nodeNumber.
					nodeNumber := nodeNumber + 1 ].
			node setProperty: #index toValue: index.
			nodes add: node.  		
		].
	^ nodes asSet asArray sort: [ :a :b | a number < b number ] 
]

{ #category : #initialization }
TwkStanNodeCenter >> segmentFrom: fromNode to: toNode [
	| keyPoint |
	keyPoint := (fromNode number < toNode number) 
		ifTrue: [ fromNode number @ toNode number ]
		ifFalse: [ toNode number @ fromNode number ].
	^ keyToSegmentMap 
		at: keyPoint
		ifAbsentPut: [ 
			idSeed := idSeed + 1.
			TwkSegment new
				name: ('_UNKNOWN_', idSeed asString);
				from: fromNode;
				to: toNode;				
				sequenceId: idSeed;
				yourself ]
]

{ #category : #accessing }
TwkStanNodeCenter >> stanNodes [
	^ locationToNodeMap values sort: [ :a :b | a number < b number ]
]

{ #category : #accessing }
TwkStanNodeCenter >> stanSegments [ 
	^ keyToSegmentMap values sort: [ :a :b | a number < b number ]
]
