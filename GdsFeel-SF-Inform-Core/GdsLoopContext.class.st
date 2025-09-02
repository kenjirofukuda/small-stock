"
I am stream loop flow control value holder.

nstance Variables
	break:		<Boolean>
	result:		<Object>

"
Class {
	#name : #GdsLoopContext,
	#superclass : #Object,
	#instVars : [
		'break',
		'result'
	],
	#category : #'GdsFeel-SF-Inform-Core'
}

{ #category : #accessing }
GdsLoopContext >> break [

	^ break
]

{ #category : #accessing }
GdsLoopContext >> break: aBoolean [

	break := aBoolean
]

{ #category : #accessing }
GdsLoopContext >> initialize [

	super initialize.
	break := false
]

{ #category : #accessing }
GdsLoopContext >> result [

	^ result
]

{ #category : #accessing }
GdsLoopContext >> result: anObject [

	result := anObject
]
