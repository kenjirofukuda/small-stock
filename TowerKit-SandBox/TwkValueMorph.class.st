"
Draggable value holder
"
Class {
	#name : #TwkValueMorph,
	#superclass : #BorderedMorph,
	#instVars : [
		'value',
		'valueMorph'
	],
	#category : #'TowerKit-SandBox'
}

{ #category : #'instance creation' }
TwkValueMorph class >> open [
	"self open"
	<script>
	self new value: 0.1 ; openInWorld.
]

{ #category : #'as yet unclassified' }
TwkValueMorph >> initialize [
	super initialize.
	self color: Color lightGray twiceLighter
]

{ #category : #'as yet unclassified' }
TwkValueMorph >> value: aNumber [
	value := aNumber.
	self valueMorph contents: value asString.
	(self findA: StringMorph)
		ifNil: [ self addMorph: self valueMorph ]. 
]

{ #category : #'as yet unclassified' }
TwkValueMorph >> valueMorph [
	^ valueMorph ifNil: [ valueMorph := StringMorph new] 
]
