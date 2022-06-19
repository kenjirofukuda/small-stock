Class {
	#name : #MandaraComponent,
	#superclass : #WAComponent,
	#instVars : [
		'slider',
		'model'
	],
	#category : #'KFSeaside-Demos'
}

{ #category : #testing }
MandaraComponent class >> canBeRoot [
	^ true
]

{ #category : #'class initialization' }
MandaraComponent class >> initialize [
	"self initialize."

	| application |
	application := WAAdmin register: self asApplicationAt: 'kf/mandara'.
	application
		preferenceAt: #scriptGeneratorClass
		put: JQScriptGenerator.
	application
		addLibrary: JQBaseTheme;
		addLibrary: JQDeploymentLibrary;
		addLibrary: JQUiDeploymentLibrary
]

{ #category : #initialize }
MandaraComponent >> initialize [
	super initialize.
	model := Mandara new
]
