Class {
	#name : #GdsOldTestCase,
	#superclass : #TestCase,
	#category : #'GdsFeel-Model-Tests'
}

{ #category : #accessing }
GdsOldTestCase >> sampleLibrary [
	GdsStation default libraries
		ifNotEmpty: [ :libs | 
			(libs detect: [ :lib | lib name sameAs: 'BGHIER' ] ifNone: [ nil ])
				ifNotNil: [ :lib | ^ lib ]
				ifNil: [ ^ libs first ] ].
	^ nil
]

{ #category : #accessing }
GdsOldTestCase >> sampleStructure [
	self sampleLibrary
		ifNotNil: [ :lib | 
			lib structures
				ifNotEmpty: [ :structures | 
					(structures detect: [ :s | s name sameAs: 'BANDGAP' ] ifNone: [ nil ])
						ifNotNil: [ :s | ^ s ].
					^ structures first ] ].
	^ nil
]

{ #category : #accessing }
GdsOldTestCase >> setUp [
	super setUp.
	(Smalltalk at: #GdsInform ifAbsent: [ nil ])
		ifNotNil: [ :clazz | 
			(GdsFeel projectDirectory / 'BGHIER.DB') isFile
				ifFalse: [ clazz makeGDSreaderSample ] ]
]

{ #category : #tests }
GdsOldTestCase >> structureDTD [
	^GdsStructure dtd.
]
