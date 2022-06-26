Class {
	#name : #GplSyntaxComponent,
	#superclass : #GplFamilyComponent,
	#instVars : [
		'expression',
		'parser',
		'parseResult',
		'searcher',
		'debugResult',
		'filteredResults'
	],
	#category : #'GdsFeel-Seaside-Gpl'
}

{ #category : #'as yet unclassified' }
GplSyntaxComponent class >> handlerName [
	^ 'gds/gpl-syntax'
]

{ #category : #'as yet unclassified' }
GplSyntaxComponent class >> initialize [
	"self initialize."

	^ WAAdmin register: self asApplicationAt: self handlerName
]

{ #category : #'as yet unclassified' }
GplSyntaxComponent >> debugChildren: aPPPerserDebuggerResult selectBlock: aSelectBlock result: aCollection [
	(aSelectBlock value: aPPPerserDebuggerResult)
		ifTrue: [ aCollection add: aPPPerserDebuggerResult ].
	aPPPerserDebuggerResult children
		do: [ :child | 
			self
				debugChildren: child
				selectBlock: aSelectBlock
				result: aCollection ]
]

{ #category : #accessing }
GplSyntaxComponent >> debugResult [
	debugResult
		ifNil: [ debugResult := PPParserDebuggerResult
				parse: self expression
				with: self parser ].
	^ debugResult
]

{ #category : #accessing }
GplSyntaxComponent >> expression [
	expression ifNil: [ expression := '1' ].
	^ expression asString
]

{ #category : #accessing }
GplSyntaxComponent >> expression: aByteString [
	expression := aByteString.
	parser := nil.
	parseResult := nil.
	debugResult := nil.
	filteredResults := nil
]

{ #category : #accessing }
GplSyntaxComponent >> filteredResults [
	filteredResults
		ifNil:
			[ filteredResults := self namesForParserDebugResult: self debugResult ].
	^ filteredResults
]

{ #category : #initialization }
GplSyntaxComponent >> initialize [
	super initialize.
	searcher := PPSearcher new
]

{ #category : #'as yet unclassified' }
GplSyntaxComponent >> namesForParserDebugResult: aPPPerserDebugResult [
	| nodes |
	nodes := OrderedCollection new.
	self
		debugChildren: aPPPerserDebugResult
		selectBlock: [ :node | self parserDebugResultFilter: node ]
		result: nodes.
	^ nodes asSet asArray
		sort: [ :a :b | a end - a start < (b end - b start) ]
]

{ #category : #accessing }
GplSyntaxComponent >> parseResult [
	parseResult
		ifNil: [ parseResult := self parser parse: self expression ].
	^ parseResult
]

{ #category : #accessing }
GplSyntaxComponent >> parser [
	parser ifNil: [ parser := GplExpressionGrammar new trim ].
	^ parser
]

{ #category : #'as yet unclassified' }
GplSyntaxComponent >> parserDebugResultFilter: aPPPerserDebugResult [
	aPPPerserDebugResult result isPetitFailure
		ifTrue: [ ^ false ].
	"(aPPPerserDebugResult parser name beginsWith: 'prec') ifTrue: [^true]"
	^ #('nullLiteral' 'numberVectorLiteral' 'addition' 'subtraction' 'division' 'multiplication' 'stringLiteral' 'arrayConcatenate' , 'list')
		includes: aPPPerserDebugResult parser name
]

{ #category : #rendering }
GplSyntaxComponent >> renderArray: anArray on: html [
	(anArray respondsTo: #do:)
		ifFalse: [ ^ html text: anArray ].
	html
		unorderedList: [ anArray
				do: [ :each | 
					(each isMemberOf: Array)
						ifTrue: [ self renderArray: each on: html ]
						ifFalse: [ html listItem: each ] ] ]
]

{ #category : #rendering }
GplSyntaxComponent >> renderContentOn: html [
	self renderExpressionInputOn: html.
	html div: [ self renderString: self expression withIndexesOn: html ].
	html
		div: [ html text: 'debug result:'.
			self renderArray: self filteredResults on: html ].
	html
		div: [ html text: 'parse result:'.
			self renderArray: self parseResult on: html ]
]

{ #category : #rendering }
GplSyntaxComponent >> renderExpressionInputOn: html [
	html
		form: [ html textInput
				id: #expression;
				size: 80;
				on: #expression of: self.
			html submitButton ]
]

{ #category : #rendering }
GplSyntaxComponent >> renderMatchesOn: html [
	#(matchesIn: matchesSkipIn: matchingRangesIn: matchingSkipRangesIn:)
		do: [ :sel | self renderParserSelector: sel on: html ]
]

{ #category : #rendering }
GplSyntaxComponent >> renderParserSelector: oneArgSel on: html [
	html
		div: [ html text: oneArgSel asString , ' '.
			self
				renderArray: (self parser perform: oneArgSel with: self expression)
				on: html ]
]

{ #category : #rendering }
GplSyntaxComponent >> renderSearchExampleOn: html [
	searcher
		matches: (PPPattern kind: PPLiteralParser)
		do: [ :p :answer | 
			answer
				add: p;
				yourself ].
	html
		div: [ html text: 'search: '.
			self
				renderArray: (searcher execute: self parser initialAnswer: OrderedCollection new)
				on: html ]
]

{ #category : #rendering }
GplSyntaxComponent >> renderString: aString withIndexesOn: html [
	html table
		class: 'indexedString';
		with: [ html tableRow
				class: 'charIndex';
				with: [ aString withIndexDo: [ :c :index | html tableData: index ] ].
			html
				tableRow: [ aString withIndexDo: [ :c :Index | html tableData: c ] ] ]
]

{ #category : #rendering }
GplSyntaxComponent >> style [
	^ 'body {
	font-family: "Osaka-Regular", "IPAGothic Regular", "Monaco";
	font-size: 16px;
}

table.indexedString  {
	border-collapse: collapse;
	border:1px solid gray;
}

td  {
	text-align: center;
	border:1px solid gray;
}

.charIndex {
	color: gray;
	font-size: 10px;
}

'
]
