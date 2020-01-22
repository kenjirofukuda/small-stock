Class {
	#name : #GplDataExtent,
	#superclass : #GplSingleHandler,
	#category : #'GdsFeel-CLI-Commands'
}

{ #category : #testing }
GplDataExtent class >> isFunctionAllowed [
	^true.
]

{ #category : #testing }
GplDataExtent class >> isNiladicAllowed [
	^true.
	
]

{ #category : #accessing }
GplDataExtent class >> methodName [
	^'DATAEXTENT'
]

{ #category : #handler }
GplDataExtent >> evaluateToken: aToken [ 
	| numArgs |
	self mustStructureOpen.
	numArgs := evaluator numArgs: aToken.
	('numPushd: <1p><n> numReturn: <2p><n> notConsumedTokens: <3p><n>' 
		expandMacrosWithArguments: 
			{ evaluator numPushed . evaluator numReturn: aToken .  evaluator notConsumedTokens: aToken}) traceCr.
	numArgs = 0
		ifTrue: [
			^self fullExtent].
	^self keysExtent.
	
	
]

{ #category : #handler }
GplDataExtent >> fullExtent [
	self structure liveElements
		ifEmpty: [^self nullVector].
	^GdsMatrix fromRectangle:  self structure dataExtentForElements.
	
]

{ #category : #handler }
GplDataExtent >> keysExtent [
	| gv1 smVec elements errorKeys smBounds |
	gv1 := evaluator popArg asGplValue.
	smVec := gv1 asVector asSmalltalkValue.
	elements := OrderedCollection new.
	errorKeys := OrderedCollection new.
	self 
		keyNumbers: smVec 
		doWithElement: [:key :element| 
			element
				ifNil: [errorKeys add: key]
				ifNotNil: [elements add: element]].
	self illigalKeyNumbers: errorKeys.
	elements ifEmpty: [^self nullVector].
	smBounds := self structure 
		lookupDataExtentForElementsChooserBlock: [:element |
			elements includes: element].
	^GdsMatrix fromRectangle: smBounds. 
	
]
