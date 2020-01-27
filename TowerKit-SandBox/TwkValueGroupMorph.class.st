Class {
	#name : #TwkValueGroupMorph,
	#superclass : #BorderedMorph,
	#category : #'TowerKit-SandBox'
}

{ #category : #'instance creation' }
TwkValueGroupMorph class >> open [
	<script>
	"self open"
	self new openInWorld.
]

{ #category : #'instance creation' }
TwkValueGroupMorph class >> openWithInstances [
	<script>
	"self openWithInstances"
	| m | 
	m := self new .
	10 timesRepeat: [ 
	m	addMorphBack: (TwkValueMorph new value: 10 atRandom * 0.1)].
	m openInWorld.
]

{ #category : #'as yet unclassified' }
TwkValueGroupMorph >> initialize [
	super initialize.
	self color: Color white.
	self enableDrop: true. 
	self listDirection: #leftToRight.
	self changeTableLayout.
]
