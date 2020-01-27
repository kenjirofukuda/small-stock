Class {
	#name : #TwkSampleArm,
	#superclass : #TwkNode,
	#category : #'TowerKit-Diagram'
}

{ #category : #accessing }
TwkSampleArm >> Q [
	^ self armLength / (2 * self bodyWidth)
]

{ #category : #accessing }
TwkSampleArm >> R [
	^ self reactionForce
]

{ #category : #accessing }
TwkSampleArm >> armLength [
	^ 6550
]

{ #category : #accessing }
TwkSampleArm >> armSegments [
	| points |
	points := self bodyPositions.
	^ Array
		with: (LineSegment from: self forcePosition to: (points at: 4))
		with: (LineSegment from: self forcePosition to: (points at: 1))
]

{ #category : #accessing }
TwkSampleArm >> b [
	^ self bodyWidth
]

{ #category : #accessing }
TwkSampleArm >> bodyPositions [
	| halfWidth signs |
	halfWidth := self bodyWidth / 2.
	signs := { 1 @ -1 . -1 @ -1 . -1 @ 1 . 1 @ 1 }.
	^ signs collect: [ :each | each * halfWidth ]
]

{ #category : #accessing }
TwkSampleArm >> bodySegments [
	| points |
	points := self bodyPositions.
	^ #(#(1 2) #(2 3) #(3 4) #(4 1) #(2 4) #(1 3))
		collect: [ :each |
			LineSegment from: (points at: each first) to: (points at: each second) 
			 ]    
]

{ #category : #accessing }
TwkSampleArm >> bodyWidth [
	^ 2400
]

{ #category : #accessing }
TwkSampleArm >> crossSegments [
	^ LineSegment splitedSegments: self segments  epsilon: TwkTowerKit epsilon  
]

{ #category : #'as yet unclassified' }
TwkSampleArm >> forcePosition [
	^ self armLength @ 0
]

{ #category : #initalize }
TwkSampleArm >> initialize [
	self name: 'SampleArm'.	
]

{ #category : #accessing }
TwkSampleArm >> l [
	^ self armLength
]

{ #category : #accessing }
TwkSampleArm >> positions [
	^ (self bodyPositions , { self forcePosition }, { 0 @ 0 }) asSet
]

{ #category : #'as yet unclassified' }
TwkSampleArm >> printOn: aStream [
	self diagramJoints do: [ :each | each printOn: aStream ]
]

{ #category : #accessing }
TwkSampleArm >> q [
	^ self Q
]

{ #category : #accessing }
TwkSampleArm >> reactionForce [
	^ (self armLength / self bodyWidth) - 0.5
]

{ #category : #'as yet unclassified' }
TwkSampleArm >> renderRoassalOn: aRTView [
	| points bounds maxSide ellipseSize lineSize  |
	points := self positions.
	bounds := GeometryUtils lookupDataBounds: points.
	maxSide := bounds width max: bounds height.
	ellipseSize := maxSide / 40.0.
	lineSize := maxSide / 240.0.

	self 
		renderRoassalOn: aRTView 
		points: points 
		segments: self crossSegments 
		ellipseSize: ellipseSize 
		lineSize: lineSize.

	self postRoassalOn: aRTView

]

{ #category : #accessing }
TwkSampleArm >> segments [
	^ self bodySegments, self armSegments 
]

{ #category : #'as yet unclassified' }
TwkSampleArm >> segmentsHasPosition: aPoint [
	(self crossSegments select: [ :seg | seg controlPoints anySatisfy: [ :p | p closeTo: aPoint ] ])
		ifNotEmpty: [ :points | 
			]
	
]
