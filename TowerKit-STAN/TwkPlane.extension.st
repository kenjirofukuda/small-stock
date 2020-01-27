Extension { #name : #TwkPlane }

{ #category : #'*TowerKit-STAN' }
TwkPlane >> beUnresolved [
	width := nil
]

{ #category : #'*TowerKit-STAN' }
TwkPlane >> stanHorizontalRoundPoints [
	| points |
	" same order in horizontal environment "
	points := OrderedCollection new.
	points addAll: self basicHorizontalIndexedPoints.
	^ points asArray	
]

{ #category : #'*TowerKit-STAN' }
TwkPlane >> stanRoundPoints [
	^ self ownerBrick isPost
		ifTrue: [ self stanVerticalRoundPoints ]
		ifFalse: [ self stanHorizontalRoundPoints  ]
		
]

{ #category : #'*TowerKit-STAN' }
TwkPlane >> stanVerticalRoundPoints [
	| points basicPoints |
	" 1 2 3 4  to 4 1 2 3 order STAN invertical "
	points := OrderedCollection new.
	basicPoints :=  self basicVerticalIndexedPoints.
	points add: basicPoints last.
	points addAll: basicPoints allButLast.
	^ points asArray	
]
