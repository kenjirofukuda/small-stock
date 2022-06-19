Class {
	#name : #GplCommands,
	#superclass : #GplSingleHandler,
	#category : #'GdsFeel-CLI-Commands'
}

{ #category : #accessing }
GplCommands class >> methodName [
	^ 'COMMANDS'
]

{ #category : #handler }
GplCommands >> evaluateToken: aToken [
	^ self strings: GplHandler commandNames sort
]
