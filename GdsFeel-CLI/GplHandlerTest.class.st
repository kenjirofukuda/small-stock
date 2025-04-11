Class {
	#name : 'GplHandlerTest',
	#superclass : 'GdsTestCase',
	#category : 'GdsFeel-CLI-Test',
	#package : 'GdsFeel-CLI',
	#tag : 'Test'
}

{ #category : 'as yet unclassified' }
GplHandlerTest >> testIsVoid [
	self
		assert:
			(GplToken builtinMethods
				allSatisfy: [ :each | (GplHandler isVoid: each) not ])
]
