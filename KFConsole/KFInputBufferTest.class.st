"
A GdsInputBufferTest is a test class for testing the behavior of GdsInputBuffer
"
Class {
	#name : #KFInputBufferTest,
	#superclass : #TestCase,
	#category : #'KFConsole-Tests'
}

{ #category : #tests }
KFInputBufferTest >> testAddPoint [
	| buff |
	buff := KFInputBuffer new.
	buff addString: 'CE:'.
	buff addPoint: 10 @ 20.
	self assert: buff stringContents = 'CE: 10 20'.
	buff addPoint: 30 @ 40.
	self assert: buff stringContents = 'CE: 10 20 30 40'
]

{ #category : #tests }
KFInputBufferTest >> testAddPoints [
	| buff |
	buff := KFInputBuffer new.
	buff addString: 'CE:'.
	buff
		addPoints:
			{(10 @ 20).
			(30 @ 40)}.
	self assert: buff stringContents = 'CE: 10 20 30 40'
]

{ #category : #tests }
KFInputBufferTest >> testAddString [
	| buff |
	buff := KFInputBuffer new.
	buff addString: 'baka'.
	buff addString: 'aho'.
	self assert: buff stringContents = 'bakaaho'
]

{ #category : #tests }
KFInputBufferTest >> testFoo [
	| buff morph ts ws |
	ts := TextStream with: ''.
	ws := Smalltalk tools workspace openContents: '' label: 'log'.
	ws stylingActive.
	ws toggleStylingActive.
	buff := KFInputBuffer new.
	morph := BorderedMorph new.
	morph extent: 512 @ 342.
	buff announcer
		when: KFInputBufferFlushed
		do: [ :ann | 
			self inform: ann stringContents.
			ann stringContents logCr.
			ts nextPutAll: ann stringContents.
			ts cr.
			ws contents: ts contents ].
	"morph on: #doubleClick send: #value to: [ self inform: buff stringContents ]."
	morph
		on: #mouseUp
		send: #value:
		to: [ :evt | 
			| lp |
			lp := evt position - morph innerBounds origin.
			buff addPoint: lp.
			self inform: lp asString ].
	morph on: #mouseEnter send: #value to: [ morph takeKeyboardFocus ].
	morph
		on: #keyStroke
		send: #value:
		to: [ :evt | buff addChar: evt keyCharacter ].
	morph
		on: #keyStroke
		send: #value:
		to: [ :evt | self inform: evt asString ].
	morph takeKeyboardFocus.
	morph bindKeyCombination: $q control toAction: [ :m | m delete ].
	morph announcer
		when: MorphDeleted
		do: [ (SystemWindow allInstances
				detect: [ :w | w model == ws ]
				ifNone: [ nil ]) ifNotNil: [ :win | win close ] ].
	morph openCenteredInWorld
]

{ #category : #tests }
KFInputBufferTest >> testFoo2 [
	| morph |
	morph := BorderedMorph new.
	morph extent: 512 @ 342.
	(morph embeddedInMorphicWindowLabeled: 'Test')
		ifNotNil: [ :w | 
			w bindKeyCombination: $q control toAction: [ w delete ].
			morph color: Color red lighter.
			w announcer
				on: WindowActivated
				do: [ morph takeKeyboardFocus ].
			w openInWorld ]
]

{ #category : #tests }
KFInputBufferTest >> testInsertChar [
	| buff |
	buff := KFInputBuffer new.
	buff addString: 'baka'.
	buff insertPos: 0.
	buff insertChar: $A.
	self assert: buff stringContents equals: 'Abaka'.
	buff insertPos: 1.
	buff insertChar: $K.
	self assert: buff stringContents equals: 'AKbaka'.
	buff addChar: $K.
	self assert: buff stringContents equals: 'AKbakaK'.
	buff insertPos: 0.
	buff insertChar: $U.
	buff insertChar: $n.
	buff insertChar: $k.
	buff insertChar: $o.
	self assert: buff stringContents equals: 'UnkoAKbakaK'.
	self assert: buff insertPos equals: 4.
	buff insertString: ' Warikomi '.
	self assert: buff stringContents equals: 'Unko Warikomi AKbakaK'.
	self assert: buff insertPos equals: 14.
	buff backspace.
	self assert: buff stringContents equals: 'Unko WarikomiAKbakaK'.
	self assert: buff insertPos equals: 13
]

{ #category : #tests }
KFInputBufferTest >> testPuts [
	| buff |
	buff := KFInputBuffer new.
	buff puts: 'bakaka omae'.
	buff puts: 'bakaka omae'.
	self
		assert:
			buff stringContents
				=
					'bakaka omae
bakaka omae
'
]
