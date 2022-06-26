Class {
	#name : #XmlMandara,
	#superclass : #MandaraComponent,
	#category : #'KFSeaside-Demos'
}

{ #category : #'as yet unclassified' }
XmlMandara class >> initialize [
	"self initialize."

	| application |
	application := WAAdmin register: self asApplicationAt: 'kf/mandara3'.
	application
		preferenceAt: #scriptGeneratorClass
		put: JQScriptGenerator.
	application
		addLibrary: JQBaseTheme;
		addLibrary: JQDeploymentLibrary;
		addLibrary: JQUiDeploymentLibrary
]

{ #category : #rendering }
XmlMandara >> renderContentOn: html [
	| sliderId |
	html heading: 'Mandara (SVG)'.
	html document nextPutAll: self svgXml greaseString
]

{ #category : #rendering }
XmlMandara >> renderInlineBySVGOn: html [
	| sliderId |
	html heading: 'Mandara'.
	html document
		nextPutAll:
			'<svg xmlns="http://www.w3.org/2000/svg" version="1.1">
  <path d="M150 0 L75 200 L225 200 Z" />
</svg>'
]

{ #category : #rendering }
XmlMandara >> svgXml [
	| top group |
	top := XMLElement
		name: 'svg'
		namespaceURI: 'http://www.w3.org/2000/svg'
		attributes: {('version' -> 1.1 asString)}.
	group := XMLElement name: 'g'.
	group attributeAt: 'stroke' put: 'blue'.
	group attributeAt: 'stroke-width' put: '0.5'.
	group attributeAt: 'fill' put: 'none'.
	top addNode: group.
	model strokes do: [ :stroke | group addNode: stroke asXmlElement ].
	^ top
]
