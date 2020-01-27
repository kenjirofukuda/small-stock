Class {
	#name : #TwkMaterialResitory,
	#superclass : #TwkNode,
	#instVars : [
		'defaultMaterials',
		'entries'
	],
	#category : #'TowerKit-Core'
}

{ #category : #'accessing - materials' }
TwkMaterialResitory >> defaultMaterial: aMaterialName [
	defaultMaterials := self ensureCollection: aMaterialName.
	
]

{ #category : #initialization }
TwkMaterialResitory >> initialize [
	super initialize.
	entries := OrderedCollection new.
]

{ #category : #'accessing - materials' }
TwkMaterialResitory >> material: aMaterialName at: aSymbol depthIndexes: aNumberCollection [
	self material: aMaterialName at: aSymbol indexes: aNumberCollection indexType: #depth
]

{ #category : #'accessing - materials' }
TwkMaterialResitory >> material: aMaterialName at: aSymbol indexes: aNumberCollection [
	self material: aMaterialName at: aSymbol indexes: aNumberCollection indexType: #plane

]

{ #category : #'as yet unclassified' }
TwkMaterialResitory >> material: aMaterialName at: aSymbol indexes: aNumberCollection indexType: aTypeSymbol [
	| entry |
	entry := IdentityDictionary new.
	entry at: #materials put: (self ensureCollection: aMaterialName).
	entry at: #at put: (self ensureCollection: aSymbol).
	entry at: #indexes put: (self ensureCollection: aNumberCollection).
	entry at: #indexType put: aTypeSymbol.
	entries add: entry.
	
	
]

{ #category : #'as yet unclassified' }
TwkMaterialResitory >> splitMaterialName: aMaterialName [
	| matcher |
	(aMaterialName trim allRegexMatches: '(^\d+)')
		ifNotEmpty: [ :col | 
			^ Array
				with: (aMaterialName allButFirst: col anyOne size)
				with: col anyOne
				with: #member ].
	matcher := RxMatcher forString: '^\-(\d+)$'.
	(matcher matches: aMaterialName)
		ifTrue: [ ^ Array with: '' with: (matcher subexpression: 2) with: #bolt ].
	(aMaterialName trim findTokens: '-')
		ifNotEmpty: [ :col | 
			col size >= 2
				ifTrue: [ ^ Array
						with: ((col copyFrom: 1 to: col size - 1) joinUsing: '-')
						with: col last
						with: #bolt ] ].
	^ Array with: aMaterialName trim with: '1' with: #unkown
]
