Class {
	#name : #TwkNode,
	#superclass : #Object,
	#traits : 'TTwkPropertiesOwner',
	#classTraits : 'TTwkPropertiesOwner classTrait',
	#instVars : [
		'name',
		'parent',
		'properties',
		'uuid'
	],
	#category : #'TowerKit-Core'
}

{ #category : #accessing }
TwkNode class >> japaneseClassName [
	^ 'ノード'
]

{ #category : #'objects from disk' }
TwkNode class >> stringCollectionToSymbols: aCollection [
	^ aCollection class
		streamContents: [ :s | 
			aCollection
				do: [ :each | 
					each isString
						ifTrue: [ s nextPut: each asSymbol ]
						ifFalse: [ 
							each isCollection
								ifTrue: [ s nextPut: (self stringCollectionToSymbols: each) ]
								ifFalse: [ s nextPut: each ] ] ] ]
]

{ #category : #'brick-structure' }
TwkNode >> allOwnersDo: aBlock [
	"Evaluate aBlock with all owners of the receiver"
	self owner ifNotNil:[ ^ self owner withAllOwnersDo: aBlock ].
]

{ #category : #'objects from disk' }
TwkNode >> asJson [
	^ NeoJSONWriter toStringPretty: self twkJsonObject
]

{ #category : #'objects from disk' }
TwkNode >> attributesFrom: aDictionary [
	self basicAttributesFrom: aDictionary
]

{ #category : #'objects from disk' }
TwkNode >> attributesOn: aDictionary [
	aDictionary at: '_clazz' put: self class name asString.
	self basicAttributesOn: aDictionary.
	
]

{ #category : #'objects from disk' }
TwkNode >> basicAttributesFrom: aDictionary [
	(self jsonKeys)
		do: [ :each | 
			(aDictionary at: each ifAbsent: []) 
				ifNotNil: [ :val | 
					| instVar instance |
					instVar := self instVarNamed: each.	
					instance := val twkInstance.
					(instVar isKindOf: NewValueHolder)
						ifTrue: [ instVar value: instance . ]
						ifFalse: [ self instVarNamed: each put: instance ]. 
					  ] ].

]

{ #category : #'objects from disk' }
TwkNode >> basicAttributesOn: aDictionary [
	(self jsonKeys)
		do: [ :each | 
			(self instVarNamed: each asString)
				ifNotNil: [ :val | 
					aDictionary
						at: each
						put:
							((val isKindOf: NewValueHolder)
								ifTrue: [ val value ]
								ifFalse: [ val ]) twkJsonObject  ] ].

]

{ #category : #private }
TwkNode >> clearCache [
]

{ #category : #utility }
TwkNode >> ensureCollection: anObject [
	^ anObject 
		isArray 
			ifFalse: [
				anObject isInterval ifTrue: [ ^ anObject asArray ]. 
				Array with: anObject ] 
			ifTrue: [ anObject ].

]

{ #category : #'brick-structure' }
TwkNode >> firstOwnerSuchThat: conditionBlock [

	self allOwnersDo: [:m | (conditionBlock cull: m) ifTrue: [^ m]].
	^ nil

]

{ #category : #'objects from disk' }
TwkNode >> fixCrossValues [
	([ self instVarNamed: 'crossValues' ]
		on: Error
		do: [ :ex | ex return: nil ])
		ifNotNil: [ :instVar | 
			self instVarNamed: 'crossValues' put: (TwkNode stringCollectionToSymbols: instVar).
			"self crossValues: (self instVarNamed: 'crossValues')" ]
]

{ #category : #initialization }
TwkNode >> initialize [
	uuid := UUID new asString.
]

{ #category : #accessing }
TwkNode >> japaneseClassName [
	^ self class japaneseClassName
]

{ #category : #'objects from disk' }
TwkNode >> jsonKeys [
	^ (self jsonKeysForDirect, self jsonKeysForObject, self jsonKeysForObjectCollection)
]

{ #category : #'objects from disk' }
TwkNode >> jsonKeysForDirect [
	^ #(name uuid) asOrderedCollection
]

{ #category : #'objects from disk' }
TwkNode >> jsonKeysForObject [
	^ #()  asOrderedCollection
]

{ #category : #'objects from disk' }
TwkNode >> jsonKeysForObjectCollection [
	^ #() asOrderedCollection
]

{ #category : #accessing }
TwkNode >> name [
	^ name
]

{ #category : #accessing }
TwkNode >> name: aName [
	name := aName
	
]

{ #category : #accessing }
TwkNode >> number [
	^ (self name allButFirst) asNumber 
]

{ #category : #accessing }
TwkNode >> onceParent: aNode [
	self parent ifNil: [ self parent:  aNode. ].
	
]

{ #category : #accessing }
TwkNode >> owner [
	^ self parent
]

{ #category : #accessing }
TwkNode >> ownerBrick [
	^ self ownerThatIsA: TwkAbstractBrick 
]

{ #category : #accessing }
TwkNode >> ownerBrickDo: aBlock [
	self ownerBrick ifNotNil: [ :brick | aBlock value: brick ]	
]

{ #category : #'brick-structure' }
TwkNode >> ownerThatIsA: aClass [
	"Return the first enclosing morph that is a kind of aClass, or nil if none"

	^ self firstOwnerSuchThat: [:m | m isKindOf: aClass]
]

{ #category : #accessing }
TwkNode >> parent [
	^ parent
]

{ #category : #accessing }
TwkNode >> parent: aNode [
	parent := aNode
	
]

{ #category : #copying }
TwkNode >> postCopy [
	super postCopy.
	(self valueOfProperty: #copyHistory ifAbsentPut: [ OrderedCollection new ])
		add: uuid.
	uuid := UUID new asString.
	
]

{ #category : #'objects from disk' }
TwkNode >> postFixJsonRestore [
	self fixCrossValues
]

{ #category : #printing }
TwkNode >> printOn: aStream [
	super printOn: aStream.
	name ifNotNil: [
		aStream nextPut: $(.
		aStream nextPutAll: self name printString. 
		aStream nextPut: $).	]
]

{ #category : #accessing }
TwkNode >> properties [
	^ properties ifNil: [ properties := Dictionary new. ]
]

{ #category : #'objects from disk' }
TwkNode >> twkJsonObject [
	| map |
	map := Dictionary new.
	map at: '_clazz' put: self class name.
	self parent 
		ifNotNil: [ map at: '_parentUUID' put: self parent uuid ].
	^ (TwkTowerKit instanceMap at: uuid ifAbsent: [])
		ifNil: [ 
			self attributesOn: map .
			TwkTowerKit instanceMap at: uuid put: map.
			map]
		ifNotNil: [ 
			map at: 'uuid' put: uuid.
			map.
			 ]
]

{ #category : #accessing }
TwkNode >> uuid [
	^ uuid
]

{ #category : #'brick-structure' }
TwkNode >> withAllOwnersDo: aBlock [
	"Evaluate aBlock with the receiver and all of its owners"
	aBlock cull: self.
	self owner ifNotNil:[ ^ self owner withAllOwnersDo: aBlock ]
]
