Trait {
	#name : #THTML5Enabler,
	#category : #'KFSeaside-Components'
}

{ #category : #'accessing method dictionary' }
THTML5Enabler classSide >> addAndClassifySelector: selector withMethod: compiledMethod inProtocol: aCategory [
	"When a new methods is added, I add it to the localMethodDict and also propagate the changes to my users"

	self localMethodDict at: selector put: compiledMethod.
	super
		addAndClassifySelector: selector
		withMethod: compiledMethod
		inProtocol: aCategory.
	TraitChange addSelector: selector on: self
]

{ #category : #'accessing method dictionary' }
THTML5Enabler classSide >> addSelector: selector withMethod: compiledMethod [
	"When a new selector is installed in a class I insert the selector in the local methodDict and propagate the changes to my users"

	self localMethodDict at: selector put: compiledMethod.
	super addSelector: selector withMethod: compiledMethod.
	TraitChange addSelector: selector on: self
]

{ #category : #'accessing method dictionary' }
THTML5Enabler classSide >> addSelector: selector withMethod: compiledMethod notifying: requestor [
	self
		deprecated: 'Please use #addSelector:withMethod: instead'
		transformWith:
			'`@receiver addSelector: `@statements1 withMethod: `@statements2 notifying: `@statements3'
				-> '`@receiver addSelector: `@statements1 withMethod: `@statements2'.
	^ self addSelector: selector withMethod: compiledMethod
]

{ #category : #initialization }
THTML5Enabler classSide >> doRebuildMethodDictionary [
	| selectors removedSelectors removeFromOrganization modified |
	"During the creation of the class or after a change in the traitComposition, the whole method dictionary is calculated.
	If I return true, my users should be updated"
	"1. I recreate the local methodDict"
	modified := false.
	self methodDict
		valuesDo:
			[ :m | m traitSource ifNil: [ self localMethodDict at: m selector put: m ] ].

	"2. I filter the selectors from the trait composition, rejecting the ones that are locally defined.
	And then I install the methods in myself. The trait composition only install the method if it is needed."
	selectors := self traitComposition selectors
		reject: [ :e | self localMethodDict includesKey: e ].
	selectors
		do: [ :e | 
			modified := modified
				| (self traitComposition installSelector: e into: self replacing: false) ].

	"3. I handle the methods that I have and they are no more in the traitComposition."
	removedSelectors := self methodDict keys
		reject: [ :aSelector | 
			(selectors includes: aSelector)
				or: [ self localMethodDict includesKey: aSelector ] ].
	modified := modified | removedSelectors isNotEmpty.
	removedSelectors
		do: [ :aSelector | self methodDict removeKey: aSelector ].

	"4. Finally, I remove these methods from my class organization"
	removeFromOrganization := self organization allMethodSelectors
		reject: [ :e | self methodDict includesKey: e ].
	removeFromOrganization
		do: [ :aSelector | self organization removeElement: aSelector ].
	^ modified
]

{ #category : #testing }
THTML5Enabler classSide >> findOriginClassOf: aMethod [
	"I return the myself or the trait that has the original implementation of a method.
	If the method is an alias, the returned class includes the original aliased method"

	(aMethod hasProperty: #traitSource)
		ifTrue: [ ^ aMethod traitSource innerClass ].
	(self includesLocalSelector: aMethod selector)
		ifTrue: [ ^ self ].
	^ (self traitComposition
		traitDefining: aMethod selector
		ifNone: [ ^ self ]) innerClass
]

{ #category : #testing }
THTML5Enabler classSide >> findOriginMethodOf: aMethod [
	"I return the original method for a aMethod.
	If this is a local method, the original method is itself.
	If it cames from a trait composition I look for the method in the trait composition.
	First I try with the trait stored in the traitSource. 
	If it is an aliased or conflicting method, the method is look up in the whole trait composition"

	(self includesLocalSelector: aMethod selector)
		ifTrue: [ ^ aMethod ].
	(aMethod hasProperty: #traitSource)
		ifTrue: [ | newSelector |
			newSelector := self traitComposition
				originSelectorOf: aMethod selector.
			^ aMethod traitSource
				compiledMethodAt: newSelector
				ifAbsent: [ aMethod ] ].
	^ (self traitComposition
		traitDefining: aMethod selector
		ifNone: [ self ])
		compiledMethodAt: aMethod selector
		ifAbsent: [ ^ aMethod ]
]

{ #category : #testing }
THTML5Enabler classSide >> hasTraitComposition [
	^ self traitComposition isEmpty not
]

{ #category : #testing }
THTML5Enabler classSide >> isLocalMethodsProtocol: aProtocol [
	"Checks if the protocol has local selectors"

	aProtocol methods ifEmpty: [ ^ true ].
	^ aProtocol methods
		anySatisfy: [ :each | self isLocalSelector: each ]
]

{ #category : #testing }
THTML5Enabler classSide >> isLocalSelector: aSelector [
	^ self localMethodDict includesKey: aSelector
]

{ #category : #accessing }
THTML5Enabler classSide >> localMethodDict [
	"The local methodDict is in the metaclass. In this way I do not have to recompile the methods during the bootstrap when we don't have a compiler."

	^ self class baseLocalMethods
]

{ #category : #accessing }
THTML5Enabler classSide >> localMethodDict: aMethodDictionary [
	^ self class baseLocalMethods: aMethodDictionary
]

{ #category : #accessing }
THTML5Enabler classSide >> localMethods [
	"returns the methods of classes excluding the ones of the traits that the class uses"

	^ self localMethodDict values
]

{ #category : #'accessing method dictionary' }
THTML5Enabler classSide >> localSelectors [
	^ self localMethodDict keys
]

{ #category : #categories }
THTML5Enabler classSide >> recategorizeSelector: selector from: oldCategory to: newCategory [
	| original |
	"When a method is recategorized I have to classify the method, but also recategorize the aliases pointing to it"
	original := self organization
		categoryOfElement: selector
		ifAbsent: [ ^ self ].

	"If it is nil is because it is a removal. It will removed when the method is removed."
	newCategory ifNil: [ ^ self ].
	original = oldCategory
		ifTrue: [ self organization
				classify: selector
				under: newCategory
				suppressIfDefault: true ].
	(self traitComposition reverseAlias: selector)
		do: [ :e | 
			self recategorizeSelector: e from: oldCategory to: newCategory.
			self
				notifyOfRecategorizedSelector: e
				from: oldCategory
				to: newCategory ].
	self organization removeEmptyCategories
]

{ #category : #'trait-composition' }
THTML5Enabler classSide >> removeFromComposition: aTrait [
	self
		setTraitComposition: (self traitComposition copyWithoutTrait: aTrait asTraitComposition)
]

{ #category : #removing }
THTML5Enabler classSide >> removeSelector: aSelector [
	"When a selector is removed it should be notified to my users.
	Check the class TraitChange for more details"

	super removeSelector: aSelector.
	self localMethodDict removeKey: aSelector ifAbsent: [  ].
	TraitChange removeSelector: aSelector on: self
]

{ #category : #'accessing tags' }
THTML5Enabler classSide >> tagsForMethods [
	"Any method could be tagged with multiple symbols for user purpose. 
	And class contains all method tags which used or not used yet by methods.
	For now we could only implemented it on top of Protocol. 
	It supposed to not include any method tags inherited from Traits 
	which is opposite to current Protocol implementation.
	And extension protocol is not treated as tag"

	| allProtocols |
	allProtocols := self organization protocols
		reject:
			[ :each | each name = Protocol unclassified | each isExtensionProtocol ].
	^ allProtocols
		select: [ :each | self isLocalMethodsProtocol: each ]
		thenCollect: #name
]

{ #category : #accessing }
THTML5Enabler classSide >> traitComposition [
	"My trait composition is in my class. So I do not need to recompile the methods when installing them during bootstrap"

	^ self class baseComposition
]

{ #category : #accessing }
THTML5Enabler classSide >> traitComposition: anObject [
	self class baseComposition: anObject
]

{ #category : #accessing }
THTML5Enabler classSide >> traits [
	^ self traitComposition traits
]

{ #category : #rendering }
THTML5Enabler >> rendererClass [
	^ KFWAHtmlCanvas
]
