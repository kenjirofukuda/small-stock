Class {
	#name : #GdsShellWindowMorph,
	#superclass : #ShellWindowMorph,
	#instVars : [
		'textStyle'
	],
	#category : #'GdsFeel-CLI-CommandShell'
}

{ #category : #'as yet unclassified' }
GdsShellWindowMorph class >> open [
	"Open a new CommandShell, and answer the instance of ShellWindowMorph which it uses."

	"GdsShellWindowMorph open"

	^ GdsCommandShell open dependents at: 2
]

{ #category : #accessing }
GdsShellWindowMorph >> familyName [
	"Source Code Pro"
	(Smalltalk at: #SourceCodeFonts)
		ifNotNil: [ :clazz | ^ clazz fontName ].
	^  'Nouveau IBM' 

]

{ #category : #'as yet unclassified' }
GdsShellWindowMorph >> replaceCustomParagraph [
	self textMorph setProperty: #paragraphClass toValue: GdsParagraph.
	 
]

{ #category : #'as yet unclassified' }
GdsShellWindowMorph >> setText: aText [
	super setText: aText.
	(self textMorph paragraph isMemberOf: GdsParagraph)
		ifFalse: [ self replaceCustomParagraph ]. 

]

{ #category : #'as yet unclassified' }
GdsShellWindowMorph >> textStyle [
	"A fixed width font for the text morph"
	^textStyle ifNil: [ textStyle :=  (LogicalFont familyName: (self familyName) pointSize: 11) textStyle.]

]
