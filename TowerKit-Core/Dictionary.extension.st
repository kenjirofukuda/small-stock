Extension { #name : #Dictionary }

{ #category : #'*TowerKit-Core' }
Dictionary >> twkInstance [
	| map symbolKeys |
	(self at: '_clazz' ifAbsent: [  ])
		ifNotNil: [ :className | 
			| result |
			result := TwkTowerKit instanceMap
				at: (self at: 'uuid')
				ifAbsentPut: [ | instance |
					instance := className asSymbol asClass new.
					instance attributesFrom: self.
					Array with: instance with: self ].
			^ result first ].
	map := Dictionary new.
	symbolKeys := self at: '_symbolKeys' ifAbsent: [ #() ].
	self
		keysAndValuesDo: [ :key :value | 
			(key beginsWith: '_')
				ifFalse: [ | newKey |
					newKey := (symbolKeys includes: key)
						ifTrue: [ key asSymbol ]
						ifFalse: [ key ].
					map at: newKey put: value twkInstance ] ].
	^ map
]

{ #category : #'*TowerKit-Core' }
Dictionary >> twkJsonObject [
	| map |
	map := Dictionary new.
	(self keys select: [ :key | key isSymbol  ])
		ifNotEmptyDo: [ :symbolKeys |
			map at: '_symbolKeys' put: symbolKeys.
			 ].
	self keysAndValuesDo: [ :key :value |
		map at: key put: ([value twkJsonObject] on: Error do: [ :ex | ex return: value ])
		].
	^ map.
]
