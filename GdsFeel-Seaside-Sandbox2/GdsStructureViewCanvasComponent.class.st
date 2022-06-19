Class {
	#name : #GdsStructureViewCanvasComponent,
	#superclass : #WAComponent,
	#traits : 'THTML5Enabler',
	#classTraits : 'THTML5Enabler classTrait',
	#category : #'GdsFeel-Seaside-Sandbox2'
}

{ #category : #'accessing method dictionary' }
GdsStructureViewCanvasComponent class >> addAndClassifySelector: selector withMethod: compiledMethod inProtocol: aCategory [
	"When a new methods is added, I add it to the localMethodDict and also propagate the changes to my users"

	self localMethodDict at: selector put: compiledMethod.
	super
		addAndClassifySelector: selector
		withMethod: compiledMethod
		inProtocol: aCategory.
	TraitChange addSelector: selector on: self
]

{ #category : #'accessing method dictionary' }
GdsStructureViewCanvasComponent class >> addSelector: selector withMethod: compiledMethod [
	"When a new selector is installed in a class I insert the selector in the local methodDict and propagate the changes to my users"

	self localMethodDict at: selector put: compiledMethod.
	super addSelector: selector withMethod: compiledMethod.
	TraitChange addSelector: selector on: self
]

{ #category : #'accessing method dictionary' }
GdsStructureViewCanvasComponent class >> addSelector: selector withMethod: compiledMethod notifying: requestor [
	self
		deprecated: 'Please use #addSelector:withMethod: instead'
		transformWith:
			'`@receiver addSelector: `@statements1 withMethod: `@statements2 notifying: `@statements3'
				-> '`@receiver addSelector: `@statements1 withMethod: `@statements2'.
	^ self addSelector: selector withMethod: compiledMethod
]

{ #category : #testing }
GdsStructureViewCanvasComponent class >> canBeRoot [
	^ true
]

{ #category : #initialization }
GdsStructureViewCanvasComponent class >> doRebuildMethodDictionary [
	| selectors removedSelectors removeFromOrganization modified |
	"During the creation of the class or after a change in the traitComposition, the whole method dictionary is calculated.
	If I return true, my users should be updated"
	"1. I recreate the local methodDict"
	modified := false.
	self methodDict
		valuesDo:
			[ :m | m traitSource ifNil: [ self localMethodDict at: m selector put: m ] ].

	"2. I filter the selectors from the trait composition, rejecting the ones that are locally defined.
	And then I install the methods in myself. The trait composition only install the method if it is needed."
	selectors := self traitComposition selectors
		reject: [ :e | self localMethodDict includesKey: e ].
	selectors
		do: [ :e | 
			modified := modified
				| (self traitComposition installSelector: e into: self replacing: false) ].

	"3. I handle the methods that I have and they are no more in the traitComposition."
	removedSelectors := self methodDict keys
		reject: [ :aSelector | 
			(selectors includes: aSelector)
				or: [ self localMethodDict includesKey: aSelector ] ].
	modified := modified | removedSelectors isNotEmpty.
	removedSelectors
		do: [ :aSelector | self methodDict removeKey: aSelector ].

	"4. Finally, I remove these methods from my class organization"
	removeFromOrganization := self organization allMethodSelectors
		reject: [ :e | self methodDict includesKey: e ].
	removeFromOrganization
		do: [ :aSelector | self organization removeElement: aSelector ].
	^ modified
]

{ #category : #testing }
GdsStructureViewCanvasComponent class >> findOriginClassOf: aMethod [
	"I return the myself or the trait that has the original implementation of a method.
	If the method is an alias, the returned class includes the original aliased method"

	(aMethod hasProperty: #traitSource)
		ifTrue: [ ^ aMethod traitSource innerClass ].
	(self includesLocalSelector: aMethod selector)
		ifTrue: [ ^ self ].
	^ (self traitComposition
		traitDefining: aMethod selector
		ifNone: [ ^ self ]) innerClass
]

{ #category : #testing }
GdsStructureViewCanvasComponent class >> findOriginMethodOf: aMethod [
	"I return the original method for a aMethod.
	If this is a local method, the original method is itself.
	If it cames from a trait composition I look for the method in the trait composition.
	First I try with the trait stored in the traitSource. 
	If it is an aliased or conflicting method, the method is look up in the whole trait composition"

	(self includesLocalSelector: aMethod selector)
		ifTrue: [ ^ aMethod ].
	(aMethod hasProperty: #traitSource)
		ifTrue: [ | newSelector |
			newSelector := self traitComposition
				originSelectorOf: aMethod selector.
			^ aMethod traitSource
				compiledMethodAt: newSelector
				ifAbsent: [ aMethod ] ].
	^ (self traitComposition
		traitDefining: aMethod selector
		ifNone: [ self ])
		compiledMethodAt: aMethod selector
		ifAbsent: [ ^ aMethod ]
]

{ #category : #testing }
GdsStructureViewCanvasComponent class >> hasTraitComposition [
	^ self traitComposition isEmpty not
]

{ #category : #'class initialization' }
GdsStructureViewCanvasComponent class >> initialize [
	| application |
	application := WAAdmin register: self asApplicationAt: 'gds/sandbox1'.
	application
		addLibrary: JQ2DeploymentLibrary;
		addLibrary: GdsPrerequiredLibrary;
		addLibrary: GeoDevelopmentLibrary;
		addLibrary: GdsModelDevelopmentLibrary;
		addLibrary: GdsCanvasDevelopmentLibrary
]

{ #category : #testing }
GdsStructureViewCanvasComponent class >> isLocalMethodsProtocol: aProtocol [
	"Checks if the protocol has local selectors"

	aProtocol methods ifEmpty: [ ^ true ].
	^ aProtocol methods
		anySatisfy: [ :each | self isLocalSelector: each ]
]

{ #category : #testing }
GdsStructureViewCanvasComponent class >> isLocalSelector: aSelector [
	^ self localMethodDict includesKey: aSelector
]

{ #category : #accessing }
GdsStructureViewCanvasComponent class >> localMethodDict [
	"The local methodDict is in the metaclass. In this way I do not have to recompile the methods during the bootstrap when we don't have a compiler."

	^ self class baseLocalMethods
]

{ #category : #accessing }
GdsStructureViewCanvasComponent class >> localMethodDict: aMethodDictionary [
	^ self class baseLocalMethods: aMethodDictionary
]

{ #category : #accessing }
GdsStructureViewCanvasComponent class >> localMethods [
	"returns the methods of classes excluding the ones of the traits that the class uses"

	^ self localMethodDict values
]

{ #category : #'accessing method dictionary' }
GdsStructureViewCanvasComponent class >> localSelectors [
	^ self localMethodDict keys
]

{ #category : #initialization }
GdsStructureViewCanvasComponent class >> rebuildMethodDictionary [
	"Useful to be rewritten in Traits"

	^ self doRebuildMethodDictionary
]

{ #category : #categories }
GdsStructureViewCanvasComponent class >> recategorizeSelector: selector from: oldCategory to: newCategory [
	| original |
	"When a method is recategorized I have to classify the method, but also recategorize the aliases pointing to it"
	original := self organization
		categoryOfElement: selector
		ifAbsent: [ ^ self ].

	"If it is nil is because it is a removal. It will removed when the method is removed."
	newCategory ifNil: [ ^ self ].
	original = oldCategory
		ifTrue: [ self organization
				classify: selector
				under: newCategory
				suppressIfDefault: true ].
	(self traitComposition reverseAlias: selector)
		do: [ :e | 
			self recategorizeSelector: e from: oldCategory to: newCategory.
			self
				notifyOfRecategorizedSelector: e
				from: oldCategory
				to: newCategory ].
	self organization removeEmptyCategories
]

{ #category : #'trait-composition' }
GdsStructureViewCanvasComponent class >> removeFromComposition: aTrait [
	self
		setTraitComposition: (self traitComposition copyWithoutTrait: aTrait asTraitComposition)
]

{ #category : #removing }
GdsStructureViewCanvasComponent class >> removeFromSystem: logged [
	"When a traited class is removed the traits it is using should be updated"

	| mySubclasses |
	self traitComposition removeUser: self.
	self class traitComposition removeUser: self class.
	TraitedClass removeUser: self class.
	mySubclasses := self subclasses.
	super removeFromSystem: logged.

	"As I am a traited class my subclasses does not have the basic traited class 
	methods, so I add them."
	mySubclasses do: [ :each | each class initializeBasicMethods ]
]

{ #category : #removing }
GdsStructureViewCanvasComponent class >> removeSelector: aSelector [
	"When a selector is removed it should be notified to my users.
	Check the class TraitChange for more details"

	super removeSelector: aSelector.
	self localMethodDict removeKey: aSelector ifAbsent: [  ].
	TraitChange removeSelector: aSelector on: self
]

{ #category : #'accessing tags' }
GdsStructureViewCanvasComponent class >> tagsForMethods [
	"Any method could be tagged with multiple symbols for user purpose. 
	And class contains all method tags which used or not used yet by methods.
	For now we could only implemented it on top of Protocol. 
	It supposed to not include any method tags inherited from Traits 
	which is opposite to current Protocol implementation.
	And extension protocol is not treated as tag"

	| allProtocols |
	allProtocols := self organization protocols
		reject:
			[ :each | each name = Protocol unclassified | each isExtensionProtocol ].
	^ allProtocols
		select: [ :each | self isLocalMethodsProtocol: each ]
		thenCollect: #name
]

{ #category : #accessing }
GdsStructureViewCanvasComponent class >> traitComposition [
	"My trait composition is in my class. So I do not need to recompile the methods when installing them during bootstrap"

	^ self class baseComposition
]

{ #category : #accessing }
GdsStructureViewCanvasComponent class >> traitComposition: anObject [
	self class baseComposition: anObject
]

{ #category : #accessing }
GdsStructureViewCanvasComponent class >> traitUsers [
	"I am a traited class, I have no users, this is for compatibility with traits"

	^ #()
]

{ #category : #accessing }
GdsStructureViewCanvasComponent class >> traits [
	^ self traitComposition traits
]

{ #category : #scripts }
GdsStructureViewCanvasComponent >> canvasScript [
	^ '/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */

/* global GDS, GEO, createjs, Snap */
"use strict";

var gStructure = null;
var gStructureView = null;
var gQueue = null;
var gWaitMSecs = 300;

function loadIt() {
  $("#canvas-wrapper").css("display", "block");
  window.addEventListener("resize", function () {
    clearTimeout(gQueue);
    gQueue = setTimeout(function () {
      adjustPortSize();
    }, gWaitMSecs);
  }, false);

  adjustPortSize();
  gStructure = new GDS.Structure();
  var elms = sampleElements();
  elms.forEach(function (e) {
 	var ge = GDS.Element.fromObject(e);
    console.log(e);
	if (ge) {  
    	console.log(ge);
	   	gStructure.addElement(ge);
	}
  });


  gStructureView = new GDS.StructureView("canvas", gStructure);
  gStructureView.addMouseMoveListener(function (e) {
    $("#deviceX").html(sprintf("%5d", e.offsetX));
    $("#deviceY").html(sprintf("%5d", e.offsetY));
    var worldPoint = gStructureView.port.deviceToWorld(e.offsetX, e.offsetY);
    $("#worldX").html(sprintf("%+20.4f", worldPoint.x.roundDigits(4)));
    $("#worldY").html(sprintf("%+20.4f", worldPoint.y.roundDigits(4)));
  });

  gStructureView.fit();
}

function adjustPortSize() {
  var w = $("#canvas-wrapper").width();
  var h = $("#canvas-wrapper").height();
  $("#canvas").attr("width", w);
  $("#canvas").attr("height", h);
  if (gStructureView) {
    gStructureView.port.setSize(w, h);
  }
  $("#canvas-wrapper").css("display", "block");

}

function msg(s) {
  var msgTag = $("#msg")[0];
  if (msgTag) {
    msgTag.innerHTML = s;
  }
  console.log(s);
}

'
]

{ #category : #rendering }
GdsStructureViewCanvasComponent >> renderCanvasWrapperOn: html [
	html document
		nextPutAll:
			'    <div id="canvas-wrapper">
      <canvas id="canvas" style="display: block">
      </canvas>
    </div>
'
]

{ #category : #rendering }
GdsStructureViewCanvasComponent >> renderContentOn: html [
	html script: self sampleElements.
	html script: self canvasScript.
	self renderCanvasWrapperOn: html.
	html document addLoadScript: (JSStream this call: 'loadIt')
]

{ #category : #'as yet unclassified' }
GdsStructureViewCanvasComponent >> sampleElements [
	^ String
		streamContents: [ :s | 
			s nextPutAll: 'function sampleElements() {'.
			s lf.
			s nextPutAll: 'return'.
			s space.
			s
				nextPutAll:
					([ self structure elements ]
						on: Error
						do: [ :ex | 
							ex traceCr.
							ex return: #() ]) asJson.
			s nextPut: $;.
			s lf.
			s nextPutAll: '}'.
			s lf ]
]

{ #category : #accessing }
GdsStructureViewCanvasComponent >> structure [
	^ GdsStation default structure
]

{ #category : #hooks }
GdsStructureViewCanvasComponent >> style [
	^ '
html, body { width:100%; height:95%; }

#canvas-wrapper {
  width: calc(100%);
  height: calc(100%);
}

#canvas {
  display: block;
  border-color: rgb(79, 133, 37);
  border-width: 1px;
  background-color: gray;
	width:calc(100%);
	height:calc(100%);
}
'
]
