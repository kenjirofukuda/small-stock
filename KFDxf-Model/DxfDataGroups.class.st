Class {
	#name : #DxfDataGroups,
	#superclass : #Object,
	#instVars : [
		'name',
		'dataGroups'
	],
	#category : #'KFDxf-Model'
}

{ #category : #adding }
DxfDataGroups >> addCode: aCode data: aData [
	self addDataGroup: (DxfDataGroup newFromCode: aCode data: aData).
]

{ #category : #adding }
DxfDataGroups >> addDataGroup: aDxfDataGroup [
	dataGroups ifNil: [ dataGroups := OrderedCollection new ].
	dataGroups add: aDxfDataGroup.
]

{ #category : #adding }
DxfDataGroups >> addDataGroupAll: aCollection [
	aCollection do: [ :each | self addDataGroup: each ]
]

{ #category : #accessing }
DxfDataGroups >> commonFlag [
	^ (self numberByNumber: 70)
		ifNil: [ 0 ]
		ifNotNil: [ :v | v ]
]

{ #category : #accessing }
DxfDataGroups >> dataGroups [
	^ dataGroups ifNil: [ dataGroups := OrderedCollection new ]
]

{ #category : #adding }
DxfDataGroups >> dataGroups: aCollection [
	dataGroups := aCollection
]

{ #category : #accessing }
DxfDataGroups >> encodedStringByNumber: aNumber [
	(self dataGroups detect: [ :each | each code = aNumber ] ifNone: [  ])
		ifNotNil: [ :group | ^ group encodedString].
	^ nil
]

{ #category : #accessing }
DxfDataGroups >> encodedStringByNumber: aNumber default: v [
	(self dataGroups detect: [ :each | each code = aNumber ] ifNone: [  ])
	ifNotNil: [ :group | ^ group encodedString].
	^ v
]

{ #category : #accessing }
DxfDataGroups >> findDataGroup: findBlock thenStreamDo: aStreamBlock [
	| s found |
	s := ReadStream on: self dataGroups.
	found := nil.
	[s atEnd or: [found notNil]]
		whileFalse: [ 
			| dataGroup |
			dataGroup := s next.
			(findBlock value: dataGroup)
				ifTrue: [ 
					aStreamBlock value: s.					
					 ].
			 ].

]

{ #category : #accessing }
DxfDataGroups >> handleNumber [
	^ self numberByNumber: 5 default: 0. 	"FIXME"
]

{ #category : #accessing }
DxfDataGroups >> handleNumber: aNumber [
	self setCode: 5 data: aNumber
]

{ #category : #'as yet unclassified' }
DxfDataGroups >> initialize [
	super initialize.
	dataGroups := nil.

]

{ #category : #accessing }
DxfDataGroups >> name [
	^ name
]

{ #category : #accessing }
DxfDataGroups >> name: aString [
	name ifNotNil: [ ^ self ].
	name := aString
]

{ #category : #accessing }
DxfDataGroups >> numberByNumber: aNumber [
	^ self numberByNumber: aNumber default: nil 
]

{ #category : #accessing }
DxfDataGroups >> numberByNumber: aNumber default: v [
	(self stringByNumber: aNumber)
		ifNotNil: [ :string | ^ string trim asNumber].
	^ v
]

{ #category : #accessing }
DxfDataGroups >> setCode: aCode data: aData [
	(self dataGroups detect: [ :g | g code = aCode ] ifNone: [  ])
		ifNotNil: [ :g | g data: aData ]
		ifNil: [ self addCode: aCode data: aData ]
]

{ #category : #'as yet unclassified' }
DxfDataGroups >> splitByCode: aCode [
	| entities ent |
	entities := OrderedCollection new.
	ent := nil.
	self dataGroups do: [ :dataGroup | 
		dataGroup code = aCode
			ifTrue: [
				ent 
					ifNotNil: [
						entities add: ent asArray.
						ent := nil ].
				 ent := OrderedCollection new.
				 ent add: dataGroup	] 
			ifFalse: [ 
				ent 
					ifNotNil: [
						ent add: dataGroup 
					 ]
				 ]
		].
	ent 
		ifNotNil: [
			entities add: ent asArray.
			ent := nil ].
	^ entities asArray

]

{ #category : #accessing }
DxfDataGroups >> stringByNumber: aNumber [
	(self dataGroups detect: [ :each | each code = aNumber ] ifNone: [  ])
		ifNotNil: [ :group | ^ group data trim].
	^ nil
]

{ #category : #accessing }
DxfDataGroups >> stringByNumber: aNumber default: v [
	(self dataGroups detect: [ :each | each code = aNumber ] ifNone: [  ])
		ifNotNil: [ :group | ^ group data trim].
	^ v
]
