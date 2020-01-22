"
A GdsGrid is Gridding attribute.

Instance Variables
	offsetX:		<Float>
	offsetY:		<Float>
	scaleX:		<Float>
	scaleY:		<Float>

offsetX
	- xxxxx

offsetY
	- xxxxx

scaleX
	- xxxxx

scaleY
	- xxxxx

"
Class {
	#name : #GdsGrid,
	#superclass : #Model,
	#instVars : [
		'offsetX',
		'offsetY',
		'scaleX',
		'scaleY',
		'displayMultiply'
	],
	#category : #'GdsFeel-Model-Viewing'
}

{ #category : #'as yet unclassified' }
GdsGrid class >> lookupGridStepsMin: aMinValue max: aMaxValue gridScale: aGridScale [
	^((Interval 
		from: ((aMinValue roundTo: aGridScale) -  aGridScale) 
		to: ((aMaxValue roundTo: aGridScale) + aGridScale ) by: aGridScale) 
			collect: [:each | each roundTo: aGridScale]) asArray.
]

{ #category : #convert }
GdsGrid >> asAbbreviateArray [
	^ Array streamContents: [ :s |
		self isZeroOffset 
			ifTrue: [
				s nextPut: scaleX.
				self isSameScale 
					ifFalse: [s nextPut: scaleY]]
			ifFalse: [
				s nextPutAll: self asArray]].

]

{ #category : #convert }
GdsGrid >> asArray [
	^{ offsetX . offsetY . scaleX . scaleY }
]

{ #category : #convert }
GdsGrid >> asRequestString [
	^GdsFeel join:  (self asAbbreviateArray collect: [:each | each asString]) using: ' '.
]

{ #category : #accessing }
GdsGrid >> displayMultiply [
	^displayMultiply
	
]

{ #category : #accessing }
GdsGrid >> displayMultiply: aValue [
	| value |
	value := aValue asInteger .
	value negative ifTrue: [^self].
	displayMultiply := value.
	self changed: #gridDisplayMultiply.
	
]

{ #category : #initialization }
GdsGrid >> initialize [
	offsetX := 0.0.
	offsetY := 0.0.
	scaleX := 1.0.
	scaleY := 1.0.
	displayMultiply := 10.
	
]

{ #category : #testing }
GdsGrid >> isSameOffset [
	^offsetX = offsetY
]

{ #category : #testing }
GdsGrid >> isSameScale [
	^scaleX = scaleY
]

{ #category : #testing }
GdsGrid >> isZeroOffset [
	^self offset isZero
]

{ #category : #utility }
GdsGrid >> lookupGridStepsMin: aMin max: aMax gridScale: aGridScale gridOffset: aGridOffset [
	|  start end  values |
	start :=  aMin roundTo: aGridScale.
	end :=  aMax roundTo: aGridScale.
	values := (self class lookupGridStepsMin: start max: end gridScale: aGridScale).
	values := values select: [:each | | v | 
		v := (each rem: aGridScale) abs roundTo: aGridScale.
		(v closeTo:  0.0) or: [v closeTo: aGridScale]].  
	values := values collect: [:each | each + aGridOffset].
	^values
	
	
]

{ #category : #accessing }
GdsGrid >> offset [
	^offsetX@offsetY.
]

{ #category : #accessing }
GdsGrid >> offset: aOffset [
	| p |
	p := aOffset asPoint.
	self setOffsetX: p x setOffsetY: p y. 
	self changed: #gridOffset.
	self displayMultiply: 1.
	
	
]

{ #category : #accessing }
GdsGrid >> scale [
	^scaleX@scaleY.
]

{ #category : #accessing }
GdsGrid >> scale: aScale [
	| p |
	p := aScale asPoint.
	self setScaleX: p x setScaleY: p y. 
	self changed: #gridScale.
	self displayMultiply: 1.
	
]

{ #category : #private }
GdsGrid >> setOffsetX: aX setOffsetY: aY [
	offsetX := aX.
	offsetY := aY.
	

]

{ #category : #private }
GdsGrid >> setScaleX: aX setScaleY: aY [
	scaleX := aX.
	scaleY := aY.
	
]

{ #category : #accessing }
GdsGrid >> values: anArray [
	self assert: [anArray isNil not].
	self assert: [anArray allSatisfy: [:each | each isNumber]].
	self assert: [#(1 2 4) includes: anArray size].
	anArray ifEmpty: [^self].
	anArray size = 1
		ifTrue: [
			scaleX := anArray at: 1.
			scaleY := anArray at: 1.].
	anArray size = 2
		ifTrue: [
			scaleX := anArray at: 1.
			scaleY := anArray at: 2.].
	anArray size = 4
		ifTrue: [
			offsetX := anArray at: 1.
			offsetY := anArray at: 2.
			scaleX := anArray at: 3.
			scaleY := anArray at: 4.].

	self changed: #gridScale.
	anArray size = 4 
		ifTrue: [self changed: #gridOffset.].
	self displayMultiply: 1.
	
]
