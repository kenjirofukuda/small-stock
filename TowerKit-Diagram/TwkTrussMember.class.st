Class {
	#name : #TwkTrussMember,
	#superclass : #TwkTrussElement,
	#instVars : [
		'from',
		'to'
	],
	#category : #'TowerKit-Diagram'
}

{ #category : #accessing }
TwkTrussMember >> angleDegressBaseNamed: aBaseName [
	| baseJoint angleJoint |
	(self hasJointName: aBaseName)
		ifFalse: [ ^ self error: ('<1s> not found' expandMacros with: aBaseName) ].
	(from sameAs: aBaseName)
		ifTrue: [ 
			baseJoint := self fromJoint.
			angleJoint := self toJoint ]
		ifFalse: [ 
			baseJoint := self toJoint.
			angleJoint := self fromJoint ].
	^ (angleJoint position - baseJoint position) angleDegress degressNormalized. 
]

{ #category : #converting }
TwkTrussMember >> asLineSegment [
	^ LineSegment from: self startPosition to: self endPosition
]

{ #category : #accessing }
TwkTrussMember >> endPosition [
	^ self toJoint position
]

{ #category : #accessing }
TwkTrussMember >> from: aFromPointName [
	from := aFromPointName
	
]

{ #category : #accessing }
TwkTrussMember >> fromJoint [
	self world ensurePoint: from jointDo: [ :foundJoint  | ^ foundJoint ].
	^ nil
]

{ #category : #accessing }
TwkTrussMember >> hasJointName: aString [
	^ (from sameAs: aString) or: [to sameAs: aString] 
]

{ #category : #initialization }
TwkTrussMember >> initialize [
	super initialize.
	from := '*'.
	to := '*'.	
]

{ #category : #testing }
TwkTrussMember >> isHorizontal [
	^ self asLineSegment isHorizontal
]

{ #category : #testing }
TwkTrussMember >> isVertical [
	^ self asLineSegment isVertical
]

{ #category : #accessing }
TwkTrussMember >> names [
	^ Array with: from with: to
]

{ #category : #printing }
TwkTrussMember >> printOn: aStream [
	aStream nextPutAll: self name.
	aStream nextPut: $(.
	aStream nextPutAll: from.
	aStream nextPut: $-.
	aStream nextPutAll: to.
	aStream nextPut: $).	
]

{ #category : #accessing }
TwkTrussMember >> reverseSideName: aFindName [
	^ (self names reject: [ :each | each sameAs: aFindName ]) anyOne.
]

{ #category : #accessing }
TwkTrussMember >> startPosition [
	^ self fromJoint position
]

{ #category : #accessing }
TwkTrussMember >> to: aToPointName [
	to := aToPointName
	
]

{ #category : #accessing }
TwkTrussMember >> toJoint [
	self world ensurePoint: to jointDo: [ :foundJoint  | ^ foundJoint ].
	^ nil
]

{ #category : #accessing }
TwkTrussMember >> topLetter [
	^ 'S'
]
