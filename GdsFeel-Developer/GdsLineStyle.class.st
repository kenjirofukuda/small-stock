Class {
	#name : #GdsLineStyle,
	#superclass : #Object,
	#category : #'GdsFeel-Developer-Model'
}

{ #category : #accessing }
GdsLineStyle >> letter [

	self symbol = #solid ifTrue: [ ^ $- ].
	self symbol = #brokn ifTrue: [ ^ $! ].
	self symbol = #dashed ifTrue: [ ^ $| ].
	self symbol = #doted ifTrue: [ ^ $: ].
	^ $E "error symbol"
]

{ #category : #accessing }
GdsLineStyle >> symbol [
	^#solid.
	
]
