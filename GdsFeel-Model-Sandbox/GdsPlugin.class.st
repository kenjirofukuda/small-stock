Class {
	#name : #GdsPlugin,
	#superclass : #Object,
	#category : #'GdsFeel-Model-Sandbox'
}

{ #category : #'as yet unclassified' }
GdsPlugin >> enabledPluginClasses [
	"GdsPlugin new enabledPluginClasses inspect."
	^ self pluginClasses select: [ :clazz | (clazz respondsTo: #enabled) and: [ clazz enabled ]]
]

{ #category : #'as yet unclassified' }
GdsPlugin >> pluginClasses [
	"self new pluginClasses inspect."

	| pragmas  |
	pragmas := (PragmaCollector
		filter: [ :pragma | | sel |
			sel := 	(pragma respondsTo: #methodSelector) ifTrue: [ #methodSelector ] ifFalse: [ #selector ]. 
			(pragma perform: sel)  = #gdsPlugin ]) reset.
	^ pragmas collect: [ :each | each method methodClass baseClass ]
]
