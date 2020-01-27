Class {
	#name : #TwkText,
	#superclass : #TwkNode,
	#instVars : [
		'textHeight',
		'charWidth',
		'margin',
		'contents',
		'textWidth',
		'basePoint',
		'vertical',
		'useMargin',
		'offset',
		'marginRatio'
	],
	#category : #'TowerKit-GdsFeel'
}

{ #category : #accessing }
TwkText >> basePoint [
	^ basePoint
]

{ #category : #accessing }
TwkText >> basePoint: aPoint [
	basePoint := aPoint	
	
]

{ #category : #accessing }
TwkText >> boundsByCenter [
	^ Rectangle center: self center extent: self extent
]

{ #category : #accessing }
TwkText >> center [
	^ basePoint + self offset
]

{ #category : #accessing }
TwkText >> contents [
	^ contents
]

{ #category : #accessing }
TwkText >> contents: aString [
	contents := aString.
	textWidth := charWidth * contents size.
	
]

{ #category : #initialization }
TwkText >> extent [
	^ textWidth @ textHeight
]

{ #category : #initialization }
TwkText >> initialize [
	useMargin := false.
	vertical := true.
	offset := 0.0 @ 0.0.
	basePoint := 0.0 @ 0.0.
	marginRatio := 1.0.
	
]

{ #category : #testing }
TwkText >> isVertical [
	^ vertical
]

{ #category : #accessing }
TwkText >> marginOffset [
	| x y yProc |
	yProc := [ (margin + (textHeight * self marginRatio)) * basePoint y sign]. 
	self isVertical
		ifTrue: [
			x := (margin + (textWidth * self marginRatio)) * basePoint x sign.
			y := 0.
			(basePoint x closeTo: 0.0)
				ifTrue: [
					y := yProc value ] ]
		ifFalse: [
			x := 0.
			y := yProc value ].
	^ x @ y
]

{ #category : #accessing }
TwkText >> marginRatio [
	^ marginRatio 
]

{ #category : #accessing }
TwkText >> marginRatio: aNumber [
	marginRatio := aNumber
]

{ #category : #accessing }
TwkText >> offset [
	^ self useMargin 
		ifTrue: [ self marginOffset ]
		ifFalse: [ offset ]
]

{ #category : #accessing }
TwkText >> offset: aPoint [
	offset := aPoint
]

{ #category : #accessing }
TwkText >> textHeight [
	^ textHeight
]

{ #category : #accessing }
TwkText >> textHeight: aNumber [
	textHeight := aNumber < 0 ifTrue: [ 100 ] ifFalse: [ aNumber ].
	charWidth := textHeight * 0.5.
	margin := charWidth.
	
]

{ #category : #accessing }
TwkText >> textWidth [
	^ textWidth
]

{ #category : #accessing }
TwkText >> useMargin [
	^ useMargin
]

{ #category : #accessing }
TwkText >> useMargin: aBoolean [
	useMargin := aBoolean
]

{ #category : #accessing }
TwkText >> vertical: aBoolean [
	vertical := aBoolean
	
]
