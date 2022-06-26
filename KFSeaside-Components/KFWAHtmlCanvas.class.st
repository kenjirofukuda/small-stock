Class {
	#name : #KFWAHtmlCanvas,
	#superclass : #WAHtmlCanvas,
	#category : #'KFSeaside-Components'
}

{ #category : #'tags-input' }
KFWAHtmlCanvas >> buttonInput [
	^ self brush: KFWAButtonInputTag new
]
