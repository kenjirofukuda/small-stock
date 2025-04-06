"
GplCommandSpec has not been documented yet. The class comment should describe the purpose of the class, its collaborations and its variables.

Instance Variables:
	name	<String>
	functionArgumentTypes	<Collection<Symbol>>
	procedureArgumentTypes	<Collection<Symbol>>
"
Class {
	#name : 'GplCommandSpec',
	#superclass : 'Object',
	#instVars : [
		'name',
		'functionArgumentTypes',
		'procedureArgumentTypes'
	],
	#category : 'GdsFeel-CLI-Handler',
	#package : 'GdsFeel-CLI',
	#tag : 'Handler'
}

{ #category : 'accessing' }
GplCommandSpec class >> selectorWithArgType: argType methodType: methodType methodName: methodName [
	^ ({(argType asString asLowercase , methodType asString capitalized
		, methodName asLowercase capitalized , ':')} joinUsing: '') asSymbol
]

{ #category : 'accessing' }
GplCommandSpec >> acceptableTypeSymbols [
	^ Array with: #niladic with: #monadic with: #diadic
]

{ #category : 'private' }
GplCommandSpec >> asKeySymbol: aTypeName [
	^ aTypeName asString asLowercase asSymbol
]

{ #category : 'private' }
GplCommandSpec >> asPrintType: aTypeName [
	^ aTypeName asString asUppercase asString
]

{ #category : 'accessing' }
GplCommandSpec >> functionArgumentTypes [
	functionArgumentTypes ifNil: [ ^ #() ].
	^ functionArgumentTypes
]

{ #category : 'accessing' }
GplCommandSpec >> functionArgumentTypes: aCollection [
	functionArgumentTypes := aCollection
]

{ #category : 'accessing' }
GplCommandSpec >> generateSelecters [
	^ (self
		generateSelecters: self functionArgumentTypes
		functionOrProcedure: #function)
		,
			(self
				generateSelecters: self procedureArgumentTypes
				functionOrProcedure: #procedure)
]

{ #category : 'accessing' }
GplCommandSpec >> generateSelecters: typeSymbols functionOrProcedure: methodType [
	^ typeSymbols
		collect: [ :sym | 
			self class
				selectorWithArgType: sym
				methodType: methodType
				methodName: self name ]
]

{ #category : 'testing' }
GplCommandSpec >> hasAnyTypes [
	^ self functionArgumentTypes size + self procedureArgumentTypes size
		> 0
]

{ #category : 'testing' }
GplCommandSpec >> isBiContext [
	^ self functionArgumentTypes size > 0
		and: [ self procedureArgumentTypes size > 0 ]
]

{ #category : 'testing' }
GplCommandSpec >> isFunctionAllowed [
	^ functionArgumentTypes notEmpty
]

{ #category : 'testing' }
GplCommandSpec >> isValid [
	^ self name notEmpty and: [ self hasAnyTypes ]
]

{ #category : 'accessing' }
GplCommandSpec >> name [
	name ifNil: [ ^ '' ].
	^ name
]

{ #category : 'accessing' }
GplCommandSpec >> name: aCommandName [
	name := aCommandName
]

{ #category : 'accessing' }
GplCommandSpec >> procedureArgumentTypes [
	procedureArgumentTypes ifNil: [ ^ #() ].
	^ procedureArgumentTypes
]

{ #category : 'accessing' }
GplCommandSpec >> procedureArgumentTypes: aCollection [
	procedureArgumentTypes := aCollection
]

{ #category : 'printing' }
GplCommandSpec >> statement [
	^ String
		streamContents: [ :s | 
			self isValid
				ifFalse: [ s nextPutAll: '| ' ].	"if error comment format"
			s nextPutAll: 'EXTERNAL'.
			s nextPut: Character space.
			s nextPut: Character space.
			self procedureArgumentTypes
				ifNotEmpty: [ self procedureArgumentTypes
						do: [ :each | 
							s nextPutAll: (self asPrintType: each).
							s nextPut: Character space ].
					s nextPutAll: 'PROCEDURE' ].
			self isBiContext
				ifTrue: [ s nextPutAll: ', ' ].
			self functionArgumentTypes
				ifNotEmpty: [ self functionArgumentTypes
						do: [ :each | 
							s nextPutAll: (self asPrintType: each).
							s nextPut: Character space ].
					s nextPutAll: 'FUNCTION' ].
			s nextPut: Character space.
			s nextPutAll: (self asPrintType: self name) ]
]
