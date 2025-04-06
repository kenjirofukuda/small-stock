Class {
	#name : 'GplShisokuTest',
	#superclass : 'PPCompositeParserTest',
	#category : 'GplPetitParser-Tests',
	#package : 'GplPetitParser',
	#tag : 'Tests'
}

{ #category : 'tests' }
GplShisokuTest >> parserClass [
	^ GplShisoku
]

{ #category : 'tests' }
GplShisokuTest >> testBigE [
	"Tests GplShisoku>>#bigE"

	self parse: '1 + 2' rule: #prec0.
	self parse: '1 + 2 + 3' rule: #prec0.
	self parse: '1 + 2 * 3' rule: #prec0.
	self parse: '1 * 2 + 3' rule: #prec0.
	self parse: '1+ 2' rule: #prec0.
	self parse: '1+2+3' rule: #prec0.
	self parse: '1+2*3' rule: #prec0.
	self parse: '1*2+3' rule: #prec0.
	self parse: '(1+2)+3' rule: #prec0
]
