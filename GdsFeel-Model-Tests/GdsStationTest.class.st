"
A GdsStationTest is a test class for testing the behavior of GdsStation
"
Class {
	#name : #GdsStationTest,
	#superclass : #GdsOldTestCase,
	#category : #'GdsFeel-Model-Tests'
}

{ #category : #tests }
GdsStationTest >> testDefault [

	GdsStation default inspect.
]

{ #category : #'tests-private' }
GdsStationTest >> testFileMap [
	GdsStation default fileMap keys allSatisfy: [ :f | f isFile ]. 
	GdsStation default fileMap values allSatisfy: [ :lib | lib isKindOf: GdsLibrary ]. 	
]

{ #category : #tests }
GdsStationTest >> testLibraries [

	self assert: GdsStation default libraries notEmpty.
	UIManager default chooseFrom:
		(GdsStation default libraries collect: [ :l | l name ])
]

{ #category : #'tests-accessing' }
GdsStationTest >> testLibrary [
	| changeCount reciever |
	self assert: self sampleLibrary notNil.
	self assert: (self sampleLibrary libName sameAs: 'BGHIER').
	GdsStation default library: nil.
	changeCount := 0.
	reciever := [ changeCount := changeCount + 1.
	self inform: GdsStation default library libName ].
	GdsStation default announcer
		when: #libraryChanged
		send: #value
		to: reciever.
	GdsStation default libraries
		do: [ :lib | GdsStation default library: lib ].
	self assert: GdsStation default libraries size equals: changeCount.
	GdsStation default announcer unsubscribe: reciever
]

{ #category : #'tests-accessing' }
GdsStationTest >> testStructure [

	| changeCount reciever |
	changeCount := 0.
	GdsStation default library: nil.
	reciever := [ 
	            changeCount := changeCount + 1.
	            GdsStation default structure 
						ifNotNil: [ : struc |
							self inform: struc name ] ].
	GdsStation default announcer
		when: #structureChanged
		send: #value
		to: reciever.
	GdsStation default
		openLibraryNamed: 'BGHIER.DB'
		during: [ :library | 
			library structures do: [ :structure | 
				GdsStation default structure: structure ].
			self assert: library structures size equals: changeCount.
			library autoAllocateLayerColors ].
	GdsStation default library: nil.
	GdsStation default structure: nil.
	GdsStation default announcer unsubscribe: reciever
]

{ #category : #'tests-accessing' }
GdsStationTest >> testStructure2 [

	| changeCount reciever |
	changeCount := 0.
	GdsStation default library: nil.
	reciever := [ 
	            changeCount := changeCount + 1.
	            GdsStation default structure 
						ifNotNil: [ : struc |
							self inform: struc name ] ].

	GdsStation default announcer
		when: GdsStructureActivated  
		send: #value
		to: reciever.
		
	GdsStation default
		openLibraryNamed: 'BGHIER.DB'
		during: [ :library | 
			library structures do: [ :structure | 
				GdsStation default structure: structure ].
			self assert: library structures size equals: changeCount.
			library autoAllocateLayerColors ].

	GdsStation default library: nil.
	GdsStation default structure: nil.
	GdsStation default announcer unsubscribe: reciever
]
