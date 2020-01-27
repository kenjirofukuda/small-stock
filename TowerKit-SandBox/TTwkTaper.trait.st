Trait {
	#name : #TTwkTaper,
	#category : #'TowerKit-SandBox'
}

{ #category : #'accessing - taper' }
TTwkTaper >> firstValue [
	^ 0
]

{ #category : #'accessing - taper' }
TTwkTaper >> growSize [
	^ self lastValue - self firstValue 
]

{ #category : #'accessing - taper' }
TTwkTaper >> growSizeByUnit [
	^ self growSize / self interVolume
]

{ #category : #'accessing - taper' }
TTwkTaper >> interVolume [
	^ 0
]

{ #category : #'accessing - taper' }
TTwkTaper >> korobi [
	^ (self growSize / 2) / self interVolume
]

{ #category : #'accessing - taper' }
TTwkTaper >> korobiBoth [
	^ self growSizeByUnit
]

{ #category : #'accessing - taper' }
TTwkTaper >> lastValue [
	^ 0
]

{ #category : #'accessing - taper' }
TTwkTaper >> nobi [
	^ ((self korobi * self korobi) + 1) sqrt 
]

{ #category : #'accessing - taper' }
TTwkTaper >> sizeFromFirst: aNumber [ 
	^ self growSizeByUnit * aNumber + self firstValue 
]

{ #category : #'accessing - taper' }
TTwkTaper >> sizeFromLast: aNumber [
	^ self lastValue - (self growSizeByUnit * aNumber)
]
