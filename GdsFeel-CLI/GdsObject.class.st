Class {
	#name : #GdsObject,
	#superclass : #Object,
	#category : #'GdsFeel-CLI-Kernel'
}

{ #category : #'error handling' }
GdsObject class >> error: aString [
	^GdsError new signal:  aString
]

{ #category : #'error handling' }
GdsObject class >> runtimeError: aString [
	^GplRuntimeError new signal:  aString
]

{ #category : #'error handling' }
GdsObject class >> syntaxError: aString [
	^GplSyntaxError new signal:  aString
]

{ #category : #'as yet unclassified' }
GdsObject >> error: aString [
	^self class error: aString
]

{ #category : #'as yet unclassified' }
GdsObject >> runtimeError: aString [
	^self class runtimeError: aString.
]

{ #category : #'as yet unclassified' }
GdsObject >> syntaxError: aString [
	^self class syntaxError: aString
]
