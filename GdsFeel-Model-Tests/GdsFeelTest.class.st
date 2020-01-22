Class {
	#name : #GdsFeelTest,
	#superclass : #GdsOldTestCase,
	#category : #'GdsFeel-Model-Tests'
}

{ #category : #tests }
GdsFeelTest >> testProjectDirectory [
	"Tests GdsFeel>>#projectDirectory"
	GdsFeel projectDirectory traceCr.
	GdsFeel projectDirectory fullName traceCr.
	self assert: GdsFeel projectDirectory isDirectory.
	
]
