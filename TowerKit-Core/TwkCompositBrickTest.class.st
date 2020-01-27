"
A TwkCompositBrickTest is a test class for testing the behavior of TwkCompositBrick
"
Class {
	#name : #TwkCompositBrickTest,
	#superclass : #TestCase,
	#category : #'TowerKit-Core-Tests'
}

{ #category : #'tests-objects from disk' }
TwkCompositBrickTest >> restoreFromJsonNamed: aFileName [
	(TwkCompositBrick projectJsonFiles
		detect: [ :f | f parent basename sameAs: aFileName ]
		ifNone: [  ])
		ifNotNil: [ :f | (TwkCompositBrick fromJsonFile: f) explore ]
]

{ #category : #'tests-objects from disk' }
TwkCompositBrickTest >> testFileOutAsJson [
]

{ #category : #'tests-objects from disk' }
TwkCompositBrickTest >> testrRestore [
	TwkCompositBrick projectJsonFiles first
		ifNotNil: [ :f | 
			TwkTowerKit clearInstanceMap.
			f
				readStreamDo: [ :s | 
					| map instance |
					map := (NeoJSONReader on: s) next.
					instance := map twkInstance.
					{map.
					instance} explore ] ]
]

{ #category : #'tests-objects from disk' }
TwkCompositBrickTest >> testrRestoreFromJson [
	self restoreFromJsonNamed: 'YAMAHEN01'			 
]

{ #category : #'tests-objects from disk' }
TwkCompositBrickTest >> testrRestoreFromJson2 [
	self restoreFromJsonNamed: 'YAMAHEN02'
]

{ #category : #'tests-objects from disk' }
TwkCompositBrickTest >> testrRestoreFromJson3 [
	self restoreFromJsonNamed: 'HOGE'
]
