Class {
	#name : 'GdsBetaCompatibility',
	#superclass : 'GdsStrictCompatibility',
	#category : 'GdsFeel-Model-Basic',
	#package : 'GdsFeel-Model-Basic'
}

{ #category : 'as yet unclassified' }
GdsBetaCompatibility class >> isActive [
	^true.
]

{ #category : 'as yet unclassified' }
GdsBetaCompatibility >> coerceStructureName: aString [
	^(super coerceStructureName: aString) asUppercase.
]

{ #category : 'as yet unclassified' }
GdsBetaCompatibility >> libNameMax [
	^32
]
