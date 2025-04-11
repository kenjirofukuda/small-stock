Class {
	#name : 'GdsStringTest',
	#superclass : 'GdsTestCase',
	#category : 'GdsFeel-CLI-Test',
	#package : 'GdsFeel-CLI',
	#tag : 'Test'
}

{ #category : 'tests' }
GdsStringTest >> testAcceptableExpression [
	self deny: (GdsString acceptableExpression: '').
	self deny: (GdsString acceptableExpression: '"').
	self deny: (GdsString acceptableExpression: $' asString).
	self assert: (GdsString acceptableExpression: '""')
]

{ #category : 'tests' }
GdsStringTest >> testApplySymbolTo [
	| sample |
	sample := 'ABC' asGdsValue.
	"not a GdsDataStructure"
	self should: [ sample applySymbol: #+ to: 1 ] raise: GplError.

	"self + self"
	self should: [ sample applySymbol: #+ to: sample ] raise: GplError.

	"self -  self"
	self should: [ sample applySymbol: #- to: sample ] raise: GplError.

	"self *  self"
	self should: [ sample applySymbol: #* to: sample ] raise: GplError.

	"self %  self"
	self should: [ sample applySymbol: #% to: sample ] raise: GplError
]

{ #category : 'tests' }
GdsStringTest >> testFromEmbedLiteral [
	"not close >"

	self
		should: [ GdsString fromLiteral: '"Calma<CR GDSII"' ]
		raise: GplSyntaxError.

	"not open <"
	self
		should: [ GdsString fromLiteral: '"Calma CR> GDSII"' ]
		raise: GplSyntaxError.

	"nested <"
	self
		should: [ GdsString fromLiteral: '"Calma<<CR> GDSII"' ]
		raise: GplSyntaxError.

	"nested >"
	self
		should: [ GdsString fromLiteral: '"Calma<CR>> GDSII"' ]
		raise: GplSyntaxError.

	"nested <<>>"
	self
		should: [ GdsString fromLiteral: '"Calma<<CR>> GDSII"' ]
		raise: GplSyntaxError.

	"ok"
	self
		shouldnt: [ GdsString fromLiteral: '"Calma<CR> GDSII"' ]
		raise: GplSyntaxError
]

{ #category : 'tests' }
GdsStringTest >> testFromLiteral [
	| result expResult |
	expResult := GdsNull instance.
	result := GdsString fromLiteral: '""'.
	self assert: result = expResult.
	self
		shouldnt: [ GdsString fromLiteral: '"ABC"' ]
		raise: GplSyntaxError.

	"double quote only."
	self should: [ GdsString fromLiteral: '"' ] raise: GplSyntaxError.

	"missing closing quote"
	self should: [ GdsString fromLiteral: '"ABC' ] raise: GplSyntaxError.

	"single quote not support"
	self
		should: [ GdsString fromLiteral: '''ABC''' ]
		raise: GplSyntaxError
]

{ #category : 'tests' }
GdsStringTest >> testFromLiteralExtension [
	| result expResult msg |
	msg := 'TODO: implement < > notation in string context'.
	expResult := String with: (Character value: 0).
	result := (GdsString fromLiteral: '"<NUL>"') gplString.
	self assert: result = expResult description: msg.
	expResult := (Character value: 8r7) asString.
	result := (GdsString fromLiteral: '"<BEL>"') gplString.
	self assert: result = expResult description: msg.
	expResult := String tab.
	result := (GdsString fromLiteral: '"<TAB>"') gplString.
	self assert: result = expResult description: msg.
	expResult := String lf.
	result := (GdsString fromLiteral: '"<LF>"') gplString.
	self assert: result = expResult description: msg.
	expResult := (Character value: 8r14) asString.
	result := (GdsString fromLiteral: '"<FF>"') gplString.
	self assert: result = expResult description: msg.
	expResult := String cr.
	result := (GdsString fromLiteral: '"<CR>"') gplString.
	self assert: result = expResult description: msg.
	expResult := (Character value: 8r15) asString.
	result := (GdsString fromLiteral: '"<NL>"') gplString.
	self assert: result = expResult description: msg.
	expResult := (Character value: 8r33) asString.
	result := (GdsString fromLiteral: '"<ESC>"') gplString.
	self assert: result = expResult description: msg.
	expResult := (Character value: 8r36) asString.
	result := (GdsString fromLiteral: '"<BROFF>"') gplString.
	self assert: result = expResult description: msg.
	expResult := (Character value: 8r37) asString.
	result := (GdsString fromLiteral: '"<BRON>"') gplString.
	self assert: result = expResult description: msg.
	expResult := (Character value: 8r42) asString.
	result := (GdsString fromLiteral: '"<QT>"') gplString.
	self assert: result = expResult description: msg.
	expResult := '<'.
	result := (GdsString fromLiteral: '"<74>"') gplString.
	self assert: result = expResult description: msg.
	expResult := '>'.
	result := (GdsString fromLiteral: '"<76>"') gplString.
	self assert: result = expResult description: msg.
	expResult := (Character value: 8r177) asString.
	result := (GdsString fromLiteral: '"<DEL>"') gplString.
	self assert: result = expResult description: msg
]

{ #category : 'tests' }
GdsStringTest >> testFromLiteralExtension2 [
	| result expResult msg |
	msg := 'TODO: implement < > notation in string context'.
	expResult := '"ABC"'.
	result := (GdsString fromLiteral: '"<QT>ABC<QT>"') gplString.
	self assert: result = expResult description: msg.
	expResult := 'ABC
DEF'.
	result := (GdsString fromLiteral: '"ABC<CR>DEF"') gplString.
	self assert: result = expResult description: msg.
	expResult := '<CR>'.
	result := (GdsString fromLiteral: '"<74>CR<76>"') gplString.
	self assert: result = expResult description: msg.
	expResult := 'Gerald Lott'.
	result := (GdsString
		fromLiteral: '"<107><145><162><141><154><144><40><114><157><164><164>"')
		gplString.
	self assert: result = expResult description: msg
]

{ #category : 'tests' }
GdsStringTest >> testIsList [
	self deny: (GdsString fromLiteral: '"ABC"') isList
]

{ #category : 'tests' }
GdsStringTest >> testLength [
	"length is a list element size not a vector size"

	self assert: (GdsString fromLiteral: '"A"') length = 1.
	self assert: (GdsString fromLiteral: '"AB"') length = 1.
	self assert: (GdsString fromLiteral: '"ABC"') length = 1
]

{ #category : 'tests' }
GdsStringTest >> testMode [
	| result expResult |
	expResult := 4.
	result := (GdsString fromLiteral: '"ABC"') mode.
	self assert: result = expResult
]

{ #category : 'tests' }
GdsStringTest >> testRank [
	| result expResult |
	expResult := 1.
	result := (GdsString fromLiteral: '"ABC"') rank.
	self assert: result = expResult
]

{ #category : 'tests' }
GdsStringTest >> testShape [
	| result expResult |
	expResult := 3.
	result := (GdsString fromLiteral: '"ABC"') shape.
	self assert: result = expResult
]

{ #category : 'tests' }
GdsStringTest >> testSize [
	| result expResult |
	expResult := 1.
	result := (GdsString fromLiteral: '"A"') size.
	self assert: result = expResult.
	expResult := 2.
	result := (GdsString fromLiteral: '"AB"') size.
	self assert: result = expResult.
	expResult := 3.
	result := (GdsString fromLiteral: '"ABC"') size.
	self assert: result = expResult
]

{ #category : 'tests' }
GdsStringTest >> testTypeString [
	| result expResult |
	expResult := 'CHAR'.
	result := (GdsString fromLiteral: '"ABC"') typeString.
	self assert: result = expResult.
	expResult := 'NULL'.
	result := (GdsString fromLiteral: '""') typeString.
	self assert: result = expResult
]
