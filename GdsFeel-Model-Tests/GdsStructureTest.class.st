"
A GdsStructure2Test is a test class for testing the behavior of GdsStructure2
"
Class {
	#name : #GdsStructureTest,
	#superclass : #GdsOldTestCase,
	#category : #'GdsFeel-Model-Tests'
}

{ #category : #tests }
GdsStructureTest >> testCopy [
	| src dest |
	GdsStation default structure
		ifNotNil: [ :s | 
			src := s.
			dest := s copy.
			self assert: src ~~ dest.
			self
				assert: (src instVarNamed: 'elements') ~~ (dest instVarNamed: 'elements').
			src elements
				doWithIndex:
					[ :each :index | self assert: each ~~ (dest elements at: index) ] ]
]

{ #category : #'tests-copying' }
GdsStructureTest >> testDuplicate [
	| src dest |
	GdsStation default structure
		ifNotNil: [ :s | 
			src := s.
			dest := s duplicate.
			self assert: src ~~ dest.
			self
				assert: (src instVarNamed: 'elements') ~~ (dest instVarNamed: 'elements').
			src elements
				doWithIndex:
					[ :each :index | self assert: each ~~ (dest elements at: index) ] ]
]

{ #category : #'tests-accessing' }
GdsStructureTest >> testElements [

	self sampleStructure elements inspect
]

{ #category : #tests }
GdsStructureTest >> testFoo [
	(XMLDOMParser parse:  (self sampleStructure latestContents)) explore.

]

{ #category : #tests }
GdsStructureTest >> testFoo2 [
	| doc contents |

	contents := String streamContents: [ :s |
		s << GdsStructure dtd.
		s << self sampleStructure latestContents.
		].	
	doc := XMLDOMParser parse:  contents.
	doc traceCr.

]

{ #category : #tests }
GdsStructureTest >> testIsOpen [

	self 
		assert: self sampleLibrary isOpen 
		equals: (self sampleLibrary structures allSatisfy: [ :s | s isOpen ]). 

]

{ #category : #tests }
GdsStructureTest >> testLatestContents [
	self assert: (self sampleStructure latestContents notNil ).
	self assert: (self sampleStructure latestContents isString) .
	self assert: (self sampleStructure latestContents notEmpty) .
	self assert: (self sampleStructure latestContents beginsWith: '<?xml').
	self assert: (self sampleStructure latestContents endsWith: '</structure>').	
]

{ #category : #tests }
GdsStructureTest >> testLatestFile [
	self sampleLibrary isOpen
		ifFalse: [
			self sampleLibrary extract].
	self sampleStructure latestFile traceCr.
	self assert: self sampleStructure latestFile notNil. 
	self assert: (self sampleStructure latestFile isKindOf: FileReference). 
	self assert: self sampleStructure latestFile isFile. 

]

{ #category : #tests }
GdsStructureTest >> testLatestZipMemberName [

	| exString |
	exString := String streamContents: [:s |
		s << self sampleStructure name.
		s << '\.structure\/'.
		s << self sampleStructure name.
		s << '\.(\d+)\.gdsfeelbeta']. 
	self assert: (self sampleStructure latestZipMemberName matchesRegex: exString).	
	self sampleStructure latestZipMemberName traceCr.
]

{ #category : #'tests-initialize-release' }
GdsStructureTest >> testLibrary [
	"library: only set once."
	self should:  [self sampleStructure library: self sampleLibrary] raise: Exception.
	
]

{ #category : #tests }
GdsStructureTest >> testMemberFiles [
	"self sampleStructure memberFiles explore"

	self
		assert:
			(self sampleStructure memberFiles
				allSatisfy: [ :each | 
					(each isKindOf: FileReference)
						and: [ each isFile and: [ each extension sameAs: 'gdsfeelbeta' ] ] ])
]

{ #category : #tests }
GdsStructureTest >> testMemberMatcher [
	| m |
	m := self sampleStructure memberMatcher: 'AIUEO.1.gdsfeelbeta'.
	self assert: m notNil.
	self assert: 4 equals: m subexpressionCount.
	self assert: 'AIUEO.1.gdsfeelbeta' equals: (m subexpression: 1).
	self assert: 'AIUEO' equals: (m subexpression: 2).	
	self assert: '1' equals: (m subexpression: 3).

	m := self sampleStructure memberMatcher: 'AIUEO..gdsfeelbeta'.
	self assert: m isNil.

	m := self sampleStructure memberMatcher: 'AIUEO.*.gdsfeelbeta'.
	self assert: m isNil.

	m := self sampleStructure memberMatcher: '...1.gdsfeelbeta'.
	self assert: m isNil.

	m := self sampleStructure memberMatcher: '.1.gdsfeelbeta'.
	self assert: m isNil.

	m := self sampleStructure memberMatcher: 'AIUEO.-1.gdsfeelbeta'.
	self assert: m isNil.	
	
	m := self sampleStructure memberMatcher: 'AIUEO.1.gdsfeel'.
	self assert: m isNil.	
]

{ #category : #'tests-initialize-release' }
GdsStructureTest >> testName [
	self should:  [self sampleStructure name: 'sample illigal name'] raise: Exception.
	self assert: (self sampleStructure name isString).
]

{ #category : #tests }
GdsStructureTest >> testRelativeDirectoryName [
	self sampleStructure relativeDirectoryName traceCr.
	self sampleLibrary zipArchiveDo: [ :zip | 
		self assert: (zip memberNames 
			includes: (self sampleStructure relativeDirectoryName, '/'))]
]

{ #category : #tests }
GdsStructureTest >> testRevisonOfName [
	self assert: 1 equals: (self sampleStructure revisonOfName: 'AIUEO1.1.gdsfeelbeta').
	self assert: 99 equals: (self sampleStructure revisonOfName: 'AIUEO1.99.gdsfeelbeta').
	
	"only positive number"
	self assert: (self sampleStructure revisonOfName: 'AIUEO1.-1.gdsfeelbeta') < 0.	
	
	"must gdsfeelbeta"
	self assert: (self sampleStructure revisonOfName: 'AIUEO1.1.gdsfeel') < 0.	

	"format error"
	self assert: (self sampleStructure revisonOfName: '..1.gdsfeelbeta') < 0.		
]

{ #category : #tests }
GdsStructureTest >> testZipMemberNames [
	self assert: (self sampleStructure zipMemberNames isCollection).
	
	self assert: ((self sampleStructure zipMemberNames) 
							allSatisfy: [ :name | name isString ]).
							
	self sampleStructure zipMemberNames traceCr.
]
