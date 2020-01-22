Class {
	#name : #GdsParagraph,
	#superclass : #Paragraph,
	#category : #'GdsFeel-CLI-CommandShell'
}

{ #category : #display }
GdsParagraph >> displayOn: aCanvas using: displayScanner at: somePosition [
	"Send all visible lines to the displayScanner for display"
	| visibleRectangle offset leftInRun line |
	visibleRectangle := aCanvas clipRect.
	offset := (somePosition - positionWhenComposed) truncated.
	leftInRun := 0.
	(self lineIndexForPoint: visibleRectangle topLeft)
		to: (self lineIndexForPoint: visibleRectangle bottomRight)
		do: [:i | line := lines at: i.
			self displaySelectionInLine2: line on: aCanvas.
			line first <= line last ifTrue:
				[leftInRun := displayScanner displayLine: line offset: offset leftInRun: leftInRun]].

]

{ #category : #'as yet unclassified' }
GdsParagraph >> displaySelectionInLine2: line on: aCanvas [ 
	| leftX rightX caretColor |
	selectionStart ifNil: [^self].	"No selection"
	aCanvas isShadowDrawing ifTrue: [ ^self ].	"don't draw selection with shadow"
	selectionStart = selectionStop 
		ifTrue: 
			["Only show caret on line where clicked"

			selectionStart textLine ~= line ifTrue: [^self]]
		ifFalse: 
			["Test entire selection before or after here"

			(selectionStop stringIndex < line first 
				or: [selectionStart stringIndex > (line last + 1)]) ifTrue: [^self].	"No selection on this line"
			(selectionStop stringIndex = line first 
				and: [selectionStop textLine ~= line]) ifTrue: [^self].	"Selection ends on line above"
			(selectionStart stringIndex = (line last + 1) 
				and: [selectionStop textLine ~= line]) ifTrue: [^self]].	"Selection begins on line below"
	leftX := (selectionStart stringIndex < line first 
				ifTrue: [line ]
				ifFalse: [selectionStart ])left.
	rightX := (selectionStop stringIndex > (line last + 1) or: 
					[selectionStop stringIndex = (line last + 1) 
						and: [selectionStop textLine ~= line]]) 
				ifTrue: [line right]
				ifFalse: [selectionStop left].
	selectionStart = selectionStop 
		ifTrue: 
			[ | theCaretWidth |
			theCaretWidth := 9.
			rightX := rightX + 1.
			caretRect := leftX @ line top corner: (leftX+theCaretWidth)@ line bottom.
			
			caretColor := self insertionPointColor.
			(self showCaret and: [ caretColor ~= Color transparent  ])
				ifTrue: [ aCanvas fillRectangle: caretRect color: caretColor ]
				ifFalse:[ aCanvas frameRectangle: caretRect color: caretColor].]
		ifFalse: 
			[caretRect := nil.
			aCanvas fillRectangle: (leftX @ line top corner: rightX @ line bottom)
				color: self selectionColor]
]

{ #category : #settings }
GdsParagraph >> insertionPointColor [
	"when focused out use frameRectangle then don't use transparent"
	"self focused ifFalse: [^ Color transparent]." 
	^ Display depth <= 2
		ifTrue: [Color black]
		ifFalse: [self class insertionPointColor]
]
