Class {
	#name : #HikiPage,
	#superclass : #Object,
	#instVars : [
		'file',
		'space',
		'matcherMap',
		'inEscape',
		'tableCount',
		'site'
	],
	#category : #'Hiki-Core'
}

{ #category : #accessing }
HikiPage >> attachedCount [
	self attachedFolder exists ifFalse: [ ^ 0 ].
	^ self attachedFolder children size	
]

{ #category : #inspector }
HikiPage >> attachedCountString [
	| count|
	count := self attachedCount .
	^ count = 0 ifTrue: [ ' ' ] ifFalse: [ count asString ]
]

{ #category : #'accessing - folder' }
HikiPage >> attachedFolder [
	^ self site attachedFolder / self encodedName
]

{ #category : #'accessing - contents' }
HikiPage >> contents [
	^ HikiSite contentsOfFile: self file encoding: self encoding 
]

{ #category : #'accessing - contents' }
HikiPage >> contentsEndWithEmptyLine [
	^ self contents lines, #('')
]

{ #category : #inspector }
HikiPage >> contentsForInspector [
	^ String
		streamContents: [ :s | 
			s nextPutAll: self decordedFileName.
			s cr.
			s cr.
			s nextPutAll: self contents ]
]

{ #category : #conversions }
HikiPage >> decodePercent: aString [
	^ (HikiSite decodePercentAsByteArray: aString)
		asString convertFromEncoding: self encoding
]

{ #category : #accessing }
HikiPage >> decordedFileName [
	^ self decodePercent: self encodedName
]

{ #category : #accessing }
HikiPage >> encodedName [
	^ self file basename
]

{ #category : #accessing }
HikiPage >> encoding [
	^ 'euc-jp'
]

{ #category : #accessing }
HikiPage >> file [
	^ file
]

{ #category : #initialization }
HikiPage >> file: aFile [
	file := aFile asFileReference
]

{ #category : #inspector }
HikiPage >> gtInspectorHikiPageAsMarkdownIn: composite [
	<gtInspectorPresentationOrder: 110>
	composite text
		title: 'Markdown'; 
		display: self markdownContents
]

{ #category : #inspector }
HikiPage >> gtInspectorHikiPageAttachedIn: composite [
	<gtInspectorPresentationOrder: 100>
	self attachedFolder exists
		ifTrue: [ 
			| result |
			result := self attachedFolder gtInspectorItemsIn: composite.
			result title: 'Attached'.
			^ result ]	"^ composite text 
		title: 'Attached';
		display: [ '']
		"
]

{ #category : #inspector }
HikiPage >> gtInspectorHikiPageIn: composite [
	<gtInspectorPresentationOrder: 100>
	composite text
		title: 'Hiki'; 
		display: self contents
]

{ #category : #'format converter' }
HikiPage >> handleHeading: aString [
	| m mark rest|
	m := matcherMap at: aString first.
	(m matches: aString) ifFalse: [ ^ nil ]. 
	mark := m subexpression: 2.
	rest := m subexpression: 3.
	^ (String new: mark size withAll: $#), ' ', rest
]

{ #category : #'format converter' }
HikiPage >> handleHorizontalLine: aString [
	^ String
		streamContents: [ :s | 
			s cr.
			s nextPutAll: aString ]
]

{ #category : #'format converter' }
HikiPage >> handleNonEmpty: aString [
	(aString beginsWith: '<<<')
		ifTrue: [  
			inEscape := true.
			^ aString copyReplaceAll: '<<<' with: (String cr, '```') ].
	(aString beginsWith: '>>>')
		ifTrue: [ 
			inEscape := false.
			^ aString copyReplaceAll: '>>>' with: ('```', String cr) ].
	inEscape  ifTrue: [ ^ nil ].	
	(aString beginsWith: '!')
		ifTrue: [ 
			(self handleHeading: aString)
				ifNotNilDo: [ :line |  ^ line ] ].
				
	(aString beginsWith: '*')
		ifTrue: [ 
			(self handleUnordered: aString)
				ifNotNilDo: [ :line |  ^ line ] ].

	(aString beginsWith: '#')
		ifTrue: [
			(self handleOrdered: aString)
				ifNotNilDo: [ :line |  ^ line ] ].

	(aString beginsWith: '|')
		ifTrue: [ 
			(self handleTable: aString)
				ifNotNilDo: [ :line |  ^ line ] ].
	(aString beginsWith: '-')
		ifTrue: [ 
			(self handleHorizontalLine: aString)
				ifNotNilDo: [ :line |  ^ line ] ].
	^ nil
]

{ #category : #'format converter' }
HikiPage >> handleOrdered: aString [
	| m mark rest|
	m := matcherMap at: aString first.
	(m matches: aString) ifFalse: [ ^ nil ]. 
	mark := m subexpression: 2.
	rest := m subexpression: 3.
	^ (String new: (mark size  - 1) withAll: Character tab), '1. ', rest	
]

{ #category : #'format converter' }
HikiPage >> handleTable: aString [
	| result1 itemCount |
	tableCount := tableCount + 1.
	result1 := aString copyReplaceAll: '||' with: '|'.
	tableCount = 1		
		ifFalse: [ ^ result1 ].
	itemCount := (result1 findTokens: '/') size + 1.
	^ String
		streamContents: [ :s | 
			s nextPutAll: result1.
			s cr.
			itemCount timesRepeat: [ s nextPutAll: '|----' ] ]
]

{ #category : #'format converter' }
HikiPage >> handleUnordered: aString [
	|  mark rest s ch |
	mark := ''.
	s := ReadStream on: aString.
	[ch := s next.
	ch  = $* ] 
		whileTrue: [mark := mark, {ch}].
	rest := ch asString, s upToEnd.
	^ (String new: (mark size  - 1) withAll: Character tab), '* ', rest		
]

{ #category : #initialization }
HikiPage >> initialize [
	super initialize.
	matcherMap := Dictionary new.
	inEscape := false.
	tableCount := 0.
	matcherMap at: $! put: '(!+)([^!]*)' asRegex.
	matcherMap at: $# put: '(#+)([^#]*)' asRegex.	
	"matcherMap at: $* put: '(:isStar:+)([^:isStar:]*)' asRegex.	"
	
]

{ #category : #'accessing - contents' }
HikiPage >> markdownContents [
	^ String cr join: ((self contentsEndWithEmptyLine) collect: [ :line | self toMarkdown: line ])
]

{ #category : #accessing }
HikiPage >> name [
	^ self decordedFileName

]

{ #category : #'accessing - contents' }
HikiPage >> parserContents [
	self parserFile
		readStreamDo: [ :s | 
			s binary.
			s upTo: ($< asciiValue). 	" (60 = $<) skip Ruby marshal with Date"
			s skip: -1.
			s text.
			s converter: (TextConverter newForEncoding: self encoding).
			^ s upToEnd ]
]

{ #category : #'accessing - folder' }
HikiPage >> parserFile [
	^ self site parserFolder / self encodedName
]

{ #category : #printing }
HikiPage >> printOn: aStream [
	self decordedFileName printOn: aStream
]

{ #category : #dependencies }
HikiPage >> release [
	site := nil.
	super release
	
]

{ #category : #accessing }
HikiPage >> site [
	^ site
	
]

{ #category : #initialization }
HikiPage >> site: aHikiSite [
	site := aHikiSite
	
]

{ #category : #'format converter' }
HikiPage >> toMarkdown: aString [
	| result |
	space ifNil: [ space := 0 ].
	result := aString.
	aString notEmpty
		ifTrue: [ 
			((aString beginsWith: ' ') and: [ inEscape not ])
				ifTrue: [ 
					result := self trimFirst: result.
					space = 0
						ifTrue: [ result := String cr , '```' , String cr , result ].
					space := space + 1.
					^ result ].
			(self handleNonEmpty: aString) ifNotNilDo: [ :line | result := line ] ].
	space > 0
		ifTrue: [ 
			result := self trimFirst: result.
			result := String cr , '```' , String cr , result.
			space := 0 ].
	(result beginsWith: '|')
		ifFalse: [ 
			tableCount := 0 ].
	^ result
]

{ #category : #'format converter' }
HikiPage >> trimFirst: aString [
	inEscape ifTrue: [ ^ aString ].
	aString ifEmpty: [ ^ aString ].
	aString first = Character space ifFalse: [ ^ aString] .
	^  aString allButFirst

]
