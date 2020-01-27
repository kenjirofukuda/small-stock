Class {
	#name : #TwkCompositBrick,
	#superclass : #TwkNode,
	#instVars : [
		'doneVerify',
		'postMap',
		'beamMap'
	],
	#category : #'TowerKit-Core'
}

{ #category : #'as yet unclassified' }
TwkCompositBrick class >> chooseProjectFile [
	^ UIManager default
		chooseFullFileNameMatching: #('*.json')
		label: ('Choose "<1s>"' expandMacrosWith: self jsonFileName)
		path: TwkTowerKit defaultFolder
]

{ #category : #'as yet unclassified' }
TwkCompositBrick class >> exampleYna17 [
	<script>
	| brick |
	brick := TwkCompositBrick new name: 'YONA_P17' .
	self yonaP17CreatePostsOn: brick.
	brick verify.		
	"Cursor wait showWhile: [ brick gdsGenerate ]."
	brick explore.
	
]

{ #category : #'objects from disk' }
TwkCompositBrick class >> fromJsonFile: aFileReference [
	aFileReference asFileReference 
		readStreamDo: [ :s |
			^ self fromJsonStream: s
			 ]
]

{ #category : #'objects from disk' }
TwkCompositBrick class >> fromJsonStream: aJsonStream [
	TwkTowerKit clearInstanceMap.
	(NeoJSONReader on: aJsonStream) next
		ifNotNil: [ :map | 
			| result |
			result := map twkInstance.
			self postFixParents.
			result verify.
			^ result ].
	^ nil
]

{ #category : #'instance creation' }
TwkCompositBrick class >> fromUser [
	<script>
	self chooseProjectFile
		ifNotNil: [ :file | ^ self fromJsonFile: file ].
	^ nil
]

{ #category : #'objects from disk' }
TwkCompositBrick class >> jsonFileName [
	^  'input-data.json'
]

{ #category : #'objects from disk' }
TwkCompositBrick class >> postFixParents [
	TwkTowerKit instanceMap
		keysAndValuesDo: [ :twkUUID :twkObjectAndMap | 
			twkObjectAndMap second
				at: '_parentUUID'
				ifPresent: [ :parentUUID | 
					TwkTowerKit instanceMap
						at: parentUUID
						ifPresent: [ :parentObjectAndMap | 
							twkObjectAndMap first parent: parentObjectAndMap first ] ] ].
	TwkTowerKit instanceMap 
		valuesDo: [ :twkObjectAndMap | 
			twkObjectAndMap first postFixJsonRestore ].		
]

{ #category : #'as yet unclassified' }
TwkCompositBrick class >> projectJsonFiles [
	"self projectJsonFiles explore"
	^ TwkTowerKit defaultFolder allFiles select: [ :f | f basename sameAs: self jsonFileName ]
]

{ #category : #'as yet unclassified' }
TwkCompositBrick class >> yonaP17CreatePostsOn: brick [
	| postSpans postCrosses1 |
	postSpans := #(450 6000 6000 5500 5000 4300 3750 3000 1400 1331 2069 1400 1325 2875 1500 1750 1750 1500 1750 1750 1500 2000 1500).
	postCrosses1 := #(#empty #(#cross #midHorizontal) #(#cross #midHorizontal) #(#cross #midHorizontal) #(#cross #midHorizontal) #(#cross #midHorizontal) #(#cross #midHorizontal) #cross #upperCross #lowerCross #cross #upperCross #lowerCross #cross #downSlant #upSlant #downSlant #upSlant #downSlant #upSlant #downSlant #upSlant #downSlant).
	brick addPostNamed: 'P17'.
	brick posts
		do: [ :post | 
			post spanValues: postSpans.
			post crossValues: postCrosses1.
			post defaultPlaneRealMaterial: false.
			post realMaterial: true indexes: #(9 10 11 13 14 16 17 19 20 22 23).
			post grandSpanSize: 1.
			post verifyTotalLength: 21000.
			post faces
				do: [ :each | 
					(each)
						skipSpans: 3;
						addWidth: 7200;
						skipSpans: 5;
						addWidth: 3000;
						skipSpans: 13;
						addWidth: 1800;
						skipSpans: 8;
						yourself ] ]	"			post
				addSection: [ :section | 
					section name: 'A'.
					section crossValues: #(#cross) ].
			post
				addSection: [ :section | 
					section name: 'B'.
					section spanSplit: true.
					section crossValues: #(#diamond) ].
"	"			post sectionUsing: 'A' indexes: #(9 10 11).
			post splitIndexes: #(2).
			post spanUsing: 'B' indexes: #(2) ]."
]

{ #category : #adding }
TwkCompositBrick >> addBeam: aBeam [
	beamMap at: aBeam name put: aBeam.
	aBeam parent: self.
]

{ #category : #adding }
TwkCompositBrick >> addBeamNamed: aName [
	| beam |
	self assert: aName notNil.
	self assert: aName notEmpty.
	beam := (TwkBeam new name: aName).
	self addBeam: beam.
	^ beam.
]

{ #category : #adding }
TwkCompositBrick >> addPost: aPost [
	postMap at: aPost name put: aPost.
	aPost parent: self.
]

{ #category : #adding }
TwkCompositBrick >> addPostNamed: aName [
	| poll |
	self assert: aName notNil.
	self assert: aName notEmpty.
	poll := (TwkPost new name: aName).
	self addPost: poll.
	^ poll.
]

{ #category : #accessing }
TwkCompositBrick >> allBricks [
	^ (self posts, self beams)
]

{ #category : #accessing }
TwkCompositBrick >> beamNamed: aBeamName [
	^ beamMap at: aBeamName
	
]

{ #category : #accessing }
TwkCompositBrick >> beams [
	^ ((beamMap values select: [:each | each isValidName]) sort: [ :a :b | a number < b number ])
]

{ #category : #enumerating }
TwkCompositBrick >> beams:	aNames do: aBlock [ 
	(aNames collect: [ :each | self beamNamed: each ]) do: aBlock

]

{ #category : #actions }
TwkCompositBrick >> buildOutputFiles [
	self stanSegments.
	self fileOutForStan.
	self jsonSerializeEnabled
		ifTrue: [ self fileOutAsJson ].
	(self respondsTo: #buildDxf)
		ifTrue: [ self perform: #buildDxf ]
	
]

{ #category : #accessing }
TwkCompositBrick >> compositSpanValues [
	^ self splitedSliceHeights reversed offsetValues reversed 
]

{ #category : #testing }
TwkCompositBrick >> existsByJson [
	name ifNil: [ ^ false ].
	name ifEmpty: [ ^ false ].
	^ self jsonOutputFile isFile
]

{ #category : #testing }
TwkCompositBrick >> existsOnStorage [
	^ self existsByJson 
]

{ #category : #'objects from disk' }
TwkCompositBrick >> fileOutAsJson [
	TwkTowerKit clearInstanceMap.
	(self jsonOutputFile asFileReference)
		ensureDelete;
		mbWriteStreamDo: [ :s |
			self fileOutJsonOn: s ]
]

{ #category : #'objects from disk' }
TwkCompositBrick >> fileOutJsonOn: aWriteStream [
	(NeoJSONWriter on: aWriteStream)
		prettyPrint: true;
		nextPut: self twkJsonObject
]

{ #category : #initialization }
TwkCompositBrick >> initialize [
	super initialize.
	postMap := Dictionary new.
	beamMap := Dictionary new.	
]

{ #category : #'objects from disk' }
TwkCompositBrick >> jsonKeysForObject [
	^ super jsonKeysForObject addAll: #(postMap beamMap); yourself
]

{ #category : #'objects from disk' }
TwkCompositBrick >> jsonOutputFile [
	^ self projectFolder / self class jsonFileName
]

{ #category : #testing }
TwkCompositBrick >> jsonSerializeEnabled [
	"AdHook "
	^ false
]

{ #category : #accessing }
TwkCompositBrick >> maxPostNumber [
	^ self posts size
]

{ #category : #accessing }
TwkCompositBrick >> name: aName [
	super name: aName asUppercase
	
]

{ #category : #reporting }
TwkCompositBrick >> nodesReportData [
	^ (self posts, self beams) 
			collect: [ :p | 
				p name ->  (p stanNodes collect: [ :n | n type ]) asBag valuesAndCounts ]
]

{ #category : #accessing }
TwkCompositBrick >> postNamed: aPostName [
	^ postMap at: aPostName
	
]

{ #category : #accessing }
TwkCompositBrick >> postStartNumber [
	self posts size <= 3
		ifTrue: [  0  ]
		ifFalse: [ 1000 ]
]

{ #category : #accessing }
TwkCompositBrick >> postUnit [
	^ 100
]

{ #category : #accessing }
TwkCompositBrick >> posts [
	^ ((postMap values select: [:each | each isValidName]) sort: [ :a :b | a number < b number ])
]

{ #category : #enumerating }
TwkCompositBrick >> posts:	aNames do: aBlock [ 
	(aNames collect: [ :each | self postNamed: each ]) do: aBlock

]

{ #category : #'objects from disk' }
TwkCompositBrick >> projectFolder [
	^ (TwkTowerKit defaultFolder / self name asUppercase) ensureCreateDirectory. 
]

{ #category : #'development support' }
TwkCompositBrick >> segmentsReportData [
	^ self posts , self beams
		collect: [ :p | p name -> (p stanSegments collect: [ :n | n type ]) asBag valuesAndCounts ]
]

{ #category : #accessing }
TwkCompositBrick >> sliceValuesOfBeam [
	^ self sliceValuesOfBricks: self beams
]

{ #category : #private }
TwkCompositBrick >> sliceValuesOfBricks: aCollection [
	^ (Array streamContents: [ :s |
			aCollection do: [ :each | s nextPutAll: each sliceValues ] ])
				asSet sorted.
]

{ #category : #accessing }
TwkCompositBrick >> sliceValuesOfPost [
	^ self sliceValuesOfBricks: self posts
]

{ #category : #accessing }
TwkCompositBrick >> splitedSliceHeights [
	| heights |
	heights := OrderedCollection new.
	self posts do: [ :post |
		post faces do: [ :face |
			heights addAll: face brickStack splitedSliceHeights.
			 ]
		 ].
	heights := heights asSet asArray sort: [ :a :b  | a > b ].
	^ heights
]

{ #category : #private }
TwkCompositBrick >> splitedSliceHeightsOfBricks: aCollection [
	^ (Array streamContents: [ :s |
			aCollection do: [ :each | s nextPutAll: each splitedSliceHeights ] ])
				asSet sorted.
]

{ #category : #accessing }
TwkCompositBrick >> splitedSliceHeightsOfPosts [
	^ self splitedSliceHeightsOfBricks: self posts
]

{ #category : #actions }
TwkCompositBrick >> verify [
	doneVerify ifNil: [ doneVerify := false ].
	doneVerify ifFalse: [ self allBricks do: [ :brick | brick verify ] ].
	doneVerify := true
]
