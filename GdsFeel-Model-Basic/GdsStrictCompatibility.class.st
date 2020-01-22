Class {
	#name : #GdsStrictCompatibility,
	#superclass : #GdsCompatibility,
	#category : #'GdsFeel-Model-Basic'
}

{ #category : #testing }
GdsStrictCompatibility >> elementColorAllowed [
	^false
]

{ #category : #acessing }
GdsStrictCompatibility >> layerNumberMax [
	^63
]

{ #category : #acessing }
GdsStrictCompatibility >> libNameMax [
	^10
]

{ #category : #testing }
GdsStrictCompatibility >> multilingalNameAllowed [
	^ false
]

{ #category : #'category name' }
GdsStrictCompatibility >> supportedColorSymbols [
	^#(blue cyan green magenta red white yellow).
]
