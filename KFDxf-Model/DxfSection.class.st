Class {
	#name : #DxfSection,
	#superclass : #DxfDataGroups,
	#instVars : [
		'stream',
		'table',
		'ent',
		'tables',
		'shapes'
	],
	#category : #'KFDxf-Model'
}

{ #category : #accessing }
DxfSection >> accadver [
	(self name sameAs: 'HEADER')
		ifFalse: [ ^ '' ].
	self 
		findDataGroup: [ :dataGroup | dataGroup asArray = #(9 '$ACADVER') ] 
		thenStreamDo: [ :s | ^ s next data ].
	^ nil
]

{ #category : #action }
DxfSection >> clearShapes [
	shapes := nil.
]

{ #category : #initialization }
DxfSection >> initialize [
	super initialize.
	name := nil.
]

{ #category : #accessing }
DxfSection >> lookupShapes [
	| activeShape |
	activeShape := nil.
	^ Array
		streamContents: [ :arrayStream | 
			self splitEntities
				do: [ :each | 
					| className |
					className := ('Dxf' , each first data asLowercase capitalized)
						asSymbol.
					(Smalltalk at: className ifAbsent: [ nil ])
						ifNotNil: [ :clazz | 
							activeShape := clazz new
								addDataGroupAll: each;
								yourself.
							arrayStream nextPut: activeShape ]
						ifNil: [ (className , ': Not Found') traceCr.
							activeShape ifNotNil: [ activeShape addDataGroupAll: each ] ] ] ]
]

{ #category : #accessing }
DxfSection >> lookupTables [
	^ self splitByTable collect: [ :each | 
		| t | 
		t := DxfTable new.
		t dataGroups: each.
		t
		 ]
]

{ #category : #printing }
DxfSection >> printOn: aStream [
	super printOn: aStream.
	aStream nextPut: $(.
	self name printOn: aStream.
	aStream nextPut: $).
	
]

{ #category : #accessing }
DxfSection >> shapes [
	^ shapes ifNil: [ shapes := self lookupShapes ]
]

{ #category : #'as yet unclassified' }
DxfSection >> splitByTable [
	| entities ent |
	entities := OrderedCollection new.
	ent := nil.
	self dataGroups do: [ :dataGroup | | handled |
		handled := false.
		dataGroup isBeginTable
			ifTrue: [
				ent := OrderedCollection new.
				handled := true]. 
		dataGroup isEndTable
			ifTrue: [
				ent 
					ifNotNil: [
						entities add: ent asArray.
						ent := nil ].
				handled := true]. 
		handled 
			ifFalse: [ 
				ent 
					ifNotNil: [
						ent add: dataGroup 
					 ]
				 ]
		].
	^ entities asArray

]

{ #category : #'as yet unclassified' }
DxfSection >> splitEntities [
	^ self splitByCode: 0
]

{ #category : #accessing }
DxfSection >> tableNamed: aString [
	^ self tables detect: [ :section | section name sameAs: aString ] ifNone: [  ] 
]

{ #category : #accessing }
DxfSection >> tables [
	^ tables ifNil: [ tables := self lookupTables ]
]
