Class {
	#name : #TwkTrussWorld,
	#superclass : #TwkNode,
	#instVars : [
		'joints',
		'jointNumber',
		'memberNumber',
		'members',
		'points',
		'outerPoints',
		'innerPoints'
	],
	#category : #'TowerKit-Diagram'
}

{ #category : #accessing }
TwkTrussWorld >> axisMembers [
	^ self members select: [ :each | each asLineSegment isHorizontal or: [ each asLineSegment isVertical ] ]
]

{ #category : #private }
TwkTrussWorld >> createMember [
	| member |
	member := TwkTrussMember new.
	member parent: self.
	^ member
]

{ #category : #utility }
TwkTrussWorld >> ensurePoint: aPoint jointDo: memberBlock [
	aPoint isString 
		ifTrue: [ 
			(self jointByName: aPoint)
				ifNotNil: [ :foundJoint | 
					memberBlock value: foundJoint ]
				ifNil: [ ^ self error: ('Point name not found: <1s>' expandMacrosWith: aPoint) ] ].
	
	aPoint isPoint 
		ifTrue: [ 
			(self jointByPosition: aPoint)
				ifNotNil: [ :foundJoint | 
					memberBlock value: foundJoint ]
				ifNil: [ ^ self error: ('Point not found: <1p>' expandMacrosWith: aPoint) ] ].
			
]

{ #category : #examples }
TwkTrussWorld >> fillSampleArm [
	| arm reaction baseForce |

	arm := TwkSampleArm new.
	baseForce := TwkForce new
						loadValue: 1;
						angleDegress: 90;
						yourself.
	self newForce
		position: arm forcePosition;
		addForce: baseForce.
		
	self newJoint position: 0 @ 0.
	reaction := 1 / arm bodyPositions size.
	arm bodyPositions
		do: [ :each | 
			| reactionForce pinJoint halfQ  rotateForce1 rotateForce2 |
			pinJoint := self newPin position: each.
			reactionForce := baseForce reversed
				loadValue: reaction;
				yourself.

			halfQ := arm Q / 2.			
			rotateForce1 := TwkForce new
				loadValue: halfQ negated;
				angleDegress: pinJoint nearAngle;
				yourself.				
			rotateForce2 := TwkForce new
				loadValue: halfQ;
				angleDegress: pinJoint farAngle;
				yourself.
				
			pinJoint addForce: reactionForce.
			pinJoint addForce: rotateForce1.	
			pinJoint addForce: rotateForce2 ].			

	arm crossSegments do: [ :seg | self newMemberSegment: seg ].					

]

{ #category : #'as yet unclassified' }
TwkTrussWorld >> findFirstJoint [
	^ ((self joints select: [ :each | each hasForce ]) 
		sort: [ :a :b | a ownerMembers size < b ownerMembers size]) first
]

{ #category : #accessing }
TwkTrussWorld >> forces [
	^ Array streamContents: [ :s | 
		joints do: [ :each | 	s nextPutAll: each forcesOrdered ] ]
]

{ #category : #initialization }
TwkTrussWorld >> initialize [
	super initialize.
	jointNumber := 1.
	memberNumber := 1.
	joints := OrderedCollection new.
	members := OrderedCollection new.
	points := OrderedCollection new.
	self name: 'World'
]

{ #category : #accessing }
TwkTrussWorld >> innerPoints [
	^ innerPoints ifNil: [ innerPoints := self lookupInnerPoints ]
]

{ #category : #accessing }
TwkTrussWorld >> jointByName: aString [
	^ joints detect: [ :joint | joint name sameAs: aString ] ifNone: [  ]
			
]

{ #category : #accessing }
TwkTrussWorld >> jointByPosition: aPoint [
	^ joints detect: [ :joint | joint position closeTo: aPoint ] ifNone: [  ]

]

{ #category : #accessing }
TwkTrussWorld >> joints [
	^ joints
]

{ #category : #accessing }
TwkTrussWorld >> loadAssociationsComposite [
	^ joints flatCollect: [ :each | 
			each forcesCompositOrdered 
				collect: [ :force | 
					each -> force loadValueVector  ] ]
]

{ #category : #'as yet unclassified' }
TwkTrussWorld >> loadDictionaryPoints [
	| map |
	map := Dictionary new.
	self outerPoints do: [ :each  |
		| joint |
		joint := each valueOfProperty: #joint.
		map at: joint  ifAbsentPut: [ OrderedCollection new ].
		(map at: joint) add: each ].
	map keysAndValuesDo: [ :key :value |
		map at: key put: value asArray].
	^ map 
]

{ #category : #accessing }
TwkTrussWorld >> loadValues [
	^ joints flatCollect: [ :each | each forcesOrdered collect: [ :force | force loadValueVector  ] ]
]

{ #category : #accessing }
TwkTrussWorld >> loadValuesHorizontal [
	^ self loadValues collect: [ :each | each x ]
]

{ #category : #accessing }
TwkTrussWorld >> loadValuesVertical [
	^ self loadValues collect: [ :each | each y ]
]

{ #category : #'as yet unclassified' }
TwkTrussWorld >> lookupInnerPoints [
	| col pointsMap joint newPoint segs crossPoint segments mapEntry |
	col := OrderedCollection new.
	pointsMap := self loadDictionaryPoints.
	joint := self findFirstJoint.
	newPoint := self newPoint.
	segs := OrderedCollection new.
	mapEntry := (pointsMap at: joint). 
	(joint ownerMembersBaseAngle: joint forces anyOne angleDegress ccw: true)
		doWithIndex: [ :member :index | 
			| pointAngle fromJoint seg fromPoint |
			pointAngle := ((member angleDegressBaseNamed: joint name) + 180) degressNormalized.
			fromJoint := self jointByName: (member reverseSideName: joint name).
			fromPoint := mapEntry at: index.
			seg := LineSegment 
				from: fromPoint asPoint 
				to: fromPoint asPoint + (Point r: 1 degrees: pointAngle).
			segs add: seg.
			Transcript
				cr;
				show: '---------------------------';
				cr.
			{member.
			pointAngle.
			fromJoint.
			fromPoint.
			seg} logCr	"self halt." ].
	crossPoint := segs first intersectionWith: segs second virtualAllowed: true.
	newPoint position: crossPoint.
	segments := segs collect: [ :each | LineSegment from: each start to: crossPoint ].	
	newPoint setProperty: #segments toValue: segments.
	"segments traceCr."
	col add: newPoint.	
	^ col asArray
]

{ #category : #'as yet unclassified' }
TwkTrussWorld >> lookupOuterPoints [
	| subTotal |
	subTotal := 0 @ 0.
	^ Array streamContents: [ :s | 
		(self loadAssociationsComposite) doWithIndex: [ :assoc :index | 
			| node |
			subTotal := subTotal + assoc value.
			node := self newPoint
				position: subTotal;	
				setProperty: #joint toValue: assoc key;			
				yourself.
			s nextPut: node
			]
		]

]

{ #category : #accessing }
TwkTrussWorld >> members [
	^ members
]

{ #category : #'instance creation' }
TwkTrussWorld >> newForce [
	^ self newJointTyped: #force
]

{ #category : #'instance creation' }
TwkTrussWorld >> newJoint [
	^ self newJointTyped: #normal
]

{ #category : #'instance creation' }
TwkTrussWorld >> newJointTyped: aSymbol [
	| joint |
	joint := TwkTrussJoint new.
	joint parent: self.
	joint type: aSymbol.
	joints add: joint.
	joint number: jointNumber.
	jointNumber := jointNumber + 1.	
	^ joint
]

{ #category : #'instance creation' }
TwkTrussWorld >> newMemberFrom: aPoint1 to: aPoint2 [
	| member | 
	member := self createMember.
	self ensurePoint: aPoint1 jointDo: [ :foundJoint |  member from: foundJoint name ].
	self ensurePoint: aPoint2 jointDo: [ :foundJoint |  member to: foundJoint name ].	
	member number: memberNumber. 	
	members add: member.	
	memberNumber := memberNumber + 1.
	^ member	
]

{ #category : #'instance creation' }
TwkTrussWorld >> newMemberSegment: aLineSegment [
	^ self newMemberFrom: aLineSegment start to: aLineSegment end
	
]

{ #category : #'instance creation' }
TwkTrussWorld >> newPin [
	^ self newJointTyped: #pin
]

{ #category : #'instance creation' }
TwkTrussWorld >> newPoint [
	| point |
	point := TwkTrussPoint new.
	point parent: self.
	points add: point.
	point number: (points collect: [:each | each number ]) max + 1.
	^ point
]

{ #category : #'instance creation' }
TwkTrussWorld >> newRoller [
	^ self newJointTyped: #roller
]

{ #category : #accessing }
TwkTrussWorld >> outerPoints [
	^ outerPoints ifNil: [ outerPoints := self lookupOuterPoints ].

]

{ #category : #accessing }
TwkTrussWorld >> positions [
	^ joints collect: [ :each | each position ]
]

{ #category : #accessing }
TwkTrussWorld >> segments [
	^ members collect: [ :each | each asLineSegment ]
]
