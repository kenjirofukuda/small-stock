Class {
	#name : 'GplCurrentItemNoArgHandler',
	#superclass : 'GplMultiHandler',
	#category : 'GdsFeel-CLI-Handler',
	#package : 'GdsFeel-CLI',
	#tag : 'Handler'
}

{ #category : 'accessing' }
GplCurrentItemNoArgHandler class >> associateArray [
	^ {('UNGET' -> #unget).
	('PUT' -> #put).
	('ITEMREVERSE' -> #reverseVertices)}
]

{ #category : 'testing' }
GplCurrentItemNoArgHandler class >> isFunctionAllowed: aCommandName [
	^ false
]

{ #category : 'handler' }
GplCurrentItemNoArgHandler >> evaluateToken: aToken [
	| selector |
	selector := self class selectorForMethodName: aToken fragment.
	self currentItem perform: selector.
	^ self nullVector
]
