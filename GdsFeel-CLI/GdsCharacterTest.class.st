Class {
	#name : #GdsCharacterTest,
	#superclass : #GdsTestCase,
	#category : #'GdsFeel-CLI-Test'
}

{ #category : #tests }
GdsCharacterTest >> testConstants [
	self assert: (GdsCharacter nul) asciiValue equals: 8r0. 
	self assert: (GdsCharacter bel) asciiValue equals: 8r7. 	
	self assert: (GdsCharacter tab) asciiValue equals: 8r11. 		
	self assert: (GdsCharacter lf) asciiValue equals: 8r12. 				
	self assert: (GdsCharacter ff) asciiValue equals: 8r14. 				
	self assert: (GdsCharacter cr) asciiValue equals: 8r15.
	self assert: (GdsCharacter nl) asciiValue equals: 8r15. 				
	self assert: (GdsCharacter esc) asciiValue equals: 8r33. 				
	self assert: (GdsCharacter broff) asciiValue equals: 8r36. 														
	self assert: (GdsCharacter bron) asciiValue equals: 8r37. 																			
	self assert: (GdsCharacter qt) asciiValue equals: 8r42. 																			
	self assert: (GdsCharacter del) asciiValue equals: 8r177. 																			
														
]
