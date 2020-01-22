Class {
	#name : #DxfTable,
	#superclass : #DxfDataGroups,
	#instVars : [
		'layers',
		'lineTypes'
	],
	#category : #'KFDxf-Model'
}

{ #category : #accessing }
DxfTable >> dataGroups: aCollection [
	(aCollection detect: [ :each | each code = 2 ] ifNone: [  ])
		ifNotNil: [:group | self name: group data trim].
	super dataGroups: aCollection
]

{ #category : #accessing }
DxfTable >> layers [
	^ layers ifNil: [ layers := self splitAsLayer ]
]

{ #category : #accessing }
DxfTable >> lineTypes [
	^ lineTypes  ifNil: [ lineTypes := self splitAsLinetype ]
]

{ #category : #printing }
DxfTable >> printOn: aStream [
	super printOn: aStream.
	self name ifNil: [ ^ self ].
	aStream nextPut: $(.
	self name printOn: aStream.
	aStream nextPut: $).
	
]

{ #category : #'as yet unclassified' }
DxfTable >> splitAsClass: aClass [
	| entities ent |
	entities := OrderedCollection new.
	ent := nil.
	self dataGroups do: [ :each | | handled |
		 handled := false.
		(each code = 0 and: [ self name sameAs: each data trim ])
			ifTrue: [ 
				ent 
					ifNotNil: [ 
						entities add: ent. 
						ent := nil ].
				ent 
					ifNil: [ 
						ent := aClass new. 
						ent addDataGroup: each ].
				handled := true].
		(ent notNil and: [handled not ])
			ifTrue: [ ent addDataGroup: each ].
		].
	ent 
		ifNotNil: [ 
			entities add: ent ]. 
	^ entities asArray 
]

{ #category : #'as yet unclassified' }
DxfTable >> splitAsLayer [
	^ self splitAsClass: DxfLayer.
]

{ #category : #'as yet unclassified' }
DxfTable >> splitAsLinetype [
	^ self splitAsClass: DxfLinetype
]

{ #category : #'as yet unclassified' }
DxfTable >> splitEntities [
	^ self splitAsClass: DxfDataGroups.
]
