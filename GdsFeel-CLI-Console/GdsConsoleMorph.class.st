"
A GdsConsoleMorph is Gds Depends console morph
"
Class {
	#name : #GdsConsoleMorph,
	#superclass : #KFConsoleMorph,
	#category : #'GdsFeel-CLI-Console'
}

{ #category : #accessing }
GdsConsoleMorph >> consoleClass [
	^ GdsConsole
]

{ #category : #drawing }
GdsConsoleMorph >> drawChar: aCharacter on: aCanvas [
	({Character arrowUp . Character arrowDown} includes: aCharacter)
		ifTrue: [^ self bold: (aCharacter = Character arrowDown)].
	^ super drawChar: aCharacter on: aCanvas.

]

{ #category : #drawing }
GdsConsoleMorph >> drawOn: aCanvas [
	super drawOn: aCanvas.
	self drawLocationOn: aCanvas.
	self drawTimeOn: aCanvas.

]

{ #category : #initialize }
GdsConsoleMorph >> initialize [
	super initialize.
	self console promptString: '? '.
	overlayMorph := nil asValueHolder.
	overlayMorph whenChangedDo: [ :newValue | 
		newValue ifNotNil: [:newMorph |
			self superDrawable: false ] ].		
	
]

{ #category : #accessing }
GdsConsoleMorph >> overlayColor [
	overlayMorph value ifNotNil: [ :m | ^m backgroundColor ].
	^ self color.
]

{ #category : #accessing }
GdsConsoleMorph >> overlayMorph [
	^ overlayMorph value.
]

{ #category : #accessing }
GdsConsoleMorph >> overlayMorph: aMorph [ 
	overlayMorph value: aMorph.
]

{ #category : #accessing }
GdsConsoleMorph >> visiblePenColor [
	^self overlayMorph isNil
		ifTrue: [ super visiblePenColor ]
		ifFalse: [ | c |
			c := Color green twiceLighter.
			self bold ifFalse: [ c ] ifTrue: [c whiter]]
]
