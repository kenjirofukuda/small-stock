Class {
	#name : #GdsArray,
	#superclass : #GdsDataStructure,
	#category : #'GdsFeel-CLI-Data'
}

{ #category : #arithmetic }
GdsArray >> applySymbol: aSymbol to: aObject [
	| col |
	self applySymbolCheck: aSymbol to: aObject.
	self assert: [ self isScalar not ].
	((aObject isMemberOf: GdsVector)
		or: [ aObject isMemberOf: GdsMatrix ])
		ifTrue: [ self size = aObject size
				ifFalse: [ ^ self runtimeError: 'ILLIGAL DATA SIZE' ].
			col := OrderedCollection new.
			self elements
				doWithIndex:
					[ :value :index | col add: (value perform: aSymbol with: (aObject at: index)) ].
			^ GdsVector withAll: col ].
	^ GdsVector
		withAll:
			(self elements
				collect: [ :value | value perform: aSymbol with: aObject ])
]

{ #category : #convert }
GdsArray >> asGdsFloating [
	^ self vectorClass
		withAll: (self elements collect: [ :v | v asGdsFloating ])
]

{ #category : #'error handling' }
GdsArray >> doesNotUnderstand: aMessage [
	"Transcript cr; show: aMessage."

	self isScalar
		ifFalse: [ ^ self newElementSelector: aMessage selector ].
	^ super doesNotUnderstand: aMessage
]

{ #category : #convert }
GdsArray >> mostCompactValue [
	^ self vectorClass
		withAll: (self elements collect: [ :v | v mostCompactValue ])
]

{ #category : #private }
GdsArray >> newElementSelector: aSelector [
	^ self vectorClass
		withAll: (self elements collect: [ :v | v perform: aSelector ])
]

{ #category : #testing }
GdsArray >> sameAsInteger [
	^ self asVector elements allSatisfy: [ :v | v sameAsInteger ]
]
