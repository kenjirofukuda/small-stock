Class {
	#name : #GdsPrerequiredLibrary,
	#superclass : #WAFileLibrary,
	#category : #'GdsFeel-Seaside-Sandbox2'
}

{ #category : #updating }
GdsPrerequiredLibrary >> updateRoot: anHtmlRoot [
	anHtmlRoot script
		url: 'https://code.createjs.com/easeljs-0.8.2.min.js'.
	anHtmlRoot script
		url:
			'https://cdnjs.cloudflare.com/ajax/libs/snap.svg/0.4.1/snap.svg-min.js'.
	anHtmlRoot script
		url: 'https://cdnjs.cloudflare.com/ajax/libs/sprintf/1.0.3/sprintf.min.js'.
	super updateRoot: anHtmlRoot
]
