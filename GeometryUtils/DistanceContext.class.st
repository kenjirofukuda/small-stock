Class {
	#name : #DistanceContext,
	#superclass : #Object,
	#instVars : [
		'virtualCrossPoint',
		'crossPoint',
		'cross',
		'start',
		'startToCross',
		'end',
		'endToCross',
		'side',
		'segIndex',
		'testPoint',
		'lineSegment'
	],
	#category : #GeometryUtils
}

{ #category : #'instance creation' }
DistanceContext class >> fromPoint: aPoint lineSegment: aLineSegment [
	^ self new testPoint: aPoint; lineSegment: aLineSegment; yourself.
]

{ #category : #private }
DistanceContext >> clearCache [
	end := nil.
	start := nil.
	startToCross := nil.
	endToCross := nil.
	cross := nil.
	virtualCrossPoint := nil.
	side := nil.
	
]

{ #category : #accessing }
DistanceContext >> cross [

	^ cross ifNil: [ cross := testPoint distanceTo: self crossPoint ]
]

{ #category : #accessing }
DistanceContext >> crossPoint [
	^ crossPoint ifNil: [crossPoint := self virtualCrossPoint adhereTo: self lineSegment bounds].
]

{ #category : #accessing }
DistanceContext >> end [

	^ end ifNil: [ end := lineSegment end distanceTo: testPoint ]
]

{ #category : #accessing }
DistanceContext >> endPoint [
	^ self lineSegment end
]

{ #category : #accessing }
DistanceContext >> endPoint: aPoint [
	self lineSegment end: aPoint.
	self clearCache.
]

{ #category : #accessing }
DistanceContext >> endToCross [
	^ endToCross ifNil: [endToCross := lineSegment end dist: self crossPoint]
]

{ #category : #accessing }
DistanceContext >> lineSegment [
	^ lineSegment ifNil: [ lineSegment := LineSegment from: 0 @ 0 to: 0 @ 0 ]
]

{ #category : #accessing }
DistanceContext >> lineSegment: aLineSegment [
	lineSegment := aLineSegment.
	self clearCache.
]

{ #category : #accessing }
DistanceContext >> segIndex [
	^ segIndex
]

{ #category : #accessing }
DistanceContext >> segIndex: anInteger [
	segIndex := anInteger
]

{ #category : #accessing }
DistanceContext >> side [
	^ side ifNil: [  side := lineSegment  sideOfPoint: testPoint ]
]

{ #category : #accessing }
DistanceContext >> start [

	^ start ifNil: [ start := lineSegment start distanceTo: testPoint ]
]

{ #category : #accessing }
DistanceContext >> startPoint [
	^ self lineSegment start
]

{ #category : #accessing }
DistanceContext >> startPoint: aPoint [
	self lineSegment start: aPoint.
	self clearCache.	
]

{ #category : #accessing }
DistanceContext >> startToCross [
	^ startToCross ifNil: [startToCross := lineSegment start dist: self crossPoint]
]

{ #category : #accessing }
DistanceContext >> testPoint [
	^ testPoint
]

{ #category : #accessing }
DistanceContext >> testPoint: aPoint [
	testPoint := aPoint copy.
	self clearCache.
]

{ #category : #accessing }
DistanceContext >> triplet [
	^ { self start . self end . self cross }
]

{ #category : #accessing }
DistanceContext >> virtualCrossPoint [
	^ virtualCrossPoint ifNil: [ virtualCrossPoint := testPoint nearestPointAlongLineFrom: self lineSegment start to: self lineSegment end. ]	

]
