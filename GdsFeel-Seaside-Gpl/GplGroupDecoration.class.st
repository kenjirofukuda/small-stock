Class {
	#name : #GplGroupDecoration,
	#superclass : #WAWidgetDecoration,
	#instVars : [
		'groupClasses'
	],
	#category : #'GdsFeel-Seaside-Gpl'
}

{ #category : #'as yet unclassified' }
GplGroupDecoration >> groupClasses: classes [
	groupClasses := classes
]

{ #category : #'as yet unclassified' }
GplGroupDecoration >> renderContentOn: html [
	groupClasses
		do: [ :clazz | 
			html div
				class: 'tab';
				with: [ html anchor
						url: '/' , clazz handlerName;
						with: clazz handlerName ] ].
	self renderNextOn: html
]
