Class {
	#name : #GdsNumber,
	#superclass : #GdsDglType,
	#category : #'GdsFeel-CLI-DGL'
}

{ #category : #'as yet unclassified' }
GdsNumber class >> fromSmalltalk: anObject [
	| clazz |
	clazz := self allSubclasses detect: [:each  | each isAcceptableSmalltalkObject: anObject] ifNone: [^nil].
	clazz ifNil: [^self error: 'CANNT INSTANCE CREATION' ].
	^clazz fromSmalltalk: anObject.
]

{ #category : #'as yet unclassified' }
GdsNumber class >> isAcceptableSmalltalkObject: anObject [
	^self allSubclasses anySatisfy: [:clazz | clazz isAcceptableSmalltalkObject: anObject].
]
