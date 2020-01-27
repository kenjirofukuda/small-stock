Class {
	#name : #TwkTaper,
	#superclass : #TwkNode,
	#traits : 'TTwkTaper',
	#classTraits : 'TTwkTaper classTrait',
	#category : #'TowerKit-SandBox'
}

{ #category : #'accessing - block entry' }
TwkTaper >> firstValue [
	(self valueOfProperty: #firstValue ifAbsent: [ 0 ])
		ifNotNil: [ :val | 
			^ val isBlock
				ifTrue: [ val value ]
				ifFalse: [ val ] ].
	^ nil
]

{ #category : #'accessing - block entry' }
TwkTaper >> firstValue: anObject [
	self setProperty: #firstValue toValue: anObject 
]

{ #category : #'accessing - block entry' }
TwkTaper >> interVolume [
	(self valueOfProperty: #interVolume ifAbsent: [ 0 ])
		ifNotNil: [ :val | 
			^ val isBlock
				ifTrue: [ val value ]
				ifFalse: [ val ] ].
	^ nil
]

{ #category : #'accessing - block entry' }
TwkTaper >> interVolume: anObject [
	self setProperty: #interVolume toValue: anObject 
]

{ #category : #'accessing - block entry' }
TwkTaper >> lastValue [
	(self valueOfProperty: #lastValue ifAbsent: [ 0 ])
		ifNotNil: [ :val | 
			^ val isBlock
				ifTrue: [ val value ]
				ifFalse: [ val ] ].
	^ nil
]

{ #category : #'accessing - block entry' }
TwkTaper >> lastValue: anObject [
	self setProperty: #lastValue toValue: anObject 
]
