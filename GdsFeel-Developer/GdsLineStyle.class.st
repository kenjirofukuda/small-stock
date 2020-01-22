Class {
	#name : #GdsLineStyle,
	#superclass : #Object,
	#category : #'GdsFeel-Developer-Model'
}

{ #category : #'as yet unclassified' }
GdsLineStyle >> letter [
	self symbol = #solid ifTrue: [^$-].
	self symbol = #brokn ifTrue: [^$!].
	self symbol = #dashed ifTrue: [^$|].
	self symbol = #doted ifTrue: [^$:].
	^$E "error symbol"
	
]

{ #category : #'as yet unclassified' }
GdsLineStyle >> symbol [
	^#solid.
	
]
