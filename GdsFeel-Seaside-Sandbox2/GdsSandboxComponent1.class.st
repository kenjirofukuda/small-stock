Class {
	#name : #GdsSandboxComponent1,
	#superclass : #WAComponent,
	#traits : 'THTML5Enabler',
	#classTraits : 'THTML5Enabler classTrait',
	#category : #'GdsFeel-Seaside-Sandbox2'
}

{ #category : #'accessing method dictionary' }
GdsSandboxComponent1 class >> addAndClassifySelector: selector withMethod: compiledMethod inProtocol: aCategory [
	"When a new methods is added, I add it to the localMethodDict and also propagate the changes to my users"

	self localMethodDict at: selector put: compiledMethod.
	super
		addAndClassifySelector: selector
		withMethod: compiledMethod
		inProtocol: aCategory.
	TraitChange addSelector: selector on: self
]

{ #category : #'accessing method dictionary' }
GdsSandboxComponent1 class >> addSelector: selector withMethod: compiledMethod [
	"When a new selector is installed in a class I insert the selector in the local methodDict and propagate the changes to my users"

	self localMethodDict at: selector put: compiledMethod.
	super addSelector: selector withMethod: compiledMethod.
	TraitChange addSelector: selector on: self
]

{ #category : #'accessing method dictionary' }
GdsSandboxComponent1 class >> addSelector: selector withMethod: compiledMethod notifying: requestor [
	self
		deprecated: 'Please use #addSelector:withMethod: instead'
		transformWith:
			'`@receiver addSelector: `@statements1 withMethod: `@statements2 notifying: `@statements3'
				-> '`@receiver addSelector: `@statements1 withMethod: `@statements2'.
	^ self addSelector: selector withMethod: compiledMethod
]

{ #category : #testing }
GdsSandboxComponent1 class >> canBeRoot [
	^ true
]

{ #category : #initialization }
GdsSandboxComponent1 class >> doRebuildMethodDictionary [
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
GdsSandboxComponent1 class >> findOriginClassOf: aMethod [
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
GdsSandboxComponent1 class >> findOriginMethodOf: aMethod [
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
GdsSandboxComponent1 class >> hasTraitComposition [
	^ self traitComposition isEmpty not
]

{ #category : #'class initialization' }
GdsSandboxComponent1 class >> initialize [
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
GdsSandboxComponent1 class >> isLocalMethodsProtocol: aProtocol [
	"Checks if the protocol has local selectors"

	aProtocol methods ifEmpty: [ ^ true ].
	^ aProtocol methods
		anySatisfy: [ :each | self isLocalSelector: each ]
]

{ #category : #testing }
GdsSandboxComponent1 class >> isLocalSelector: aSelector [
	^ self localMethodDict includesKey: aSelector
]

{ #category : #accessing }
GdsSandboxComponent1 class >> localMethodDict [
	"The local methodDict is in the metaclass. In this way I do not have to recompile the methods during the bootstrap when we don't have a compiler."

	^ self class baseLocalMethods
]

{ #category : #accessing }
GdsSandboxComponent1 class >> localMethodDict: aMethodDictionary [
	^ self class baseLocalMethods: aMethodDictionary
]

{ #category : #accessing }
GdsSandboxComponent1 class >> localMethods [
	"returns the methods of classes excluding the ones of the traits that the class uses"

	^ self localMethodDict values
]

{ #category : #'accessing method dictionary' }
GdsSandboxComponent1 class >> localSelectors [
	^ self localMethodDict keys
]

{ #category : #initialization }
GdsSandboxComponent1 class >> rebuildMethodDictionary [
	"Useful to be rewritten in Traits"

	^ self doRebuildMethodDictionary
]

{ #category : #categories }
GdsSandboxComponent1 class >> recategorizeSelector: selector from: oldCategory to: newCategory [
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
GdsSandboxComponent1 class >> removeFromComposition: aTrait [
	self
		setTraitComposition: (self traitComposition copyWithoutTrait: aTrait asTraitComposition)
]

{ #category : #removing }
GdsSandboxComponent1 class >> removeFromSystem: logged [
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
GdsSandboxComponent1 class >> removeSelector: aSelector [
	"When a selector is removed it should be notified to my users.
	Check the class TraitChange for more details"

	super removeSelector: aSelector.
	self localMethodDict removeKey: aSelector ifAbsent: [  ].
	TraitChange removeSelector: aSelector on: self
]

{ #category : #'accessing tags' }
GdsSandboxComponent1 class >> tagsForMethods [
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
GdsSandboxComponent1 class >> traitComposition [
	"My trait composition is in my class. So I do not need to recompile the methods when installing them during bootstrap"

	^ self class baseComposition
]

{ #category : #accessing }
GdsSandboxComponent1 class >> traitComposition: anObject [
	self class baseComposition: anObject
]

{ #category : #accessing }
GdsSandboxComponent1 class >> traitUsers [
	"I am a traited class, I have no users, this is for compatibility with traits"

	^ #()
]

{ #category : #accessing }
GdsSandboxComponent1 class >> traits [
	^ self traitComposition traits
]

{ #category : #scripts }
GdsSandboxComponent1 >> canvasScript [
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
  var sampleData = towerData();
  sampleData.nodes.forEach(function (node) {
    var p3 = node.position;
    gStructure.addElement(GDS.Point.fromXY(p3[0], p3[2]));
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
GdsSandboxComponent1 >> renderCanvasWrapperOn: html [
	html document
		nextPutAll:
			'    <div id="canvas-wrapper">
      <canvas id="canvas" style="display: block">
      </canvas>
    </div>
'
]

{ #category : #rendering }
GdsSandboxComponent1 >> renderContentOn: html [
	html script: self towerData.
	html script: self canvasScript.
	self renderNavigationButtonsOn: html.
	self renderMouseLocationtOn: html.
	self renderCanvasWrapperOn: html.
	self renderMessageAreaOn: html.
	html document addLoadScript: (JSStream this call: 'loadIt')
]

{ #category : #rendering }
GdsSandboxComponent1 >> renderCoordinateOn: html label: aLabel id: anId value: aValue [
	html
		code: [ html text: aLabel.
			html span
				id: anId;
				with: aValue ]
]

{ #category : #rendering }
GdsSandboxComponent1 >> renderMessageAreaOn: html [
	html document
		nextPutAll:
			'
    <div id="msg"></div>
'
]

{ #category : #rendering }
GdsSandboxComponent1 >> renderMouseHVLocationtOn: html [
	self
		renderCoordinateOn: html
		label: 'h:'
		id: 'deviceX'
		value: '0.0000'.
	html code: ', '.
	self
		renderCoordinateOn: html
		label: 'v:'
		id: 'deviceY'
		value: '0.0000'
]

{ #category : #rendering }
GdsSandboxComponent1 >> renderMouseLocationtOn: html [
	self renderMouseHVLocationtOn: html.
	html code: ' '.
	self renderMouseXYLocationtOn: html
]

{ #category : #rendering }
GdsSandboxComponent1 >> renderMouseXYLocationtOn: html [
	self
		renderCoordinateOn: html
		label: 'x:'
		id: 'worldX'
		value: '0.0000'.
	html code: ', '.
	self
		renderCoordinateOn: html
		label: 'y:'
		id: 'worldY'
		value: '0.0000'
]

{ #category : #rendering }
GdsSandboxComponent1 >> renderNavigationButtonsOn: html [
	html
		div: [ html buttonInput
				value: 2.0;
				onClick: ((JSStream on: 'gStructureView') call: 'zoomDouble').
			html buttonInput
				value: 0.5;
				onClick: ((JSStream on: 'gStructureView') call: 'zoomHalf').
			html buttonInput
				value: 'fit';
				onClick: ((JSStream on: 'gStructureView') call: 'fit') ]
]

{ #category : #hooks }
GdsSandboxComponent1 >> style [
	^ '
html, body { width:100%; height:95%; }

#svg-wrapper, #canvas-wrapper {
  width: 100%;
  height: 95%;
}

#canvas {
  display: block;
  border-color: rgb(79, 133, 37);
  border-width: 1px;
  background-color: gray;
}
'
]

{ #category : #scripts }
GdsSandboxComponent1 >> towerData [
	^ 'function towerData(){
return {
	"nodes" : [
		{
			"number" : 1000,
			"tags" : [
				"P13"
			],
			"type" : "slope",
			"position" : [
				0.0,
				0.0,
				21750.0
			],
			"legIndex" : 0,
			"brick" : "P13",
			"name" : "1000",
			"uuid" : "0c4de210-609a-eb41-aca9-7a8a3e4a155d",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1001,
			"tags" : [
				"P13"
			],
			"type" : "slope",
			"position" : [
				120.0,
				-120.0,
				20470.0
			],
			"legIndex" : 1,
			"brick" : "P13",
			"name" : "1001",
			"uuid" : "11afe8f1-a698-3e4a-9708-30426791701b",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1002,
			"tags" : [
				"P13"
			],
			"type" : "slope",
			"position" : [
				-120.0,
				-120.0,
				20470.0
			],
			"legIndex" : 2,
			"brick" : "P13",
			"name" : "1002",
			"uuid" : "548a11f1-54e6-d748-9138-ca413f5c6677",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1003,
			"tags" : [
				"P13"
			],
			"type" : "slope",
			"position" : [
				-120.0,
				120.0,
				20470.0
			],
			"legIndex" : 3,
			"brick" : "P13",
			"name" : "1003",
			"uuid" : "d59f7238-df4a-2542-a0b5-27c6303808dc",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1004,
			"tags" : [
				"P13"
			],
			"type" : "slope",
			"position" : [
				120.0,
				120.0,
				20470.0
			],
			"legIndex" : 4,
			"brick" : "P13",
			"name" : "1004",
			"uuid" : "e8e42ae1-b7d6-aa40-b9f4-7f431c46e409",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1005,
			"tags" : [
				"P13"
			],
			"type" : "slope",
			"position" : [
				240.0,
				-240.0,
				19190.0
			],
			"legIndex" : 1,
			"brick" : "P13",
			"name" : "1005",
			"uuid" : "77524bc1-c55e-3544-9b14-fe6c824f1afc",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1006,
			"tags" : [
				"P13"
			],
			"type" : "slope",
			"position" : [
				-240.0,
				-240.0,
				19190.0
			],
			"legIndex" : 2,
			"brick" : "P13",
			"name" : "1006",
			"uuid" : "54d598ae-4192-124f-8886-e616fcb0a92e",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1007,
			"tags" : [
				"P13"
			],
			"type" : "slope",
			"position" : [
				-240.0,
				240.0,
				19190.0
			],
			"legIndex" : 3,
			"brick" : "P13",
			"name" : "1007",
			"uuid" : "85799ac3-fa0d-3040-a780-11e9804ff9d6",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1008,
			"tags" : [
				"P13"
			],
			"type" : "slope",
			"position" : [
				240.0,
				240.0,
				19190.0
			],
			"legIndex" : 4,
			"brick" : "P13",
			"name" : "1008",
			"uuid" : "e8de5cb9-c405-ea49-bcfc-b3e0924bad83",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1009,
			"tags" : [
				"P13"
			],
			"type" : "slope",
			"position" : [
				360.0,
				-360.0,
				17910.0
			],
			"legIndex" : 1,
			"brick" : "P13",
			"name" : "1009",
			"uuid" : "5d2adcd5-9768-6948-a298-88b6d8c2f666",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1010,
			"tags" : [
				"P13"
			],
			"type" : "slope",
			"position" : [
				-360.0,
				-360.0,
				17910.0
			],
			"legIndex" : 2,
			"brick" : "P13",
			"name" : "1010",
			"uuid" : "2af4b00b-45dc-be47-b26b-61f8144a5d8e",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1011,
			"tags" : [
				"P13"
			],
			"type" : "slope",
			"position" : [
				-360.0,
				360.0,
				17910.0
			],
			"legIndex" : 3,
			"brick" : "P13",
			"name" : "1011",
			"uuid" : "9be3c888-8041-1140-af61-6296e9d68605",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1012,
			"tags" : [
				"P13"
			],
			"type" : "slope",
			"position" : [
				360.0,
				360.0,
				17910.0
			],
			"legIndex" : 4,
			"brick" : "P13",
			"name" : "1012",
			"uuid" : "820adc28-997f-f647-bbcb-b80ff014202f",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1013,
			"tags" : [
				"P13"
			],
			"type" : "slope",
			"position" : [
				480.0,
				-480.0,
				16630.0
			],
			"legIndex" : 1,
			"brick" : "P13",
			"name" : "1013",
			"uuid" : "e738ce58-4c40-9742-8388-5853af3214d4",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1014,
			"tags" : [
				"P13"
			],
			"type" : "slope",
			"position" : [
				-480.0,
				-480.0,
				16630.0
			],
			"legIndex" : 2,
			"brick" : "P13",
			"name" : "1014",
			"uuid" : "50bf4080-c7b5-aa41-a2ca-f209bdfa64fd",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1015,
			"tags" : [
				"P13"
			],
			"type" : "slope",
			"position" : [
				-480.0,
				480.0,
				16630.0
			],
			"legIndex" : 3,
			"brick" : "P13",
			"name" : "1015",
			"uuid" : "3fee3edf-0667-3048-b9f1-82682b5c547a",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1016,
			"tags" : [
				"P13"
			],
			"type" : "slope",
			"position" : [
				480.0,
				480.0,
				16630.0
			],
			"legIndex" : 4,
			"brick" : "P13",
			"name" : "1016",
			"uuid" : "74d3372a-694c-cf49-ba7c-626e653ef760",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1017,
			"tags" : [
				"B13",
				"P13"
			],
			"type" : "slope",
			"position" : [
				600.0,
				-600.0,
				15350.0
			],
			"legIndex" : 1,
			"brick" : "P13",
			"name" : "1017",
			"uuid" : "80d670c8-6c4c-6344-810c-2f28ea40ebe5",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1018,
			"tags" : [
				"P13"
			],
			"type" : "slope",
			"position" : [
				-600.0,
				-600.0,
				15350.0
			],
			"legIndex" : 2,
			"brick" : "P13",
			"name" : "1018",
			"uuid" : "3a0a42bc-9cdc-3449-a4ae-4c648cdd45a2",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1019,
			"tags" : [
				"P13"
			],
			"type" : "slope",
			"position" : [
				-600.0,
				600.0,
				15350.0
			],
			"legIndex" : 3,
			"brick" : "P13",
			"name" : "1019",
			"uuid" : "25945961-92b9-9841-9613-c78f5ea7a309",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1020,
			"tags" : [
				"B13",
				"P13"
			],
			"type" : "slope",
			"position" : [
				600.0,
				600.0,
				15350.0
			],
			"legIndex" : 4,
			"brick" : "P13",
			"name" : "1020",
			"uuid" : "297a957e-4474-5f48-bb65-5c7831b2142f",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1021,
			"tags" : [
				"B13",
				"P13"
			],
			"type" : "slope",
			"position" : [
				600.0,
				-600.0,
				14150.0
			],
			"legIndex" : 2,
			"brick" : "P13",
			"name" : "1021",
			"uuid" : "eaff7ace-4dac-8046-a75a-4422c85b5b5f",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1022,
			"tags" : [
				"P13"
			],
			"type" : "slope",
			"position" : [
				-600.0,
				-600.0,
				14150.0
			],
			"legIndex" : 2,
			"brick" : "P13",
			"name" : "1022",
			"uuid" : "4bf27e5c-f72b-4642-a750-4cc807556b52",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1023,
			"tags" : [
				"P13"
			],
			"type" : "slope",
			"position" : [
				-600.0,
				600.0,
				14150.0
			],
			"legIndex" : 3,
			"brick" : "P13",
			"name" : "1023",
			"uuid" : "487c43b1-1436-2f43-87ae-440dcd2bf45b",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1024,
			"tags" : [
				"B13",
				"P13"
			],
			"type" : "slope",
			"position" : [
				600.0,
				600.0,
				14150.0
			],
			"legIndex" : 3,
			"brick" : "P13",
			"name" : "1024",
			"uuid" : "e8e6ba76-5c9f-8b4b-bb71-b84e9ccfc56a",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1025,
			"tags" : [
				"P13"
			],
			"type" : "slope",
			"position" : [
				675.0,
				-675.0,
				12950.0
			],
			"legIndex" : 1,
			"brick" : "P13",
			"name" : "1025",
			"uuid" : "1a34ad34-894e-2a44-9044-8ab57c3022e8",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1026,
			"tags" : [
				"P13"
			],
			"type" : "slope",
			"position" : [
				-675.0,
				-675.0,
				12950.0
			],
			"legIndex" : 2,
			"brick" : "P13",
			"name" : "1026",
			"uuid" : "68e187b0-802a-ae41-a33e-98f5e335140e",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1027,
			"tags" : [
				"P13"
			],
			"type" : "slope",
			"position" : [
				-675.0,
				675.0,
				12950.0
			],
			"legIndex" : 3,
			"brick" : "P13",
			"name" : "1027",
			"uuid" : "4537f6d4-1614-6d4d-bcb4-0ae26915d4d2",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1028,
			"tags" : [
				"P13"
			],
			"type" : "slope",
			"position" : [
				675.0,
				675.0,
				12950.0
			],
			"legIndex" : 4,
			"brick" : "P13",
			"name" : "1028",
			"uuid" : "ea2ebd8a-f20d-a94f-89a1-baed2987c5f8",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1029,
			"tags" : [
				"P13"
			],
			"type" : "slope",
			"position" : [
				718.8312000000001,
				-718.8312000000001,
				12248.7013
			],
			"legIndex" : 1,
			"brick" : "P13",
			"name" : "1029",
			"uuid" : "d66090e2-d6ff-3b4f-b095-0b19d4bbd36c",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1030,
			"tags" : [
				"P13"
			],
			"type" : "slope",
			"position" : [
				-718.8312000000001,
				-718.8312000000001,
				12248.7013
			],
			"legIndex" : 2,
			"brick" : "P13",
			"name" : "1030",
			"uuid" : "42905013-52ea-554d-85ee-323384b169c8",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1031,
			"tags" : [
				"P13"
			],
			"type" : "slope",
			"position" : [
				-718.8312000000001,
				718.8312000000001,
				12248.7013
			],
			"legIndex" : 3,
			"brick" : "P13",
			"name" : "1031",
			"uuid" : "64e09c93-8ecb-2b48-9341-253557b04c42",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1032,
			"tags" : [
				"P13"
			],
			"type" : "slope",
			"position" : [
				718.8312000000001,
				718.8312000000001,
				12248.7013
			],
			"legIndex" : 4,
			"brick" : "P13",
			"name" : "1032",
			"uuid" : "a27de60f-d743-ed41-b844-ac4aa96ca22b",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1033,
			"tags" : [
				"P13"
			],
			"type" : "slope",
			"position" : [
				768.75,
				-768.75,
				11450.0
			],
			"legIndex" : 1,
			"brick" : "P13",
			"name" : "1033",
			"uuid" : "515e49de-a6ca-3640-bca2-d72d9627ab05",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1034,
			"tags" : [
				"P13"
			],
			"type" : "slope",
			"position" : [
				-768.75,
				-768.75,
				11450.0
			],
			"legIndex" : 2,
			"brick" : "P13",
			"name" : "1034",
			"uuid" : "d5a39826-7519-1040-82b3-82ba17eabc6a",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1035,
			"tags" : [
				"P13"
			],
			"type" : "slope",
			"position" : [
				-768.75,
				768.75,
				11450.0
			],
			"legIndex" : 3,
			"brick" : "P13",
			"name" : "1035",
			"uuid" : "74ad7da9-3570-564c-a5ed-8d375401590b",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1036,
			"tags" : [
				"P13"
			],
			"type" : "slope",
			"position" : [
				768.75,
				768.75,
				11450.0
			],
			"legIndex" : 4,
			"brick" : "P13",
			"name" : "1036",
			"uuid" : "e6a48daa-b05d-0047-b25c-d1cfbb592557",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1037,
			"tags" : [
				"P13"
			],
			"type" : "slope",
			"position" : [
				823.8679000000001,
				-823.8679000000001,
				10568.1132
			],
			"legIndex" : 1,
			"brick" : "P13",
			"name" : "1037",
			"uuid" : "acd53120-7618-4247-8abf-896417ccf6f3",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1038,
			"tags" : [
				"P13"
			],
			"type" : "slope",
			"position" : [
				-823.8679000000001,
				-823.8679000000001,
				10568.1132
			],
			"legIndex" : 2,
			"brick" : "P13",
			"name" : "1038",
			"uuid" : "fa73276d-47e1-8447-b8b5-3f4fb1a99879",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1039,
			"tags" : [
				"P13"
			],
			"type" : "slope",
			"position" : [
				-823.8679000000001,
				823.8679000000001,
				10568.1132
			],
			"legIndex" : 3,
			"brick" : "P13",
			"name" : "1039",
			"uuid" : "f3e36454-9fdc-c848-b80b-d0152b59956b",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1040,
			"tags" : [
				"P13"
			],
			"type" : "slope",
			"position" : [
				823.8679000000001,
				823.8679000000001,
				10568.1132
			],
			"legIndex" : 4,
			"brick" : "P13",
			"name" : "1040",
			"uuid" : "bdbbd935-442e-6342-bd97-27ffb03c6b84",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1041,
			"tags" : [
				"P13"
			],
			"type" : "slope",
			"position" : [
				887.5,
				-887.5,
				9550.0
			],
			"legIndex" : 1,
			"brick" : "P13",
			"name" : "1041",
			"uuid" : "a1436aca-1d66-554f-8e36-dd0a122e05f0",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1042,
			"tags" : [
				"P13"
			],
			"type" : "slope",
			"position" : [
				-887.5,
				-887.5,
				9550.0
			],
			"legIndex" : 2,
			"brick" : "P13",
			"name" : "1042",
			"uuid" : "a1b74ac7-2c75-f348-a1a2-720d4d7d6940",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1043,
			"tags" : [
				"P13"
			],
			"type" : "slope",
			"position" : [
				-887.5,
				887.5,
				9550.0
			],
			"legIndex" : 3,
			"brick" : "P13",
			"name" : "1043",
			"uuid" : "5010c502-75a6-754a-969d-01885b978837",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1044,
			"tags" : [
				"P13"
			],
			"type" : "slope",
			"position" : [
				887.5,
				887.5,
				9550.0
			],
			"legIndex" : 4,
			"brick" : "P13",
			"name" : "1044",
			"uuid" : "ff0edcab-81bf-2042-bd5b-beb2213ba8d7",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1045,
			"tags" : [
				"P13"
			],
			"type" : "slope",
			"position" : [
				948.6066000000001,
				-948.6066000000001,
				8572.295100000001
			],
			"legIndex" : 1,
			"brick" : "P13",
			"name" : "1045",
			"uuid" : "9907128d-c511-7c43-a43b-339d06886d7e",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1046,
			"tags" : [
				"P13"
			],
			"type" : "slope",
			"position" : [
				-948.6066000000001,
				-948.6066000000001,
				8572.295100000001
			],
			"legIndex" : 2,
			"brick" : "P13",
			"name" : "1046",
			"uuid" : "9f67919a-c776-3742-8810-565905e605d1",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1047,
			"tags" : [
				"P13"
			],
			"type" : "slope",
			"position" : [
				-948.6066000000001,
				948.6066000000001,
				8572.295100000001
			],
			"legIndex" : 3,
			"brick" : "P13",
			"name" : "1047",
			"uuid" : "f2991e59-110a-004c-ac56-21bf16b1f3bd",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1048,
			"tags" : [
				"P13"
			],
			"type" : "slope",
			"position" : [
				948.6066000000001,
				948.6066000000001,
				8572.295100000001
			],
			"legIndex" : 4,
			"brick" : "P13",
			"name" : "1048",
			"uuid" : "95f19117-e617-9b48-b97e-669e483c5ca8",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1049,
			"tags" : [
				"P13"
			],
			"type" : "slope",
			"position" : [
				1018.75,
				-1018.75,
				7450.0
			],
			"legIndex" : 1,
			"brick" : "P13",
			"name" : "1049",
			"uuid" : "798d7c91-fad7-7f4b-98f9-fb2b89d33ec0",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1050,
			"tags" : [
				"P13"
			],
			"type" : "slope",
			"position" : [
				-1018.75,
				-1018.75,
				7450.0
			],
			"legIndex" : 2,
			"brick" : "P13",
			"name" : "1050",
			"uuid" : "a4c9e267-2ee6-af44-8724-9c491e11a637",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1051,
			"tags" : [
				"P13"
			],
			"type" : "slope",
			"position" : [
				-1018.75,
				1018.75,
				7450.0
			],
			"legIndex" : 3,
			"brick" : "P13",
			"name" : "1051",
			"uuid" : "83a42a01-b395-7e4b-8338-caf87e77ba2d",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1052,
			"tags" : [
				"P13"
			],
			"type" : "slope",
			"position" : [
				1018.75,
				1018.75,
				7450.0
			],
			"legIndex" : 4,
			"brick" : "P13",
			"name" : "1052",
			"uuid" : "cbddba03-d053-ca41-b7ec-77aed592b509",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1053,
			"tags" : [
				"P13"
			],
			"type" : "slope",
			"position" : [
				1085.8883,
				-1085.8883,
				6375.7880000000005
			],
			"legIndex" : 1,
			"brick" : "P13",
			"name" : "1053",
			"uuid" : "6365839f-b47a-874e-9e4d-3c076f746a77",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1054,
			"tags" : [
				"P13"
			],
			"type" : "slope",
			"position" : [
				-1085.8883,
				-1085.8883,
				6375.7880000000005
			],
			"legIndex" : 2,
			"brick" : "P13",
			"name" : "1054",
			"uuid" : "dd14c355-5db3-9640-9b34-fc614d818172",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1055,
			"tags" : [
				"P13"
			],
			"type" : "slope",
			"position" : [
				-1085.8883,
				1085.8883,
				6375.7880000000005
			],
			"legIndex" : 3,
			"brick" : "P13",
			"name" : "1055",
			"uuid" : "10197ca1-9ff4-0247-b389-01139e3e109e",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1056,
			"tags" : [
				"P13"
			],
			"type" : "slope",
			"position" : [
				1085.8883,
				1085.8883,
				6375.7880000000005
			],
			"legIndex" : 4,
			"brick" : "P13",
			"name" : "1056",
			"uuid" : "58cb97cc-8f20-e74d-b518-187ca97351a7",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1057,
			"tags" : [
				"P13"
			],
			"type" : "slope",
			"position" : [
				1218.0008,
				-1218.0008,
				5150.0
			],
			"legIndex" : 1,
			"brick" : "P13",
			"name" : "1057",
			"uuid" : "3bba249a-8837-124f-a7c3-8e23a1d4b80e",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1058,
			"tags" : [
				"P13"
			],
			"type" : "slope",
			"position" : [
				-1218.0008,
				-1218.0008,
				5150.0
			],
			"legIndex" : 2,
			"brick" : "P13",
			"name" : "1058",
			"uuid" : "09dbbe3e-1899-6d4f-b816-fb5b398846f7",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1059,
			"tags" : [
				"P13"
			],
			"type" : "slope",
			"position" : [
				-1218.0008,
				1218.0008,
				5150.0
			],
			"legIndex" : 3,
			"brick" : "P13",
			"name" : "1059",
			"uuid" : "f600f585-7c30-ac47-b0d4-e85967bfdd2a",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1060,
			"tags" : [
				"P13"
			],
			"type" : "slope",
			"position" : [
				1218.0008,
				1218.0008,
				5150.0
			],
			"legIndex" : 4,
			"brick" : "P13",
			"name" : "1060",
			"uuid" : "ce446136-3d30-7a4e-8b2d-1e9b3f32a7e0",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1061,
			"tags" : [
				"P13"
			],
			"type" : "slope",
			"position" : [
				1339.3054,
				-1339.3054,
				4024.4915
			],
			"legIndex" : 1,
			"brick" : "P13",
			"name" : "1061",
			"uuid" : "22fcdd10-a63e-0b41-803b-be66adfa8a19",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1062,
			"tags" : [
				"P13"
			],
			"type" : "slope",
			"position" : [
				-1339.3054,
				-1339.3054,
				4024.4915
			],
			"legIndex" : 2,
			"brick" : "P13",
			"name" : "1062",
			"uuid" : "bbd2ec7d-c526-6442-b3cc-6384f5cfb955",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1063,
			"tags" : [
				"P13"
			],
			"type" : "slope",
			"position" : [
				-1339.3054,
				1339.3054,
				4024.4915
			],
			"legIndex" : 3,
			"brick" : "P13",
			"name" : "1063",
			"uuid" : "d7b3fd6f-e26c-0d43-beac-a591a07024ab",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1064,
			"tags" : [
				"P13"
			],
			"type" : "slope",
			"position" : [
				1339.3054,
				1339.3054,
				4024.4915
			],
			"legIndex" : 4,
			"brick" : "P13",
			"name" : "1064",
			"uuid" : "57af5511-c2c7-a046-be6d-a7635faf0041",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1065,
			"tags" : [
				"P13"
			],
			"type" : "slope",
			"position" : [
				1487.4449,
				-1487.4449,
				2650.0
			],
			"legIndex" : 1,
			"brick" : "P13",
			"name" : "1065",
			"uuid" : "ab7b1d0e-7b12-e641-83dd-453a53a55751",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1066,
			"tags" : [
				"P13"
			],
			"type" : "slope",
			"position" : [
				-1487.4449,
				-1487.4449,
				2650.0
			],
			"legIndex" : 2,
			"brick" : "P13",
			"name" : "1066",
			"uuid" : "5bb5cbb2-e7ff-7e44-bb9f-379e898fcd38",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1067,
			"tags" : [
				"P13"
			],
			"type" : "slope",
			"position" : [
				-1487.4449,
				1487.4449,
				2650.0
			],
			"legIndex" : 3,
			"brick" : "P13",
			"name" : "1067",
			"uuid" : "fcc88c23-7065-124a-8001-c2a07ddb6ace",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1068,
			"tags" : [
				"P13"
			],
			"type" : "slope",
			"position" : [
				1487.4449,
				1487.4449,
				2650.0
			],
			"legIndex" : 4,
			"brick" : "P13",
			"name" : "1068",
			"uuid" : "cad9eca7-90ea-ec40-8c75-dcccf219c099",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1069,
			"tags" : [
				"P13"
			],
			"type" : "slope",
			"position" : [
				1617.7409,
				-1617.7409,
				1441.0663
			],
			"legIndex" : 1,
			"brick" : "P13",
			"name" : "1069",
			"uuid" : "645f0887-741b-654a-a061-614d6884ac69",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1070,
			"tags" : [
				"P13"
			],
			"type" : "slope",
			"position" : [
				-1617.7409,
				-1617.7409,
				1441.0663
			],
			"legIndex" : 2,
			"brick" : "P13",
			"name" : "1070",
			"uuid" : "97eb4cea-dd81-1042-b9f0-f91401e64321",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1071,
			"tags" : [
				"P13"
			],
			"type" : "slope",
			"position" : [
				-1617.7409,
				1617.7409,
				1441.0663
			],
			"legIndex" : 3,
			"brick" : "P13",
			"name" : "1071",
			"uuid" : "171ada4e-a19e-5c48-a83e-8afd88bcdaaf",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1072,
			"tags" : [
				"P13"
			],
			"type" : "slope",
			"position" : [
				1617.7409,
				1617.7409,
				1441.0663
			],
			"legIndex" : 4,
			"brick" : "P13",
			"name" : "1072",
			"uuid" : "40518384-9600-5e46-84a6-c61637320e83",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1073,
			"tags" : [
				"P13"
			],
			"type" : "slope",
			"position" : [
				1773.0556000000001,
				-1773.0556000000001,
				0.0
			],
			"legIndex" : 1,
			"brick" : "P13",
			"name" : "1073",
			"uuid" : "55afb04d-99fd-c141-b5ac-d4bb5b2ef2e2",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1074,
			"tags" : [
				"P13"
			],
			"type" : "slope",
			"position" : [
				-1773.0556000000001,
				-1773.0556000000001,
				0.0
			],
			"legIndex" : 2,
			"brick" : "P13",
			"name" : "1074",
			"uuid" : "530cf43c-2b55-d745-b192-3c6cec427c04",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1075,
			"tags" : [
				"P13"
			],
			"type" : "slope",
			"position" : [
				-1773.0556000000001,
				1773.0556000000001,
				0.0
			],
			"legIndex" : 3,
			"brick" : "P13",
			"name" : "1075",
			"uuid" : "6e9e5463-4f1a-4048-afff-3b03565b7220",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1076,
			"tags" : [
				"P13"
			],
			"type" : "slope",
			"position" : [
				1773.0556000000001,
				1773.0556000000001,
				0.0
			],
			"legIndex" : 4,
			"brick" : "P13",
			"name" : "1076",
			"uuid" : "89dea590-a393-8e4b-8560-53cf3a4412d9",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1077,
			"tags" : [
				"P13"
			],
			"type" : "panel",
			"position" : [
				0.0,
				-600.0,
				14750.0
			],
			"legIndex" : -1,
			"brick" : "P13",
			"name" : "1077",
			"uuid" : "b875d315-6842-0048-9170-daebe0c26d4b",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1078,
			"tags" : [
				"P13"
			],
			"type" : "panel",
			"position" : [
				-600.0,
				0.0,
				14750.0
			],
			"legIndex" : -1,
			"brick" : "P13",
			"name" : "1078",
			"uuid" : "de17d8c7-63e6-3d47-85a4-83f76380f235",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1079,
			"tags" : [
				"P13"
			],
			"type" : "panel",
			"position" : [
				0.0,
				600.0,
				14750.0
			],
			"legIndex" : -1,
			"brick" : "P13",
			"name" : "1079",
			"uuid" : "02ebac90-30d9-e342-bf90-0df1536731a3",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1080,
			"tags" : [
				"P13"
			],
			"type" : "panel",
			"position" : [
				600.0,
				0.0,
				14750.0
			],
			"legIndex" : -1,
			"brick" : "P13",
			"name" : "1080",
			"uuid" : "a8835ba5-7c95-a344-b82a-d7f9ee008923",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1081,
			"tags" : [
				"P13"
			],
			"type" : "panel",
			"position" : [
				0.0,
				-635.2941000000001,
				13585.294100000001
			],
			"legIndex" : -1,
			"brick" : "P13",
			"name" : "1081",
			"uuid" : "c927e48c-94b3-ff4d-8293-c1d8f2c7951d",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1082,
			"tags" : [
				"P13"
			],
			"type" : "panel",
			"position" : [
				-635.2941000000001,
				0.0,
				13585.294100000001
			],
			"legIndex" : -1,
			"brick" : "P13",
			"name" : "1082",
			"uuid" : "da0f1734-c989-e646-a0a5-d3f1999d23f4",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1083,
			"tags" : [
				"P13"
			],
			"type" : "panel",
			"position" : [
				0.0,
				635.2941000000001,
				13585.294100000001
			],
			"legIndex" : -1,
			"brick" : "P13",
			"name" : "1083",
			"uuid" : "18b6c88b-912a-744e-9a0b-f2b1e0d43227",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1084,
			"tags" : [
				"P13"
			],
			"type" : "panel",
			"position" : [
				635.2941000000001,
				0.0,
				13585.294100000001
			],
			"legIndex" : -1,
			"brick" : "P13",
			"name" : "1084",
			"uuid" : "9f702971-8382-7e47-8cfa-bdbc3d8fe662",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1085,
			"tags" : [
				"P13"
			],
			"type" : "panel",
			"position" : [
				0.0,
				-718.8312000000001,
				12248.7013
			],
			"legIndex" : -1,
			"brick" : "P13",
			"name" : "1085",
			"uuid" : "0f51d148-3c23-dd40-a148-85fd1c9279bf",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1086,
			"tags" : [
				"P13"
			],
			"type" : "panel",
			"position" : [
				-718.8312000000001,
				0.0,
				12248.7013
			],
			"legIndex" : -1,
			"brick" : "P13",
			"name" : "1086",
			"uuid" : "74447f7f-df9e-e54f-9b6d-bcf03885be5f",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1087,
			"tags" : [
				"P13"
			],
			"type" : "panel",
			"position" : [
				0.0,
				718.8312000000001,
				12248.7013
			],
			"legIndex" : -1,
			"brick" : "P13",
			"name" : "1087",
			"uuid" : "e27f5541-28ef-e746-9e3b-95add36b1704",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1088,
			"tags" : [
				"P13"
			],
			"type" : "panel",
			"position" : [
				718.8312000000001,
				0.0,
				12248.7013
			],
			"legIndex" : -1,
			"brick" : "P13",
			"name" : "1088",
			"uuid" : "f8998538-3cfb-c248-a46c-dd19a5572048",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1089,
			"tags" : [
				"P13"
			],
			"type" : "panel",
			"position" : [
				0.0,
				-823.8679000000001,
				10568.1132
			],
			"legIndex" : -1,
			"brick" : "P13",
			"name" : "1089",
			"uuid" : "a802605b-c3b3-9c4c-90f6-728014304a1d",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1090,
			"tags" : [
				"P13"
			],
			"type" : "panel",
			"position" : [
				-823.8679000000001,
				0.0,
				10568.1132
			],
			"legIndex" : -1,
			"brick" : "P13",
			"name" : "1090",
			"uuid" : "4503a267-36b6-1141-9776-b6666c6d4558",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1091,
			"tags" : [
				"P13"
			],
			"type" : "panel",
			"position" : [
				0.0,
				823.8679000000001,
				10568.1132
			],
			"legIndex" : -1,
			"brick" : "P13",
			"name" : "1091",
			"uuid" : "9f65ee19-b09a-b043-926d-daa923bab387",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1092,
			"tags" : [
				"P13"
			],
			"type" : "panel",
			"position" : [
				823.8679000000001,
				0.0,
				10568.1132
			],
			"legIndex" : -1,
			"brick" : "P13",
			"name" : "1092",
			"uuid" : "63934ca2-c6b0-f543-a04b-893f72e40dc5",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1093,
			"tags" : [
				"P13"
			],
			"type" : "panel",
			"position" : [
				0.0,
				-948.6066000000001,
				8572.295100000001
			],
			"legIndex" : -1,
			"brick" : "P13",
			"name" : "1093",
			"uuid" : "025d2ddc-0009-614c-81cc-a10d895e33f9",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1094,
			"tags" : [
				"P13"
			],
			"type" : "panel",
			"position" : [
				-948.6066000000001,
				0.0,
				8572.295100000001
			],
			"legIndex" : -1,
			"brick" : "P13",
			"name" : "1094",
			"uuid" : "a38f87a1-91a4-5c49-ab0d-57a8fcf23fcb",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1095,
			"tags" : [
				"P13"
			],
			"type" : "panel",
			"position" : [
				0.0,
				948.6066000000001,
				8572.295100000001
			],
			"legIndex" : -1,
			"brick" : "P13",
			"name" : "1095",
			"uuid" : "1a74427f-e232-f94d-aa8e-0a603e083788",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1096,
			"tags" : [
				"P13"
			],
			"type" : "panel",
			"position" : [
				948.6066000000001,
				0.0,
				8572.295100000001
			],
			"legIndex" : -1,
			"brick" : "P13",
			"name" : "1096",
			"uuid" : "5aaacc36-9f91-9246-98cb-9fd71f4da28e",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1097,
			"tags" : [
				"P13"
			],
			"type" : "panel",
			"position" : [
				0.0,
				-1085.8883,
				6375.7880000000005
			],
			"legIndex" : -1,
			"brick" : "P13",
			"name" : "1097",
			"uuid" : "86f4d001-61a8-5e4e-bec3-25a74d5d714a",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1098,
			"tags" : [
				"P13"
			],
			"type" : "panel",
			"position" : [
				-1085.8883,
				0.0,
				6375.7880000000005
			],
			"legIndex" : -1,
			"brick" : "P13",
			"name" : "1098",
			"uuid" : "756c2150-f86b-ff48-b762-6b3f1a4cfe45",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1099,
			"tags" : [
				"P13"
			],
			"type" : "panel",
			"position" : [
				0.0,
				1085.8883,
				6375.7880000000005
			],
			"legIndex" : -1,
			"brick" : "P13",
			"name" : "1099",
			"uuid" : "fe66238a-c3a7-2740-8309-147f6398101f",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1100,
			"tags" : [
				"P13"
			],
			"type" : "panel",
			"position" : [
				1085.8883,
				0.0,
				6375.7880000000005
			],
			"legIndex" : -1,
			"brick" : "P13",
			"name" : "1100",
			"uuid" : "f4d68f35-eabc-3347-960c-cfdba58d11fc",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1101,
			"tags" : [
				"P13"
			],
			"type" : "panel",
			"position" : [
				0.0,
				-1339.3054,
				4024.4915
			],
			"legIndex" : -1,
			"brick" : "P13",
			"name" : "1101",
			"uuid" : "2a8e8a89-5482-c345-90b5-876896aa2a22",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1102,
			"tags" : [
				"P13"
			],
			"type" : "panel",
			"position" : [
				-1339.3054,
				0.0,
				4024.4915
			],
			"legIndex" : -1,
			"brick" : "P13",
			"name" : "1102",
			"uuid" : "d0c0107d-79fe-9e46-8517-8483a6fd3f41",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1103,
			"tags" : [
				"P13"
			],
			"type" : "panel",
			"position" : [
				0.0,
				1339.3054,
				4024.4915
			],
			"legIndex" : -1,
			"brick" : "P13",
			"name" : "1103",
			"uuid" : "6a1edbcc-c6f9-a84c-8e98-931adbd6ad4a",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1104,
			"tags" : [
				"P13"
			],
			"type" : "panel",
			"position" : [
				1339.3054,
				0.0,
				4024.4915
			],
			"legIndex" : -1,
			"brick" : "P13",
			"name" : "1104",
			"uuid" : "a4d6273a-c9d3-8d40-91ca-62e5d44768fd",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1105,
			"tags" : [
				"P13"
			],
			"type" : "panel",
			"position" : [
				0.0,
				-1617.7409,
				1441.0663
			],
			"legIndex" : -1,
			"brick" : "P13",
			"name" : "1105",
			"uuid" : "0943fd7c-d396-5042-b188-53b070fe5890",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1106,
			"tags" : [
				"P13"
			],
			"type" : "panel",
			"position" : [
				-1617.7409,
				0.0,
				1441.0663
			],
			"legIndex" : -1,
			"brick" : "P13",
			"name" : "1106",
			"uuid" : "5bb52d6b-cacc-ff41-a388-b87895e8bddd",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1107,
			"tags" : [
				"P13"
			],
			"type" : "panel",
			"position" : [
				0.0,
				1617.7409,
				1441.0663
			],
			"legIndex" : -1,
			"brick" : "P13",
			"name" : "1107",
			"uuid" : "7bd2d469-ce3b-c345-a1d6-ef669d86cf75",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1108,
			"tags" : [
				"P13"
			],
			"type" : "panel",
			"position" : [
				1617.7409,
				0.0,
				1441.0663
			],
			"legIndex" : -1,
			"brick" : "P13",
			"name" : "1108",
			"uuid" : "9b0c2767-c963-f04c-bd3e-c5577938e2ab",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1201,
			"tags" : [
				"B14",
				"P14"
			],
			"type" : "slope",
			"position" : [
				16600.0,
				-600.0,
				15350.0
			],
			"legIndex" : 1,
			"brick" : "P14",
			"name" : "1201",
			"uuid" : "d04b59ea-2a0e-ca46-a810-c07ee1ec40b8",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1202,
			"tags" : [
				"B13",
				"P14"
			],
			"type" : "slope",
			"position" : [
				15400.0,
				-600.0,
				15350.0
			],
			"legIndex" : 1,
			"brick" : "P14",
			"name" : "1202",
			"uuid" : "70731cef-7195-b049-975b-c843c2c8d5ad",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1203,
			"tags" : [
				"B13",
				"P14"
			],
			"type" : "slope",
			"position" : [
				15400.0,
				600.0,
				15350.0
			],
			"legIndex" : 4,
			"brick" : "P14",
			"name" : "1203",
			"uuid" : "9148bb3c-84dc-6348-82e6-5545a8bf7ec5",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1204,
			"tags" : [
				"B14",
				"P14"
			],
			"type" : "slope",
			"position" : [
				16600.0,
				600.0,
				15350.0
			],
			"legIndex" : 4,
			"brick" : "P14",
			"name" : "1204",
			"uuid" : "6559e8f6-c02c-dd47-a2fe-cd2c85e010e2",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1205,
			"tags" : [
				"B14",
				"P14"
			],
			"type" : "slope",
			"position" : [
				16600.0,
				-600.0,
				14150.0
			],
			"legIndex" : 2,
			"brick" : "P14",
			"name" : "1205",
			"uuid" : "86ebee4f-9957-1b46-8d25-278eec54555e",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1206,
			"tags" : [
				"B13",
				"P14"
			],
			"type" : "slope",
			"position" : [
				15400.0,
				-600.0,
				14150.0
			],
			"legIndex" : 2,
			"brick" : "P14",
			"name" : "1206",
			"uuid" : "78241c69-842f-0949-a012-4f3ae825715b",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1207,
			"tags" : [
				"B13",
				"P14"
			],
			"type" : "slope",
			"position" : [
				15400.0,
				600.0,
				14150.0
			],
			"legIndex" : 3,
			"brick" : "P14",
			"name" : "1207",
			"uuid" : "bae6c983-ed78-b141-aad0-c2edce949b58",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1208,
			"tags" : [
				"B14",
				"P14"
			],
			"type" : "slope",
			"position" : [
				16600.0,
				600.0,
				14150.0
			],
			"legIndex" : 3,
			"brick" : "P14",
			"name" : "1208",
			"uuid" : "ec68aa24-255e-524c-99a2-17ac76ee63df",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1209,
			"tags" : [
				"P14"
			],
			"type" : "slope",
			"position" : [
				16675.0,
				-675.0,
				12950.0
			],
			"legIndex" : 1,
			"brick" : "P14",
			"name" : "1209",
			"uuid" : "40372d30-9bba-9a45-9969-d94ebd9f11dd",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1210,
			"tags" : [
				"P14"
			],
			"type" : "slope",
			"position" : [
				15325.0,
				-675.0,
				12950.0
			],
			"legIndex" : 2,
			"brick" : "P14",
			"name" : "1210",
			"uuid" : "e2a0bc70-19ac-a648-b7d3-35533e19d2ed",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1211,
			"tags" : [
				"P14"
			],
			"type" : "slope",
			"position" : [
				15325.0,
				675.0,
				12950.0
			],
			"legIndex" : 3,
			"brick" : "P14",
			"name" : "1211",
			"uuid" : "f7effbc8-e1c8-1d40-9e0c-88545da362e3",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1212,
			"tags" : [
				"P14"
			],
			"type" : "slope",
			"position" : [
				16675.0,
				675.0,
				12950.0
			],
			"legIndex" : 4,
			"brick" : "P14",
			"name" : "1212",
			"uuid" : "060752b7-33e7-ed41-af60-70c8edd0539b",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1213,
			"tags" : [
				"P14"
			],
			"type" : "slope",
			"position" : [
				16718.8312,
				-718.8312000000001,
				12248.7013
			],
			"legIndex" : 1,
			"brick" : "P14",
			"name" : "1213",
			"uuid" : "f2abaf93-990c-d542-a5c1-1305182a4d5f",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1214,
			"tags" : [
				"P14"
			],
			"type" : "slope",
			"position" : [
				15281.168800000001,
				-718.8312000000001,
				12248.7013
			],
			"legIndex" : 2,
			"brick" : "P14",
			"name" : "1214",
			"uuid" : "10a33de6-a6d1-ad4f-98ba-f5a22c8a1415",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1215,
			"tags" : [
				"P14"
			],
			"type" : "slope",
			"position" : [
				15281.168800000001,
				718.8312000000001,
				12248.7013
			],
			"legIndex" : 3,
			"brick" : "P14",
			"name" : "1215",
			"uuid" : "3b1e6222-318f-4840-8c02-17a91261ab26",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1216,
			"tags" : [
				"P14"
			],
			"type" : "slope",
			"position" : [
				16718.8312,
				718.8312000000001,
				12248.7013
			],
			"legIndex" : 4,
			"brick" : "P14",
			"name" : "1216",
			"uuid" : "d700ddba-813f-1a4d-b7b8-33a34c1c9dd2",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1217,
			"tags" : [
				"P14"
			],
			"type" : "slope",
			"position" : [
				16768.75,
				-768.75,
				11450.0
			],
			"legIndex" : 1,
			"brick" : "P14",
			"name" : "1217",
			"uuid" : "b88785de-2ce6-1e42-9ac7-12a11cc157e4",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1218,
			"tags" : [
				"P14"
			],
			"type" : "slope",
			"position" : [
				15231.25,
				-768.75,
				11450.0
			],
			"legIndex" : 2,
			"brick" : "P14",
			"name" : "1218",
			"uuid" : "58ae6b81-7ef3-bc4b-a677-66d0421d0ceb",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1219,
			"tags" : [
				"P14"
			],
			"type" : "slope",
			"position" : [
				15231.25,
				768.75,
				11450.0
			],
			"legIndex" : 3,
			"brick" : "P14",
			"name" : "1219",
			"uuid" : "dbc2a06c-6800-7942-a2a0-56dd6a5c4bc7",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1220,
			"tags" : [
				"P14"
			],
			"type" : "slope",
			"position" : [
				16768.75,
				768.75,
				11450.0
			],
			"legIndex" : 4,
			"brick" : "P14",
			"name" : "1220",
			"uuid" : "1b8d1a60-3d30-e24d-a0ed-dc17aee4e80e",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1221,
			"tags" : [
				"P14"
			],
			"type" : "slope",
			"position" : [
				16823.8679,
				-823.8679000000001,
				10568.1132
			],
			"legIndex" : 1,
			"brick" : "P14",
			"name" : "1221",
			"uuid" : "7016eb24-5418-8e4c-af8b-e2d918d1e68e",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1222,
			"tags" : [
				"P14"
			],
			"type" : "slope",
			"position" : [
				15176.1321,
				-823.8679000000001,
				10568.1132
			],
			"legIndex" : 2,
			"brick" : "P14",
			"name" : "1222",
			"uuid" : "8e84c39a-55e5-8c42-9ab5-6dac84985838",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1223,
			"tags" : [
				"P14"
			],
			"type" : "slope",
			"position" : [
				15176.1321,
				823.8679000000001,
				10568.1132
			],
			"legIndex" : 3,
			"brick" : "P14",
			"name" : "1223",
			"uuid" : "044cde9b-18c0-224d-80ab-0636512b833e",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1224,
			"tags" : [
				"P14"
			],
			"type" : "slope",
			"position" : [
				16823.8679,
				823.8679000000001,
				10568.1132
			],
			"legIndex" : 4,
			"brick" : "P14",
			"name" : "1224",
			"uuid" : "d63a5ed9-ef8e-0f45-b0d5-8079fd727d8b",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1225,
			"tags" : [
				"P14"
			],
			"type" : "slope",
			"position" : [
				16887.5,
				-887.5,
				9550.0
			],
			"legIndex" : 1,
			"brick" : "P14",
			"name" : "1225",
			"uuid" : "3898b225-bf9d-7842-a403-23ea77e51187",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1226,
			"tags" : [
				"P14"
			],
			"type" : "slope",
			"position" : [
				15112.5,
				-887.5,
				9550.0
			],
			"legIndex" : 2,
			"brick" : "P14",
			"name" : "1226",
			"uuid" : "3d859edc-39b4-6649-ad0d-b6753edd38a4",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1227,
			"tags" : [
				"P14"
			],
			"type" : "slope",
			"position" : [
				15112.5,
				887.5,
				9550.0
			],
			"legIndex" : 3,
			"brick" : "P14",
			"name" : "1227",
			"uuid" : "04fc0344-9f97-b449-b149-94c378c9f75b",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1228,
			"tags" : [
				"P14"
			],
			"type" : "slope",
			"position" : [
				16887.5,
				887.5,
				9550.0
			],
			"legIndex" : 4,
			"brick" : "P14",
			"name" : "1228",
			"uuid" : "b55adfea-0633-e147-a567-2758c0b0be0b",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1229,
			"tags" : [
				"P14"
			],
			"type" : "slope",
			"position" : [
				16948.6066,
				-948.6066000000001,
				8572.295100000001
			],
			"legIndex" : 1,
			"brick" : "P14",
			"name" : "1229",
			"uuid" : "f676fcb4-3dce-374c-b8cf-26a731773818",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1230,
			"tags" : [
				"P14"
			],
			"type" : "slope",
			"position" : [
				15051.3934,
				-948.6066000000001,
				8572.295100000001
			],
			"legIndex" : 2,
			"brick" : "P14",
			"name" : "1230",
			"uuid" : "0df394cf-edfe-7a44-a550-ad2a90c3a066",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1231,
			"tags" : [
				"P14"
			],
			"type" : "slope",
			"position" : [
				15051.3934,
				948.6066000000001,
				8572.295100000001
			],
			"legIndex" : 3,
			"brick" : "P14",
			"name" : "1231",
			"uuid" : "1aa170fd-3aea-3149-a733-aaf18527bc8b",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1232,
			"tags" : [
				"P14"
			],
			"type" : "slope",
			"position" : [
				16948.6066,
				948.6066000000001,
				8572.295100000001
			],
			"legIndex" : 4,
			"brick" : "P14",
			"name" : "1232",
			"uuid" : "ebdc727b-7a7c-534c-be58-61df243b664e",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1233,
			"tags" : [
				"P14"
			],
			"type" : "slope",
			"position" : [
				17018.75,
				-1018.75,
				7450.0
			],
			"legIndex" : 1,
			"brick" : "P14",
			"name" : "1233",
			"uuid" : "8a82a818-5b20-b049-812d-27dcfe539d7f",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1234,
			"tags" : [
				"P14"
			],
			"type" : "slope",
			"position" : [
				14981.25,
				-1018.75,
				7450.0
			],
			"legIndex" : 2,
			"brick" : "P14",
			"name" : "1234",
			"uuid" : "2367dd59-76ab-3448-8028-f3d64166c1bc",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1235,
			"tags" : [
				"P14"
			],
			"type" : "slope",
			"position" : [
				14981.25,
				1018.75,
				7450.0
			],
			"legIndex" : 3,
			"brick" : "P14",
			"name" : "1235",
			"uuid" : "bc5b31a9-3ef3-6b46-b81e-8db3ca553cc1",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1236,
			"tags" : [
				"P14"
			],
			"type" : "slope",
			"position" : [
				17018.75,
				1018.75,
				7450.0
			],
			"legIndex" : 4,
			"brick" : "P14",
			"name" : "1236",
			"uuid" : "3c6f6a56-8c01-4449-a36f-b1d6d3461a2c",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1237,
			"tags" : [
				"P14"
			],
			"type" : "slope",
			"position" : [
				17085.888300000002,
				-1085.8883,
				6375.7880000000005
			],
			"legIndex" : 1,
			"brick" : "P14",
			"name" : "1237",
			"uuid" : "df874141-52bf-a449-842c-cb7ddefbf491",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1238,
			"tags" : [
				"P14"
			],
			"type" : "slope",
			"position" : [
				14914.111700000001,
				-1085.8883,
				6375.7880000000005
			],
			"legIndex" : 2,
			"brick" : "P14",
			"name" : "1238",
			"uuid" : "90b97940-3e68-7341-8ec0-42b9f45356f3",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1239,
			"tags" : [
				"P14"
			],
			"type" : "slope",
			"position" : [
				14914.111700000001,
				1085.8883,
				6375.7880000000005
			],
			"legIndex" : 3,
			"brick" : "P14",
			"name" : "1239",
			"uuid" : "cbd81747-5123-2742-85c1-e5f6b1ee96b8",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1240,
			"tags" : [
				"P14"
			],
			"type" : "slope",
			"position" : [
				17085.888300000002,
				1085.8883,
				6375.7880000000005
			],
			"legIndex" : 4,
			"brick" : "P14",
			"name" : "1240",
			"uuid" : "e6b8a40c-bf52-924c-9db9-56adced54ad5",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1241,
			"tags" : [
				"P14"
			],
			"type" : "slope",
			"position" : [
				17218.0008,
				-1218.0008,
				5150.0
			],
			"legIndex" : 1,
			"brick" : "P14",
			"name" : "1241",
			"uuid" : "67db87c2-a273-6d45-ac1c-44712ab4bd2d",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1242,
			"tags" : [
				"P14"
			],
			"type" : "slope",
			"position" : [
				14781.9992,
				-1218.0008,
				5150.0
			],
			"legIndex" : 2,
			"brick" : "P14",
			"name" : "1242",
			"uuid" : "8355f745-dae1-154e-8ef4-4a8700b93817",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1243,
			"tags" : [
				"P14"
			],
			"type" : "slope",
			"position" : [
				14781.9992,
				1218.0008,
				5150.0
			],
			"legIndex" : 3,
			"brick" : "P14",
			"name" : "1243",
			"uuid" : "ba6291a8-94e6-6846-a447-29b3ff61be7b",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1244,
			"tags" : [
				"P14"
			],
			"type" : "slope",
			"position" : [
				17218.0008,
				1218.0008,
				5150.0
			],
			"legIndex" : 4,
			"brick" : "P14",
			"name" : "1244",
			"uuid" : "088d2ab2-dfda-8a49-bbd4-9f998ffadb79",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1245,
			"tags" : [
				"P14"
			],
			"type" : "slope",
			"position" : [
				17339.3054,
				-1339.3054,
				4024.4915
			],
			"legIndex" : 1,
			"brick" : "P14",
			"name" : "1245",
			"uuid" : "ac1a494f-ba2a-fc42-ba25-14baa196f2e7",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1246,
			"tags" : [
				"P14"
			],
			"type" : "slope",
			"position" : [
				14660.6946,
				-1339.3054,
				4024.4915
			],
			"legIndex" : 2,
			"brick" : "P14",
			"name" : "1246",
			"uuid" : "2075453a-2c6e-a340-be47-aee50f925837",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1247,
			"tags" : [
				"P14"
			],
			"type" : "slope",
			"position" : [
				14660.6946,
				1339.3054,
				4024.4915
			],
			"legIndex" : 3,
			"brick" : "P14",
			"name" : "1247",
			"uuid" : "ea33eac2-7c1e-954a-8c00-885a38af5c23",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1248,
			"tags" : [
				"P14"
			],
			"type" : "slope",
			"position" : [
				17339.3054,
				1339.3054,
				4024.4915
			],
			"legIndex" : 4,
			"brick" : "P14",
			"name" : "1248",
			"uuid" : "659533ab-7880-4845-aae8-70f04889ea2d",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1249,
			"tags" : [
				"P14"
			],
			"type" : "slope",
			"position" : [
				17487.444900000002,
				-1487.4449,
				2650.0
			],
			"legIndex" : 1,
			"brick" : "P14",
			"name" : "1249",
			"uuid" : "9a8d53d5-f19f-f346-903e-2208774c5681",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1250,
			"tags" : [
				"P14"
			],
			"type" : "slope",
			"position" : [
				14512.555100000001,
				-1487.4449,
				2650.0
			],
			"legIndex" : 2,
			"brick" : "P14",
			"name" : "1250",
			"uuid" : "31e35566-fcf9-8143-a3f8-318755e72832",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1251,
			"tags" : [
				"P14"
			],
			"type" : "slope",
			"position" : [
				14512.555100000001,
				1487.4449,
				2650.0
			],
			"legIndex" : 3,
			"brick" : "P14",
			"name" : "1251",
			"uuid" : "900b5073-b967-ba4c-b372-bf2fab5887cc",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1252,
			"tags" : [
				"P14"
			],
			"type" : "slope",
			"position" : [
				17487.444900000002,
				1487.4449,
				2650.0
			],
			"legIndex" : 4,
			"brick" : "P14",
			"name" : "1252",
			"uuid" : "66d6f919-fff6-5648-9b53-cbfb95411be8",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1253,
			"tags" : [
				"P14"
			],
			"type" : "slope",
			"position" : [
				17617.7409,
				-1617.7409,
				1441.0663
			],
			"legIndex" : 1,
			"brick" : "P14",
			"name" : "1253",
			"uuid" : "e6863d0a-a59a-874f-a6f8-c2d28aed7790",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1254,
			"tags" : [
				"P14"
			],
			"type" : "slope",
			"position" : [
				14382.259100000001,
				-1617.7409,
				1441.0663
			],
			"legIndex" : 2,
			"brick" : "P14",
			"name" : "1254",
			"uuid" : "c857dd1d-5798-ee4e-9805-35919eba5f09",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1255,
			"tags" : [
				"P14"
			],
			"type" : "slope",
			"position" : [
				14382.259100000001,
				1617.7409,
				1441.0663
			],
			"legIndex" : 3,
			"brick" : "P14",
			"name" : "1255",
			"uuid" : "26c8b0e1-c347-e24f-8880-be67caff3a39",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1256,
			"tags" : [
				"P14"
			],
			"type" : "slope",
			"position" : [
				17617.7409,
				1617.7409,
				1441.0663
			],
			"legIndex" : 4,
			"brick" : "P14",
			"name" : "1256",
			"uuid" : "6707bb50-4fcd-8142-a7ea-79c5fa30398f",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1257,
			"tags" : [
				"P14"
			],
			"type" : "slope",
			"position" : [
				17773.0556,
				-1773.0556000000001,
				0.0
			],
			"legIndex" : 1,
			"brick" : "P14",
			"name" : "1257",
			"uuid" : "d4e2e058-848b-3740-9367-54ae16d2ae24",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1258,
			"tags" : [
				"P14"
			],
			"type" : "slope",
			"position" : [
				14226.9444,
				-1773.0556000000001,
				0.0
			],
			"legIndex" : 2,
			"brick" : "P14",
			"name" : "1258",
			"uuid" : "05e35022-4191-284a-a30e-e12dad0589b2",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1259,
			"tags" : [
				"P14"
			],
			"type" : "slope",
			"position" : [
				14226.9444,
				1773.0556000000001,
				0.0
			],
			"legIndex" : 3,
			"brick" : "P14",
			"name" : "1259",
			"uuid" : "53cafb85-285e-334c-bcc3-87477adcbdc3",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1260,
			"tags" : [
				"P14"
			],
			"type" : "slope",
			"position" : [
				17773.0556,
				1773.0556000000001,
				0.0
			],
			"legIndex" : 4,
			"brick" : "P14",
			"name" : "1260",
			"uuid" : "6ecbf9f3-507c-2a4f-9926-6a85ba75c77e",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1261,
			"tags" : [
				"P14"
			],
			"type" : "panel",
			"position" : [
				16000.0,
				-600.0,
				14750.0
			],
			"legIndex" : -1,
			"brick" : "P14",
			"name" : "1261",
			"uuid" : "b2e40a42-7422-9d4f-a792-38c3cd41e129",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1262,
			"tags" : [
				"P14"
			],
			"type" : "panel",
			"position" : [
				15400.0,
				0.0,
				14750.0
			],
			"legIndex" : -1,
			"brick" : "P14",
			"name" : "1262",
			"uuid" : "cc7c0775-2198-7b4f-86f0-98f20d06e0cd",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1263,
			"tags" : [
				"P14"
			],
			"type" : "panel",
			"position" : [
				16000.0,
				600.0,
				14750.0
			],
			"legIndex" : -1,
			"brick" : "P14",
			"name" : "1263",
			"uuid" : "88add0cf-12ed-b443-aed8-3caa63de461e",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1264,
			"tags" : [
				"P14"
			],
			"type" : "panel",
			"position" : [
				16600.0,
				0.0,
				14750.0
			],
			"legIndex" : -1,
			"brick" : "P14",
			"name" : "1264",
			"uuid" : "0943cb0a-1bba-9142-beab-ea4ee939abfd",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1265,
			"tags" : [
				"P14"
			],
			"type" : "panel",
			"position" : [
				16000.0,
				-635.2941000000001,
				13585.294100000001
			],
			"legIndex" : -1,
			"brick" : "P14",
			"name" : "1265",
			"uuid" : "ac014740-4688-074b-8166-5e203f58c029",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1266,
			"tags" : [
				"P14"
			],
			"type" : "panel",
			"position" : [
				15364.7059,
				0.0,
				13585.294100000001
			],
			"legIndex" : -1,
			"brick" : "P14",
			"name" : "1266",
			"uuid" : "2514c95d-e525-4d4d-8460-de670c5be1f5",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1267,
			"tags" : [
				"P14"
			],
			"type" : "panel",
			"position" : [
				16000.0,
				635.2941000000001,
				13585.294100000001
			],
			"legIndex" : -1,
			"brick" : "P14",
			"name" : "1267",
			"uuid" : "b847864f-ed48-c645-8cd6-9ba3d7d3651b",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1268,
			"tags" : [
				"P14"
			],
			"type" : "panel",
			"position" : [
				16635.2941,
				0.0,
				13585.294100000001
			],
			"legIndex" : -1,
			"brick" : "P14",
			"name" : "1268",
			"uuid" : "d5366e76-49db-104b-ab52-60e6755a341e",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1269,
			"tags" : [
				"P14"
			],
			"type" : "panel",
			"position" : [
				16000.0,
				-718.8312000000001,
				12248.7013
			],
			"legIndex" : -1,
			"brick" : "P14",
			"name" : "1269",
			"uuid" : "02658fcc-6ff6-fc46-87af-283f942911ea",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1270,
			"tags" : [
				"P14"
			],
			"type" : "panel",
			"position" : [
				15281.168800000001,
				0.0,
				12248.7013
			],
			"legIndex" : -1,
			"brick" : "P14",
			"name" : "1270",
			"uuid" : "0865b620-61f1-9a40-a872-320be5810628",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1271,
			"tags" : [
				"P14"
			],
			"type" : "panel",
			"position" : [
				16000.0,
				718.8312000000001,
				12248.7013
			],
			"legIndex" : -1,
			"brick" : "P14",
			"name" : "1271",
			"uuid" : "58709891-7cad-834c-92ab-76e0b699e30f",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1272,
			"tags" : [
				"P14"
			],
			"type" : "panel",
			"position" : [
				16718.8312,
				0.0,
				12248.7013
			],
			"legIndex" : -1,
			"brick" : "P14",
			"name" : "1272",
			"uuid" : "ef261c76-ab05-ab42-b785-494017a3932d",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1273,
			"tags" : [
				"P14"
			],
			"type" : "panel",
			"position" : [
				16000.0,
				-823.8679000000001,
				10568.1132
			],
			"legIndex" : -1,
			"brick" : "P14",
			"name" : "1273",
			"uuid" : "b1d85ec1-d3cb-024d-a0c2-4b137dc1ec13",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1274,
			"tags" : [
				"P14"
			],
			"type" : "panel",
			"position" : [
				15176.1321,
				0.0,
				10568.1132
			],
			"legIndex" : -1,
			"brick" : "P14",
			"name" : "1274",
			"uuid" : "982416a2-3d1f-d446-bdbd-5c43bee6083e",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1275,
			"tags" : [
				"P14"
			],
			"type" : "panel",
			"position" : [
				16000.0,
				823.8679000000001,
				10568.1132
			],
			"legIndex" : -1,
			"brick" : "P14",
			"name" : "1275",
			"uuid" : "1ab59064-59ec-e74a-b710-719811abd224",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1276,
			"tags" : [
				"P14"
			],
			"type" : "panel",
			"position" : [
				16823.8679,
				0.0,
				10568.1132
			],
			"legIndex" : -1,
			"brick" : "P14",
			"name" : "1276",
			"uuid" : "ddb8066c-f9a6-3a4e-a227-3f4d28c6577f",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1277,
			"tags" : [
				"P14"
			],
			"type" : "panel",
			"position" : [
				16000.0,
				-948.6066000000001,
				8572.295100000001
			],
			"legIndex" : -1,
			"brick" : "P14",
			"name" : "1277",
			"uuid" : "da7cf610-cd3b-934b-bbe6-0dabf01dc917",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1278,
			"tags" : [
				"P14"
			],
			"type" : "panel",
			"position" : [
				15051.3934,
				0.0,
				8572.295100000001
			],
			"legIndex" : -1,
			"brick" : "P14",
			"name" : "1278",
			"uuid" : "dfbcd897-8e66-a741-b22f-a34b2ba49f56",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1279,
			"tags" : [
				"P14"
			],
			"type" : "panel",
			"position" : [
				16000.0,
				948.6066000000001,
				8572.295100000001
			],
			"legIndex" : -1,
			"brick" : "P14",
			"name" : "1279",
			"uuid" : "2a515077-33dc-344b-9906-0a7812958be4",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1280,
			"tags" : [
				"P14"
			],
			"type" : "panel",
			"position" : [
				16948.6066,
				0.0,
				8572.295100000001
			],
			"legIndex" : -1,
			"brick" : "P14",
			"name" : "1280",
			"uuid" : "d11cac57-f1b8-e14e-ad2b-a18ccf5d3e11",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1281,
			"tags" : [
				"P14"
			],
			"type" : "panel",
			"position" : [
				16000.0,
				-1085.8883,
				6375.7880000000005
			],
			"legIndex" : -1,
			"brick" : "P14",
			"name" : "1281",
			"uuid" : "1be584ec-0869-1a4d-874c-744794788248",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1282,
			"tags" : [
				"P14"
			],
			"type" : "panel",
			"position" : [
				14914.111700000001,
				0.0,
				6375.7880000000005
			],
			"legIndex" : -1,
			"brick" : "P14",
			"name" : "1282",
			"uuid" : "fbf5bce1-493d-b343-b5f1-128e720f3a12",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1283,
			"tags" : [
				"P14"
			],
			"type" : "panel",
			"position" : [
				16000.0,
				1085.8883,
				6375.7880000000005
			],
			"legIndex" : -1,
			"brick" : "P14",
			"name" : "1283",
			"uuid" : "e628e911-ffa1-7f4c-b2c3-1fc2924cf682",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1284,
			"tags" : [
				"P14"
			],
			"type" : "panel",
			"position" : [
				17085.888300000002,
				0.0,
				6375.7880000000005
			],
			"legIndex" : -1,
			"brick" : "P14",
			"name" : "1284",
			"uuid" : "7e3f6bea-29ab-bd43-9194-05373ab3da00",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1285,
			"tags" : [
				"P14"
			],
			"type" : "panel",
			"position" : [
				16000.0,
				-1339.3054,
				4024.4915
			],
			"legIndex" : -1,
			"brick" : "P14",
			"name" : "1285",
			"uuid" : "b154a28f-e084-7b42-8259-f6f433077f11",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1286,
			"tags" : [
				"P14"
			],
			"type" : "panel",
			"position" : [
				14660.6946,
				0.0,
				4024.4915
			],
			"legIndex" : -1,
			"brick" : "P14",
			"name" : "1286",
			"uuid" : "6d401829-ceda-6840-947d-1bcd1024d00a",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1287,
			"tags" : [
				"P14"
			],
			"type" : "panel",
			"position" : [
				16000.0,
				1339.3054,
				4024.4915
			],
			"legIndex" : -1,
			"brick" : "P14",
			"name" : "1287",
			"uuid" : "3736839b-4876-4148-a1af-229153b1b074",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1288,
			"tags" : [
				"P14"
			],
			"type" : "panel",
			"position" : [
				17339.3054,
				0.0,
				4024.4915
			],
			"legIndex" : -1,
			"brick" : "P14",
			"name" : "1288",
			"uuid" : "ff401724-3171-0441-9445-d087b110cf59",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1289,
			"tags" : [
				"P14"
			],
			"type" : "panel",
			"position" : [
				16000.0,
				-1617.7409,
				1441.0663
			],
			"legIndex" : -1,
			"brick" : "P14",
			"name" : "1289",
			"uuid" : "0776db77-46ec-9444-8ac0-a33bb707d90f",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1290,
			"tags" : [
				"P14"
			],
			"type" : "panel",
			"position" : [
				14382.259100000001,
				0.0,
				1441.0663
			],
			"legIndex" : -1,
			"brick" : "P14",
			"name" : "1290",
			"uuid" : "fa517887-24af-fd4d-a7df-9485d76a1c2a",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1291,
			"tags" : [
				"P14"
			],
			"type" : "panel",
			"position" : [
				16000.0,
				1617.7409,
				1441.0663
			],
			"legIndex" : -1,
			"brick" : "P14",
			"name" : "1291",
			"uuid" : "71ab1a4c-726f-bb41-91ca-4f46a99f026e",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1292,
			"tags" : [
				"P14"
			],
			"type" : "panel",
			"position" : [
				17617.7409,
				0.0,
				1441.0663
			],
			"legIndex" : -1,
			"brick" : "P14",
			"name" : "1292",
			"uuid" : "d688a2cf-da83-1747-8c75-ff9356a5af16",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1300,
			"tags" : [
				"P15"
			],
			"type" : "slope",
			"position" : [
				32000.0,
				0.0,
				21750.0
			],
			"legIndex" : 0,
			"brick" : "P15",
			"name" : "1300",
			"uuid" : "b9a98bd1-554d-2e46-b545-c0ef9bab3f69",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1301,
			"tags" : [
				"P15"
			],
			"type" : "slope",
			"position" : [
				32120.0,
				-120.0,
				20470.0
			],
			"legIndex" : 1,
			"brick" : "P15",
			"name" : "1301",
			"uuid" : "ed334815-fafd-8d41-9610-311db3706401",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1302,
			"tags" : [
				"P15"
			],
			"type" : "slope",
			"position" : [
				31880.0,
				-120.0,
				20470.0
			],
			"legIndex" : 2,
			"brick" : "P15",
			"name" : "1302",
			"uuid" : "15b0f9c5-9898-bc4d-92d4-3fc83c288ae2",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1303,
			"tags" : [
				"P15"
			],
			"type" : "slope",
			"position" : [
				31880.0,
				120.0,
				20470.0
			],
			"legIndex" : 3,
			"brick" : "P15",
			"name" : "1303",
			"uuid" : "cc0c068e-6b32-7841-bccc-c581a7b10c6a",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1304,
			"tags" : [
				"P15"
			],
			"type" : "slope",
			"position" : [
				32120.0,
				120.0,
				20470.0
			],
			"legIndex" : 4,
			"brick" : "P15",
			"name" : "1304",
			"uuid" : "50790632-b688-4342-a49f-e67324b23c20",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1305,
			"tags" : [
				"P15"
			],
			"type" : "slope",
			"position" : [
				32240.0,
				-240.0,
				19190.0
			],
			"legIndex" : 1,
			"brick" : "P15",
			"name" : "1305",
			"uuid" : "0f42f153-53ef-4549-a5af-33cbac24dae2",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1306,
			"tags" : [
				"P15"
			],
			"type" : "slope",
			"position" : [
				31760.0,
				-240.0,
				19190.0
			],
			"legIndex" : 2,
			"brick" : "P15",
			"name" : "1306",
			"uuid" : "eb08f71e-7d06-b849-acaf-0da71d2c80b9",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1307,
			"tags" : [
				"P15"
			],
			"type" : "slope",
			"position" : [
				31760.0,
				240.0,
				19190.0
			],
			"legIndex" : 3,
			"brick" : "P15",
			"name" : "1307",
			"uuid" : "d85cc47e-fbf9-ab40-bcb6-bc5083982358",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1308,
			"tags" : [
				"P15"
			],
			"type" : "slope",
			"position" : [
				32240.0,
				240.0,
				19190.0
			],
			"legIndex" : 4,
			"brick" : "P15",
			"name" : "1308",
			"uuid" : "38b0f8cc-ec42-d246-959e-453392842445",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1309,
			"tags" : [
				"P15"
			],
			"type" : "slope",
			"position" : [
				32360.0,
				-360.0,
				17910.0
			],
			"legIndex" : 1,
			"brick" : "P15",
			"name" : "1309",
			"uuid" : "cccf9cc2-dcc0-a14d-8d41-9d00af68ffbf",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1310,
			"tags" : [
				"P15"
			],
			"type" : "slope",
			"position" : [
				31640.0,
				-360.0,
				17910.0
			],
			"legIndex" : 2,
			"brick" : "P15",
			"name" : "1310",
			"uuid" : "52bdbb5b-4bcf-fd4c-a02c-284e3a0cb92b",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1311,
			"tags" : [
				"P15"
			],
			"type" : "slope",
			"position" : [
				31640.0,
				360.0,
				17910.0
			],
			"legIndex" : 3,
			"brick" : "P15",
			"name" : "1311",
			"uuid" : "62813a35-3cd6-b24f-a4da-b1425684fed2",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1312,
			"tags" : [
				"P15"
			],
			"type" : "slope",
			"position" : [
				32360.0,
				360.0,
				17910.0
			],
			"legIndex" : 4,
			"brick" : "P15",
			"name" : "1312",
			"uuid" : "f78eccfa-5da7-0949-82ab-3b92988434b5",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1313,
			"tags" : [
				"P15"
			],
			"type" : "slope",
			"position" : [
				32480.0,
				-480.0,
				16630.0
			],
			"legIndex" : 1,
			"brick" : "P15",
			"name" : "1313",
			"uuid" : "e71dd370-4f65-4e44-85fb-8600e322080f",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1314,
			"tags" : [
				"P15"
			],
			"type" : "slope",
			"position" : [
				31520.0,
				-480.0,
				16630.0
			],
			"legIndex" : 2,
			"brick" : "P15",
			"name" : "1314",
			"uuid" : "2cda42db-f470-1e43-a6b9-f0d167ffb040",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1315,
			"tags" : [
				"P15"
			],
			"type" : "slope",
			"position" : [
				31520.0,
				480.0,
				16630.0
			],
			"legIndex" : 3,
			"brick" : "P15",
			"name" : "1315",
			"uuid" : "75d7ccb7-f1f9-2448-be27-dde6ada5139b",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1316,
			"tags" : [
				"P15"
			],
			"type" : "slope",
			"position" : [
				32480.0,
				480.0,
				16630.0
			],
			"legIndex" : 4,
			"brick" : "P15",
			"name" : "1316",
			"uuid" : "675931dc-b372-c445-9fce-79e8bfb5331f",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1317,
			"tags" : [
				"B15",
				"P15"
			],
			"type" : "slope",
			"position" : [
				32600.0,
				-600.0,
				15350.0
			],
			"legIndex" : 1,
			"brick" : "P15",
			"name" : "1317",
			"uuid" : "715d8753-5b49-5e4f-8379-d63c4d8d5bf3",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1318,
			"tags" : [
				"B14",
				"P15"
			],
			"type" : "slope",
			"position" : [
				31400.0,
				-600.0,
				15350.0
			],
			"legIndex" : 1,
			"brick" : "P15",
			"name" : "1318",
			"uuid" : "68404c31-aac6-9c46-8a7f-eaaeae06b056",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1319,
			"tags" : [
				"B14",
				"P15"
			],
			"type" : "slope",
			"position" : [
				31400.0,
				600.0,
				15350.0
			],
			"legIndex" : 4,
			"brick" : "P15",
			"name" : "1319",
			"uuid" : "be8f1438-7008-4d4d-8b16-4997d4bf177f",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1320,
			"tags" : [
				"B15",
				"P15"
			],
			"type" : "slope",
			"position" : [
				32600.0,
				600.0,
				15350.0
			],
			"legIndex" : 4,
			"brick" : "P15",
			"name" : "1320",
			"uuid" : "2d472bf0-4113-7c41-a416-c730d318acb8",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1321,
			"tags" : [
				"B15",
				"P15"
			],
			"type" : "slope",
			"position" : [
				32600.0,
				-600.0,
				14150.0
			],
			"legIndex" : 2,
			"brick" : "P15",
			"name" : "1321",
			"uuid" : "69d5de29-1275-ba4c-8d52-7a7ae66e1f13",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1322,
			"tags" : [
				"B14",
				"P15"
			],
			"type" : "slope",
			"position" : [
				31400.0,
				-600.0,
				14150.0
			],
			"legIndex" : 2,
			"brick" : "P15",
			"name" : "1322",
			"uuid" : "b8db546b-06d3-de4d-b577-209bf2b9441b",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1323,
			"tags" : [
				"B14",
				"P15"
			],
			"type" : "slope",
			"position" : [
				31400.0,
				600.0,
				14150.0
			],
			"legIndex" : 3,
			"brick" : "P15",
			"name" : "1323",
			"uuid" : "0bec4077-6436-4646-b8c7-c30069808e4a",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1324,
			"tags" : [
				"B15",
				"P15"
			],
			"type" : "slope",
			"position" : [
				32600.0,
				600.0,
				14150.0
			],
			"legIndex" : 3,
			"brick" : "P15",
			"name" : "1324",
			"uuid" : "e714a2fc-0e95-fa4d-8e1a-2f73003cb82f",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1325,
			"tags" : [
				"P15"
			],
			"type" : "slope",
			"position" : [
				32675.0,
				-675.0,
				12950.0
			],
			"legIndex" : 1,
			"brick" : "P15",
			"name" : "1325",
			"uuid" : "2b2c3d65-c900-ac4b-b143-cc13d60ce6b4",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1326,
			"tags" : [
				"P15"
			],
			"type" : "slope",
			"position" : [
				31325.0,
				-675.0,
				12950.0
			],
			"legIndex" : 2,
			"brick" : "P15",
			"name" : "1326",
			"uuid" : "f1baa9c5-1f7a-274b-8b1a-6d3c3088f15f",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1327,
			"tags" : [
				"P15"
			],
			"type" : "slope",
			"position" : [
				31325.0,
				675.0,
				12950.0
			],
			"legIndex" : 3,
			"brick" : "P15",
			"name" : "1327",
			"uuid" : "cbc8677e-835c-1c43-8c13-ff31e83685ca",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1328,
			"tags" : [
				"P15"
			],
			"type" : "slope",
			"position" : [
				32675.0,
				675.0,
				12950.0
			],
			"legIndex" : 4,
			"brick" : "P15",
			"name" : "1328",
			"uuid" : "329727b9-a9aa-a44f-956a-90006000de6d",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1329,
			"tags" : [
				"P15"
			],
			"type" : "slope",
			"position" : [
				32718.8312,
				-718.8312000000001,
				12248.7013
			],
			"legIndex" : 1,
			"brick" : "P15",
			"name" : "1329",
			"uuid" : "c769e015-0420-7042-be76-cc615e309c92",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1330,
			"tags" : [
				"P15"
			],
			"type" : "slope",
			"position" : [
				31281.168800000003,
				-718.8312000000001,
				12248.7013
			],
			"legIndex" : 2,
			"brick" : "P15",
			"name" : "1330",
			"uuid" : "50b314ce-f7e6-e549-96bf-4c840dc62b90",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1331,
			"tags" : [
				"P15"
			],
			"type" : "slope",
			"position" : [
				31281.168800000003,
				718.8312000000001,
				12248.7013
			],
			"legIndex" : 3,
			"brick" : "P15",
			"name" : "1331",
			"uuid" : "b03d8fa7-515a-6e4d-819c-d42f94f9bbf3",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1332,
			"tags" : [
				"P15"
			],
			"type" : "slope",
			"position" : [
				32718.8312,
				718.8312000000001,
				12248.7013
			],
			"legIndex" : 4,
			"brick" : "P15",
			"name" : "1332",
			"uuid" : "7f71976b-2a19-f444-90f0-7f5fd40ecabd",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1333,
			"tags" : [
				"P15"
			],
			"type" : "slope",
			"position" : [
				32768.75,
				-768.75,
				11450.0
			],
			"legIndex" : 1,
			"brick" : "P15",
			"name" : "1333",
			"uuid" : "eb7a9fbf-46cc-a245-a4e4-b98e6b98e10d",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1334,
			"tags" : [
				"P15"
			],
			"type" : "slope",
			"position" : [
				31231.25,
				-768.75,
				11450.0
			],
			"legIndex" : 2,
			"brick" : "P15",
			"name" : "1334",
			"uuid" : "ffb0f6c7-f8f6-0d4a-863a-e6e4aff494fa",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1335,
			"tags" : [
				"P15"
			],
			"type" : "slope",
			"position" : [
				31231.25,
				768.75,
				11450.0
			],
			"legIndex" : 3,
			"brick" : "P15",
			"name" : "1335",
			"uuid" : "517511b1-1261-0947-90f1-fdec727569fc",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1336,
			"tags" : [
				"P15"
			],
			"type" : "slope",
			"position" : [
				32768.75,
				768.75,
				11450.0
			],
			"legIndex" : 4,
			"brick" : "P15",
			"name" : "1336",
			"uuid" : "a36ee201-5dec-9e43-ad14-797adc3894bc",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1337,
			"tags" : [
				"P15"
			],
			"type" : "slope",
			"position" : [
				32823.867900000005,
				-823.8679000000001,
				10568.1132
			],
			"legIndex" : 1,
			"brick" : "P15",
			"name" : "1337",
			"uuid" : "154c68a6-9ab9-ef43-9b3c-b2a7aa715599",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1338,
			"tags" : [
				"P15"
			],
			"type" : "slope",
			"position" : [
				31176.132100000003,
				-823.8679000000001,
				10568.1132
			],
			"legIndex" : 2,
			"brick" : "P15",
			"name" : "1338",
			"uuid" : "5a0455cd-c17c-744a-b40d-36535c13344b",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1339,
			"tags" : [
				"P15"
			],
			"type" : "slope",
			"position" : [
				31176.132100000003,
				823.8679000000001,
				10568.1132
			],
			"legIndex" : 3,
			"brick" : "P15",
			"name" : "1339",
			"uuid" : "54d2bfe2-fd80-d04e-9fbb-1e9b2f2ed3bc",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1340,
			"tags" : [
				"P15"
			],
			"type" : "slope",
			"position" : [
				32823.867900000005,
				823.8679000000001,
				10568.1132
			],
			"legIndex" : 4,
			"brick" : "P15",
			"name" : "1340",
			"uuid" : "ec57d220-b841-1e44-892a-c89b9f69f17b",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1341,
			"tags" : [
				"P15"
			],
			"type" : "slope",
			"position" : [
				32887.5,
				-887.5,
				9550.0
			],
			"legIndex" : 1,
			"brick" : "P15",
			"name" : "1341",
			"uuid" : "9aa625a0-34b4-954a-ac8b-ac91dabe4b33",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1342,
			"tags" : [
				"P15"
			],
			"type" : "slope",
			"position" : [
				31112.5,
				-887.5,
				9550.0
			],
			"legIndex" : 2,
			"brick" : "P15",
			"name" : "1342",
			"uuid" : "b6759c99-8f80-c04e-97bb-b303bba1c65d",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1343,
			"tags" : [
				"P15"
			],
			"type" : "slope",
			"position" : [
				31112.5,
				887.5,
				9550.0
			],
			"legIndex" : 3,
			"brick" : "P15",
			"name" : "1343",
			"uuid" : "818eda23-00c4-bd46-a56a-f4d5de7c08d5",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1344,
			"tags" : [
				"P15"
			],
			"type" : "slope",
			"position" : [
				32887.5,
				887.5,
				9550.0
			],
			"legIndex" : 4,
			"brick" : "P15",
			"name" : "1344",
			"uuid" : "db27bbcc-05c8-1e45-af5a-c9e0e7bae766",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1345,
			"tags" : [
				"P15"
			],
			"type" : "slope",
			"position" : [
				32948.6066,
				-948.6066000000001,
				8572.295100000001
			],
			"legIndex" : 1,
			"brick" : "P15",
			"name" : "1345",
			"uuid" : "6212dbc0-30b7-c646-a2bb-30e7722a77ef",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1346,
			"tags" : [
				"P15"
			],
			"type" : "slope",
			"position" : [
				31051.3934,
				-948.6066000000001,
				8572.295100000001
			],
			"legIndex" : 2,
			"brick" : "P15",
			"name" : "1346",
			"uuid" : "467844c9-b348-7840-820f-ab1e285519f0",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1347,
			"tags" : [
				"P15"
			],
			"type" : "slope",
			"position" : [
				31051.3934,
				948.6066000000001,
				8572.295100000001
			],
			"legIndex" : 3,
			"brick" : "P15",
			"name" : "1347",
			"uuid" : "27008951-7337-b44d-9c7f-2148237a8e39",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1348,
			"tags" : [
				"P15"
			],
			"type" : "slope",
			"position" : [
				32948.6066,
				948.6066000000001,
				8572.295100000001
			],
			"legIndex" : 4,
			"brick" : "P15",
			"name" : "1348",
			"uuid" : "e4ce6689-7dfc-be46-b06c-c2bf634a4852",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1349,
			"tags" : [
				"P15"
			],
			"type" : "slope",
			"position" : [
				33018.75,
				-1018.75,
				7450.0
			],
			"legIndex" : 1,
			"brick" : "P15",
			"name" : "1349",
			"uuid" : "aea29ba8-aa23-ec40-bbda-735be5dd4f4a",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1350,
			"tags" : [
				"P15"
			],
			"type" : "slope",
			"position" : [
				30981.25,
				-1018.75,
				7450.0
			],
			"legIndex" : 2,
			"brick" : "P15",
			"name" : "1350",
			"uuid" : "318d17d4-d22a-8f46-8b5d-fd0f3157a970",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1351,
			"tags" : [
				"P15"
			],
			"type" : "slope",
			"position" : [
				30981.25,
				1018.75,
				7450.0
			],
			"legIndex" : 3,
			"brick" : "P15",
			"name" : "1351",
			"uuid" : "731ec1a4-a4c3-3343-be9f-4524066e9db6",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1352,
			"tags" : [
				"P15"
			],
			"type" : "slope",
			"position" : [
				33018.75,
				1018.75,
				7450.0
			],
			"legIndex" : 4,
			"brick" : "P15",
			"name" : "1352",
			"uuid" : "5abeccd7-42e4-7f40-aa2a-99708dd8fafe",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1353,
			"tags" : [
				"P15"
			],
			"type" : "slope",
			"position" : [
				33085.8883,
				-1085.8883,
				6375.7880000000005
			],
			"legIndex" : 1,
			"brick" : "P15",
			"name" : "1353",
			"uuid" : "4d472f89-8a32-114f-979a-042ccdee2a50",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1354,
			"tags" : [
				"P15"
			],
			"type" : "slope",
			"position" : [
				30914.1117,
				-1085.8883,
				6375.7880000000005
			],
			"legIndex" : 2,
			"brick" : "P15",
			"name" : "1354",
			"uuid" : "d5589167-6661-4c42-a510-4d6ad354c915",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1355,
			"tags" : [
				"P15"
			],
			"type" : "slope",
			"position" : [
				30914.1117,
				1085.8883,
				6375.7880000000005
			],
			"legIndex" : 3,
			"brick" : "P15",
			"name" : "1355",
			"uuid" : "8fea8bf5-ffbd-b643-b8df-08726815e1d7",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1356,
			"tags" : [
				"P15"
			],
			"type" : "slope",
			"position" : [
				33085.8883,
				1085.8883,
				6375.7880000000005
			],
			"legIndex" : 4,
			"brick" : "P15",
			"name" : "1356",
			"uuid" : "2707dfa8-ae3d-834e-8290-0ec9a25d545c",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1357,
			"tags" : [
				"P15"
			],
			"type" : "slope",
			"position" : [
				33218.0008,
				-1218.0008,
				5150.0
			],
			"legIndex" : 1,
			"brick" : "P15",
			"name" : "1357",
			"uuid" : "a2a6a4cd-31fe-4747-a92f-a2e39c2c8ec7",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1358,
			"tags" : [
				"P15"
			],
			"type" : "slope",
			"position" : [
				30781.999200000002,
				-1218.0008,
				5150.0
			],
			"legIndex" : 2,
			"brick" : "P15",
			"name" : "1358",
			"uuid" : "b02c9a5f-92a5-3b4a-823a-34b8a2d0fa26",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1359,
			"tags" : [
				"P15"
			],
			"type" : "slope",
			"position" : [
				30781.999200000002,
				1218.0008,
				5150.0
			],
			"legIndex" : 3,
			"brick" : "P15",
			"name" : "1359",
			"uuid" : "612060cc-93b6-9247-b0b4-23a77d3770cc",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1360,
			"tags" : [
				"P15"
			],
			"type" : "slope",
			"position" : [
				33218.0008,
				1218.0008,
				5150.0
			],
			"legIndex" : 4,
			"brick" : "P15",
			"name" : "1360",
			"uuid" : "801c9505-d78b-2347-b5ca-c572fcb9378e",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1361,
			"tags" : [
				"P15"
			],
			"type" : "slope",
			"position" : [
				33339.305400000005,
				-1339.3054,
				4024.4915
			],
			"legIndex" : 1,
			"brick" : "P15",
			"name" : "1361",
			"uuid" : "7d3ed8a6-02b9-8743-bcd8-79cca227751b",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1362,
			"tags" : [
				"P15"
			],
			"type" : "slope",
			"position" : [
				30660.694600000003,
				-1339.3054,
				4024.4915
			],
			"legIndex" : 2,
			"brick" : "P15",
			"name" : "1362",
			"uuid" : "e6641f8b-5b7f-ba43-81f5-db806dd8ccc1",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1363,
			"tags" : [
				"P15"
			],
			"type" : "slope",
			"position" : [
				30660.694600000003,
				1339.3054,
				4024.4915
			],
			"legIndex" : 3,
			"brick" : "P15",
			"name" : "1363",
			"uuid" : "846937de-30d5-524f-9f17-e77829a388b2",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1364,
			"tags" : [
				"P15"
			],
			"type" : "slope",
			"position" : [
				33339.305400000005,
				1339.3054,
				4024.4915
			],
			"legIndex" : 4,
			"brick" : "P15",
			"name" : "1364",
			"uuid" : "87e05a91-8c5b-9e4f-8222-7a132fabb9f9",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1365,
			"tags" : [
				"P15"
			],
			"type" : "slope",
			"position" : [
				33487.4449,
				-1487.4449,
				2650.0
			],
			"legIndex" : 1,
			"brick" : "P15",
			"name" : "1365",
			"uuid" : "9826c5d6-ffa5-f047-89e8-f88c1a94572d",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1366,
			"tags" : [
				"P15"
			],
			"type" : "slope",
			"position" : [
				30512.5551,
				-1487.4449,
				2650.0
			],
			"legIndex" : 2,
			"brick" : "P15",
			"name" : "1366",
			"uuid" : "ff561132-8f4e-eb44-b308-268a509b584c",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1367,
			"tags" : [
				"P15"
			],
			"type" : "slope",
			"position" : [
				30512.5551,
				1487.4449,
				2650.0
			],
			"legIndex" : 3,
			"brick" : "P15",
			"name" : "1367",
			"uuid" : "220a1ae5-7852-ac4b-84b5-a3da678370cc",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1368,
			"tags" : [
				"P15"
			],
			"type" : "slope",
			"position" : [
				33487.4449,
				1487.4449,
				2650.0
			],
			"legIndex" : 4,
			"brick" : "P15",
			"name" : "1368",
			"uuid" : "1d01ab50-964a-134b-9f01-3c703a6a53e7",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1369,
			"tags" : [
				"P15"
			],
			"type" : "slope",
			"position" : [
				33617.740900000004,
				-1617.7409,
				1441.0663
			],
			"legIndex" : 1,
			"brick" : "P15",
			"name" : "1369",
			"uuid" : "a9751d0e-377b-ba44-983d-65ce3d48945e",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1370,
			"tags" : [
				"P15"
			],
			"type" : "slope",
			"position" : [
				30382.259100000003,
				-1617.7409,
				1441.0663
			],
			"legIndex" : 2,
			"brick" : "P15",
			"name" : "1370",
			"uuid" : "6d1c5422-6efc-b044-a0a7-24ff4bb30cfb",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1371,
			"tags" : [
				"P15"
			],
			"type" : "slope",
			"position" : [
				30382.259100000003,
				1617.7409,
				1441.0663
			],
			"legIndex" : 3,
			"brick" : "P15",
			"name" : "1371",
			"uuid" : "219ba2c1-845b-7f4a-ab41-872183f27b8c",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1372,
			"tags" : [
				"P15"
			],
			"type" : "slope",
			"position" : [
				33617.740900000004,
				1617.7409,
				1441.0663
			],
			"legIndex" : 4,
			"brick" : "P15",
			"name" : "1372",
			"uuid" : "b2b0dd5e-1692-8b45-bced-efb8069d1927",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1373,
			"tags" : [
				"P15"
			],
			"type" : "slope",
			"position" : [
				33773.0556,
				-1773.0556000000001,
				0.0
			],
			"legIndex" : 1,
			"brick" : "P15",
			"name" : "1373",
			"uuid" : "c4fdea07-2f37-4744-a160-5901c14f9591",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1374,
			"tags" : [
				"P15"
			],
			"type" : "slope",
			"position" : [
				30226.9444,
				-1773.0556000000001,
				0.0
			],
			"legIndex" : 2,
			"brick" : "P15",
			"name" : "1374",
			"uuid" : "2a2efb6f-faac-e74e-bd26-d60b23697c0a",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1375,
			"tags" : [
				"P15"
			],
			"type" : "slope",
			"position" : [
				30226.9444,
				1773.0556000000001,
				0.0
			],
			"legIndex" : 3,
			"brick" : "P15",
			"name" : "1375",
			"uuid" : "9500b9a5-c350-5a4d-8c95-80dc664795db",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1376,
			"tags" : [
				"P15"
			],
			"type" : "slope",
			"position" : [
				33773.0556,
				1773.0556000000001,
				0.0
			],
			"legIndex" : 4,
			"brick" : "P15",
			"name" : "1376",
			"uuid" : "f1361ee2-4e11-bc4c-a51d-776a22477b17",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1377,
			"tags" : [
				"P15"
			],
			"type" : "panel",
			"position" : [
				32000.0,
				-600.0,
				14750.0
			],
			"legIndex" : -1,
			"brick" : "P15",
			"name" : "1377",
			"uuid" : "1890d900-410d-fe47-b766-ad18230e0b9a",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1378,
			"tags" : [
				"P15"
			],
			"type" : "panel",
			"position" : [
				31400.0,
				0.0,
				14750.0
			],
			"legIndex" : -1,
			"brick" : "P15",
			"name" : "1378",
			"uuid" : "7910e44a-af11-124b-85d0-cf4f7cafa3a6",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1379,
			"tags" : [
				"P15"
			],
			"type" : "panel",
			"position" : [
				32000.0,
				600.0,
				14750.0
			],
			"legIndex" : -1,
			"brick" : "P15",
			"name" : "1379",
			"uuid" : "1074e56f-0b88-3444-978d-4875b36b3399",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1380,
			"tags" : [
				"P15"
			],
			"type" : "panel",
			"position" : [
				32600.0,
				0.0,
				14750.0
			],
			"legIndex" : -1,
			"brick" : "P15",
			"name" : "1380",
			"uuid" : "f042dc62-d71a-a740-87b0-10f613942457",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1381,
			"tags" : [
				"P15"
			],
			"type" : "panel",
			"position" : [
				32000.0,
				-635.2941000000001,
				13585.294100000001
			],
			"legIndex" : -1,
			"brick" : "P15",
			"name" : "1381",
			"uuid" : "4147b110-c866-5f46-bb4e-19c470ced10a",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1382,
			"tags" : [
				"P15"
			],
			"type" : "panel",
			"position" : [
				31364.7059,
				0.0,
				13585.294100000001
			],
			"legIndex" : -1,
			"brick" : "P15",
			"name" : "1382",
			"uuid" : "c32e6fce-5d0b-4f49-89d3-0e86bab8df13",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1383,
			"tags" : [
				"P15"
			],
			"type" : "panel",
			"position" : [
				32000.0,
				635.2941000000001,
				13585.294100000001
			],
			"legIndex" : -1,
			"brick" : "P15",
			"name" : "1383",
			"uuid" : "2748ce4f-15f4-f449-8535-23e62f0fe8ef",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1384,
			"tags" : [
				"P15"
			],
			"type" : "panel",
			"position" : [
				32635.294100000003,
				0.0,
				13585.294100000001
			],
			"legIndex" : -1,
			"brick" : "P15",
			"name" : "1384",
			"uuid" : "68845d97-9d55-b843-92f3-a919fcded4ec",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1385,
			"tags" : [
				"P15"
			],
			"type" : "panel",
			"position" : [
				32000.0,
				-718.8312000000001,
				12248.7013
			],
			"legIndex" : -1,
			"brick" : "P15",
			"name" : "1385",
			"uuid" : "374e9857-6654-814e-89b2-50e46e746b5e",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1386,
			"tags" : [
				"P15"
			],
			"type" : "panel",
			"position" : [
				31281.168800000003,
				0.0,
				12248.7013
			],
			"legIndex" : -1,
			"brick" : "P15",
			"name" : "1386",
			"uuid" : "5062163c-6d3c-544a-9c56-40358f264555",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1387,
			"tags" : [
				"P15"
			],
			"type" : "panel",
			"position" : [
				32000.0,
				718.8312000000001,
				12248.7013
			],
			"legIndex" : -1,
			"brick" : "P15",
			"name" : "1387",
			"uuid" : "a218e0ac-0eaa-4845-bca7-c38335d3be2b",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1388,
			"tags" : [
				"P15"
			],
			"type" : "panel",
			"position" : [
				32718.8312,
				0.0,
				12248.7013
			],
			"legIndex" : -1,
			"brick" : "P15",
			"name" : "1388",
			"uuid" : "96ccdbf7-671c-1c44-8787-d8e209add820",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1389,
			"tags" : [
				"P15"
			],
			"type" : "panel",
			"position" : [
				32000.0,
				-823.8679000000001,
				10568.1132
			],
			"legIndex" : -1,
			"brick" : "P15",
			"name" : "1389",
			"uuid" : "a637f5e5-f30a-5e4a-bf35-19b1cee394c9",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1390,
			"tags" : [
				"P15"
			],
			"type" : "panel",
			"position" : [
				31176.132100000003,
				0.0,
				10568.1132
			],
			"legIndex" : -1,
			"brick" : "P15",
			"name" : "1390",
			"uuid" : "bc0e5f1f-7f2a-ab44-957b-1d8e68b8f9a4",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1391,
			"tags" : [
				"P15"
			],
			"type" : "panel",
			"position" : [
				32000.0,
				823.8679000000001,
				10568.1132
			],
			"legIndex" : -1,
			"brick" : "P15",
			"name" : "1391",
			"uuid" : "5d06b5ac-f6cb-264f-86c3-6ea419a61448",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1392,
			"tags" : [
				"P15"
			],
			"type" : "panel",
			"position" : [
				32823.867900000005,
				0.0,
				10568.1132
			],
			"legIndex" : -1,
			"brick" : "P15",
			"name" : "1392",
			"uuid" : "3eff7e04-7950-e24d-b4d2-be33fe48e02d",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1393,
			"tags" : [
				"P15"
			],
			"type" : "panel",
			"position" : [
				32000.0,
				-948.6066000000001,
				8572.295100000001
			],
			"legIndex" : -1,
			"brick" : "P15",
			"name" : "1393",
			"uuid" : "5b8ce82f-4541-3847-9459-d7d097f131ad",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1394,
			"tags" : [
				"P15"
			],
			"type" : "panel",
			"position" : [
				31051.3934,
				0.0,
				8572.295100000001
			],
			"legIndex" : -1,
			"brick" : "P15",
			"name" : "1394",
			"uuid" : "a6ecd9e8-4bfc-7c49-b47f-ade0152a20a7",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1395,
			"tags" : [
				"P15"
			],
			"type" : "panel",
			"position" : [
				32000.0,
				948.6066000000001,
				8572.295100000001
			],
			"legIndex" : -1,
			"brick" : "P15",
			"name" : "1395",
			"uuid" : "29d34a39-4559-ef4b-bfb9-e59406142b3c",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1396,
			"tags" : [
				"P15"
			],
			"type" : "panel",
			"position" : [
				32948.6066,
				0.0,
				8572.295100000001
			],
			"legIndex" : -1,
			"brick" : "P15",
			"name" : "1396",
			"uuid" : "1e7ae3f9-8dba-3e45-b5ef-4c1a941eebab",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1397,
			"tags" : [
				"P15"
			],
			"type" : "panel",
			"position" : [
				32000.0,
				-1085.8883,
				6375.7880000000005
			],
			"legIndex" : -1,
			"brick" : "P15",
			"name" : "1397",
			"uuid" : "b7df5b27-4e7a-2e45-947c-a3ea6083b579",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1398,
			"tags" : [
				"P15"
			],
			"type" : "panel",
			"position" : [
				30914.1117,
				0.0,
				6375.7880000000005
			],
			"legIndex" : -1,
			"brick" : "P15",
			"name" : "1398",
			"uuid" : "e14437c8-7d7e-544b-806f-564b5d84416c",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1399,
			"tags" : [
				"P15"
			],
			"type" : "panel",
			"position" : [
				32000.0,
				1085.8883,
				6375.7880000000005
			],
			"legIndex" : -1,
			"brick" : "P15",
			"name" : "1399",
			"uuid" : "c052cd68-e42c-724c-8d16-bbe2bdbb707b",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1400,
			"tags" : [
				"P15"
			],
			"type" : "panel",
			"position" : [
				33085.8883,
				0.0,
				6375.7880000000005
			],
			"legIndex" : -1,
			"brick" : "P15",
			"name" : "1400",
			"uuid" : "5298d396-bd81-d245-88e5-1f1e181936de",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1401,
			"tags" : [
				"P15"
			],
			"type" : "panel",
			"position" : [
				32000.0,
				-1339.3054,
				4024.4915
			],
			"legIndex" : -1,
			"brick" : "P15",
			"name" : "1401",
			"uuid" : "4d7a4f11-26c2-1d45-b9a1-05649c851cc8",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1402,
			"tags" : [
				"P15"
			],
			"type" : "panel",
			"position" : [
				30660.694600000003,
				0.0,
				4024.4915
			],
			"legIndex" : -1,
			"brick" : "P15",
			"name" : "1402",
			"uuid" : "984c168d-3281-f34a-9da9-a6bef53b5618",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1403,
			"tags" : [
				"P15"
			],
			"type" : "panel",
			"position" : [
				32000.0,
				1339.3054,
				4024.4915
			],
			"legIndex" : -1,
			"brick" : "P15",
			"name" : "1403",
			"uuid" : "697784cd-c9c0-b040-92f4-350aa16cb231",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1404,
			"tags" : [
				"P15"
			],
			"type" : "panel",
			"position" : [
				33339.305400000005,
				0.0,
				4024.4915
			],
			"legIndex" : -1,
			"brick" : "P15",
			"name" : "1404",
			"uuid" : "ab71615e-0bb2-f44d-9e9b-7b3a8e9b1b2c",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1405,
			"tags" : [
				"P15"
			],
			"type" : "panel",
			"position" : [
				32000.0,
				-1617.7409,
				1441.0663
			],
			"legIndex" : -1,
			"brick" : "P15",
			"name" : "1405",
			"uuid" : "febc14f7-2173-5243-8592-747fe988df61",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1406,
			"tags" : [
				"P15"
			],
			"type" : "panel",
			"position" : [
				30382.259100000003,
				0.0,
				1441.0663
			],
			"legIndex" : -1,
			"brick" : "P15",
			"name" : "1406",
			"uuid" : "8c86a174-5ad8-2644-83bd-d7d03197ec97",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1407,
			"tags" : [
				"P15"
			],
			"type" : "panel",
			"position" : [
				32000.0,
				1617.7409,
				1441.0663
			],
			"legIndex" : -1,
			"brick" : "P15",
			"name" : "1407",
			"uuid" : "9802bf7f-a9a0-af43-b5d3-0e8f1d0e7f2f",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1408,
			"tags" : [
				"P15"
			],
			"type" : "panel",
			"position" : [
				33617.740900000004,
				0.0,
				1441.0663
			],
			"legIndex" : -1,
			"brick" : "P15",
			"name" : "1408",
			"uuid" : "6eeadc5d-a83b-384e-980a-738be6198570",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1501,
			"tags" : [
				"B16",
				"P16"
			],
			"type" : "slope",
			"position" : [
				48600.0,
				-600.0,
				15350.0
			],
			"legIndex" : 1,
			"brick" : "P16",
			"name" : "1501",
			"uuid" : "8a7896eb-728a-a646-b0d5-8f75a0e7ba05",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1502,
			"tags" : [
				"B15",
				"P16"
			],
			"type" : "slope",
			"position" : [
				47400.0,
				-600.0,
				15350.0
			],
			"legIndex" : 1,
			"brick" : "P16",
			"name" : "1502",
			"uuid" : "cbeb8106-4d13-8f49-bc8a-be3fc1201075",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1503,
			"tags" : [
				"B15",
				"P16"
			],
			"type" : "slope",
			"position" : [
				47400.0,
				600.0,
				15350.0
			],
			"legIndex" : 4,
			"brick" : "P16",
			"name" : "1503",
			"uuid" : "a5997478-6c75-1e4a-807f-2541c7b039e9",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1504,
			"tags" : [
				"B16",
				"P16"
			],
			"type" : "slope",
			"position" : [
				48600.0,
				600.0,
				15350.0
			],
			"legIndex" : 4,
			"brick" : "P16",
			"name" : "1504",
			"uuid" : "5c7bd264-76d0-b443-9f80-fc72e4b3265b",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1505,
			"tags" : [
				"B16",
				"P16"
			],
			"type" : "slope",
			"position" : [
				48600.0,
				-600.0,
				14150.0
			],
			"legIndex" : 2,
			"brick" : "P16",
			"name" : "1505",
			"uuid" : "e265509a-3b14-c144-a89b-b210a7f18140",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1506,
			"tags" : [
				"B15",
				"P16"
			],
			"type" : "slope",
			"position" : [
				47400.0,
				-600.0,
				14150.0
			],
			"legIndex" : 2,
			"brick" : "P16",
			"name" : "1506",
			"uuid" : "2cd08c71-3f89-e440-91a7-d1fdeb18d71a",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1507,
			"tags" : [
				"B15",
				"P16"
			],
			"type" : "slope",
			"position" : [
				47400.0,
				600.0,
				14150.0
			],
			"legIndex" : 3,
			"brick" : "P16",
			"name" : "1507",
			"uuid" : "53bca141-6854-6840-bff5-2df49aad4f2e",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1508,
			"tags" : [
				"B16",
				"P16"
			],
			"type" : "slope",
			"position" : [
				48600.0,
				600.0,
				14150.0
			],
			"legIndex" : 3,
			"brick" : "P16",
			"name" : "1508",
			"uuid" : "8545ba25-807c-7b44-a8b7-fe48d355600b",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1509,
			"tags" : [
				"P16"
			],
			"type" : "slope",
			"position" : [
				48600.0,
				-600.0,
				12950.0
			],
			"legIndex" : 1,
			"brick" : "P16",
			"name" : "1509",
			"uuid" : "73ff262c-4e39-bf47-bd4a-9b121b2a330c",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1510,
			"tags" : [
				"P16"
			],
			"type" : "slope",
			"position" : [
				47400.0,
				-600.0,
				12950.0
			],
			"legIndex" : 2,
			"brick" : "P16",
			"name" : "1510",
			"uuid" : "4b8395ea-7a6c-6743-b146-4acf5fc699a8",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1511,
			"tags" : [
				"P16"
			],
			"type" : "slope",
			"position" : [
				47400.0,
				600.0,
				12950.0
			],
			"legIndex" : 3,
			"brick" : "P16",
			"name" : "1511",
			"uuid" : "0473a8eb-e0f0-424c-812b-d770881b082b",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1512,
			"tags" : [
				"P16"
			],
			"type" : "slope",
			"position" : [
				48600.0,
				600.0,
				12950.0
			],
			"legIndex" : 4,
			"brick" : "P16",
			"name" : "1512",
			"uuid" : "dc77aa01-4379-7643-8436-705d927e6893",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1513,
			"tags" : [
				"P16"
			],
			"type" : "slope",
			"position" : [
				48600.0,
				-600.0,
				12200.0
			],
			"legIndex" : 1,
			"brick" : "P16",
			"name" : "1513",
			"uuid" : "573708e0-f54f-c84d-ba34-468fa6361991",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1514,
			"tags" : [
				"P16"
			],
			"type" : "slope",
			"position" : [
				47400.0,
				-600.0,
				12200.0
			],
			"legIndex" : 2,
			"brick" : "P16",
			"name" : "1514",
			"uuid" : "44f36a23-fad4-5240-aad7-65ddb2eaa53e",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1515,
			"tags" : [
				"P16"
			],
			"type" : "slope",
			"position" : [
				47400.0,
				600.0,
				12200.0
			],
			"legIndex" : 3,
			"brick" : "P16",
			"name" : "1515",
			"uuid" : "11827ada-39b1-044d-b984-6451ed839c5b",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1516,
			"tags" : [
				"P16"
			],
			"type" : "slope",
			"position" : [
				48600.0,
				600.0,
				12200.0
			],
			"legIndex" : 4,
			"brick" : "P16",
			"name" : "1516",
			"uuid" : "9ca9678b-3f2a-0e43-bdd6-f8e346191e2b",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1517,
			"tags" : [
				"P16"
			],
			"type" : "slope",
			"position" : [
				48600.0,
				-600.0,
				11450.0
			],
			"legIndex" : 1,
			"brick" : "P16",
			"name" : "1517",
			"uuid" : "2fb4a455-5782-1e4d-93e4-d985b88445d9",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1518,
			"tags" : [
				"P16"
			],
			"type" : "slope",
			"position" : [
				47400.0,
				-600.0,
				11450.0
			],
			"legIndex" : 2,
			"brick" : "P16",
			"name" : "1518",
			"uuid" : "19a25061-e881-724b-a316-12a023ecbdd8",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1519,
			"tags" : [
				"P16"
			],
			"type" : "slope",
			"position" : [
				47400.0,
				600.0,
				11450.0
			],
			"legIndex" : 3,
			"brick" : "P16",
			"name" : "1519",
			"uuid" : "da47ca5a-d95b-a942-a2ca-f2f357d1c61e",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1520,
			"tags" : [
				"P16"
			],
			"type" : "slope",
			"position" : [
				48600.0,
				600.0,
				11450.0
			],
			"legIndex" : 4,
			"brick" : "P16",
			"name" : "1520",
			"uuid" : "0904e654-01f7-3742-bb87-bad61add39d8",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1521,
			"tags" : [
				"P16"
			],
			"type" : "slope",
			"position" : [
				48600.0,
				-600.0,
				10500.0
			],
			"legIndex" : 1,
			"brick" : "P16",
			"name" : "1521",
			"uuid" : "1b1c2a39-587b-6045-a973-55b7e01e1b3a",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1522,
			"tags" : [
				"P16"
			],
			"type" : "slope",
			"position" : [
				47400.0,
				-600.0,
				10500.0
			],
			"legIndex" : 2,
			"brick" : "P16",
			"name" : "1522",
			"uuid" : "80c28b69-4fbf-ce4a-bb17-82b8ceeb7f19",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1523,
			"tags" : [
				"P16"
			],
			"type" : "slope",
			"position" : [
				47400.0,
				600.0,
				10500.0
			],
			"legIndex" : 3,
			"brick" : "P16",
			"name" : "1523",
			"uuid" : "030daf80-a3f2-f04f-b1b3-e956adeec6d6",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1524,
			"tags" : [
				"P16"
			],
			"type" : "slope",
			"position" : [
				48600.0,
				600.0,
				10500.0
			],
			"legIndex" : 4,
			"brick" : "P16",
			"name" : "1524",
			"uuid" : "45ff0350-949d-1446-87eb-471faa1313f9",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1525,
			"tags" : [
				"P16"
			],
			"type" : "slope",
			"position" : [
				48600.0,
				-600.0,
				9550.0
			],
			"legIndex" : 1,
			"brick" : "P16",
			"name" : "1525",
			"uuid" : "f9308de6-fee6-094c-a9d5-b0a8edce23d4",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1526,
			"tags" : [
				"P16"
			],
			"type" : "slope",
			"position" : [
				47400.0,
				-600.0,
				9550.0
			],
			"legIndex" : 2,
			"brick" : "P16",
			"name" : "1526",
			"uuid" : "e0f05a07-1c92-aa41-b45e-84a7b508c122",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1527,
			"tags" : [
				"P16"
			],
			"type" : "slope",
			"position" : [
				47400.0,
				600.0,
				9550.0
			],
			"legIndex" : 3,
			"brick" : "P16",
			"name" : "1527",
			"uuid" : "30ab4e90-74b6-4744-bd40-ebbaf9448d44",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1528,
			"tags" : [
				"P16"
			],
			"type" : "slope",
			"position" : [
				48600.0,
				600.0,
				9550.0
			],
			"legIndex" : 4,
			"brick" : "P16",
			"name" : "1528",
			"uuid" : "8ccbffe1-813e-1b42-b8b8-df5c8e69f1d7",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1529,
			"tags" : [
				"P16"
			],
			"type" : "slope",
			"position" : [
				48600.0,
				-600.0,
				8500.0
			],
			"legIndex" : 1,
			"brick" : "P16",
			"name" : "1529",
			"uuid" : "4ae19580-592b-014f-b5a5-a6f0b647d16a",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1530,
			"tags" : [
				"P16"
			],
			"type" : "slope",
			"position" : [
				47400.0,
				-600.0,
				8500.0
			],
			"legIndex" : 2,
			"brick" : "P16",
			"name" : "1530",
			"uuid" : "154f6edf-67b1-a046-beef-542da15510bd",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1531,
			"tags" : [
				"P16"
			],
			"type" : "slope",
			"position" : [
				47400.0,
				600.0,
				8500.0
			],
			"legIndex" : 3,
			"brick" : "P16",
			"name" : "1531",
			"uuid" : "3ced28ee-4aaa-eb43-8c1d-2f431c75c3e0",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1532,
			"tags" : [
				"P16"
			],
			"type" : "slope",
			"position" : [
				48600.0,
				600.0,
				8500.0
			],
			"legIndex" : 4,
			"brick" : "P16",
			"name" : "1532",
			"uuid" : "e71576a5-509d-c24b-be3b-20121e23e661",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1533,
			"tags" : [
				"P16"
			],
			"type" : "slope",
			"position" : [
				48600.0,
				-600.0,
				7450.0
			],
			"legIndex" : 1,
			"brick" : "P16",
			"name" : "1533",
			"uuid" : "0d655a7b-904a-fb40-b7ad-05d0a15c67f7",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1534,
			"tags" : [
				"P16"
			],
			"type" : "slope",
			"position" : [
				47400.0,
				-600.0,
				7450.0
			],
			"legIndex" : 2,
			"brick" : "P16",
			"name" : "1534",
			"uuid" : "a1edbf35-fb61-4d4d-a1ed-b966a6a2abae",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1535,
			"tags" : [
				"P16"
			],
			"type" : "slope",
			"position" : [
				47400.0,
				600.0,
				7450.0
			],
			"legIndex" : 3,
			"brick" : "P16",
			"name" : "1535",
			"uuid" : "8b8c59e7-cce1-424d-a220-01aeebbf3d76",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1536,
			"tags" : [
				"P16"
			],
			"type" : "slope",
			"position" : [
				48600.0,
				600.0,
				7450.0
			],
			"legIndex" : 4,
			"brick" : "P16",
			"name" : "1536",
			"uuid" : "97eaf659-df1b-b641-b980-fc9de49d3ff2",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1537,
			"tags" : [
				"P16"
			],
			"type" : "slope",
			"position" : [
				48738.0,
				-738.0,
				6564.5
			],
			"legIndex" : 1,
			"brick" : "P16",
			"name" : "1537",
			"uuid" : "5496b90b-c921-6348-859c-6149ee8daf74",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1538,
			"tags" : [
				"P16"
			],
			"type" : "slope",
			"position" : [
				47262.0,
				-738.0,
				6564.5
			],
			"legIndex" : 2,
			"brick" : "P16",
			"name" : "1538",
			"uuid" : "e9202b0c-5f7a-3843-9bec-913412d33d35",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1539,
			"tags" : [
				"P16"
			],
			"type" : "slope",
			"position" : [
				47262.0,
				738.0,
				6564.5
			],
			"legIndex" : 3,
			"brick" : "P16",
			"name" : "1539",
			"uuid" : "5c9ecf1b-aa1e-0c4a-a492-f93546eea478",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1540,
			"tags" : [
				"P16"
			],
			"type" : "slope",
			"position" : [
				48738.0,
				738.0,
				6564.5
			],
			"legIndex" : 4,
			"brick" : "P16",
			"name" : "1540",
			"uuid" : "d58ec7b0-b013-6541-bd2a-b4555b5fdb60",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1541,
			"tags" : [
				"P16"
			],
			"type" : "slope",
			"position" : [
				48958.441600000006,
				-958.4416,
				5150.0
			],
			"legIndex" : 1,
			"brick" : "P16",
			"name" : "1541",
			"uuid" : "e357b88f-345d-9242-9271-3ab6de2193b0",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1542,
			"tags" : [
				"P16"
			],
			"type" : "slope",
			"position" : [
				47041.5584,
				-958.4416,
				5150.0
			],
			"legIndex" : 2,
			"brick" : "P16",
			"name" : "1542",
			"uuid" : "ac1398b6-5643-ff4c-82d3-3d2cb0e32aef",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1543,
			"tags" : [
				"P16"
			],
			"type" : "slope",
			"position" : [
				47041.5584,
				958.4416,
				5150.0
			],
			"legIndex" : 3,
			"brick" : "P16",
			"name" : "1543",
			"uuid" : "3c198bc0-b75d-4041-a642-61819bbba5f1",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1544,
			"tags" : [
				"P16"
			],
			"type" : "slope",
			"position" : [
				48958.441600000006,
				958.4416,
				5150.0
			],
			"legIndex" : 4,
			"brick" : "P16",
			"name" : "1544",
			"uuid" : "11de3d75-f291-a142-a16a-bf665b3e9329",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1545,
			"tags" : [
				"P16"
			],
			"type" : "slope",
			"position" : [
				49120.340500000006,
				-1120.3405,
				4111.1486
			],
			"legIndex" : 1,
			"brick" : "P16",
			"name" : "1545",
			"uuid" : "0fbc2ab7-628e-e54a-95e5-f9fd52e321ea",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1546,
			"tags" : [
				"P16"
			],
			"type" : "slope",
			"position" : [
				46879.6595,
				-1120.3405,
				4111.1486
			],
			"legIndex" : 2,
			"brick" : "P16",
			"name" : "1546",
			"uuid" : "962bbbb6-d4a2-cc4f-9072-e496a3863ca4",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1547,
			"tags" : [
				"P16"
			],
			"type" : "slope",
			"position" : [
				46879.6595,
				1120.3405,
				4111.1486
			],
			"legIndex" : 3,
			"brick" : "P16",
			"name" : "1547",
			"uuid" : "87dc33dc-ab51-6f47-9551-17a4730d41cc",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1548,
			"tags" : [
				"P16"
			],
			"type" : "slope",
			"position" : [
				49120.340500000006,
				1120.3405,
				4111.1486
			],
			"legIndex" : 4,
			"brick" : "P16",
			"name" : "1548",
			"uuid" : "dcdc017f-3490-b74f-9eeb-f07d322dd2d1",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1549,
			"tags" : [
				"P16"
			],
			"type" : "slope",
			"position" : [
				49348.051900000006,
				-1348.0519000000002,
				2650.0
			],
			"legIndex" : 1,
			"brick" : "P16",
			"name" : "1549",
			"uuid" : "4bb8a3cb-7a88-7446-ace5-8c42ea93a49f",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1550,
			"tags" : [
				"P16"
			],
			"type" : "slope",
			"position" : [
				46651.9481,
				-1348.0519000000002,
				2650.0
			],
			"legIndex" : 2,
			"brick" : "P16",
			"name" : "1550",
			"uuid" : "51d5f4a5-4ab4-cb42-b71e-6ddf087611ff",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1551,
			"tags" : [
				"P16"
			],
			"type" : "slope",
			"position" : [
				46651.9481,
				1348.0519000000002,
				2650.0
			],
			"legIndex" : 3,
			"brick" : "P16",
			"name" : "1551",
			"uuid" : "a65f0fc6-1cb2-244e-ae59-7360e0df97fe",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1552,
			"tags" : [
				"P16"
			],
			"type" : "slope",
			"position" : [
				49348.051900000006,
				1348.0519000000002,
				2650.0
			],
			"legIndex" : 4,
			"brick" : "P16",
			"name" : "1552",
			"uuid" : "821a52aa-e0d1-f448-b1c1-269a480da3d2",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1553,
			"tags" : [
				"P16"
			],
			"type" : "slope",
			"position" : [
				49527.116500000004,
				-1527.1165,
				1501.0025
			],
			"legIndex" : 1,
			"brick" : "P16",
			"name" : "1553",
			"uuid" : "4182bb26-5b1a-bd4f-b25d-7ed3e9620cd6",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1554,
			"tags" : [
				"P16"
			],
			"type" : "slope",
			"position" : [
				46472.8835,
				-1527.1165,
				1501.0025
			],
			"legIndex" : 2,
			"brick" : "P16",
			"name" : "1554",
			"uuid" : "8931e4e6-1761-fd42-8c03-b6d8c8491aba",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1555,
			"tags" : [
				"P16"
			],
			"type" : "slope",
			"position" : [
				46472.8835,
				1527.1165,
				1501.0025
			],
			"legIndex" : 3,
			"brick" : "P16",
			"name" : "1555",
			"uuid" : "ebc0ad73-92f0-5848-9d94-3078ff1ab9cd",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1556,
			"tags" : [
				"P16"
			],
			"type" : "slope",
			"position" : [
				49527.116500000004,
				1527.1165,
				1501.0025
			],
			"legIndex" : 4,
			"brick" : "P16",
			"name" : "1556",
			"uuid" : "c4988537-112b-6f4d-9bb9-362c0249492b",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1557,
			"tags" : [
				"P16"
			],
			"type" : "slope",
			"position" : [
				49761.039000000004,
				-1761.039,
				0.0
			],
			"legIndex" : 1,
			"brick" : "P16",
			"name" : "1557",
			"uuid" : "42204d62-6ea9-8f4d-a139-7d6a7feec424",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1558,
			"tags" : [
				"P16"
			],
			"type" : "slope",
			"position" : [
				46238.961,
				-1761.039,
				0.0
			],
			"legIndex" : 2,
			"brick" : "P16",
			"name" : "1558",
			"uuid" : "5334fd14-21fe-8d40-bb26-24cb1dc07a07",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1559,
			"tags" : [
				"P16"
			],
			"type" : "slope",
			"position" : [
				46238.961,
				1761.039,
				0.0
			],
			"legIndex" : 3,
			"brick" : "P16",
			"name" : "1559",
			"uuid" : "b7e27220-b06b-704a-b6e0-754107d66659",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1560,
			"tags" : [
				"P16"
			],
			"type" : "slope",
			"position" : [
				49761.039000000004,
				1761.039,
				0.0
			],
			"legIndex" : 4,
			"brick" : "P16",
			"name" : "1560",
			"uuid" : "23b7be85-08e7-d34f-b54e-f5f6764852ed",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1561,
			"tags" : [
				"P16"
			],
			"type" : "panel",
			"position" : [
				48000.0,
				-600.0,
				14750.0
			],
			"legIndex" : -1,
			"brick" : "P16",
			"name" : "1561",
			"uuid" : "f7db2692-d669-c844-95b4-0f81d6cd8099",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1562,
			"tags" : [
				"P16"
			],
			"type" : "panel",
			"position" : [
				47400.0,
				0.0,
				14750.0
			],
			"legIndex" : -1,
			"brick" : "P16",
			"name" : "1562",
			"uuid" : "fb392a83-d72a-ed48-af8e-b11bfd059b40",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1563,
			"tags" : [
				"P16"
			],
			"type" : "panel",
			"position" : [
				48000.0,
				600.0,
				14750.0
			],
			"legIndex" : -1,
			"brick" : "P16",
			"name" : "1563",
			"uuid" : "7325bd48-a381-aa42-a460-48c1d38a05dd",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1564,
			"tags" : [
				"P16"
			],
			"type" : "panel",
			"position" : [
				48600.0,
				0.0,
				14750.0
			],
			"legIndex" : -1,
			"brick" : "P16",
			"name" : "1564",
			"uuid" : "9a81cea1-2831-3b45-a6ce-67c93b778bca",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1565,
			"tags" : [
				"P16"
			],
			"type" : "panel",
			"position" : [
				48000.0,
				-600.0,
				13550.0
			],
			"legIndex" : -1,
			"brick" : "P16",
			"name" : "1565",
			"uuid" : "87d4022b-8c57-9b41-9720-10ae03533530",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1566,
			"tags" : [
				"P16"
			],
			"type" : "panel",
			"position" : [
				47400.0,
				0.0,
				13550.0
			],
			"legIndex" : -1,
			"brick" : "P16",
			"name" : "1566",
			"uuid" : "8797c9dc-116b-7a47-ae60-4ef8885860d6",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1567,
			"tags" : [
				"P16"
			],
			"type" : "panel",
			"position" : [
				48000.0,
				600.0,
				13550.0
			],
			"legIndex" : -1,
			"brick" : "P16",
			"name" : "1567",
			"uuid" : "3a2ade7a-924c-f047-be4d-74393d06c42f",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1568,
			"tags" : [
				"P16"
			],
			"type" : "panel",
			"position" : [
				48600.0,
				0.0,
				13550.0
			],
			"legIndex" : -1,
			"brick" : "P16",
			"name" : "1568",
			"uuid" : "68338f88-4a38-9b48-a686-315bebd6eb8f",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1569,
			"tags" : [
				"P16"
			],
			"type" : "panel",
			"position" : [
				48000.0,
				-600.0,
				12200.0
			],
			"legIndex" : -1,
			"brick" : "P16",
			"name" : "1569",
			"uuid" : "5fc95dbb-cef5-ec4b-bff1-0c848f01984c",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1570,
			"tags" : [
				"P16"
			],
			"type" : "panel",
			"position" : [
				47400.0,
				0.0,
				12200.0
			],
			"legIndex" : -1,
			"brick" : "P16",
			"name" : "1570",
			"uuid" : "d4b6471e-8913-5d47-8604-4dcd26027c2f",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1571,
			"tags" : [
				"P16"
			],
			"type" : "panel",
			"position" : [
				48000.0,
				600.0,
				12200.0
			],
			"legIndex" : -1,
			"brick" : "P16",
			"name" : "1571",
			"uuid" : "bfb70aee-4069-4d4e-b4b5-eab32fe67de4",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1572,
			"tags" : [
				"P16"
			],
			"type" : "panel",
			"position" : [
				48600.0,
				0.0,
				12200.0
			],
			"legIndex" : -1,
			"brick" : "P16",
			"name" : "1572",
			"uuid" : "c8d3c64e-41c0-1f4f-896c-d8c973fc2ca1",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1573,
			"tags" : [
				"P16"
			],
			"type" : "panel",
			"position" : [
				48000.0,
				-600.0,
				10500.0
			],
			"legIndex" : -1,
			"brick" : "P16",
			"name" : "1573",
			"uuid" : "29998613-81a8-e745-b55e-f79f13d6ed66",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1574,
			"tags" : [
				"P16"
			],
			"type" : "panel",
			"position" : [
				47400.0,
				0.0,
				10500.0
			],
			"legIndex" : -1,
			"brick" : "P16",
			"name" : "1574",
			"uuid" : "9683bbee-8fb5-e94f-a31e-dd97468f6168",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1575,
			"tags" : [
				"P16"
			],
			"type" : "panel",
			"position" : [
				48000.0,
				600.0,
				10500.0
			],
			"legIndex" : -1,
			"brick" : "P16",
			"name" : "1575",
			"uuid" : "2523c8f6-d3a0-894a-9eb4-1494f977c4dc",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1576,
			"tags" : [
				"P16"
			],
			"type" : "panel",
			"position" : [
				48600.0,
				0.0,
				10500.0
			],
			"legIndex" : -1,
			"brick" : "P16",
			"name" : "1576",
			"uuid" : "126f91e8-8a20-ab4e-9acc-538396efeb68",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1577,
			"tags" : [
				"P16"
			],
			"type" : "panel",
			"position" : [
				48000.0,
				-600.0,
				8500.0
			],
			"legIndex" : -1,
			"brick" : "P16",
			"name" : "1577",
			"uuid" : "49adef4c-dad1-0549-8d20-27b33147724f",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1578,
			"tags" : [
				"P16"
			],
			"type" : "panel",
			"position" : [
				47400.0,
				0.0,
				8500.0
			],
			"legIndex" : -1,
			"brick" : "P16",
			"name" : "1578",
			"uuid" : "c23a83ca-53e9-2d41-b47a-ede930ad162a",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1579,
			"tags" : [
				"P16"
			],
			"type" : "panel",
			"position" : [
				48000.0,
				600.0,
				8500.0
			],
			"legIndex" : -1,
			"brick" : "P16",
			"name" : "1579",
			"uuid" : "c6b04ff2-3899-5242-a58c-e485015368c4",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1580,
			"tags" : [
				"P16"
			],
			"type" : "panel",
			"position" : [
				48600.0,
				0.0,
				8500.0
			],
			"legIndex" : -1,
			"brick" : "P16",
			"name" : "1580",
			"uuid" : "232699fd-291c-1f4e-af49-3abb756dcb00",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1581,
			"tags" : [
				"P16"
			],
			"type" : "panel",
			"position" : [
				48000.0,
				-738.0,
				6564.5
			],
			"legIndex" : -1,
			"brick" : "P16",
			"name" : "1581",
			"uuid" : "050dd26c-7bcd-fd46-9a35-513333b52e36",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1582,
			"tags" : [
				"P16"
			],
			"type" : "panel",
			"position" : [
				47262.0,
				0.0,
				6564.5
			],
			"legIndex" : -1,
			"brick" : "P16",
			"name" : "1582",
			"uuid" : "8aba91a1-c980-a84c-9f6d-a0e00e0c0b53",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1583,
			"tags" : [
				"P16"
			],
			"type" : "panel",
			"position" : [
				48000.0,
				738.0,
				6564.5
			],
			"legIndex" : -1,
			"brick" : "P16",
			"name" : "1583",
			"uuid" : "6026ff2b-a638-104a-bfb2-a989fb0cd3fd",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1584,
			"tags" : [
				"P16"
			],
			"type" : "panel",
			"position" : [
				48738.0,
				0.0,
				6564.5
			],
			"legIndex" : -1,
			"brick" : "P16",
			"name" : "1584",
			"uuid" : "fdc4055b-c0ab-644f-985a-c16c8f7f05f2",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1585,
			"tags" : [
				"P16"
			],
			"type" : "panel",
			"position" : [
				48000.0,
				-1120.3405,
				4111.1486
			],
			"legIndex" : -1,
			"brick" : "P16",
			"name" : "1585",
			"uuid" : "fa722c30-217f-eb4b-971f-a300dcfa4eef",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1586,
			"tags" : [
				"P16"
			],
			"type" : "panel",
			"position" : [
				46879.6595,
				0.0,
				4111.1486
			],
			"legIndex" : -1,
			"brick" : "P16",
			"name" : "1586",
			"uuid" : "fcdecac8-6bc2-5f42-ad67-d7d3bddce4cb",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1587,
			"tags" : [
				"P16"
			],
			"type" : "panel",
			"position" : [
				48000.0,
				1120.3405,
				4111.1486
			],
			"legIndex" : -1,
			"brick" : "P16",
			"name" : "1587",
			"uuid" : "1fa02b11-0176-4443-8704-5a578f385db1",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1588,
			"tags" : [
				"P16"
			],
			"type" : "panel",
			"position" : [
				49120.340500000006,
				0.0,
				4111.1486
			],
			"legIndex" : -1,
			"brick" : "P16",
			"name" : "1588",
			"uuid" : "c0fe4cf9-8834-3d4d-90c6-95c9d9c36109",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1589,
			"tags" : [
				"P16"
			],
			"type" : "panel",
			"position" : [
				48000.0,
				-1527.1165,
				1501.0025
			],
			"legIndex" : -1,
			"brick" : "P16",
			"name" : "1589",
			"uuid" : "d359e5e0-cf71-7a42-88ab-297c3063dd63",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1590,
			"tags" : [
				"P16"
			],
			"type" : "panel",
			"position" : [
				46472.8835,
				0.0,
				1501.0025
			],
			"legIndex" : -1,
			"brick" : "P16",
			"name" : "1590",
			"uuid" : "163faa5e-8a14-ef47-b4f2-45291cef2ec4",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1591,
			"tags" : [
				"P16"
			],
			"type" : "panel",
			"position" : [
				48000.0,
				1527.1165,
				1501.0025
			],
			"legIndex" : -1,
			"brick" : "P16",
			"name" : "1591",
			"uuid" : "0e5a73b0-ad48-7843-8685-51d02028f31d",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1592,
			"tags" : [
				"P16"
			],
			"type" : "panel",
			"position" : [
				49527.116500000004,
				0.0,
				1501.0025
			],
			"legIndex" : -1,
			"brick" : "P16",
			"name" : "1592",
			"uuid" : "d32b51a8-9c28-d244-9c19-052d1aadbcf6",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1600,
			"tags" : [
				"P17"
			],
			"type" : "slope",
			"position" : [
				64000.0,
				0.0,
				21750.0
			],
			"legIndex" : 0,
			"brick" : "P17",
			"name" : "1600",
			"uuid" : "60ec42bc-c50b-c24b-9dca-3761f94f7de4",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1601,
			"tags" : [
				"P17"
			],
			"type" : "slope",
			"position" : [
				64120.0,
				-120.0,
				20470.0
			],
			"legIndex" : 1,
			"brick" : "P17",
			"name" : "1601",
			"uuid" : "815b66fb-b019-d749-9a8d-7430bf788796",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1602,
			"tags" : [
				"P17"
			],
			"type" : "slope",
			"position" : [
				63880.0,
				-120.0,
				20470.0
			],
			"legIndex" : 2,
			"brick" : "P17",
			"name" : "1602",
			"uuid" : "2f50f033-295a-9b4d-85f8-807665362d52",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1603,
			"tags" : [
				"P17"
			],
			"type" : "slope",
			"position" : [
				63880.0,
				120.0,
				20470.0
			],
			"legIndex" : 3,
			"brick" : "P17",
			"name" : "1603",
			"uuid" : "66eba01e-77be-3449-98fb-a4208785b6d8",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1604,
			"tags" : [
				"P17"
			],
			"type" : "slope",
			"position" : [
				64120.0,
				120.0,
				20470.0
			],
			"legIndex" : 4,
			"brick" : "P17",
			"name" : "1604",
			"uuid" : "979183db-b2e9-da48-95a0-e223f44830a1",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1605,
			"tags" : [
				"P17"
			],
			"type" : "slope",
			"position" : [
				64240.0,
				-240.0,
				19190.0
			],
			"legIndex" : 1,
			"brick" : "P17",
			"name" : "1605",
			"uuid" : "6a2b2aa3-f6d6-654c-a611-633419f38683",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1606,
			"tags" : [
				"P17"
			],
			"type" : "slope",
			"position" : [
				63760.0,
				-240.0,
				19190.0
			],
			"legIndex" : 2,
			"brick" : "P17",
			"name" : "1606",
			"uuid" : "6e56305f-d07e-234b-bcd4-76893c97a73b",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1607,
			"tags" : [
				"P17"
			],
			"type" : "slope",
			"position" : [
				63760.0,
				240.0,
				19190.0
			],
			"legIndex" : 3,
			"brick" : "P17",
			"name" : "1607",
			"uuid" : "02b9922a-8a6a-a54f-9beb-00335488e5eb",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1608,
			"tags" : [
				"P17"
			],
			"type" : "slope",
			"position" : [
				64240.0,
				240.0,
				19190.0
			],
			"legIndex" : 4,
			"brick" : "P17",
			"name" : "1608",
			"uuid" : "b619efe5-5801-6642-9d86-2dcf00eea29d",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1609,
			"tags" : [
				"P17"
			],
			"type" : "slope",
			"position" : [
				64360.0,
				-360.0,
				17910.0
			],
			"legIndex" : 1,
			"brick" : "P17",
			"name" : "1609",
			"uuid" : "7ceb0845-f391-9e4d-82ba-4cd5c321b484",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1610,
			"tags" : [
				"P17"
			],
			"type" : "slope",
			"position" : [
				63640.0,
				-360.0,
				17910.0
			],
			"legIndex" : 2,
			"brick" : "P17",
			"name" : "1610",
			"uuid" : "16c6c9e6-0b62-d141-a1a0-fa1868cf4c69",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1611,
			"tags" : [
				"P17"
			],
			"type" : "slope",
			"position" : [
				63640.0,
				360.0,
				17910.0
			],
			"legIndex" : 3,
			"brick" : "P17",
			"name" : "1611",
			"uuid" : "684c434d-040a-5f46-8e0d-814626467f24",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1612,
			"tags" : [
				"P17"
			],
			"type" : "slope",
			"position" : [
				64360.0,
				360.0,
				17910.0
			],
			"legIndex" : 4,
			"brick" : "P17",
			"name" : "1612",
			"uuid" : "64f433e0-46ba-f54d-9389-2fd0c4310fd9",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1613,
			"tags" : [
				"P17"
			],
			"type" : "slope",
			"position" : [
				64480.0,
				-480.0,
				16630.0
			],
			"legIndex" : 1,
			"brick" : "P17",
			"name" : "1613",
			"uuid" : "711eb6fe-9b48-d34a-a87a-2dac9d51cda9",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1614,
			"tags" : [
				"P17"
			],
			"type" : "slope",
			"position" : [
				63520.0,
				-480.0,
				16630.0
			],
			"legIndex" : 2,
			"brick" : "P17",
			"name" : "1614",
			"uuid" : "a145d6fa-5cda-4845-871d-8599d96d35ee",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1615,
			"tags" : [
				"P17"
			],
			"type" : "slope",
			"position" : [
				63520.0,
				480.0,
				16630.0
			],
			"legIndex" : 3,
			"brick" : "P17",
			"name" : "1615",
			"uuid" : "40b58de0-7e64-3f4e-97ce-ffd4ed17c6dd",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1616,
			"tags" : [
				"P17"
			],
			"type" : "slope",
			"position" : [
				64480.0,
				480.0,
				16630.0
			],
			"legIndex" : 4,
			"brick" : "P17",
			"name" : "1616",
			"uuid" : "cae648e0-19c8-f846-9684-357b58801ccd",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1617,
			"tags" : [
				"P17"
			],
			"type" : "slope",
			"position" : [
				64600.0,
				-600.0,
				15350.0
			],
			"legIndex" : 1,
			"brick" : "P17",
			"name" : "1617",
			"uuid" : "bbf5d5a0-bf13-9749-b52e-6a9f13d85944",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1618,
			"tags" : [
				"B16",
				"P17"
			],
			"type" : "slope",
			"position" : [
				63400.0,
				-600.0,
				15350.0
			],
			"legIndex" : 1,
			"brick" : "P17",
			"name" : "1618",
			"uuid" : "94f83d6c-1ddb-b647-a442-9370536463a9",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1619,
			"tags" : [
				"B16",
				"P17"
			],
			"type" : "slope",
			"position" : [
				63400.0,
				600.0,
				15350.0
			],
			"legIndex" : 4,
			"brick" : "P17",
			"name" : "1619",
			"uuid" : "72f2a13f-f815-be4b-af13-bf9970f2d2ef",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1620,
			"tags" : [
				"P17"
			],
			"type" : "slope",
			"position" : [
				64600.0,
				600.0,
				15350.0
			],
			"legIndex" : 4,
			"brick" : "P17",
			"name" : "1620",
			"uuid" : "a2631b1b-3cce-ef4d-8e2e-7027839f1775",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1621,
			"tags" : [
				"P17"
			],
			"type" : "slope",
			"position" : [
				64600.0,
				-600.0,
				14150.0
			],
			"legIndex" : 1,
			"brick" : "P17",
			"name" : "1621",
			"uuid" : "fb22c15d-06df-da43-b80d-062610f9f716",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1622,
			"tags" : [
				"B16",
				"P17"
			],
			"type" : "slope",
			"position" : [
				63400.0,
				-600.0,
				14150.0
			],
			"legIndex" : 2,
			"brick" : "P17",
			"name" : "1622",
			"uuid" : "992d95a0-8b15-f142-bc89-213f6768ac02",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1623,
			"tags" : [
				"B16",
				"P17"
			],
			"type" : "slope",
			"position" : [
				63400.0,
				600.0,
				14150.0
			],
			"legIndex" : 3,
			"brick" : "P17",
			"name" : "1623",
			"uuid" : "a157f5a5-7bec-f642-89d4-fdc8f546ba5c",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1624,
			"tags" : [
				"P17"
			],
			"type" : "slope",
			"position" : [
				64600.0,
				600.0,
				14150.0
			],
			"legIndex" : 4,
			"brick" : "P17",
			"name" : "1624",
			"uuid" : "588b5c59-80f9-b04d-961e-b7a89fc2fcea",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1625,
			"tags" : [
				"P17"
			],
			"type" : "slope",
			"position" : [
				64600.0,
				-600.0,
				12950.0
			],
			"legIndex" : 1,
			"brick" : "P17",
			"name" : "1625",
			"uuid" : "6ea37e97-f1fa-2b44-95c5-bdd36aafc71a",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1626,
			"tags" : [
				"P17"
			],
			"type" : "slope",
			"position" : [
				63400.0,
				-600.0,
				12950.0
			],
			"legIndex" : 2,
			"brick" : "P17",
			"name" : "1626",
			"uuid" : "22927266-3b10-9a41-8d0e-0d82311f6ba4",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1627,
			"tags" : [
				"P17"
			],
			"type" : "slope",
			"position" : [
				63400.0,
				600.0,
				12950.0
			],
			"legIndex" : 3,
			"brick" : "P17",
			"name" : "1627",
			"uuid" : "1ec9b086-21af-f045-8cc7-82a210ddbc19",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1628,
			"tags" : [
				"P17"
			],
			"type" : "slope",
			"position" : [
				64600.0,
				600.0,
				12950.0
			],
			"legIndex" : 4,
			"brick" : "P17",
			"name" : "1628",
			"uuid" : "d1c06e30-6832-0944-9049-58da7d1d8980",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1629,
			"tags" : [
				"P17"
			],
			"type" : "slope",
			"position" : [
				64600.0,
				-600.0,
				12200.0
			],
			"legIndex" : 1,
			"brick" : "P17",
			"name" : "1629",
			"uuid" : "3e64b4db-c1ef-a24b-83d5-9f0804986829",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1630,
			"tags" : [
				"P17"
			],
			"type" : "slope",
			"position" : [
				63400.0,
				-600.0,
				12200.0
			],
			"legIndex" : 2,
			"brick" : "P17",
			"name" : "1630",
			"uuid" : "41758b2e-7d47-6243-81e6-8bcdaf96e887",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1631,
			"tags" : [
				"P17"
			],
			"type" : "slope",
			"position" : [
				63400.0,
				600.0,
				12200.0
			],
			"legIndex" : 3,
			"brick" : "P17",
			"name" : "1631",
			"uuid" : "e8148f14-f224-a746-adf1-dbeaf0a553cf",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1632,
			"tags" : [
				"P17"
			],
			"type" : "slope",
			"position" : [
				64600.0,
				600.0,
				12200.0
			],
			"legIndex" : 4,
			"brick" : "P17",
			"name" : "1632",
			"uuid" : "3616df43-6930-b442-afc8-7145ff1c5212",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1633,
			"tags" : [
				"P17"
			],
			"type" : "slope",
			"position" : [
				64600.0,
				-600.0,
				11450.0
			],
			"legIndex" : 1,
			"brick" : "P17",
			"name" : "1633",
			"uuid" : "1ac7f004-069d-5947-a38b-ad45c7881608",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1634,
			"tags" : [
				"P17"
			],
			"type" : "slope",
			"position" : [
				63400.0,
				-600.0,
				11450.0
			],
			"legIndex" : 2,
			"brick" : "P17",
			"name" : "1634",
			"uuid" : "bf6f0b42-a29a-3843-86d8-17a39b4f0a61",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1635,
			"tags" : [
				"P17"
			],
			"type" : "slope",
			"position" : [
				63400.0,
				600.0,
				11450.0
			],
			"legIndex" : 3,
			"brick" : "P17",
			"name" : "1635",
			"uuid" : "2c6b2565-8115-d44d-8c82-8a7d68519158",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1636,
			"tags" : [
				"P17"
			],
			"type" : "slope",
			"position" : [
				64600.0,
				600.0,
				11450.0
			],
			"legIndex" : 4,
			"brick" : "P17",
			"name" : "1636",
			"uuid" : "1f3ab014-271c-c148-9e52-8c924aa499a1",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1637,
			"tags" : [
				"P17"
			],
			"type" : "slope",
			"position" : [
				64600.0,
				-600.0,
				10500.0
			],
			"legIndex" : 1,
			"brick" : "P17",
			"name" : "1637",
			"uuid" : "845d0bed-9cf4-9b4e-aa0a-2fcd1363f5f2",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1638,
			"tags" : [
				"P17"
			],
			"type" : "slope",
			"position" : [
				63400.0,
				-600.0,
				10500.0
			],
			"legIndex" : 2,
			"brick" : "P17",
			"name" : "1638",
			"uuid" : "c62ac735-88e3-5d47-b362-175c5adda61f",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1639,
			"tags" : [
				"P17"
			],
			"type" : "slope",
			"position" : [
				63400.0,
				600.0,
				10500.0
			],
			"legIndex" : 3,
			"brick" : "P17",
			"name" : "1639",
			"uuid" : "6b10a647-99f8-eb4f-8fcc-6a8ba772ee05",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1640,
			"tags" : [
				"P17"
			],
			"type" : "slope",
			"position" : [
				64600.0,
				600.0,
				10500.0
			],
			"legIndex" : 4,
			"brick" : "P17",
			"name" : "1640",
			"uuid" : "94ce4f9c-1a3d-584b-8cff-b9c796c14344",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1641,
			"tags" : [
				"P17"
			],
			"type" : "slope",
			"position" : [
				64600.0,
				-600.0,
				9550.0
			],
			"legIndex" : 1,
			"brick" : "P17",
			"name" : "1641",
			"uuid" : "a8c9f1c1-9eb7-1042-b57e-fa649220d0c9",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1642,
			"tags" : [
				"P17"
			],
			"type" : "slope",
			"position" : [
				63400.0,
				-600.0,
				9550.0
			],
			"legIndex" : 2,
			"brick" : "P17",
			"name" : "1642",
			"uuid" : "08223d06-f9e0-e143-815b-86aa1662ba3b",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1643,
			"tags" : [
				"P17"
			],
			"type" : "slope",
			"position" : [
				63400.0,
				600.0,
				9550.0
			],
			"legIndex" : 3,
			"brick" : "P17",
			"name" : "1643",
			"uuid" : "1caabd6e-3e1d-5546-897c-3ce42c839a35",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1644,
			"tags" : [
				"P17"
			],
			"type" : "slope",
			"position" : [
				64600.0,
				600.0,
				9550.0
			],
			"legIndex" : 4,
			"brick" : "P17",
			"name" : "1644",
			"uuid" : "8ecd500d-f1fb-da45-8706-a5d1d20d9956",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1645,
			"tags" : [
				"P17"
			],
			"type" : "slope",
			"position" : [
				64600.0,
				-600.0,
				8500.0
			],
			"legIndex" : 1,
			"brick" : "P17",
			"name" : "1645",
			"uuid" : "6c9251e1-f45f-8d45-963f-5895f95bf3a2",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1646,
			"tags" : [
				"P17"
			],
			"type" : "slope",
			"position" : [
				63400.0,
				-600.0,
				8500.0
			],
			"legIndex" : 2,
			"brick" : "P17",
			"name" : "1646",
			"uuid" : "e66703a1-5fee-6d41-a519-635716ee04e1",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1647,
			"tags" : [
				"P17"
			],
			"type" : "slope",
			"position" : [
				63400.0,
				600.0,
				8500.0
			],
			"legIndex" : 3,
			"brick" : "P17",
			"name" : "1647",
			"uuid" : "d7e6f3fe-e1d3-164e-9f8c-46b90aed74c5",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1648,
			"tags" : [
				"P17"
			],
			"type" : "slope",
			"position" : [
				64600.0,
				600.0,
				8500.0
			],
			"legIndex" : 4,
			"brick" : "P17",
			"name" : "1648",
			"uuid" : "2511e26e-a606-044e-b2d9-7a53edbd0198",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1649,
			"tags" : [
				"P17"
			],
			"type" : "slope",
			"position" : [
				64600.0,
				-600.0,
				7450.0
			],
			"legIndex" : 1,
			"brick" : "P17",
			"name" : "1649",
			"uuid" : "dcdae12f-c4e8-ca4f-8b2e-66b28243245e",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1650,
			"tags" : [
				"P17"
			],
			"type" : "slope",
			"position" : [
				63400.0,
				-600.0,
				7450.0
			],
			"legIndex" : 2,
			"brick" : "P17",
			"name" : "1650",
			"uuid" : "990d672a-b1af-6e41-a00c-17a89b844711",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1651,
			"tags" : [
				"P17"
			],
			"type" : "slope",
			"position" : [
				63400.0,
				600.0,
				7450.0
			],
			"legIndex" : 3,
			"brick" : "P17",
			"name" : "1651",
			"uuid" : "815475e5-324c-254d-8a9f-b85e1f69b10e",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1652,
			"tags" : [
				"P17"
			],
			"type" : "slope",
			"position" : [
				64600.0,
				600.0,
				7450.0
			],
			"legIndex" : 4,
			"brick" : "P17",
			"name" : "1652",
			"uuid" : "42962560-95b7-2c41-9d10-3f517f6b506b",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1653,
			"tags" : [
				"P17"
			],
			"type" : "slope",
			"position" : [
				64738.0,
				-738.0,
				6564.5
			],
			"legIndex" : 1,
			"brick" : "P17",
			"name" : "1653",
			"uuid" : "1e4b9d22-2334-5442-b15f-bac7eeb50a17",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1654,
			"tags" : [
				"P17"
			],
			"type" : "slope",
			"position" : [
				63262.0,
				-738.0,
				6564.5
			],
			"legIndex" : 2,
			"brick" : "P17",
			"name" : "1654",
			"uuid" : "8c7be252-b4c6-1040-bf2b-8f5f7b73d101",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1655,
			"tags" : [
				"P17"
			],
			"type" : "slope",
			"position" : [
				63262.0,
				738.0,
				6564.5
			],
			"legIndex" : 3,
			"brick" : "P17",
			"name" : "1655",
			"uuid" : "2a92fcbf-bc50-ea43-9995-559769f8f9ba",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1656,
			"tags" : [
				"P17"
			],
			"type" : "slope",
			"position" : [
				64738.0,
				738.0,
				6564.5
			],
			"legIndex" : 4,
			"brick" : "P17",
			"name" : "1656",
			"uuid" : "842642cf-9f82-644e-868a-11027d8c2588",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1657,
			"tags" : [
				"P17"
			],
			"type" : "slope",
			"position" : [
				64958.441600000006,
				-958.4416,
				5150.0
			],
			"legIndex" : 1,
			"brick" : "P17",
			"name" : "1657",
			"uuid" : "0ce43c05-91b7-5e4c-a1f1-2140a9904246",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1658,
			"tags" : [
				"P17"
			],
			"type" : "slope",
			"position" : [
				63041.5584,
				-958.4416,
				5150.0
			],
			"legIndex" : 2,
			"brick" : "P17",
			"name" : "1658",
			"uuid" : "519a1aee-83d5-1144-a1fb-dcc7d9d431b0",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1659,
			"tags" : [
				"P17"
			],
			"type" : "slope",
			"position" : [
				63041.5584,
				958.4416,
				5150.0
			],
			"legIndex" : 3,
			"brick" : "P17",
			"name" : "1659",
			"uuid" : "acef381c-66a7-104a-8adb-af87c333d91c",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1660,
			"tags" : [
				"P17"
			],
			"type" : "slope",
			"position" : [
				64958.441600000006,
				958.4416,
				5150.0
			],
			"legIndex" : 4,
			"brick" : "P17",
			"name" : "1660",
			"uuid" : "f0b0880b-1301-494e-a649-a6e2643bd791",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1661,
			"tags" : [
				"P17"
			],
			"type" : "slope",
			"position" : [
				65120.340500000006,
				-1120.3405,
				4111.1486
			],
			"legIndex" : 1,
			"brick" : "P17",
			"name" : "1661",
			"uuid" : "f014e25e-c1e9-c146-b8ed-40172c6980b2",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1662,
			"tags" : [
				"P17"
			],
			"type" : "slope",
			"position" : [
				62879.6595,
				-1120.3405,
				4111.1486
			],
			"legIndex" : 2,
			"brick" : "P17",
			"name" : "1662",
			"uuid" : "a723bb16-4473-ec42-9490-cb75cdc82034",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1663,
			"tags" : [
				"P17"
			],
			"type" : "slope",
			"position" : [
				62879.6595,
				1120.3405,
				4111.1486
			],
			"legIndex" : 3,
			"brick" : "P17",
			"name" : "1663",
			"uuid" : "a9aeb75f-f41f-794b-b326-46529d7284f9",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1664,
			"tags" : [
				"P17"
			],
			"type" : "slope",
			"position" : [
				65120.340500000006,
				1120.3405,
				4111.1486
			],
			"legIndex" : 4,
			"brick" : "P17",
			"name" : "1664",
			"uuid" : "99e7dc29-70d7-fa4a-89e6-d04b6e20443a",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1665,
			"tags" : [
				"P17"
			],
			"type" : "slope",
			"position" : [
				65348.051900000006,
				-1348.0519000000002,
				2650.0
			],
			"legIndex" : 1,
			"brick" : "P17",
			"name" : "1665",
			"uuid" : "2e3c8932-66a3-dc4b-8490-351a7517d784",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1666,
			"tags" : [
				"P17"
			],
			"type" : "slope",
			"position" : [
				62651.9481,
				-1348.0519000000002,
				2650.0
			],
			"legIndex" : 2,
			"brick" : "P17",
			"name" : "1666",
			"uuid" : "c7a87ed6-026f-9541-a796-da356476ff90",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1667,
			"tags" : [
				"P17"
			],
			"type" : "slope",
			"position" : [
				62651.9481,
				1348.0519000000002,
				2650.0
			],
			"legIndex" : 3,
			"brick" : "P17",
			"name" : "1667",
			"uuid" : "b5704b70-c08b-9a4c-ab93-c64521a37a27",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1668,
			"tags" : [
				"P17"
			],
			"type" : "slope",
			"position" : [
				65348.051900000006,
				1348.0519000000002,
				2650.0
			],
			"legIndex" : 4,
			"brick" : "P17",
			"name" : "1668",
			"uuid" : "51e4327e-4953-0347-ab15-4ddcb0515bf6",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1669,
			"tags" : [
				"P17"
			],
			"type" : "slope",
			"position" : [
				65527.116500000004,
				-1527.1165,
				1501.0025
			],
			"legIndex" : 1,
			"brick" : "P17",
			"name" : "1669",
			"uuid" : "5ea11e0d-4a34-fe42-bbda-0899bce55287",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1670,
			"tags" : [
				"P17"
			],
			"type" : "slope",
			"position" : [
				62472.8835,
				-1527.1165,
				1501.0025
			],
			"legIndex" : 2,
			"brick" : "P17",
			"name" : "1670",
			"uuid" : "e15d85a9-156f-1c48-86c1-ca44251e0706",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1671,
			"tags" : [
				"P17"
			],
			"type" : "slope",
			"position" : [
				62472.8835,
				1527.1165,
				1501.0025
			],
			"legIndex" : 3,
			"brick" : "P17",
			"name" : "1671",
			"uuid" : "a1167dfb-6c36-3a41-a4e9-7847720059db",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1672,
			"tags" : [
				"P17"
			],
			"type" : "slope",
			"position" : [
				65527.116500000004,
				1527.1165,
				1501.0025
			],
			"legIndex" : 4,
			"brick" : "P17",
			"name" : "1672",
			"uuid" : "0f11e328-317d-7e44-b4c1-ca62a0c43976",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1673,
			"tags" : [
				"P17"
			],
			"type" : "slope",
			"position" : [
				65761.039,
				-1761.039,
				0.0
			],
			"legIndex" : 1,
			"brick" : "P17",
			"name" : "1673",
			"uuid" : "8b8a4c7f-c628-ad47-a5ed-135e3b03ff8d",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1674,
			"tags" : [
				"P17"
			],
			"type" : "slope",
			"position" : [
				62238.961,
				-1761.039,
				0.0
			],
			"legIndex" : 2,
			"brick" : "P17",
			"name" : "1674",
			"uuid" : "17ffdad2-4482-4d40-89ab-70afff1b7a57",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1675,
			"tags" : [
				"P17"
			],
			"type" : "slope",
			"position" : [
				62238.961,
				1761.039,
				0.0
			],
			"legIndex" : 3,
			"brick" : "P17",
			"name" : "1675",
			"uuid" : "de021881-8198-0b4d-807f-2335d10e11d3",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1676,
			"tags" : [
				"P17"
			],
			"type" : "slope",
			"position" : [
				65761.039,
				1761.039,
				0.0
			],
			"legIndex" : 4,
			"brick" : "P17",
			"name" : "1676",
			"uuid" : "b816a94e-0a2e-fc4e-b9fb-0fbb97b71e88",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1677,
			"tags" : [
				"P17"
			],
			"type" : "panel",
			"position" : [
				64000.0,
				-600.0,
				14750.0
			],
			"legIndex" : -1,
			"brick" : "P17",
			"name" : "1677",
			"uuid" : "95c78645-4e41-3746-a19b-189c91f3d61b",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1678,
			"tags" : [
				"P17"
			],
			"type" : "panel",
			"position" : [
				63400.0,
				0.0,
				14750.0
			],
			"legIndex" : -1,
			"brick" : "P17",
			"name" : "1678",
			"uuid" : "4d613830-8c0e-ba44-8c92-31f3ef274e47",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1679,
			"tags" : [
				"P17"
			],
			"type" : "panel",
			"position" : [
				64000.0,
				600.0,
				14750.0
			],
			"legIndex" : -1,
			"brick" : "P17",
			"name" : "1679",
			"uuid" : "aa74eae4-5b67-5c4a-a1ee-3ac5ddfca14b",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1680,
			"tags" : [
				"P17"
			],
			"type" : "panel",
			"position" : [
				64600.0,
				0.0,
				14750.0
			],
			"legIndex" : -1,
			"brick" : "P17",
			"name" : "1680",
			"uuid" : "47a959ce-e913-8f43-b991-8ce825b74115",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1681,
			"tags" : [
				"P17"
			],
			"type" : "panel",
			"position" : [
				64000.0,
				-600.0,
				13550.0
			],
			"legIndex" : -1,
			"brick" : "P17",
			"name" : "1681",
			"uuid" : "43fb10f6-ac4a-e348-9ca3-2b046a1f2b60",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1682,
			"tags" : [
				"P17"
			],
			"type" : "panel",
			"position" : [
				63400.0,
				0.0,
				13550.0
			],
			"legIndex" : -1,
			"brick" : "P17",
			"name" : "1682",
			"uuid" : "5ad78b5d-d506-7d44-bd32-37b20d699e28",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1683,
			"tags" : [
				"P17"
			],
			"type" : "panel",
			"position" : [
				64000.0,
				600.0,
				13550.0
			],
			"legIndex" : -1,
			"brick" : "P17",
			"name" : "1683",
			"uuid" : "2cf76208-6161-c94d-ba42-09becbcd301f",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1684,
			"tags" : [
				"P17"
			],
			"type" : "panel",
			"position" : [
				64600.0,
				0.0,
				13550.0
			],
			"legIndex" : -1,
			"brick" : "P17",
			"name" : "1684",
			"uuid" : "f8100c50-56bf-4144-9658-14980b9da2b7",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1685,
			"tags" : [
				"P17"
			],
			"type" : "panel",
			"position" : [
				64000.0,
				-600.0,
				12200.0
			],
			"legIndex" : -1,
			"brick" : "P17",
			"name" : "1685",
			"uuid" : "17f0407c-b782-fe46-a0fd-afe12ac56772",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1686,
			"tags" : [
				"P17"
			],
			"type" : "panel",
			"position" : [
				63400.0,
				0.0,
				12200.0
			],
			"legIndex" : -1,
			"brick" : "P17",
			"name" : "1686",
			"uuid" : "59308e70-1828-434a-ac4d-e4a28774fca6",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1687,
			"tags" : [
				"P17"
			],
			"type" : "panel",
			"position" : [
				64000.0,
				600.0,
				12200.0
			],
			"legIndex" : -1,
			"brick" : "P17",
			"name" : "1687",
			"uuid" : "3558abb6-8fd8-514a-90fb-fdec553b40e8",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1688,
			"tags" : [
				"P17"
			],
			"type" : "panel",
			"position" : [
				64600.0,
				0.0,
				12200.0
			],
			"legIndex" : -1,
			"brick" : "P17",
			"name" : "1688",
			"uuid" : "8ca64abf-219d-5446-bff3-5b577c58b505",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1689,
			"tags" : [
				"P17"
			],
			"type" : "panel",
			"position" : [
				64000.0,
				-600.0,
				10500.0
			],
			"legIndex" : -1,
			"brick" : "P17",
			"name" : "1689",
			"uuid" : "b743ac12-e735-ca49-8d94-f5c4ed22db06",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1690,
			"tags" : [
				"P17"
			],
			"type" : "panel",
			"position" : [
				63400.0,
				0.0,
				10500.0
			],
			"legIndex" : -1,
			"brick" : "P17",
			"name" : "1690",
			"uuid" : "c63a2a3f-f94d-d24f-8fcf-c765f866ec19",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1691,
			"tags" : [
				"P17"
			],
			"type" : "panel",
			"position" : [
				64000.0,
				600.0,
				10500.0
			],
			"legIndex" : -1,
			"brick" : "P17",
			"name" : "1691",
			"uuid" : "59ebd888-bc47-c649-94e9-21fc5f2eb0f0",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1692,
			"tags" : [
				"P17"
			],
			"type" : "panel",
			"position" : [
				64600.0,
				0.0,
				10500.0
			],
			"legIndex" : -1,
			"brick" : "P17",
			"name" : "1692",
			"uuid" : "38db9c33-9237-f043-93bf-cc40afa50874",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1693,
			"tags" : [
				"P17"
			],
			"type" : "panel",
			"position" : [
				64000.0,
				-600.0,
				8500.0
			],
			"legIndex" : -1,
			"brick" : "P17",
			"name" : "1693",
			"uuid" : "8620d8c2-cf56-6d40-b5e4-8c3d8630b4e1",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1694,
			"tags" : [
				"P17"
			],
			"type" : "panel",
			"position" : [
				63400.0,
				0.0,
				8500.0
			],
			"legIndex" : -1,
			"brick" : "P17",
			"name" : "1694",
			"uuid" : "1b3d0e0c-a445-a247-a407-231648c9e062",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1695,
			"tags" : [
				"P17"
			],
			"type" : "panel",
			"position" : [
				64000.0,
				600.0,
				8500.0
			],
			"legIndex" : -1,
			"brick" : "P17",
			"name" : "1695",
			"uuid" : "a906d2ee-9cb1-a447-8a3f-d01078846c20",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1696,
			"tags" : [
				"P17"
			],
			"type" : "panel",
			"position" : [
				64600.0,
				0.0,
				8500.0
			],
			"legIndex" : -1,
			"brick" : "P17",
			"name" : "1696",
			"uuid" : "0e101c02-c9f6-2e47-9dd9-5894fd0ec152",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1697,
			"tags" : [
				"P17"
			],
			"type" : "panel",
			"position" : [
				64000.0,
				-738.0,
				6564.5
			],
			"legIndex" : -1,
			"brick" : "P17",
			"name" : "1697",
			"uuid" : "16b7147d-49b7-c543-9e26-bb773fa21bcd",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1698,
			"tags" : [
				"P17"
			],
			"type" : "panel",
			"position" : [
				63262.0,
				0.0,
				6564.5
			],
			"legIndex" : -1,
			"brick" : "P17",
			"name" : "1698",
			"uuid" : "a7e0daec-0049-a74f-bda5-3dc804d96e46",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1699,
			"tags" : [
				"P17"
			],
			"type" : "panel",
			"position" : [
				64000.0,
				738.0,
				6564.5
			],
			"legIndex" : -1,
			"brick" : "P17",
			"name" : "1699",
			"uuid" : "41447de4-e484-0841-8e3d-526b7b1682ac",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1700,
			"tags" : [
				"P17"
			],
			"type" : "panel",
			"position" : [
				64738.0,
				0.0,
				6564.5
			],
			"legIndex" : -1,
			"brick" : "P17",
			"name" : "1700",
			"uuid" : "bed7e0c1-e59d-9e47-85a4-61ea1a720ed4",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1701,
			"tags" : [
				"P17"
			],
			"type" : "panel",
			"position" : [
				64000.0,
				-1120.3405,
				4111.1486
			],
			"legIndex" : -1,
			"brick" : "P17",
			"name" : "1701",
			"uuid" : "07cb5582-55b8-5245-9860-174d0e09ad5e",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1702,
			"tags" : [
				"P17"
			],
			"type" : "panel",
			"position" : [
				62879.6595,
				0.0,
				4111.1486
			],
			"legIndex" : -1,
			"brick" : "P17",
			"name" : "1702",
			"uuid" : "395d89ce-ecfc-804c-b094-fc2c94b504a6",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1703,
			"tags" : [
				"P17"
			],
			"type" : "panel",
			"position" : [
				64000.0,
				1120.3405,
				4111.1486
			],
			"legIndex" : -1,
			"brick" : "P17",
			"name" : "1703",
			"uuid" : "a4a33f2a-2aa8-774f-b358-48c9320d24a3",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1704,
			"tags" : [
				"P17"
			],
			"type" : "panel",
			"position" : [
				65120.340500000006,
				0.0,
				4111.1486
			],
			"legIndex" : -1,
			"brick" : "P17",
			"name" : "1704",
			"uuid" : "68d63a02-3648-344a-b953-b0757cf25521",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1705,
			"tags" : [
				"P17"
			],
			"type" : "panel",
			"position" : [
				64000.0,
				-1527.1165,
				1501.0025
			],
			"legIndex" : -1,
			"brick" : "P17",
			"name" : "1705",
			"uuid" : "985416ec-a93b-3246-b631-6d472fad8831",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1706,
			"tags" : [
				"P17"
			],
			"type" : "panel",
			"position" : [
				62472.8835,
				0.0,
				1501.0025
			],
			"legIndex" : -1,
			"brick" : "P17",
			"name" : "1706",
			"uuid" : "138cae93-c17e-8a4f-9790-84137eef7916",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1707,
			"tags" : [
				"P17"
			],
			"type" : "panel",
			"position" : [
				64000.0,
				1527.1165,
				1501.0025
			],
			"legIndex" : -1,
			"brick" : "P17",
			"name" : "1707",
			"uuid" : "46da349a-e4a4-8a4d-8e3d-1c52a7c787a0",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1708,
			"tags" : [
				"P17"
			],
			"type" : "panel",
			"position" : [
				65527.116500000004,
				0.0,
				1501.0025
			],
			"legIndex" : -1,
			"brick" : "P17",
			"name" : "1708",
			"uuid" : "d50f060b-2449-9945-8b63-7a55a492f692",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1801,
			"tags" : [
				"B13"
			],
			"type" : "slope",
			"position" : [
				1800.0,
				-600.0,
				15350.0
			],
			"legIndex" : 1,
			"brick" : "B13",
			"name" : "1801",
			"uuid" : "84fe0938-f92f-7448-aba9-6e62c7b375a6",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1802,
			"tags" : [
				"B13"
			],
			"type" : "slope",
			"position" : [
				1800.0,
				-600.0,
				14150.0
			],
			"legIndex" : 2,
			"brick" : "B13",
			"name" : "1802",
			"uuid" : "498e262a-d204-5f4b-807d-92d0cfcc181e",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1803,
			"tags" : [
				"B13"
			],
			"type" : "slope",
			"position" : [
				1800.0,
				600.0,
				14150.0
			],
			"legIndex" : 3,
			"brick" : "B13",
			"name" : "1803",
			"uuid" : "c97841b7-3457-714c-9cb8-27b44f6d9a36",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1804,
			"tags" : [
				"B13"
			],
			"type" : "slope",
			"position" : [
				1800.0,
				600.0,
				15350.0
			],
			"legIndex" : 4,
			"brick" : "B13",
			"name" : "1804",
			"uuid" : "27ba30db-10ca-254d-803d-c5b7d909cb75",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1805,
			"tags" : [
				"B13"
			],
			"type" : "slope",
			"position" : [
				3000.0,
				-600.0,
				15350.0
			],
			"legIndex" : 1,
			"brick" : "B13",
			"name" : "1805",
			"uuid" : "624ec6a9-a0cd-f643-8d98-e573fb5435ba",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1806,
			"tags" : [
				"B13"
			],
			"type" : "slope",
			"position" : [
				3000.0,
				-600.0,
				14150.0
			],
			"legIndex" : 2,
			"brick" : "B13",
			"name" : "1806",
			"uuid" : "78dcfa2e-cfe2-604d-b72f-92f2e0f256b0",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1807,
			"tags" : [
				"B13"
			],
			"type" : "slope",
			"position" : [
				3000.0,
				600.0,
				14150.0
			],
			"legIndex" : 3,
			"brick" : "B13",
			"name" : "1807",
			"uuid" : "8fa9bb82-d050-b44d-9811-1536c9a0b592",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1808,
			"tags" : [
				"B13"
			],
			"type" : "slope",
			"position" : [
				3000.0,
				600.0,
				15350.0
			],
			"legIndex" : 4,
			"brick" : "B13",
			"name" : "1808",
			"uuid" : "8dd440b9-db0d-6e48-b32d-bbfbd25ddb7a",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1809,
			"tags" : [
				"B13"
			],
			"type" : "slope",
			"position" : [
				4000.0,
				-600.0,
				15350.0
			],
			"legIndex" : 1,
			"brick" : "B13",
			"name" : "1809",
			"uuid" : "37797bea-e2dc-3d4e-87ef-a2e4f080cb7a",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1810,
			"tags" : [
				"B13"
			],
			"type" : "slope",
			"position" : [
				4000.0,
				-600.0,
				14150.0
			],
			"legIndex" : 2,
			"brick" : "B13",
			"name" : "1810",
			"uuid" : "a8c70f29-087e-074c-bdf0-778d6b9e3ef7",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1811,
			"tags" : [
				"B13"
			],
			"type" : "slope",
			"position" : [
				4000.0,
				600.0,
				14150.0
			],
			"legIndex" : 3,
			"brick" : "B13",
			"name" : "1811",
			"uuid" : "daecf456-85b6-3c4e-abb4-0b3ee0d399ce",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1812,
			"tags" : [
				"B13"
			],
			"type" : "slope",
			"position" : [
				4000.0,
				600.0,
				15350.0
			],
			"legIndex" : 4,
			"brick" : "B13",
			"name" : "1812",
			"uuid" : "a814f26e-9d62-f848-9262-00a565767a8f",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1813,
			"tags" : [
				"B13"
			],
			"type" : "slope",
			"position" : [
				5000.0,
				-600.0,
				15350.0
			],
			"legIndex" : 1,
			"brick" : "B13",
			"name" : "1813",
			"uuid" : "f52ab216-44e6-9f45-bdae-4ec2427095a0",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1814,
			"tags" : [
				"B13"
			],
			"type" : "slope",
			"position" : [
				5000.0,
				-600.0,
				14150.0
			],
			"legIndex" : 2,
			"brick" : "B13",
			"name" : "1814",
			"uuid" : "cf58295d-6c0b-3340-a253-8a4cf614358b",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1815,
			"tags" : [
				"B13"
			],
			"type" : "slope",
			"position" : [
				5000.0,
				600.0,
				14150.0
			],
			"legIndex" : 3,
			"brick" : "B13",
			"name" : "1815",
			"uuid" : "116cbe17-aa68-6743-ad78-8dfbc98eb39c",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1816,
			"tags" : [
				"B13"
			],
			"type" : "slope",
			"position" : [
				5000.0,
				600.0,
				15350.0
			],
			"legIndex" : 4,
			"brick" : "B13",
			"name" : "1816",
			"uuid" : "c35c0a3f-0168-ba4f-b376-1aa92f9eb551",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1817,
			"tags" : [
				"B13"
			],
			"type" : "slope",
			"position" : [
				6000.0,
				-600.0,
				15350.0
			],
			"legIndex" : 1,
			"brick" : "B13",
			"name" : "1817",
			"uuid" : "57e21438-b79f-f44d-ae73-4285fc359c08",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1818,
			"tags" : [
				"B13"
			],
			"type" : "slope",
			"position" : [
				6000.0,
				-600.0,
				14150.0
			],
			"legIndex" : 2,
			"brick" : "B13",
			"name" : "1818",
			"uuid" : "b966aedd-7d82-3f41-b009-ef70ebf46932",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1819,
			"tags" : [
				"B13"
			],
			"type" : "slope",
			"position" : [
				6000.0,
				600.0,
				14150.0
			],
			"legIndex" : 3,
			"brick" : "B13",
			"name" : "1819",
			"uuid" : "ddf47068-97ee-d04e-a730-a0460d48ea12",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1820,
			"tags" : [
				"B13"
			],
			"type" : "slope",
			"position" : [
				6000.0,
				600.0,
				15350.0
			],
			"legIndex" : 4,
			"brick" : "B13",
			"name" : "1820",
			"uuid" : "bb4d8cb5-07c5-104c-ac5c-2b307d3d3ee3",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1821,
			"tags" : [
				"B13"
			],
			"type" : "slope",
			"position" : [
				7000.0,
				-600.0,
				15350.0
			],
			"legIndex" : 1,
			"brick" : "B13",
			"name" : "1821",
			"uuid" : "b4780bd5-f85d-f44d-adf2-c20fbfd8d7db",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1822,
			"tags" : [
				"B13"
			],
			"type" : "slope",
			"position" : [
				7000.0,
				-600.0,
				14150.0
			],
			"legIndex" : 2,
			"brick" : "B13",
			"name" : "1822",
			"uuid" : "028c7434-1c3e-de4a-b21e-f4424141feec",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1823,
			"tags" : [
				"B13"
			],
			"type" : "slope",
			"position" : [
				7000.0,
				600.0,
				14150.0
			],
			"legIndex" : 3,
			"brick" : "B13",
			"name" : "1823",
			"uuid" : "d850fdb7-508e-f944-b491-72be62552d99",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1824,
			"tags" : [
				"B13"
			],
			"type" : "slope",
			"position" : [
				7000.0,
				600.0,
				15350.0
			],
			"legIndex" : 4,
			"brick" : "B13",
			"name" : "1824",
			"uuid" : "a0f6bb73-957f-5b4f-8356-ba6720de10f8",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1825,
			"tags" : [
				"B13"
			],
			"type" : "slope",
			"position" : [
				8000.0,
				-600.0,
				15350.0
			],
			"legIndex" : 1,
			"brick" : "B13",
			"name" : "1825",
			"uuid" : "f414a3d8-e5bf-de49-a0a8-24256ab20b10",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1826,
			"tags" : [
				"B13"
			],
			"type" : "slope",
			"position" : [
				8000.0,
				-600.0,
				14150.0
			],
			"legIndex" : 2,
			"brick" : "B13",
			"name" : "1826",
			"uuid" : "65a62683-0f4e-834f-ba60-236e280add85",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1827,
			"tags" : [
				"B13"
			],
			"type" : "slope",
			"position" : [
				8000.0,
				600.0,
				14150.0
			],
			"legIndex" : 3,
			"brick" : "B13",
			"name" : "1827",
			"uuid" : "61a29728-8bfd-db44-b8b7-f0df29df6c6c",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1828,
			"tags" : [
				"B13"
			],
			"type" : "slope",
			"position" : [
				8000.0,
				600.0,
				15350.0
			],
			"legIndex" : 4,
			"brick" : "B13",
			"name" : "1828",
			"uuid" : "c18dd1e6-4da2-0a4e-b338-14217e99031e",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1829,
			"tags" : [
				"B13"
			],
			"type" : "slope",
			"position" : [
				9000.0,
				-600.0,
				15350.0
			],
			"legIndex" : 1,
			"brick" : "B13",
			"name" : "1829",
			"uuid" : "c80a67d1-3067-a745-ae48-770166f38d21",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1830,
			"tags" : [
				"B13"
			],
			"type" : "slope",
			"position" : [
				9000.0,
				-600.0,
				14150.0
			],
			"legIndex" : 2,
			"brick" : "B13",
			"name" : "1830",
			"uuid" : "521416e3-8258-024c-b118-c1dfac827c9b",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1831,
			"tags" : [
				"B13"
			],
			"type" : "slope",
			"position" : [
				9000.0,
				600.0,
				14150.0
			],
			"legIndex" : 3,
			"brick" : "B13",
			"name" : "1831",
			"uuid" : "2d654905-17a7-3b4e-9db7-2870e2a9f88c",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1832,
			"tags" : [
				"B13"
			],
			"type" : "slope",
			"position" : [
				9000.0,
				600.0,
				15350.0
			],
			"legIndex" : 4,
			"brick" : "B13",
			"name" : "1832",
			"uuid" : "d152f158-a0c6-e348-a6b2-3e27f092230f",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1833,
			"tags" : [
				"B13"
			],
			"type" : "slope",
			"position" : [
				10000.0,
				-600.0,
				15350.0
			],
			"legIndex" : 1,
			"brick" : "B13",
			"name" : "1833",
			"uuid" : "dabe4738-ef65-eb4c-8baf-b833db453efb",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1834,
			"tags" : [
				"B13"
			],
			"type" : "slope",
			"position" : [
				10000.0,
				-600.0,
				14150.0
			],
			"legIndex" : 2,
			"brick" : "B13",
			"name" : "1834",
			"uuid" : "4fca46b5-6dc0-714c-b5ab-40d92426b14e",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1835,
			"tags" : [
				"B13"
			],
			"type" : "slope",
			"position" : [
				10000.0,
				600.0,
				14150.0
			],
			"legIndex" : 3,
			"brick" : "B13",
			"name" : "1835",
			"uuid" : "d3d4f3fb-184c-0c4f-9e82-85782974f4dd",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1836,
			"tags" : [
				"B13"
			],
			"type" : "slope",
			"position" : [
				10000.0,
				600.0,
				15350.0
			],
			"legIndex" : 4,
			"brick" : "B13",
			"name" : "1836",
			"uuid" : "89632538-6b26-e24c-9c67-7155f765a7aa",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1837,
			"tags" : [
				"B13"
			],
			"type" : "slope",
			"position" : [
				11000.0,
				-600.0,
				15350.0
			],
			"legIndex" : 1,
			"brick" : "B13",
			"name" : "1837",
			"uuid" : "701dbc5f-9629-284d-9c6b-bcb7a7c1a663",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1838,
			"tags" : [
				"B13"
			],
			"type" : "slope",
			"position" : [
				11000.0,
				-600.0,
				14150.0
			],
			"legIndex" : 2,
			"brick" : "B13",
			"name" : "1838",
			"uuid" : "5ccc2cbd-f7a7-f34f-831c-c4c97ed25e4f",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1839,
			"tags" : [
				"B13"
			],
			"type" : "slope",
			"position" : [
				11000.0,
				600.0,
				14150.0
			],
			"legIndex" : 3,
			"brick" : "B13",
			"name" : "1839",
			"uuid" : "6a70b1c6-b254-f946-bc74-1a1375ad17cf",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1840,
			"tags" : [
				"B13"
			],
			"type" : "slope",
			"position" : [
				11000.0,
				600.0,
				15350.0
			],
			"legIndex" : 4,
			"brick" : "B13",
			"name" : "1840",
			"uuid" : "a760311a-64d1-764e-8fa3-10c23b00f608",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1841,
			"tags" : [
				"B13"
			],
			"type" : "slope",
			"position" : [
				12000.0,
				-600.0,
				15350.0
			],
			"legIndex" : 1,
			"brick" : "B13",
			"name" : "1841",
			"uuid" : "dea3b965-54a5-5743-9c54-4abff9749e9a",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1842,
			"tags" : [
				"B13"
			],
			"type" : "slope",
			"position" : [
				12000.0,
				-600.0,
				14150.0
			],
			"legIndex" : 2,
			"brick" : "B13",
			"name" : "1842",
			"uuid" : "3c7f0338-e3bb-c54e-9745-cefe7f163284",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1843,
			"tags" : [
				"B13"
			],
			"type" : "slope",
			"position" : [
				12000.0,
				600.0,
				14150.0
			],
			"legIndex" : 3,
			"brick" : "B13",
			"name" : "1843",
			"uuid" : "064d2377-e690-9e40-8fa4-3a7d851a59f7",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1844,
			"tags" : [
				"B13"
			],
			"type" : "slope",
			"position" : [
				12000.0,
				600.0,
				15350.0
			],
			"legIndex" : 4,
			"brick" : "B13",
			"name" : "1844",
			"uuid" : "4f5b8c8a-2915-cd44-b5e5-fb5dc3a43c61",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1845,
			"tags" : [
				"B13"
			],
			"type" : "slope",
			"position" : [
				13000.0,
				-600.0,
				15350.0
			],
			"legIndex" : 1,
			"brick" : "B13",
			"name" : "1845",
			"uuid" : "dba2115e-d779-844c-8e93-0a11f04d0ea1",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1846,
			"tags" : [
				"B13"
			],
			"type" : "slope",
			"position" : [
				13000.0,
				-600.0,
				14150.0
			],
			"legIndex" : 2,
			"brick" : "B13",
			"name" : "1846",
			"uuid" : "930356a4-6edc-dc4b-9cef-c7c9030fb89c",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1847,
			"tags" : [
				"B13"
			],
			"type" : "slope",
			"position" : [
				13000.0,
				600.0,
				14150.0
			],
			"legIndex" : 3,
			"brick" : "B13",
			"name" : "1847",
			"uuid" : "43421b70-1cce-fc41-a355-f8be4e1fadcc",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1848,
			"tags" : [
				"B13"
			],
			"type" : "slope",
			"position" : [
				13000.0,
				600.0,
				15350.0
			],
			"legIndex" : 4,
			"brick" : "B13",
			"name" : "1848",
			"uuid" : "78b8d288-0637-af4f-97e9-560bfa069f20",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1849,
			"tags" : [
				"B13"
			],
			"type" : "slope",
			"position" : [
				14200.0,
				-600.0,
				15350.0
			],
			"legIndex" : 1,
			"brick" : "B13",
			"name" : "1849",
			"uuid" : "6fa49d72-ba2a-a447-a820-d923b2d37cbb",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1850,
			"tags" : [
				"B13"
			],
			"type" : "slope",
			"position" : [
				14200.0,
				-600.0,
				14150.0
			],
			"legIndex" : 2,
			"brick" : "B13",
			"name" : "1850",
			"uuid" : "3eafe023-1742-d34b-b1e6-113c63f4288c",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1851,
			"tags" : [
				"B13"
			],
			"type" : "slope",
			"position" : [
				14200.0,
				600.0,
				14150.0
			],
			"legIndex" : 3,
			"brick" : "B13",
			"name" : "1851",
			"uuid" : "d1a8ca44-1730-6d4d-83ec-40d8d5b7c5c0",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1852,
			"tags" : [
				"B13"
			],
			"type" : "slope",
			"position" : [
				14200.0,
				600.0,
				15350.0
			],
			"legIndex" : 4,
			"brick" : "B13",
			"name" : "1852",
			"uuid" : "d2d96860-661b-1e47-a11a-91c28b5a2877",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1853,
			"tags" : [
				"B13"
			],
			"type" : "panel",
			"position" : [
				4000.0,
				0.0,
				14150.0
			],
			"legIndex" : -1,
			"brick" : "B13",
			"name" : "1853",
			"uuid" : "42d6a181-0360-d14f-addc-f99f3791178c",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1854,
			"tags" : [
				"B13"
			],
			"type" : "panel",
			"position" : [
				4000.0,
				0.0,
				15350.0
			],
			"legIndex" : -1,
			"brick" : "B13",
			"name" : "1854",
			"uuid" : "5ad9dcc3-9897-9240-be37-547eaf3b5371",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1855,
			"tags" : [
				"B13"
			],
			"type" : "panel",
			"position" : [
				8000.0,
				0.0,
				14150.0
			],
			"legIndex" : -1,
			"brick" : "B13",
			"name" : "1855",
			"uuid" : "53ec8038-6746-f145-af1d-4906bc6b6730",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1856,
			"tags" : [
				"B13"
			],
			"type" : "panel",
			"position" : [
				8000.0,
				0.0,
				15350.0
			],
			"legIndex" : -1,
			"brick" : "B13",
			"name" : "1856",
			"uuid" : "15ede0fb-59b9-364f-9971-fb3101a53a70",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1857,
			"tags" : [
				"B13"
			],
			"type" : "panel",
			"position" : [
				12000.0,
				0.0,
				14150.0
			],
			"legIndex" : -1,
			"brick" : "B13",
			"name" : "1857",
			"uuid" : "5222217d-64bf-d34e-8d9c-862444e4d4ce",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1858,
			"tags" : [
				"B13"
			],
			"type" : "panel",
			"position" : [
				12000.0,
				0.0,
				15350.0
			],
			"legIndex" : -1,
			"brick" : "B13",
			"name" : "1858",
			"uuid" : "38f2165f-2e71-8545-82fd-0e44f78d5418",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1901,
			"tags" : [
				"B14"
			],
			"type" : "slope",
			"position" : [
				17800.0,
				-600.0,
				15350.0
			],
			"legIndex" : 1,
			"brick" : "B14",
			"name" : "1901",
			"uuid" : "8576b4d4-1d76-4548-930c-0d9d3fa422c0",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1902,
			"tags" : [
				"B14"
			],
			"type" : "slope",
			"position" : [
				17800.0,
				-600.0,
				14150.0
			],
			"legIndex" : 2,
			"brick" : "B14",
			"name" : "1902",
			"uuid" : "069fe2df-1147-9e46-bf2b-272c8b247d52",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1903,
			"tags" : [
				"B14"
			],
			"type" : "slope",
			"position" : [
				17800.0,
				600.0,
				14150.0
			],
			"legIndex" : 3,
			"brick" : "B14",
			"name" : "1903",
			"uuid" : "9e7dad2c-1fdf-db49-af90-7586f197982e",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1904,
			"tags" : [
				"B14"
			],
			"type" : "slope",
			"position" : [
				17800.0,
				600.0,
				15350.0
			],
			"legIndex" : 4,
			"brick" : "B14",
			"name" : "1904",
			"uuid" : "65489347-6da6-8746-af53-0e1abd25ac78",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1905,
			"tags" : [
				"B14"
			],
			"type" : "slope",
			"position" : [
				19000.0,
				-600.0,
				15350.0
			],
			"legIndex" : 1,
			"brick" : "B14",
			"name" : "1905",
			"uuid" : "1f9edf0e-dcaf-3744-8926-461bb428949e",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1906,
			"tags" : [
				"B14"
			],
			"type" : "slope",
			"position" : [
				19000.0,
				-600.0,
				14150.0
			],
			"legIndex" : 2,
			"brick" : "B14",
			"name" : "1906",
			"uuid" : "670d6067-f4f7-2f4e-a8f2-7020209c36ae",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1907,
			"tags" : [
				"B14"
			],
			"type" : "slope",
			"position" : [
				19000.0,
				600.0,
				14150.0
			],
			"legIndex" : 3,
			"brick" : "B14",
			"name" : "1907",
			"uuid" : "1be61bd8-31f7-a64a-91da-d7e396872ca2",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1908,
			"tags" : [
				"B14"
			],
			"type" : "slope",
			"position" : [
				19000.0,
				600.0,
				15350.0
			],
			"legIndex" : 4,
			"brick" : "B14",
			"name" : "1908",
			"uuid" : "799cd827-6181-444e-9acc-9737fd7a0257",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1909,
			"tags" : [
				"B14"
			],
			"type" : "slope",
			"position" : [
				20000.0,
				-600.0,
				15350.0
			],
			"legIndex" : 1,
			"brick" : "B14",
			"name" : "1909",
			"uuid" : "ccff1bc1-d797-bd4f-97d6-0bfe8d03d607",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1910,
			"tags" : [
				"B14"
			],
			"type" : "slope",
			"position" : [
				20000.0,
				-600.0,
				14150.0
			],
			"legIndex" : 2,
			"brick" : "B14",
			"name" : "1910",
			"uuid" : "f8e47008-47de-b244-ad32-091780fa50ed",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1911,
			"tags" : [
				"B14"
			],
			"type" : "slope",
			"position" : [
				20000.0,
				600.0,
				14150.0
			],
			"legIndex" : 3,
			"brick" : "B14",
			"name" : "1911",
			"uuid" : "d54a1a15-b263-e441-960c-f04802626ba2",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1912,
			"tags" : [
				"B14"
			],
			"type" : "slope",
			"position" : [
				20000.0,
				600.0,
				15350.0
			],
			"legIndex" : 4,
			"brick" : "B14",
			"name" : "1912",
			"uuid" : "704dd910-52b7-bf40-9c25-910d0ac59f2a",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1913,
			"tags" : [
				"B14"
			],
			"type" : "slope",
			"position" : [
				21000.0,
				-600.0,
				15350.0
			],
			"legIndex" : 1,
			"brick" : "B14",
			"name" : "1913",
			"uuid" : "10d402c5-5f75-d644-8162-2b04d11ee4aa",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1914,
			"tags" : [
				"B14"
			],
			"type" : "slope",
			"position" : [
				21000.0,
				-600.0,
				14150.0
			],
			"legIndex" : 2,
			"brick" : "B14",
			"name" : "1914",
			"uuid" : "55d957ad-08ca-3143-810c-5e1b6e1ad024",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1915,
			"tags" : [
				"B14"
			],
			"type" : "slope",
			"position" : [
				21000.0,
				600.0,
				14150.0
			],
			"legIndex" : 3,
			"brick" : "B14",
			"name" : "1915",
			"uuid" : "f10498a4-6446-4f4c-8cb8-01b1afdd5f79",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1916,
			"tags" : [
				"B14"
			],
			"type" : "slope",
			"position" : [
				21000.0,
				600.0,
				15350.0
			],
			"legIndex" : 4,
			"brick" : "B14",
			"name" : "1916",
			"uuid" : "d020dbe4-c614-dc46-b1d1-acf892834b43",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1917,
			"tags" : [
				"B14"
			],
			"type" : "slope",
			"position" : [
				22000.0,
				-600.0,
				15350.0
			],
			"legIndex" : 1,
			"brick" : "B14",
			"name" : "1917",
			"uuid" : "add93f93-538e-8849-8bbf-6f39d997d748",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1918,
			"tags" : [
				"B14"
			],
			"type" : "slope",
			"position" : [
				22000.0,
				-600.0,
				14150.0
			],
			"legIndex" : 2,
			"brick" : "B14",
			"name" : "1918",
			"uuid" : "30f282d4-e79f-924f-89aa-d06e6d0edabb",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1919,
			"tags" : [
				"B14"
			],
			"type" : "slope",
			"position" : [
				22000.0,
				600.0,
				14150.0
			],
			"legIndex" : 3,
			"brick" : "B14",
			"name" : "1919",
			"uuid" : "012ec121-b8e8-8f46-86ba-b9ba78e5e38b",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1920,
			"tags" : [
				"B14"
			],
			"type" : "slope",
			"position" : [
				22000.0,
				600.0,
				15350.0
			],
			"legIndex" : 4,
			"brick" : "B14",
			"name" : "1920",
			"uuid" : "3983dfbe-1414-a34e-b79d-f8a568fd6acb",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1921,
			"tags" : [
				"B14"
			],
			"type" : "slope",
			"position" : [
				23000.0,
				-600.0,
				15350.0
			],
			"legIndex" : 1,
			"brick" : "B14",
			"name" : "1921",
			"uuid" : "c72d1454-73e5-db43-b07d-7923e13708b7",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1922,
			"tags" : [
				"B14"
			],
			"type" : "slope",
			"position" : [
				23000.0,
				-600.0,
				14150.0
			],
			"legIndex" : 2,
			"brick" : "B14",
			"name" : "1922",
			"uuid" : "76241fb5-0cf2-4746-9de2-675c0fa45b30",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1923,
			"tags" : [
				"B14"
			],
			"type" : "slope",
			"position" : [
				23000.0,
				600.0,
				14150.0
			],
			"legIndex" : 3,
			"brick" : "B14",
			"name" : "1923",
			"uuid" : "dbfd40b0-0e53-8649-9ad7-637610b22ab7",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1924,
			"tags" : [
				"B14"
			],
			"type" : "slope",
			"position" : [
				23000.0,
				600.0,
				15350.0
			],
			"legIndex" : 4,
			"brick" : "B14",
			"name" : "1924",
			"uuid" : "2e984935-a463-7f46-9d42-e23372977b8a",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1925,
			"tags" : [
				"B14"
			],
			"type" : "slope",
			"position" : [
				24000.0,
				-600.0,
				15350.0
			],
			"legIndex" : 1,
			"brick" : "B14",
			"name" : "1925",
			"uuid" : "e319ebab-4675-744e-b3d8-9930fe616023",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1926,
			"tags" : [
				"B14"
			],
			"type" : "slope",
			"position" : [
				24000.0,
				-600.0,
				14150.0
			],
			"legIndex" : 2,
			"brick" : "B14",
			"name" : "1926",
			"uuid" : "d7315479-9069-1a40-a6a4-438753d9b804",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1927,
			"tags" : [
				"B14"
			],
			"type" : "slope",
			"position" : [
				24000.0,
				600.0,
				14150.0
			],
			"legIndex" : 3,
			"brick" : "B14",
			"name" : "1927",
			"uuid" : "d2caf7d4-b95e-d14f-9a6c-06954cbf08b6",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1928,
			"tags" : [
				"B14"
			],
			"type" : "slope",
			"position" : [
				24000.0,
				600.0,
				15350.0
			],
			"legIndex" : 4,
			"brick" : "B14",
			"name" : "1928",
			"uuid" : "6d6519b2-0d5f-ec47-9089-501ee119d8fb",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1929,
			"tags" : [
				"B14"
			],
			"type" : "slope",
			"position" : [
				25000.0,
				-600.0,
				15350.0
			],
			"legIndex" : 1,
			"brick" : "B14",
			"name" : "1929",
			"uuid" : "a34d195a-3cdb-394f-ac18-41338c45287d",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1930,
			"tags" : [
				"B14"
			],
			"type" : "slope",
			"position" : [
				25000.0,
				-600.0,
				14150.0
			],
			"legIndex" : 2,
			"brick" : "B14",
			"name" : "1930",
			"uuid" : "bf6eb52f-6f44-c84e-9f60-c52c3e0ece20",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1931,
			"tags" : [
				"B14"
			],
			"type" : "slope",
			"position" : [
				25000.0,
				600.0,
				14150.0
			],
			"legIndex" : 3,
			"brick" : "B14",
			"name" : "1931",
			"uuid" : "a92b4c97-d143-464c-b299-7eb9d1302c6b",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1932,
			"tags" : [
				"B14"
			],
			"type" : "slope",
			"position" : [
				25000.0,
				600.0,
				15350.0
			],
			"legIndex" : 4,
			"brick" : "B14",
			"name" : "1932",
			"uuid" : "69f6f687-8488-bd4b-854e-bfc9693d234e",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1933,
			"tags" : [
				"B14"
			],
			"type" : "slope",
			"position" : [
				26000.0,
				-600.0,
				15350.0
			],
			"legIndex" : 1,
			"brick" : "B14",
			"name" : "1933",
			"uuid" : "d4da5aff-1d23-5e46-8faf-e8bbb45eb19c",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1934,
			"tags" : [
				"B14"
			],
			"type" : "slope",
			"position" : [
				26000.0,
				-600.0,
				14150.0
			],
			"legIndex" : 2,
			"brick" : "B14",
			"name" : "1934",
			"uuid" : "8f70ff2f-0430-2148-8424-60fb34f9edac",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1935,
			"tags" : [
				"B14"
			],
			"type" : "slope",
			"position" : [
				26000.0,
				600.0,
				14150.0
			],
			"legIndex" : 3,
			"brick" : "B14",
			"name" : "1935",
			"uuid" : "18199bc8-6790-0e4a-a045-7c6e685dfeb3",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1936,
			"tags" : [
				"B14"
			],
			"type" : "slope",
			"position" : [
				26000.0,
				600.0,
				15350.0
			],
			"legIndex" : 4,
			"brick" : "B14",
			"name" : "1936",
			"uuid" : "9ad54874-6c08-3844-ba03-4c1068358d3f",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1937,
			"tags" : [
				"B14"
			],
			"type" : "slope",
			"position" : [
				27000.0,
				-600.0,
				15350.0
			],
			"legIndex" : 1,
			"brick" : "B14",
			"name" : "1937",
			"uuid" : "ff9c7618-d906-0a46-ba70-137e2a056b50",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1938,
			"tags" : [
				"B14"
			],
			"type" : "slope",
			"position" : [
				27000.0,
				-600.0,
				14150.0
			],
			"legIndex" : 2,
			"brick" : "B14",
			"name" : "1938",
			"uuid" : "c5c3d2ec-1fe0-6740-939e-8e913f233417",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1939,
			"tags" : [
				"B14"
			],
			"type" : "slope",
			"position" : [
				27000.0,
				600.0,
				14150.0
			],
			"legIndex" : 3,
			"brick" : "B14",
			"name" : "1939",
			"uuid" : "c845d51f-caaa-e94e-a096-5b3c210144ea",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1940,
			"tags" : [
				"B14"
			],
			"type" : "slope",
			"position" : [
				27000.0,
				600.0,
				15350.0
			],
			"legIndex" : 4,
			"brick" : "B14",
			"name" : "1940",
			"uuid" : "66f20f31-8a86-d14e-b983-18cb0b03d07b",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1941,
			"tags" : [
				"B14"
			],
			"type" : "slope",
			"position" : [
				28000.0,
				-600.0,
				15350.0
			],
			"legIndex" : 1,
			"brick" : "B14",
			"name" : "1941",
			"uuid" : "209b82f5-2c25-3a47-bf03-6ffc8cd00c1f",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1942,
			"tags" : [
				"B14"
			],
			"type" : "slope",
			"position" : [
				28000.0,
				-600.0,
				14150.0
			],
			"legIndex" : 2,
			"brick" : "B14",
			"name" : "1942",
			"uuid" : "82b90f36-d7d3-ab49-935e-d6c378f31a30",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1943,
			"tags" : [
				"B14"
			],
			"type" : "slope",
			"position" : [
				28000.0,
				600.0,
				14150.0
			],
			"legIndex" : 3,
			"brick" : "B14",
			"name" : "1943",
			"uuid" : "761766bb-5995-fa4c-b3b1-48733f196099",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1944,
			"tags" : [
				"B14"
			],
			"type" : "slope",
			"position" : [
				28000.0,
				600.0,
				15350.0
			],
			"legIndex" : 4,
			"brick" : "B14",
			"name" : "1944",
			"uuid" : "ed43b663-41d2-e141-8be9-8a7249e8d7c5",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1945,
			"tags" : [
				"B14"
			],
			"type" : "slope",
			"position" : [
				29000.0,
				-600.0,
				15350.0
			],
			"legIndex" : 1,
			"brick" : "B14",
			"name" : "1945",
			"uuid" : "225176e3-f489-d542-ba9d-e8918b303602",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1946,
			"tags" : [
				"B14"
			],
			"type" : "slope",
			"position" : [
				29000.0,
				-600.0,
				14150.0
			],
			"legIndex" : 2,
			"brick" : "B14",
			"name" : "1946",
			"uuid" : "4424727e-8156-344b-b5aa-e9454fcda4e5",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1947,
			"tags" : [
				"B14"
			],
			"type" : "slope",
			"position" : [
				29000.0,
				600.0,
				14150.0
			],
			"legIndex" : 3,
			"brick" : "B14",
			"name" : "1947",
			"uuid" : "329a2e28-cc97-324e-abe8-d35a85df7d58",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1948,
			"tags" : [
				"B14"
			],
			"type" : "slope",
			"position" : [
				29000.0,
				600.0,
				15350.0
			],
			"legIndex" : 4,
			"brick" : "B14",
			"name" : "1948",
			"uuid" : "bf01f258-158c-7b49-8466-69faf304f18c",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1949,
			"tags" : [
				"B14"
			],
			"type" : "slope",
			"position" : [
				30200.0,
				-600.0,
				15350.0
			],
			"legIndex" : 1,
			"brick" : "B14",
			"name" : "1949",
			"uuid" : "52608ef7-7017-074d-9ca5-830fd5c71bd0",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1950,
			"tags" : [
				"B14"
			],
			"type" : "slope",
			"position" : [
				30200.0,
				-600.0,
				14150.0
			],
			"legIndex" : 2,
			"brick" : "B14",
			"name" : "1950",
			"uuid" : "0472e7f9-fc61-ac40-b8e0-6dd041049d45",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1951,
			"tags" : [
				"B14"
			],
			"type" : "slope",
			"position" : [
				30200.0,
				600.0,
				14150.0
			],
			"legIndex" : 3,
			"brick" : "B14",
			"name" : "1951",
			"uuid" : "3d50911b-4522-4e4c-95de-5ee302f33b78",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1952,
			"tags" : [
				"B14"
			],
			"type" : "slope",
			"position" : [
				30200.0,
				600.0,
				15350.0
			],
			"legIndex" : 4,
			"brick" : "B14",
			"name" : "1952",
			"uuid" : "8bfa82b8-c2f6-224e-b0d1-c7f4267928f9",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1953,
			"tags" : [
				"B14"
			],
			"type" : "panel",
			"position" : [
				20000.0,
				-600.0,
				14750.0
			],
			"legIndex" : -1,
			"brick" : "B14",
			"name" : "1953",
			"uuid" : "0e02b8f0-9d90-5c40-b0a6-5357c6beb971",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1954,
			"tags" : [
				"B14"
			],
			"type" : "panel",
			"position" : [
				20000.0,
				0.0,
				14150.0
			],
			"legIndex" : -1,
			"brick" : "B14",
			"name" : "1954",
			"uuid" : "1b4642a5-d44c-4d49-83cf-9cf453d15a71",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1955,
			"tags" : [
				"B14"
			],
			"type" : "panel",
			"position" : [
				20000.0,
				600.0,
				14750.0
			],
			"legIndex" : -1,
			"brick" : "B14",
			"name" : "1955",
			"uuid" : "57821390-aa0e-c148-aa6d-afaf894ef0ba",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1956,
			"tags" : [
				"B14"
			],
			"type" : "panel",
			"position" : [
				20000.0,
				0.0,
				15350.0
			],
			"legIndex" : -1,
			"brick" : "B14",
			"name" : "1956",
			"uuid" : "c5eedecd-837f-314d-886d-933ebfd404a9",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1957,
			"tags" : [
				"B14"
			],
			"type" : "panel",
			"position" : [
				24000.0,
				-600.0,
				14750.0
			],
			"legIndex" : -1,
			"brick" : "B14",
			"name" : "1957",
			"uuid" : "acb434a4-44a9-fa4c-bf55-66b6e2ffcc3b",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1958,
			"tags" : [
				"B14"
			],
			"type" : "panel",
			"position" : [
				24000.0,
				0.0,
				14150.0
			],
			"legIndex" : -1,
			"brick" : "B14",
			"name" : "1958",
			"uuid" : "808a9454-bb83-854d-b573-5dfeb24e0352",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1959,
			"tags" : [
				"B14"
			],
			"type" : "panel",
			"position" : [
				24000.0,
				600.0,
				14750.0
			],
			"legIndex" : -1,
			"brick" : "B14",
			"name" : "1959",
			"uuid" : "571a9e66-7975-8048-a43a-4e2878600766",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1960,
			"tags" : [
				"B14"
			],
			"type" : "panel",
			"position" : [
				24000.0,
				0.0,
				15350.0
			],
			"legIndex" : -1,
			"brick" : "B14",
			"name" : "1960",
			"uuid" : "f35b79a6-ca12-6340-aa82-ffdcc0441053",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1961,
			"tags" : [
				"B14"
			],
			"type" : "panel",
			"position" : [
				28000.0,
				-600.0,
				14750.0
			],
			"legIndex" : -1,
			"brick" : "B14",
			"name" : "1961",
			"uuid" : "b0604fab-3b9e-9141-b172-1f488d74562c",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1962,
			"tags" : [
				"B14"
			],
			"type" : "panel",
			"position" : [
				28000.0,
				0.0,
				14150.0
			],
			"legIndex" : -1,
			"brick" : "B14",
			"name" : "1962",
			"uuid" : "4c6d82f5-58c0-1b41-8223-c7cb4a9cd086",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1963,
			"tags" : [
				"B14"
			],
			"type" : "panel",
			"position" : [
				28000.0,
				600.0,
				14750.0
			],
			"legIndex" : -1,
			"brick" : "B14",
			"name" : "1963",
			"uuid" : "5a3c4b85-32e5-2548-8f04-99639c7c2dc5",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 1964,
			"tags" : [
				"B14"
			],
			"type" : "panel",
			"position" : [
				28000.0,
				0.0,
				15350.0
			],
			"legIndex" : -1,
			"brick" : "B14",
			"name" : "1964",
			"uuid" : "3d6f5ffa-2416-8d4b-a6f7-cd7f50f23f55",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 2001,
			"tags" : [
				"B15"
			],
			"type" : "slope",
			"position" : [
				33800.0,
				-600.0,
				15350.0
			],
			"legIndex" : 1,
			"brick" : "B15",
			"name" : "2001",
			"uuid" : "292a8708-0471-8841-a280-dfe199c2a9b0",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 2002,
			"tags" : [
				"B15"
			],
			"type" : "slope",
			"position" : [
				33800.0,
				-600.0,
				14150.0
			],
			"legIndex" : 2,
			"brick" : "B15",
			"name" : "2002",
			"uuid" : "dcbb8046-871c-4e45-a07d-524747fc2355",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 2003,
			"tags" : [
				"B15"
			],
			"type" : "slope",
			"position" : [
				33800.0,
				600.0,
				14150.0
			],
			"legIndex" : 3,
			"brick" : "B15",
			"name" : "2003",
			"uuid" : "52524f85-888b-b04a-9feb-c698da535c60",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 2004,
			"tags" : [
				"B15"
			],
			"type" : "slope",
			"position" : [
				33800.0,
				600.0,
				15350.0
			],
			"legIndex" : 4,
			"brick" : "B15",
			"name" : "2004",
			"uuid" : "76ac6bb1-159a-c844-b251-d5019e550f2a",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 2005,
			"tags" : [
				"B15"
			],
			"type" : "slope",
			"position" : [
				35000.0,
				-600.0,
				15350.0
			],
			"legIndex" : 1,
			"brick" : "B15",
			"name" : "2005",
			"uuid" : "af874531-33f1-694b-8b7a-448f2289caba",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 2006,
			"tags" : [
				"B15"
			],
			"type" : "slope",
			"position" : [
				35000.0,
				-600.0,
				14150.0
			],
			"legIndex" : 2,
			"brick" : "B15",
			"name" : "2006",
			"uuid" : "0245a7c8-740d-3642-a33b-d7b1e23f17f8",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 2007,
			"tags" : [
				"B15"
			],
			"type" : "slope",
			"position" : [
				35000.0,
				600.0,
				14150.0
			],
			"legIndex" : 3,
			"brick" : "B15",
			"name" : "2007",
			"uuid" : "d7aea986-5a25-a448-ac61-57a05bf9f71b",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 2008,
			"tags" : [
				"B15"
			],
			"type" : "slope",
			"position" : [
				35000.0,
				600.0,
				15350.0
			],
			"legIndex" : 4,
			"brick" : "B15",
			"name" : "2008",
			"uuid" : "bf7e26cf-5707-2845-a242-a0003b3abe41",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 2009,
			"tags" : [
				"B15"
			],
			"type" : "slope",
			"position" : [
				36000.0,
				-600.0,
				15350.0
			],
			"legIndex" : 1,
			"brick" : "B15",
			"name" : "2009",
			"uuid" : "3fa4efdd-d598-8841-861d-4ac9745eda43",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 2010,
			"tags" : [
				"B15"
			],
			"type" : "slope",
			"position" : [
				36000.0,
				-600.0,
				14150.0
			],
			"legIndex" : 2,
			"brick" : "B15",
			"name" : "2010",
			"uuid" : "d2e5ea47-84ae-3744-87ff-17e057447e1e",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 2011,
			"tags" : [
				"B15"
			],
			"type" : "slope",
			"position" : [
				36000.0,
				600.0,
				14150.0
			],
			"legIndex" : 3,
			"brick" : "B15",
			"name" : "2011",
			"uuid" : "15e72822-7752-644a-897a-4bf664596372",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 2012,
			"tags" : [
				"B15"
			],
			"type" : "slope",
			"position" : [
				36000.0,
				600.0,
				15350.0
			],
			"legIndex" : 4,
			"brick" : "B15",
			"name" : "2012",
			"uuid" : "865c1fe2-d855-c64f-8099-60eea413409e",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 2013,
			"tags" : [
				"B15"
			],
			"type" : "slope",
			"position" : [
				37000.0,
				-600.0,
				15350.0
			],
			"legIndex" : 1,
			"brick" : "B15",
			"name" : "2013",
			"uuid" : "ec4c72e8-3ce2-554e-b9eb-39e63234f1ff",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 2014,
			"tags" : [
				"B15"
			],
			"type" : "slope",
			"position" : [
				37000.0,
				-600.0,
				14150.0
			],
			"legIndex" : 2,
			"brick" : "B15",
			"name" : "2014",
			"uuid" : "2d90aaf3-5e6b-3146-8ac9-ec2ff4652f1d",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 2015,
			"tags" : [
				"B15"
			],
			"type" : "slope",
			"position" : [
				37000.0,
				600.0,
				14150.0
			],
			"legIndex" : 3,
			"brick" : "B15",
			"name" : "2015",
			"uuid" : "94532723-7120-6b45-a642-8a29eb757cf2",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 2016,
			"tags" : [
				"B15"
			],
			"type" : "slope",
			"position" : [
				37000.0,
				600.0,
				15350.0
			],
			"legIndex" : 4,
			"brick" : "B15",
			"name" : "2016",
			"uuid" : "f37c72c6-ee8e-0c40-8dff-015e8757664c",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 2017,
			"tags" : [
				"B15"
			],
			"type" : "slope",
			"position" : [
				38000.0,
				-600.0,
				15350.0
			],
			"legIndex" : 1,
			"brick" : "B15",
			"name" : "2017",
			"uuid" : "b956cd36-527e-6849-b56b-54e8604da220",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 2018,
			"tags" : [
				"B15"
			],
			"type" : "slope",
			"position" : [
				38000.0,
				-600.0,
				14150.0
			],
			"legIndex" : 2,
			"brick" : "B15",
			"name" : "2018",
			"uuid" : "f1c8ada2-dc7d-0245-920a-1ffd6a6fd8ce",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 2019,
			"tags" : [
				"B15"
			],
			"type" : "slope",
			"position" : [
				38000.0,
				600.0,
				14150.0
			],
			"legIndex" : 3,
			"brick" : "B15",
			"name" : "2019",
			"uuid" : "bbdd9e27-b8da-224a-ad58-cb80d18bd95b",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 2020,
			"tags" : [
				"B15"
			],
			"type" : "slope",
			"position" : [
				38000.0,
				600.0,
				15350.0
			],
			"legIndex" : 4,
			"brick" : "B15",
			"name" : "2020",
			"uuid" : "3ebd2c81-52ff-a543-a2cd-3aec8370019d",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 2021,
			"tags" : [
				"B15"
			],
			"type" : "slope",
			"position" : [
				39000.0,
				-600.0,
				15350.0
			],
			"legIndex" : 1,
			"brick" : "B15",
			"name" : "2021",
			"uuid" : "3cde3ab2-407c-004e-823a-feff4ccf6530",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 2022,
			"tags" : [
				"B15"
			],
			"type" : "slope",
			"position" : [
				39000.0,
				-600.0,
				14150.0
			],
			"legIndex" : 2,
			"brick" : "B15",
			"name" : "2022",
			"uuid" : "45f48a9c-6015-3b47-85a2-f561dd00707d",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 2023,
			"tags" : [
				"B15"
			],
			"type" : "slope",
			"position" : [
				39000.0,
				600.0,
				14150.0
			],
			"legIndex" : 3,
			"brick" : "B15",
			"name" : "2023",
			"uuid" : "65032348-1b24-1a44-a5f1-73726631fd5a",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 2024,
			"tags" : [
				"B15"
			],
			"type" : "slope",
			"position" : [
				39000.0,
				600.0,
				15350.0
			],
			"legIndex" : 4,
			"brick" : "B15",
			"name" : "2024",
			"uuid" : "789d5c54-da6d-314a-8dd4-a2ef3db3bba3",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 2025,
			"tags" : [
				"B15"
			],
			"type" : "slope",
			"position" : [
				40000.0,
				-600.0,
				15350.0
			],
			"legIndex" : 1,
			"brick" : "B15",
			"name" : "2025",
			"uuid" : "01cf0f69-c6f1-1f47-a7b2-83adc2d3e23f",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 2026,
			"tags" : [
				"B15"
			],
			"type" : "slope",
			"position" : [
				40000.0,
				-600.0,
				14150.0
			],
			"legIndex" : 2,
			"brick" : "B15",
			"name" : "2026",
			"uuid" : "0667a911-c911-034d-a284-9534eb480e6d",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 2027,
			"tags" : [
				"B15"
			],
			"type" : "slope",
			"position" : [
				40000.0,
				600.0,
				14150.0
			],
			"legIndex" : 3,
			"brick" : "B15",
			"name" : "2027",
			"uuid" : "c8af2d35-fd8f-0349-a565-30a1f2ef5d0a",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 2028,
			"tags" : [
				"B15"
			],
			"type" : "slope",
			"position" : [
				40000.0,
				600.0,
				15350.0
			],
			"legIndex" : 4,
			"brick" : "B15",
			"name" : "2028",
			"uuid" : "dda08ea7-f22f-8748-887b-99ecf4ba3453",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 2029,
			"tags" : [
				"B15"
			],
			"type" : "slope",
			"position" : [
				41000.0,
				-600.0,
				15350.0
			],
			"legIndex" : 1,
			"brick" : "B15",
			"name" : "2029",
			"uuid" : "e7facd5e-ba1d-944a-9f5a-91a1084426b9",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 2030,
			"tags" : [
				"B15"
			],
			"type" : "slope",
			"position" : [
				41000.0,
				-600.0,
				14150.0
			],
			"legIndex" : 2,
			"brick" : "B15",
			"name" : "2030",
			"uuid" : "b121aa6d-a897-a64c-93b3-c740a48ec93c",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 2031,
			"tags" : [
				"B15"
			],
			"type" : "slope",
			"position" : [
				41000.0,
				600.0,
				14150.0
			],
			"legIndex" : 3,
			"brick" : "B15",
			"name" : "2031",
			"uuid" : "3a0d6228-78e8-484f-bf7c-c50cc1f0a71d",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 2032,
			"tags" : [
				"B15"
			],
			"type" : "slope",
			"position" : [
				41000.0,
				600.0,
				15350.0
			],
			"legIndex" : 4,
			"brick" : "B15",
			"name" : "2032",
			"uuid" : "bdcf6bb3-0abb-2745-83e3-0f1f0c36a37f",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 2033,
			"tags" : [
				"B15"
			],
			"type" : "slope",
			"position" : [
				42000.0,
				-600.0,
				15350.0
			],
			"legIndex" : 1,
			"brick" : "B15",
			"name" : "2033",
			"uuid" : "b624779e-96c2-8649-9f78-4493959ce263",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 2034,
			"tags" : [
				"B15"
			],
			"type" : "slope",
			"position" : [
				42000.0,
				-600.0,
				14150.0
			],
			"legIndex" : 2,
			"brick" : "B15",
			"name" : "2034",
			"uuid" : "4ab4a7ca-0f2e-1c42-8caf-855a11e41cad",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 2035,
			"tags" : [
				"B15"
			],
			"type" : "slope",
			"position" : [
				42000.0,
				600.0,
				14150.0
			],
			"legIndex" : 3,
			"brick" : "B15",
			"name" : "2035",
			"uuid" : "f9960513-32a3-484d-b754-74cb4d1ccb92",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 2036,
			"tags" : [
				"B15"
			],
			"type" : "slope",
			"position" : [
				42000.0,
				600.0,
				15350.0
			],
			"legIndex" : 4,
			"brick" : "B15",
			"name" : "2036",
			"uuid" : "a25623f9-e7a0-474e-a389-9eb45e39e6e8",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 2037,
			"tags" : [
				"B15"
			],
			"type" : "slope",
			"position" : [
				43000.0,
				-600.0,
				15350.0
			],
			"legIndex" : 1,
			"brick" : "B15",
			"name" : "2037",
			"uuid" : "5e35f257-57f7-bb46-9721-7e738d9c33c3",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 2038,
			"tags" : [
				"B15"
			],
			"type" : "slope",
			"position" : [
				43000.0,
				-600.0,
				14150.0
			],
			"legIndex" : 2,
			"brick" : "B15",
			"name" : "2038",
			"uuid" : "dd71a322-2366-c34e-a351-a60945d33a40",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 2039,
			"tags" : [
				"B15"
			],
			"type" : "slope",
			"position" : [
				43000.0,
				600.0,
				14150.0
			],
			"legIndex" : 3,
			"brick" : "B15",
			"name" : "2039",
			"uuid" : "9179c46c-0683-584e-981f-9fc3cbe93fbe",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 2040,
			"tags" : [
				"B15"
			],
			"type" : "slope",
			"position" : [
				43000.0,
				600.0,
				15350.0
			],
			"legIndex" : 4,
			"brick" : "B15",
			"name" : "2040",
			"uuid" : "9f9dc5cd-3b3f-c64a-8625-c2b99f1c928a",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 2041,
			"tags" : [
				"B15"
			],
			"type" : "slope",
			"position" : [
				44000.0,
				-600.0,
				15350.0
			],
			"legIndex" : 1,
			"brick" : "B15",
			"name" : "2041",
			"uuid" : "9626b402-b920-744e-bcfa-d142f65df7b0",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 2042,
			"tags" : [
				"B15"
			],
			"type" : "slope",
			"position" : [
				44000.0,
				-600.0,
				14150.0
			],
			"legIndex" : 2,
			"brick" : "B15",
			"name" : "2042",
			"uuid" : "fe2127d0-0818-f54e-a66f-0d5302e764b8",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 2043,
			"tags" : [
				"B15"
			],
			"type" : "slope",
			"position" : [
				44000.0,
				600.0,
				14150.0
			],
			"legIndex" : 3,
			"brick" : "B15",
			"name" : "2043",
			"uuid" : "517b1be9-20c8-ab42-bb56-7a2e348c3c9d",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 2044,
			"tags" : [
				"B15"
			],
			"type" : "slope",
			"position" : [
				44000.0,
				600.0,
				15350.0
			],
			"legIndex" : 4,
			"brick" : "B15",
			"name" : "2044",
			"uuid" : "eb542b08-1375-ae4f-8c26-a28d0372370d",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 2045,
			"tags" : [
				"B15"
			],
			"type" : "slope",
			"position" : [
				45000.0,
				-600.0,
				15350.0
			],
			"legIndex" : 1,
			"brick" : "B15",
			"name" : "2045",
			"uuid" : "1ec4ceee-beb5-a64a-953c-33d82df2a2a3",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 2046,
			"tags" : [
				"B15"
			],
			"type" : "slope",
			"position" : [
				45000.0,
				-600.0,
				14150.0
			],
			"legIndex" : 2,
			"brick" : "B15",
			"name" : "2046",
			"uuid" : "31c9f6aa-15b3-fd48-a413-8b134e87a1c5",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 2047,
			"tags" : [
				"B15"
			],
			"type" : "slope",
			"position" : [
				45000.0,
				600.0,
				14150.0
			],
			"legIndex" : 3,
			"brick" : "B15",
			"name" : "2047",
			"uuid" : "2a93b06b-8869-1e47-bd6e-7a018a99d77b",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 2048,
			"tags" : [
				"B15"
			],
			"type" : "slope",
			"position" : [
				45000.0,
				600.0,
				15350.0
			],
			"legIndex" : 4,
			"brick" : "B15",
			"name" : "2048",
			"uuid" : "2ff9d48a-cff3-2346-b941-cce787772f32",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 2049,
			"tags" : [
				"B15"
			],
			"type" : "slope",
			"position" : [
				46200.0,
				-600.0,
				15350.0
			],
			"legIndex" : 1,
			"brick" : "B15",
			"name" : "2049",
			"uuid" : "4e1aab20-1985-b544-bb79-dc70adfb084d",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 2050,
			"tags" : [
				"B15"
			],
			"type" : "slope",
			"position" : [
				46200.0,
				-600.0,
				14150.0
			],
			"legIndex" : 2,
			"brick" : "B15",
			"name" : "2050",
			"uuid" : "7eed48f3-a753-6344-a15f-e177c6511745",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 2051,
			"tags" : [
				"B15"
			],
			"type" : "slope",
			"position" : [
				46200.0,
				600.0,
				14150.0
			],
			"legIndex" : 3,
			"brick" : "B15",
			"name" : "2051",
			"uuid" : "07ba2b0c-2167-c24c-90e2-84018f83bfda",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 2052,
			"tags" : [
				"B15"
			],
			"type" : "slope",
			"position" : [
				46200.0,
				600.0,
				15350.0
			],
			"legIndex" : 4,
			"brick" : "B15",
			"name" : "2052",
			"uuid" : "8973f857-508b-ca4c-96b5-3ba37ccb4541",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 2053,
			"tags" : [
				"B15"
			],
			"type" : "panel",
			"position" : [
				35000.0,
				-600.0,
				14750.0
			],
			"legIndex" : -1,
			"brick" : "B15",
			"name" : "2053",
			"uuid" : "cc737564-cafe-0a45-b9fd-fe41ef140013",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 2054,
			"tags" : [
				"B15"
			],
			"type" : "panel",
			"position" : [
				35000.0,
				600.0,
				14750.0
			],
			"legIndex" : -1,
			"brick" : "B15",
			"name" : "2054",
			"uuid" : "ac46b058-a367-2843-9fde-6b6456e35304",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 2055,
			"tags" : [
				"B15"
			],
			"type" : "panel",
			"position" : [
				36000.0,
				0.0,
				14150.0
			],
			"legIndex" : -1,
			"brick" : "B15",
			"name" : "2055",
			"uuid" : "551581f9-6f59-bf45-9668-adee7456cf77",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 2056,
			"tags" : [
				"B15"
			],
			"type" : "panel",
			"position" : [
				36000.0,
				0.0,
				15350.0
			],
			"legIndex" : -1,
			"brick" : "B15",
			"name" : "2056",
			"uuid" : "56e8ba51-2f67-8e4c-a897-b21d7e703170",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 2057,
			"tags" : [
				"B15"
			],
			"type" : "panel",
			"position" : [
				40000.0,
				-600.0,
				14750.0
			],
			"legIndex" : -1,
			"brick" : "B15",
			"name" : "2057",
			"uuid" : "570ac080-2b55-5b49-8b60-eec464c79bb8",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 2058,
			"tags" : [
				"B15"
			],
			"type" : "panel",
			"position" : [
				40000.0,
				0.0,
				14150.0
			],
			"legIndex" : -1,
			"brick" : "B15",
			"name" : "2058",
			"uuid" : "d9b0f9a7-ba5b-8743-873f-1d833e9a5834",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 2059,
			"tags" : [
				"B15"
			],
			"type" : "panel",
			"position" : [
				40000.0,
				600.0,
				14750.0
			],
			"legIndex" : -1,
			"brick" : "B15",
			"name" : "2059",
			"uuid" : "de9fd355-e300-ee4a-820d-0be07178b996",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 2060,
			"tags" : [
				"B15"
			],
			"type" : "panel",
			"position" : [
				40000.0,
				0.0,
				15350.0
			],
			"legIndex" : -1,
			"brick" : "B15",
			"name" : "2060",
			"uuid" : "7f9c4a83-5ea8-e245-bfb8-4f4daa2c6f94",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 2061,
			"tags" : [
				"B15"
			],
			"type" : "panel",
			"position" : [
				44000.0,
				0.0,
				14150.0
			],
			"legIndex" : -1,
			"brick" : "B15",
			"name" : "2061",
			"uuid" : "e3bd64d8-8053-7a4b-a192-d9a0958c1253",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 2062,
			"tags" : [
				"B15"
			],
			"type" : "panel",
			"position" : [
				44000.0,
				0.0,
				15350.0
			],
			"legIndex" : -1,
			"brick" : "B15",
			"name" : "2062",
			"uuid" : "67af560e-3b70-fb45-89a9-6228c99dedde",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 2063,
			"tags" : [
				"B15"
			],
			"type" : "panel",
			"position" : [
				45000.0,
				-600.0,
				14750.0
			],
			"legIndex" : -1,
			"brick" : "B15",
			"name" : "2063",
			"uuid" : "ef329974-207a-6e45-bb86-598ced4db525",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 2064,
			"tags" : [
				"B15"
			],
			"type" : "panel",
			"position" : [
				45000.0,
				600.0,
				14750.0
			],
			"legIndex" : -1,
			"brick" : "B15",
			"name" : "2064",
			"uuid" : "3b97d7c3-4325-3946-ab76-a26d833067bc",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 2101,
			"tags" : [
				"B16"
			],
			"type" : "slope",
			"position" : [
				49800.0,
				-600.0,
				15350.0
			],
			"legIndex" : 1,
			"brick" : "B16",
			"name" : "2101",
			"uuid" : "db2d5a46-aa7c-074a-9870-32ef75ed1cea",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 2102,
			"tags" : [
				"B16"
			],
			"type" : "slope",
			"position" : [
				49800.0,
				-600.0,
				14150.0
			],
			"legIndex" : 2,
			"brick" : "B16",
			"name" : "2102",
			"uuid" : "23c2fdc6-869d-244a-9368-3e853141f244",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 2103,
			"tags" : [
				"B16"
			],
			"type" : "slope",
			"position" : [
				49800.0,
				600.0,
				14150.0
			],
			"legIndex" : 3,
			"brick" : "B16",
			"name" : "2103",
			"uuid" : "b9bc7f1e-f209-8041-a67d-abc2a37adbde",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 2104,
			"tags" : [
				"B16"
			],
			"type" : "slope",
			"position" : [
				49800.0,
				600.0,
				15350.0
			],
			"legIndex" : 4,
			"brick" : "B16",
			"name" : "2104",
			"uuid" : "412f7d36-85a4-7243-9ef6-08b032fd7838",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 2105,
			"tags" : [
				"B16"
			],
			"type" : "slope",
			"position" : [
				51000.0,
				-600.0,
				15350.0
			],
			"legIndex" : 1,
			"brick" : "B16",
			"name" : "2105",
			"uuid" : "0eeb24be-dd7d-5748-9670-27c78151e666",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 2106,
			"tags" : [
				"B16"
			],
			"type" : "slope",
			"position" : [
				51000.0,
				-600.0,
				14150.0
			],
			"legIndex" : 2,
			"brick" : "B16",
			"name" : "2106",
			"uuid" : "2d237a05-17e0-884d-a11e-2bedf39889f8",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 2107,
			"tags" : [
				"B16"
			],
			"type" : "slope",
			"position" : [
				51000.0,
				600.0,
				14150.0
			],
			"legIndex" : 3,
			"brick" : "B16",
			"name" : "2107",
			"uuid" : "cab0b2ac-067f-604c-9d95-2ad99ec77ac7",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 2108,
			"tags" : [
				"B16"
			],
			"type" : "slope",
			"position" : [
				51000.0,
				600.0,
				15350.0
			],
			"legIndex" : 4,
			"brick" : "B16",
			"name" : "2108",
			"uuid" : "55fe2e28-566d-f740-82c1-6a42639d545e",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 2109,
			"tags" : [
				"B16"
			],
			"type" : "slope",
			"position" : [
				52000.0,
				-600.0,
				15350.0
			],
			"legIndex" : 1,
			"brick" : "B16",
			"name" : "2109",
			"uuid" : "afb4e64d-2caa-1d40-8c88-0c7700be5bde",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 2110,
			"tags" : [
				"B16"
			],
			"type" : "slope",
			"position" : [
				52000.0,
				-600.0,
				14150.0
			],
			"legIndex" : 2,
			"brick" : "B16",
			"name" : "2110",
			"uuid" : "75937ac0-f8c2-be4d-b421-8f3adb2d43bc",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 2111,
			"tags" : [
				"B16"
			],
			"type" : "slope",
			"position" : [
				52000.0,
				600.0,
				14150.0
			],
			"legIndex" : 3,
			"brick" : "B16",
			"name" : "2111",
			"uuid" : "505d595b-cb93-3c4d-ac6d-62cf1b336e91",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 2112,
			"tags" : [
				"B16"
			],
			"type" : "slope",
			"position" : [
				52000.0,
				600.0,
				15350.0
			],
			"legIndex" : 4,
			"brick" : "B16",
			"name" : "2112",
			"uuid" : "9a9391ef-a510-c24b-b221-d3331ad30ea6",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 2113,
			"tags" : [
				"B16"
			],
			"type" : "slope",
			"position" : [
				53000.0,
				-600.0,
				15350.0
			],
			"legIndex" : 1,
			"brick" : "B16",
			"name" : "2113",
			"uuid" : "4007763d-84b1-4840-96b6-8cde76dfd96a",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 2114,
			"tags" : [
				"B16"
			],
			"type" : "slope",
			"position" : [
				53000.0,
				-600.0,
				14150.0
			],
			"legIndex" : 2,
			"brick" : "B16",
			"name" : "2114",
			"uuid" : "fdc59da6-28c0-8d43-a129-b2f7e06fb60f",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 2115,
			"tags" : [
				"B16"
			],
			"type" : "slope",
			"position" : [
				53000.0,
				600.0,
				14150.0
			],
			"legIndex" : 3,
			"brick" : "B16",
			"name" : "2115",
			"uuid" : "3a0032fb-bc1f-7544-b5d2-7fd96c9b490c",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 2116,
			"tags" : [
				"B16"
			],
			"type" : "slope",
			"position" : [
				53000.0,
				600.0,
				15350.0
			],
			"legIndex" : 4,
			"brick" : "B16",
			"name" : "2116",
			"uuid" : "37074caf-9228-aa40-859d-9426673dd0a5",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 2117,
			"tags" : [
				"B16"
			],
			"type" : "slope",
			"position" : [
				54000.0,
				-600.0,
				15350.0
			],
			"legIndex" : 1,
			"brick" : "B16",
			"name" : "2117",
			"uuid" : "cc93e0a9-8b02-8f45-abe0-ee265e57ae66",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 2118,
			"tags" : [
				"B16"
			],
			"type" : "slope",
			"position" : [
				54000.0,
				-600.0,
				14150.0
			],
			"legIndex" : 2,
			"brick" : "B16",
			"name" : "2118",
			"uuid" : "567842de-16d3-6e4f-9625-0ec147159837",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 2119,
			"tags" : [
				"B16"
			],
			"type" : "slope",
			"position" : [
				54000.0,
				600.0,
				14150.0
			],
			"legIndex" : 3,
			"brick" : "B16",
			"name" : "2119",
			"uuid" : "93662a89-6702-8f48-8168-eb586ab833d8",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 2120,
			"tags" : [
				"B16"
			],
			"type" : "slope",
			"position" : [
				54000.0,
				600.0,
				15350.0
			],
			"legIndex" : 4,
			"brick" : "B16",
			"name" : "2120",
			"uuid" : "90dbbf2e-bd0b-5646-a751-5647955ad507",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 2121,
			"tags" : [
				"B16"
			],
			"type" : "slope",
			"position" : [
				55000.0,
				-600.0,
				15350.0
			],
			"legIndex" : 1,
			"brick" : "B16",
			"name" : "2121",
			"uuid" : "8679593e-deae-9e41-8dcb-d11f4d104aa5",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 2122,
			"tags" : [
				"B16"
			],
			"type" : "slope",
			"position" : [
				55000.0,
				-600.0,
				14150.0
			],
			"legIndex" : 2,
			"brick" : "B16",
			"name" : "2122",
			"uuid" : "8bf6c471-50cd-0140-846f-e5f8c72b56e3",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 2123,
			"tags" : [
				"B16"
			],
			"type" : "slope",
			"position" : [
				55000.0,
				600.0,
				14150.0
			],
			"legIndex" : 3,
			"brick" : "B16",
			"name" : "2123",
			"uuid" : "124182df-4276-774e-b582-090d84e41314",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 2124,
			"tags" : [
				"B16"
			],
			"type" : "slope",
			"position" : [
				55000.0,
				600.0,
				15350.0
			],
			"legIndex" : 4,
			"brick" : "B16",
			"name" : "2124",
			"uuid" : "b945641b-07aa-684a-9928-cd9c863fb936",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 2125,
			"tags" : [
				"B16"
			],
			"type" : "slope",
			"position" : [
				56000.0,
				-600.0,
				15350.0
			],
			"legIndex" : 1,
			"brick" : "B16",
			"name" : "2125",
			"uuid" : "cd0c70bb-979a-2b41-8d94-36f8d3d673ea",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 2126,
			"tags" : [
				"B16"
			],
			"type" : "slope",
			"position" : [
				56000.0,
				-600.0,
				14150.0
			],
			"legIndex" : 2,
			"brick" : "B16",
			"name" : "2126",
			"uuid" : "aea57391-86cd-5848-a42e-f7c432050df4",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 2127,
			"tags" : [
				"B16"
			],
			"type" : "slope",
			"position" : [
				56000.0,
				600.0,
				14150.0
			],
			"legIndex" : 3,
			"brick" : "B16",
			"name" : "2127",
			"uuid" : "b465fccf-1880-6141-bd93-77d8cd354e59",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 2128,
			"tags" : [
				"B16"
			],
			"type" : "slope",
			"position" : [
				56000.0,
				600.0,
				15350.0
			],
			"legIndex" : 4,
			"brick" : "B16",
			"name" : "2128",
			"uuid" : "53f98bc8-4d9f-844a-b9a7-7856769d09fd",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 2129,
			"tags" : [
				"B16"
			],
			"type" : "slope",
			"position" : [
				57000.0,
				-600.0,
				15350.0
			],
			"legIndex" : 1,
			"brick" : "B16",
			"name" : "2129",
			"uuid" : "c6f1d719-fa30-0543-8992-a64fe78c69e2",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 2130,
			"tags" : [
				"B16"
			],
			"type" : "slope",
			"position" : [
				57000.0,
				-600.0,
				14150.0
			],
			"legIndex" : 2,
			"brick" : "B16",
			"name" : "2130",
			"uuid" : "02fe640f-8fc4-a74b-b943-c261c05182f1",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 2131,
			"tags" : [
				"B16"
			],
			"type" : "slope",
			"position" : [
				57000.0,
				600.0,
				14150.0
			],
			"legIndex" : 3,
			"brick" : "B16",
			"name" : "2131",
			"uuid" : "65d49720-8df9-8a40-886b-5fd9b266b1b1",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 2132,
			"tags" : [
				"B16"
			],
			"type" : "slope",
			"position" : [
				57000.0,
				600.0,
				15350.0
			],
			"legIndex" : 4,
			"brick" : "B16",
			"name" : "2132",
			"uuid" : "a09e95e5-6459-9e43-bd69-a6844805c766",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 2133,
			"tags" : [
				"B16"
			],
			"type" : "slope",
			"position" : [
				58000.0,
				-600.0,
				15350.0
			],
			"legIndex" : 1,
			"brick" : "B16",
			"name" : "2133",
			"uuid" : "3b33fe81-7e0c-ef45-bcc6-dc90b76bffb1",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 2134,
			"tags" : [
				"B16"
			],
			"type" : "slope",
			"position" : [
				58000.0,
				-600.0,
				14150.0
			],
			"legIndex" : 2,
			"brick" : "B16",
			"name" : "2134",
			"uuid" : "1decf1a9-1983-1443-95dd-b22e171800ba",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 2135,
			"tags" : [
				"B16"
			],
			"type" : "slope",
			"position" : [
				58000.0,
				600.0,
				14150.0
			],
			"legIndex" : 3,
			"brick" : "B16",
			"name" : "2135",
			"uuid" : "6971e81d-4ba7-794e-b6ac-859b5b7deef5",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 2136,
			"tags" : [
				"B16"
			],
			"type" : "slope",
			"position" : [
				58000.0,
				600.0,
				15350.0
			],
			"legIndex" : 4,
			"brick" : "B16",
			"name" : "2136",
			"uuid" : "a288f6ed-cc52-0141-9e58-9d35a108c031",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 2137,
			"tags" : [
				"B16"
			],
			"type" : "slope",
			"position" : [
				59000.0,
				-600.0,
				15350.0
			],
			"legIndex" : 1,
			"brick" : "B16",
			"name" : "2137",
			"uuid" : "fdfe8d88-416c-e143-9005-58ce6b2904f6",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 2138,
			"tags" : [
				"B16"
			],
			"type" : "slope",
			"position" : [
				59000.0,
				-600.0,
				14150.0
			],
			"legIndex" : 2,
			"brick" : "B16",
			"name" : "2138",
			"uuid" : "b2b1333b-e18d-1f4e-b876-fd92839be0a1",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 2139,
			"tags" : [
				"B16"
			],
			"type" : "slope",
			"position" : [
				59000.0,
				600.0,
				14150.0
			],
			"legIndex" : 3,
			"brick" : "B16",
			"name" : "2139",
			"uuid" : "a28fa2d7-6aaa-e643-ab80-06c283a19281",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 2140,
			"tags" : [
				"B16"
			],
			"type" : "slope",
			"position" : [
				59000.0,
				600.0,
				15350.0
			],
			"legIndex" : 4,
			"brick" : "B16",
			"name" : "2140",
			"uuid" : "283928fd-9661-ca4e-8b40-eedd0dd9060c",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 2141,
			"tags" : [
				"B16"
			],
			"type" : "slope",
			"position" : [
				60000.0,
				-600.0,
				15350.0
			],
			"legIndex" : 1,
			"brick" : "B16",
			"name" : "2141",
			"uuid" : "24828e43-c3da-0946-8349-e4b27fbef4e4",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 2142,
			"tags" : [
				"B16"
			],
			"type" : "slope",
			"position" : [
				60000.0,
				-600.0,
				14150.0
			],
			"legIndex" : 2,
			"brick" : "B16",
			"name" : "2142",
			"uuid" : "2d25d35f-fb7c-1d4c-a6d1-371c28bff8f7",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 2143,
			"tags" : [
				"B16"
			],
			"type" : "slope",
			"position" : [
				60000.0,
				600.0,
				14150.0
			],
			"legIndex" : 3,
			"brick" : "B16",
			"name" : "2143",
			"uuid" : "e27653f3-c320-764c-8a25-0276da3b152a",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 2144,
			"tags" : [
				"B16"
			],
			"type" : "slope",
			"position" : [
				60000.0,
				600.0,
				15350.0
			],
			"legIndex" : 4,
			"brick" : "B16",
			"name" : "2144",
			"uuid" : "85b7003b-6b43-2045-ac7d-f9514268bbd4",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 2145,
			"tags" : [
				"B16"
			],
			"type" : "slope",
			"position" : [
				61000.0,
				-600.0,
				15350.0
			],
			"legIndex" : 1,
			"brick" : "B16",
			"name" : "2145",
			"uuid" : "dc30cbd2-0f12-2b45-bd8b-c5e7cdc827ce",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 2146,
			"tags" : [
				"B16"
			],
			"type" : "slope",
			"position" : [
				61000.0,
				-600.0,
				14150.0
			],
			"legIndex" : 2,
			"brick" : "B16",
			"name" : "2146",
			"uuid" : "97b9af67-7d8e-344d-998f-8d93765e3dd0",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 2147,
			"tags" : [
				"B16"
			],
			"type" : "slope",
			"position" : [
				61000.0,
				600.0,
				14150.0
			],
			"legIndex" : 3,
			"brick" : "B16",
			"name" : "2147",
			"uuid" : "cee0722f-7660-ad4b-882d-3f2c45b514d8",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 2148,
			"tags" : [
				"B16"
			],
			"type" : "slope",
			"position" : [
				61000.0,
				600.0,
				15350.0
			],
			"legIndex" : 4,
			"brick" : "B16",
			"name" : "2148",
			"uuid" : "f2217caf-1239-d144-a785-6ebe46dd8cd8",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 2149,
			"tags" : [
				"B16"
			],
			"type" : "slope",
			"position" : [
				62200.0,
				-600.0,
				15350.0
			],
			"legIndex" : 1,
			"brick" : "B16",
			"name" : "2149",
			"uuid" : "919e160c-ff7b-f34e-a60e-f929b97654de",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 2150,
			"tags" : [
				"B16"
			],
			"type" : "slope",
			"position" : [
				62200.0,
				-600.0,
				14150.0
			],
			"legIndex" : 2,
			"brick" : "B16",
			"name" : "2150",
			"uuid" : "f3aea194-b17a-684e-abf6-ab237b583623",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 2151,
			"tags" : [
				"B16"
			],
			"type" : "slope",
			"position" : [
				62200.0,
				600.0,
				14150.0
			],
			"legIndex" : 3,
			"brick" : "B16",
			"name" : "2151",
			"uuid" : "c0e0d1c0-b616-2d47-804a-acbdaeb8ec83",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 2152,
			"tags" : [
				"B16"
			],
			"type" : "slope",
			"position" : [
				62200.0,
				600.0,
				15350.0
			],
			"legIndex" : 4,
			"brick" : "B16",
			"name" : "2152",
			"uuid" : "35121011-3967-c347-8734-d77dd6d392eb",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 2153,
			"tags" : [
				"B16"
			],
			"type" : "panel",
			"position" : [
				51000.0,
				-600.0,
				14750.0
			],
			"legIndex" : -1,
			"brick" : "B16",
			"name" : "2153",
			"uuid" : "3dda4f79-1314-8e45-87c4-ca74cd3ca23d",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 2154,
			"tags" : [
				"B16"
			],
			"type" : "panel",
			"position" : [
				51000.0,
				600.0,
				14750.0
			],
			"legIndex" : -1,
			"brick" : "B16",
			"name" : "2154",
			"uuid" : "60f7d4ea-d587-b648-acac-8e833c4fc1c9",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 2155,
			"tags" : [
				"B16"
			],
			"type" : "panel",
			"position" : [
				52000.0,
				0.0,
				14150.0
			],
			"legIndex" : -1,
			"brick" : "B16",
			"name" : "2155",
			"uuid" : "7e1b8c43-c7da-4f44-8cca-9522348aaa73",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 2156,
			"tags" : [
				"B16"
			],
			"type" : "panel",
			"position" : [
				52000.0,
				0.0,
				15350.0
			],
			"legIndex" : -1,
			"brick" : "B16",
			"name" : "2156",
			"uuid" : "dd667fe9-1faa-3343-b06a-88afa04716c2",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 2157,
			"tags" : [
				"B16"
			],
			"type" : "panel",
			"position" : [
				56000.0,
				-600.0,
				14750.0
			],
			"legIndex" : -1,
			"brick" : "B16",
			"name" : "2157",
			"uuid" : "ff90a78d-97ec-f840-b2dd-9f8652c958c3",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 2158,
			"tags" : [
				"B16"
			],
			"type" : "panel",
			"position" : [
				56000.0,
				0.0,
				14150.0
			],
			"legIndex" : -1,
			"brick" : "B16",
			"name" : "2158",
			"uuid" : "e0d6b690-7cc5-0b44-ac02-dd8971c72dbc",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 2159,
			"tags" : [
				"B16"
			],
			"type" : "panel",
			"position" : [
				56000.0,
				600.0,
				14750.0
			],
			"legIndex" : -1,
			"brick" : "B16",
			"name" : "2159",
			"uuid" : "3c2624ee-0df4-8640-9f67-7e2bf32e0560",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 2160,
			"tags" : [
				"B16"
			],
			"type" : "panel",
			"position" : [
				56000.0,
				0.0,
				15350.0
			],
			"legIndex" : -1,
			"brick" : "B16",
			"name" : "2160",
			"uuid" : "1dc99bfd-ad9e-1c4b-a606-7b4e2d319bfd",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 2161,
			"tags" : [
				"B16"
			],
			"type" : "panel",
			"position" : [
				60000.0,
				0.0,
				14150.0
			],
			"legIndex" : -1,
			"brick" : "B16",
			"name" : "2161",
			"uuid" : "625a6317-caee-cb46-8896-e3184176e40b",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 2162,
			"tags" : [
				"B16"
			],
			"type" : "panel",
			"position" : [
				60000.0,
				0.0,
				15350.0
			],
			"legIndex" : -1,
			"brick" : "B16",
			"name" : "2162",
			"uuid" : "8f6dc538-9f9e-3a40-abf2-60451ee10599",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 2163,
			"tags" : [
				"B16"
			],
			"type" : "panel",
			"position" : [
				61000.0,
				-600.0,
				14750.0
			],
			"legIndex" : -1,
			"brick" : "B16",
			"name" : "2163",
			"uuid" : "01956286-0d1a-4e48-8913-8da9b5ff2fd5",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 2164,
			"tags" : [
				"B16"
			],
			"type" : "panel",
			"position" : [
				61000.0,
				600.0,
				14750.0
			],
			"legIndex" : -1,
			"brick" : "B16",
			"name" : "2164",
			"uuid" : "0d50773f-5bbd-194b-977c-6e2a252584ad",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 2201,
			"tags" : [
				"P13"
			],
			"type" : "section",
			"position" : [
				0.0,
				0.0,
				15350.0
			],
			"legIndex" : -1,
			"brick" : "P13",
			"name" : "2201",
			"uuid" : "34b6e128-758b-7d48-bff1-89236269ed7e",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 2202,
			"tags" : [
				"P13"
			],
			"type" : "section",
			"position" : [
				0.0,
				0.0,
				14150.0
			],
			"legIndex" : -1,
			"brick" : "P13",
			"name" : "2202",
			"uuid" : "3595123b-cac2-a84b-8d56-81338312986b",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 2301,
			"tags" : [
				"P14"
			],
			"type" : "section",
			"position" : [
				16000.0,
				0.0,
				15350.0
			],
			"legIndex" : -1,
			"brick" : "P14",
			"name" : "2301",
			"uuid" : "f803c0d6-8841-1b4a-aa2b-21c7d3f5ce33",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 2302,
			"tags" : [
				"P14"
			],
			"type" : "section",
			"position" : [
				16000.0,
				0.0,
				14150.0
			],
			"legIndex" : -1,
			"brick" : "P14",
			"name" : "2302",
			"uuid" : "c45512f0-d300-b84e-9f41-1ba407cb78f5",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 2401,
			"tags" : [
				"P15"
			],
			"type" : "section",
			"position" : [
				32000.0,
				0.0,
				15350.0
			],
			"legIndex" : -1,
			"brick" : "P15",
			"name" : "2401",
			"uuid" : "4a3d13f2-6a34-314b-92ac-015a08bb7287",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 2402,
			"tags" : [
				"P15"
			],
			"type" : "section",
			"position" : [
				32000.0,
				0.0,
				14150.0
			],
			"legIndex" : -1,
			"brick" : "P15",
			"name" : "2402",
			"uuid" : "add0890c-be69-a04c-b5ac-1b4d6cb22d8d",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 2501,
			"tags" : [
				"P16"
			],
			"type" : "section",
			"position" : [
				48000.0,
				0.0,
				15350.0
			],
			"legIndex" : -1,
			"brick" : "P16",
			"name" : "2501",
			"uuid" : "12df42fb-98a8-4342-91c8-888a869cd7e9",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 2502,
			"tags" : [
				"P16"
			],
			"type" : "section",
			"position" : [
				48000.0,
				0.0,
				14150.0
			],
			"legIndex" : -1,
			"brick" : "P16",
			"name" : "2502",
			"uuid" : "38da5e4d-ac6a-2b43-9721-4259046cfe1b",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 2601,
			"tags" : [
				"P17"
			],
			"type" : "section",
			"position" : [
				64000.0,
				0.0,
				15350.0
			],
			"legIndex" : -1,
			"brick" : "P17",
			"name" : "2601",
			"uuid" : "4da8f25a-4dd2-4740-b51b-04721b3d5e42",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 2602,
			"tags" : [
				"P17"
			],
			"type" : "section",
			"position" : [
				64000.0,
				0.0,
				14150.0
			],
			"legIndex" : -1,
			"brick" : "P17",
			"name" : "2602",
			"uuid" : "f84c81ed-191f-0e44-8b6c-89985f3ea9be",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 2701,
			"tags" : [
				"B13"
			],
			"type" : "section",
			"position" : [
				3000.0,
				0.0,
				14750.0
			],
			"legIndex" : -1,
			"brick" : "B13",
			"name" : "2701",
			"uuid" : "e5a5b5f4-fd8e-c245-b771-d7de00ebdb54",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 2702,
			"tags" : [
				"B13"
			],
			"type" : "section",
			"position" : [
				4000.0,
				0.0,
				14750.0
			],
			"legIndex" : -1,
			"brick" : "B13",
			"name" : "2702",
			"uuid" : "e6e2fe15-3f2d-4041-8566-9a63c6425393",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 2703,
			"tags" : [
				"B13"
			],
			"type" : "section",
			"position" : [
				8000.0,
				0.0,
				14750.0
			],
			"legIndex" : -1,
			"brick" : "B13",
			"name" : "2703",
			"uuid" : "ca973f53-42a8-8a44-9308-258177515113",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 2704,
			"tags" : [
				"B13"
			],
			"type" : "section",
			"position" : [
				12000.0,
				0.0,
				14750.0
			],
			"legIndex" : -1,
			"brick" : "B13",
			"name" : "2704",
			"uuid" : "1c7c1cd4-8ed6-1b4a-ae69-dbe26fe00a2f",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 2705,
			"tags" : [
				"B13"
			],
			"type" : "section",
			"position" : [
				13000.0,
				0.0,
				14750.0
			],
			"legIndex" : -1,
			"brick" : "B13",
			"name" : "2705",
			"uuid" : "6839df7d-9bb3-e142-b78b-43551ba147c9",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 2801,
			"tags" : [
				"B14"
			],
			"type" : "section",
			"position" : [
				19000.0,
				0.0,
				14750.0
			],
			"legIndex" : -1,
			"brick" : "B14",
			"name" : "2801",
			"uuid" : "490713ac-04a4-c848-8556-cd345c89e23b",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 2802,
			"tags" : [
				"B14"
			],
			"type" : "section",
			"position" : [
				20000.0,
				0.0,
				14750.0
			],
			"legIndex" : -1,
			"brick" : "B14",
			"name" : "2802",
			"uuid" : "4f5b5dbc-9681-7d40-a933-7a1f949d85ea",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 2803,
			"tags" : [
				"B14"
			],
			"type" : "section",
			"position" : [
				24000.0,
				0.0,
				14750.0
			],
			"legIndex" : -1,
			"brick" : "B14",
			"name" : "2803",
			"uuid" : "7245f91b-6f77-1845-aa0c-0ff7e1e98319",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 2804,
			"tags" : [
				"B14"
			],
			"type" : "section",
			"position" : [
				28000.0,
				0.0,
				14750.0
			],
			"legIndex" : -1,
			"brick" : "B14",
			"name" : "2804",
			"uuid" : "e9de6a1f-1f00-f14a-a109-20102644b5b7",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 2805,
			"tags" : [
				"B14"
			],
			"type" : "section",
			"position" : [
				29000.0,
				0.0,
				14750.0
			],
			"legIndex" : -1,
			"brick" : "B14",
			"name" : "2805",
			"uuid" : "1411a9ad-2d11-fa40-bb86-2579eaf74f07",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 2901,
			"tags" : [
				"B15"
			],
			"type" : "section",
			"position" : [
				35000.0,
				0.0,
				14750.0
			],
			"legIndex" : -1,
			"brick" : "B15",
			"name" : "2901",
			"uuid" : "58dc6a8a-5654-324c-a14a-9cda1b85e3e8",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 2902,
			"tags" : [
				"B15"
			],
			"type" : "section",
			"position" : [
				36000.0,
				0.0,
				14750.0
			],
			"legIndex" : -1,
			"brick" : "B15",
			"name" : "2902",
			"uuid" : "7aaed41e-a498-c84b-9244-1c4c71549f7e",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 2903,
			"tags" : [
				"B15"
			],
			"type" : "section",
			"position" : [
				40000.0,
				0.0,
				14750.0
			],
			"legIndex" : -1,
			"brick" : "B15",
			"name" : "2903",
			"uuid" : "bf94ab4c-2247-134e-95b4-7e3e5e6fdecf",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 2904,
			"tags" : [
				"B15"
			],
			"type" : "section",
			"position" : [
				44000.0,
				0.0,
				14750.0
			],
			"legIndex" : -1,
			"brick" : "B15",
			"name" : "2904",
			"uuid" : "58389976-70de-a34d-b1bb-09d9bda8feb0",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 2905,
			"tags" : [
				"B15"
			],
			"type" : "section",
			"position" : [
				45000.0,
				0.0,
				14750.0
			],
			"legIndex" : -1,
			"brick" : "B15",
			"name" : "2905",
			"uuid" : "ff9b4e61-033d-5648-a059-4a78bf7511fb",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 3001,
			"tags" : [
				"B16"
			],
			"type" : "section",
			"position" : [
				51000.0,
				0.0,
				14750.0
			],
			"legIndex" : -1,
			"brick" : "B16",
			"name" : "3001",
			"uuid" : "c6019fea-ca37-1242-9f3a-036f003513b8",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 3002,
			"tags" : [
				"B16"
			],
			"type" : "section",
			"position" : [
				52000.0,
				0.0,
				14750.0
			],
			"legIndex" : -1,
			"brick" : "B16",
			"name" : "3002",
			"uuid" : "554ba101-7c4c-7443-be39-8323eb1b5d14",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 3003,
			"tags" : [
				"B16"
			],
			"type" : "section",
			"position" : [
				56000.0,
				0.0,
				14750.0
			],
			"legIndex" : -1,
			"brick" : "B16",
			"name" : "3003",
			"uuid" : "615df0e8-b4f6-384a-8bff-574cc9f20521",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 3004,
			"tags" : [
				"B16"
			],
			"type" : "section",
			"position" : [
				60000.0,
				0.0,
				14750.0
			],
			"legIndex" : -1,
			"brick" : "B16",
			"name" : "3004",
			"uuid" : "d2c7028c-11a6-8049-8d62-c641590a707f",
			"_clazz" : "TwkStanNode"
		},
		{
			"number" : 3005,
			"tags" : [
				"B16"
			],
			"type" : "section",
			"position" : [
				61000.0,
				0.0,
				14750.0
			],
			"legIndex" : -1,
			"brick" : "B16",
			"name" : "3005",
			"uuid" : "a72a9cbd-d562-394c-af91-39007218a342",
			"_clazz" : "TwkStanNode"
		}
	],
	"segments" : [
		{
			"number" : 10001,
			"tags" : [
				"P13"
			],
			"type" : "slope",
			"to" : 1001,
			"from" : 1000,
			"brick" : "P13",
			"name" : "10001",
			"uuid" : "546de041-c20d-674a-832c-432507830e28",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 10002,
			"tags" : [
				"P13"
			],
			"type" : "slope",
			"to" : 1002,
			"from" : 1000,
			"brick" : "P13",
			"name" : "10002",
			"uuid" : "22a05639-e627-d248-9133-9108b7faab65",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 10003,
			"tags" : [
				"P13"
			],
			"type" : "slope",
			"to" : 1003,
			"from" : 1000,
			"brick" : "P13",
			"name" : "10003",
			"uuid" : "ef55d07b-8cc7-b94e-981d-af8bd4448152",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 10004,
			"tags" : [
				"P13"
			],
			"type" : "slope",
			"to" : 1004,
			"from" : 1000,
			"brick" : "P13",
			"name" : "10004",
			"uuid" : "2c58bc61-9563-db45-9cd8-dd893f07b5b1",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 10005,
			"tags" : [
				"P13"
			],
			"type" : "slope",
			"to" : 1005,
			"from" : 1001,
			"brick" : "P13",
			"name" : "10005",
			"uuid" : "5137e383-44d1-2d45-b16a-0bcbe9a1c039",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 10006,
			"tags" : [
				"P13"
			],
			"type" : "slope",
			"to" : 1006,
			"from" : 1002,
			"brick" : "P13",
			"name" : "10006",
			"uuid" : "447ae272-07cd-7b40-9318-c62b1d7f9183",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 10007,
			"tags" : [
				"P13"
			],
			"type" : "slope",
			"to" : 1007,
			"from" : 1003,
			"brick" : "P13",
			"name" : "10007",
			"uuid" : "accf6b9e-5e17-a646-8882-00ed32a56531",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 10008,
			"tags" : [
				"P13"
			],
			"type" : "slope",
			"to" : 1008,
			"from" : 1004,
			"brick" : "P13",
			"name" : "10008",
			"uuid" : "54a3c3e9-5b5f-3342-bc90-c21b6c8c1eff",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 10009,
			"tags" : [
				"P13"
			],
			"type" : "slope",
			"to" : 1009,
			"from" : 1005,
			"brick" : "P13",
			"name" : "10009",
			"uuid" : "db076445-02b3-0e4e-b13e-0f61f3eef1b0",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 10010,
			"tags" : [
				"P13"
			],
			"type" : "slope",
			"to" : 1010,
			"from" : 1006,
			"brick" : "P13",
			"name" : "10010",
			"uuid" : "f4919529-51c2-0045-ad59-5494754438b9",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 10011,
			"tags" : [
				"P13"
			],
			"type" : "slope",
			"to" : 1011,
			"from" : 1007,
			"brick" : "P13",
			"name" : "10011",
			"uuid" : "c85eb7d5-0876-104f-a27e-4c41d8ca15a3",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 10012,
			"tags" : [
				"P13"
			],
			"type" : "slope",
			"to" : 1012,
			"from" : 1008,
			"brick" : "P13",
			"name" : "10012",
			"uuid" : "4d839b3e-fcb2-6142-9925-9fa4e96c004c",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 10013,
			"tags" : [
				"P13"
			],
			"type" : "slope",
			"to" : 1013,
			"from" : 1009,
			"brick" : "P13",
			"name" : "10013",
			"uuid" : "728dc8b4-2d7d-c14d-8183-0467989342c4",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 10014,
			"tags" : [
				"P13"
			],
			"type" : "slope",
			"to" : 1014,
			"from" : 1010,
			"brick" : "P13",
			"name" : "10014",
			"uuid" : "755a1ad7-c7ab-0648-85a0-1b938823fc4e",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 10015,
			"tags" : [
				"P13"
			],
			"type" : "slope",
			"to" : 1015,
			"from" : 1011,
			"brick" : "P13",
			"name" : "10015",
			"uuid" : "846023c3-a3e4-cd44-97d6-fff2ddeafbd0",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 10016,
			"tags" : [
				"P13"
			],
			"type" : "slope",
			"to" : 1016,
			"from" : 1012,
			"brick" : "P13",
			"name" : "10016",
			"uuid" : "9bd5e5e8-163e-e445-b34f-99399fef2eb6",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 10017,
			"tags" : [
				"P13"
			],
			"type" : "slope",
			"to" : 1017,
			"from" : 1013,
			"brick" : "P13",
			"name" : "10017",
			"uuid" : "bd481baa-c2f4-f24d-870b-238edba39d4c",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 10018,
			"tags" : [
				"P13"
			],
			"type" : "slope",
			"to" : 1018,
			"from" : 1014,
			"brick" : "P13",
			"name" : "10018",
			"uuid" : "bb35f1f4-4a8e-c34c-8dc4-eab4aaa6bac5",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 10019,
			"tags" : [
				"P13"
			],
			"type" : "slope",
			"to" : 1019,
			"from" : 1015,
			"brick" : "P13",
			"name" : "10019",
			"uuid" : "f1e16f59-2799-5d4c-b437-fd197d1f786b",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 10020,
			"tags" : [
				"P13"
			],
			"type" : "slope",
			"to" : 1020,
			"from" : 1016,
			"brick" : "P13",
			"name" : "10020",
			"uuid" : "4f8ce0b1-b63a-b644-9286-741b20cbce5c",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 10021,
			"tags" : [
				"P13"
			],
			"type" : "slope",
			"to" : 1021,
			"from" : 1017,
			"brick" : "P13",
			"name" : "10021",
			"uuid" : "7512d0e8-5d97-bd4f-8e72-6b29b6c2f628",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 10022,
			"tags" : [
				"P13"
			],
			"type" : "slope",
			"to" : 1022,
			"from" : 1018,
			"brick" : "P13",
			"name" : "10022",
			"uuid" : "b7eb6e33-f08d-6247-93a6-435fe991e5fa",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 10023,
			"tags" : [
				"P13"
			],
			"type" : "slope",
			"to" : 1023,
			"from" : 1019,
			"brick" : "P13",
			"name" : "10023",
			"uuid" : "1ac710ad-3645-8e4a-bdbb-d8efd6ef3274",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 10024,
			"tags" : [
				"P13"
			],
			"type" : "slope",
			"to" : 1024,
			"from" : 1020,
			"brick" : "P13",
			"name" : "10024",
			"uuid" : "83bd4174-1aa9-d145-8175-443025cd34ed",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 10025,
			"tags" : [
				"P13"
			],
			"type" : "slope",
			"to" : 1025,
			"from" : 1021,
			"brick" : "P13",
			"name" : "10025",
			"uuid" : "ae1bf600-472d-504d-b070-2e95db7a1d8f",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 10026,
			"tags" : [
				"P13"
			],
			"type" : "slope",
			"to" : 1026,
			"from" : 1022,
			"brick" : "P13",
			"name" : "10026",
			"uuid" : "2a30e9f1-bceb-2941-aa57-2291e1061d38",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 10027,
			"tags" : [
				"P13"
			],
			"type" : "slope",
			"to" : 1027,
			"from" : 1023,
			"brick" : "P13",
			"name" : "10027",
			"uuid" : "f0027b46-5e96-f74d-a6cb-b2b889e433c1",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 10028,
			"tags" : [
				"P13"
			],
			"type" : "slope",
			"to" : 1028,
			"from" : 1024,
			"brick" : "P13",
			"name" : "10028",
			"uuid" : "cd45885d-a8ef-a34c-92a4-bffda9af5c17",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 10029,
			"tags" : [
				"P13"
			],
			"type" : "slope",
			"to" : 1029,
			"from" : 1025,
			"brick" : "P13",
			"name" : "10029",
			"uuid" : "c8ff3ece-bca2-ad4e-a943-baa0bb13146f",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 10030,
			"tags" : [
				"P13"
			],
			"type" : "slope",
			"to" : 1030,
			"from" : 1026,
			"brick" : "P13",
			"name" : "10030",
			"uuid" : "e5e2ad95-326f-f64e-a43c-3cbe2dc8f092",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 10031,
			"tags" : [
				"P13"
			],
			"type" : "slope",
			"to" : 1031,
			"from" : 1027,
			"brick" : "P13",
			"name" : "10031",
			"uuid" : "56d22b4e-4857-c447-baf3-c7a18f2a668d",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 10032,
			"tags" : [
				"P13"
			],
			"type" : "slope",
			"to" : 1032,
			"from" : 1028,
			"brick" : "P13",
			"name" : "10032",
			"uuid" : "7b1a2159-bb69-8f4f-b087-897a0c25f2e3",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 10033,
			"tags" : [
				"P13"
			],
			"type" : "slope",
			"to" : 1033,
			"from" : 1029,
			"brick" : "P13",
			"name" : "10033",
			"uuid" : "6427cf5e-a448-c149-b24f-a5df188efb8f",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 10034,
			"tags" : [
				"P13"
			],
			"type" : "slope",
			"to" : 1034,
			"from" : 1030,
			"brick" : "P13",
			"name" : "10034",
			"uuid" : "d2a61bb5-290d-a348-9ff4-40b91b51386b",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 10035,
			"tags" : [
				"P13"
			],
			"type" : "slope",
			"to" : 1035,
			"from" : 1031,
			"brick" : "P13",
			"name" : "10035",
			"uuid" : "bd6d6c2f-9df5-d647-957f-b3cf956adf4e",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 10036,
			"tags" : [
				"P13"
			],
			"type" : "slope",
			"to" : 1036,
			"from" : 1032,
			"brick" : "P13",
			"name" : "10036",
			"uuid" : "f2d84fd1-430d-5f44-af14-85439e10b636",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 10037,
			"tags" : [
				"P13"
			],
			"type" : "slope",
			"to" : 1037,
			"from" : 1033,
			"brick" : "P13",
			"name" : "10037",
			"uuid" : "264d6a1c-128b-914e-9170-f937927b71cd",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 10038,
			"tags" : [
				"P13"
			],
			"type" : "slope",
			"to" : 1038,
			"from" : 1034,
			"brick" : "P13",
			"name" : "10038",
			"uuid" : "dd87a850-db38-ac42-8da4-e97ee1c4c111",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 10039,
			"tags" : [
				"P13"
			],
			"type" : "slope",
			"to" : 1039,
			"from" : 1035,
			"brick" : "P13",
			"name" : "10039",
			"uuid" : "66480aa8-ddda-364f-8ab4-acd67c98acd6",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 10040,
			"tags" : [
				"P13"
			],
			"type" : "slope",
			"to" : 1040,
			"from" : 1036,
			"brick" : "P13",
			"name" : "10040",
			"uuid" : "9bb42874-f792-f946-a974-7221ba941146",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 10041,
			"tags" : [
				"P13"
			],
			"type" : "slope",
			"to" : 1041,
			"from" : 1037,
			"brick" : "P13",
			"name" : "10041",
			"uuid" : "f90bf709-c54d-fd46-9bb8-7f5d2a069591",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 10042,
			"tags" : [
				"P13"
			],
			"type" : "slope",
			"to" : 1042,
			"from" : 1038,
			"brick" : "P13",
			"name" : "10042",
			"uuid" : "818fee40-6351-8246-af5c-7b7e7ac55ea7",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 10043,
			"tags" : [
				"P13"
			],
			"type" : "slope",
			"to" : 1043,
			"from" : 1039,
			"brick" : "P13",
			"name" : "10043",
			"uuid" : "2d82550d-506e-184f-a916-2dff389dfe32",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 10044,
			"tags" : [
				"P13"
			],
			"type" : "slope",
			"to" : 1044,
			"from" : 1040,
			"brick" : "P13",
			"name" : "10044",
			"uuid" : "b0695868-cb93-ad4c-9c6a-6991c9c20183",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 10045,
			"tags" : [
				"P13"
			],
			"type" : "slope",
			"to" : 1045,
			"from" : 1041,
			"brick" : "P13",
			"name" : "10045",
			"uuid" : "5412fa9b-2691-f543-bef0-8b65eafdfb84",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 10046,
			"tags" : [
				"P13"
			],
			"type" : "slope",
			"to" : 1046,
			"from" : 1042,
			"brick" : "P13",
			"name" : "10046",
			"uuid" : "0f69d494-09b5-0e46-840e-be5dd2d4191d",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 10047,
			"tags" : [
				"P13"
			],
			"type" : "slope",
			"to" : 1047,
			"from" : 1043,
			"brick" : "P13",
			"name" : "10047",
			"uuid" : "f33a5833-13fa-f644-a4c3-4c2a1a0494ab",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 10048,
			"tags" : [
				"P13"
			],
			"type" : "slope",
			"to" : 1048,
			"from" : 1044,
			"brick" : "P13",
			"name" : "10048",
			"uuid" : "5a730a8d-3c6c-064e-b421-5b20824d715d",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 10049,
			"tags" : [
				"P13"
			],
			"type" : "slope",
			"to" : 1049,
			"from" : 1045,
			"brick" : "P13",
			"name" : "10049",
			"uuid" : "132dfed1-1b74-b24e-acf1-bebf798180d6",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 10050,
			"tags" : [
				"P13"
			],
			"type" : "slope",
			"to" : 1050,
			"from" : 1046,
			"brick" : "P13",
			"name" : "10050",
			"uuid" : "f94e8c6c-4a1c-3746-85c9-094bb0f839ac",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 10051,
			"tags" : [
				"P13"
			],
			"type" : "slope",
			"to" : 1051,
			"from" : 1047,
			"brick" : "P13",
			"name" : "10051",
			"uuid" : "a2736eaa-32e5-fa4b-a2f4-00aac66b8877",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 10052,
			"tags" : [
				"P13"
			],
			"type" : "slope",
			"to" : 1052,
			"from" : 1048,
			"brick" : "P13",
			"name" : "10052",
			"uuid" : "e4d2097d-47b4-7b4f-a1b8-f6fed976fc74",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 10053,
			"tags" : [
				"P13"
			],
			"type" : "slope",
			"to" : 1053,
			"from" : 1049,
			"brick" : "P13",
			"name" : "10053",
			"uuid" : "975f4962-75d2-ca4a-b5be-238f0da007d2",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 10054,
			"tags" : [
				"P13"
			],
			"type" : "slope",
			"to" : 1054,
			"from" : 1050,
			"brick" : "P13",
			"name" : "10054",
			"uuid" : "36ffdbbe-0188-a841-abc1-ac1029571f6e",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 10055,
			"tags" : [
				"P13"
			],
			"type" : "slope",
			"to" : 1055,
			"from" : 1051,
			"brick" : "P13",
			"name" : "10055",
			"uuid" : "707df5fc-6460-9342-a0e3-1b5d0a1d2e16",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 10056,
			"tags" : [
				"P13"
			],
			"type" : "slope",
			"to" : 1056,
			"from" : 1052,
			"brick" : "P13",
			"name" : "10056",
			"uuid" : "8595d9a3-4781-e648-85b4-73d6ac48eca1",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 10057,
			"tags" : [
				"P13"
			],
			"type" : "slope",
			"to" : 1057,
			"from" : 1053,
			"brick" : "P13",
			"name" : "10057",
			"uuid" : "edf0120e-16c7-ed46-9513-70ff7290f9ef",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 10058,
			"tags" : [
				"P13"
			],
			"type" : "slope",
			"to" : 1058,
			"from" : 1054,
			"brick" : "P13",
			"name" : "10058",
			"uuid" : "f07d7ba2-8d1d-5446-a1e7-0ea3f86b453c",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 10059,
			"tags" : [
				"P13"
			],
			"type" : "slope",
			"to" : 1059,
			"from" : 1055,
			"brick" : "P13",
			"name" : "10059",
			"uuid" : "04203a93-2555-9a49-8b34-72cbdf988fff",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 10060,
			"tags" : [
				"P13"
			],
			"type" : "slope",
			"to" : 1060,
			"from" : 1056,
			"brick" : "P13",
			"name" : "10060",
			"uuid" : "1667430c-4381-ca48-8da4-b89bc246f605",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 10061,
			"tags" : [
				"P13"
			],
			"type" : "slope",
			"to" : 1061,
			"from" : 1057,
			"brick" : "P13",
			"name" : "10061",
			"uuid" : "c4e354e3-c2d8-9c48-9f00-0897b495a019",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 10062,
			"tags" : [
				"P13"
			],
			"type" : "slope",
			"to" : 1062,
			"from" : 1058,
			"brick" : "P13",
			"name" : "10062",
			"uuid" : "c00ea962-100f-3a47-ae8a-23b59738abb6",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 10063,
			"tags" : [
				"P13"
			],
			"type" : "slope",
			"to" : 1063,
			"from" : 1059,
			"brick" : "P13",
			"name" : "10063",
			"uuid" : "cf0421ee-feb1-ec4d-9eeb-56bdcffd84ce",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 10064,
			"tags" : [
				"P13"
			],
			"type" : "slope",
			"to" : 1064,
			"from" : 1060,
			"brick" : "P13",
			"name" : "10064",
			"uuid" : "0b93cf0f-1802-8148-84ea-046b64335160",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 10065,
			"tags" : [
				"P13"
			],
			"type" : "slope",
			"to" : 1065,
			"from" : 1061,
			"brick" : "P13",
			"name" : "10065",
			"uuid" : "7ec6416a-94e9-8a49-93eb-a2d66fc8a0e3",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 10066,
			"tags" : [
				"P13"
			],
			"type" : "slope",
			"to" : 1066,
			"from" : 1062,
			"brick" : "P13",
			"name" : "10066",
			"uuid" : "5ff20a51-bdbe-7147-8e4a-8ff88c7cea57",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 10067,
			"tags" : [
				"P13"
			],
			"type" : "slope",
			"to" : 1067,
			"from" : 1063,
			"brick" : "P13",
			"name" : "10067",
			"uuid" : "629e3aba-e239-ce47-86e7-dbbb240ecd7e",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 10068,
			"tags" : [
				"P13"
			],
			"type" : "slope",
			"to" : 1068,
			"from" : 1064,
			"brick" : "P13",
			"name" : "10068",
			"uuid" : "2017cf46-3757-cc46-8a4c-7429b7e94612",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 10069,
			"tags" : [
				"P13"
			],
			"type" : "slope",
			"to" : 1069,
			"from" : 1065,
			"brick" : "P13",
			"name" : "10069",
			"uuid" : "fb8d99f0-1002-964d-8637-57488bfa4c9f",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 10070,
			"tags" : [
				"P13"
			],
			"type" : "slope",
			"to" : 1070,
			"from" : 1066,
			"brick" : "P13",
			"name" : "10070",
			"uuid" : "1d4939d2-e902-6843-ab25-b3dcc4a84fb8",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 10071,
			"tags" : [
				"P13"
			],
			"type" : "slope",
			"to" : 1071,
			"from" : 1067,
			"brick" : "P13",
			"name" : "10071",
			"uuid" : "454664b2-f81c-9349-a685-5a592d813b4b",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 10072,
			"tags" : [
				"P13"
			],
			"type" : "slope",
			"to" : 1072,
			"from" : 1068,
			"brick" : "P13",
			"name" : "10072",
			"uuid" : "9c1e9f22-18de-2f4c-9996-91b921b4c15c",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 10073,
			"tags" : [
				"P13"
			],
			"type" : "slope",
			"to" : 1073,
			"from" : 1069,
			"brick" : "P13",
			"name" : "10073",
			"uuid" : "712b1637-d02e-bc49-b0ea-d26ef576e061",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 10074,
			"tags" : [
				"P13"
			],
			"type" : "slope",
			"to" : 1074,
			"from" : 1070,
			"brick" : "P13",
			"name" : "10074",
			"uuid" : "232e78fa-c604-f543-b3ea-f7da0d4f4b09",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 10075,
			"tags" : [
				"P13"
			],
			"type" : "slope",
			"to" : 1075,
			"from" : 1071,
			"brick" : "P13",
			"name" : "10075",
			"uuid" : "2d6afc1f-48fe-3940-a7d8-f26b06224eda",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 10076,
			"tags" : [
				"P13"
			],
			"type" : "slope",
			"to" : 1076,
			"from" : 1072,
			"brick" : "P13",
			"name" : "10076",
			"uuid" : "c497b7a3-6426-fc4f-bba0-278329148f63",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 28001,
			"tags" : [
				"P13"
			],
			"type" : "sectionRound",
			"to" : 1002,
			"from" : 1001,
			"brick" : "P13",
			"name" : "28001",
			"uuid" : "696e6a7d-c567-9c49-91d6-09479562134c",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 28002,
			"tags" : [
				"P13"
			],
			"type" : "sectionRound",
			"to" : 1003,
			"from" : 1002,
			"brick" : "P13",
			"name" : "28002",
			"uuid" : "ba0361f7-3590-e943-898b-c78009eabae6",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 28003,
			"tags" : [
				"P13"
			],
			"type" : "sectionRound",
			"to" : 1004,
			"from" : 1003,
			"brick" : "P13",
			"name" : "28003",
			"uuid" : "65add777-a5cb-3d48-b62e-61abbe8a9be7",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 28004,
			"tags" : [
				"P13"
			],
			"type" : "sectionRound",
			"to" : 1001,
			"from" : 1004,
			"brick" : "P13",
			"name" : "28004",
			"uuid" : "bf03b982-8caa-5d4c-917d-f6af94ebe6ea",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 28005,
			"tags" : [
				"P13"
			],
			"type" : "sectionRound",
			"to" : 1006,
			"from" : 1005,
			"brick" : "P13",
			"name" : "28005",
			"uuid" : "1f9b4ac9-bb79-cf48-9018-a320537d5a18",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 28006,
			"tags" : [
				"P13"
			],
			"type" : "sectionRound",
			"to" : 1007,
			"from" : 1006,
			"brick" : "P13",
			"name" : "28006",
			"uuid" : "13f152eb-6661-784d-85df-b0dc9ffb2fc4",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 28007,
			"tags" : [
				"P13"
			],
			"type" : "sectionRound",
			"to" : 1008,
			"from" : 1007,
			"brick" : "P13",
			"name" : "28007",
			"uuid" : "f3499677-a4b2-df44-9027-03975b8e8534",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 28008,
			"tags" : [
				"P13"
			],
			"type" : "sectionRound",
			"to" : 1005,
			"from" : 1008,
			"brick" : "P13",
			"name" : "28008",
			"uuid" : "4bfaf51f-8cd4-1a48-8b3b-c5a680466e6b",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 28009,
			"tags" : [
				"P13"
			],
			"type" : "sectionRound",
			"to" : 1010,
			"from" : 1009,
			"brick" : "P13",
			"name" : "28009",
			"uuid" : "b03a97ae-9df3-d945-9927-edb6b6f77ecf",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 28010,
			"tags" : [
				"P13"
			],
			"type" : "sectionRound",
			"to" : 1011,
			"from" : 1010,
			"brick" : "P13",
			"name" : "28010",
			"uuid" : "dc08111c-1a65-d84a-9b56-bc82993f5e82",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 28011,
			"tags" : [
				"P13"
			],
			"type" : "sectionRound",
			"to" : 1012,
			"from" : 1011,
			"brick" : "P13",
			"name" : "28011",
			"uuid" : "d98b55da-95d6-e247-9147-95f97bf09751",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 28012,
			"tags" : [
				"P13"
			],
			"type" : "sectionRound",
			"to" : 1009,
			"from" : 1012,
			"brick" : "P13",
			"name" : "28012",
			"uuid" : "7e7e3464-88fb-8f4b-bccd-17615112cbc0",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 28013,
			"tags" : [
				"P13"
			],
			"type" : "sectionRound",
			"to" : 1014,
			"from" : 1013,
			"brick" : "P13",
			"name" : "28013",
			"uuid" : "5e7df32a-1628-a749-8e64-879d0854bb4d",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 28014,
			"tags" : [
				"P13"
			],
			"type" : "sectionRound",
			"to" : 1015,
			"from" : 1014,
			"brick" : "P13",
			"name" : "28014",
			"uuid" : "1686bcc4-d1ab-0e47-9a96-508b1ea83cdf",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 28015,
			"tags" : [
				"P13"
			],
			"type" : "sectionRound",
			"to" : 1016,
			"from" : 1015,
			"brick" : "P13",
			"name" : "28015",
			"uuid" : "5aff4cf5-3a2f-4a41-b996-a1be95a1b36a",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 28016,
			"tags" : [
				"P13"
			],
			"type" : "sectionRound",
			"to" : 1013,
			"from" : 1016,
			"brick" : "P13",
			"name" : "28016",
			"uuid" : "18367378-3662-f842-9f4d-d87321a200a2",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 28017,
			"tags" : [
				"P13"
			],
			"type" : "sectionRound",
			"to" : 1018,
			"from" : 1017,
			"brick" : "P13",
			"name" : "28017",
			"uuid" : "1c285c9d-8ee3-f249-9845-74b50fb9f1c5",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 28018,
			"tags" : [
				"P13"
			],
			"type" : "sectionRound",
			"to" : 1019,
			"from" : 1018,
			"brick" : "P13",
			"name" : "28018",
			"uuid" : "78938151-11df-0245-aa2e-147346027ca3",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 28019,
			"tags" : [
				"P13"
			],
			"type" : "sectionRound",
			"to" : 1020,
			"from" : 1019,
			"brick" : "P13",
			"name" : "28019",
			"uuid" : "5de04970-493d-254a-ab8f-12309e32ad12",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 28020,
			"tags" : [
				"P13"
			],
			"type" : "sectionRound",
			"to" : 1017,
			"from" : 1020,
			"brick" : "P13",
			"name" : "28020",
			"uuid" : "bbcbdb61-2854-ae40-a4f0-2f5e50cd07e8",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 28021,
			"tags" : [
				"P13"
			],
			"type" : "sectionRound",
			"to" : 1022,
			"from" : 1021,
			"brick" : "P13",
			"name" : "28021",
			"uuid" : "e204d1e3-6b7e-f944-8ea9-149ee4a9d9c2",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 28022,
			"tags" : [
				"P13"
			],
			"type" : "sectionRound",
			"to" : 1023,
			"from" : 1022,
			"brick" : "P13",
			"name" : "28022",
			"uuid" : "9f83a3c4-77e3-0045-b5b4-0d6b8e4d6f6f",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 28023,
			"tags" : [
				"P13"
			],
			"type" : "sectionRound",
			"to" : 1024,
			"from" : 1023,
			"brick" : "P13",
			"name" : "28023",
			"uuid" : "a2c26875-8014-ac43-8fb0-227444ffcff7",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 28024,
			"tags" : [
				"P13"
			],
			"type" : "sectionRound",
			"to" : 1021,
			"from" : 1024,
			"brick" : "P13",
			"name" : "28024",
			"uuid" : "e3b8ca9c-437b-0046-8ca2-26ebd71f440e",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 28025,
			"tags" : [
				"P13"
			],
			"type" : "sectionRound",
			"to" : 1085,
			"from" : 1029,
			"brick" : "P13",
			"name" : "28025",
			"uuid" : "35ad6e2d-a084-5b4a-9b37-5d5c896c6afd",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 28026,
			"tags" : [
				"P13"
			],
			"type" : "sectionRound",
			"to" : 1030,
			"from" : 1085,
			"brick" : "P13",
			"name" : "28026",
			"uuid" : "17f694e4-638e-e748-a221-0977d7cded88",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 28027,
			"tags" : [
				"P13"
			],
			"type" : "sectionRound",
			"to" : 1086,
			"from" : 1030,
			"brick" : "P13",
			"name" : "28027",
			"uuid" : "82b73129-9353-7948-a67f-bc247547fb73",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 28028,
			"tags" : [
				"P13"
			],
			"type" : "sectionRound",
			"to" : 1031,
			"from" : 1086,
			"brick" : "P13",
			"name" : "28028",
			"uuid" : "dd0ba105-9fa9-d34c-bd83-9995fb4a5f9d",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 28029,
			"tags" : [
				"P13"
			],
			"type" : "sectionRound",
			"to" : 1087,
			"from" : 1031,
			"brick" : "P13",
			"name" : "28029",
			"uuid" : "c4d47979-84d4-d34a-b9ff-61e75256141e",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 28030,
			"tags" : [
				"P13"
			],
			"type" : "sectionRound",
			"to" : 1032,
			"from" : 1087,
			"brick" : "P13",
			"name" : "28030",
			"uuid" : "4cc56bff-b4cf-9947-8bda-a8912f4e2b44",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 28031,
			"tags" : [
				"P13"
			],
			"type" : "sectionRound",
			"to" : 1088,
			"from" : 1032,
			"brick" : "P13",
			"name" : "28031",
			"uuid" : "bf3d0590-0c07-ca42-abb5-f25ce86e4693",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 28032,
			"tags" : [
				"P13"
			],
			"type" : "sectionRound",
			"to" : 1029,
			"from" : 1088,
			"brick" : "P13",
			"name" : "28032",
			"uuid" : "b82d9ac3-71f4-d54e-9323-19962459396c",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 28033,
			"tags" : [
				"P13"
			],
			"type" : "sectionRound",
			"to" : 1089,
			"from" : 1037,
			"brick" : "P13",
			"name" : "28033",
			"uuid" : "9c5e317b-7079-ab4b-8763-18c8c3370968",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 28034,
			"tags" : [
				"P13"
			],
			"type" : "sectionRound",
			"to" : 1038,
			"from" : 1089,
			"brick" : "P13",
			"name" : "28034",
			"uuid" : "99f98782-4229-5345-b34f-e5b6d1641d04",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 28035,
			"tags" : [
				"P13"
			],
			"type" : "sectionRound",
			"to" : 1090,
			"from" : 1038,
			"brick" : "P13",
			"name" : "28035",
			"uuid" : "a030cecd-7a0d-bd4d-91b5-354180034bc7",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 28036,
			"tags" : [
				"P13"
			],
			"type" : "sectionRound",
			"to" : 1039,
			"from" : 1090,
			"brick" : "P13",
			"name" : "28036",
			"uuid" : "3a48a926-651f-484a-b4f7-3f217890d247",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 28037,
			"tags" : [
				"P13"
			],
			"type" : "sectionRound",
			"to" : 1091,
			"from" : 1039,
			"brick" : "P13",
			"name" : "28037",
			"uuid" : "a8eef307-96b6-7849-8038-92b17de563f7",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 28038,
			"tags" : [
				"P13"
			],
			"type" : "sectionRound",
			"to" : 1040,
			"from" : 1091,
			"brick" : "P13",
			"name" : "28038",
			"uuid" : "ed3b1609-956f-d84e-8e96-cf10d84d6461",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 28039,
			"tags" : [
				"P13"
			],
			"type" : "sectionRound",
			"to" : 1092,
			"from" : 1040,
			"brick" : "P13",
			"name" : "28039",
			"uuid" : "3030802b-9324-a346-a6f7-6f99f8966d67",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 28040,
			"tags" : [
				"P13"
			],
			"type" : "sectionRound",
			"to" : 1037,
			"from" : 1092,
			"brick" : "P13",
			"name" : "28040",
			"uuid" : "6f334632-393e-2243-ae47-8c34354b156e",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 28041,
			"tags" : [
				"P13"
			],
			"type" : "sectionRound",
			"to" : 1093,
			"from" : 1045,
			"brick" : "P13",
			"name" : "28041",
			"uuid" : "5d8fb9f0-c67d-9743-ada7-e3da83047391",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 28042,
			"tags" : [
				"P13"
			],
			"type" : "sectionRound",
			"to" : 1046,
			"from" : 1093,
			"brick" : "P13",
			"name" : "28042",
			"uuid" : "991485e5-5d4e-e344-b4d3-febdbec83fb1",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 28043,
			"tags" : [
				"P13"
			],
			"type" : "sectionRound",
			"to" : 1094,
			"from" : 1046,
			"brick" : "P13",
			"name" : "28043",
			"uuid" : "935782fa-3334-1744-88fb-27052e149e74",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 28044,
			"tags" : [
				"P13"
			],
			"type" : "sectionRound",
			"to" : 1047,
			"from" : 1094,
			"brick" : "P13",
			"name" : "28044",
			"uuid" : "894569c6-d2fb-9647-a01c-9499c02fa26e",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 28045,
			"tags" : [
				"P13"
			],
			"type" : "sectionRound",
			"to" : 1095,
			"from" : 1047,
			"brick" : "P13",
			"name" : "28045",
			"uuid" : "4ce7135e-6df3-fb4c-aa64-8161af64a958",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 28046,
			"tags" : [
				"P13"
			],
			"type" : "sectionRound",
			"to" : 1048,
			"from" : 1095,
			"brick" : "P13",
			"name" : "28046",
			"uuid" : "16059a0c-b32d-e84e-a93e-69ab20d1f0dc",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 28047,
			"tags" : [
				"P13"
			],
			"type" : "sectionRound",
			"to" : 1096,
			"from" : 1048,
			"brick" : "P13",
			"name" : "28047",
			"uuid" : "34a8819f-f050-0e45-83f9-00b8dba9d435",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 28048,
			"tags" : [
				"P13"
			],
			"type" : "sectionRound",
			"to" : 1045,
			"from" : 1096,
			"brick" : "P13",
			"name" : "28048",
			"uuid" : "0f86d56d-867b-6045-8af2-f449a6647072",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 28049,
			"tags" : [
				"P13"
			],
			"type" : "sectionRound",
			"to" : 1097,
			"from" : 1053,
			"brick" : "P13",
			"name" : "28049",
			"uuid" : "87e18392-bc8d-5142-b851-8bb9cdcd51cf",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 28050,
			"tags" : [
				"P13"
			],
			"type" : "sectionRound",
			"to" : 1054,
			"from" : 1097,
			"brick" : "P13",
			"name" : "28050",
			"uuid" : "9f6bc43b-9a9d-e243-8dea-1ea08041d3e6",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 28051,
			"tags" : [
				"P13"
			],
			"type" : "sectionRound",
			"to" : 1098,
			"from" : 1054,
			"brick" : "P13",
			"name" : "28051",
			"uuid" : "b406a152-4d5d-3b42-9359-9afa346cfb1a",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 28052,
			"tags" : [
				"P13"
			],
			"type" : "sectionRound",
			"to" : 1055,
			"from" : 1098,
			"brick" : "P13",
			"name" : "28052",
			"uuid" : "da740ff2-7eda-0847-b0cb-48dc48f5ff11",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 28053,
			"tags" : [
				"P13"
			],
			"type" : "sectionRound",
			"to" : 1099,
			"from" : 1055,
			"brick" : "P13",
			"name" : "28053",
			"uuid" : "fbc20c67-a8fe-de41-b75b-fbab3c03daca",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 28054,
			"tags" : [
				"P13"
			],
			"type" : "sectionRound",
			"to" : 1056,
			"from" : 1099,
			"brick" : "P13",
			"name" : "28054",
			"uuid" : "ac65a7fb-8fb3-694b-815c-3ba4d500778f",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 28055,
			"tags" : [
				"P13"
			],
			"type" : "sectionRound",
			"to" : 1100,
			"from" : 1056,
			"brick" : "P13",
			"name" : "28055",
			"uuid" : "a2fe7985-f2c4-8544-b70d-e2845852459e",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 28056,
			"tags" : [
				"P13"
			],
			"type" : "sectionRound",
			"to" : 1053,
			"from" : 1100,
			"brick" : "P13",
			"name" : "28056",
			"uuid" : "e6efae50-840a-a24f-908b-5528144f3bc7",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 28057,
			"tags" : [
				"P13"
			],
			"type" : "sectionRound",
			"to" : 1101,
			"from" : 1061,
			"brick" : "P13",
			"name" : "28057",
			"uuid" : "493cd433-3a76-884f-b5a8-03be410f5ac8",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 28058,
			"tags" : [
				"P13"
			],
			"type" : "sectionRound",
			"to" : 1062,
			"from" : 1101,
			"brick" : "P13",
			"name" : "28058",
			"uuid" : "33f08873-6e42-c347-9b11-d22c56066c15",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 28059,
			"tags" : [
				"P13"
			],
			"type" : "sectionRound",
			"to" : 1102,
			"from" : 1062,
			"brick" : "P13",
			"name" : "28059",
			"uuid" : "504dac91-1109-0f42-b223-bc62d0bdb47c",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 28060,
			"tags" : [
				"P13"
			],
			"type" : "sectionRound",
			"to" : 1063,
			"from" : 1102,
			"brick" : "P13",
			"name" : "28060",
			"uuid" : "eb6a2148-8458-c843-b047-24157c38cb07",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 28061,
			"tags" : [
				"P13"
			],
			"type" : "sectionRound",
			"to" : 1103,
			"from" : 1063,
			"brick" : "P13",
			"name" : "28061",
			"uuid" : "b24049b3-71d2-c147-a51f-c0fb24596fe6",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 28062,
			"tags" : [
				"P13"
			],
			"type" : "sectionRound",
			"to" : 1064,
			"from" : 1103,
			"brick" : "P13",
			"name" : "28062",
			"uuid" : "79f806cc-3e4e-2543-bbe2-6c4eac64d0d5",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 28063,
			"tags" : [
				"P13"
			],
			"type" : "sectionRound",
			"to" : 1104,
			"from" : 1064,
			"brick" : "P13",
			"name" : "28063",
			"uuid" : "d4b95257-41db-fc41-84b5-3d60ebb8e834",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 28064,
			"tags" : [
				"P13"
			],
			"type" : "sectionRound",
			"to" : 1061,
			"from" : 1104,
			"brick" : "P13",
			"name" : "28064",
			"uuid" : "cb00ac00-88a4-5244-9020-0e3fd407cc70",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 28065,
			"tags" : [
				"P13"
			],
			"type" : "sectionRound",
			"to" : 1105,
			"from" : 1069,
			"brick" : "P13",
			"name" : "28065",
			"uuid" : "8d6ed319-31e4-9f40-ab3f-df8913d5cf74",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 28066,
			"tags" : [
				"P13"
			],
			"type" : "sectionRound",
			"to" : 1070,
			"from" : 1105,
			"brick" : "P13",
			"name" : "28066",
			"uuid" : "994407e9-c620-0843-b39d-66bfba7e9dad",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 28067,
			"tags" : [
				"P13"
			],
			"type" : "sectionRound",
			"to" : 1106,
			"from" : 1070,
			"brick" : "P13",
			"name" : "28067",
			"uuid" : "2dfe7326-730d-3d4e-a489-85cdb3c726b1",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 28068,
			"tags" : [
				"P13"
			],
			"type" : "sectionRound",
			"to" : 1071,
			"from" : 1106,
			"brick" : "P13",
			"name" : "28068",
			"uuid" : "49b9dbb8-079f-5a4e-b614-6cfc58b0d9a2",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 28069,
			"tags" : [
				"P13"
			],
			"type" : "sectionRound",
			"to" : 1107,
			"from" : 1071,
			"brick" : "P13",
			"name" : "28069",
			"uuid" : "08d8adcf-1d6c-2641-b4ce-97ce6130990f",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 28070,
			"tags" : [
				"P13"
			],
			"type" : "sectionRound",
			"to" : 1072,
			"from" : 1107,
			"brick" : "P13",
			"name" : "28070",
			"uuid" : "5782276a-461d-e24d-b78e-1c6fb77e4dc6",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 28071,
			"tags" : [
				"P13"
			],
			"type" : "sectionRound",
			"to" : 1108,
			"from" : 1072,
			"brick" : "P13",
			"name" : "28071",
			"uuid" : "bb0dc4b5-c4ce-6d43-acad-9aff924b2e37",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 28072,
			"tags" : [
				"P13"
			],
			"type" : "sectionRound",
			"to" : 1069,
			"from" : 1108,
			"brick" : "P13",
			"name" : "28072",
			"uuid" : "f803d0ae-6f81-c841-81e1-6ed4ef565bcb",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 28101,
			"tags" : [
				"P13"
			],
			"type" : "sectionSlant",
			"to" : 1020,
			"from" : 2201,
			"brick" : "P13",
			"name" : "28101",
			"uuid" : "4e8f9581-cace-b848-8616-8c59f4c752fe",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 28102,
			"tags" : [
				"P13"
			],
			"type" : "sectionSlant",
			"to" : 2201,
			"from" : 1018,
			"brick" : "P13",
			"name" : "28102",
			"uuid" : "8303cbe4-3aa7-9647-8de6-5a0a0c195a01",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 28103,
			"tags" : [
				"P13"
			],
			"type" : "sectionSlant",
			"to" : 1019,
			"from" : 2201,
			"brick" : "P13",
			"name" : "28103",
			"uuid" : "71bb509a-4150-f342-9b8e-cb4cbaf71c62",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 28104,
			"tags" : [
				"P13"
			],
			"type" : "sectionSlant",
			"to" : 2201,
			"from" : 1017,
			"brick" : "P13",
			"name" : "28104",
			"uuid" : "0ebcc6b2-9d42-7643-9946-980fafb3dfec",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 28105,
			"tags" : [
				"P13"
			],
			"type" : "sectionSlant",
			"to" : 1024,
			"from" : 2202,
			"brick" : "P13",
			"name" : "28105",
			"uuid" : "ece2f7b4-0352-e340-b478-669ac03c852b",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 28106,
			"tags" : [
				"P13"
			],
			"type" : "sectionSlant",
			"to" : 2202,
			"from" : 1022,
			"brick" : "P13",
			"name" : "28106",
			"uuid" : "1dfba1e2-8bca-9340-97d5-bd66e01cf57b",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 28107,
			"tags" : [
				"P13"
			],
			"type" : "sectionSlant",
			"to" : 1023,
			"from" : 2202,
			"brick" : "P13",
			"name" : "28107",
			"uuid" : "44c112bf-5e24-1649-80b9-fb7a95f8b554",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 28108,
			"tags" : [
				"P13"
			],
			"type" : "sectionSlant",
			"to" : 2202,
			"from" : 1021,
			"brick" : "P13",
			"name" : "28108",
			"uuid" : "dd914327-9b35-3b47-992c-39aafe871103",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 28109,
			"tags" : [
				"P13"
			],
			"type" : "sectionSlant",
			"to" : 1101,
			"from" : 1104,
			"brick" : "P13",
			"name" : "28109",
			"uuid" : "859914ad-7d0e-f24a-b42f-ff2ccbdf709d",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 28110,
			"tags" : [
				"P13"
			],
			"type" : "sectionSlant",
			"to" : 1102,
			"from" : 1101,
			"brick" : "P13",
			"name" : "28110",
			"uuid" : "1649fe8e-b433-2b45-97d9-a92691b703fd",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 28111,
			"tags" : [
				"P13"
			],
			"type" : "sectionSlant",
			"to" : 1103,
			"from" : 1102,
			"brick" : "P13",
			"name" : "28111",
			"uuid" : "b064e0b0-6702-a949-beed-62c7c1d270e4",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 28112,
			"tags" : [
				"P13"
			],
			"type" : "sectionSlant",
			"to" : 1104,
			"from" : 1103,
			"brick" : "P13",
			"name" : "28112",
			"uuid" : "aff5d5e3-bff0-0440-b9a1-67f944796d41",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 28113,
			"tags" : [
				"P13"
			],
			"type" : "sectionSlant",
			"to" : 1105,
			"from" : 1108,
			"brick" : "P13",
			"name" : "28113",
			"uuid" : "8fefaa49-abdc-a44f-a71b-b401cba3f1ec",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 28114,
			"tags" : [
				"P13"
			],
			"type" : "sectionSlant",
			"to" : 1106,
			"from" : 1105,
			"brick" : "P13",
			"name" : "28114",
			"uuid" : "ca2288b7-927d-bd48-80a3-7398ada84b07",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 28115,
			"tags" : [
				"P13"
			],
			"type" : "sectionSlant",
			"to" : 1107,
			"from" : 1106,
			"brick" : "P13",
			"name" : "28115",
			"uuid" : "643fd035-0b7c-ee47-9ab8-5af45f441614",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 28116,
			"tags" : [
				"P13"
			],
			"type" : "sectionSlant",
			"to" : 1108,
			"from" : 1107,
			"brick" : "P13",
			"name" : "28116",
			"uuid" : "6a516bdd-d9db-824d-b37a-41bce929d35d",
			"_clazz" : "TwkSegment"
		},
		{
			"uuid" : "ea6664e4-38ac-9f4b-935a-96fdb326d280",
			"name" : "19001",
			"_clazz" : "TwkSegment",
			"brick" : "FRONT",
			"from" : 1006,
			"face" : "front",
			"tags" : [
				"P13"
			],
			"type" : "panel",
			"to" : 1001,
			"number" : 19001
		},
		{
			"uuid" : "4f19674a-82f9-ab44-80f8-46e8d6213222",
			"name" : "19002",
			"_clazz" : "TwkSegment",
			"brick" : "LEFT",
			"from" : 1007,
			"face" : "left",
			"tags" : [
				"P13"
			],
			"type" : "panel",
			"to" : 1002,
			"number" : 19002
		},
		{
			"uuid" : "9290dd95-fb6e-334f-8ac5-c5c9c5a98814",
			"name" : "19003",
			"_clazz" : "TwkSegment",
			"brick" : "BACK",
			"from" : 1008,
			"face" : "back",
			"tags" : [
				"P13"
			],
			"type" : "panel",
			"to" : 1003,
			"number" : 19003
		},
		{
			"uuid" : "18d6cfd6-ef6e-3c4e-a47d-dcb52b45ab20",
			"name" : "19004",
			"_clazz" : "TwkSegment",
			"brick" : "RIGHT",
			"from" : 1005,
			"face" : "right",
			"tags" : [
				"P13"
			],
			"type" : "panel",
			"to" : 1004,
			"number" : 19004
		},
		{
			"uuid" : "7b7ee028-cf5e-9b49-a0b4-4a8af53eeea9",
			"name" : "19005",
			"_clazz" : "TwkSegment",
			"brick" : "FRONT",
			"from" : 1010,
			"face" : "front",
			"tags" : [
				"P13"
			],
			"type" : "panel",
			"to" : 1005,
			"number" : 19005
		},
		{
			"uuid" : "c8531d30-f103-9c42-a318-2d6b322b7c3e",
			"name" : "19006",
			"_clazz" : "TwkSegment",
			"brick" : "LEFT",
			"from" : 1011,
			"face" : "left",
			"tags" : [
				"P13"
			],
			"type" : "panel",
			"to" : 1006,
			"number" : 19006
		},
		{
			"uuid" : "3e895080-c5df-9a44-ac3d-7eb31db6db6a",
			"name" : "19007",
			"_clazz" : "TwkSegment",
			"brick" : "BACK",
			"from" : 1012,
			"face" : "back",
			"tags" : [
				"P13"
			],
			"type" : "panel",
			"to" : 1007,
			"number" : 19007
		},
		{
			"uuid" : "ef6346cf-2767-fb48-98bf-a92aa8c9d977",
			"name" : "19008",
			"_clazz" : "TwkSegment",
			"brick" : "RIGHT",
			"from" : 1009,
			"face" : "right",
			"tags" : [
				"P13"
			],
			"type" : "panel",
			"to" : 1008,
			"number" : 19008
		},
		{
			"uuid" : "da0233b6-de87-534a-b505-2196a9ddd60c",
			"name" : "19009",
			"_clazz" : "TwkSegment",
			"brick" : "FRONT",
			"from" : 1014,
			"face" : "front",
			"tags" : [
				"P13"
			],
			"type" : "panel",
			"to" : 1009,
			"number" : 19009
		},
		{
			"uuid" : "bb21e742-8b7d-5043-abd7-dbada3df7c91",
			"name" : "19010",
			"_clazz" : "TwkSegment",
			"brick" : "LEFT",
			"from" : 1015,
			"face" : "left",
			"tags" : [
				"P13"
			],
			"type" : "panel",
			"to" : 1010,
			"number" : 19010
		},
		{
			"uuid" : "66738cd6-d050-3b40-b1e3-790019fa82ba",
			"name" : "19011",
			"_clazz" : "TwkSegment",
			"brick" : "BACK",
			"from" : 1016,
			"face" : "back",
			"tags" : [
				"P13"
			],
			"type" : "panel",
			"to" : 1011,
			"number" : 19011
		},
		{
			"uuid" : "44905876-bd66-a144-a705-0a603d4e0077",
			"name" : "19012",
			"_clazz" : "TwkSegment",
			"brick" : "RIGHT",
			"from" : 1013,
			"face" : "right",
			"tags" : [
				"P13"
			],
			"type" : "panel",
			"to" : 1012,
			"number" : 19012
		},
		{
			"uuid" : "b82d3701-080c-c545-8c24-2dd2cf99a158",
			"name" : "19013",
			"_clazz" : "TwkSegment",
			"brick" : "FRONT",
			"from" : 1018,
			"face" : "front",
			"tags" : [
				"P13"
			],
			"type" : "panel",
			"to" : 1013,
			"number" : 19013
		},
		{
			"uuid" : "24d060a6-cf99-414d-92cb-28dc97bbd188",
			"name" : "19014",
			"_clazz" : "TwkSegment",
			"brick" : "LEFT",
			"from" : 1019,
			"face" : "left",
			"tags" : [
				"P13"
			],
			"type" : "panel",
			"to" : 1014,
			"number" : 19014
		},
		{
			"uuid" : "4e05458b-b419-d04b-8297-9f52b6a259d7",
			"name" : "19015",
			"_clazz" : "TwkSegment",
			"brick" : "BACK",
			"from" : 1020,
			"face" : "back",
			"tags" : [
				"P13"
			],
			"type" : "panel",
			"to" : 1015,
			"number" : 19015
		},
		{
			"uuid" : "5577cc52-1479-1f49-a379-faa2765573df",
			"name" : "19016",
			"_clazz" : "TwkSegment",
			"brick" : "RIGHT",
			"from" : 1017,
			"face" : "right",
			"tags" : [
				"P13"
			],
			"type" : "panel",
			"to" : 1016,
			"number" : 19016
		},
		{
			"uuid" : "0c12785a-c45a-ad41-afa4-ee1e5633efb2",
			"name" : "19017",
			"_clazz" : "TwkSegment",
			"brick" : "FRONT",
			"from" : 1077,
			"face" : "front",
			"tags" : [
				"P13"
			],
			"type" : "panel",
			"to" : 1017,
			"number" : 19017
		},
		{
			"uuid" : "06d0e650-6aab-b044-91d6-5a96595ce2c8",
			"name" : "19018",
			"_clazz" : "TwkSegment",
			"brick" : "FRONT",
			"from" : 1022,
			"face" : "front",
			"tags" : [
				"P13"
			],
			"type" : "panel",
			"to" : 1077,
			"number" : 19018
		},
		{
			"uuid" : "3a34d168-5bff-434e-9ad4-1425fb0f7ef7",
			"name" : "19019",
			"_clazz" : "TwkSegment",
			"brick" : "FRONT",
			"from" : 1077,
			"face" : "front",
			"tags" : [
				"P13"
			],
			"type" : "panel",
			"to" : 1018,
			"number" : 19019
		},
		{
			"uuid" : "1dc0e66f-1713-1e4e-baf8-50b99562e7b6",
			"name" : "19020",
			"_clazz" : "TwkSegment",
			"brick" : "FRONT",
			"from" : 1021,
			"face" : "front",
			"tags" : [
				"P13"
			],
			"type" : "panel",
			"to" : 1077,
			"number" : 19020
		},
		{
			"uuid" : "d5fcb0e5-c3e2-e94e-89b2-129b434eff6c",
			"name" : "19021",
			"_clazz" : "TwkSegment",
			"brick" : "LEFT",
			"from" : 1078,
			"face" : "left",
			"tags" : [
				"P13"
			],
			"type" : "panel",
			"to" : 1018,
			"number" : 19021
		},
		{
			"uuid" : "26d68665-fa86-0644-a649-2feb2eb318ed",
			"name" : "19022",
			"_clazz" : "TwkSegment",
			"brick" : "LEFT",
			"from" : 1023,
			"face" : "left",
			"tags" : [
				"P13"
			],
			"type" : "panel",
			"to" : 1078,
			"number" : 19022
		},
		{
			"uuid" : "c7b07ce5-a909-664a-8527-2fb0656b7b7d",
			"name" : "19023",
			"_clazz" : "TwkSegment",
			"brick" : "LEFT",
			"from" : 1078,
			"face" : "left",
			"tags" : [
				"P13"
			],
			"type" : "panel",
			"to" : 1019,
			"number" : 19023
		},
		{
			"uuid" : "41ce4e7b-9a91-dc43-9fb2-7f312e351dce",
			"name" : "19024",
			"_clazz" : "TwkSegment",
			"brick" : "LEFT",
			"from" : 1022,
			"face" : "left",
			"tags" : [
				"P13"
			],
			"type" : "panel",
			"to" : 1078,
			"number" : 19024
		},
		{
			"uuid" : "d280ade2-4a20-fa48-bd05-e5f0faa1fe42",
			"name" : "19025",
			"_clazz" : "TwkSegment",
			"brick" : "BACK",
			"from" : 1079,
			"face" : "back",
			"tags" : [
				"P13"
			],
			"type" : "panel",
			"to" : 1019,
			"number" : 19025
		},
		{
			"uuid" : "b069e678-1ed1-2041-a5a2-ccca84dd7f7d",
			"name" : "19026",
			"_clazz" : "TwkSegment",
			"brick" : "BACK",
			"from" : 1024,
			"face" : "back",
			"tags" : [
				"P13"
			],
			"type" : "panel",
			"to" : 1079,
			"number" : 19026
		},
		{
			"uuid" : "1f9cc25b-f531-b742-90a3-02d37cc5f032",
			"name" : "19027",
			"_clazz" : "TwkSegment",
			"brick" : "BACK",
			"from" : 1079,
			"face" : "back",
			"tags" : [
				"P13"
			],
			"type" : "panel",
			"to" : 1020,
			"number" : 19027
		},
		{
			"uuid" : "ed72f535-4a75-fd4c-bd3c-f6520b410242",
			"name" : "19028",
			"_clazz" : "TwkSegment",
			"brick" : "BACK",
			"from" : 1023,
			"face" : "back",
			"tags" : [
				"P13"
			],
			"type" : "panel",
			"to" : 1079,
			"number" : 19028
		},
		{
			"uuid" : "64bcab3d-ab25-9744-ad80-247e6245dec8",
			"name" : "19029",
			"_clazz" : "TwkSegment",
			"brick" : "RIGHT",
			"from" : 1080,
			"face" : "right",
			"tags" : [
				"P13"
			],
			"type" : "panel",
			"to" : 1020,
			"number" : 19029
		},
		{
			"uuid" : "7e9bd876-f04f-e741-b0c9-98d7d4847a26",
			"name" : "19030",
			"_clazz" : "TwkSegment",
			"brick" : "RIGHT",
			"from" : 1021,
			"face" : "right",
			"tags" : [
				"P13"
			],
			"type" : "panel",
			"to" : 1080,
			"number" : 19030
		},
		{
			"uuid" : "01687769-3e5d-cb41-885f-5673fcfa1583",
			"name" : "19031",
			"_clazz" : "TwkSegment",
			"brick" : "RIGHT",
			"from" : 1080,
			"face" : "right",
			"tags" : [
				"P13"
			],
			"type" : "panel",
			"to" : 1017,
			"number" : 19031
		},
		{
			"uuid" : "e26c6aa5-20d4-e547-8ff1-c30fa0007d3a",
			"name" : "19032",
			"_clazz" : "TwkSegment",
			"brick" : "RIGHT",
			"from" : 1024,
			"face" : "right",
			"tags" : [
				"P13"
			],
			"type" : "panel",
			"to" : 1080,
			"number" : 19032
		},
		{
			"uuid" : "09dbfbac-de66-9a42-b526-56fffddcbb78",
			"name" : "19033",
			"_clazz" : "TwkSegment",
			"brick" : "FRONT",
			"from" : 1081,
			"face" : "front",
			"tags" : [
				"P13"
			],
			"type" : "panel",
			"to" : 1021,
			"number" : 19033
		},
		{
			"uuid" : "b3d6cee0-a663-ef4c-9c02-e55c4f4be017",
			"name" : "19034",
			"_clazz" : "TwkSegment",
			"brick" : "FRONT",
			"from" : 1026,
			"face" : "front",
			"tags" : [
				"P13"
			],
			"type" : "panel",
			"to" : 1081,
			"number" : 19034
		},
		{
			"uuid" : "47759265-5f6f-6549-b5cf-1d900fadcb44",
			"name" : "19035",
			"_clazz" : "TwkSegment",
			"brick" : "FRONT",
			"from" : 1081,
			"face" : "front",
			"tags" : [
				"P13"
			],
			"type" : "panel",
			"to" : 1022,
			"number" : 19035
		},
		{
			"uuid" : "7ec398a6-78ba-1b4b-b59e-a15fde7c818b",
			"name" : "19036",
			"_clazz" : "TwkSegment",
			"brick" : "FRONT",
			"from" : 1025,
			"face" : "front",
			"tags" : [
				"P13"
			],
			"type" : "panel",
			"to" : 1081,
			"number" : 19036
		},
		{
			"uuid" : "c765c073-8132-194b-a231-cb4f3c53ee48",
			"name" : "19037",
			"_clazz" : "TwkSegment",
			"brick" : "LEFT",
			"from" : 1082,
			"face" : "left",
			"tags" : [
				"P13"
			],
			"type" : "panel",
			"to" : 1022,
			"number" : 19037
		},
		{
			"uuid" : "86771bad-825b-9a43-a400-6217538d034b",
			"name" : "19038",
			"_clazz" : "TwkSegment",
			"brick" : "LEFT",
			"from" : 1027,
			"face" : "left",
			"tags" : [
				"P13"
			],
			"type" : "panel",
			"to" : 1082,
			"number" : 19038
		},
		{
			"uuid" : "d43308a8-5222-3540-8495-8054cfad226c",
			"name" : "19039",
			"_clazz" : "TwkSegment",
			"brick" : "LEFT",
			"from" : 1082,
			"face" : "left",
			"tags" : [
				"P13"
			],
			"type" : "panel",
			"to" : 1023,
			"number" : 19039
		},
		{
			"uuid" : "916bca95-c184-5144-b731-f106a42122e0",
			"name" : "19040",
			"_clazz" : "TwkSegment",
			"brick" : "LEFT",
			"from" : 1026,
			"face" : "left",
			"tags" : [
				"P13"
			],
			"type" : "panel",
			"to" : 1082,
			"number" : 19040
		},
		{
			"uuid" : "c1f13eb9-98aa-314d-af37-656056a16216",
			"name" : "19041",
			"_clazz" : "TwkSegment",
			"brick" : "BACK",
			"from" : 1083,
			"face" : "back",
			"tags" : [
				"P13"
			],
			"type" : "panel",
			"to" : 1023,
			"number" : 19041
		},
		{
			"uuid" : "89897010-c616-6646-b8ff-64830d7d3284",
			"name" : "19042",
			"_clazz" : "TwkSegment",
			"brick" : "BACK",
			"from" : 1028,
			"face" : "back",
			"tags" : [
				"P13"
			],
			"type" : "panel",
			"to" : 1083,
			"number" : 19042
		},
		{
			"uuid" : "83cb2aca-793f-924c-9a0d-7618a605c091",
			"name" : "19043",
			"_clazz" : "TwkSegment",
			"brick" : "BACK",
			"from" : 1083,
			"face" : "back",
			"tags" : [
				"P13"
			],
			"type" : "panel",
			"to" : 1024,
			"number" : 19043
		},
		{
			"uuid" : "a6b8f9ad-4c1b-6249-9205-1b3634488965",
			"name" : "19044",
			"_clazz" : "TwkSegment",
			"brick" : "BACK",
			"from" : 1027,
			"face" : "back",
			"tags" : [
				"P13"
			],
			"type" : "panel",
			"to" : 1083,
			"number" : 19044
		},
		{
			"uuid" : "30704e92-cde7-a749-a8d8-1ef8848b8d55",
			"name" : "19045",
			"_clazz" : "TwkSegment",
			"brick" : "RIGHT",
			"from" : 1084,
			"face" : "right",
			"tags" : [
				"P13"
			],
			"type" : "panel",
			"to" : 1024,
			"number" : 19045
		},
		{
			"uuid" : "ad2010a6-9480-3846-8de4-525332b7b34d",
			"name" : "19046",
			"_clazz" : "TwkSegment",
			"brick" : "RIGHT",
			"from" : 1025,
			"face" : "right",
			"tags" : [
				"P13"
			],
			"type" : "panel",
			"to" : 1084,
			"number" : 19046
		},
		{
			"uuid" : "68ace925-7836-9d45-8fc9-7e19f9f50186",
			"name" : "19047",
			"_clazz" : "TwkSegment",
			"brick" : "RIGHT",
			"from" : 1084,
			"face" : "right",
			"tags" : [
				"P13"
			],
			"type" : "panel",
			"to" : 1021,
			"number" : 19047
		},
		{
			"uuid" : "804437c4-0d65-ef41-b368-19d31efb5b71",
			"name" : "19048",
			"_clazz" : "TwkSegment",
			"brick" : "RIGHT",
			"from" : 1028,
			"face" : "right",
			"tags" : [
				"P13"
			],
			"type" : "panel",
			"to" : 1084,
			"number" : 19048
		},
		{
			"uuid" : "5cfe9c02-0141-db44-b43f-79d5ca2a9d4c",
			"name" : "19049",
			"_clazz" : "TwkSegment",
			"brick" : "FRONT",
			"from" : 1085,
			"face" : "front",
			"tags" : [
				"P13"
			],
			"type" : "panel",
			"to" : 1025,
			"number" : 19049
		},
		{
			"uuid" : "1d7adc98-0d32-4643-b827-b7e3b295ce91",
			"name" : "19050",
			"_clazz" : "TwkSegment",
			"brick" : "FRONT",
			"from" : 1034,
			"face" : "front",
			"tags" : [
				"P13"
			],
			"type" : "panel",
			"to" : 1085,
			"number" : 19050
		},
		{
			"uuid" : "44c6a50c-1b8b-4843-8610-ccc25a26fd22",
			"name" : "19051",
			"_clazz" : "TwkSegment",
			"brick" : "FRONT",
			"from" : 1085,
			"face" : "front",
			"tags" : [
				"P13"
			],
			"type" : "panel",
			"to" : 1026,
			"number" : 19051
		},
		{
			"uuid" : "8e843af8-964a-d34a-9ec4-08dac390c9ae",
			"name" : "19052",
			"_clazz" : "TwkSegment",
			"brick" : "FRONT",
			"from" : 1033,
			"face" : "front",
			"tags" : [
				"P13"
			],
			"type" : "panel",
			"to" : 1085,
			"number" : 19052
		},
		{
			"uuid" : "16cf0029-379b-5041-822f-c20bc9be53c1",
			"name" : "19053",
			"_clazz" : "TwkSegment",
			"brick" : "LEFT",
			"from" : 1086,
			"face" : "left",
			"tags" : [
				"P13"
			],
			"type" : "panel",
			"to" : 1026,
			"number" : 19053
		},
		{
			"uuid" : "16a4b0ea-d6e8-7b47-ab0a-f1b64c54bfb5",
			"name" : "19054",
			"_clazz" : "TwkSegment",
			"brick" : "LEFT",
			"from" : 1035,
			"face" : "left",
			"tags" : [
				"P13"
			],
			"type" : "panel",
			"to" : 1086,
			"number" : 19054
		},
		{
			"uuid" : "2546f0d9-62ec-8b45-8d31-8bd22def6b38",
			"name" : "19055",
			"_clazz" : "TwkSegment",
			"brick" : "LEFT",
			"from" : 1086,
			"face" : "left",
			"tags" : [
				"P13"
			],
			"type" : "panel",
			"to" : 1027,
			"number" : 19055
		},
		{
			"uuid" : "a365ad96-df03-9047-9f61-e1f099de0f2f",
			"name" : "19056",
			"_clazz" : "TwkSegment",
			"brick" : "LEFT",
			"from" : 1034,
			"face" : "left",
			"tags" : [
				"P13"
			],
			"type" : "panel",
			"to" : 1086,
			"number" : 19056
		},
		{
			"uuid" : "7bc110a8-b200-6147-a23f-25a233cf5ed0",
			"name" : "19057",
			"_clazz" : "TwkSegment",
			"brick" : "BACK",
			"from" : 1087,
			"face" : "back",
			"tags" : [
				"P13"
			],
			"type" : "panel",
			"to" : 1027,
			"number" : 19057
		},
		{
			"uuid" : "40c4adfc-b0a9-ab48-94e2-3b2fa355771d",
			"name" : "19058",
			"_clazz" : "TwkSegment",
			"brick" : "BACK",
			"from" : 1036,
			"face" : "back",
			"tags" : [
				"P13"
			],
			"type" : "panel",
			"to" : 1087,
			"number" : 19058
		},
		{
			"uuid" : "cad84495-3ee8-7b40-a2ee-d04970159841",
			"name" : "19059",
			"_clazz" : "TwkSegment",
			"brick" : "BACK",
			"from" : 1087,
			"face" : "back",
			"tags" : [
				"P13"
			],
			"type" : "panel",
			"to" : 1028,
			"number" : 19059
		},
		{
			"uuid" : "e04d4b53-dd40-2f45-b13e-da5b72217df1",
			"name" : "19060",
			"_clazz" : "TwkSegment",
			"brick" : "BACK",
			"from" : 1035,
			"face" : "back",
			"tags" : [
				"P13"
			],
			"type" : "panel",
			"to" : 1087,
			"number" : 19060
		},
		{
			"uuid" : "abbf7359-419e-084b-bbf8-63b182bcd10f",
			"name" : "19061",
			"_clazz" : "TwkSegment",
			"brick" : "RIGHT",
			"from" : 1088,
			"face" : "right",
			"tags" : [
				"P13"
			],
			"type" : "panel",
			"to" : 1028,
			"number" : 19061
		},
		{
			"uuid" : "34e20b4e-58e0-df40-a6f1-49c7d81226fb",
			"name" : "19062",
			"_clazz" : "TwkSegment",
			"brick" : "RIGHT",
			"from" : 1033,
			"face" : "right",
			"tags" : [
				"P13"
			],
			"type" : "panel",
			"to" : 1088,
			"number" : 19062
		},
		{
			"uuid" : "b6c35853-9884-704b-b314-7c453b4a8c3f",
			"name" : "19063",
			"_clazz" : "TwkSegment",
			"brick" : "RIGHT",
			"from" : 1088,
			"face" : "right",
			"tags" : [
				"P13"
			],
			"type" : "panel",
			"to" : 1025,
			"number" : 19063
		},
		{
			"uuid" : "4ffc106b-a3c3-284d-8c1d-e80c1c7530ac",
			"name" : "19064",
			"_clazz" : "TwkSegment",
			"brick" : "RIGHT",
			"from" : 1036,
			"face" : "right",
			"tags" : [
				"P13"
			],
			"type" : "panel",
			"to" : 1088,
			"number" : 19064
		},
		{
			"uuid" : "5b6f79cb-21ba-7544-ac57-69ad28ee9f92",
			"name" : "19065",
			"_clazz" : "TwkSegment",
			"brick" : "FRONT",
			"from" : 1089,
			"face" : "front",
			"tags" : [
				"P13"
			],
			"type" : "panel",
			"to" : 1033,
			"number" : 19065
		},
		{
			"uuid" : "1adf992b-6992-e744-8505-f136deb266c5",
			"name" : "19066",
			"_clazz" : "TwkSegment",
			"brick" : "FRONT",
			"from" : 1042,
			"face" : "front",
			"tags" : [
				"P13"
			],
			"type" : "panel",
			"to" : 1089,
			"number" : 19066
		},
		{
			"uuid" : "162023e2-9199-7f4a-bc95-b78f939c8908",
			"name" : "19067",
			"_clazz" : "TwkSegment",
			"brick" : "FRONT",
			"from" : 1089,
			"face" : "front",
			"tags" : [
				"P13"
			],
			"type" : "panel",
			"to" : 1034,
			"number" : 19067
		},
		{
			"uuid" : "a61039f3-e1ec-c54e-b62e-f3593f11035d",
			"name" : "19068",
			"_clazz" : "TwkSegment",
			"brick" : "FRONT",
			"from" : 1041,
			"face" : "front",
			"tags" : [
				"P13"
			],
			"type" : "panel",
			"to" : 1089,
			"number" : 19068
		},
		{
			"uuid" : "35f78929-3fdf-ee40-8ebc-b8c274e8eda3",
			"name" : "19069",
			"_clazz" : "TwkSegment",
			"brick" : "LEFT",
			"from" : 1090,
			"face" : "left",
			"tags" : [
				"P13"
			],
			"type" : "panel",
			"to" : 1034,
			"number" : 19069
		},
		{
			"uuid" : "96ef4c86-7662-4849-8a1d-bbadf85aec79",
			"name" : "19070",
			"_clazz" : "TwkSegment",
			"brick" : "LEFT",
			"from" : 1043,
			"face" : "left",
			"tags" : [
				"P13"
			],
			"type" : "panel",
			"to" : 1090,
			"number" : 19070
		},
		{
			"uuid" : "647fa1aa-7302-ad47-a1f2-4459353506d5",
			"name" : "19071",
			"_clazz" : "TwkSegment",
			"brick" : "LEFT",
			"from" : 1090,
			"face" : "left",
			"tags" : [
				"P13"
			],
			"type" : "panel",
			"to" : 1035,
			"number" : 19071
		},
		{
			"uuid" : "b8d195f8-a6c2-3c4d-b2f5-68f25890d8f4",
			"name" : "19072",
			"_clazz" : "TwkSegment",
			"brick" : "LEFT",
			"from" : 1042,
			"face" : "left",
			"tags" : [
				"P13"
			],
			"type" : "panel",
			"to" : 1090,
			"number" : 19072
		},
		{
			"uuid" : "a4178fd8-0894-154d-8b24-efa1d25b0361",
			"name" : "19073",
			"_clazz" : "TwkSegment",
			"brick" : "BACK",
			"from" : 1091,
			"face" : "back",
			"tags" : [
				"P13"
			],
			"type" : "panel",
			"to" : 1035,
			"number" : 19073
		},
		{
			"uuid" : "034054b2-8f7d-6a46-81ba-13a49643ca63",
			"name" : "19074",
			"_clazz" : "TwkSegment",
			"brick" : "BACK",
			"from" : 1044,
			"face" : "back",
			"tags" : [
				"P13"
			],
			"type" : "panel",
			"to" : 1091,
			"number" : 19074
		},
		{
			"uuid" : "dec7772e-9af1-3e4b-a676-8bc9826762a0",
			"name" : "19075",
			"_clazz" : "TwkSegment",
			"brick" : "BACK",
			"from" : 1091,
			"face" : "back",
			"tags" : [
				"P13"
			],
			"type" : "panel",
			"to" : 1036,
			"number" : 19075
		},
		{
			"uuid" : "ee43fbd1-1d5f-804f-a3ad-25a6f40302b3",
			"name" : "19076",
			"_clazz" : "TwkSegment",
			"brick" : "BACK",
			"from" : 1043,
			"face" : "back",
			"tags" : [
				"P13"
			],
			"type" : "panel",
			"to" : 1091,
			"number" : 19076
		},
		{
			"uuid" : "b6b544f3-9c63-e247-a3bd-06980e1374e3",
			"name" : "19077",
			"_clazz" : "TwkSegment",
			"brick" : "RIGHT",
			"from" : 1092,
			"face" : "right",
			"tags" : [
				"P13"
			],
			"type" : "panel",
			"to" : 1036,
			"number" : 19077
		},
		{
			"uuid" : "02506f50-4e6d-b645-9ccd-cc1e12266915",
			"name" : "19078",
			"_clazz" : "TwkSegment",
			"brick" : "RIGHT",
			"from" : 1041,
			"face" : "right",
			"tags" : [
				"P13"
			],
			"type" : "panel",
			"to" : 1092,
			"number" : 19078
		},
		{
			"uuid" : "d2e776b3-df5a-024d-842f-38356c99e6c8",
			"name" : "19079",
			"_clazz" : "TwkSegment",
			"brick" : "RIGHT",
			"from" : 1092,
			"face" : "right",
			"tags" : [
				"P13"
			],
			"type" : "panel",
			"to" : 1033,
			"number" : 19079
		},
		{
			"uuid" : "dac6b454-9df3-1b46-9e6c-a24fca7f083d",
			"name" : "19080",
			"_clazz" : "TwkSegment",
			"brick" : "RIGHT",
			"from" : 1044,
			"face" : "right",
			"tags" : [
				"P13"
			],
			"type" : "panel",
			"to" : 1092,
			"number" : 19080
		},
		{
			"uuid" : "4baddb94-146e-f546-9bfb-ccd95c568ca5",
			"name" : "19081",
			"_clazz" : "TwkSegment",
			"brick" : "FRONT",
			"from" : 1093,
			"face" : "front",
			"tags" : [
				"P13"
			],
			"type" : "panel",
			"to" : 1041,
			"number" : 19081
		},
		{
			"uuid" : "ba9e882a-e1e7-eb45-b1ae-f00f7ed87ea8",
			"name" : "19082",
			"_clazz" : "TwkSegment",
			"brick" : "FRONT",
			"from" : 1050,
			"face" : "front",
			"tags" : [
				"P13"
			],
			"type" : "panel",
			"to" : 1093,
			"number" : 19082
		},
		{
			"uuid" : "7c577b20-638c-a140-9ab8-36e9956ca969",
			"name" : "19083",
			"_clazz" : "TwkSegment",
			"brick" : "FRONT",
			"from" : 1093,
			"face" : "front",
			"tags" : [
				"P13"
			],
			"type" : "panel",
			"to" : 1042,
			"number" : 19083
		},
		{
			"uuid" : "921ca6f1-313c-bf42-b7eb-c1ea64dc6deb",
			"name" : "19084",
			"_clazz" : "TwkSegment",
			"brick" : "FRONT",
			"from" : 1049,
			"face" : "front",
			"tags" : [
				"P13"
			],
			"type" : "panel",
			"to" : 1093,
			"number" : 19084
		},
		{
			"uuid" : "0bd1ace4-58f9-d34a-a799-783e0e6c127c",
			"name" : "19085",
			"_clazz" : "TwkSegment",
			"brick" : "LEFT",
			"from" : 1094,
			"face" : "left",
			"tags" : [
				"P13"
			],
			"type" : "panel",
			"to" : 1042,
			"number" : 19085
		},
		{
			"uuid" : "68524e09-3ebb-7145-ad1e-f2169383ee3c",
			"name" : "19086",
			"_clazz" : "TwkSegment",
			"brick" : "LEFT",
			"from" : 1051,
			"face" : "left",
			"tags" : [
				"P13"
			],
			"type" : "panel",
			"to" : 1094,
			"number" : 19086
		},
		{
			"uuid" : "34681dfa-a50b-6d41-83f0-62338cb137ad",
			"name" : "19087",
			"_clazz" : "TwkSegment",
			"brick" : "LEFT",
			"from" : 1094,
			"face" : "left",
			"tags" : [
				"P13"
			],
			"type" : "panel",
			"to" : 1043,
			"number" : 19087
		},
		{
			"uuid" : "f1470020-1655-264c-8786-4b0471b7386f",
			"name" : "19088",
			"_clazz" : "TwkSegment",
			"brick" : "LEFT",
			"from" : 1050,
			"face" : "left",
			"tags" : [
				"P13"
			],
			"type" : "panel",
			"to" : 1094,
			"number" : 19088
		},
		{
			"uuid" : "657569cb-bdd3-4f47-a772-f888dd0329bb",
			"name" : "19089",
			"_clazz" : "TwkSegment",
			"brick" : "BACK",
			"from" : 1095,
			"face" : "back",
			"tags" : [
				"P13"
			],
			"type" : "panel",
			"to" : 1043,
			"number" : 19089
		},
		{
			"uuid" : "7120a6fc-eb51-5947-812d-d9008b934d47",
			"name" : "19090",
			"_clazz" : "TwkSegment",
			"brick" : "BACK",
			"from" : 1052,
			"face" : "back",
			"tags" : [
				"P13"
			],
			"type" : "panel",
			"to" : 1095,
			"number" : 19090
		},
		{
			"uuid" : "43f7caf6-e25e-234b-b693-d15dc4924faf",
			"name" : "19091",
			"_clazz" : "TwkSegment",
			"brick" : "BACK",
			"from" : 1095,
			"face" : "back",
			"tags" : [
				"P13"
			],
			"type" : "panel",
			"to" : 1044,
			"number" : 19091
		},
		{
			"uuid" : "51f4e9e6-e579-d047-9b7b-bc5d2661c322",
			"name" : "19092",
			"_clazz" : "TwkSegment",
			"brick" : "BACK",
			"from" : 1051,
			"face" : "back",
			"tags" : [
				"P13"
			],
			"type" : "panel",
			"to" : 1095,
			"number" : 19092
		},
		{
			"uuid" : "9b3e6bba-1620-3440-8cc5-61b0b9ea0c6a",
			"name" : "19093",
			"_clazz" : "TwkSegment",
			"brick" : "RIGHT",
			"from" : 1096,
			"face" : "right",
			"tags" : [
				"P13"
			],
			"type" : "panel",
			"to" : 1044,
			"number" : 19093
		},
		{
			"uuid" : "b4e3abdc-9aab-b646-a4c9-bf071ad69d75",
			"name" : "19094",
			"_clazz" : "TwkSegment",
			"brick" : "RIGHT",
			"from" : 1049,
			"face" : "right",
			"tags" : [
				"P13"
			],
			"type" : "panel",
			"to" : 1096,
			"number" : 19094
		},
		{
			"uuid" : "bb156f7f-70fd-334e-a3db-409c692c55d4",
			"name" : "19095",
			"_clazz" : "TwkSegment",
			"brick" : "RIGHT",
			"from" : 1096,
			"face" : "right",
			"tags" : [
				"P13"
			],
			"type" : "panel",
			"to" : 1041,
			"number" : 19095
		},
		{
			"uuid" : "f3f77842-b656-504c-9e70-07846ed0a3c4",
			"name" : "19096",
			"_clazz" : "TwkSegment",
			"brick" : "RIGHT",
			"from" : 1052,
			"face" : "right",
			"tags" : [
				"P13"
			],
			"type" : "panel",
			"to" : 1096,
			"number" : 19096
		},
		{
			"uuid" : "f5134da0-04c4-0c42-b093-651828d06102",
			"name" : "19097",
			"_clazz" : "TwkSegment",
			"brick" : "FRONT",
			"from" : 1097,
			"face" : "front",
			"tags" : [
				"P13"
			],
			"type" : "panel",
			"to" : 1049,
			"number" : 19097
		},
		{
			"uuid" : "fd5cb579-2241-4f47-999b-c6aa87d7cc06",
			"name" : "19098",
			"_clazz" : "TwkSegment",
			"brick" : "FRONT",
			"from" : 1050,
			"face" : "front",
			"tags" : [
				"P13"
			],
			"type" : "panel",
			"to" : 1097,
			"number" : 19098
		},
		{
			"uuid" : "f15bb413-86eb-5147-83ad-3bda6feaa161",
			"name" : "19099",
			"_clazz" : "TwkSegment",
			"brick" : "LEFT",
			"from" : 1098,
			"face" : "left",
			"tags" : [
				"P13"
			],
			"type" : "panel",
			"to" : 1050,
			"number" : 19099
		},
		{
			"uuid" : "f26d2a1f-49a6-4643-b2a3-b10b68e15790",
			"name" : "19100",
			"_clazz" : "TwkSegment",
			"brick" : "LEFT",
			"from" : 1051,
			"face" : "left",
			"tags" : [
				"P13"
			],
			"type" : "panel",
			"to" : 1098,
			"number" : 19100
		},
		{
			"uuid" : "bdf33a46-5c4a-f143-8e55-37859e19cc52",
			"name" : "19101",
			"_clazz" : "TwkSegment",
			"brick" : "BACK",
			"from" : 1099,
			"face" : "back",
			"tags" : [
				"P13"
			],
			"type" : "panel",
			"to" : 1051,
			"number" : 19101
		},
		{
			"uuid" : "2c840a8a-7851-bd40-9424-53a1235d76ab",
			"name" : "19102",
			"_clazz" : "TwkSegment",
			"brick" : "BACK",
			"from" : 1052,
			"face" : "back",
			"tags" : [
				"P13"
			],
			"type" : "panel",
			"to" : 1099,
			"number" : 19102
		},
		{
			"uuid" : "e1507152-1fe2-5142-8f19-80a4eba24734",
			"name" : "19103",
			"_clazz" : "TwkSegment",
			"brick" : "RIGHT",
			"from" : 1100,
			"face" : "right",
			"tags" : [
				"P13"
			],
			"type" : "panel",
			"to" : 1052,
			"number" : 19103
		},
		{
			"uuid" : "1f57805d-cb72-cb45-b319-715542fd9e40",
			"name" : "19104",
			"_clazz" : "TwkSegment",
			"brick" : "RIGHT",
			"from" : 1049,
			"face" : "right",
			"tags" : [
				"P13"
			],
			"type" : "panel",
			"to" : 1100,
			"number" : 19104
		},
		{
			"uuid" : "6ef5da06-0097-e64e-adcc-d7936af2efd5",
			"name" : "19105",
			"_clazz" : "TwkSegment",
			"brick" : "FRONT",
			"from" : 1058,
			"face" : "front",
			"tags" : [
				"P13"
			],
			"type" : "panel",
			"to" : 1097,
			"number" : 19105
		},
		{
			"uuid" : "03140cd9-73e1-0a42-ae77-98a208813e72",
			"name" : "19106",
			"_clazz" : "TwkSegment",
			"brick" : "FRONT",
			"from" : 1097,
			"face" : "front",
			"tags" : [
				"P13"
			],
			"type" : "panel",
			"to" : 1057,
			"number" : 19106
		},
		{
			"uuid" : "8cebf4a0-87e8-ad44-9606-f2df1734c8ae",
			"name" : "19107",
			"_clazz" : "TwkSegment",
			"brick" : "LEFT",
			"from" : 1059,
			"face" : "left",
			"tags" : [
				"P13"
			],
			"type" : "panel",
			"to" : 1098,
			"number" : 19107
		},
		{
			"uuid" : "74ac0f03-6473-3745-8338-f760e143ee6f",
			"name" : "19108",
			"_clazz" : "TwkSegment",
			"brick" : "LEFT",
			"from" : 1098,
			"face" : "left",
			"tags" : [
				"P13"
			],
			"type" : "panel",
			"to" : 1058,
			"number" : 19108
		},
		{
			"uuid" : "2333a8e3-5c2b-d549-815d-56a528ec2c10",
			"name" : "19109",
			"_clazz" : "TwkSegment",
			"brick" : "BACK",
			"from" : 1060,
			"face" : "back",
			"tags" : [
				"P13"
			],
			"type" : "panel",
			"to" : 1099,
			"number" : 19109
		},
		{
			"uuid" : "221892b5-84a3-ed42-a0b3-b50b9c5d89e1",
			"name" : "19110",
			"_clazz" : "TwkSegment",
			"brick" : "BACK",
			"from" : 1099,
			"face" : "back",
			"tags" : [
				"P13"
			],
			"type" : "panel",
			"to" : 1059,
			"number" : 19110
		},
		{
			"uuid" : "149eeec5-d10a-0d45-a3aa-ec1852972f39",
			"name" : "19111",
			"_clazz" : "TwkSegment",
			"brick" : "RIGHT",
			"from" : 1057,
			"face" : "right",
			"tags" : [
				"P13"
			],
			"type" : "panel",
			"to" : 1100,
			"number" : 19111
		},
		{
			"uuid" : "fa390469-8605-664f-b0f5-ddcaca280f3a",
			"name" : "19112",
			"_clazz" : "TwkSegment",
			"brick" : "RIGHT",
			"from" : 1100,
			"face" : "right",
			"tags" : [
				"P13"
			],
			"type" : "panel",
			"to" : 1060,
			"number" : 19112
		},
		{
			"uuid" : "f80a80b5-c334-f54e-80aa-fd1f61d4e2d9",
			"name" : "19113",
			"_clazz" : "TwkSegment",
			"brick" : "FRONT",
			"from" : 1101,
			"face" : "front",
			"tags" : [
				"P13"
			],
			"type" : "panel",
			"to" : 1057,
			"number" : 19113
		},
		{
			"uuid" : "a42982de-5f30-fe46-b266-8bac1256fb3a",
			"name" : "19114",
			"_clazz" : "TwkSegment",
			"brick" : "FRONT",
			"from" : 1066,
			"face" : "front",
			"tags" : [
				"P13"
			],
			"type" : "panel",
			"to" : 1101,
			"number" : 19114
		},
		{
			"uuid" : "df284d6f-c6bb-c247-a931-1b59c273d8c4",
			"name" : "19115",
			"_clazz" : "TwkSegment",
			"brick" : "FRONT",
			"from" : 1101,
			"face" : "front",
			"tags" : [
				"P13"
			],
			"type" : "panel",
			"to" : 1058,
			"number" : 19115
		},
		{
			"uuid" : "7f7dfefe-0133-ca40-8869-d8df62dd0208",
			"name" : "19116",
			"_clazz" : "TwkSegment",
			"brick" : "FRONT",
			"from" : 1065,
			"face" : "front",
			"tags" : [
				"P13"
			],
			"type" : "panel",
			"to" : 1101,
			"number" : 19116
		},
		{
			"uuid" : "c53bbbea-4cde-7c49-81f0-2259281b64e0",
			"name" : "19117",
			"_clazz" : "TwkSegment",
			"brick" : "LEFT",
			"from" : 1102,
			"face" : "left",
			"tags" : [
				"P13"
			],
			"type" : "panel",
			"to" : 1058,
			"number" : 19117
		},
		{
			"uuid" : "c7e262fa-fc07-3141-a2a7-9931d29f4ddb",
			"name" : "19118",
			"_clazz" : "TwkSegment",
			"brick" : "LEFT",
			"from" : 1067,
			"face" : "left",
			"tags" : [
				"P13"
			],
			"type" : "panel",
			"to" : 1102,
			"number" : 19118
		},
		{
			"uuid" : "2bfee33e-2275-a647-ae33-213d7cb51f2f",
			"name" : "19119",
			"_clazz" : "TwkSegment",
			"brick" : "LEFT",
			"from" : 1102,
			"face" : "left",
			"tags" : [
				"P13"
			],
			"type" : "panel",
			"to" : 1059,
			"number" : 19119
		},
		{
			"uuid" : "58dce327-2531-0f4b-ae42-24c27da2c45e",
			"name" : "19120",
			"_clazz" : "TwkSegment",
			"brick" : "LEFT",
			"from" : 1066,
			"face" : "left",
			"tags" : [
				"P13"
			],
			"type" : "panel",
			"to" : 1102,
			"number" : 19120
		},
		{
			"uuid" : "0a1b27bb-17fa-8f40-8490-daa3e3fee320",
			"name" : "19121",
			"_clazz" : "TwkSegment",
			"brick" : "BACK",
			"from" : 1103,
			"face" : "back",
			"tags" : [
				"P13"
			],
			"type" : "panel",
			"to" : 1059,
			"number" : 19121
		},
		{
			"uuid" : "8d86275c-2499-854a-aa44-b3d12e0a1ef9",
			"name" : "19122",
			"_clazz" : "TwkSegment",
			"brick" : "BACK",
			"from" : 1068,
			"face" : "back",
			"tags" : [
				"P13"
			],
			"type" : "panel",
			"to" : 1103,
			"number" : 19122
		},
		{
			"uuid" : "85cafd3a-0c81-1d4a-aad6-3ded7488527d",
			"name" : "19123",
			"_clazz" : "TwkSegment",
			"brick" : "BACK",
			"from" : 1103,
			"face" : "back",
			"tags" : [
				"P13"
			],
			"type" : "panel",
			"to" : 1060,
			"number" : 19123
		},
		{
			"uuid" : "aeae75b5-a187-a343-8f80-0adeb3dcda4e",
			"name" : "19124",
			"_clazz" : "TwkSegment",
			"brick" : "BACK",
			"from" : 1067,
			"face" : "back",
			"tags" : [
				"P13"
			],
			"type" : "panel",
			"to" : 1103,
			"number" : 19124
		},
		{
			"uuid" : "4096f5c0-de67-5942-9fe7-4db87e9b4708",
			"name" : "19125",
			"_clazz" : "TwkSegment",
			"brick" : "RIGHT",
			"from" : 1104,
			"face" : "right",
			"tags" : [
				"P13"
			],
			"type" : "panel",
			"to" : 1060,
			"number" : 19125
		},
		{
			"uuid" : "c169df67-874b-d142-9c7e-3a5f5c6b4b52",
			"name" : "19126",
			"_clazz" : "TwkSegment",
			"brick" : "RIGHT",
			"from" : 1065,
			"face" : "right",
			"tags" : [
				"P13"
			],
			"type" : "panel",
			"to" : 1104,
			"number" : 19126
		},
		{
			"uuid" : "5dd9ec90-0ecb-4d4e-87f7-ea3d86d946e0",
			"name" : "19127",
			"_clazz" : "TwkSegment",
			"brick" : "RIGHT",
			"from" : 1104,
			"face" : "right",
			"tags" : [
				"P13"
			],
			"type" : "panel",
			"to" : 1057,
			"number" : 19127
		},
		{
			"uuid" : "b7161fb7-8b00-1346-8b94-4d04eb7c5b86",
			"name" : "19128",
			"_clazz" : "TwkSegment",
			"brick" : "RIGHT",
			"from" : 1068,
			"face" : "right",
			"tags" : [
				"P13"
			],
			"type" : "panel",
			"to" : 1104,
			"number" : 19128
		},
		{
			"uuid" : "655323da-29ae-0542-8da8-8c6da44d1fac",
			"name" : "19129",
			"_clazz" : "TwkSegment",
			"brick" : "FRONT",
			"from" : 1105,
			"face" : "front",
			"tags" : [
				"P13"
			],
			"type" : "panel",
			"to" : 1065,
			"number" : 19129
		},
		{
			"uuid" : "a0aa66b6-7d05-7549-892d-417d8a813ca3",
			"name" : "19130",
			"_clazz" : "TwkSegment",
			"brick" : "FRONT",
			"from" : 1074,
			"face" : "front",
			"tags" : [
				"P13"
			],
			"type" : "panel",
			"to" : 1105,
			"number" : 19130
		},
		{
			"uuid" : "0707492c-9b1a-aa49-b756-90aff518fbdd",
			"name" : "19131",
			"_clazz" : "TwkSegment",
			"brick" : "FRONT",
			"from" : 1105,
			"face" : "front",
			"tags" : [
				"P13"
			],
			"type" : "panel",
			"to" : 1066,
			"number" : 19131
		},
		{
			"uuid" : "88b43565-caa7-7a40-a871-6ffa0b15bc48",
			"name" : "19132",
			"_clazz" : "TwkSegment",
			"brick" : "FRONT",
			"from" : 1073,
			"face" : "front",
			"tags" : [
				"P13"
			],
			"type" : "panel",
			"to" : 1105,
			"number" : 19132
		},
		{
			"uuid" : "afefe62e-0129-7545-9123-c1677a753795",
			"name" : "19133",
			"_clazz" : "TwkSegment",
			"brick" : "LEFT",
			"from" : 1106,
			"face" : "left",
			"tags" : [
				"P13"
			],
			"type" : "panel",
			"to" : 1066,
			"number" : 19133
		},
		{
			"uuid" : "94af33d3-2945-2d40-ba90-f0fe7053a548",
			"name" : "19134",
			"_clazz" : "TwkSegment",
			"brick" : "LEFT",
			"from" : 1075,
			"face" : "left",
			"tags" : [
				"P13"
			],
			"type" : "panel",
			"to" : 1106,
			"number" : 19134
		},
		{
			"uuid" : "b043d32a-2b0d-0b40-9b02-07a924fe3ec1",
			"name" : "19135",
			"_clazz" : "TwkSegment",
			"brick" : "LEFT",
			"from" : 1106,
			"face" : "left",
			"tags" : [
				"P13"
			],
			"type" : "panel",
			"to" : 1067,
			"number" : 19135
		},
		{
			"uuid" : "da251b19-bc18-0f4e-b912-aeba278bdd6a",
			"name" : "19136",
			"_clazz" : "TwkSegment",
			"brick" : "LEFT",
			"from" : 1074,
			"face" : "left",
			"tags" : [
				"P13"
			],
			"type" : "panel",
			"to" : 1106,
			"number" : 19136
		},
		{
			"uuid" : "19d2558b-e9f3-b04d-b5cb-d03fba4d9c89",
			"name" : "19137",
			"_clazz" : "TwkSegment",
			"brick" : "BACK",
			"from" : 1107,
			"face" : "back",
			"tags" : [
				"P13"
			],
			"type" : "panel",
			"to" : 1067,
			"number" : 19137
		},
		{
			"uuid" : "de46608d-18a3-7f4e-8fee-17410943e808",
			"name" : "19138",
			"_clazz" : "TwkSegment",
			"brick" : "BACK",
			"from" : 1076,
			"face" : "back",
			"tags" : [
				"P13"
			],
			"type" : "panel",
			"to" : 1107,
			"number" : 19138
		},
		{
			"uuid" : "f8b2d16e-5f2a-ad45-887a-b3d20a5dad5d",
			"name" : "19139",
			"_clazz" : "TwkSegment",
			"brick" : "BACK",
			"from" : 1107,
			"face" : "back",
			"tags" : [
				"P13"
			],
			"type" : "panel",
			"to" : 1068,
			"number" : 19139
		},
		{
			"uuid" : "1a4f65f5-ed5d-594f-95bc-205f9d0cfaf5",
			"name" : "19140",
			"_clazz" : "TwkSegment",
			"brick" : "BACK",
			"from" : 1075,
			"face" : "back",
			"tags" : [
				"P13"
			],
			"type" : "panel",
			"to" : 1107,
			"number" : 19140
		},
		{
			"uuid" : "a5eaac11-7788-164c-b444-264405bcf219",
			"name" : "19141",
			"_clazz" : "TwkSegment",
			"brick" : "RIGHT",
			"from" : 1108,
			"face" : "right",
			"tags" : [
				"P13"
			],
			"type" : "panel",
			"to" : 1068,
			"number" : 19141
		},
		{
			"uuid" : "4104c0d5-7a22-bc48-9a43-fbb98f6294e8",
			"name" : "19142",
			"_clazz" : "TwkSegment",
			"brick" : "RIGHT",
			"from" : 1073,
			"face" : "right",
			"tags" : [
				"P13"
			],
			"type" : "panel",
			"to" : 1108,
			"number" : 19142
		},
		{
			"uuid" : "7bd73676-99f2-284d-816d-9a1f994d45e4",
			"name" : "19143",
			"_clazz" : "TwkSegment",
			"brick" : "RIGHT",
			"from" : 1108,
			"face" : "right",
			"tags" : [
				"P13"
			],
			"type" : "panel",
			"to" : 1065,
			"number" : 19143
		},
		{
			"uuid" : "80924e58-2b82-9342-b974-cdcb4318587b",
			"name" : "19144",
			"_clazz" : "TwkSegment",
			"brick" : "RIGHT",
			"from" : 1076,
			"face" : "right",
			"tags" : [
				"P13"
			],
			"type" : "panel",
			"to" : 1108,
			"number" : 19144
		},
		{
			"number" : 11001,
			"tags" : [
				"P14"
			],
			"type" : "slope",
			"to" : 1205,
			"from" : 1201,
			"brick" : "P14",
			"name" : "11001",
			"uuid" : "ad6e5b9b-b197-cb40-b1c5-f8a8c4c4fe27",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 11002,
			"tags" : [
				"P14"
			],
			"type" : "slope",
			"to" : 1206,
			"from" : 1202,
			"brick" : "P14",
			"name" : "11002",
			"uuid" : "4844193b-447b-6849-a06b-12b37f54ffa1",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 11003,
			"tags" : [
				"P14"
			],
			"type" : "slope",
			"to" : 1207,
			"from" : 1203,
			"brick" : "P14",
			"name" : "11003",
			"uuid" : "dc602506-b9ae-3543-8574-6c9c7a7c2282",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 11004,
			"tags" : [
				"P14"
			],
			"type" : "slope",
			"to" : 1208,
			"from" : 1204,
			"brick" : "P14",
			"name" : "11004",
			"uuid" : "32b6d027-3ce2-7f4b-8eaa-b25f45511060",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 11005,
			"tags" : [
				"P14"
			],
			"type" : "slope",
			"to" : 1209,
			"from" : 1205,
			"brick" : "P14",
			"name" : "11005",
			"uuid" : "5a3a1bca-2d56-0b45-a58f-96cc26ce6dc9",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 11006,
			"tags" : [
				"P14"
			],
			"type" : "slope",
			"to" : 1210,
			"from" : 1206,
			"brick" : "P14",
			"name" : "11006",
			"uuid" : "f5d8b4e7-ecc9-5043-aaba-bb797f4873ee",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 11007,
			"tags" : [
				"P14"
			],
			"type" : "slope",
			"to" : 1211,
			"from" : 1207,
			"brick" : "P14",
			"name" : "11007",
			"uuid" : "aad9695e-2069-084b-8e15-adc87865e3e9",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 11008,
			"tags" : [
				"P14"
			],
			"type" : "slope",
			"to" : 1212,
			"from" : 1208,
			"brick" : "P14",
			"name" : "11008",
			"uuid" : "f6152330-6b73-9242-b4a1-67078eb835e7",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 11009,
			"tags" : [
				"P14"
			],
			"type" : "slope",
			"to" : 1213,
			"from" : 1209,
			"brick" : "P14",
			"name" : "11009",
			"uuid" : "b559a5c9-2cc6-5641-85aa-dc44aef1e322",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 11010,
			"tags" : [
				"P14"
			],
			"type" : "slope",
			"to" : 1214,
			"from" : 1210,
			"brick" : "P14",
			"name" : "11010",
			"uuid" : "b8e22be5-2e2f-e244-b8b1-57953cc5dbb7",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 11011,
			"tags" : [
				"P14"
			],
			"type" : "slope",
			"to" : 1215,
			"from" : 1211,
			"brick" : "P14",
			"name" : "11011",
			"uuid" : "edd3b185-e16c-4d4c-81c6-017e48bcb48b",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 11012,
			"tags" : [
				"P14"
			],
			"type" : "slope",
			"to" : 1216,
			"from" : 1212,
			"brick" : "P14",
			"name" : "11012",
			"uuid" : "95a50350-3816-2741-9f4a-e20e553705d5",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 11013,
			"tags" : [
				"P14"
			],
			"type" : "slope",
			"to" : 1217,
			"from" : 1213,
			"brick" : "P14",
			"name" : "11013",
			"uuid" : "7089bac9-2789-8440-94bf-4c0f5aa682c0",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 11014,
			"tags" : [
				"P14"
			],
			"type" : "slope",
			"to" : 1218,
			"from" : 1214,
			"brick" : "P14",
			"name" : "11014",
			"uuid" : "e2c76842-d51e-b940-b3f2-f5e0ee2a1b78",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 11015,
			"tags" : [
				"P14"
			],
			"type" : "slope",
			"to" : 1219,
			"from" : 1215,
			"brick" : "P14",
			"name" : "11015",
			"uuid" : "946dff58-0995-de43-bc88-1ae5f7db6cf9",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 11016,
			"tags" : [
				"P14"
			],
			"type" : "slope",
			"to" : 1220,
			"from" : 1216,
			"brick" : "P14",
			"name" : "11016",
			"uuid" : "558d54c4-c75d-5a4a-a397-7db4025e1700",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 11017,
			"tags" : [
				"P14"
			],
			"type" : "slope",
			"to" : 1221,
			"from" : 1217,
			"brick" : "P14",
			"name" : "11017",
			"uuid" : "e97c7580-e663-1b48-a3be-64379622a00d",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 11018,
			"tags" : [
				"P14"
			],
			"type" : "slope",
			"to" : 1222,
			"from" : 1218,
			"brick" : "P14",
			"name" : "11018",
			"uuid" : "ff012b00-a2e8-be4d-9628-1ea54a4d175f",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 11019,
			"tags" : [
				"P14"
			],
			"type" : "slope",
			"to" : 1223,
			"from" : 1219,
			"brick" : "P14",
			"name" : "11019",
			"uuid" : "072fd075-3a5f-e04b-bc2a-d605244abb3a",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 11020,
			"tags" : [
				"P14"
			],
			"type" : "slope",
			"to" : 1224,
			"from" : 1220,
			"brick" : "P14",
			"name" : "11020",
			"uuid" : "0708afff-6355-d246-af69-e278e46e7b76",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 11021,
			"tags" : [
				"P14"
			],
			"type" : "slope",
			"to" : 1225,
			"from" : 1221,
			"brick" : "P14",
			"name" : "11021",
			"uuid" : "11ff06ee-58f7-6045-837f-ac1d63f3dff3",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 11022,
			"tags" : [
				"P14"
			],
			"type" : "slope",
			"to" : 1226,
			"from" : 1222,
			"brick" : "P14",
			"name" : "11022",
			"uuid" : "a9fbca74-bab7-a448-be81-c5ae73ce30e1",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 11023,
			"tags" : [
				"P14"
			],
			"type" : "slope",
			"to" : 1227,
			"from" : 1223,
			"brick" : "P14",
			"name" : "11023",
			"uuid" : "b15367da-9d35-cf44-9a55-cb3bc0548325",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 11024,
			"tags" : [
				"P14"
			],
			"type" : "slope",
			"to" : 1228,
			"from" : 1224,
			"brick" : "P14",
			"name" : "11024",
			"uuid" : "5153b49f-9c5b-dc44-82cc-4faf391dea5e",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 11025,
			"tags" : [
				"P14"
			],
			"type" : "slope",
			"to" : 1229,
			"from" : 1225,
			"brick" : "P14",
			"name" : "11025",
			"uuid" : "4c638b4c-325d-044e-8d33-a3291c65d988",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 11026,
			"tags" : [
				"P14"
			],
			"type" : "slope",
			"to" : 1230,
			"from" : 1226,
			"brick" : "P14",
			"name" : "11026",
			"uuid" : "81676efd-72a5-4848-a67d-3924bd4c0f5e",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 11027,
			"tags" : [
				"P14"
			],
			"type" : "slope",
			"to" : 1231,
			"from" : 1227,
			"brick" : "P14",
			"name" : "11027",
			"uuid" : "ef70797d-09d2-6c4f-85a6-1859cd972897",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 11028,
			"tags" : [
				"P14"
			],
			"type" : "slope",
			"to" : 1232,
			"from" : 1228,
			"brick" : "P14",
			"name" : "11028",
			"uuid" : "61605870-9a26-0c4a-85dd-b6cbde6d9ee0",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 11029,
			"tags" : [
				"P14"
			],
			"type" : "slope",
			"to" : 1233,
			"from" : 1229,
			"brick" : "P14",
			"name" : "11029",
			"uuid" : "4d6bc8cb-1d75-d140-b2dc-6efa0a977a5d",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 11030,
			"tags" : [
				"P14"
			],
			"type" : "slope",
			"to" : 1234,
			"from" : 1230,
			"brick" : "P14",
			"name" : "11030",
			"uuid" : "72196e41-4af7-8041-b39b-75ff4c1b7c24",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 11031,
			"tags" : [
				"P14"
			],
			"type" : "slope",
			"to" : 1235,
			"from" : 1231,
			"brick" : "P14",
			"name" : "11031",
			"uuid" : "4eaf86cd-ed8c-8944-bbee-a4a1628c94ff",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 11032,
			"tags" : [
				"P14"
			],
			"type" : "slope",
			"to" : 1236,
			"from" : 1232,
			"brick" : "P14",
			"name" : "11032",
			"uuid" : "22c5b887-5dcc-3343-a8c4-2648b1cb554c",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 11033,
			"tags" : [
				"P14"
			],
			"type" : "slope",
			"to" : 1237,
			"from" : 1233,
			"brick" : "P14",
			"name" : "11033",
			"uuid" : "4e7f70be-82b4-8e4e-90de-7757fe5f435b",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 11034,
			"tags" : [
				"P14"
			],
			"type" : "slope",
			"to" : 1238,
			"from" : 1234,
			"brick" : "P14",
			"name" : "11034",
			"uuid" : "9d6fcd07-bfe7-ac42-a7b7-a5125b6b3618",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 11035,
			"tags" : [
				"P14"
			],
			"type" : "slope",
			"to" : 1239,
			"from" : 1235,
			"brick" : "P14",
			"name" : "11035",
			"uuid" : "984209e9-fe85-5843-a2b8-38ca46d900d6",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 11036,
			"tags" : [
				"P14"
			],
			"type" : "slope",
			"to" : 1240,
			"from" : 1236,
			"brick" : "P14",
			"name" : "11036",
			"uuid" : "c4278b00-7c6b-8941-8a2a-778c6668527e",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 11037,
			"tags" : [
				"P14"
			],
			"type" : "slope",
			"to" : 1241,
			"from" : 1237,
			"brick" : "P14",
			"name" : "11037",
			"uuid" : "8bfec165-9919-2a47-b7f8-bcff71cf20e7",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 11038,
			"tags" : [
				"P14"
			],
			"type" : "slope",
			"to" : 1242,
			"from" : 1238,
			"brick" : "P14",
			"name" : "11038",
			"uuid" : "3567369b-0884-be44-90e5-45e8f5e046a8",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 11039,
			"tags" : [
				"P14"
			],
			"type" : "slope",
			"to" : 1243,
			"from" : 1239,
			"brick" : "P14",
			"name" : "11039",
			"uuid" : "92d78617-7c7d-714f-a4fe-97a3830b2d8f",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 11040,
			"tags" : [
				"P14"
			],
			"type" : "slope",
			"to" : 1244,
			"from" : 1240,
			"brick" : "P14",
			"name" : "11040",
			"uuid" : "b3c9806a-d50c-8249-9868-305a45ff512d",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 11041,
			"tags" : [
				"P14"
			],
			"type" : "slope",
			"to" : 1245,
			"from" : 1241,
			"brick" : "P14",
			"name" : "11041",
			"uuid" : "b829cff5-2825-564f-b7dc-4271b1c44995",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 11042,
			"tags" : [
				"P14"
			],
			"type" : "slope",
			"to" : 1246,
			"from" : 1242,
			"brick" : "P14",
			"name" : "11042",
			"uuid" : "777216a4-7ceb-5944-90db-7e865f8f258c",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 11043,
			"tags" : [
				"P14"
			],
			"type" : "slope",
			"to" : 1247,
			"from" : 1243,
			"brick" : "P14",
			"name" : "11043",
			"uuid" : "ac58b6d1-fd82-594a-939c-0ac60845427c",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 11044,
			"tags" : [
				"P14"
			],
			"type" : "slope",
			"to" : 1248,
			"from" : 1244,
			"brick" : "P14",
			"name" : "11044",
			"uuid" : "6ed439b9-cadf-f24d-b883-7b4f4b0b7ff2",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 11045,
			"tags" : [
				"P14"
			],
			"type" : "slope",
			"to" : 1249,
			"from" : 1245,
			"brick" : "P14",
			"name" : "11045",
			"uuid" : "1921548f-614e-f642-b26d-bf9db216b6d4",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 11046,
			"tags" : [
				"P14"
			],
			"type" : "slope",
			"to" : 1250,
			"from" : 1246,
			"brick" : "P14",
			"name" : "11046",
			"uuid" : "c5f6aafc-4fd1-2847-9109-a2f62e92ad31",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 11047,
			"tags" : [
				"P14"
			],
			"type" : "slope",
			"to" : 1251,
			"from" : 1247,
			"brick" : "P14",
			"name" : "11047",
			"uuid" : "84f033f7-0df2-0743-bd2e-6069bc19acfd",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 11048,
			"tags" : [
				"P14"
			],
			"type" : "slope",
			"to" : 1252,
			"from" : 1248,
			"brick" : "P14",
			"name" : "11048",
			"uuid" : "9b3c3f49-10f7-cc4c-b4d6-bd42e03eb93c",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 11049,
			"tags" : [
				"P14"
			],
			"type" : "slope",
			"to" : 1253,
			"from" : 1249,
			"brick" : "P14",
			"name" : "11049",
			"uuid" : "196d02d4-53ca-554a-8428-c2a6b0cec56e",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 11050,
			"tags" : [
				"P14"
			],
			"type" : "slope",
			"to" : 1254,
			"from" : 1250,
			"brick" : "P14",
			"name" : "11050",
			"uuid" : "2a80e3ea-f015-b040-9c01-6a3813ecf06b",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 11051,
			"tags" : [
				"P14"
			],
			"type" : "slope",
			"to" : 1255,
			"from" : 1251,
			"brick" : "P14",
			"name" : "11051",
			"uuid" : "7be24412-504c-204e-b64b-d53aaa9d0fd8",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 11052,
			"tags" : [
				"P14"
			],
			"type" : "slope",
			"to" : 1256,
			"from" : 1252,
			"brick" : "P14",
			"name" : "11052",
			"uuid" : "048d770b-8471-504b-a003-2ce42423aa19",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 11053,
			"tags" : [
				"P14"
			],
			"type" : "slope",
			"to" : 1257,
			"from" : 1253,
			"brick" : "P14",
			"name" : "11053",
			"uuid" : "c42d9b3d-19a4-8d47-b23d-efdec7fdc5ea",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 11054,
			"tags" : [
				"P14"
			],
			"type" : "slope",
			"to" : 1258,
			"from" : 1254,
			"brick" : "P14",
			"name" : "11054",
			"uuid" : "0beb01b4-ce22-1644-be8e-90eccba81ae1",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 11055,
			"tags" : [
				"P14"
			],
			"type" : "slope",
			"to" : 1259,
			"from" : 1255,
			"brick" : "P14",
			"name" : "11055",
			"uuid" : "fa02a191-37d7-294b-90c5-93cf7433fe1b",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 11056,
			"tags" : [
				"P14"
			],
			"type" : "slope",
			"to" : 1260,
			"from" : 1256,
			"brick" : "P14",
			"name" : "11056",
			"uuid" : "b1bb6722-b350-ae47-a603-cca6251dd362",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 29001,
			"tags" : [
				"P14"
			],
			"type" : "sectionRound",
			"to" : 1202,
			"from" : 1201,
			"brick" : "P14",
			"name" : "29001",
			"uuid" : "ef635e72-53ee-c345-ac66-12b547c37e94",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 29002,
			"tags" : [
				"P14"
			],
			"type" : "sectionRound",
			"to" : 1203,
			"from" : 1202,
			"brick" : "P14",
			"name" : "29002",
			"uuid" : "32c552f7-2f38-e748-8294-1bed836ecbf1",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 29003,
			"tags" : [
				"P14"
			],
			"type" : "sectionRound",
			"to" : 1204,
			"from" : 1203,
			"brick" : "P14",
			"name" : "29003",
			"uuid" : "385eecf4-60dd-654e-8e79-0cb4e4b4a7ec",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 29004,
			"tags" : [
				"P14"
			],
			"type" : "sectionRound",
			"to" : 1201,
			"from" : 1204,
			"brick" : "P14",
			"name" : "29004",
			"uuid" : "ec3de230-b93c-de42-91bb-ca305fbb69c6",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 29005,
			"tags" : [
				"P14"
			],
			"type" : "sectionRound",
			"to" : 1206,
			"from" : 1205,
			"brick" : "P14",
			"name" : "29005",
			"uuid" : "f2645e58-ca26-f342-a810-caefe6405b56",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 29006,
			"tags" : [
				"P14"
			],
			"type" : "sectionRound",
			"to" : 1207,
			"from" : 1206,
			"brick" : "P14",
			"name" : "29006",
			"uuid" : "23004b32-a82a-1f42-857f-bc98ac204dc2",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 29007,
			"tags" : [
				"P14"
			],
			"type" : "sectionRound",
			"to" : 1208,
			"from" : 1207,
			"brick" : "P14",
			"name" : "29007",
			"uuid" : "09297e0a-c4e3-b545-8344-83c0fbc3cdfa",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 29008,
			"tags" : [
				"P14"
			],
			"type" : "sectionRound",
			"to" : 1205,
			"from" : 1208,
			"brick" : "P14",
			"name" : "29008",
			"uuid" : "3e9d4115-c4e0-244b-8a01-5c251b06e5ae",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 29009,
			"tags" : [
				"P14"
			],
			"type" : "sectionRound",
			"to" : 1269,
			"from" : 1213,
			"brick" : "P14",
			"name" : "29009",
			"uuid" : "0f9dc8a5-66fc-9048-9c02-fe87bd02c368",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 29010,
			"tags" : [
				"P14"
			],
			"type" : "sectionRound",
			"to" : 1214,
			"from" : 1269,
			"brick" : "P14",
			"name" : "29010",
			"uuid" : "fe024ce3-90a3-354f-a44a-06afdeac5d6a",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 29011,
			"tags" : [
				"P14"
			],
			"type" : "sectionRound",
			"to" : 1270,
			"from" : 1214,
			"brick" : "P14",
			"name" : "29011",
			"uuid" : "689fc1ef-dcbf-0e41-aa8f-04c414f629d1",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 29012,
			"tags" : [
				"P14"
			],
			"type" : "sectionRound",
			"to" : 1215,
			"from" : 1270,
			"brick" : "P14",
			"name" : "29012",
			"uuid" : "38ba452b-722a-fe4a-a8ab-cd03b428d97f",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 29013,
			"tags" : [
				"P14"
			],
			"type" : "sectionRound",
			"to" : 1271,
			"from" : 1215,
			"brick" : "P14",
			"name" : "29013",
			"uuid" : "91abd25a-5277-fd47-b263-15afcd01ebe6",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 29014,
			"tags" : [
				"P14"
			],
			"type" : "sectionRound",
			"to" : 1216,
			"from" : 1271,
			"brick" : "P14",
			"name" : "29014",
			"uuid" : "b5914c67-c7a7-474b-bf18-8bc8b547bfff",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 29015,
			"tags" : [
				"P14"
			],
			"type" : "sectionRound",
			"to" : 1272,
			"from" : 1216,
			"brick" : "P14",
			"name" : "29015",
			"uuid" : "e832beee-297c-b449-88c7-b139bc54d664",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 29016,
			"tags" : [
				"P14"
			],
			"type" : "sectionRound",
			"to" : 1213,
			"from" : 1272,
			"brick" : "P14",
			"name" : "29016",
			"uuid" : "110b2921-c44f-7c44-8cfd-daef61962569",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 29017,
			"tags" : [
				"P14"
			],
			"type" : "sectionRound",
			"to" : 1273,
			"from" : 1221,
			"brick" : "P14",
			"name" : "29017",
			"uuid" : "cf6a264e-ae9c-ed47-8fb3-5b5183bd029e",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 29018,
			"tags" : [
				"P14"
			],
			"type" : "sectionRound",
			"to" : 1222,
			"from" : 1273,
			"brick" : "P14",
			"name" : "29018",
			"uuid" : "f0889582-8f0b-0e45-b10a-953d6d03010b",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 29019,
			"tags" : [
				"P14"
			],
			"type" : "sectionRound",
			"to" : 1274,
			"from" : 1222,
			"brick" : "P14",
			"name" : "29019",
			"uuid" : "6862fb04-b79c-cf4f-b08c-04b31efab479",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 29020,
			"tags" : [
				"P14"
			],
			"type" : "sectionRound",
			"to" : 1223,
			"from" : 1274,
			"brick" : "P14",
			"name" : "29020",
			"uuid" : "3f41a847-9280-2b47-a63d-3d75b43efb65",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 29021,
			"tags" : [
				"P14"
			],
			"type" : "sectionRound",
			"to" : 1275,
			"from" : 1223,
			"brick" : "P14",
			"name" : "29021",
			"uuid" : "ff3b2149-d093-e342-9aa8-607de5e49cc0",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 29022,
			"tags" : [
				"P14"
			],
			"type" : "sectionRound",
			"to" : 1224,
			"from" : 1275,
			"brick" : "P14",
			"name" : "29022",
			"uuid" : "96cbe81e-68c9-d747-b41c-f7041a009470",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 29023,
			"tags" : [
				"P14"
			],
			"type" : "sectionRound",
			"to" : 1276,
			"from" : 1224,
			"brick" : "P14",
			"name" : "29023",
			"uuid" : "b06857b1-86c1-3d46-8e35-0815b4f07618",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 29024,
			"tags" : [
				"P14"
			],
			"type" : "sectionRound",
			"to" : 1221,
			"from" : 1276,
			"brick" : "P14",
			"name" : "29024",
			"uuid" : "d40e8546-2817-e044-bb8a-df4457a5e746",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 29025,
			"tags" : [
				"P14"
			],
			"type" : "sectionRound",
			"to" : 1277,
			"from" : 1229,
			"brick" : "P14",
			"name" : "29025",
			"uuid" : "3fd2a18d-d3b5-6e48-a922-010e674954f8",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 29026,
			"tags" : [
				"P14"
			],
			"type" : "sectionRound",
			"to" : 1230,
			"from" : 1277,
			"brick" : "P14",
			"name" : "29026",
			"uuid" : "c66b1abc-d97d-a647-8902-f274b19fccff",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 29027,
			"tags" : [
				"P14"
			],
			"type" : "sectionRound",
			"to" : 1278,
			"from" : 1230,
			"brick" : "P14",
			"name" : "29027",
			"uuid" : "f1a04e39-ca93-bb4e-99ae-b71fdc8f2f76",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 29028,
			"tags" : [
				"P14"
			],
			"type" : "sectionRound",
			"to" : 1231,
			"from" : 1278,
			"brick" : "P14",
			"name" : "29028",
			"uuid" : "d4a23c76-e79a-994f-a044-5240ece697a0",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 29029,
			"tags" : [
				"P14"
			],
			"type" : "sectionRound",
			"to" : 1279,
			"from" : 1231,
			"brick" : "P14",
			"name" : "29029",
			"uuid" : "31e3a076-9230-0840-8b74-8d12070ff5ec",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 29030,
			"tags" : [
				"P14"
			],
			"type" : "sectionRound",
			"to" : 1232,
			"from" : 1279,
			"brick" : "P14",
			"name" : "29030",
			"uuid" : "151d3765-05c7-9c4c-8578-4eceb01fa3d5",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 29031,
			"tags" : [
				"P14"
			],
			"type" : "sectionRound",
			"to" : 1280,
			"from" : 1232,
			"brick" : "P14",
			"name" : "29031",
			"uuid" : "d1dc29c6-623a-b04c-ab43-fcb8d7aeb448",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 29032,
			"tags" : [
				"P14"
			],
			"type" : "sectionRound",
			"to" : 1229,
			"from" : 1280,
			"brick" : "P14",
			"name" : "29032",
			"uuid" : "cf654c8d-1b44-2c42-8e26-4be79e4c2824",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 29033,
			"tags" : [
				"P14"
			],
			"type" : "sectionRound",
			"to" : 1281,
			"from" : 1237,
			"brick" : "P14",
			"name" : "29033",
			"uuid" : "20748d01-51d4-3549-ab60-94813ebd9a50",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 29034,
			"tags" : [
				"P14"
			],
			"type" : "sectionRound",
			"to" : 1238,
			"from" : 1281,
			"brick" : "P14",
			"name" : "29034",
			"uuid" : "b20516d6-e8a0-de42-a706-742aa01e89d7",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 29035,
			"tags" : [
				"P14"
			],
			"type" : "sectionRound",
			"to" : 1282,
			"from" : 1238,
			"brick" : "P14",
			"name" : "29035",
			"uuid" : "0b657726-ae77-3948-9189-ae9ddc30a628",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 29036,
			"tags" : [
				"P14"
			],
			"type" : "sectionRound",
			"to" : 1239,
			"from" : 1282,
			"brick" : "P14",
			"name" : "29036",
			"uuid" : "cf735f2d-4f62-5c49-adf8-38b584df1a8c",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 29037,
			"tags" : [
				"P14"
			],
			"type" : "sectionRound",
			"to" : 1283,
			"from" : 1239,
			"brick" : "P14",
			"name" : "29037",
			"uuid" : "502e3565-a612-cf48-a710-79b86226c163",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 29038,
			"tags" : [
				"P14"
			],
			"type" : "sectionRound",
			"to" : 1240,
			"from" : 1283,
			"brick" : "P14",
			"name" : "29038",
			"uuid" : "b545b240-dc72-4345-8983-942ab6bcddce",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 29039,
			"tags" : [
				"P14"
			],
			"type" : "sectionRound",
			"to" : 1284,
			"from" : 1240,
			"brick" : "P14",
			"name" : "29039",
			"uuid" : "665228b4-731c-f747-b846-2f5d5dcc5627",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 29040,
			"tags" : [
				"P14"
			],
			"type" : "sectionRound",
			"to" : 1237,
			"from" : 1284,
			"brick" : "P14",
			"name" : "29040",
			"uuid" : "af90c402-75db-8349-9f6d-42e4ac61b164",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 29041,
			"tags" : [
				"P14"
			],
			"type" : "sectionRound",
			"to" : 1285,
			"from" : 1245,
			"brick" : "P14",
			"name" : "29041",
			"uuid" : "8addae70-329d-ec41-b447-41617baa5806",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 29042,
			"tags" : [
				"P14"
			],
			"type" : "sectionRound",
			"to" : 1246,
			"from" : 1285,
			"brick" : "P14",
			"name" : "29042",
			"uuid" : "e795e09c-6455-9946-b62c-4ac6b0f83226",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 29043,
			"tags" : [
				"P14"
			],
			"type" : "sectionRound",
			"to" : 1286,
			"from" : 1246,
			"brick" : "P14",
			"name" : "29043",
			"uuid" : "4482c290-8571-464b-86e2-f9a06739dfd7",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 29044,
			"tags" : [
				"P14"
			],
			"type" : "sectionRound",
			"to" : 1247,
			"from" : 1286,
			"brick" : "P14",
			"name" : "29044",
			"uuid" : "1b617df2-58e8-9c48-bc29-90503f2af4ec",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 29045,
			"tags" : [
				"P14"
			],
			"type" : "sectionRound",
			"to" : 1287,
			"from" : 1247,
			"brick" : "P14",
			"name" : "29045",
			"uuid" : "7af355c6-b286-744d-bf85-9f1e5d49a97e",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 29046,
			"tags" : [
				"P14"
			],
			"type" : "sectionRound",
			"to" : 1248,
			"from" : 1287,
			"brick" : "P14",
			"name" : "29046",
			"uuid" : "69d2fe98-68a9-8649-b942-f0bee7ab7e04",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 29047,
			"tags" : [
				"P14"
			],
			"type" : "sectionRound",
			"to" : 1288,
			"from" : 1248,
			"brick" : "P14",
			"name" : "29047",
			"uuid" : "ff749ed0-fbf3-8949-bea8-0e59fe26ebbc",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 29048,
			"tags" : [
				"P14"
			],
			"type" : "sectionRound",
			"to" : 1245,
			"from" : 1288,
			"brick" : "P14",
			"name" : "29048",
			"uuid" : "06d1adc3-34c8-0f43-83a9-475af997b170",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 29049,
			"tags" : [
				"P14"
			],
			"type" : "sectionRound",
			"to" : 1289,
			"from" : 1253,
			"brick" : "P14",
			"name" : "29049",
			"uuid" : "3f2ab8fa-bbad-e147-a90c-daf88c1624d8",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 29050,
			"tags" : [
				"P14"
			],
			"type" : "sectionRound",
			"to" : 1254,
			"from" : 1289,
			"brick" : "P14",
			"name" : "29050",
			"uuid" : "fb72baa1-b033-1441-8aba-26aeddd4c9b5",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 29051,
			"tags" : [
				"P14"
			],
			"type" : "sectionRound",
			"to" : 1290,
			"from" : 1254,
			"brick" : "P14",
			"name" : "29051",
			"uuid" : "9f60229f-7520-b743-a245-38341d372416",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 29052,
			"tags" : [
				"P14"
			],
			"type" : "sectionRound",
			"to" : 1255,
			"from" : 1290,
			"brick" : "P14",
			"name" : "29052",
			"uuid" : "8676a721-bed9-f946-a7e1-7fcbb69e7ac3",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 29053,
			"tags" : [
				"P14"
			],
			"type" : "sectionRound",
			"to" : 1291,
			"from" : 1255,
			"brick" : "P14",
			"name" : "29053",
			"uuid" : "5b6e115f-ab39-6b4b-8aad-ac1823f937de",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 29054,
			"tags" : [
				"P14"
			],
			"type" : "sectionRound",
			"to" : 1256,
			"from" : 1291,
			"brick" : "P14",
			"name" : "29054",
			"uuid" : "826f662f-048f-3744-85d1-c5fa5e621f17",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 29055,
			"tags" : [
				"P14"
			],
			"type" : "sectionRound",
			"to" : 1292,
			"from" : 1256,
			"brick" : "P14",
			"name" : "29055",
			"uuid" : "d7c0fa98-fa20-9441-b180-1b7b94d55615",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 29056,
			"tags" : [
				"P14"
			],
			"type" : "sectionRound",
			"to" : 1253,
			"from" : 1292,
			"brick" : "P14",
			"name" : "29056",
			"uuid" : "37c1576a-b398-fd4d-be3a-b45590b946ec",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 29101,
			"tags" : [
				"P14"
			],
			"type" : "sectionSlant",
			"to" : 1204,
			"from" : 2301,
			"brick" : "P14",
			"name" : "29101",
			"uuid" : "8d82a242-7b35-4a42-b5d8-12e8967ac813",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 29102,
			"tags" : [
				"P14"
			],
			"type" : "sectionSlant",
			"to" : 2301,
			"from" : 1202,
			"brick" : "P14",
			"name" : "29102",
			"uuid" : "65936044-6649-7e45-92a3-6c9f95803e09",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 29103,
			"tags" : [
				"P14"
			],
			"type" : "sectionSlant",
			"to" : 1203,
			"from" : 2301,
			"brick" : "P14",
			"name" : "29103",
			"uuid" : "2b269ed9-60d3-d349-a595-6c7595b20598",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 29104,
			"tags" : [
				"P14"
			],
			"type" : "sectionSlant",
			"to" : 2301,
			"from" : 1201,
			"brick" : "P14",
			"name" : "29104",
			"uuid" : "4651db36-f91b-b547-8838-f7e3002d7947",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 29105,
			"tags" : [
				"P14"
			],
			"type" : "sectionSlant",
			"to" : 1208,
			"from" : 2302,
			"brick" : "P14",
			"name" : "29105",
			"uuid" : "912c2c3d-0ab7-4741-915b-22f0fb669b52",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 29106,
			"tags" : [
				"P14"
			],
			"type" : "sectionSlant",
			"to" : 2302,
			"from" : 1206,
			"brick" : "P14",
			"name" : "29106",
			"uuid" : "7bd5f85b-6e95-2f43-803d-eb9a3011fc4b",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 29107,
			"tags" : [
				"P14"
			],
			"type" : "sectionSlant",
			"to" : 1207,
			"from" : 2302,
			"brick" : "P14",
			"name" : "29107",
			"uuid" : "511011f9-a70d-9042-a86d-08b626294aac",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 29108,
			"tags" : [
				"P14"
			],
			"type" : "sectionSlant",
			"to" : 2302,
			"from" : 1205,
			"brick" : "P14",
			"name" : "29108",
			"uuid" : "241af5c4-e0de-3741-b01c-6efddb35984e",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 29109,
			"tags" : [
				"P14"
			],
			"type" : "sectionSlant",
			"to" : 1285,
			"from" : 1288,
			"brick" : "P14",
			"name" : "29109",
			"uuid" : "e016c479-f083-7347-ade9-9bd158e01c44",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 29110,
			"tags" : [
				"P14"
			],
			"type" : "sectionSlant",
			"to" : 1286,
			"from" : 1285,
			"brick" : "P14",
			"name" : "29110",
			"uuid" : "84139389-1e69-8849-9931-cfc2178dbd2c",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 29111,
			"tags" : [
				"P14"
			],
			"type" : "sectionSlant",
			"to" : 1287,
			"from" : 1286,
			"brick" : "P14",
			"name" : "29111",
			"uuid" : "63d543aa-b9c7-9542-a816-9dc6474e0ae9",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 29112,
			"tags" : [
				"P14"
			],
			"type" : "sectionSlant",
			"to" : 1288,
			"from" : 1287,
			"brick" : "P14",
			"name" : "29112",
			"uuid" : "7c65af69-23c0-064a-8e53-1085f864b409",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 29113,
			"tags" : [
				"P14"
			],
			"type" : "sectionSlant",
			"to" : 1289,
			"from" : 1292,
			"brick" : "P14",
			"name" : "29113",
			"uuid" : "f7dc4e7c-1f27-c54d-abf8-2535ee82c637",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 29114,
			"tags" : [
				"P14"
			],
			"type" : "sectionSlant",
			"to" : 1290,
			"from" : 1289,
			"brick" : "P14",
			"name" : "29114",
			"uuid" : "e1028aa1-39b1-3849-846c-5d069ba0cd61",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 29115,
			"tags" : [
				"P14"
			],
			"type" : "sectionSlant",
			"to" : 1291,
			"from" : 1290,
			"brick" : "P14",
			"name" : "29115",
			"uuid" : "8c39310c-a967-b147-aabe-eb597980e765",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 29116,
			"tags" : [
				"P14"
			],
			"type" : "sectionSlant",
			"to" : 1292,
			"from" : 1291,
			"brick" : "P14",
			"name" : "29116",
			"uuid" : "25489154-c1c2-7149-ac57-e2322d500aa2",
			"_clazz" : "TwkSegment"
		},
		{
			"uuid" : "95e603e8-dfde-3641-89cc-1a4e2ba2d0fb",
			"name" : "20001",
			"_clazz" : "TwkSegment",
			"brick" : "FRONT",
			"from" : 1261,
			"face" : "front",
			"tags" : [
				"P14"
			],
			"type" : "panel",
			"to" : 1201,
			"number" : 20001
		},
		{
			"uuid" : "7d6ca06b-1c4a-3947-b796-fd0e7a19ef56",
			"name" : "20002",
			"_clazz" : "TwkSegment",
			"brick" : "FRONT",
			"from" : 1206,
			"face" : "front",
			"tags" : [
				"P14"
			],
			"type" : "panel",
			"to" : 1261,
			"number" : 20002
		},
		{
			"uuid" : "917905dd-c34d-0041-9953-a4b57f3d531a",
			"name" : "20003",
			"_clazz" : "TwkSegment",
			"brick" : "FRONT",
			"from" : 1261,
			"face" : "front",
			"tags" : [
				"P14"
			],
			"type" : "panel",
			"to" : 1202,
			"number" : 20003
		},
		{
			"uuid" : "232b8576-643c-6047-8c77-d4cb9b2311f2",
			"name" : "20004",
			"_clazz" : "TwkSegment",
			"brick" : "FRONT",
			"from" : 1205,
			"face" : "front",
			"tags" : [
				"P14"
			],
			"type" : "panel",
			"to" : 1261,
			"number" : 20004
		},
		{
			"uuid" : "780b9e63-853d-7a48-a0a3-be2fb40a06a9",
			"name" : "20005",
			"_clazz" : "TwkSegment",
			"brick" : "LEFT",
			"from" : 1262,
			"face" : "left",
			"tags" : [
				"P14"
			],
			"type" : "panel",
			"to" : 1202,
			"number" : 20005
		},
		{
			"uuid" : "db1cd9e2-ec07-2f44-8841-d8ed4553f128",
			"name" : "20006",
			"_clazz" : "TwkSegment",
			"brick" : "LEFT",
			"from" : 1207,
			"face" : "left",
			"tags" : [
				"P14"
			],
			"type" : "panel",
			"to" : 1262,
			"number" : 20006
		},
		{
			"uuid" : "8e9cf82d-ce92-4a40-af22-af6d288aa3b1",
			"name" : "20007",
			"_clazz" : "TwkSegment",
			"brick" : "LEFT",
			"from" : 1262,
			"face" : "left",
			"tags" : [
				"P14"
			],
			"type" : "panel",
			"to" : 1203,
			"number" : 20007
		},
		{
			"uuid" : "56bb5cd4-283a-d241-9c2c-0278c9770341",
			"name" : "20008",
			"_clazz" : "TwkSegment",
			"brick" : "LEFT",
			"from" : 1206,
			"face" : "left",
			"tags" : [
				"P14"
			],
			"type" : "panel",
			"to" : 1262,
			"number" : 20008
		},
		{
			"uuid" : "5bdd7342-b8c7-a740-b6de-61cf90e891a6",
			"name" : "20009",
			"_clazz" : "TwkSegment",
			"brick" : "BACK",
			"from" : 1263,
			"face" : "back",
			"tags" : [
				"P14"
			],
			"type" : "panel",
			"to" : 1203,
			"number" : 20009
		},
		{
			"uuid" : "60058547-a41f-ec4e-8549-2dae5f3cdfea",
			"name" : "20010",
			"_clazz" : "TwkSegment",
			"brick" : "BACK",
			"from" : 1208,
			"face" : "back",
			"tags" : [
				"P14"
			],
			"type" : "panel",
			"to" : 1263,
			"number" : 20010
		},
		{
			"uuid" : "d1d44719-f56e-f443-8753-12d33d75f62c",
			"name" : "20011",
			"_clazz" : "TwkSegment",
			"brick" : "BACK",
			"from" : 1263,
			"face" : "back",
			"tags" : [
				"P14"
			],
			"type" : "panel",
			"to" : 1204,
			"number" : 20011
		},
		{
			"uuid" : "a3f9d431-0497-9344-b559-3d38808c60e6",
			"name" : "20012",
			"_clazz" : "TwkSegment",
			"brick" : "BACK",
			"from" : 1207,
			"face" : "back",
			"tags" : [
				"P14"
			],
			"type" : "panel",
			"to" : 1263,
			"number" : 20012
		},
		{
			"uuid" : "2fdc6f40-186e-f940-b5a1-aaed5f768654",
			"name" : "20013",
			"_clazz" : "TwkSegment",
			"brick" : "RIGHT",
			"from" : 1264,
			"face" : "right",
			"tags" : [
				"P14"
			],
			"type" : "panel",
			"to" : 1204,
			"number" : 20013
		},
		{
			"uuid" : "cab039a3-24f9-6d4b-aa71-98354b012ed5",
			"name" : "20014",
			"_clazz" : "TwkSegment",
			"brick" : "RIGHT",
			"from" : 1205,
			"face" : "right",
			"tags" : [
				"P14"
			],
			"type" : "panel",
			"to" : 1264,
			"number" : 20014
		},
		{
			"uuid" : "4e0d7be3-d8cc-c24e-b4b4-d4e4d9482d3c",
			"name" : "20015",
			"_clazz" : "TwkSegment",
			"brick" : "RIGHT",
			"from" : 1264,
			"face" : "right",
			"tags" : [
				"P14"
			],
			"type" : "panel",
			"to" : 1201,
			"number" : 20015
		},
		{
			"uuid" : "40fcff5b-61be-d64d-b379-9c6501473701",
			"name" : "20016",
			"_clazz" : "TwkSegment",
			"brick" : "RIGHT",
			"from" : 1208,
			"face" : "right",
			"tags" : [
				"P14"
			],
			"type" : "panel",
			"to" : 1264,
			"number" : 20016
		},
		{
			"uuid" : "ec6fe4b1-d609-de4d-a7e5-8898f8310cde",
			"name" : "20017",
			"_clazz" : "TwkSegment",
			"brick" : "FRONT",
			"from" : 1265,
			"face" : "front",
			"tags" : [
				"P14"
			],
			"type" : "panel",
			"to" : 1205,
			"number" : 20017
		},
		{
			"uuid" : "32ae2876-0cd0-4543-8706-352f144b3cd3",
			"name" : "20018",
			"_clazz" : "TwkSegment",
			"brick" : "FRONT",
			"from" : 1210,
			"face" : "front",
			"tags" : [
				"P14"
			],
			"type" : "panel",
			"to" : 1265,
			"number" : 20018
		},
		{
			"uuid" : "385838bf-a330-404e-8092-1efbbefb21c0",
			"name" : "20019",
			"_clazz" : "TwkSegment",
			"brick" : "FRONT",
			"from" : 1265,
			"face" : "front",
			"tags" : [
				"P14"
			],
			"type" : "panel",
			"to" : 1206,
			"number" : 20019
		},
		{
			"uuid" : "ba7bb1cb-cefa-684b-beb3-5bfd27cd4106",
			"name" : "20020",
			"_clazz" : "TwkSegment",
			"brick" : "FRONT",
			"from" : 1209,
			"face" : "front",
			"tags" : [
				"P14"
			],
			"type" : "panel",
			"to" : 1265,
			"number" : 20020
		},
		{
			"uuid" : "b59ca5d0-3ca4-014f-a753-e36f4670ee32",
			"name" : "20021",
			"_clazz" : "TwkSegment",
			"brick" : "LEFT",
			"from" : 1266,
			"face" : "left",
			"tags" : [
				"P14"
			],
			"type" : "panel",
			"to" : 1206,
			"number" : 20021
		},
		{
			"uuid" : "093ab582-7b7f-c248-a1ab-e18db3e56809",
			"name" : "20022",
			"_clazz" : "TwkSegment",
			"brick" : "LEFT",
			"from" : 1211,
			"face" : "left",
			"tags" : [
				"P14"
			],
			"type" : "panel",
			"to" : 1266,
			"number" : 20022
		},
		{
			"uuid" : "8e2e6fb4-f24b-8046-92dd-3fee6f773719",
			"name" : "20023",
			"_clazz" : "TwkSegment",
			"brick" : "LEFT",
			"from" : 1266,
			"face" : "left",
			"tags" : [
				"P14"
			],
			"type" : "panel",
			"to" : 1207,
			"number" : 20023
		},
		{
			"uuid" : "338eebad-1424-a143-a54a-de8b63593fbd",
			"name" : "20024",
			"_clazz" : "TwkSegment",
			"brick" : "LEFT",
			"from" : 1210,
			"face" : "left",
			"tags" : [
				"P14"
			],
			"type" : "panel",
			"to" : 1266,
			"number" : 20024
		},
		{
			"uuid" : "d3a5b8ec-e428-2b40-9ab4-5b19989b8a76",
			"name" : "20025",
			"_clazz" : "TwkSegment",
			"brick" : "BACK",
			"from" : 1267,
			"face" : "back",
			"tags" : [
				"P14"
			],
			"type" : "panel",
			"to" : 1207,
			"number" : 20025
		},
		{
			"uuid" : "97eff6b4-fefc-2447-8fbb-89caebc11998",
			"name" : "20026",
			"_clazz" : "TwkSegment",
			"brick" : "BACK",
			"from" : 1212,
			"face" : "back",
			"tags" : [
				"P14"
			],
			"type" : "panel",
			"to" : 1267,
			"number" : 20026
		},
		{
			"uuid" : "ab0d2c55-01ee-1c4a-b4ab-1f7f8235e8e0",
			"name" : "20027",
			"_clazz" : "TwkSegment",
			"brick" : "BACK",
			"from" : 1267,
			"face" : "back",
			"tags" : [
				"P14"
			],
			"type" : "panel",
			"to" : 1208,
			"number" : 20027
		},
		{
			"uuid" : "fe595b2d-a0bb-2441-a357-f0ef28048cbe",
			"name" : "20028",
			"_clazz" : "TwkSegment",
			"brick" : "BACK",
			"from" : 1211,
			"face" : "back",
			"tags" : [
				"P14"
			],
			"type" : "panel",
			"to" : 1267,
			"number" : 20028
		},
		{
			"uuid" : "42f5eda4-762a-c24e-8852-9612006e505d",
			"name" : "20029",
			"_clazz" : "TwkSegment",
			"brick" : "RIGHT",
			"from" : 1268,
			"face" : "right",
			"tags" : [
				"P14"
			],
			"type" : "panel",
			"to" : 1208,
			"number" : 20029
		},
		{
			"uuid" : "2695842b-f734-bb49-9f2d-c0d681bcae74",
			"name" : "20030",
			"_clazz" : "TwkSegment",
			"brick" : "RIGHT",
			"from" : 1209,
			"face" : "right",
			"tags" : [
				"P14"
			],
			"type" : "panel",
			"to" : 1268,
			"number" : 20030
		},
		{
			"uuid" : "97e7becf-7ee6-984a-aa9d-e1c0e6bb179e",
			"name" : "20031",
			"_clazz" : "TwkSegment",
			"brick" : "RIGHT",
			"from" : 1268,
			"face" : "right",
			"tags" : [
				"P14"
			],
			"type" : "panel",
			"to" : 1205,
			"number" : 20031
		},
		{
			"uuid" : "2119d575-9c19-9441-83a7-19631ed80a0c",
			"name" : "20032",
			"_clazz" : "TwkSegment",
			"brick" : "RIGHT",
			"from" : 1212,
			"face" : "right",
			"tags" : [
				"P14"
			],
			"type" : "panel",
			"to" : 1268,
			"number" : 20032
		},
		{
			"uuid" : "744549ff-1980-5b42-9f6a-f5c95043cbbb",
			"name" : "20033",
			"_clazz" : "TwkSegment",
			"brick" : "FRONT",
			"from" : 1269,
			"face" : "front",
			"tags" : [
				"P14"
			],
			"type" : "panel",
			"to" : 1209,
			"number" : 20033
		},
		{
			"uuid" : "de0930e1-6001-8643-9dc1-e8a2cfe77bcc",
			"name" : "20034",
			"_clazz" : "TwkSegment",
			"brick" : "FRONT",
			"from" : 1218,
			"face" : "front",
			"tags" : [
				"P14"
			],
			"type" : "panel",
			"to" : 1269,
			"number" : 20034
		},
		{
			"uuid" : "06c762b6-a798-f64c-bd0e-90405712ac56",
			"name" : "20035",
			"_clazz" : "TwkSegment",
			"brick" : "FRONT",
			"from" : 1269,
			"face" : "front",
			"tags" : [
				"P14"
			],
			"type" : "panel",
			"to" : 1210,
			"number" : 20035
		},
		{
			"uuid" : "800e7507-7172-a54b-876e-37626ff9e49a",
			"name" : "20036",
			"_clazz" : "TwkSegment",
			"brick" : "FRONT",
			"from" : 1217,
			"face" : "front",
			"tags" : [
				"P14"
			],
			"type" : "panel",
			"to" : 1269,
			"number" : 20036
		},
		{
			"uuid" : "d87b1179-4b91-d546-b0f1-2a881d72b9a2",
			"name" : "20037",
			"_clazz" : "TwkSegment",
			"brick" : "LEFT",
			"from" : 1270,
			"face" : "left",
			"tags" : [
				"P14"
			],
			"type" : "panel",
			"to" : 1210,
			"number" : 20037
		},
		{
			"uuid" : "c10eb58a-81b0-194b-979e-ebfb8957043e",
			"name" : "20038",
			"_clazz" : "TwkSegment",
			"brick" : "LEFT",
			"from" : 1219,
			"face" : "left",
			"tags" : [
				"P14"
			],
			"type" : "panel",
			"to" : 1270,
			"number" : 20038
		},
		{
			"uuid" : "5b9058cc-748a-2948-a823-b7609d7b39a8",
			"name" : "20039",
			"_clazz" : "TwkSegment",
			"brick" : "LEFT",
			"from" : 1270,
			"face" : "left",
			"tags" : [
				"P14"
			],
			"type" : "panel",
			"to" : 1211,
			"number" : 20039
		},
		{
			"uuid" : "402c08a4-5229-e641-8a42-624e2a461ddd",
			"name" : "20040",
			"_clazz" : "TwkSegment",
			"brick" : "LEFT",
			"from" : 1218,
			"face" : "left",
			"tags" : [
				"P14"
			],
			"type" : "panel",
			"to" : 1270,
			"number" : 20040
		},
		{
			"uuid" : "67daf8ec-a1d5-a544-8ffc-085e52f4cfce",
			"name" : "20041",
			"_clazz" : "TwkSegment",
			"brick" : "BACK",
			"from" : 1271,
			"face" : "back",
			"tags" : [
				"P14"
			],
			"type" : "panel",
			"to" : 1211,
			"number" : 20041
		},
		{
			"uuid" : "89d65bef-4213-8240-875a-66c996114055",
			"name" : "20042",
			"_clazz" : "TwkSegment",
			"brick" : "BACK",
			"from" : 1220,
			"face" : "back",
			"tags" : [
				"P14"
			],
			"type" : "panel",
			"to" : 1271,
			"number" : 20042
		},
		{
			"uuid" : "3d7465b9-14e2-5847-8809-d8980af6d396",
			"name" : "20043",
			"_clazz" : "TwkSegment",
			"brick" : "BACK",
			"from" : 1271,
			"face" : "back",
			"tags" : [
				"P14"
			],
			"type" : "panel",
			"to" : 1212,
			"number" : 20043
		},
		{
			"uuid" : "01696770-1279-8447-945d-9b028046a74a",
			"name" : "20044",
			"_clazz" : "TwkSegment",
			"brick" : "BACK",
			"from" : 1219,
			"face" : "back",
			"tags" : [
				"P14"
			],
			"type" : "panel",
			"to" : 1271,
			"number" : 20044
		},
		{
			"uuid" : "00556ce1-704f-854d-a7e1-72531b182b6b",
			"name" : "20045",
			"_clazz" : "TwkSegment",
			"brick" : "RIGHT",
			"from" : 1272,
			"face" : "right",
			"tags" : [
				"P14"
			],
			"type" : "panel",
			"to" : 1212,
			"number" : 20045
		},
		{
			"uuid" : "d6df5347-d2ed-904c-8c2b-5dcddaed34c6",
			"name" : "20046",
			"_clazz" : "TwkSegment",
			"brick" : "RIGHT",
			"from" : 1217,
			"face" : "right",
			"tags" : [
				"P14"
			],
			"type" : "panel",
			"to" : 1272,
			"number" : 20046
		},
		{
			"uuid" : "699ff826-830a-2f49-b853-340c9262849c",
			"name" : "20047",
			"_clazz" : "TwkSegment",
			"brick" : "RIGHT",
			"from" : 1272,
			"face" : "right",
			"tags" : [
				"P14"
			],
			"type" : "panel",
			"to" : 1209,
			"number" : 20047
		},
		{
			"uuid" : "cd556671-83ab-b641-96c5-d88df32e2f0a",
			"name" : "20048",
			"_clazz" : "TwkSegment",
			"brick" : "RIGHT",
			"from" : 1220,
			"face" : "right",
			"tags" : [
				"P14"
			],
			"type" : "panel",
			"to" : 1272,
			"number" : 20048
		},
		{
			"uuid" : "f3e7c61e-74ae-7541-96e9-3f32910640cd",
			"name" : "20049",
			"_clazz" : "TwkSegment",
			"brick" : "FRONT",
			"from" : 1273,
			"face" : "front",
			"tags" : [
				"P14"
			],
			"type" : "panel",
			"to" : 1217,
			"number" : 20049
		},
		{
			"uuid" : "ffc946d0-7300-be46-bf8b-66535f7c1c10",
			"name" : "20050",
			"_clazz" : "TwkSegment",
			"brick" : "FRONT",
			"from" : 1226,
			"face" : "front",
			"tags" : [
				"P14"
			],
			"type" : "panel",
			"to" : 1273,
			"number" : 20050
		},
		{
			"uuid" : "ddeb8635-925c-3a42-a9f0-14ed499e7952",
			"name" : "20051",
			"_clazz" : "TwkSegment",
			"brick" : "FRONT",
			"from" : 1273,
			"face" : "front",
			"tags" : [
				"P14"
			],
			"type" : "panel",
			"to" : 1218,
			"number" : 20051
		},
		{
			"uuid" : "90cd9b0b-6a97-2540-9f86-4274dbcaeffc",
			"name" : "20052",
			"_clazz" : "TwkSegment",
			"brick" : "FRONT",
			"from" : 1225,
			"face" : "front",
			"tags" : [
				"P14"
			],
			"type" : "panel",
			"to" : 1273,
			"number" : 20052
		},
		{
			"uuid" : "df30b72d-54d0-284d-9d54-c2c12fb99fa4",
			"name" : "20053",
			"_clazz" : "TwkSegment",
			"brick" : "LEFT",
			"from" : 1274,
			"face" : "left",
			"tags" : [
				"P14"
			],
			"type" : "panel",
			"to" : 1218,
			"number" : 20053
		},
		{
			"uuid" : "521802ef-8c14-1e42-b1e5-b1c25458d34b",
			"name" : "20054",
			"_clazz" : "TwkSegment",
			"brick" : "LEFT",
			"from" : 1227,
			"face" : "left",
			"tags" : [
				"P14"
			],
			"type" : "panel",
			"to" : 1274,
			"number" : 20054
		},
		{
			"uuid" : "76c4a959-0624-7b4b-9bf1-dd602966e94d",
			"name" : "20055",
			"_clazz" : "TwkSegment",
			"brick" : "LEFT",
			"from" : 1274,
			"face" : "left",
			"tags" : [
				"P14"
			],
			"type" : "panel",
			"to" : 1219,
			"number" : 20055
		},
		{
			"uuid" : "97e120a6-da74-0d41-8458-bf5e149d1731",
			"name" : "20056",
			"_clazz" : "TwkSegment",
			"brick" : "LEFT",
			"from" : 1226,
			"face" : "left",
			"tags" : [
				"P14"
			],
			"type" : "panel",
			"to" : 1274,
			"number" : 20056
		},
		{
			"uuid" : "64bbc4e8-fb43-b54e-a238-7ce83378a42a",
			"name" : "20057",
			"_clazz" : "TwkSegment",
			"brick" : "BACK",
			"from" : 1275,
			"face" : "back",
			"tags" : [
				"P14"
			],
			"type" : "panel",
			"to" : 1219,
			"number" : 20057
		},
		{
			"uuid" : "f98411d4-0838-3240-9a80-fcf34b756900",
			"name" : "20058",
			"_clazz" : "TwkSegment",
			"brick" : "BACK",
			"from" : 1228,
			"face" : "back",
			"tags" : [
				"P14"
			],
			"type" : "panel",
			"to" : 1275,
			"number" : 20058
		},
		{
			"uuid" : "16e283e3-00cf-1d4d-b805-a6af7b5fbf7b",
			"name" : "20059",
			"_clazz" : "TwkSegment",
			"brick" : "BACK",
			"from" : 1275,
			"face" : "back",
			"tags" : [
				"P14"
			],
			"type" : "panel",
			"to" : 1220,
			"number" : 20059
		},
		{
			"uuid" : "154c07a8-e8f1-1a4f-8225-2870f012b9ab",
			"name" : "20060",
			"_clazz" : "TwkSegment",
			"brick" : "BACK",
			"from" : 1227,
			"face" : "back",
			"tags" : [
				"P14"
			],
			"type" : "panel",
			"to" : 1275,
			"number" : 20060
		},
		{
			"uuid" : "d4b57e89-ada6-5846-81aa-97da7505de6e",
			"name" : "20061",
			"_clazz" : "TwkSegment",
			"brick" : "RIGHT",
			"from" : 1276,
			"face" : "right",
			"tags" : [
				"P14"
			],
			"type" : "panel",
			"to" : 1220,
			"number" : 20061
		},
		{
			"uuid" : "9d82c89a-422e-9a49-bcc0-18cc6a65914d",
			"name" : "20062",
			"_clazz" : "TwkSegment",
			"brick" : "RIGHT",
			"from" : 1225,
			"face" : "right",
			"tags" : [
				"P14"
			],
			"type" : "panel",
			"to" : 1276,
			"number" : 20062
		},
		{
			"uuid" : "3c13bcce-de1e-7447-b362-3868e1d2d4aa",
			"name" : "20063",
			"_clazz" : "TwkSegment",
			"brick" : "RIGHT",
			"from" : 1276,
			"face" : "right",
			"tags" : [
				"P14"
			],
			"type" : "panel",
			"to" : 1217,
			"number" : 20063
		},
		{
			"uuid" : "bdecfa41-c82b-194c-9478-f65804f9ac70",
			"name" : "20064",
			"_clazz" : "TwkSegment",
			"brick" : "RIGHT",
			"from" : 1228,
			"face" : "right",
			"tags" : [
				"P14"
			],
			"type" : "panel",
			"to" : 1276,
			"number" : 20064
		},
		{
			"uuid" : "b1aec0fb-1ff5-c042-9d1d-5df3a9acbbf5",
			"name" : "20065",
			"_clazz" : "TwkSegment",
			"brick" : "FRONT",
			"from" : 1277,
			"face" : "front",
			"tags" : [
				"P14"
			],
			"type" : "panel",
			"to" : 1225,
			"number" : 20065
		},
		{
			"uuid" : "22cebe28-3f32-1b44-a760-2e1bfd0be78c",
			"name" : "20066",
			"_clazz" : "TwkSegment",
			"brick" : "FRONT",
			"from" : 1234,
			"face" : "front",
			"tags" : [
				"P14"
			],
			"type" : "panel",
			"to" : 1277,
			"number" : 20066
		},
		{
			"uuid" : "1a31994f-8c99-3d44-a218-c3c35dbc4f7d",
			"name" : "20067",
			"_clazz" : "TwkSegment",
			"brick" : "FRONT",
			"from" : 1277,
			"face" : "front",
			"tags" : [
				"P14"
			],
			"type" : "panel",
			"to" : 1226,
			"number" : 20067
		},
		{
			"uuid" : "c884139c-d316-464d-bfa9-5388ba01cf09",
			"name" : "20068",
			"_clazz" : "TwkSegment",
			"brick" : "FRONT",
			"from" : 1233,
			"face" : "front",
			"tags" : [
				"P14"
			],
			"type" : "panel",
			"to" : 1277,
			"number" : 20068
		},
		{
			"uuid" : "d8fa9d2c-0172-634e-918e-e1736979c4ab",
			"name" : "20069",
			"_clazz" : "TwkSegment",
			"brick" : "LEFT",
			"from" : 1278,
			"face" : "left",
			"tags" : [
				"P14"
			],
			"type" : "panel",
			"to" : 1226,
			"number" : 20069
		},
		{
			"uuid" : "62bfe7bb-22f8-2b40-94c5-b87953378363",
			"name" : "20070",
			"_clazz" : "TwkSegment",
			"brick" : "LEFT",
			"from" : 1235,
			"face" : "left",
			"tags" : [
				"P14"
			],
			"type" : "panel",
			"to" : 1278,
			"number" : 20070
		},
		{
			"uuid" : "91d7b208-45bf-d349-b1d8-80f159b95c3a",
			"name" : "20071",
			"_clazz" : "TwkSegment",
			"brick" : "LEFT",
			"from" : 1278,
			"face" : "left",
			"tags" : [
				"P14"
			],
			"type" : "panel",
			"to" : 1227,
			"number" : 20071
		},
		{
			"uuid" : "de1268a9-5ddc-fa4f-835f-2a3b96df74ab",
			"name" : "20072",
			"_clazz" : "TwkSegment",
			"brick" : "LEFT",
			"from" : 1234,
			"face" : "left",
			"tags" : [
				"P14"
			],
			"type" : "panel",
			"to" : 1278,
			"number" : 20072
		},
		{
			"uuid" : "ff84dec4-9b62-f24a-87b4-1a7bf86b0001",
			"name" : "20073",
			"_clazz" : "TwkSegment",
			"brick" : "BACK",
			"from" : 1279,
			"face" : "back",
			"tags" : [
				"P14"
			],
			"type" : "panel",
			"to" : 1227,
			"number" : 20073
		},
		{
			"uuid" : "2daffc56-62e8-b846-829d-b2f2e31f12ba",
			"name" : "20074",
			"_clazz" : "TwkSegment",
			"brick" : "BACK",
			"from" : 1236,
			"face" : "back",
			"tags" : [
				"P14"
			],
			"type" : "panel",
			"to" : 1279,
			"number" : 20074
		},
		{
			"uuid" : "15dfc031-6d45-bd4e-ae8e-5b4577a2abe4",
			"name" : "20075",
			"_clazz" : "TwkSegment",
			"brick" : "BACK",
			"from" : 1279,
			"face" : "back",
			"tags" : [
				"P14"
			],
			"type" : "panel",
			"to" : 1228,
			"number" : 20075
		},
		{
			"uuid" : "2be08f57-fb3a-5344-80d0-c974342c8c34",
			"name" : "20076",
			"_clazz" : "TwkSegment",
			"brick" : "BACK",
			"from" : 1235,
			"face" : "back",
			"tags" : [
				"P14"
			],
			"type" : "panel",
			"to" : 1279,
			"number" : 20076
		},
		{
			"uuid" : "54767f9b-f158-f045-b39d-71647f497a28",
			"name" : "20077",
			"_clazz" : "TwkSegment",
			"brick" : "RIGHT",
			"from" : 1280,
			"face" : "right",
			"tags" : [
				"P14"
			],
			"type" : "panel",
			"to" : 1228,
			"number" : 20077
		},
		{
			"uuid" : "d4969104-b9b8-ed4d-a266-7c893fc53b7f",
			"name" : "20078",
			"_clazz" : "TwkSegment",
			"brick" : "RIGHT",
			"from" : 1233,
			"face" : "right",
			"tags" : [
				"P14"
			],
			"type" : "panel",
			"to" : 1280,
			"number" : 20078
		},
		{
			"uuid" : "43c91768-e8b2-854c-aaf8-b4322210c79f",
			"name" : "20079",
			"_clazz" : "TwkSegment",
			"brick" : "RIGHT",
			"from" : 1280,
			"face" : "right",
			"tags" : [
				"P14"
			],
			"type" : "panel",
			"to" : 1225,
			"number" : 20079
		},
		{
			"uuid" : "dfbe68a1-6152-974e-8a32-4df441c86afa",
			"name" : "20080",
			"_clazz" : "TwkSegment",
			"brick" : "RIGHT",
			"from" : 1236,
			"face" : "right",
			"tags" : [
				"P14"
			],
			"type" : "panel",
			"to" : 1280,
			"number" : 20080
		},
		{
			"uuid" : "73450208-03e0-784d-8ba6-ab6cf036b66c",
			"name" : "20081",
			"_clazz" : "TwkSegment",
			"brick" : "FRONT",
			"from" : 1281,
			"face" : "front",
			"tags" : [
				"P14"
			],
			"type" : "panel",
			"to" : 1233,
			"number" : 20081
		},
		{
			"uuid" : "7628e1c1-eede-f448-90b6-43e46cb734f4",
			"name" : "20082",
			"_clazz" : "TwkSegment",
			"brick" : "FRONT",
			"from" : 1234,
			"face" : "front",
			"tags" : [
				"P14"
			],
			"type" : "panel",
			"to" : 1281,
			"number" : 20082
		},
		{
			"uuid" : "97396407-42f1-5c44-9851-09f729498213",
			"name" : "20083",
			"_clazz" : "TwkSegment",
			"brick" : "LEFT",
			"from" : 1282,
			"face" : "left",
			"tags" : [
				"P14"
			],
			"type" : "panel",
			"to" : 1234,
			"number" : 20083
		},
		{
			"uuid" : "f7e829da-a1cf-eb4b-ab08-0d83a83b4fc5",
			"name" : "20084",
			"_clazz" : "TwkSegment",
			"brick" : "LEFT",
			"from" : 1235,
			"face" : "left",
			"tags" : [
				"P14"
			],
			"type" : "panel",
			"to" : 1282,
			"number" : 20084
		},
		{
			"uuid" : "347d80ee-713f-3141-beb4-3010d0634f8a",
			"name" : "20085",
			"_clazz" : "TwkSegment",
			"brick" : "BACK",
			"from" : 1283,
			"face" : "back",
			"tags" : [
				"P14"
			],
			"type" : "panel",
			"to" : 1235,
			"number" : 20085
		},
		{
			"uuid" : "580e5707-5b26-864a-8fc5-04311e652c82",
			"name" : "20086",
			"_clazz" : "TwkSegment",
			"brick" : "BACK",
			"from" : 1236,
			"face" : "back",
			"tags" : [
				"P14"
			],
			"type" : "panel",
			"to" : 1283,
			"number" : 20086
		},
		{
			"uuid" : "9de24ae7-6216-364a-a219-2d08494dac2e",
			"name" : "20087",
			"_clazz" : "TwkSegment",
			"brick" : "RIGHT",
			"from" : 1284,
			"face" : "right",
			"tags" : [
				"P14"
			],
			"type" : "panel",
			"to" : 1236,
			"number" : 20087
		},
		{
			"uuid" : "b46740ce-9a32-4849-a153-794d636c637f",
			"name" : "20088",
			"_clazz" : "TwkSegment",
			"brick" : "RIGHT",
			"from" : 1233,
			"face" : "right",
			"tags" : [
				"P14"
			],
			"type" : "panel",
			"to" : 1284,
			"number" : 20088
		},
		{
			"uuid" : "c2959b98-430a-f840-8dce-9f4d4fcfb7c2",
			"name" : "20089",
			"_clazz" : "TwkSegment",
			"brick" : "FRONT",
			"from" : 1242,
			"face" : "front",
			"tags" : [
				"P14"
			],
			"type" : "panel",
			"to" : 1281,
			"number" : 20089
		},
		{
			"uuid" : "583473db-1759-7f4f-ab9e-1c82a7d4b5d4",
			"name" : "20090",
			"_clazz" : "TwkSegment",
			"brick" : "FRONT",
			"from" : 1281,
			"face" : "front",
			"tags" : [
				"P14"
			],
			"type" : "panel",
			"to" : 1241,
			"number" : 20090
		},
		{
			"uuid" : "b237aa3f-3872-6040-9d00-f8ecb6939603",
			"name" : "20091",
			"_clazz" : "TwkSegment",
			"brick" : "LEFT",
			"from" : 1243,
			"face" : "left",
			"tags" : [
				"P14"
			],
			"type" : "panel",
			"to" : 1282,
			"number" : 20091
		},
		{
			"uuid" : "94834364-0d07-974b-82a6-7b57a8b7907c",
			"name" : "20092",
			"_clazz" : "TwkSegment",
			"brick" : "LEFT",
			"from" : 1282,
			"face" : "left",
			"tags" : [
				"P14"
			],
			"type" : "panel",
			"to" : 1242,
			"number" : 20092
		},
		{
			"uuid" : "7c4f3af2-1b8b-e941-9ac1-34057186a593",
			"name" : "20093",
			"_clazz" : "TwkSegment",
			"brick" : "BACK",
			"from" : 1244,
			"face" : "back",
			"tags" : [
				"P14"
			],
			"type" : "panel",
			"to" : 1283,
			"number" : 20093
		},
		{
			"uuid" : "45652998-d112-d14f-ae53-1a86cd83468e",
			"name" : "20094",
			"_clazz" : "TwkSegment",
			"brick" : "BACK",
			"from" : 1283,
			"face" : "back",
			"tags" : [
				"P14"
			],
			"type" : "panel",
			"to" : 1243,
			"number" : 20094
		},
		{
			"uuid" : "a588f118-5a59-5148-ac3c-1a5803768c36",
			"name" : "20095",
			"_clazz" : "TwkSegment",
			"brick" : "RIGHT",
			"from" : 1241,
			"face" : "right",
			"tags" : [
				"P14"
			],
			"type" : "panel",
			"to" : 1284,
			"number" : 20095
		},
		{
			"uuid" : "073913e9-823c-c140-b65f-2a5dc0ff92cf",
			"name" : "20096",
			"_clazz" : "TwkSegment",
			"brick" : "RIGHT",
			"from" : 1284,
			"face" : "right",
			"tags" : [
				"P14"
			],
			"type" : "panel",
			"to" : 1244,
			"number" : 20096
		},
		{
			"uuid" : "ef50d75c-467d-2d4e-96e6-160990f29f2f",
			"name" : "20097",
			"_clazz" : "TwkSegment",
			"brick" : "FRONT",
			"from" : 1285,
			"face" : "front",
			"tags" : [
				"P14"
			],
			"type" : "panel",
			"to" : 1241,
			"number" : 20097
		},
		{
			"uuid" : "1f3d5290-a86c-d449-92b1-2d8ab01aa3f3",
			"name" : "20098",
			"_clazz" : "TwkSegment",
			"brick" : "FRONT",
			"from" : 1250,
			"face" : "front",
			"tags" : [
				"P14"
			],
			"type" : "panel",
			"to" : 1285,
			"number" : 20098
		},
		{
			"uuid" : "c471031c-f718-0346-8f0d-c4bfd8680adc",
			"name" : "20099",
			"_clazz" : "TwkSegment",
			"brick" : "FRONT",
			"from" : 1285,
			"face" : "front",
			"tags" : [
				"P14"
			],
			"type" : "panel",
			"to" : 1242,
			"number" : 20099
		},
		{
			"uuid" : "a6fe05ff-2a7e-f145-9600-2ede47ee23c2",
			"name" : "20100",
			"_clazz" : "TwkSegment",
			"brick" : "FRONT",
			"from" : 1249,
			"face" : "front",
			"tags" : [
				"P14"
			],
			"type" : "panel",
			"to" : 1285,
			"number" : 20100
		},
		{
			"uuid" : "07803b05-75e7-d043-8999-e1e95812da60",
			"name" : "20101",
			"_clazz" : "TwkSegment",
			"brick" : "LEFT",
			"from" : 1286,
			"face" : "left",
			"tags" : [
				"P14"
			],
			"type" : "panel",
			"to" : 1242,
			"number" : 20101
		},
		{
			"uuid" : "a0180856-c49e-bd45-9655-afb8664daff9",
			"name" : "20102",
			"_clazz" : "TwkSegment",
			"brick" : "LEFT",
			"from" : 1251,
			"face" : "left",
			"tags" : [
				"P14"
			],
			"type" : "panel",
			"to" : 1286,
			"number" : 20102
		},
		{
			"uuid" : "4c08c118-3b12-f847-ae52-0df94c89e3e9",
			"name" : "20103",
			"_clazz" : "TwkSegment",
			"brick" : "LEFT",
			"from" : 1286,
			"face" : "left",
			"tags" : [
				"P14"
			],
			"type" : "panel",
			"to" : 1243,
			"number" : 20103
		},
		{
			"uuid" : "46b08b4d-637e-904e-9e43-87d6207e795f",
			"name" : "20104",
			"_clazz" : "TwkSegment",
			"brick" : "LEFT",
			"from" : 1250,
			"face" : "left",
			"tags" : [
				"P14"
			],
			"type" : "panel",
			"to" : 1286,
			"number" : 20104
		},
		{
			"uuid" : "1bb5922a-479c-5346-94cf-714f103cf443",
			"name" : "20105",
			"_clazz" : "TwkSegment",
			"brick" : "BACK",
			"from" : 1287,
			"face" : "back",
			"tags" : [
				"P14"
			],
			"type" : "panel",
			"to" : 1243,
			"number" : 20105
		},
		{
			"uuid" : "3e475122-2755-924d-9f38-10a274f5f389",
			"name" : "20106",
			"_clazz" : "TwkSegment",
			"brick" : "BACK",
			"from" : 1252,
			"face" : "back",
			"tags" : [
				"P14"
			],
			"type" : "panel",
			"to" : 1287,
			"number" : 20106
		},
		{
			"uuid" : "812d2b18-f9b2-214b-acba-6e4ff26cfef1",
			"name" : "20107",
			"_clazz" : "TwkSegment",
			"brick" : "BACK",
			"from" : 1287,
			"face" : "back",
			"tags" : [
				"P14"
			],
			"type" : "panel",
			"to" : 1244,
			"number" : 20107
		},
		{
			"uuid" : "48dd57eb-b798-b24b-a6a4-47f0e62bd0b2",
			"name" : "20108",
			"_clazz" : "TwkSegment",
			"brick" : "BACK",
			"from" : 1251,
			"face" : "back",
			"tags" : [
				"P14"
			],
			"type" : "panel",
			"to" : 1287,
			"number" : 20108
		},
		{
			"uuid" : "977c8f23-7496-5c4a-873d-fc99961e6a27",
			"name" : "20109",
			"_clazz" : "TwkSegment",
			"brick" : "RIGHT",
			"from" : 1288,
			"face" : "right",
			"tags" : [
				"P14"
			],
			"type" : "panel",
			"to" : 1244,
			"number" : 20109
		},
		{
			"uuid" : "bf8b79e9-d79a-4543-a0f6-2bdaa770d077",
			"name" : "20110",
			"_clazz" : "TwkSegment",
			"brick" : "RIGHT",
			"from" : 1249,
			"face" : "right",
			"tags" : [
				"P14"
			],
			"type" : "panel",
			"to" : 1288,
			"number" : 20110
		},
		{
			"uuid" : "c7af3583-3615-a44e-9cd6-edc9a810cbf3",
			"name" : "20111",
			"_clazz" : "TwkSegment",
			"brick" : "RIGHT",
			"from" : 1288,
			"face" : "right",
			"tags" : [
				"P14"
			],
			"type" : "panel",
			"to" : 1241,
			"number" : 20111
		},
		{
			"uuid" : "5edb29aa-4042-7a42-bbec-8fa643dac449",
			"name" : "20112",
			"_clazz" : "TwkSegment",
			"brick" : "RIGHT",
			"from" : 1252,
			"face" : "right",
			"tags" : [
				"P14"
			],
			"type" : "panel",
			"to" : 1288,
			"number" : 20112
		},
		{
			"uuid" : "11704298-d66f-6b4a-b1ce-c9d45962c323",
			"name" : "20113",
			"_clazz" : "TwkSegment",
			"brick" : "FRONT",
			"from" : 1289,
			"face" : "front",
			"tags" : [
				"P14"
			],
			"type" : "panel",
			"to" : 1249,
			"number" : 20113
		},
		{
			"uuid" : "f9a58816-98a3-a64a-a986-9460847e5596",
			"name" : "20114",
			"_clazz" : "TwkSegment",
			"brick" : "FRONT",
			"from" : 1258,
			"face" : "front",
			"tags" : [
				"P14"
			],
			"type" : "panel",
			"to" : 1289,
			"number" : 20114
		},
		{
			"uuid" : "46dc7106-52a6-a546-aeb9-b4a4a20e299f",
			"name" : "20115",
			"_clazz" : "TwkSegment",
			"brick" : "FRONT",
			"from" : 1289,
			"face" : "front",
			"tags" : [
				"P14"
			],
			"type" : "panel",
			"to" : 1250,
			"number" : 20115
		},
		{
			"uuid" : "23f88aeb-5220-7d46-bcec-a27b9a38c031",
			"name" : "20116",
			"_clazz" : "TwkSegment",
			"brick" : "FRONT",
			"from" : 1257,
			"face" : "front",
			"tags" : [
				"P14"
			],
			"type" : "panel",
			"to" : 1289,
			"number" : 20116
		},
		{
			"uuid" : "243529c0-e81a-d647-95fa-1abb0de837b2",
			"name" : "20117",
			"_clazz" : "TwkSegment",
			"brick" : "LEFT",
			"from" : 1290,
			"face" : "left",
			"tags" : [
				"P14"
			],
			"type" : "panel",
			"to" : 1250,
			"number" : 20117
		},
		{
			"uuid" : "77f5ed65-1105-b644-b100-849565d1f85f",
			"name" : "20118",
			"_clazz" : "TwkSegment",
			"brick" : "LEFT",
			"from" : 1259,
			"face" : "left",
			"tags" : [
				"P14"
			],
			"type" : "panel",
			"to" : 1290,
			"number" : 20118
		},
		{
			"uuid" : "3d3bd981-0834-2f49-b166-f66bc2ca1b9c",
			"name" : "20119",
			"_clazz" : "TwkSegment",
			"brick" : "LEFT",
			"from" : 1290,
			"face" : "left",
			"tags" : [
				"P14"
			],
			"type" : "panel",
			"to" : 1251,
			"number" : 20119
		},
		{
			"uuid" : "cba02d8d-71a8-4d48-ba04-a1a919f1232f",
			"name" : "20120",
			"_clazz" : "TwkSegment",
			"brick" : "LEFT",
			"from" : 1258,
			"face" : "left",
			"tags" : [
				"P14"
			],
			"type" : "panel",
			"to" : 1290,
			"number" : 20120
		},
		{
			"uuid" : "b2a0197a-c340-1c41-aeef-71b29337302d",
			"name" : "20121",
			"_clazz" : "TwkSegment",
			"brick" : "BACK",
			"from" : 1291,
			"face" : "back",
			"tags" : [
				"P14"
			],
			"type" : "panel",
			"to" : 1251,
			"number" : 20121
		},
		{
			"uuid" : "6fdc34b3-9f91-ce4f-a04c-19a353ef875e",
			"name" : "20122",
			"_clazz" : "TwkSegment",
			"brick" : "BACK",
			"from" : 1260,
			"face" : "back",
			"tags" : [
				"P14"
			],
			"type" : "panel",
			"to" : 1291,
			"number" : 20122
		},
		{
			"uuid" : "e7e83d8b-3081-8e48-8feb-85de93e2de3f",
			"name" : "20123",
			"_clazz" : "TwkSegment",
			"brick" : "BACK",
			"from" : 1291,
			"face" : "back",
			"tags" : [
				"P14"
			],
			"type" : "panel",
			"to" : 1252,
			"number" : 20123
		},
		{
			"uuid" : "4f9f011f-52e5-944d-ac9a-5c8d2a10bba1",
			"name" : "20124",
			"_clazz" : "TwkSegment",
			"brick" : "BACK",
			"from" : 1259,
			"face" : "back",
			"tags" : [
				"P14"
			],
			"type" : "panel",
			"to" : 1291,
			"number" : 20124
		},
		{
			"uuid" : "532e7e11-f1ca-ac40-bb3a-b2d3ef2b8d86",
			"name" : "20125",
			"_clazz" : "TwkSegment",
			"brick" : "RIGHT",
			"from" : 1292,
			"face" : "right",
			"tags" : [
				"P14"
			],
			"type" : "panel",
			"to" : 1252,
			"number" : 20125
		},
		{
			"uuid" : "d574780c-4b60-eb4b-aefa-9c5d4ae2c089",
			"name" : "20126",
			"_clazz" : "TwkSegment",
			"brick" : "RIGHT",
			"from" : 1257,
			"face" : "right",
			"tags" : [
				"P14"
			],
			"type" : "panel",
			"to" : 1292,
			"number" : 20126
		},
		{
			"uuid" : "67c803ae-13b1-0f4a-a502-b431a5374463",
			"name" : "20127",
			"_clazz" : "TwkSegment",
			"brick" : "RIGHT",
			"from" : 1292,
			"face" : "right",
			"tags" : [
				"P14"
			],
			"type" : "panel",
			"to" : 1249,
			"number" : 20127
		},
		{
			"uuid" : "19563ba0-9b6b-4841-9ee0-df441b20a52f",
			"name" : "20128",
			"_clazz" : "TwkSegment",
			"brick" : "RIGHT",
			"from" : 1260,
			"face" : "right",
			"tags" : [
				"P14"
			],
			"type" : "panel",
			"to" : 1292,
			"number" : 20128
		},
		{
			"number" : 12001,
			"tags" : [
				"P15"
			],
			"type" : "slope",
			"to" : 1301,
			"from" : 1300,
			"brick" : "P15",
			"name" : "12001",
			"uuid" : "6a534990-d41c-8748-84c5-bce230d3e015",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 12002,
			"tags" : [
				"P15"
			],
			"type" : "slope",
			"to" : 1302,
			"from" : 1300,
			"brick" : "P15",
			"name" : "12002",
			"uuid" : "bc0df0f7-749a-c34a-b171-8c8ccf155e66",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 12003,
			"tags" : [
				"P15"
			],
			"type" : "slope",
			"to" : 1303,
			"from" : 1300,
			"brick" : "P15",
			"name" : "12003",
			"uuid" : "0623d19a-bfb7-a541-b456-23691c9e6caf",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 12004,
			"tags" : [
				"P15"
			],
			"type" : "slope",
			"to" : 1304,
			"from" : 1300,
			"brick" : "P15",
			"name" : "12004",
			"uuid" : "b103161c-3bad-6d48-bedf-fe8d31c89bf0",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 12005,
			"tags" : [
				"P15"
			],
			"type" : "slope",
			"to" : 1305,
			"from" : 1301,
			"brick" : "P15",
			"name" : "12005",
			"uuid" : "b2a9b66f-35fd-0b47-9e10-9ebf4c8c1657",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 12006,
			"tags" : [
				"P15"
			],
			"type" : "slope",
			"to" : 1306,
			"from" : 1302,
			"brick" : "P15",
			"name" : "12006",
			"uuid" : "4a47c1fd-74ef-1540-8a6b-f74c14682a3c",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 12007,
			"tags" : [
				"P15"
			],
			"type" : "slope",
			"to" : 1307,
			"from" : 1303,
			"brick" : "P15",
			"name" : "12007",
			"uuid" : "d6d0bd2d-a076-5942-bc39-1ec764a9095e",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 12008,
			"tags" : [
				"P15"
			],
			"type" : "slope",
			"to" : 1308,
			"from" : 1304,
			"brick" : "P15",
			"name" : "12008",
			"uuid" : "8abaaa7d-e93f-9849-bad9-0d8beb2cd02b",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 12009,
			"tags" : [
				"P15"
			],
			"type" : "slope",
			"to" : 1309,
			"from" : 1305,
			"brick" : "P15",
			"name" : "12009",
			"uuid" : "0218aa7a-28ff-bf4f-8d16-d8ef9fa5244f",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 12010,
			"tags" : [
				"P15"
			],
			"type" : "slope",
			"to" : 1310,
			"from" : 1306,
			"brick" : "P15",
			"name" : "12010",
			"uuid" : "d14e0603-e19a-8c4d-af5d-eb7a62e6b886",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 12011,
			"tags" : [
				"P15"
			],
			"type" : "slope",
			"to" : 1311,
			"from" : 1307,
			"brick" : "P15",
			"name" : "12011",
			"uuid" : "3453b9a0-f465-0941-944b-71dae1148a1c",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 12012,
			"tags" : [
				"P15"
			],
			"type" : "slope",
			"to" : 1312,
			"from" : 1308,
			"brick" : "P15",
			"name" : "12012",
			"uuid" : "f14789c9-c33f-f645-9c9b-4c35c820c738",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 12013,
			"tags" : [
				"P15"
			],
			"type" : "slope",
			"to" : 1313,
			"from" : 1309,
			"brick" : "P15",
			"name" : "12013",
			"uuid" : "9066e1a4-f04a-2046-8ea7-65223a51ea93",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 12014,
			"tags" : [
				"P15"
			],
			"type" : "slope",
			"to" : 1314,
			"from" : 1310,
			"brick" : "P15",
			"name" : "12014",
			"uuid" : "65b97c85-96b0-164c-862f-7d8d4dee90a3",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 12015,
			"tags" : [
				"P15"
			],
			"type" : "slope",
			"to" : 1315,
			"from" : 1311,
			"brick" : "P15",
			"name" : "12015",
			"uuid" : "c087beae-58a7-374d-8373-f32074393555",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 12016,
			"tags" : [
				"P15"
			],
			"type" : "slope",
			"to" : 1316,
			"from" : 1312,
			"brick" : "P15",
			"name" : "12016",
			"uuid" : "b91603c6-77c4-7c47-8e56-ace2f1e8a3ba",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 12017,
			"tags" : [
				"P15"
			],
			"type" : "slope",
			"to" : 1317,
			"from" : 1313,
			"brick" : "P15",
			"name" : "12017",
			"uuid" : "27b9b61a-322b-4a49-a353-b2c99d46e3a4",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 12018,
			"tags" : [
				"P15"
			],
			"type" : "slope",
			"to" : 1318,
			"from" : 1314,
			"brick" : "P15",
			"name" : "12018",
			"uuid" : "eac2ecf1-44c4-7d4d-a0f9-3cb6aa414c9f",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 12019,
			"tags" : [
				"P15"
			],
			"type" : "slope",
			"to" : 1319,
			"from" : 1315,
			"brick" : "P15",
			"name" : "12019",
			"uuid" : "0937a3b9-12b2-2a4f-acc6-925c8c05e27b",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 12020,
			"tags" : [
				"P15"
			],
			"type" : "slope",
			"to" : 1320,
			"from" : 1316,
			"brick" : "P15",
			"name" : "12020",
			"uuid" : "910c7c12-5722-1640-8a78-6a9c60fd1c5c",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 12021,
			"tags" : [
				"P15"
			],
			"type" : "slope",
			"to" : 1321,
			"from" : 1317,
			"brick" : "P15",
			"name" : "12021",
			"uuid" : "9ef0234a-8fe3-1a40-8d16-13462729a68b",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 12022,
			"tags" : [
				"P15"
			],
			"type" : "slope",
			"to" : 1322,
			"from" : 1318,
			"brick" : "P15",
			"name" : "12022",
			"uuid" : "600d800c-10bd-2a41-9941-95d35be7230a",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 12023,
			"tags" : [
				"P15"
			],
			"type" : "slope",
			"to" : 1323,
			"from" : 1319,
			"brick" : "P15",
			"name" : "12023",
			"uuid" : "5db1c116-e0b4-684a-a053-9a1a2365901a",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 12024,
			"tags" : [
				"P15"
			],
			"type" : "slope",
			"to" : 1324,
			"from" : 1320,
			"brick" : "P15",
			"name" : "12024",
			"uuid" : "9e28b8ee-49ca-874a-8adb-70472378559f",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 12025,
			"tags" : [
				"P15"
			],
			"type" : "slope",
			"to" : 1325,
			"from" : 1321,
			"brick" : "P15",
			"name" : "12025",
			"uuid" : "9c641598-197b-074c-a1ca-67e824f9e5d7",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 12026,
			"tags" : [
				"P15"
			],
			"type" : "slope",
			"to" : 1326,
			"from" : 1322,
			"brick" : "P15",
			"name" : "12026",
			"uuid" : "248b12fc-9f14-f541-9d79-048371f6568c",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 12027,
			"tags" : [
				"P15"
			],
			"type" : "slope",
			"to" : 1327,
			"from" : 1323,
			"brick" : "P15",
			"name" : "12027",
			"uuid" : "249958f2-b8b4-4743-a9e2-f77bdae4e8b4",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 12028,
			"tags" : [
				"P15"
			],
			"type" : "slope",
			"to" : 1328,
			"from" : 1324,
			"brick" : "P15",
			"name" : "12028",
			"uuid" : "c61c93e0-b602-9140-b0ac-fef8ee0ac445",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 12029,
			"tags" : [
				"P15"
			],
			"type" : "slope",
			"to" : 1329,
			"from" : 1325,
			"brick" : "P15",
			"name" : "12029",
			"uuid" : "d3f2996f-8a9b-6c4d-9d8e-bf134a62f7ee",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 12030,
			"tags" : [
				"P15"
			],
			"type" : "slope",
			"to" : 1330,
			"from" : 1326,
			"brick" : "P15",
			"name" : "12030",
			"uuid" : "62999cd9-356c-0248-b102-a4a601ee1a64",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 12031,
			"tags" : [
				"P15"
			],
			"type" : "slope",
			"to" : 1331,
			"from" : 1327,
			"brick" : "P15",
			"name" : "12031",
			"uuid" : "03010817-73b7-634d-8f31-1ccd57008cbb",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 12032,
			"tags" : [
				"P15"
			],
			"type" : "slope",
			"to" : 1332,
			"from" : 1328,
			"brick" : "P15",
			"name" : "12032",
			"uuid" : "5fd0c5df-d94b-4543-919f-f251387047e3",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 12033,
			"tags" : [
				"P15"
			],
			"type" : "slope",
			"to" : 1333,
			"from" : 1329,
			"brick" : "P15",
			"name" : "12033",
			"uuid" : "c2aa8ab0-7d0d-1849-9a19-59d59c6d0f43",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 12034,
			"tags" : [
				"P15"
			],
			"type" : "slope",
			"to" : 1334,
			"from" : 1330,
			"brick" : "P15",
			"name" : "12034",
			"uuid" : "e895f8af-900d-594c-91aa-68908d54fd30",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 12035,
			"tags" : [
				"P15"
			],
			"type" : "slope",
			"to" : 1335,
			"from" : 1331,
			"brick" : "P15",
			"name" : "12035",
			"uuid" : "760eb088-8320-8d41-bdd6-605203976281",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 12036,
			"tags" : [
				"P15"
			],
			"type" : "slope",
			"to" : 1336,
			"from" : 1332,
			"brick" : "P15",
			"name" : "12036",
			"uuid" : "08af25b9-a40d-ae45-b09e-7277d2a89200",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 12037,
			"tags" : [
				"P15"
			],
			"type" : "slope",
			"to" : 1337,
			"from" : 1333,
			"brick" : "P15",
			"name" : "12037",
			"uuid" : "f796c3e0-c1d3-5f44-afa8-7b512a73587c",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 12038,
			"tags" : [
				"P15"
			],
			"type" : "slope",
			"to" : 1338,
			"from" : 1334,
			"brick" : "P15",
			"name" : "12038",
			"uuid" : "30c21939-b948-0348-b213-ef21a19f49d0",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 12039,
			"tags" : [
				"P15"
			],
			"type" : "slope",
			"to" : 1339,
			"from" : 1335,
			"brick" : "P15",
			"name" : "12039",
			"uuid" : "58836771-871e-0743-8acc-f9f618ca7190",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 12040,
			"tags" : [
				"P15"
			],
			"type" : "slope",
			"to" : 1340,
			"from" : 1336,
			"brick" : "P15",
			"name" : "12040",
			"uuid" : "c1c7c911-0441-c74d-9216-d05d102da86d",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 12041,
			"tags" : [
				"P15"
			],
			"type" : "slope",
			"to" : 1341,
			"from" : 1337,
			"brick" : "P15",
			"name" : "12041",
			"uuid" : "442962f2-3d17-904f-b12e-ef9ac7b211dc",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 12042,
			"tags" : [
				"P15"
			],
			"type" : "slope",
			"to" : 1342,
			"from" : 1338,
			"brick" : "P15",
			"name" : "12042",
			"uuid" : "b9c7a02f-b57b-c44f-bac9-05ad602409d5",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 12043,
			"tags" : [
				"P15"
			],
			"type" : "slope",
			"to" : 1343,
			"from" : 1339,
			"brick" : "P15",
			"name" : "12043",
			"uuid" : "4ace1727-c0c3-3542-ac03-446fde7b2211",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 12044,
			"tags" : [
				"P15"
			],
			"type" : "slope",
			"to" : 1344,
			"from" : 1340,
			"brick" : "P15",
			"name" : "12044",
			"uuid" : "b89cdacc-d1da-0947-a3a2-5de32c7e4196",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 12045,
			"tags" : [
				"P15"
			],
			"type" : "slope",
			"to" : 1345,
			"from" : 1341,
			"brick" : "P15",
			"name" : "12045",
			"uuid" : "57515460-7d69-3341-9618-fc410379f249",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 12046,
			"tags" : [
				"P15"
			],
			"type" : "slope",
			"to" : 1346,
			"from" : 1342,
			"brick" : "P15",
			"name" : "12046",
			"uuid" : "d10006a0-3d3f-7840-b4a6-7a716f01af31",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 12047,
			"tags" : [
				"P15"
			],
			"type" : "slope",
			"to" : 1347,
			"from" : 1343,
			"brick" : "P15",
			"name" : "12047",
			"uuid" : "7518b9f2-ee1e-384f-b797-08a1a97f35b9",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 12048,
			"tags" : [
				"P15"
			],
			"type" : "slope",
			"to" : 1348,
			"from" : 1344,
			"brick" : "P15",
			"name" : "12048",
			"uuid" : "e3bff77f-8b70-1849-b971-ebb50120423b",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 12049,
			"tags" : [
				"P15"
			],
			"type" : "slope",
			"to" : 1349,
			"from" : 1345,
			"brick" : "P15",
			"name" : "12049",
			"uuid" : "6ef85c4d-acdb-fa40-a06a-1d3bdba3e802",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 12050,
			"tags" : [
				"P15"
			],
			"type" : "slope",
			"to" : 1350,
			"from" : 1346,
			"brick" : "P15",
			"name" : "12050",
			"uuid" : "e4814f57-12c5-8e41-a6b1-6df72bcf73a7",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 12051,
			"tags" : [
				"P15"
			],
			"type" : "slope",
			"to" : 1351,
			"from" : 1347,
			"brick" : "P15",
			"name" : "12051",
			"uuid" : "a31e8778-de4c-8040-9ddd-4940f2175f26",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 12052,
			"tags" : [
				"P15"
			],
			"type" : "slope",
			"to" : 1352,
			"from" : 1348,
			"brick" : "P15",
			"name" : "12052",
			"uuid" : "987addad-9fc6-d241-b6e1-e35547b3de18",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 12053,
			"tags" : [
				"P15"
			],
			"type" : "slope",
			"to" : 1353,
			"from" : 1349,
			"brick" : "P15",
			"name" : "12053",
			"uuid" : "70088262-5141-7e4d-a69a-884d614f8bb5",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 12054,
			"tags" : [
				"P15"
			],
			"type" : "slope",
			"to" : 1354,
			"from" : 1350,
			"brick" : "P15",
			"name" : "12054",
			"uuid" : "fe3dc548-b924-c841-b3b4-037ab60ef659",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 12055,
			"tags" : [
				"P15"
			],
			"type" : "slope",
			"to" : 1355,
			"from" : 1351,
			"brick" : "P15",
			"name" : "12055",
			"uuid" : "d6c07c29-5fff-6e4e-ba98-162ffbe3f471",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 12056,
			"tags" : [
				"P15"
			],
			"type" : "slope",
			"to" : 1356,
			"from" : 1352,
			"brick" : "P15",
			"name" : "12056",
			"uuid" : "c1c3a368-bd9b-0d49-8880-72c40a94c303",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 12057,
			"tags" : [
				"P15"
			],
			"type" : "slope",
			"to" : 1357,
			"from" : 1353,
			"brick" : "P15",
			"name" : "12057",
			"uuid" : "aac97691-01ea-c444-995b-9cbe439725b7",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 12058,
			"tags" : [
				"P15"
			],
			"type" : "slope",
			"to" : 1358,
			"from" : 1354,
			"brick" : "P15",
			"name" : "12058",
			"uuid" : "ba20dea7-2de5-9947-b16a-a69afc9f4ddf",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 12059,
			"tags" : [
				"P15"
			],
			"type" : "slope",
			"to" : 1359,
			"from" : 1355,
			"brick" : "P15",
			"name" : "12059",
			"uuid" : "2a5645cc-594c-6e40-84ab-aeeb34469850",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 12060,
			"tags" : [
				"P15"
			],
			"type" : "slope",
			"to" : 1360,
			"from" : 1356,
			"brick" : "P15",
			"name" : "12060",
			"uuid" : "e1b281bf-a508-8648-8dc0-02f5ebb643f9",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 12061,
			"tags" : [
				"P15"
			],
			"type" : "slope",
			"to" : 1361,
			"from" : 1357,
			"brick" : "P15",
			"name" : "12061",
			"uuid" : "c121dccb-49a7-b545-b97e-ed6dada35de8",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 12062,
			"tags" : [
				"P15"
			],
			"type" : "slope",
			"to" : 1362,
			"from" : 1358,
			"brick" : "P15",
			"name" : "12062",
			"uuid" : "42000b02-0b5f-5841-bfaf-e1b525d0a22d",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 12063,
			"tags" : [
				"P15"
			],
			"type" : "slope",
			"to" : 1363,
			"from" : 1359,
			"brick" : "P15",
			"name" : "12063",
			"uuid" : "d847db79-b8ee-6349-9d7e-8eca947ebed8",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 12064,
			"tags" : [
				"P15"
			],
			"type" : "slope",
			"to" : 1364,
			"from" : 1360,
			"brick" : "P15",
			"name" : "12064",
			"uuid" : "5fa00cdd-fe47-aa46-b1f3-93fd1241826a",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 12065,
			"tags" : [
				"P15"
			],
			"type" : "slope",
			"to" : 1365,
			"from" : 1361,
			"brick" : "P15",
			"name" : "12065",
			"uuid" : "c0c9bbaa-8f44-4f4e-ae2e-a332d798e87c",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 12066,
			"tags" : [
				"P15"
			],
			"type" : "slope",
			"to" : 1366,
			"from" : 1362,
			"brick" : "P15",
			"name" : "12066",
			"uuid" : "875265a7-80e6-2840-82b7-3f71c2ae31fa",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 12067,
			"tags" : [
				"P15"
			],
			"type" : "slope",
			"to" : 1367,
			"from" : 1363,
			"brick" : "P15",
			"name" : "12067",
			"uuid" : "f331e5ed-2f14-f447-ac7e-22630ac6247a",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 12068,
			"tags" : [
				"P15"
			],
			"type" : "slope",
			"to" : 1368,
			"from" : 1364,
			"brick" : "P15",
			"name" : "12068",
			"uuid" : "63dfe924-4979-dc41-84db-4f58ebf6a601",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 12069,
			"tags" : [
				"P15"
			],
			"type" : "slope",
			"to" : 1369,
			"from" : 1365,
			"brick" : "P15",
			"name" : "12069",
			"uuid" : "14dcaaef-e958-514f-bf85-6ea329e5ccec",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 12070,
			"tags" : [
				"P15"
			],
			"type" : "slope",
			"to" : 1370,
			"from" : 1366,
			"brick" : "P15",
			"name" : "12070",
			"uuid" : "5c1a92f0-f87a-7344-a6b0-0e6897d772db",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 12071,
			"tags" : [
				"P15"
			],
			"type" : "slope",
			"to" : 1371,
			"from" : 1367,
			"brick" : "P15",
			"name" : "12071",
			"uuid" : "a856c964-039b-6342-8e1c-53eb3d5e3a4a",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 12072,
			"tags" : [
				"P15"
			],
			"type" : "slope",
			"to" : 1372,
			"from" : 1368,
			"brick" : "P15",
			"name" : "12072",
			"uuid" : "b1c3e234-55a1-604e-900f-bd5c41bcb2da",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 12073,
			"tags" : [
				"P15"
			],
			"type" : "slope",
			"to" : 1373,
			"from" : 1369,
			"brick" : "P15",
			"name" : "12073",
			"uuid" : "c61772b9-76fd-d347-86aa-251a3d0323eb",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 12074,
			"tags" : [
				"P15"
			],
			"type" : "slope",
			"to" : 1374,
			"from" : 1370,
			"brick" : "P15",
			"name" : "12074",
			"uuid" : "a187e197-5a7c-cf4a-97f2-904609312550",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 12075,
			"tags" : [
				"P15"
			],
			"type" : "slope",
			"to" : 1375,
			"from" : 1371,
			"brick" : "P15",
			"name" : "12075",
			"uuid" : "8f4367fb-8d4f-b643-b0e6-c03a04c4a393",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 12076,
			"tags" : [
				"P15"
			],
			"type" : "slope",
			"to" : 1376,
			"from" : 1372,
			"brick" : "P15",
			"name" : "12076",
			"uuid" : "606f93c7-aec1-9e43-80ab-6b1647c92ce2",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 30001,
			"tags" : [
				"P15"
			],
			"type" : "sectionRound",
			"to" : 1302,
			"from" : 1301,
			"brick" : "P15",
			"name" : "30001",
			"uuid" : "62cd33a6-e076-a841-9750-4ac281911285",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 30002,
			"tags" : [
				"P15"
			],
			"type" : "sectionRound",
			"to" : 1303,
			"from" : 1302,
			"brick" : "P15",
			"name" : "30002",
			"uuid" : "25a59bc1-3e16-b040-912d-c9ab4b758f14",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 30003,
			"tags" : [
				"P15"
			],
			"type" : "sectionRound",
			"to" : 1304,
			"from" : 1303,
			"brick" : "P15",
			"name" : "30003",
			"uuid" : "a5f01440-eb74-b543-9793-52840e401585",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 30004,
			"tags" : [
				"P15"
			],
			"type" : "sectionRound",
			"to" : 1301,
			"from" : 1304,
			"brick" : "P15",
			"name" : "30004",
			"uuid" : "afdd8c6d-e55c-8c44-b8c5-a009dbd9d389",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 30005,
			"tags" : [
				"P15"
			],
			"type" : "sectionRound",
			"to" : 1306,
			"from" : 1305,
			"brick" : "P15",
			"name" : "30005",
			"uuid" : "e98735c7-da7b-494b-8de0-e9eec27a6919",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 30006,
			"tags" : [
				"P15"
			],
			"type" : "sectionRound",
			"to" : 1307,
			"from" : 1306,
			"brick" : "P15",
			"name" : "30006",
			"uuid" : "74ee3b84-e3a4-c34a-a1ea-8a69fd69d532",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 30007,
			"tags" : [
				"P15"
			],
			"type" : "sectionRound",
			"to" : 1308,
			"from" : 1307,
			"brick" : "P15",
			"name" : "30007",
			"uuid" : "e8ff5d19-6d8e-7e42-a4e6-fd7260c4598b",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 30008,
			"tags" : [
				"P15"
			],
			"type" : "sectionRound",
			"to" : 1305,
			"from" : 1308,
			"brick" : "P15",
			"name" : "30008",
			"uuid" : "f6a1369f-8653-5545-be69-cfeb4d3b1997",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 30009,
			"tags" : [
				"P15"
			],
			"type" : "sectionRound",
			"to" : 1310,
			"from" : 1309,
			"brick" : "P15",
			"name" : "30009",
			"uuid" : "0fe5a385-ea5e-1344-ba65-a56fabf6c508",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 30010,
			"tags" : [
				"P15"
			],
			"type" : "sectionRound",
			"to" : 1311,
			"from" : 1310,
			"brick" : "P15",
			"name" : "30010",
			"uuid" : "e2ed977e-54b5-8347-a23b-e2c8da576b8d",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 30011,
			"tags" : [
				"P15"
			],
			"type" : "sectionRound",
			"to" : 1312,
			"from" : 1311,
			"brick" : "P15",
			"name" : "30011",
			"uuid" : "14f59e50-e035-d940-ad9a-f67c72412ce6",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 30012,
			"tags" : [
				"P15"
			],
			"type" : "sectionRound",
			"to" : 1309,
			"from" : 1312,
			"brick" : "P15",
			"name" : "30012",
			"uuid" : "84aa5f2c-ac74-e049-a4cd-1d04f85b2722",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 30013,
			"tags" : [
				"P15"
			],
			"type" : "sectionRound",
			"to" : 1314,
			"from" : 1313,
			"brick" : "P15",
			"name" : "30013",
			"uuid" : "7f1fc0e2-068b-9442-b917-2642470e5d28",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 30014,
			"tags" : [
				"P15"
			],
			"type" : "sectionRound",
			"to" : 1315,
			"from" : 1314,
			"brick" : "P15",
			"name" : "30014",
			"uuid" : "f6c20fe8-3e38-894a-8e7d-d9ab57bbee57",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 30015,
			"tags" : [
				"P15"
			],
			"type" : "sectionRound",
			"to" : 1316,
			"from" : 1315,
			"brick" : "P15",
			"name" : "30015",
			"uuid" : "494d1b6b-16d4-8142-a269-0f94f10667b4",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 30016,
			"tags" : [
				"P15"
			],
			"type" : "sectionRound",
			"to" : 1313,
			"from" : 1316,
			"brick" : "P15",
			"name" : "30016",
			"uuid" : "66f41ab5-f485-0440-9986-2c52c4728fee",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 30017,
			"tags" : [
				"P15"
			],
			"type" : "sectionRound",
			"to" : 1318,
			"from" : 1317,
			"brick" : "P15",
			"name" : "30017",
			"uuid" : "61fbea00-2ef1-f84e-af4f-990c8f17cff9",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 30018,
			"tags" : [
				"P15"
			],
			"type" : "sectionRound",
			"to" : 1319,
			"from" : 1318,
			"brick" : "P15",
			"name" : "30018",
			"uuid" : "eb83b9bb-5867-3941-81b5-996e6ec30e33",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 30019,
			"tags" : [
				"P15"
			],
			"type" : "sectionRound",
			"to" : 1320,
			"from" : 1319,
			"brick" : "P15",
			"name" : "30019",
			"uuid" : "93fefe44-76ac-e24b-b459-ee29ac9b4b5f",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 30020,
			"tags" : [
				"P15"
			],
			"type" : "sectionRound",
			"to" : 1317,
			"from" : 1320,
			"brick" : "P15",
			"name" : "30020",
			"uuid" : "acb4ccd7-d2c9-2b4a-af54-fbbdf8196ad8",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 30021,
			"tags" : [
				"P15"
			],
			"type" : "sectionRound",
			"to" : 1322,
			"from" : 1321,
			"brick" : "P15",
			"name" : "30021",
			"uuid" : "26846b10-b823-af4a-b586-2b49b7f12611",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 30022,
			"tags" : [
				"P15"
			],
			"type" : "sectionRound",
			"to" : 1323,
			"from" : 1322,
			"brick" : "P15",
			"name" : "30022",
			"uuid" : "5c091a05-4307-9743-8b95-39ab6a2742c0",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 30023,
			"tags" : [
				"P15"
			],
			"type" : "sectionRound",
			"to" : 1324,
			"from" : 1323,
			"brick" : "P15",
			"name" : "30023",
			"uuid" : "69fc5db2-c788-2c49-9681-b6e10c8a70b8",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 30024,
			"tags" : [
				"P15"
			],
			"type" : "sectionRound",
			"to" : 1321,
			"from" : 1324,
			"brick" : "P15",
			"name" : "30024",
			"uuid" : "a13bd588-54fc-744a-abbf-a349726f06bc",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 30025,
			"tags" : [
				"P15"
			],
			"type" : "sectionRound",
			"to" : 1385,
			"from" : 1329,
			"brick" : "P15",
			"name" : "30025",
			"uuid" : "227d8d7d-b8ac-a748-b573-caad870f8d1d",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 30026,
			"tags" : [
				"P15"
			],
			"type" : "sectionRound",
			"to" : 1330,
			"from" : 1385,
			"brick" : "P15",
			"name" : "30026",
			"uuid" : "de91aa58-229e-004d-9b6b-0df3d0cf6d6f",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 30027,
			"tags" : [
				"P15"
			],
			"type" : "sectionRound",
			"to" : 1386,
			"from" : 1330,
			"brick" : "P15",
			"name" : "30027",
			"uuid" : "345ded7a-2d89-484a-97ec-b37e0914b273",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 30028,
			"tags" : [
				"P15"
			],
			"type" : "sectionRound",
			"to" : 1331,
			"from" : 1386,
			"brick" : "P15",
			"name" : "30028",
			"uuid" : "60833fa8-15fd-454e-bc3f-fc1133408ded",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 30029,
			"tags" : [
				"P15"
			],
			"type" : "sectionRound",
			"to" : 1387,
			"from" : 1331,
			"brick" : "P15",
			"name" : "30029",
			"uuid" : "0171670c-747b-4140-ba54-8313a8912d06",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 30030,
			"tags" : [
				"P15"
			],
			"type" : "sectionRound",
			"to" : 1332,
			"from" : 1387,
			"brick" : "P15",
			"name" : "30030",
			"uuid" : "f77983dc-38af-674f-bc58-f960ee7f93db",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 30031,
			"tags" : [
				"P15"
			],
			"type" : "sectionRound",
			"to" : 1388,
			"from" : 1332,
			"brick" : "P15",
			"name" : "30031",
			"uuid" : "009e0939-12a6-b045-a87d-64576afb6c7f",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 30032,
			"tags" : [
				"P15"
			],
			"type" : "sectionRound",
			"to" : 1329,
			"from" : 1388,
			"brick" : "P15",
			"name" : "30032",
			"uuid" : "f1765d8f-1989-794e-b624-27f85388cd6a",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 30033,
			"tags" : [
				"P15"
			],
			"type" : "sectionRound",
			"to" : 1389,
			"from" : 1337,
			"brick" : "P15",
			"name" : "30033",
			"uuid" : "503871e0-9d33-804d-b5c9-64672a35b5b6",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 30034,
			"tags" : [
				"P15"
			],
			"type" : "sectionRound",
			"to" : 1338,
			"from" : 1389,
			"brick" : "P15",
			"name" : "30034",
			"uuid" : "1e53932d-0fd5-a545-9f9f-f055cacdb732",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 30035,
			"tags" : [
				"P15"
			],
			"type" : "sectionRound",
			"to" : 1390,
			"from" : 1338,
			"brick" : "P15",
			"name" : "30035",
			"uuid" : "a648c601-d1d8-d14b-8ea1-6e03c417eff8",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 30036,
			"tags" : [
				"P15"
			],
			"type" : "sectionRound",
			"to" : 1339,
			"from" : 1390,
			"brick" : "P15",
			"name" : "30036",
			"uuid" : "89178760-3196-c54f-a57d-bc8051334db8",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 30037,
			"tags" : [
				"P15"
			],
			"type" : "sectionRound",
			"to" : 1391,
			"from" : 1339,
			"brick" : "P15",
			"name" : "30037",
			"uuid" : "015bbbed-454a-2f49-b20e-a2f3be5b4974",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 30038,
			"tags" : [
				"P15"
			],
			"type" : "sectionRound",
			"to" : 1340,
			"from" : 1391,
			"brick" : "P15",
			"name" : "30038",
			"uuid" : "af80c4d3-728c-b244-bbfc-936c6bfd103c",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 30039,
			"tags" : [
				"P15"
			],
			"type" : "sectionRound",
			"to" : 1392,
			"from" : 1340,
			"brick" : "P15",
			"name" : "30039",
			"uuid" : "3129bb1a-07e5-524d-bb9e-737987887ed1",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 30040,
			"tags" : [
				"P15"
			],
			"type" : "sectionRound",
			"to" : 1337,
			"from" : 1392,
			"brick" : "P15",
			"name" : "30040",
			"uuid" : "3ef659b0-b42b-e24f-855c-e7d3f6ac767a",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 30041,
			"tags" : [
				"P15"
			],
			"type" : "sectionRound",
			"to" : 1393,
			"from" : 1345,
			"brick" : "P15",
			"name" : "30041",
			"uuid" : "5220db94-501d-2f43-8f18-3cb4f5685b9e",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 30042,
			"tags" : [
				"P15"
			],
			"type" : "sectionRound",
			"to" : 1346,
			"from" : 1393,
			"brick" : "P15",
			"name" : "30042",
			"uuid" : "6c5c45f5-62f0-334b-920d-e0e7365a5fd8",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 30043,
			"tags" : [
				"P15"
			],
			"type" : "sectionRound",
			"to" : 1394,
			"from" : 1346,
			"brick" : "P15",
			"name" : "30043",
			"uuid" : "367bee7e-3307-0544-9a6e-0e26366439fd",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 30044,
			"tags" : [
				"P15"
			],
			"type" : "sectionRound",
			"to" : 1347,
			"from" : 1394,
			"brick" : "P15",
			"name" : "30044",
			"uuid" : "469d4a41-1c10-bf46-a996-143bec21225e",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 30045,
			"tags" : [
				"P15"
			],
			"type" : "sectionRound",
			"to" : 1395,
			"from" : 1347,
			"brick" : "P15",
			"name" : "30045",
			"uuid" : "dda7c687-67d6-f447-92c3-127d1b97114b",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 30046,
			"tags" : [
				"P15"
			],
			"type" : "sectionRound",
			"to" : 1348,
			"from" : 1395,
			"brick" : "P15",
			"name" : "30046",
			"uuid" : "36eaef71-369a-b34e-8877-f499654becfb",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 30047,
			"tags" : [
				"P15"
			],
			"type" : "sectionRound",
			"to" : 1396,
			"from" : 1348,
			"brick" : "P15",
			"name" : "30047",
			"uuid" : "576a262c-23eb-5b4e-b7e0-a8ce7b525b26",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 30048,
			"tags" : [
				"P15"
			],
			"type" : "sectionRound",
			"to" : 1345,
			"from" : 1396,
			"brick" : "P15",
			"name" : "30048",
			"uuid" : "07045d24-9379-5a43-a4e2-d5a285038ec5",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 30049,
			"tags" : [
				"P15"
			],
			"type" : "sectionRound",
			"to" : 1397,
			"from" : 1353,
			"brick" : "P15",
			"name" : "30049",
			"uuid" : "98f95b23-0e0d-7d4b-a494-8504056ee96e",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 30050,
			"tags" : [
				"P15"
			],
			"type" : "sectionRound",
			"to" : 1354,
			"from" : 1397,
			"brick" : "P15",
			"name" : "30050",
			"uuid" : "95f63c2a-90d5-3f4e-b641-5d4cbd088412",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 30051,
			"tags" : [
				"P15"
			],
			"type" : "sectionRound",
			"to" : 1398,
			"from" : 1354,
			"brick" : "P15",
			"name" : "30051",
			"uuid" : "9d6df9ec-f353-3d49-bf10-c632c72dc1ac",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 30052,
			"tags" : [
				"P15"
			],
			"type" : "sectionRound",
			"to" : 1355,
			"from" : 1398,
			"brick" : "P15",
			"name" : "30052",
			"uuid" : "2d52f84c-0097-2c40-a896-15cd2edcf533",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 30053,
			"tags" : [
				"P15"
			],
			"type" : "sectionRound",
			"to" : 1399,
			"from" : 1355,
			"brick" : "P15",
			"name" : "30053",
			"uuid" : "b474590b-8019-6444-ba58-f72d91f5cff2",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 30054,
			"tags" : [
				"P15"
			],
			"type" : "sectionRound",
			"to" : 1356,
			"from" : 1399,
			"brick" : "P15",
			"name" : "30054",
			"uuid" : "619be954-c203-6b48-ae48-2ddebc693d92",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 30055,
			"tags" : [
				"P15"
			],
			"type" : "sectionRound",
			"to" : 1400,
			"from" : 1356,
			"brick" : "P15",
			"name" : "30055",
			"uuid" : "fc194a10-507e-f64f-ad6f-c87296eb8880",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 30056,
			"tags" : [
				"P15"
			],
			"type" : "sectionRound",
			"to" : 1353,
			"from" : 1400,
			"brick" : "P15",
			"name" : "30056",
			"uuid" : "7c3221e9-ce60-a04d-a3a8-5cec26d0d806",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 30057,
			"tags" : [
				"P15"
			],
			"type" : "sectionRound",
			"to" : 1401,
			"from" : 1361,
			"brick" : "P15",
			"name" : "30057",
			"uuid" : "07ec53b6-7411-2442-aec6-2461545171ee",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 30058,
			"tags" : [
				"P15"
			],
			"type" : "sectionRound",
			"to" : 1362,
			"from" : 1401,
			"brick" : "P15",
			"name" : "30058",
			"uuid" : "0b140fcc-c333-7248-a388-3624fe1b59c5",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 30059,
			"tags" : [
				"P15"
			],
			"type" : "sectionRound",
			"to" : 1402,
			"from" : 1362,
			"brick" : "P15",
			"name" : "30059",
			"uuid" : "4c6fdba4-c2e3-6d44-a4d7-eee65e0fa369",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 30060,
			"tags" : [
				"P15"
			],
			"type" : "sectionRound",
			"to" : 1363,
			"from" : 1402,
			"brick" : "P15",
			"name" : "30060",
			"uuid" : "9ba37cdf-0cd8-0446-8bdd-9deb2c50bdff",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 30061,
			"tags" : [
				"P15"
			],
			"type" : "sectionRound",
			"to" : 1403,
			"from" : 1363,
			"brick" : "P15",
			"name" : "30061",
			"uuid" : "e0108ba1-e5aa-9049-ab96-da8ed06485aa",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 30062,
			"tags" : [
				"P15"
			],
			"type" : "sectionRound",
			"to" : 1364,
			"from" : 1403,
			"brick" : "P15",
			"name" : "30062",
			"uuid" : "9e59d88d-8dcc-214e-9831-d5735a599e2b",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 30063,
			"tags" : [
				"P15"
			],
			"type" : "sectionRound",
			"to" : 1404,
			"from" : 1364,
			"brick" : "P15",
			"name" : "30063",
			"uuid" : "4d2e3219-446c-e444-825f-cf58859e325d",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 30064,
			"tags" : [
				"P15"
			],
			"type" : "sectionRound",
			"to" : 1361,
			"from" : 1404,
			"brick" : "P15",
			"name" : "30064",
			"uuid" : "d7ef765b-0e29-b74e-abab-ce6f21ff0510",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 30065,
			"tags" : [
				"P15"
			],
			"type" : "sectionRound",
			"to" : 1405,
			"from" : 1369,
			"brick" : "P15",
			"name" : "30065",
			"uuid" : "883b250e-fd7c-7949-b35c-4e291fdb9ea5",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 30066,
			"tags" : [
				"P15"
			],
			"type" : "sectionRound",
			"to" : 1370,
			"from" : 1405,
			"brick" : "P15",
			"name" : "30066",
			"uuid" : "7fbc0134-2776-8143-a1c4-8ce22b4fe1bd",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 30067,
			"tags" : [
				"P15"
			],
			"type" : "sectionRound",
			"to" : 1406,
			"from" : 1370,
			"brick" : "P15",
			"name" : "30067",
			"uuid" : "4e7f5fc8-0b34-c240-8ce8-651b566a490f",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 30068,
			"tags" : [
				"P15"
			],
			"type" : "sectionRound",
			"to" : 1371,
			"from" : 1406,
			"brick" : "P15",
			"name" : "30068",
			"uuid" : "0426c035-fda4-1b4b-a580-1e5dfb7b2b25",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 30069,
			"tags" : [
				"P15"
			],
			"type" : "sectionRound",
			"to" : 1407,
			"from" : 1371,
			"brick" : "P15",
			"name" : "30069",
			"uuid" : "587fb6e0-0df7-7c4b-b51c-e5896b8f72e3",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 30070,
			"tags" : [
				"P15"
			],
			"type" : "sectionRound",
			"to" : 1372,
			"from" : 1407,
			"brick" : "P15",
			"name" : "30070",
			"uuid" : "4dd0b0d4-dc26-8d4f-9065-982204e7cdab",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 30071,
			"tags" : [
				"P15"
			],
			"type" : "sectionRound",
			"to" : 1408,
			"from" : 1372,
			"brick" : "P15",
			"name" : "30071",
			"uuid" : "4accdcb7-1221-7441-93af-9cf0d0c3236c",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 30072,
			"tags" : [
				"P15"
			],
			"type" : "sectionRound",
			"to" : 1369,
			"from" : 1408,
			"brick" : "P15",
			"name" : "30072",
			"uuid" : "46c122bb-a87f-e741-8c49-10d55fef90e8",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 30101,
			"tags" : [
				"P15"
			],
			"type" : "sectionSlant",
			"to" : 1320,
			"from" : 2401,
			"brick" : "P15",
			"name" : "30101",
			"uuid" : "cbf119f9-f6f3-de4e-816e-a1898ae8f443",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 30102,
			"tags" : [
				"P15"
			],
			"type" : "sectionSlant",
			"to" : 2401,
			"from" : 1318,
			"brick" : "P15",
			"name" : "30102",
			"uuid" : "dec2c2f2-34be-cb49-8e34-b5269e2e9ec7",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 30103,
			"tags" : [
				"P15"
			],
			"type" : "sectionSlant",
			"to" : 1319,
			"from" : 2401,
			"brick" : "P15",
			"name" : "30103",
			"uuid" : "298beeda-65cc-2044-9ab6-7e742fb26645",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 30104,
			"tags" : [
				"P15"
			],
			"type" : "sectionSlant",
			"to" : 2401,
			"from" : 1317,
			"brick" : "P15",
			"name" : "30104",
			"uuid" : "27e0c0a3-51f9-4e42-b7cd-d6eedbdce9f3",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 30105,
			"tags" : [
				"P15"
			],
			"type" : "sectionSlant",
			"to" : 1324,
			"from" : 2402,
			"brick" : "P15",
			"name" : "30105",
			"uuid" : "76c2d1c8-aeda-1648-a180-2c5560641d18",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 30106,
			"tags" : [
				"P15"
			],
			"type" : "sectionSlant",
			"to" : 2402,
			"from" : 1322,
			"brick" : "P15",
			"name" : "30106",
			"uuid" : "86f3e60b-5a87-a14a-9916-3f38225a47f7",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 30107,
			"tags" : [
				"P15"
			],
			"type" : "sectionSlant",
			"to" : 1323,
			"from" : 2402,
			"brick" : "P15",
			"name" : "30107",
			"uuid" : "3d356fd5-50e4-1f47-ba8a-fa309f9980d6",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 30108,
			"tags" : [
				"P15"
			],
			"type" : "sectionSlant",
			"to" : 2402,
			"from" : 1321,
			"brick" : "P15",
			"name" : "30108",
			"uuid" : "a628bfcc-b32f-2749-90ba-762ac1caf68c",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 30109,
			"tags" : [
				"P15"
			],
			"type" : "sectionSlant",
			"to" : 1401,
			"from" : 1404,
			"brick" : "P15",
			"name" : "30109",
			"uuid" : "caa35493-874b-854c-80cb-1b3da5dbf310",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 30110,
			"tags" : [
				"P15"
			],
			"type" : "sectionSlant",
			"to" : 1402,
			"from" : 1401,
			"brick" : "P15",
			"name" : "30110",
			"uuid" : "3a93de68-ee20-7844-b795-051fb3d5043c",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 30111,
			"tags" : [
				"P15"
			],
			"type" : "sectionSlant",
			"to" : 1403,
			"from" : 1402,
			"brick" : "P15",
			"name" : "30111",
			"uuid" : "02218275-1d38-da41-a870-b25701a69cb6",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 30112,
			"tags" : [
				"P15"
			],
			"type" : "sectionSlant",
			"to" : 1404,
			"from" : 1403,
			"brick" : "P15",
			"name" : "30112",
			"uuid" : "fcf73504-cb2e-cd4b-be5a-33f6ae55510b",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 30113,
			"tags" : [
				"P15"
			],
			"type" : "sectionSlant",
			"to" : 1405,
			"from" : 1408,
			"brick" : "P15",
			"name" : "30113",
			"uuid" : "a5b2dd9d-d029-fb44-a8fe-89a9b07f2d97",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 30114,
			"tags" : [
				"P15"
			],
			"type" : "sectionSlant",
			"to" : 1406,
			"from" : 1405,
			"brick" : "P15",
			"name" : "30114",
			"uuid" : "628e2b0b-ca4a-e44e-92e1-cd2c420865bd",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 30115,
			"tags" : [
				"P15"
			],
			"type" : "sectionSlant",
			"to" : 1407,
			"from" : 1406,
			"brick" : "P15",
			"name" : "30115",
			"uuid" : "5994a285-72c2-c64b-9238-e51a9a521853",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 30116,
			"tags" : [
				"P15"
			],
			"type" : "sectionSlant",
			"to" : 1408,
			"from" : 1407,
			"brick" : "P15",
			"name" : "30116",
			"uuid" : "a6f4b4a9-3b17-3640-9d54-fa2a8d162d3f",
			"_clazz" : "TwkSegment"
		},
		{
			"uuid" : "f309c678-4a51-2e40-90a7-6b94482db4d0",
			"name" : "21001",
			"_clazz" : "TwkSegment",
			"brick" : "FRONT",
			"from" : 1306,
			"face" : "front",
			"tags" : [
				"P15"
			],
			"type" : "panel",
			"to" : 1301,
			"number" : 21001
		},
		{
			"uuid" : "d37641f6-d296-f94a-a6e1-a6a05404c0ba",
			"name" : "21002",
			"_clazz" : "TwkSegment",
			"brick" : "LEFT",
			"from" : 1307,
			"face" : "left",
			"tags" : [
				"P15"
			],
			"type" : "panel",
			"to" : 1302,
			"number" : 21002
		},
		{
			"uuid" : "e4867af7-7261-7a4c-8d47-d059e9eb4cc6",
			"name" : "21003",
			"_clazz" : "TwkSegment",
			"brick" : "BACK",
			"from" : 1308,
			"face" : "back",
			"tags" : [
				"P15"
			],
			"type" : "panel",
			"to" : 1303,
			"number" : 21003
		},
		{
			"uuid" : "e5de3ff9-5709-7842-9b2a-304bd48e01d0",
			"name" : "21004",
			"_clazz" : "TwkSegment",
			"brick" : "RIGHT",
			"from" : 1305,
			"face" : "right",
			"tags" : [
				"P15"
			],
			"type" : "panel",
			"to" : 1304,
			"number" : 21004
		},
		{
			"uuid" : "8c9ab675-c76d-e24b-8311-26ab28c69751",
			"name" : "21005",
			"_clazz" : "TwkSegment",
			"brick" : "FRONT",
			"from" : 1310,
			"face" : "front",
			"tags" : [
				"P15"
			],
			"type" : "panel",
			"to" : 1305,
			"number" : 21005
		},
		{
			"uuid" : "99352ad8-982d-c340-b8ce-38e5f7a8f2a8",
			"name" : "21006",
			"_clazz" : "TwkSegment",
			"brick" : "LEFT",
			"from" : 1311,
			"face" : "left",
			"tags" : [
				"P15"
			],
			"type" : "panel",
			"to" : 1306,
			"number" : 21006
		},
		{
			"uuid" : "98d14705-c4ee-f44a-9ab3-3fedfef41955",
			"name" : "21007",
			"_clazz" : "TwkSegment",
			"brick" : "BACK",
			"from" : 1312,
			"face" : "back",
			"tags" : [
				"P15"
			],
			"type" : "panel",
			"to" : 1307,
			"number" : 21007
		},
		{
			"uuid" : "e1729de3-d86b-3547-bfe8-23de4dda593b",
			"name" : "21008",
			"_clazz" : "TwkSegment",
			"brick" : "RIGHT",
			"from" : 1309,
			"face" : "right",
			"tags" : [
				"P15"
			],
			"type" : "panel",
			"to" : 1308,
			"number" : 21008
		},
		{
			"uuid" : "e76a2b2e-f67a-8742-b822-6d15f4d135da",
			"name" : "21009",
			"_clazz" : "TwkSegment",
			"brick" : "FRONT",
			"from" : 1314,
			"face" : "front",
			"tags" : [
				"P15"
			],
			"type" : "panel",
			"to" : 1309,
			"number" : 21009
		},
		{
			"uuid" : "b957e19a-4d2a-da44-ab3c-8e4fffe80bd1",
			"name" : "21010",
			"_clazz" : "TwkSegment",
			"brick" : "LEFT",
			"from" : 1315,
			"face" : "left",
			"tags" : [
				"P15"
			],
			"type" : "panel",
			"to" : 1310,
			"number" : 21010
		},
		{
			"uuid" : "7dd881a1-304e-2e4a-9916-fce1dc3b0afd",
			"name" : "21011",
			"_clazz" : "TwkSegment",
			"brick" : "BACK",
			"from" : 1316,
			"face" : "back",
			"tags" : [
				"P15"
			],
			"type" : "panel",
			"to" : 1311,
			"number" : 21011
		},
		{
			"uuid" : "0919a148-5dad-e449-94a4-0e936bc335ff",
			"name" : "21012",
			"_clazz" : "TwkSegment",
			"brick" : "RIGHT",
			"from" : 1313,
			"face" : "right",
			"tags" : [
				"P15"
			],
			"type" : "panel",
			"to" : 1312,
			"number" : 21012
		},
		{
			"uuid" : "57498ca6-fc50-a54b-840b-c845dbb847e7",
			"name" : "21013",
			"_clazz" : "TwkSegment",
			"brick" : "FRONT",
			"from" : 1318,
			"face" : "front",
			"tags" : [
				"P15"
			],
			"type" : "panel",
			"to" : 1313,
			"number" : 21013
		},
		{
			"uuid" : "0fdcb117-0c7c-8942-9c21-81b51cdd8319",
			"name" : "21014",
			"_clazz" : "TwkSegment",
			"brick" : "LEFT",
			"from" : 1319,
			"face" : "left",
			"tags" : [
				"P15"
			],
			"type" : "panel",
			"to" : 1314,
			"number" : 21014
		},
		{
			"uuid" : "955165a3-14d1-d64d-b616-24666ecd2817",
			"name" : "21015",
			"_clazz" : "TwkSegment",
			"brick" : "BACK",
			"from" : 1320,
			"face" : "back",
			"tags" : [
				"P15"
			],
			"type" : "panel",
			"to" : 1315,
			"number" : 21015
		},
		{
			"uuid" : "42540932-bd46-9144-83fb-8205e549f7bc",
			"name" : "21016",
			"_clazz" : "TwkSegment",
			"brick" : "RIGHT",
			"from" : 1317,
			"face" : "right",
			"tags" : [
				"P15"
			],
			"type" : "panel",
			"to" : 1316,
			"number" : 21016
		},
		{
			"uuid" : "81af316c-e89e-8a49-9fa5-ec113a06c15e",
			"name" : "21017",
			"_clazz" : "TwkSegment",
			"brick" : "FRONT",
			"from" : 1377,
			"face" : "front",
			"tags" : [
				"P15"
			],
			"type" : "panel",
			"to" : 1317,
			"number" : 21017
		},
		{
			"uuid" : "d8898c2b-b782-4149-8d0e-88ea6bf8e2c4",
			"name" : "21018",
			"_clazz" : "TwkSegment",
			"brick" : "FRONT",
			"from" : 1322,
			"face" : "front",
			"tags" : [
				"P15"
			],
			"type" : "panel",
			"to" : 1377,
			"number" : 21018
		},
		{
			"uuid" : "0124eb58-dd16-934c-8611-58dce2b6250d",
			"name" : "21019",
			"_clazz" : "TwkSegment",
			"brick" : "FRONT",
			"from" : 1377,
			"face" : "front",
			"tags" : [
				"P15"
			],
			"type" : "panel",
			"to" : 1318,
			"number" : 21019
		},
		{
			"uuid" : "792047e2-b581-004d-bd42-0e1a4baad5ac",
			"name" : "21020",
			"_clazz" : "TwkSegment",
			"brick" : "FRONT",
			"from" : 1321,
			"face" : "front",
			"tags" : [
				"P15"
			],
			"type" : "panel",
			"to" : 1377,
			"number" : 21020
		},
		{
			"uuid" : "adb246f1-b5b1-f641-8575-ce291ff58ed0",
			"name" : "21021",
			"_clazz" : "TwkSegment",
			"brick" : "LEFT",
			"from" : 1378,
			"face" : "left",
			"tags" : [
				"P15"
			],
			"type" : "panel",
			"to" : 1318,
			"number" : 21021
		},
		{
			"uuid" : "a15fdd17-3132-c64f-9de0-27a003d6b007",
			"name" : "21022",
			"_clazz" : "TwkSegment",
			"brick" : "LEFT",
			"from" : 1323,
			"face" : "left",
			"tags" : [
				"P15"
			],
			"type" : "panel",
			"to" : 1378,
			"number" : 21022
		},
		{
			"uuid" : "7dd3f8eb-b0d9-064a-b56b-48e879ad7816",
			"name" : "21023",
			"_clazz" : "TwkSegment",
			"brick" : "LEFT",
			"from" : 1378,
			"face" : "left",
			"tags" : [
				"P15"
			],
			"type" : "panel",
			"to" : 1319,
			"number" : 21023
		},
		{
			"uuid" : "4fd6a683-0be9-634f-a656-8bf845c0a76e",
			"name" : "21024",
			"_clazz" : "TwkSegment",
			"brick" : "LEFT",
			"from" : 1322,
			"face" : "left",
			"tags" : [
				"P15"
			],
			"type" : "panel",
			"to" : 1378,
			"number" : 21024
		},
		{
			"uuid" : "911e8762-7a0b-0e42-a78c-95bd672a7a71",
			"name" : "21025",
			"_clazz" : "TwkSegment",
			"brick" : "BACK",
			"from" : 1379,
			"face" : "back",
			"tags" : [
				"P15"
			],
			"type" : "panel",
			"to" : 1319,
			"number" : 21025
		},
		{
			"uuid" : "22308d11-e27a-6141-a692-6d41180ed57b",
			"name" : "21026",
			"_clazz" : "TwkSegment",
			"brick" : "BACK",
			"from" : 1324,
			"face" : "back",
			"tags" : [
				"P15"
			],
			"type" : "panel",
			"to" : 1379,
			"number" : 21026
		},
		{
			"uuid" : "2ba28a30-9865-9c45-a5a2-7ba8c28e8e9e",
			"name" : "21027",
			"_clazz" : "TwkSegment",
			"brick" : "BACK",
			"from" : 1379,
			"face" : "back",
			"tags" : [
				"P15"
			],
			"type" : "panel",
			"to" : 1320,
			"number" : 21027
		},
		{
			"uuid" : "b4a3d6d3-8dd2-4248-893f-f2826bf5a0bc",
			"name" : "21028",
			"_clazz" : "TwkSegment",
			"brick" : "BACK",
			"from" : 1323,
			"face" : "back",
			"tags" : [
				"P15"
			],
			"type" : "panel",
			"to" : 1379,
			"number" : 21028
		},
		{
			"uuid" : "1a3f2800-8371-3145-a179-5edfaeb246bf",
			"name" : "21029",
			"_clazz" : "TwkSegment",
			"brick" : "RIGHT",
			"from" : 1380,
			"face" : "right",
			"tags" : [
				"P15"
			],
			"type" : "panel",
			"to" : 1320,
			"number" : 21029
		},
		{
			"uuid" : "bec60d05-b44b-f14a-b821-9c18f6a21d83",
			"name" : "21030",
			"_clazz" : "TwkSegment",
			"brick" : "RIGHT",
			"from" : 1321,
			"face" : "right",
			"tags" : [
				"P15"
			],
			"type" : "panel",
			"to" : 1380,
			"number" : 21030
		},
		{
			"uuid" : "422edefb-ac9d-a643-b06a-b77097693f72",
			"name" : "21031",
			"_clazz" : "TwkSegment",
			"brick" : "RIGHT",
			"from" : 1380,
			"face" : "right",
			"tags" : [
				"P15"
			],
			"type" : "panel",
			"to" : 1317,
			"number" : 21031
		},
		{
			"uuid" : "ac51c7d1-0adb-ad4f-9e3e-4811a5d741db",
			"name" : "21032",
			"_clazz" : "TwkSegment",
			"brick" : "RIGHT",
			"from" : 1324,
			"face" : "right",
			"tags" : [
				"P15"
			],
			"type" : "panel",
			"to" : 1380,
			"number" : 21032
		},
		{
			"uuid" : "e899c108-41d6-5b44-9971-a53174129050",
			"name" : "21033",
			"_clazz" : "TwkSegment",
			"brick" : "FRONT",
			"from" : 1381,
			"face" : "front",
			"tags" : [
				"P15"
			],
			"type" : "panel",
			"to" : 1321,
			"number" : 21033
		},
		{
			"uuid" : "f42ae93f-3359-bf48-867f-34b943256d04",
			"name" : "21034",
			"_clazz" : "TwkSegment",
			"brick" : "FRONT",
			"from" : 1326,
			"face" : "front",
			"tags" : [
				"P15"
			],
			"type" : "panel",
			"to" : 1381,
			"number" : 21034
		},
		{
			"uuid" : "df9eddaf-65c7-cc42-9a5e-75655a94c0e9",
			"name" : "21035",
			"_clazz" : "TwkSegment",
			"brick" : "FRONT",
			"from" : 1381,
			"face" : "front",
			"tags" : [
				"P15"
			],
			"type" : "panel",
			"to" : 1322,
			"number" : 21035
		},
		{
			"uuid" : "3df48855-e156-a344-982f-7692e48ccbd8",
			"name" : "21036",
			"_clazz" : "TwkSegment",
			"brick" : "FRONT",
			"from" : 1325,
			"face" : "front",
			"tags" : [
				"P15"
			],
			"type" : "panel",
			"to" : 1381,
			"number" : 21036
		},
		{
			"uuid" : "7e88be6f-02d3-6348-8749-13b8917899d8",
			"name" : "21037",
			"_clazz" : "TwkSegment",
			"brick" : "LEFT",
			"from" : 1382,
			"face" : "left",
			"tags" : [
				"P15"
			],
			"type" : "panel",
			"to" : 1322,
			"number" : 21037
		},
		{
			"uuid" : "dbfe6071-096c-0a48-841b-fb971b8841f1",
			"name" : "21038",
			"_clazz" : "TwkSegment",
			"brick" : "LEFT",
			"from" : 1327,
			"face" : "left",
			"tags" : [
				"P15"
			],
			"type" : "panel",
			"to" : 1382,
			"number" : 21038
		},
		{
			"uuid" : "ef57056b-5bfb-1940-9c12-2e52870d81ab",
			"name" : "21039",
			"_clazz" : "TwkSegment",
			"brick" : "LEFT",
			"from" : 1382,
			"face" : "left",
			"tags" : [
				"P15"
			],
			"type" : "panel",
			"to" : 1323,
			"number" : 21039
		},
		{
			"uuid" : "77779566-7e7c-184b-a6a9-853f5832c9cd",
			"name" : "21040",
			"_clazz" : "TwkSegment",
			"brick" : "LEFT",
			"from" : 1326,
			"face" : "left",
			"tags" : [
				"P15"
			],
			"type" : "panel",
			"to" : 1382,
			"number" : 21040
		},
		{
			"uuid" : "22d9367c-e851-364a-8945-12c6d730fa98",
			"name" : "21041",
			"_clazz" : "TwkSegment",
			"brick" : "BACK",
			"from" : 1383,
			"face" : "back",
			"tags" : [
				"P15"
			],
			"type" : "panel",
			"to" : 1323,
			"number" : 21041
		},
		{
			"uuid" : "a921a831-4003-3d47-9de6-7349ff6a9ef7",
			"name" : "21042",
			"_clazz" : "TwkSegment",
			"brick" : "BACK",
			"from" : 1328,
			"face" : "back",
			"tags" : [
				"P15"
			],
			"type" : "panel",
			"to" : 1383,
			"number" : 21042
		},
		{
			"uuid" : "6fc7dba8-27a5-3e48-833f-57c97e7f2f11",
			"name" : "21043",
			"_clazz" : "TwkSegment",
			"brick" : "BACK",
			"from" : 1383,
			"face" : "back",
			"tags" : [
				"P15"
			],
			"type" : "panel",
			"to" : 1324,
			"number" : 21043
		},
		{
			"uuid" : "6c28aba0-d406-3346-963c-83d2296f0c6a",
			"name" : "21044",
			"_clazz" : "TwkSegment",
			"brick" : "BACK",
			"from" : 1327,
			"face" : "back",
			"tags" : [
				"P15"
			],
			"type" : "panel",
			"to" : 1383,
			"number" : 21044
		},
		{
			"uuid" : "094401dc-ca40-f440-b92f-186a8bee32cc",
			"name" : "21045",
			"_clazz" : "TwkSegment",
			"brick" : "RIGHT",
			"from" : 1384,
			"face" : "right",
			"tags" : [
				"P15"
			],
			"type" : "panel",
			"to" : 1324,
			"number" : 21045
		},
		{
			"uuid" : "f1049a22-d74e-c345-af74-f3b14263f0c8",
			"name" : "21046",
			"_clazz" : "TwkSegment",
			"brick" : "RIGHT",
			"from" : 1325,
			"face" : "right",
			"tags" : [
				"P15"
			],
			"type" : "panel",
			"to" : 1384,
			"number" : 21046
		},
		{
			"uuid" : "6fb193e6-49b1-1341-988b-cbad91ded2ed",
			"name" : "21047",
			"_clazz" : "TwkSegment",
			"brick" : "RIGHT",
			"from" : 1384,
			"face" : "right",
			"tags" : [
				"P15"
			],
			"type" : "panel",
			"to" : 1321,
			"number" : 21047
		},
		{
			"uuid" : "3bb702a6-f744-dc48-9769-04a0f0241e9a",
			"name" : "21048",
			"_clazz" : "TwkSegment",
			"brick" : "RIGHT",
			"from" : 1328,
			"face" : "right",
			"tags" : [
				"P15"
			],
			"type" : "panel",
			"to" : 1384,
			"number" : 21048
		},
		{
			"uuid" : "6c15c98d-30ac-9742-a4c7-c543ae1e0325",
			"name" : "21049",
			"_clazz" : "TwkSegment",
			"brick" : "FRONT",
			"from" : 1385,
			"face" : "front",
			"tags" : [
				"P15"
			],
			"type" : "panel",
			"to" : 1325,
			"number" : 21049
		},
		{
			"uuid" : "1e05e98b-d620-d84e-9f3e-521c3e9429d7",
			"name" : "21050",
			"_clazz" : "TwkSegment",
			"brick" : "FRONT",
			"from" : 1334,
			"face" : "front",
			"tags" : [
				"P15"
			],
			"type" : "panel",
			"to" : 1385,
			"number" : 21050
		},
		{
			"uuid" : "f4373bc1-6f13-924f-b59b-920a1960e904",
			"name" : "21051",
			"_clazz" : "TwkSegment",
			"brick" : "FRONT",
			"from" : 1385,
			"face" : "front",
			"tags" : [
				"P15"
			],
			"type" : "panel",
			"to" : 1326,
			"number" : 21051
		},
		{
			"uuid" : "b7f4be72-3336-144a-9552-dca748874559",
			"name" : "21052",
			"_clazz" : "TwkSegment",
			"brick" : "FRONT",
			"from" : 1333,
			"face" : "front",
			"tags" : [
				"P15"
			],
			"type" : "panel",
			"to" : 1385,
			"number" : 21052
		},
		{
			"uuid" : "af31e3d0-b172-d34c-a6e0-9b8e311a8029",
			"name" : "21053",
			"_clazz" : "TwkSegment",
			"brick" : "LEFT",
			"from" : 1386,
			"face" : "left",
			"tags" : [
				"P15"
			],
			"type" : "panel",
			"to" : 1326,
			"number" : 21053
		},
		{
			"uuid" : "09c8454d-f946-7349-99b4-669673c8ab50",
			"name" : "21054",
			"_clazz" : "TwkSegment",
			"brick" : "LEFT",
			"from" : 1335,
			"face" : "left",
			"tags" : [
				"P15"
			],
			"type" : "panel",
			"to" : 1386,
			"number" : 21054
		},
		{
			"uuid" : "db132ece-f653-714d-b87b-58317360d22b",
			"name" : "21055",
			"_clazz" : "TwkSegment",
			"brick" : "LEFT",
			"from" : 1386,
			"face" : "left",
			"tags" : [
				"P15"
			],
			"type" : "panel",
			"to" : 1327,
			"number" : 21055
		},
		{
			"uuid" : "8978f164-a505-3a4a-adac-5f0a3464ffce",
			"name" : "21056",
			"_clazz" : "TwkSegment",
			"brick" : "LEFT",
			"from" : 1334,
			"face" : "left",
			"tags" : [
				"P15"
			],
			"type" : "panel",
			"to" : 1386,
			"number" : 21056
		},
		{
			"uuid" : "292cf15f-7984-6a4e-a2eb-faa98358c670",
			"name" : "21057",
			"_clazz" : "TwkSegment",
			"brick" : "BACK",
			"from" : 1387,
			"face" : "back",
			"tags" : [
				"P15"
			],
			"type" : "panel",
			"to" : 1327,
			"number" : 21057
		},
		{
			"uuid" : "349309fd-fd14-3442-be68-40984dc4fa08",
			"name" : "21058",
			"_clazz" : "TwkSegment",
			"brick" : "BACK",
			"from" : 1336,
			"face" : "back",
			"tags" : [
				"P15"
			],
			"type" : "panel",
			"to" : 1387,
			"number" : 21058
		},
		{
			"uuid" : "57c39bad-fa44-2541-9299-1bd7e9f25b2f",
			"name" : "21059",
			"_clazz" : "TwkSegment",
			"brick" : "BACK",
			"from" : 1387,
			"face" : "back",
			"tags" : [
				"P15"
			],
			"type" : "panel",
			"to" : 1328,
			"number" : 21059
		},
		{
			"uuid" : "9561cd1f-4aa4-a346-b907-241727baaafb",
			"name" : "21060",
			"_clazz" : "TwkSegment",
			"brick" : "BACK",
			"from" : 1335,
			"face" : "back",
			"tags" : [
				"P15"
			],
			"type" : "panel",
			"to" : 1387,
			"number" : 21060
		},
		{
			"uuid" : "c3ffedf5-5548-f74b-a915-628cb69c283b",
			"name" : "21061",
			"_clazz" : "TwkSegment",
			"brick" : "RIGHT",
			"from" : 1388,
			"face" : "right",
			"tags" : [
				"P15"
			],
			"type" : "panel",
			"to" : 1328,
			"number" : 21061
		},
		{
			"uuid" : "25ad58bc-3526-9747-aa15-bbb3914ceab4",
			"name" : "21062",
			"_clazz" : "TwkSegment",
			"brick" : "RIGHT",
			"from" : 1333,
			"face" : "right",
			"tags" : [
				"P15"
			],
			"type" : "panel",
			"to" : 1388,
			"number" : 21062
		},
		{
			"uuid" : "76e8da02-41e6-144a-9028-d122a976908c",
			"name" : "21063",
			"_clazz" : "TwkSegment",
			"brick" : "RIGHT",
			"from" : 1388,
			"face" : "right",
			"tags" : [
				"P15"
			],
			"type" : "panel",
			"to" : 1325,
			"number" : 21063
		},
		{
			"uuid" : "130b8f08-7810-d245-ac2e-767c26261e18",
			"name" : "21064",
			"_clazz" : "TwkSegment",
			"brick" : "RIGHT",
			"from" : 1336,
			"face" : "right",
			"tags" : [
				"P15"
			],
			"type" : "panel",
			"to" : 1388,
			"number" : 21064
		},
		{
			"uuid" : "f83e3248-c470-c541-b1a4-00f737479630",
			"name" : "21065",
			"_clazz" : "TwkSegment",
			"brick" : "FRONT",
			"from" : 1389,
			"face" : "front",
			"tags" : [
				"P15"
			],
			"type" : "panel",
			"to" : 1333,
			"number" : 21065
		},
		{
			"uuid" : "0a066064-866b-e249-ae78-4b5e78b130db",
			"name" : "21066",
			"_clazz" : "TwkSegment",
			"brick" : "FRONT",
			"from" : 1342,
			"face" : "front",
			"tags" : [
				"P15"
			],
			"type" : "panel",
			"to" : 1389,
			"number" : 21066
		},
		{
			"uuid" : "97e3ada0-8c72-d148-a63a-f704fbd97763",
			"name" : "21067",
			"_clazz" : "TwkSegment",
			"brick" : "FRONT",
			"from" : 1389,
			"face" : "front",
			"tags" : [
				"P15"
			],
			"type" : "panel",
			"to" : 1334,
			"number" : 21067
		},
		{
			"uuid" : "c4bf2f62-2c19-4e40-ae3f-3bd04eb3135c",
			"name" : "21068",
			"_clazz" : "TwkSegment",
			"brick" : "FRONT",
			"from" : 1341,
			"face" : "front",
			"tags" : [
				"P15"
			],
			"type" : "panel",
			"to" : 1389,
			"number" : 21068
		},
		{
			"uuid" : "08d992f3-a2ac-0e4a-bf9e-c0b427ce6d06",
			"name" : "21069",
			"_clazz" : "TwkSegment",
			"brick" : "LEFT",
			"from" : 1390,
			"face" : "left",
			"tags" : [
				"P15"
			],
			"type" : "panel",
			"to" : 1334,
			"number" : 21069
		},
		{
			"uuid" : "551ffa2a-dfbc-ee45-ba1a-3a4f6e314905",
			"name" : "21070",
			"_clazz" : "TwkSegment",
			"brick" : "LEFT",
			"from" : 1343,
			"face" : "left",
			"tags" : [
				"P15"
			],
			"type" : "panel",
			"to" : 1390,
			"number" : 21070
		},
		{
			"uuid" : "51447037-37fd-7d49-95f3-dd9cf46db250",
			"name" : "21071",
			"_clazz" : "TwkSegment",
			"brick" : "LEFT",
			"from" : 1390,
			"face" : "left",
			"tags" : [
				"P15"
			],
			"type" : "panel",
			"to" : 1335,
			"number" : 21071
		},
		{
			"uuid" : "53e1cbf2-e711-a046-b195-dae412dd3105",
			"name" : "21072",
			"_clazz" : "TwkSegment",
			"brick" : "LEFT",
			"from" : 1342,
			"face" : "left",
			"tags" : [
				"P15"
			],
			"type" : "panel",
			"to" : 1390,
			"number" : 21072
		},
		{
			"uuid" : "30d28755-f9cb-814a-9d77-ad9e83ae5e2b",
			"name" : "21073",
			"_clazz" : "TwkSegment",
			"brick" : "BACK",
			"from" : 1391,
			"face" : "back",
			"tags" : [
				"P15"
			],
			"type" : "panel",
			"to" : 1335,
			"number" : 21073
		},
		{
			"uuid" : "e30ab45f-3e68-9148-9f9e-3b44cecdbf0d",
			"name" : "21074",
			"_clazz" : "TwkSegment",
			"brick" : "BACK",
			"from" : 1344,
			"face" : "back",
			"tags" : [
				"P15"
			],
			"type" : "panel",
			"to" : 1391,
			"number" : 21074
		},
		{
			"uuid" : "397ebc4a-4eac-ab4d-bc2e-315a29853c3e",
			"name" : "21075",
			"_clazz" : "TwkSegment",
			"brick" : "BACK",
			"from" : 1391,
			"face" : "back",
			"tags" : [
				"P15"
			],
			"type" : "panel",
			"to" : 1336,
			"number" : 21075
		},
		{
			"uuid" : "a3b74d5f-f981-9d43-a227-1ea7b14d6876",
			"name" : "21076",
			"_clazz" : "TwkSegment",
			"brick" : "BACK",
			"from" : 1343,
			"face" : "back",
			"tags" : [
				"P15"
			],
			"type" : "panel",
			"to" : 1391,
			"number" : 21076
		},
		{
			"uuid" : "4214a19f-3738-f540-90fb-8b287b1cb7b2",
			"name" : "21077",
			"_clazz" : "TwkSegment",
			"brick" : "RIGHT",
			"from" : 1392,
			"face" : "right",
			"tags" : [
				"P15"
			],
			"type" : "panel",
			"to" : 1336,
			"number" : 21077
		},
		{
			"uuid" : "610d4dfa-fb02-e64f-8fac-f19689160a13",
			"name" : "21078",
			"_clazz" : "TwkSegment",
			"brick" : "RIGHT",
			"from" : 1341,
			"face" : "right",
			"tags" : [
				"P15"
			],
			"type" : "panel",
			"to" : 1392,
			"number" : 21078
		},
		{
			"uuid" : "34bea999-5ea1-e04a-ade2-9c3ecea34c28",
			"name" : "21079",
			"_clazz" : "TwkSegment",
			"brick" : "RIGHT",
			"from" : 1392,
			"face" : "right",
			"tags" : [
				"P15"
			],
			"type" : "panel",
			"to" : 1333,
			"number" : 21079
		},
		{
			"uuid" : "114938cd-d88b-e94b-857f-c0530d0c9d7a",
			"name" : "21080",
			"_clazz" : "TwkSegment",
			"brick" : "RIGHT",
			"from" : 1344,
			"face" : "right",
			"tags" : [
				"P15"
			],
			"type" : "panel",
			"to" : 1392,
			"number" : 21080
		},
		{
			"uuid" : "d60ee31a-6bb0-ef4b-b6cc-d28d7f135da4",
			"name" : "21081",
			"_clazz" : "TwkSegment",
			"brick" : "FRONT",
			"from" : 1393,
			"face" : "front",
			"tags" : [
				"P15"
			],
			"type" : "panel",
			"to" : 1341,
			"number" : 21081
		},
		{
			"uuid" : "8a01af98-2e89-2c40-bb1c-adb3a81361c1",
			"name" : "21082",
			"_clazz" : "TwkSegment",
			"brick" : "FRONT",
			"from" : 1350,
			"face" : "front",
			"tags" : [
				"P15"
			],
			"type" : "panel",
			"to" : 1393,
			"number" : 21082
		},
		{
			"uuid" : "004221f1-3375-384a-8e5f-a55b79d3c8b5",
			"name" : "21083",
			"_clazz" : "TwkSegment",
			"brick" : "FRONT",
			"from" : 1393,
			"face" : "front",
			"tags" : [
				"P15"
			],
			"type" : "panel",
			"to" : 1342,
			"number" : 21083
		},
		{
			"uuid" : "3de3fbba-adfd-8142-94dc-9745ab4923dc",
			"name" : "21084",
			"_clazz" : "TwkSegment",
			"brick" : "FRONT",
			"from" : 1349,
			"face" : "front",
			"tags" : [
				"P15"
			],
			"type" : "panel",
			"to" : 1393,
			"number" : 21084
		},
		{
			"uuid" : "35960606-de5a-0044-9283-4cc8c07dbd9d",
			"name" : "21085",
			"_clazz" : "TwkSegment",
			"brick" : "LEFT",
			"from" : 1394,
			"face" : "left",
			"tags" : [
				"P15"
			],
			"type" : "panel",
			"to" : 1342,
			"number" : 21085
		},
		{
			"uuid" : "19cbb6a6-5646-624b-85fe-7171634108a4",
			"name" : "21086",
			"_clazz" : "TwkSegment",
			"brick" : "LEFT",
			"from" : 1351,
			"face" : "left",
			"tags" : [
				"P15"
			],
			"type" : "panel",
			"to" : 1394,
			"number" : 21086
		},
		{
			"uuid" : "07a0ef65-0785-234d-b46c-091dc4884bd8",
			"name" : "21087",
			"_clazz" : "TwkSegment",
			"brick" : "LEFT",
			"from" : 1394,
			"face" : "left",
			"tags" : [
				"P15"
			],
			"type" : "panel",
			"to" : 1343,
			"number" : 21087
		},
		{
			"uuid" : "7ea9b9df-424b-9e43-9c1a-d3df85bf3004",
			"name" : "21088",
			"_clazz" : "TwkSegment",
			"brick" : "LEFT",
			"from" : 1350,
			"face" : "left",
			"tags" : [
				"P15"
			],
			"type" : "panel",
			"to" : 1394,
			"number" : 21088
		},
		{
			"uuid" : "90a8dc5f-6f21-7d4a-91e4-82e3eb9d5918",
			"name" : "21089",
			"_clazz" : "TwkSegment",
			"brick" : "BACK",
			"from" : 1395,
			"face" : "back",
			"tags" : [
				"P15"
			],
			"type" : "panel",
			"to" : 1343,
			"number" : 21089
		},
		{
			"uuid" : "5dbc5d5b-2674-da46-85d0-25e7760887d9",
			"name" : "21090",
			"_clazz" : "TwkSegment",
			"brick" : "BACK",
			"from" : 1352,
			"face" : "back",
			"tags" : [
				"P15"
			],
			"type" : "panel",
			"to" : 1395,
			"number" : 21090
		},
		{
			"uuid" : "b9507d4f-ca5e-af4c-93f7-97a3d4214c4a",
			"name" : "21091",
			"_clazz" : "TwkSegment",
			"brick" : "BACK",
			"from" : 1395,
			"face" : "back",
			"tags" : [
				"P15"
			],
			"type" : "panel",
			"to" : 1344,
			"number" : 21091
		},
		{
			"uuid" : "88947a47-b312-9f4b-8d5c-74ef31ea10cc",
			"name" : "21092",
			"_clazz" : "TwkSegment",
			"brick" : "BACK",
			"from" : 1351,
			"face" : "back",
			"tags" : [
				"P15"
			],
			"type" : "panel",
			"to" : 1395,
			"number" : 21092
		},
		{
			"uuid" : "fb038af2-4dde-3a44-837a-4552cdbed65a",
			"name" : "21093",
			"_clazz" : "TwkSegment",
			"brick" : "RIGHT",
			"from" : 1396,
			"face" : "right",
			"tags" : [
				"P15"
			],
			"type" : "panel",
			"to" : 1344,
			"number" : 21093
		},
		{
			"uuid" : "d0c64e48-e525-6f4a-af17-ce98e5cf0571",
			"name" : "21094",
			"_clazz" : "TwkSegment",
			"brick" : "RIGHT",
			"from" : 1349,
			"face" : "right",
			"tags" : [
				"P15"
			],
			"type" : "panel",
			"to" : 1396,
			"number" : 21094
		},
		{
			"uuid" : "18b14e51-92a1-624d-85a0-bff58c1cc059",
			"name" : "21095",
			"_clazz" : "TwkSegment",
			"brick" : "RIGHT",
			"from" : 1396,
			"face" : "right",
			"tags" : [
				"P15"
			],
			"type" : "panel",
			"to" : 1341,
			"number" : 21095
		},
		{
			"uuid" : "ad1dc469-2e89-6141-aeef-db64689db2aa",
			"name" : "21096",
			"_clazz" : "TwkSegment",
			"brick" : "RIGHT",
			"from" : 1352,
			"face" : "right",
			"tags" : [
				"P15"
			],
			"type" : "panel",
			"to" : 1396,
			"number" : 21096
		},
		{
			"uuid" : "460d32a8-413c-2542-b1d3-5bf9e6cd054c",
			"name" : "21097",
			"_clazz" : "TwkSegment",
			"brick" : "FRONT",
			"from" : 1397,
			"face" : "front",
			"tags" : [
				"P15"
			],
			"type" : "panel",
			"to" : 1349,
			"number" : 21097
		},
		{
			"uuid" : "ce9f2ee9-b2db-4246-98c8-85d72c187e6e",
			"name" : "21098",
			"_clazz" : "TwkSegment",
			"brick" : "FRONT",
			"from" : 1350,
			"face" : "front",
			"tags" : [
				"P15"
			],
			"type" : "panel",
			"to" : 1397,
			"number" : 21098
		},
		{
			"uuid" : "30d915d0-adcd-754a-918c-6fcb58387847",
			"name" : "21099",
			"_clazz" : "TwkSegment",
			"brick" : "LEFT",
			"from" : 1398,
			"face" : "left",
			"tags" : [
				"P15"
			],
			"type" : "panel",
			"to" : 1350,
			"number" : 21099
		},
		{
			"uuid" : "965fd49d-4df1-d645-b96c-f796bb7df50a",
			"name" : "21100",
			"_clazz" : "TwkSegment",
			"brick" : "LEFT",
			"from" : 1351,
			"face" : "left",
			"tags" : [
				"P15"
			],
			"type" : "panel",
			"to" : 1398,
			"number" : 21100
		},
		{
			"uuid" : "1ff53b35-b520-8649-8718-aa7a797d7bac",
			"name" : "21101",
			"_clazz" : "TwkSegment",
			"brick" : "BACK",
			"from" : 1399,
			"face" : "back",
			"tags" : [
				"P15"
			],
			"type" : "panel",
			"to" : 1351,
			"number" : 21101
		},
		{
			"uuid" : "3d61aa9e-d76e-6147-ac90-606bcb3c93e2",
			"name" : "21102",
			"_clazz" : "TwkSegment",
			"brick" : "BACK",
			"from" : 1352,
			"face" : "back",
			"tags" : [
				"P15"
			],
			"type" : "panel",
			"to" : 1399,
			"number" : 21102
		},
		{
			"uuid" : "ef237e7b-51a8-854f-8daf-3f88d402b78b",
			"name" : "21103",
			"_clazz" : "TwkSegment",
			"brick" : "RIGHT",
			"from" : 1400,
			"face" : "right",
			"tags" : [
				"P15"
			],
			"type" : "panel",
			"to" : 1352,
			"number" : 21103
		},
		{
			"uuid" : "cf0a0cd6-b83e-544f-88b3-9d570907ed8f",
			"name" : "21104",
			"_clazz" : "TwkSegment",
			"brick" : "RIGHT",
			"from" : 1349,
			"face" : "right",
			"tags" : [
				"P15"
			],
			"type" : "panel",
			"to" : 1400,
			"number" : 21104
		},
		{
			"uuid" : "84a69a36-07b1-7348-8553-657a73990c59",
			"name" : "21105",
			"_clazz" : "TwkSegment",
			"brick" : "FRONT",
			"from" : 1358,
			"face" : "front",
			"tags" : [
				"P15"
			],
			"type" : "panel",
			"to" : 1397,
			"number" : 21105
		},
		{
			"uuid" : "7caeec31-b285-6840-b683-c48f2a47ee48",
			"name" : "21106",
			"_clazz" : "TwkSegment",
			"brick" : "FRONT",
			"from" : 1397,
			"face" : "front",
			"tags" : [
				"P15"
			],
			"type" : "panel",
			"to" : 1357,
			"number" : 21106
		},
		{
			"uuid" : "42c6f01e-9ada-7e45-98e5-b3d2c266d518",
			"name" : "21107",
			"_clazz" : "TwkSegment",
			"brick" : "LEFT",
			"from" : 1359,
			"face" : "left",
			"tags" : [
				"P15"
			],
			"type" : "panel",
			"to" : 1398,
			"number" : 21107
		},
		{
			"uuid" : "fe7a1acf-8fe6-d943-82de-d2a1acb4a620",
			"name" : "21108",
			"_clazz" : "TwkSegment",
			"brick" : "LEFT",
			"from" : 1398,
			"face" : "left",
			"tags" : [
				"P15"
			],
			"type" : "panel",
			"to" : 1358,
			"number" : 21108
		},
		{
			"uuid" : "3ce8c2f2-afd4-4042-be69-2455f5abc9e1",
			"name" : "21109",
			"_clazz" : "TwkSegment",
			"brick" : "BACK",
			"from" : 1360,
			"face" : "back",
			"tags" : [
				"P15"
			],
			"type" : "panel",
			"to" : 1399,
			"number" : 21109
		},
		{
			"uuid" : "1938edce-1c0a-ea42-a232-f8bafdb68d3f",
			"name" : "21110",
			"_clazz" : "TwkSegment",
			"brick" : "BACK",
			"from" : 1399,
			"face" : "back",
			"tags" : [
				"P15"
			],
			"type" : "panel",
			"to" : 1359,
			"number" : 21110
		},
		{
			"uuid" : "52203b7b-fc7d-064c-9686-315b2c342349",
			"name" : "21111",
			"_clazz" : "TwkSegment",
			"brick" : "RIGHT",
			"from" : 1357,
			"face" : "right",
			"tags" : [
				"P15"
			],
			"type" : "panel",
			"to" : 1400,
			"number" : 21111
		},
		{
			"uuid" : "2ab352b9-a7a3-6843-9e0f-86f531412bbb",
			"name" : "21112",
			"_clazz" : "TwkSegment",
			"brick" : "RIGHT",
			"from" : 1400,
			"face" : "right",
			"tags" : [
				"P15"
			],
			"type" : "panel",
			"to" : 1360,
			"number" : 21112
		},
		{
			"uuid" : "1b98553d-0405-584f-880c-8b775c1624f9",
			"name" : "21113",
			"_clazz" : "TwkSegment",
			"brick" : "FRONT",
			"from" : 1401,
			"face" : "front",
			"tags" : [
				"P15"
			],
			"type" : "panel",
			"to" : 1357,
			"number" : 21113
		},
		{
			"uuid" : "ed045806-e1f7-ac46-9129-1dae327c49e5",
			"name" : "21114",
			"_clazz" : "TwkSegment",
			"brick" : "FRONT",
			"from" : 1366,
			"face" : "front",
			"tags" : [
				"P15"
			],
			"type" : "panel",
			"to" : 1401,
			"number" : 21114
		},
		{
			"uuid" : "1b04887a-3e23-074b-bf23-10b2dadd7225",
			"name" : "21115",
			"_clazz" : "TwkSegment",
			"brick" : "FRONT",
			"from" : 1401,
			"face" : "front",
			"tags" : [
				"P15"
			],
			"type" : "panel",
			"to" : 1358,
			"number" : 21115
		},
		{
			"uuid" : "4794e6ec-bdc7-0c4e-b06f-26d9186e0024",
			"name" : "21116",
			"_clazz" : "TwkSegment",
			"brick" : "FRONT",
			"from" : 1365,
			"face" : "front",
			"tags" : [
				"P15"
			],
			"type" : "panel",
			"to" : 1401,
			"number" : 21116
		},
		{
			"uuid" : "88e9aef4-0a21-4d4f-971d-a1e4852bedaa",
			"name" : "21117",
			"_clazz" : "TwkSegment",
			"brick" : "LEFT",
			"from" : 1402,
			"face" : "left",
			"tags" : [
				"P15"
			],
			"type" : "panel",
			"to" : 1358,
			"number" : 21117
		},
		{
			"uuid" : "49e40f65-819b-0847-a38a-9d7ffb78e854",
			"name" : "21118",
			"_clazz" : "TwkSegment",
			"brick" : "LEFT",
			"from" : 1367,
			"face" : "left",
			"tags" : [
				"P15"
			],
			"type" : "panel",
			"to" : 1402,
			"number" : 21118
		},
		{
			"uuid" : "cb5e544b-1f02-a14f-b078-8871f0d2587d",
			"name" : "21119",
			"_clazz" : "TwkSegment",
			"brick" : "LEFT",
			"from" : 1402,
			"face" : "left",
			"tags" : [
				"P15"
			],
			"type" : "panel",
			"to" : 1359,
			"number" : 21119
		},
		{
			"uuid" : "25f5f34d-8f4d-d248-ac5e-1687eb622425",
			"name" : "21120",
			"_clazz" : "TwkSegment",
			"brick" : "LEFT",
			"from" : 1366,
			"face" : "left",
			"tags" : [
				"P15"
			],
			"type" : "panel",
			"to" : 1402,
			"number" : 21120
		},
		{
			"uuid" : "73349af6-1659-2247-8e33-d83c1742c915",
			"name" : "21121",
			"_clazz" : "TwkSegment",
			"brick" : "BACK",
			"from" : 1403,
			"face" : "back",
			"tags" : [
				"P15"
			],
			"type" : "panel",
			"to" : 1359,
			"number" : 21121
		},
		{
			"uuid" : "339574ff-1cd8-d742-afa7-69cd51477bcb",
			"name" : "21122",
			"_clazz" : "TwkSegment",
			"brick" : "BACK",
			"from" : 1368,
			"face" : "back",
			"tags" : [
				"P15"
			],
			"type" : "panel",
			"to" : 1403,
			"number" : 21122
		},
		{
			"uuid" : "6dc5a703-7ae2-ba46-927d-38fb258f64e8",
			"name" : "21123",
			"_clazz" : "TwkSegment",
			"brick" : "BACK",
			"from" : 1403,
			"face" : "back",
			"tags" : [
				"P15"
			],
			"type" : "panel",
			"to" : 1360,
			"number" : 21123
		},
		{
			"uuid" : "6f3183c3-2a14-ff4e-8a92-19cdfe558806",
			"name" : "21124",
			"_clazz" : "TwkSegment",
			"brick" : "BACK",
			"from" : 1367,
			"face" : "back",
			"tags" : [
				"P15"
			],
			"type" : "panel",
			"to" : 1403,
			"number" : 21124
		},
		{
			"uuid" : "8f332ea5-c468-a34a-a2dc-c7905e94cfb5",
			"name" : "21125",
			"_clazz" : "TwkSegment",
			"brick" : "RIGHT",
			"from" : 1404,
			"face" : "right",
			"tags" : [
				"P15"
			],
			"type" : "panel",
			"to" : 1360,
			"number" : 21125
		},
		{
			"uuid" : "ce4cea03-175a-2442-831b-8cf9b18fb9df",
			"name" : "21126",
			"_clazz" : "TwkSegment",
			"brick" : "RIGHT",
			"from" : 1365,
			"face" : "right",
			"tags" : [
				"P15"
			],
			"type" : "panel",
			"to" : 1404,
			"number" : 21126
		},
		{
			"uuid" : "64f8ad7e-d242-2440-856e-1f0365e29d9e",
			"name" : "21127",
			"_clazz" : "TwkSegment",
			"brick" : "RIGHT",
			"from" : 1404,
			"face" : "right",
			"tags" : [
				"P15"
			],
			"type" : "panel",
			"to" : 1357,
			"number" : 21127
		},
		{
			"uuid" : "b4aeeb17-307f-ff49-8eea-27c1f2f17c79",
			"name" : "21128",
			"_clazz" : "TwkSegment",
			"brick" : "RIGHT",
			"from" : 1368,
			"face" : "right",
			"tags" : [
				"P15"
			],
			"type" : "panel",
			"to" : 1404,
			"number" : 21128
		},
		{
			"uuid" : "fa32520e-7f45-6f42-80bc-9b78b1bd8a14",
			"name" : "21129",
			"_clazz" : "TwkSegment",
			"brick" : "FRONT",
			"from" : 1405,
			"face" : "front",
			"tags" : [
				"P15"
			],
			"type" : "panel",
			"to" : 1365,
			"number" : 21129
		},
		{
			"uuid" : "231b2bee-8735-4f48-bbc8-fd563df34751",
			"name" : "21130",
			"_clazz" : "TwkSegment",
			"brick" : "FRONT",
			"from" : 1374,
			"face" : "front",
			"tags" : [
				"P15"
			],
			"type" : "panel",
			"to" : 1405,
			"number" : 21130
		},
		{
			"uuid" : "47281649-3e51-434e-a7a3-7ad4a232a735",
			"name" : "21131",
			"_clazz" : "TwkSegment",
			"brick" : "FRONT",
			"from" : 1405,
			"face" : "front",
			"tags" : [
				"P15"
			],
			"type" : "panel",
			"to" : 1366,
			"number" : 21131
		},
		{
			"uuid" : "3f7406e2-f2fe-f94a-b023-ef0c1c1ff80c",
			"name" : "21132",
			"_clazz" : "TwkSegment",
			"brick" : "FRONT",
			"from" : 1373,
			"face" : "front",
			"tags" : [
				"P15"
			],
			"type" : "panel",
			"to" : 1405,
			"number" : 21132
		},
		{
			"uuid" : "6a046790-d843-1440-9c46-31463a14cbd0",
			"name" : "21133",
			"_clazz" : "TwkSegment",
			"brick" : "LEFT",
			"from" : 1406,
			"face" : "left",
			"tags" : [
				"P15"
			],
			"type" : "panel",
			"to" : 1366,
			"number" : 21133
		},
		{
			"uuid" : "60e770e6-3373-2f4f-b7f7-1d73832c96aa",
			"name" : "21134",
			"_clazz" : "TwkSegment",
			"brick" : "LEFT",
			"from" : 1375,
			"face" : "left",
			"tags" : [
				"P15"
			],
			"type" : "panel",
			"to" : 1406,
			"number" : 21134
		},
		{
			"uuid" : "89c05beb-d625-e54b-ad5c-f154914fc1ce",
			"name" : "21135",
			"_clazz" : "TwkSegment",
			"brick" : "LEFT",
			"from" : 1406,
			"face" : "left",
			"tags" : [
				"P15"
			],
			"type" : "panel",
			"to" : 1367,
			"number" : 21135
		},
		{
			"uuid" : "e5983998-c660-4341-b8f8-3783123cc1d3",
			"name" : "21136",
			"_clazz" : "TwkSegment",
			"brick" : "LEFT",
			"from" : 1374,
			"face" : "left",
			"tags" : [
				"P15"
			],
			"type" : "panel",
			"to" : 1406,
			"number" : 21136
		},
		{
			"uuid" : "ba2a3b41-257c-ed4e-9e14-ab81608d5fcb",
			"name" : "21137",
			"_clazz" : "TwkSegment",
			"brick" : "BACK",
			"from" : 1407,
			"face" : "back",
			"tags" : [
				"P15"
			],
			"type" : "panel",
			"to" : 1367,
			"number" : 21137
		},
		{
			"uuid" : "7c2ac409-d9d4-624d-ba24-b1d72670d983",
			"name" : "21138",
			"_clazz" : "TwkSegment",
			"brick" : "BACK",
			"from" : 1376,
			"face" : "back",
			"tags" : [
				"P15"
			],
			"type" : "panel",
			"to" : 1407,
			"number" : 21138
		},
		{
			"uuid" : "1bcb65ab-825f-8641-beee-6bdf8bb605b7",
			"name" : "21139",
			"_clazz" : "TwkSegment",
			"brick" : "BACK",
			"from" : 1407,
			"face" : "back",
			"tags" : [
				"P15"
			],
			"type" : "panel",
			"to" : 1368,
			"number" : 21139
		},
		{
			"uuid" : "f5c4c5e9-4326-8448-9ab5-87c6e645c657",
			"name" : "21140",
			"_clazz" : "TwkSegment",
			"brick" : "BACK",
			"from" : 1375,
			"face" : "back",
			"tags" : [
				"P15"
			],
			"type" : "panel",
			"to" : 1407,
			"number" : 21140
		},
		{
			"uuid" : "16dfaed9-58c5-e14a-a349-7b06dc25bcf9",
			"name" : "21141",
			"_clazz" : "TwkSegment",
			"brick" : "RIGHT",
			"from" : 1408,
			"face" : "right",
			"tags" : [
				"P15"
			],
			"type" : "panel",
			"to" : 1368,
			"number" : 21141
		},
		{
			"uuid" : "d2005467-cf7c-954d-bf49-e4c123b00e76",
			"name" : "21142",
			"_clazz" : "TwkSegment",
			"brick" : "RIGHT",
			"from" : 1373,
			"face" : "right",
			"tags" : [
				"P15"
			],
			"type" : "panel",
			"to" : 1408,
			"number" : 21142
		},
		{
			"uuid" : "ae695cda-a924-1147-af3e-66761b8dc204",
			"name" : "21143",
			"_clazz" : "TwkSegment",
			"brick" : "RIGHT",
			"from" : 1408,
			"face" : "right",
			"tags" : [
				"P15"
			],
			"type" : "panel",
			"to" : 1365,
			"number" : 21143
		},
		{
			"uuid" : "98ad6f7a-0586-dc49-b2fe-8983b40c93b7",
			"name" : "21144",
			"_clazz" : "TwkSegment",
			"brick" : "RIGHT",
			"from" : 1376,
			"face" : "right",
			"tags" : [
				"P15"
			],
			"type" : "panel",
			"to" : 1408,
			"number" : 21144
		},
		{
			"number" : 13001,
			"tags" : [
				"P16"
			],
			"type" : "slope",
			"to" : 1505,
			"from" : 1501,
			"brick" : "P16",
			"name" : "13001",
			"uuid" : "9a80dcef-7514-8d4b-b5b4-a45f3402f8ea",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 13002,
			"tags" : [
				"P16"
			],
			"type" : "slope",
			"to" : 1506,
			"from" : 1502,
			"brick" : "P16",
			"name" : "13002",
			"uuid" : "c9702b27-81d5-c548-80b3-3e2f7ec4d34c",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 13003,
			"tags" : [
				"P16"
			],
			"type" : "slope",
			"to" : 1507,
			"from" : 1503,
			"brick" : "P16",
			"name" : "13003",
			"uuid" : "5a883fe1-a62f-3e45-a328-80e63a56d8ff",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 13004,
			"tags" : [
				"P16"
			],
			"type" : "slope",
			"to" : 1508,
			"from" : 1504,
			"brick" : "P16",
			"name" : "13004",
			"uuid" : "3024cdbb-a60f-d747-a6e7-515bd640d2b3",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 13005,
			"tags" : [
				"P16"
			],
			"type" : "slope",
			"to" : 1509,
			"from" : 1505,
			"brick" : "P16",
			"name" : "13005",
			"uuid" : "11501140-89ce-014b-af57-57d7c93e0306",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 13006,
			"tags" : [
				"P16"
			],
			"type" : "slope",
			"to" : 1510,
			"from" : 1506,
			"brick" : "P16",
			"name" : "13006",
			"uuid" : "bf9c4094-7c54-4844-832c-674046eb7fee",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 13007,
			"tags" : [
				"P16"
			],
			"type" : "slope",
			"to" : 1511,
			"from" : 1507,
			"brick" : "P16",
			"name" : "13007",
			"uuid" : "ae1ed72d-f7cc-2740-99b2-4c8604b91366",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 13008,
			"tags" : [
				"P16"
			],
			"type" : "slope",
			"to" : 1512,
			"from" : 1508,
			"brick" : "P16",
			"name" : "13008",
			"uuid" : "9a8293b3-63ff-0040-8363-a287aba962de",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 13009,
			"tags" : [
				"P16"
			],
			"type" : "slope",
			"to" : 1513,
			"from" : 1509,
			"brick" : "P16",
			"name" : "13009",
			"uuid" : "9b667739-3407-e04f-824d-37102de8bb53",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 13010,
			"tags" : [
				"P16"
			],
			"type" : "slope",
			"to" : 1514,
			"from" : 1510,
			"brick" : "P16",
			"name" : "13010",
			"uuid" : "1f725d08-6342-114f-8ee7-f57d882b14c6",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 13011,
			"tags" : [
				"P16"
			],
			"type" : "slope",
			"to" : 1515,
			"from" : 1511,
			"brick" : "P16",
			"name" : "13011",
			"uuid" : "01f46118-8a42-da46-90ef-9bc19d604357",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 13012,
			"tags" : [
				"P16"
			],
			"type" : "slope",
			"to" : 1516,
			"from" : 1512,
			"brick" : "P16",
			"name" : "13012",
			"uuid" : "6a45ebc6-0465-1744-a793-6255580464dd",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 13013,
			"tags" : [
				"P16"
			],
			"type" : "slope",
			"to" : 1517,
			"from" : 1513,
			"brick" : "P16",
			"name" : "13013",
			"uuid" : "4a7a3027-1124-654f-a48d-bf3b06aa5eaa",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 13014,
			"tags" : [
				"P16"
			],
			"type" : "slope",
			"to" : 1518,
			"from" : 1514,
			"brick" : "P16",
			"name" : "13014",
			"uuid" : "18584642-32ca-a043-b4c8-9acce482d0ce",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 13015,
			"tags" : [
				"P16"
			],
			"type" : "slope",
			"to" : 1519,
			"from" : 1515,
			"brick" : "P16",
			"name" : "13015",
			"uuid" : "1144cbe4-9c77-eb4d-af1d-868e81213536",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 13016,
			"tags" : [
				"P16"
			],
			"type" : "slope",
			"to" : 1520,
			"from" : 1516,
			"brick" : "P16",
			"name" : "13016",
			"uuid" : "ec317014-9d1e-854c-ab79-da2bc7d687f7",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 13017,
			"tags" : [
				"P16"
			],
			"type" : "slope",
			"to" : 1521,
			"from" : 1517,
			"brick" : "P16",
			"name" : "13017",
			"uuid" : "868d48ee-b124-3945-b9ab-a97b0d5495e2",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 13018,
			"tags" : [
				"P16"
			],
			"type" : "slope",
			"to" : 1522,
			"from" : 1518,
			"brick" : "P16",
			"name" : "13018",
			"uuid" : "8b15a109-f206-3b43-aef0-0c8760591660",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 13019,
			"tags" : [
				"P16"
			],
			"type" : "slope",
			"to" : 1523,
			"from" : 1519,
			"brick" : "P16",
			"name" : "13019",
			"uuid" : "1b384cbb-ab26-f04f-91c8-2a961aee9983",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 13020,
			"tags" : [
				"P16"
			],
			"type" : "slope",
			"to" : 1524,
			"from" : 1520,
			"brick" : "P16",
			"name" : "13020",
			"uuid" : "216e6dac-4269-4b49-bfa8-f5f9d169e14c",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 13021,
			"tags" : [
				"P16"
			],
			"type" : "slope",
			"to" : 1525,
			"from" : 1521,
			"brick" : "P16",
			"name" : "13021",
			"uuid" : "cc8d9fc6-bdb0-5e4a-96f2-9b1ead622400",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 13022,
			"tags" : [
				"P16"
			],
			"type" : "slope",
			"to" : 1526,
			"from" : 1522,
			"brick" : "P16",
			"name" : "13022",
			"uuid" : "e2148c28-2c16-8540-aafb-9fe094c068ee",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 13023,
			"tags" : [
				"P16"
			],
			"type" : "slope",
			"to" : 1527,
			"from" : 1523,
			"brick" : "P16",
			"name" : "13023",
			"uuid" : "aa602e22-710f-fd41-93f1-d697195b6938",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 13024,
			"tags" : [
				"P16"
			],
			"type" : "slope",
			"to" : 1528,
			"from" : 1524,
			"brick" : "P16",
			"name" : "13024",
			"uuid" : "b0bf6d15-3223-a245-8a08-5e544f22b21f",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 13025,
			"tags" : [
				"P16"
			],
			"type" : "slope",
			"to" : 1529,
			"from" : 1525,
			"brick" : "P16",
			"name" : "13025",
			"uuid" : "b8a1a4a4-1592-c242-90f8-3c44c7a78dea",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 13026,
			"tags" : [
				"P16"
			],
			"type" : "slope",
			"to" : 1530,
			"from" : 1526,
			"brick" : "P16",
			"name" : "13026",
			"uuid" : "4ee699a6-eb71-a441-bd0e-c09d3e426e25",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 13027,
			"tags" : [
				"P16"
			],
			"type" : "slope",
			"to" : 1531,
			"from" : 1527,
			"brick" : "P16",
			"name" : "13027",
			"uuid" : "2ffe86f9-c68a-3d4b-8c3a-5bc0c9e38f1e",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 13028,
			"tags" : [
				"P16"
			],
			"type" : "slope",
			"to" : 1532,
			"from" : 1528,
			"brick" : "P16",
			"name" : "13028",
			"uuid" : "aaa36b78-5a70-0448-a514-540ceaf19566",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 13029,
			"tags" : [
				"P16"
			],
			"type" : "slope",
			"to" : 1533,
			"from" : 1529,
			"brick" : "P16",
			"name" : "13029",
			"uuid" : "deb8ebcc-bc61-4147-ac31-1728b1ef7842",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 13030,
			"tags" : [
				"P16"
			],
			"type" : "slope",
			"to" : 1534,
			"from" : 1530,
			"brick" : "P16",
			"name" : "13030",
			"uuid" : "bde7b296-b509-0641-a19d-b37a1a1194d1",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 13031,
			"tags" : [
				"P16"
			],
			"type" : "slope",
			"to" : 1535,
			"from" : 1531,
			"brick" : "P16",
			"name" : "13031",
			"uuid" : "8ead019f-2236-cd4c-8d68-c71abead0846",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 13032,
			"tags" : [
				"P16"
			],
			"type" : "slope",
			"to" : 1536,
			"from" : 1532,
			"brick" : "P16",
			"name" : "13032",
			"uuid" : "13d83d89-785a-fe4e-b43c-8b6a0169ad1c",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 13033,
			"tags" : [
				"P16"
			],
			"type" : "slope",
			"to" : 1537,
			"from" : 1533,
			"brick" : "P16",
			"name" : "13033",
			"uuid" : "bff2db2c-ae2d-f840-8c87-8d0263d983c8",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 13034,
			"tags" : [
				"P16"
			],
			"type" : "slope",
			"to" : 1538,
			"from" : 1534,
			"brick" : "P16",
			"name" : "13034",
			"uuid" : "e9f74c4b-6d8c-fb43-8fce-fbdfa6711e50",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 13035,
			"tags" : [
				"P16"
			],
			"type" : "slope",
			"to" : 1539,
			"from" : 1535,
			"brick" : "P16",
			"name" : "13035",
			"uuid" : "1b83eb8a-6834-9447-aa6f-cd6a3b71f563",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 13036,
			"tags" : [
				"P16"
			],
			"type" : "slope",
			"to" : 1540,
			"from" : 1536,
			"brick" : "P16",
			"name" : "13036",
			"uuid" : "f69ae47d-2976-9642-b37e-569bcd37ba76",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 13037,
			"tags" : [
				"P16"
			],
			"type" : "slope",
			"to" : 1541,
			"from" : 1537,
			"brick" : "P16",
			"name" : "13037",
			"uuid" : "6d8883a7-0296-3548-b86e-362a36d7d347",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 13038,
			"tags" : [
				"P16"
			],
			"type" : "slope",
			"to" : 1542,
			"from" : 1538,
			"brick" : "P16",
			"name" : "13038",
			"uuid" : "7001c38f-b3f6-b143-bfc0-31c8baf5bd16",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 13039,
			"tags" : [
				"P16"
			],
			"type" : "slope",
			"to" : 1543,
			"from" : 1539,
			"brick" : "P16",
			"name" : "13039",
			"uuid" : "acc807ca-04d5-2a49-8ad4-623c76ed5347",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 13040,
			"tags" : [
				"P16"
			],
			"type" : "slope",
			"to" : 1544,
			"from" : 1540,
			"brick" : "P16",
			"name" : "13040",
			"uuid" : "b14a8c08-032a-1344-99cc-10659d99ab54",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 13041,
			"tags" : [
				"P16"
			],
			"type" : "slope",
			"to" : 1545,
			"from" : 1541,
			"brick" : "P16",
			"name" : "13041",
			"uuid" : "0cd7ee9a-5feb-1244-b7fb-34f8894c6b2e",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 13042,
			"tags" : [
				"P16"
			],
			"type" : "slope",
			"to" : 1546,
			"from" : 1542,
			"brick" : "P16",
			"name" : "13042",
			"uuid" : "7c404cfa-ee9e-f14b-a74e-0d9793a9e87c",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 13043,
			"tags" : [
				"P16"
			],
			"type" : "slope",
			"to" : 1547,
			"from" : 1543,
			"brick" : "P16",
			"name" : "13043",
			"uuid" : "c900a6c9-acd9-7746-8813-4c453b67f5ff",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 13044,
			"tags" : [
				"P16"
			],
			"type" : "slope",
			"to" : 1548,
			"from" : 1544,
			"brick" : "P16",
			"name" : "13044",
			"uuid" : "b60e616f-2576-0949-866f-96b8c7fb23da",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 13045,
			"tags" : [
				"P16"
			],
			"type" : "slope",
			"to" : 1549,
			"from" : 1545,
			"brick" : "P16",
			"name" : "13045",
			"uuid" : "6a9142c5-bbaf-dc44-ad49-5bd834735532",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 13046,
			"tags" : [
				"P16"
			],
			"type" : "slope",
			"to" : 1550,
			"from" : 1546,
			"brick" : "P16",
			"name" : "13046",
			"uuid" : "ed925be4-0fa9-0d44-9ced-beed7e7c9aef",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 13047,
			"tags" : [
				"P16"
			],
			"type" : "slope",
			"to" : 1551,
			"from" : 1547,
			"brick" : "P16",
			"name" : "13047",
			"uuid" : "78b142b4-543b-c244-9c01-45facc692a44",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 13048,
			"tags" : [
				"P16"
			],
			"type" : "slope",
			"to" : 1552,
			"from" : 1548,
			"brick" : "P16",
			"name" : "13048",
			"uuid" : "d95a9842-3a79-4d46-a207-19574e95ac1e",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 13049,
			"tags" : [
				"P16"
			],
			"type" : "slope",
			"to" : 1553,
			"from" : 1549,
			"brick" : "P16",
			"name" : "13049",
			"uuid" : "200ffbc7-f691-5241-b4c3-bb038825b361",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 13050,
			"tags" : [
				"P16"
			],
			"type" : "slope",
			"to" : 1554,
			"from" : 1550,
			"brick" : "P16",
			"name" : "13050",
			"uuid" : "6c7b0633-3a0f-c34c-9713-1f3434232eb8",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 13051,
			"tags" : [
				"P16"
			],
			"type" : "slope",
			"to" : 1555,
			"from" : 1551,
			"brick" : "P16",
			"name" : "13051",
			"uuid" : "028ea6e5-2df3-814c-8cd3-e7d18fe61b0e",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 13052,
			"tags" : [
				"P16"
			],
			"type" : "slope",
			"to" : 1556,
			"from" : 1552,
			"brick" : "P16",
			"name" : "13052",
			"uuid" : "80103d93-eb51-cf40-b0e5-f4c874786626",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 13053,
			"tags" : [
				"P16"
			],
			"type" : "slope",
			"to" : 1557,
			"from" : 1553,
			"brick" : "P16",
			"name" : "13053",
			"uuid" : "8e6aba7d-e558-5c40-b730-6dcc2b450d80",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 13054,
			"tags" : [
				"P16"
			],
			"type" : "slope",
			"to" : 1558,
			"from" : 1554,
			"brick" : "P16",
			"name" : "13054",
			"uuid" : "2cdf6cf7-0c28-d14e-9834-b8db2b85ce4c",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 13055,
			"tags" : [
				"P16"
			],
			"type" : "slope",
			"to" : 1559,
			"from" : 1555,
			"brick" : "P16",
			"name" : "13055",
			"uuid" : "ac2a2bd5-7b00-5949-993b-9935fb065460",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 13056,
			"tags" : [
				"P16"
			],
			"type" : "slope",
			"to" : 1560,
			"from" : 1556,
			"brick" : "P16",
			"name" : "13056",
			"uuid" : "0a3f9c7f-7ef8-324c-8063-67a35412f578",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 31001,
			"tags" : [
				"P16"
			],
			"type" : "sectionRound",
			"to" : 1502,
			"from" : 1501,
			"brick" : "P16",
			"name" : "31001",
			"uuid" : "0883f5eb-201f-704a-a2e7-5e5b471d0aa5",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 31002,
			"tags" : [
				"P16"
			],
			"type" : "sectionRound",
			"to" : 1503,
			"from" : 1502,
			"brick" : "P16",
			"name" : "31002",
			"uuid" : "8f6bb183-72fe-d247-863a-8b71385473e9",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 31003,
			"tags" : [
				"P16"
			],
			"type" : "sectionRound",
			"to" : 1504,
			"from" : 1503,
			"brick" : "P16",
			"name" : "31003",
			"uuid" : "9060edd5-fbb9-6945-91f1-9ebb24dc765d",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 31004,
			"tags" : [
				"P16"
			],
			"type" : "sectionRound",
			"to" : 1501,
			"from" : 1504,
			"brick" : "P16",
			"name" : "31004",
			"uuid" : "f8a7d0b0-fa2b-7949-8bfc-f46bc9938c2b",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 31005,
			"tags" : [
				"P16"
			],
			"type" : "sectionRound",
			"to" : 1506,
			"from" : 1505,
			"brick" : "P16",
			"name" : "31005",
			"uuid" : "6e9e9337-d8d7-8948-8885-5bd3ad942a53",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 31006,
			"tags" : [
				"P16"
			],
			"type" : "sectionRound",
			"to" : 1507,
			"from" : 1506,
			"brick" : "P16",
			"name" : "31006",
			"uuid" : "ab6232cc-74d5-394f-b51d-7d057f53c8c0",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 31007,
			"tags" : [
				"P16"
			],
			"type" : "sectionRound",
			"to" : 1508,
			"from" : 1507,
			"brick" : "P16",
			"name" : "31007",
			"uuid" : "15af5f9e-320f-5d46-9891-aaf4365ed5d7",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 31008,
			"tags" : [
				"P16"
			],
			"type" : "sectionRound",
			"to" : 1505,
			"from" : 1508,
			"brick" : "P16",
			"name" : "31008",
			"uuid" : "e5c204df-83c9-5d45-80fd-d28270fdb5a2",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 31009,
			"tags" : [
				"P16"
			],
			"type" : "sectionRound",
			"to" : 1569,
			"from" : 1513,
			"brick" : "P16",
			"name" : "31009",
			"uuid" : "3bff00c0-cdfe-4b4a-acea-0e57038286e0",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 31010,
			"tags" : [
				"P16"
			],
			"type" : "sectionRound",
			"to" : 1514,
			"from" : 1569,
			"brick" : "P16",
			"name" : "31010",
			"uuid" : "e5787f7e-5009-5c49-a605-e65c88161b5f",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 31011,
			"tags" : [
				"P16"
			],
			"type" : "sectionRound",
			"to" : 1570,
			"from" : 1514,
			"brick" : "P16",
			"name" : "31011",
			"uuid" : "08883aa0-39b4-d943-af19-964b80b082e5",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 31012,
			"tags" : [
				"P16"
			],
			"type" : "sectionRound",
			"to" : 1515,
			"from" : 1570,
			"brick" : "P16",
			"name" : "31012",
			"uuid" : "232181c3-1043-ad41-8f71-06c0693780d1",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 31013,
			"tags" : [
				"P16"
			],
			"type" : "sectionRound",
			"to" : 1571,
			"from" : 1515,
			"brick" : "P16",
			"name" : "31013",
			"uuid" : "c81d2a2c-f630-7f4b-9328-7159d04283be",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 31014,
			"tags" : [
				"P16"
			],
			"type" : "sectionRound",
			"to" : 1516,
			"from" : 1571,
			"brick" : "P16",
			"name" : "31014",
			"uuid" : "46fc4718-a860-9848-b936-0db59460e313",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 31015,
			"tags" : [
				"P16"
			],
			"type" : "sectionRound",
			"to" : 1572,
			"from" : 1516,
			"brick" : "P16",
			"name" : "31015",
			"uuid" : "c202aa01-2489-8044-972a-42f2d3dee0dd",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 31016,
			"tags" : [
				"P16"
			],
			"type" : "sectionRound",
			"to" : 1513,
			"from" : 1572,
			"brick" : "P16",
			"name" : "31016",
			"uuid" : "5b7aaa5b-4b07-aa4b-a0e8-f0bb6740609f",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 31017,
			"tags" : [
				"P16"
			],
			"type" : "sectionRound",
			"to" : 1573,
			"from" : 1521,
			"brick" : "P16",
			"name" : "31017",
			"uuid" : "b9ce502e-4963-8f44-889c-f8b05663e11b",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 31018,
			"tags" : [
				"P16"
			],
			"type" : "sectionRound",
			"to" : 1522,
			"from" : 1573,
			"brick" : "P16",
			"name" : "31018",
			"uuid" : "4b167a38-a334-e046-a59d-b22bb6ebfa38",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 31019,
			"tags" : [
				"P16"
			],
			"type" : "sectionRound",
			"to" : 1574,
			"from" : 1522,
			"brick" : "P16",
			"name" : "31019",
			"uuid" : "4e8e58a1-4fde-b540-b229-db2074dc8e19",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 31020,
			"tags" : [
				"P16"
			],
			"type" : "sectionRound",
			"to" : 1523,
			"from" : 1574,
			"brick" : "P16",
			"name" : "31020",
			"uuid" : "79c4123b-8925-f04b-b9eb-2287af3e9a22",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 31021,
			"tags" : [
				"P16"
			],
			"type" : "sectionRound",
			"to" : 1575,
			"from" : 1523,
			"brick" : "P16",
			"name" : "31021",
			"uuid" : "d9ab8ad4-70bd-3a41-98ce-770bbdd61dc1",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 31022,
			"tags" : [
				"P16"
			],
			"type" : "sectionRound",
			"to" : 1524,
			"from" : 1575,
			"brick" : "P16",
			"name" : "31022",
			"uuid" : "1588afc4-4487-fa4e-b459-c5808a7f99a5",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 31023,
			"tags" : [
				"P16"
			],
			"type" : "sectionRound",
			"to" : 1576,
			"from" : 1524,
			"brick" : "P16",
			"name" : "31023",
			"uuid" : "e60ce565-c07e-df44-ba90-3ce47fb8b384",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 31024,
			"tags" : [
				"P16"
			],
			"type" : "sectionRound",
			"to" : 1521,
			"from" : 1576,
			"brick" : "P16",
			"name" : "31024",
			"uuid" : "32b8cbff-d372-e048-bd35-15b7dc805479",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 31025,
			"tags" : [
				"P16"
			],
			"type" : "sectionRound",
			"to" : 1577,
			"from" : 1529,
			"brick" : "P16",
			"name" : "31025",
			"uuid" : "8c7ac654-31cc-0a4d-9fdc-e6f4327d23f2",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 31026,
			"tags" : [
				"P16"
			],
			"type" : "sectionRound",
			"to" : 1530,
			"from" : 1577,
			"brick" : "P16",
			"name" : "31026",
			"uuid" : "302e1aa7-d5aa-c642-8b5d-5caf4a9fed34",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 31027,
			"tags" : [
				"P16"
			],
			"type" : "sectionRound",
			"to" : 1578,
			"from" : 1530,
			"brick" : "P16",
			"name" : "31027",
			"uuid" : "0226fc31-ffed-2d46-a3c2-8178c97705e3",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 31028,
			"tags" : [
				"P16"
			],
			"type" : "sectionRound",
			"to" : 1531,
			"from" : 1578,
			"brick" : "P16",
			"name" : "31028",
			"uuid" : "d3d3633b-70b2-db4b-838e-0ca1066206d0",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 31029,
			"tags" : [
				"P16"
			],
			"type" : "sectionRound",
			"to" : 1579,
			"from" : 1531,
			"brick" : "P16",
			"name" : "31029",
			"uuid" : "f2ddb5c2-c17f-c448-a695-797e7de905b7",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 31030,
			"tags" : [
				"P16"
			],
			"type" : "sectionRound",
			"to" : 1532,
			"from" : 1579,
			"brick" : "P16",
			"name" : "31030",
			"uuid" : "770ad472-e9f7-514c-9439-aadf16a3720f",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 31031,
			"tags" : [
				"P16"
			],
			"type" : "sectionRound",
			"to" : 1580,
			"from" : 1532,
			"brick" : "P16",
			"name" : "31031",
			"uuid" : "ba6735e4-5f24-8247-bed1-ebda4498227e",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 31032,
			"tags" : [
				"P16"
			],
			"type" : "sectionRound",
			"to" : 1529,
			"from" : 1580,
			"brick" : "P16",
			"name" : "31032",
			"uuid" : "f78f8759-914d-6741-9540-86f84e93bf18",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 31033,
			"tags" : [
				"P16"
			],
			"type" : "sectionRound",
			"to" : 1534,
			"from" : 1533,
			"brick" : "P16",
			"name" : "31033",
			"uuid" : "f08afe3f-ce81-344f-b5aa-ce4a266a3bcc",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 31034,
			"tags" : [
				"P16"
			],
			"type" : "sectionRound",
			"to" : 1535,
			"from" : 1534,
			"brick" : "P16",
			"name" : "31034",
			"uuid" : "77197826-62fb-f444-840a-b18379e387e0",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 31035,
			"tags" : [
				"P16"
			],
			"type" : "sectionRound",
			"to" : 1536,
			"from" : 1535,
			"brick" : "P16",
			"name" : "31035",
			"uuid" : "c288ee58-2bd4-a14b-bc8f-a60250e1eb1d",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 31036,
			"tags" : [
				"P16"
			],
			"type" : "sectionRound",
			"to" : 1533,
			"from" : 1536,
			"brick" : "P16",
			"name" : "31036",
			"uuid" : "68f8ff53-5939-ac45-8dfd-c146cbe9e433",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 31037,
			"tags" : [
				"P16"
			],
			"type" : "sectionRound",
			"to" : 1581,
			"from" : 1537,
			"brick" : "P16",
			"name" : "31037",
			"uuid" : "4976243b-c524-564c-90dc-6f51b8fab76e",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 31038,
			"tags" : [
				"P16"
			],
			"type" : "sectionRound",
			"to" : 1538,
			"from" : 1581,
			"brick" : "P16",
			"name" : "31038",
			"uuid" : "c4ce0009-e0ff-6841-95ff-aec548df92c8",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 31039,
			"tags" : [
				"P16"
			],
			"type" : "sectionRound",
			"to" : 1582,
			"from" : 1538,
			"brick" : "P16",
			"name" : "31039",
			"uuid" : "66f9af61-cf27-4f4a-ba8a-b85f5bd324e3",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 31040,
			"tags" : [
				"P16"
			],
			"type" : "sectionRound",
			"to" : 1539,
			"from" : 1582,
			"brick" : "P16",
			"name" : "31040",
			"uuid" : "9c50bcb7-db63-fc4e-abbd-faddd6a98589",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 31041,
			"tags" : [
				"P16"
			],
			"type" : "sectionRound",
			"to" : 1583,
			"from" : 1539,
			"brick" : "P16",
			"name" : "31041",
			"uuid" : "0874da4c-26bb-8741-8327-3fa744dc82a9",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 31042,
			"tags" : [
				"P16"
			],
			"type" : "sectionRound",
			"to" : 1540,
			"from" : 1583,
			"brick" : "P16",
			"name" : "31042",
			"uuid" : "eb56f1bf-6128-2d46-933e-c94115f79b5c",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 31043,
			"tags" : [
				"P16"
			],
			"type" : "sectionRound",
			"to" : 1584,
			"from" : 1540,
			"brick" : "P16",
			"name" : "31043",
			"uuid" : "9be477bd-6e80-684c-bb2a-ae8770008586",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 31044,
			"tags" : [
				"P16"
			],
			"type" : "sectionRound",
			"to" : 1537,
			"from" : 1584,
			"brick" : "P16",
			"name" : "31044",
			"uuid" : "8fa7240e-dcc8-9f4c-94f6-e1f22f18a2a7",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 31045,
			"tags" : [
				"P16"
			],
			"type" : "sectionRound",
			"to" : 1585,
			"from" : 1545,
			"brick" : "P16",
			"name" : "31045",
			"uuid" : "921326d1-433d-fd4d-8d1a-51cbfcb76038",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 31046,
			"tags" : [
				"P16"
			],
			"type" : "sectionRound",
			"to" : 1546,
			"from" : 1585,
			"brick" : "P16",
			"name" : "31046",
			"uuid" : "b9bb12b3-a86b-294f-89de-0e38d89b2c5d",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 31047,
			"tags" : [
				"P16"
			],
			"type" : "sectionRound",
			"to" : 1586,
			"from" : 1546,
			"brick" : "P16",
			"name" : "31047",
			"uuid" : "05adb4f0-6eb0-704c-94ab-0c2d0edebc73",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 31048,
			"tags" : [
				"P16"
			],
			"type" : "sectionRound",
			"to" : 1547,
			"from" : 1586,
			"brick" : "P16",
			"name" : "31048",
			"uuid" : "e87aacef-3dee-b041-af00-31a37c2d1800",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 31049,
			"tags" : [
				"P16"
			],
			"type" : "sectionRound",
			"to" : 1587,
			"from" : 1547,
			"brick" : "P16",
			"name" : "31049",
			"uuid" : "ed7321e1-da7b-0441-9393-e1a16e7d8031",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 31050,
			"tags" : [
				"P16"
			],
			"type" : "sectionRound",
			"to" : 1548,
			"from" : 1587,
			"brick" : "P16",
			"name" : "31050",
			"uuid" : "400c1f36-4e66-bc41-a549-bc5c61799766",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 31051,
			"tags" : [
				"P16"
			],
			"type" : "sectionRound",
			"to" : 1588,
			"from" : 1548,
			"brick" : "P16",
			"name" : "31051",
			"uuid" : "890183c2-8cb9-d44b-884b-382b79311a8d",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 31052,
			"tags" : [
				"P16"
			],
			"type" : "sectionRound",
			"to" : 1545,
			"from" : 1588,
			"brick" : "P16",
			"name" : "31052",
			"uuid" : "ede7334f-f012-964e-ae1a-2558ff5f4fa8",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 31053,
			"tags" : [
				"P16"
			],
			"type" : "sectionRound",
			"to" : 1589,
			"from" : 1553,
			"brick" : "P16",
			"name" : "31053",
			"uuid" : "0e51ef9e-4f55-bb49-8030-27bb24d2c812",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 31054,
			"tags" : [
				"P16"
			],
			"type" : "sectionRound",
			"to" : 1554,
			"from" : 1589,
			"brick" : "P16",
			"name" : "31054",
			"uuid" : "6dae5309-8fa8-0d4b-ae2f-c4a6c05bf556",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 31055,
			"tags" : [
				"P16"
			],
			"type" : "sectionRound",
			"to" : 1590,
			"from" : 1554,
			"brick" : "P16",
			"name" : "31055",
			"uuid" : "c11f9dda-d0fc-dd42-a3a3-f791b41dad7b",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 31056,
			"tags" : [
				"P16"
			],
			"type" : "sectionRound",
			"to" : 1555,
			"from" : 1590,
			"brick" : "P16",
			"name" : "31056",
			"uuid" : "57a29175-fb83-6c44-8808-a589189b0c88",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 31057,
			"tags" : [
				"P16"
			],
			"type" : "sectionRound",
			"to" : 1591,
			"from" : 1555,
			"brick" : "P16",
			"name" : "31057",
			"uuid" : "e61379ae-145c-bb44-844f-e7e1a55f3830",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 31058,
			"tags" : [
				"P16"
			],
			"type" : "sectionRound",
			"to" : 1556,
			"from" : 1591,
			"brick" : "P16",
			"name" : "31058",
			"uuid" : "6214ed9a-9c17-464f-9a2f-a15b52ea91fc",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 31059,
			"tags" : [
				"P16"
			],
			"type" : "sectionRound",
			"to" : 1592,
			"from" : 1556,
			"brick" : "P16",
			"name" : "31059",
			"uuid" : "ea397777-fe11-c449-8a7b-1a6d8a206c18",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 31060,
			"tags" : [
				"P16"
			],
			"type" : "sectionRound",
			"to" : 1553,
			"from" : 1592,
			"brick" : "P16",
			"name" : "31060",
			"uuid" : "962c84db-4340-ae45-946c-397541518b65",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 31101,
			"tags" : [
				"P16"
			],
			"type" : "sectionSlant",
			"to" : 1504,
			"from" : 2501,
			"brick" : "P16",
			"name" : "31101",
			"uuid" : "95ad6a7d-6f6e-ba4c-aacd-828dcbfe51c0",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 31102,
			"tags" : [
				"P16"
			],
			"type" : "sectionSlant",
			"to" : 2501,
			"from" : 1502,
			"brick" : "P16",
			"name" : "31102",
			"uuid" : "bbc3dc93-c670-8e44-8984-f633bdf3ed48",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 31103,
			"tags" : [
				"P16"
			],
			"type" : "sectionSlant",
			"to" : 1503,
			"from" : 2501,
			"brick" : "P16",
			"name" : "31103",
			"uuid" : "0ea09537-1bee-2d45-8fa8-2837e98c34db",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 31104,
			"tags" : [
				"P16"
			],
			"type" : "sectionSlant",
			"to" : 2501,
			"from" : 1501,
			"brick" : "P16",
			"name" : "31104",
			"uuid" : "8105179d-1677-a543-9675-cbf8a18d5cd6",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 31105,
			"tags" : [
				"P16"
			],
			"type" : "sectionSlant",
			"to" : 1508,
			"from" : 2502,
			"brick" : "P16",
			"name" : "31105",
			"uuid" : "5405503f-d2c8-634c-af35-388909389783",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 31106,
			"tags" : [
				"P16"
			],
			"type" : "sectionSlant",
			"to" : 2502,
			"from" : 1506,
			"brick" : "P16",
			"name" : "31106",
			"uuid" : "e91d141f-f689-764c-ab24-5b1d519552d8",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 31107,
			"tags" : [
				"P16"
			],
			"type" : "sectionSlant",
			"to" : 1507,
			"from" : 2502,
			"brick" : "P16",
			"name" : "31107",
			"uuid" : "d1cbce14-0646-dd43-8c27-b349bceedf9c",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 31108,
			"tags" : [
				"P16"
			],
			"type" : "sectionSlant",
			"to" : 2502,
			"from" : 1505,
			"brick" : "P16",
			"name" : "31108",
			"uuid" : "3b84a9ca-f6ea-834f-9cf1-2e429bf96bfc",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 31109,
			"tags" : [
				"P16"
			],
			"type" : "sectionSlant",
			"to" : 1569,
			"from" : 1572,
			"brick" : "P16",
			"name" : "31109",
			"uuid" : "6e5433d0-48d5-0a48-8cd5-7adfd7f330cf",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 31110,
			"tags" : [
				"P16"
			],
			"type" : "sectionSlant",
			"to" : 1570,
			"from" : 1569,
			"brick" : "P16",
			"name" : "31110",
			"uuid" : "214b2b35-8cf5-7c48-b378-131e5c8d0dc7",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 31111,
			"tags" : [
				"P16"
			],
			"type" : "sectionSlant",
			"to" : 1571,
			"from" : 1570,
			"brick" : "P16",
			"name" : "31111",
			"uuid" : "7e56b496-1024-4945-93e2-bd6340bd39cc",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 31112,
			"tags" : [
				"P16"
			],
			"type" : "sectionSlant",
			"to" : 1572,
			"from" : 1571,
			"brick" : "P16",
			"name" : "31112",
			"uuid" : "da032ac9-9122-1a45-95c1-4a70f1e5d012",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 31113,
			"tags" : [
				"P16"
			],
			"type" : "sectionSlant",
			"to" : 1573,
			"from" : 1576,
			"brick" : "P16",
			"name" : "31113",
			"uuid" : "0a63c836-2f08-264f-8611-2103cd4da585",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 31114,
			"tags" : [
				"P16"
			],
			"type" : "sectionSlant",
			"to" : 1574,
			"from" : 1573,
			"brick" : "P16",
			"name" : "31114",
			"uuid" : "a802772a-901c-1b4a-9681-1de92dbe5830",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 31115,
			"tags" : [
				"P16"
			],
			"type" : "sectionSlant",
			"to" : 1575,
			"from" : 1574,
			"brick" : "P16",
			"name" : "31115",
			"uuid" : "6fb3c7a1-7968-844c-84e2-7103f951ab3b",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 31116,
			"tags" : [
				"P16"
			],
			"type" : "sectionSlant",
			"to" : 1576,
			"from" : 1575,
			"brick" : "P16",
			"name" : "31116",
			"uuid" : "3a414816-dc35-fc4b-9bd3-dfba4a3c713c",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 31117,
			"tags" : [
				"P16"
			],
			"type" : "sectionSlant",
			"to" : 1577,
			"from" : 1580,
			"brick" : "P16",
			"name" : "31117",
			"uuid" : "19ff2bb4-5b89-9647-bbec-591d386657c3",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 31118,
			"tags" : [
				"P16"
			],
			"type" : "sectionSlant",
			"to" : 1578,
			"from" : 1577,
			"brick" : "P16",
			"name" : "31118",
			"uuid" : "89b1c9ac-67c3-494d-9b15-f91d312dfebc",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 31119,
			"tags" : [
				"P16"
			],
			"type" : "sectionSlant",
			"to" : 1579,
			"from" : 1578,
			"brick" : "P16",
			"name" : "31119",
			"uuid" : "3996dcad-7533-8046-a03a-9addbf7ea272",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 31120,
			"tags" : [
				"P16"
			],
			"type" : "sectionSlant",
			"to" : 1580,
			"from" : 1579,
			"brick" : "P16",
			"name" : "31120",
			"uuid" : "ef06a3b4-b404-bd4d-8f8b-6e035794b541",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 31121,
			"tags" : [
				"P16"
			],
			"type" : "sectionSlant",
			"to" : 1581,
			"from" : 1584,
			"brick" : "P16",
			"name" : "31121",
			"uuid" : "56e0488b-cf2b-9f42-b33e-7a5e11ee9597",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 31122,
			"tags" : [
				"P16"
			],
			"type" : "sectionSlant",
			"to" : 1582,
			"from" : 1581,
			"brick" : "P16",
			"name" : "31122",
			"uuid" : "f47833d4-a291-ba40-86c7-8262ac736317",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 31123,
			"tags" : [
				"P16"
			],
			"type" : "sectionSlant",
			"to" : 1583,
			"from" : 1582,
			"brick" : "P16",
			"name" : "31123",
			"uuid" : "b6651ea1-01c4-8740-b268-7f23f66a6355",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 31124,
			"tags" : [
				"P16"
			],
			"type" : "sectionSlant",
			"to" : 1584,
			"from" : 1583,
			"brick" : "P16",
			"name" : "31124",
			"uuid" : "4a6292bc-32f0-0349-9863-cbec2f9b49e6",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 31125,
			"tags" : [
				"P16"
			],
			"type" : "sectionSlant",
			"to" : 1585,
			"from" : 1588,
			"brick" : "P16",
			"name" : "31125",
			"uuid" : "4a724111-7393-2242-80ab-21b2e07edb57",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 31126,
			"tags" : [
				"P16"
			],
			"type" : "sectionSlant",
			"to" : 1586,
			"from" : 1585,
			"brick" : "P16",
			"name" : "31126",
			"uuid" : "be31588a-66ea-2e44-bb10-4b2f7b6220ed",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 31127,
			"tags" : [
				"P16"
			],
			"type" : "sectionSlant",
			"to" : 1587,
			"from" : 1586,
			"brick" : "P16",
			"name" : "31127",
			"uuid" : "98eba8e8-43bc-144e-84e8-45e160112f4c",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 31128,
			"tags" : [
				"P16"
			],
			"type" : "sectionSlant",
			"to" : 1588,
			"from" : 1587,
			"brick" : "P16",
			"name" : "31128",
			"uuid" : "56ea63da-e2ab-724f-8426-a9b9c3163e32",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 31129,
			"tags" : [
				"P16"
			],
			"type" : "sectionSlant",
			"to" : 1589,
			"from" : 1592,
			"brick" : "P16",
			"name" : "31129",
			"uuid" : "f09df895-b73c-7644-9955-4ea57c51a08e",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 31130,
			"tags" : [
				"P16"
			],
			"type" : "sectionSlant",
			"to" : 1590,
			"from" : 1589,
			"brick" : "P16",
			"name" : "31130",
			"uuid" : "2707e15c-69f5-6d4c-b84b-d875642db9b0",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 31131,
			"tags" : [
				"P16"
			],
			"type" : "sectionSlant",
			"to" : 1591,
			"from" : 1590,
			"brick" : "P16",
			"name" : "31131",
			"uuid" : "7cfb2d45-6682-0248-80d8-4a2593bb8399",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 31132,
			"tags" : [
				"P16"
			],
			"type" : "sectionSlant",
			"to" : 1592,
			"from" : 1591,
			"brick" : "P16",
			"name" : "31132",
			"uuid" : "ce44f196-3ab8-4e4c-b4c2-d319f0c81970",
			"_clazz" : "TwkSegment"
		},
		{
			"uuid" : "d0dbfd5e-5d84-344b-a5c7-bb9db8fca3be",
			"name" : "22001",
			"_clazz" : "TwkSegment",
			"brick" : "FRONT",
			"from" : 1561,
			"face" : "front",
			"tags" : [
				"P16"
			],
			"type" : "panel",
			"to" : 1501,
			"number" : 22001
		},
		{
			"uuid" : "43bfd42c-e2aa-b940-9927-6bfa0e80db85",
			"name" : "22002",
			"_clazz" : "TwkSegment",
			"brick" : "FRONT",
			"from" : 1506,
			"face" : "front",
			"tags" : [
				"P16"
			],
			"type" : "panel",
			"to" : 1561,
			"number" : 22002
		},
		{
			"uuid" : "322d76d5-9b57-cd41-a8d4-283388116d36",
			"name" : "22003",
			"_clazz" : "TwkSegment",
			"brick" : "FRONT",
			"from" : 1561,
			"face" : "front",
			"tags" : [
				"P16"
			],
			"type" : "panel",
			"to" : 1502,
			"number" : 22003
		},
		{
			"uuid" : "5250aefc-2c88-1145-bf34-7894c88a411d",
			"name" : "22004",
			"_clazz" : "TwkSegment",
			"brick" : "FRONT",
			"from" : 1505,
			"face" : "front",
			"tags" : [
				"P16"
			],
			"type" : "panel",
			"to" : 1561,
			"number" : 22004
		},
		{
			"uuid" : "65ce98b0-9e5a-7f4a-b0a4-5cfaf068d67a",
			"name" : "22005",
			"_clazz" : "TwkSegment",
			"brick" : "LEFT",
			"from" : 1562,
			"face" : "left",
			"tags" : [
				"P16"
			],
			"type" : "panel",
			"to" : 1502,
			"number" : 22005
		},
		{
			"uuid" : "c60cd25f-5dbd-ea41-af4b-c29793adf625",
			"name" : "22006",
			"_clazz" : "TwkSegment",
			"brick" : "LEFT",
			"from" : 1507,
			"face" : "left",
			"tags" : [
				"P16"
			],
			"type" : "panel",
			"to" : 1562,
			"number" : 22006
		},
		{
			"uuid" : "433e508b-774e-7d49-8d9c-57f1c1a0a4de",
			"name" : "22007",
			"_clazz" : "TwkSegment",
			"brick" : "LEFT",
			"from" : 1562,
			"face" : "left",
			"tags" : [
				"P16"
			],
			"type" : "panel",
			"to" : 1503,
			"number" : 22007
		},
		{
			"uuid" : "13299b15-64f4-164f-8261-71312ff3ec28",
			"name" : "22008",
			"_clazz" : "TwkSegment",
			"brick" : "LEFT",
			"from" : 1506,
			"face" : "left",
			"tags" : [
				"P16"
			],
			"type" : "panel",
			"to" : 1562,
			"number" : 22008
		},
		{
			"uuid" : "bb2743f7-5b2b-2241-b217-99aba0e137d7",
			"name" : "22009",
			"_clazz" : "TwkSegment",
			"brick" : "BACK",
			"from" : 1563,
			"face" : "back",
			"tags" : [
				"P16"
			],
			"type" : "panel",
			"to" : 1503,
			"number" : 22009
		},
		{
			"uuid" : "c6d3a399-2786-0843-86a9-19ae884ad0c0",
			"name" : "22010",
			"_clazz" : "TwkSegment",
			"brick" : "BACK",
			"from" : 1508,
			"face" : "back",
			"tags" : [
				"P16"
			],
			"type" : "panel",
			"to" : 1563,
			"number" : 22010
		},
		{
			"uuid" : "ab65579b-440c-2045-9e18-72ce995c7dc8",
			"name" : "22011",
			"_clazz" : "TwkSegment",
			"brick" : "BACK",
			"from" : 1563,
			"face" : "back",
			"tags" : [
				"P16"
			],
			"type" : "panel",
			"to" : 1504,
			"number" : 22011
		},
		{
			"uuid" : "dfc6d318-4df7-6b40-bbf1-6d4b5e176abd",
			"name" : "22012",
			"_clazz" : "TwkSegment",
			"brick" : "BACK",
			"from" : 1507,
			"face" : "back",
			"tags" : [
				"P16"
			],
			"type" : "panel",
			"to" : 1563,
			"number" : 22012
		},
		{
			"uuid" : "953d7fc4-466b-a54b-afe5-73270354684e",
			"name" : "22013",
			"_clazz" : "TwkSegment",
			"brick" : "RIGHT",
			"from" : 1564,
			"face" : "right",
			"tags" : [
				"P16"
			],
			"type" : "panel",
			"to" : 1504,
			"number" : 22013
		},
		{
			"uuid" : "0cea1197-d98b-554a-8096-5de70a69d4bb",
			"name" : "22014",
			"_clazz" : "TwkSegment",
			"brick" : "RIGHT",
			"from" : 1505,
			"face" : "right",
			"tags" : [
				"P16"
			],
			"type" : "panel",
			"to" : 1564,
			"number" : 22014
		},
		{
			"uuid" : "fed4a4dd-da0d-0649-ac40-d9b1644bccd4",
			"name" : "22015",
			"_clazz" : "TwkSegment",
			"brick" : "RIGHT",
			"from" : 1564,
			"face" : "right",
			"tags" : [
				"P16"
			],
			"type" : "panel",
			"to" : 1501,
			"number" : 22015
		},
		{
			"uuid" : "81281272-020c-f740-a561-53dcc5a77ad5",
			"name" : "22016",
			"_clazz" : "TwkSegment",
			"brick" : "RIGHT",
			"from" : 1508,
			"face" : "right",
			"tags" : [
				"P16"
			],
			"type" : "panel",
			"to" : 1564,
			"number" : 22016
		},
		{
			"uuid" : "cd16e5d7-5127-4745-8012-5706c53e4f2f",
			"name" : "22017",
			"_clazz" : "TwkSegment",
			"brick" : "FRONT",
			"from" : 1565,
			"face" : "front",
			"tags" : [
				"P16"
			],
			"type" : "panel",
			"to" : 1505,
			"number" : 22017
		},
		{
			"uuid" : "5fc20cda-485b-be4f-9e85-97988b812dd3",
			"name" : "22018",
			"_clazz" : "TwkSegment",
			"brick" : "FRONT",
			"from" : 1510,
			"face" : "front",
			"tags" : [
				"P16"
			],
			"type" : "panel",
			"to" : 1565,
			"number" : 22018
		},
		{
			"uuid" : "7c2f2800-89e1-a948-898d-26fc16412fe9",
			"name" : "22019",
			"_clazz" : "TwkSegment",
			"brick" : "FRONT",
			"from" : 1565,
			"face" : "front",
			"tags" : [
				"P16"
			],
			"type" : "panel",
			"to" : 1506,
			"number" : 22019
		},
		{
			"uuid" : "f0a192a5-270a-4540-bb24-65e2c77a96f5",
			"name" : "22020",
			"_clazz" : "TwkSegment",
			"brick" : "FRONT",
			"from" : 1509,
			"face" : "front",
			"tags" : [
				"P16"
			],
			"type" : "panel",
			"to" : 1565,
			"number" : 22020
		},
		{
			"uuid" : "510b503f-f7ee-c847-88fb-888f9035a03a",
			"name" : "22021",
			"_clazz" : "TwkSegment",
			"brick" : "LEFT",
			"from" : 1566,
			"face" : "left",
			"tags" : [
				"P16"
			],
			"type" : "panel",
			"to" : 1506,
			"number" : 22021
		},
		{
			"uuid" : "f90cdc84-c081-a645-845a-ce23841b31f6",
			"name" : "22022",
			"_clazz" : "TwkSegment",
			"brick" : "LEFT",
			"from" : 1511,
			"face" : "left",
			"tags" : [
				"P16"
			],
			"type" : "panel",
			"to" : 1566,
			"number" : 22022
		},
		{
			"uuid" : "7d3e4e5a-d061-5c4a-bfd0-7189064e6006",
			"name" : "22023",
			"_clazz" : "TwkSegment",
			"brick" : "LEFT",
			"from" : 1566,
			"face" : "left",
			"tags" : [
				"P16"
			],
			"type" : "panel",
			"to" : 1507,
			"number" : 22023
		},
		{
			"uuid" : "928faf11-237e-8249-8541-36ea6957b71d",
			"name" : "22024",
			"_clazz" : "TwkSegment",
			"brick" : "LEFT",
			"from" : 1510,
			"face" : "left",
			"tags" : [
				"P16"
			],
			"type" : "panel",
			"to" : 1566,
			"number" : 22024
		},
		{
			"uuid" : "40083f95-9141-d44f-a9ef-e6b891ced227",
			"name" : "22025",
			"_clazz" : "TwkSegment",
			"brick" : "BACK",
			"from" : 1567,
			"face" : "back",
			"tags" : [
				"P16"
			],
			"type" : "panel",
			"to" : 1507,
			"number" : 22025
		},
		{
			"uuid" : "deffca40-1bc2-7642-acc4-0db7a417d4cf",
			"name" : "22026",
			"_clazz" : "TwkSegment",
			"brick" : "BACK",
			"from" : 1512,
			"face" : "back",
			"tags" : [
				"P16"
			],
			"type" : "panel",
			"to" : 1567,
			"number" : 22026
		},
		{
			"uuid" : "dfaca5e8-65ef-574a-b3f7-0e0a7b068a4d",
			"name" : "22027",
			"_clazz" : "TwkSegment",
			"brick" : "BACK",
			"from" : 1567,
			"face" : "back",
			"tags" : [
				"P16"
			],
			"type" : "panel",
			"to" : 1508,
			"number" : 22027
		},
		{
			"uuid" : "5ccd5b16-92d3-0540-ba8b-f1f91885d38c",
			"name" : "22028",
			"_clazz" : "TwkSegment",
			"brick" : "BACK",
			"from" : 1511,
			"face" : "back",
			"tags" : [
				"P16"
			],
			"type" : "panel",
			"to" : 1567,
			"number" : 22028
		},
		{
			"uuid" : "c83ee099-3f0e-1a4e-8e03-b1b89c51cac2",
			"name" : "22029",
			"_clazz" : "TwkSegment",
			"brick" : "RIGHT",
			"from" : 1568,
			"face" : "right",
			"tags" : [
				"P16"
			],
			"type" : "panel",
			"to" : 1508,
			"number" : 22029
		},
		{
			"uuid" : "97016549-b816-5841-8913-0d21c023edff",
			"name" : "22030",
			"_clazz" : "TwkSegment",
			"brick" : "RIGHT",
			"from" : 1509,
			"face" : "right",
			"tags" : [
				"P16"
			],
			"type" : "panel",
			"to" : 1568,
			"number" : 22030
		},
		{
			"uuid" : "e0420f25-3cc5-4d46-adba-b8a38dbb67d7",
			"name" : "22031",
			"_clazz" : "TwkSegment",
			"brick" : "RIGHT",
			"from" : 1568,
			"face" : "right",
			"tags" : [
				"P16"
			],
			"type" : "panel",
			"to" : 1505,
			"number" : 22031
		},
		{
			"uuid" : "cf2c0a94-08c0-e943-9bdb-55283193da21",
			"name" : "22032",
			"_clazz" : "TwkSegment",
			"brick" : "RIGHT",
			"from" : 1512,
			"face" : "right",
			"tags" : [
				"P16"
			],
			"type" : "panel",
			"to" : 1568,
			"number" : 22032
		},
		{
			"uuid" : "1d04f6a2-ce17-5448-bc96-07c0dfb3d9d1",
			"name" : "22033",
			"_clazz" : "TwkSegment",
			"brick" : "FRONT",
			"from" : 1569,
			"face" : "front",
			"tags" : [
				"P16"
			],
			"type" : "panel",
			"to" : 1509,
			"number" : 22033
		},
		{
			"uuid" : "fcce4c58-0774-3148-bcd6-67280de043f4",
			"name" : "22034",
			"_clazz" : "TwkSegment",
			"brick" : "FRONT",
			"from" : 1518,
			"face" : "front",
			"tags" : [
				"P16"
			],
			"type" : "panel",
			"to" : 1569,
			"number" : 22034
		},
		{
			"uuid" : "8106d56a-5d88-1b4a-ae72-2a3909ac31e2",
			"name" : "22035",
			"_clazz" : "TwkSegment",
			"brick" : "FRONT",
			"from" : 1569,
			"face" : "front",
			"tags" : [
				"P16"
			],
			"type" : "panel",
			"to" : 1510,
			"number" : 22035
		},
		{
			"uuid" : "db309734-07ae-b446-99b9-6c6808a4ba30",
			"name" : "22036",
			"_clazz" : "TwkSegment",
			"brick" : "FRONT",
			"from" : 1517,
			"face" : "front",
			"tags" : [
				"P16"
			],
			"type" : "panel",
			"to" : 1569,
			"number" : 22036
		},
		{
			"uuid" : "3c41d0f0-97b6-1a4b-bed5-e10dc3869281",
			"name" : "22037",
			"_clazz" : "TwkSegment",
			"brick" : "LEFT",
			"from" : 1570,
			"face" : "left",
			"tags" : [
				"P16"
			],
			"type" : "panel",
			"to" : 1510,
			"number" : 22037
		},
		{
			"uuid" : "b28dd37c-648e-974c-a494-c79d8f80425a",
			"name" : "22038",
			"_clazz" : "TwkSegment",
			"brick" : "LEFT",
			"from" : 1519,
			"face" : "left",
			"tags" : [
				"P16"
			],
			"type" : "panel",
			"to" : 1570,
			"number" : 22038
		},
		{
			"uuid" : "1ef75d9d-5ff2-5f42-8e58-f324d99b65c3",
			"name" : "22039",
			"_clazz" : "TwkSegment",
			"brick" : "LEFT",
			"from" : 1570,
			"face" : "left",
			"tags" : [
				"P16"
			],
			"type" : "panel",
			"to" : 1511,
			"number" : 22039
		},
		{
			"uuid" : "b9b548d3-d5f5-2445-9193-b8ffbae00729",
			"name" : "22040",
			"_clazz" : "TwkSegment",
			"brick" : "LEFT",
			"from" : 1518,
			"face" : "left",
			"tags" : [
				"P16"
			],
			"type" : "panel",
			"to" : 1570,
			"number" : 22040
		},
		{
			"uuid" : "d574e52d-363d-8b4b-aaf9-d5b1cf61e157",
			"name" : "22041",
			"_clazz" : "TwkSegment",
			"brick" : "BACK",
			"from" : 1571,
			"face" : "back",
			"tags" : [
				"P16"
			],
			"type" : "panel",
			"to" : 1511,
			"number" : 22041
		},
		{
			"uuid" : "11c2a210-8b52-a84f-a04a-1c052be5c0c8",
			"name" : "22042",
			"_clazz" : "TwkSegment",
			"brick" : "BACK",
			"from" : 1520,
			"face" : "back",
			"tags" : [
				"P16"
			],
			"type" : "panel",
			"to" : 1571,
			"number" : 22042
		},
		{
			"uuid" : "9c3dfe91-3a04-ba44-8df2-8a087c61fa67",
			"name" : "22043",
			"_clazz" : "TwkSegment",
			"brick" : "BACK",
			"from" : 1571,
			"face" : "back",
			"tags" : [
				"P16"
			],
			"type" : "panel",
			"to" : 1512,
			"number" : 22043
		},
		{
			"uuid" : "046810e2-b49d-0d40-bb60-323b57832019",
			"name" : "22044",
			"_clazz" : "TwkSegment",
			"brick" : "BACK",
			"from" : 1519,
			"face" : "back",
			"tags" : [
				"P16"
			],
			"type" : "panel",
			"to" : 1571,
			"number" : 22044
		},
		{
			"uuid" : "7258e5e2-4aaf-b941-8f87-fe3c1f71ed77",
			"name" : "22045",
			"_clazz" : "TwkSegment",
			"brick" : "RIGHT",
			"from" : 1572,
			"face" : "right",
			"tags" : [
				"P16"
			],
			"type" : "panel",
			"to" : 1512,
			"number" : 22045
		},
		{
			"uuid" : "55bb8f4e-fc60-c24e-b808-da1ce4c9661b",
			"name" : "22046",
			"_clazz" : "TwkSegment",
			"brick" : "RIGHT",
			"from" : 1517,
			"face" : "right",
			"tags" : [
				"P16"
			],
			"type" : "panel",
			"to" : 1572,
			"number" : 22046
		},
		{
			"uuid" : "bcfee139-3537-1a4f-872a-125c4df67cea",
			"name" : "22047",
			"_clazz" : "TwkSegment",
			"brick" : "RIGHT",
			"from" : 1572,
			"face" : "right",
			"tags" : [
				"P16"
			],
			"type" : "panel",
			"to" : 1509,
			"number" : 22047
		},
		{
			"uuid" : "3220b5d7-4733-8740-901e-d702464beabd",
			"name" : "22048",
			"_clazz" : "TwkSegment",
			"brick" : "RIGHT",
			"from" : 1520,
			"face" : "right",
			"tags" : [
				"P16"
			],
			"type" : "panel",
			"to" : 1572,
			"number" : 22048
		},
		{
			"uuid" : "669c1bfb-3249-2b47-895c-26fa2ed821c5",
			"name" : "22049",
			"_clazz" : "TwkSegment",
			"brick" : "FRONT",
			"from" : 1573,
			"face" : "front",
			"tags" : [
				"P16"
			],
			"type" : "panel",
			"to" : 1517,
			"number" : 22049
		},
		{
			"uuid" : "1709c2f1-8376-374e-8604-3938cf9ee46e",
			"name" : "22050",
			"_clazz" : "TwkSegment",
			"brick" : "FRONT",
			"from" : 1526,
			"face" : "front",
			"tags" : [
				"P16"
			],
			"type" : "panel",
			"to" : 1573,
			"number" : 22050
		},
		{
			"uuid" : "450e1934-491c-9441-884f-5ac7c9b004cf",
			"name" : "22051",
			"_clazz" : "TwkSegment",
			"brick" : "FRONT",
			"from" : 1573,
			"face" : "front",
			"tags" : [
				"P16"
			],
			"type" : "panel",
			"to" : 1518,
			"number" : 22051
		},
		{
			"uuid" : "f0d7feea-70e3-ab4e-be93-558ba61a0481",
			"name" : "22052",
			"_clazz" : "TwkSegment",
			"brick" : "FRONT",
			"from" : 1525,
			"face" : "front",
			"tags" : [
				"P16"
			],
			"type" : "panel",
			"to" : 1573,
			"number" : 22052
		},
		{
			"uuid" : "12e5849a-f5eb-f245-aec2-47e779f979d1",
			"name" : "22053",
			"_clazz" : "TwkSegment",
			"brick" : "LEFT",
			"from" : 1574,
			"face" : "left",
			"tags" : [
				"P16"
			],
			"type" : "panel",
			"to" : 1518,
			"number" : 22053
		},
		{
			"uuid" : "b23a4cad-a6a6-1647-8328-48c1658bde52",
			"name" : "22054",
			"_clazz" : "TwkSegment",
			"brick" : "LEFT",
			"from" : 1527,
			"face" : "left",
			"tags" : [
				"P16"
			],
			"type" : "panel",
			"to" : 1574,
			"number" : 22054
		},
		{
			"uuid" : "a0773a75-833e-c241-b3e3-f11b30873b2c",
			"name" : "22055",
			"_clazz" : "TwkSegment",
			"brick" : "LEFT",
			"from" : 1574,
			"face" : "left",
			"tags" : [
				"P16"
			],
			"type" : "panel",
			"to" : 1519,
			"number" : 22055
		},
		{
			"uuid" : "ea7ddc1d-db8b-e144-a51b-35b585252d29",
			"name" : "22056",
			"_clazz" : "TwkSegment",
			"brick" : "LEFT",
			"from" : 1526,
			"face" : "left",
			"tags" : [
				"P16"
			],
			"type" : "panel",
			"to" : 1574,
			"number" : 22056
		},
		{
			"uuid" : "675751b7-0f2d-1e45-8b9a-bca0a4474af8",
			"name" : "22057",
			"_clazz" : "TwkSegment",
			"brick" : "BACK",
			"from" : 1575,
			"face" : "back",
			"tags" : [
				"P16"
			],
			"type" : "panel",
			"to" : 1519,
			"number" : 22057
		},
		{
			"uuid" : "fd13e5d2-c09d-2e42-be37-f04230e8a5b1",
			"name" : "22058",
			"_clazz" : "TwkSegment",
			"brick" : "BACK",
			"from" : 1528,
			"face" : "back",
			"tags" : [
				"P16"
			],
			"type" : "panel",
			"to" : 1575,
			"number" : 22058
		},
		{
			"uuid" : "02b380cb-5e26-9543-8ca9-527c0e1420bc",
			"name" : "22059",
			"_clazz" : "TwkSegment",
			"brick" : "BACK",
			"from" : 1575,
			"face" : "back",
			"tags" : [
				"P16"
			],
			"type" : "panel",
			"to" : 1520,
			"number" : 22059
		},
		{
			"uuid" : "c705bec1-f826-6c44-943e-c92a6e73cb28",
			"name" : "22060",
			"_clazz" : "TwkSegment",
			"brick" : "BACK",
			"from" : 1527,
			"face" : "back",
			"tags" : [
				"P16"
			],
			"type" : "panel",
			"to" : 1575,
			"number" : 22060
		},
		{
			"uuid" : "2b5dc23a-57da-ab49-a362-ac8b23ce3169",
			"name" : "22061",
			"_clazz" : "TwkSegment",
			"brick" : "RIGHT",
			"from" : 1576,
			"face" : "right",
			"tags" : [
				"P16"
			],
			"type" : "panel",
			"to" : 1520,
			"number" : 22061
		},
		{
			"uuid" : "7a04daf6-30ac-834b-8e1b-6c9e66588467",
			"name" : "22062",
			"_clazz" : "TwkSegment",
			"brick" : "RIGHT",
			"from" : 1525,
			"face" : "right",
			"tags" : [
				"P16"
			],
			"type" : "panel",
			"to" : 1576,
			"number" : 22062
		},
		{
			"uuid" : "dd613b1f-1465-d444-a043-4629a0471e3b",
			"name" : "22063",
			"_clazz" : "TwkSegment",
			"brick" : "RIGHT",
			"from" : 1576,
			"face" : "right",
			"tags" : [
				"P16"
			],
			"type" : "panel",
			"to" : 1517,
			"number" : 22063
		},
		{
			"uuid" : "a28033da-0c31-f74c-b9bf-944dd62ee819",
			"name" : "22064",
			"_clazz" : "TwkSegment",
			"brick" : "RIGHT",
			"from" : 1528,
			"face" : "right",
			"tags" : [
				"P16"
			],
			"type" : "panel",
			"to" : 1576,
			"number" : 22064
		},
		{
			"uuid" : "1e8634b7-2cac-a749-a6b3-03c138786fff",
			"name" : "22065",
			"_clazz" : "TwkSegment",
			"brick" : "FRONT",
			"from" : 1577,
			"face" : "front",
			"tags" : [
				"P16"
			],
			"type" : "panel",
			"to" : 1525,
			"number" : 22065
		},
		{
			"uuid" : "430b7a35-aa2b-424d-beab-8987bba82139",
			"name" : "22066",
			"_clazz" : "TwkSegment",
			"brick" : "FRONT",
			"from" : 1534,
			"face" : "front",
			"tags" : [
				"P16"
			],
			"type" : "panel",
			"to" : 1577,
			"number" : 22066
		},
		{
			"uuid" : "d34b9a23-081f-9f4b-b9cb-189414e471b3",
			"name" : "22067",
			"_clazz" : "TwkSegment",
			"brick" : "FRONT",
			"from" : 1577,
			"face" : "front",
			"tags" : [
				"P16"
			],
			"type" : "panel",
			"to" : 1526,
			"number" : 22067
		},
		{
			"uuid" : "93be9676-ef5f-b64d-8347-1f11f8051888",
			"name" : "22068",
			"_clazz" : "TwkSegment",
			"brick" : "FRONT",
			"from" : 1533,
			"face" : "front",
			"tags" : [
				"P16"
			],
			"type" : "panel",
			"to" : 1577,
			"number" : 22068
		},
		{
			"uuid" : "b3434702-da44-cf4a-bb97-dd3771820115",
			"name" : "22069",
			"_clazz" : "TwkSegment",
			"brick" : "LEFT",
			"from" : 1578,
			"face" : "left",
			"tags" : [
				"P16"
			],
			"type" : "panel",
			"to" : 1526,
			"number" : 22069
		},
		{
			"uuid" : "d15b1d86-5d03-8948-b90b-4c3d9bb5863c",
			"name" : "22070",
			"_clazz" : "TwkSegment",
			"brick" : "LEFT",
			"from" : 1535,
			"face" : "left",
			"tags" : [
				"P16"
			],
			"type" : "panel",
			"to" : 1578,
			"number" : 22070
		},
		{
			"uuid" : "7d0a8cf1-1759-6347-b981-c731dea62e93",
			"name" : "22071",
			"_clazz" : "TwkSegment",
			"brick" : "LEFT",
			"from" : 1578,
			"face" : "left",
			"tags" : [
				"P16"
			],
			"type" : "panel",
			"to" : 1527,
			"number" : 22071
		},
		{
			"uuid" : "474d4f49-2759-5549-9cb1-e3867c444238",
			"name" : "22072",
			"_clazz" : "TwkSegment",
			"brick" : "LEFT",
			"from" : 1534,
			"face" : "left",
			"tags" : [
				"P16"
			],
			"type" : "panel",
			"to" : 1578,
			"number" : 22072
		},
		{
			"uuid" : "0d985c60-8eee-0a45-89a8-4907da527c1b",
			"name" : "22073",
			"_clazz" : "TwkSegment",
			"brick" : "BACK",
			"from" : 1579,
			"face" : "back",
			"tags" : [
				"P16"
			],
			"type" : "panel",
			"to" : 1527,
			"number" : 22073
		},
		{
			"uuid" : "a00c35d8-576e-204d-96e4-e2eacda57a91",
			"name" : "22074",
			"_clazz" : "TwkSegment",
			"brick" : "BACK",
			"from" : 1536,
			"face" : "back",
			"tags" : [
				"P16"
			],
			"type" : "panel",
			"to" : 1579,
			"number" : 22074
		},
		{
			"uuid" : "49f56d23-0fa1-b246-a7b4-a54342971b54",
			"name" : "22075",
			"_clazz" : "TwkSegment",
			"brick" : "BACK",
			"from" : 1579,
			"face" : "back",
			"tags" : [
				"P16"
			],
			"type" : "panel",
			"to" : 1528,
			"number" : 22075
		},
		{
			"uuid" : "cf3adba5-4dc7-184c-8100-fac1d4cb838f",
			"name" : "22076",
			"_clazz" : "TwkSegment",
			"brick" : "BACK",
			"from" : 1535,
			"face" : "back",
			"tags" : [
				"P16"
			],
			"type" : "panel",
			"to" : 1579,
			"number" : 22076
		},
		{
			"uuid" : "e9e13c0c-e108-d242-835a-fb330e6a2a1e",
			"name" : "22077",
			"_clazz" : "TwkSegment",
			"brick" : "RIGHT",
			"from" : 1580,
			"face" : "right",
			"tags" : [
				"P16"
			],
			"type" : "panel",
			"to" : 1528,
			"number" : 22077
		},
		{
			"uuid" : "b5f01dc8-9fc5-3d4d-b240-3a222b91852b",
			"name" : "22078",
			"_clazz" : "TwkSegment",
			"brick" : "RIGHT",
			"from" : 1533,
			"face" : "right",
			"tags" : [
				"P16"
			],
			"type" : "panel",
			"to" : 1580,
			"number" : 22078
		},
		{
			"uuid" : "7bf2b830-372c-8b44-94ab-c9906783daa3",
			"name" : "22079",
			"_clazz" : "TwkSegment",
			"brick" : "RIGHT",
			"from" : 1580,
			"face" : "right",
			"tags" : [
				"P16"
			],
			"type" : "panel",
			"to" : 1525,
			"number" : 22079
		},
		{
			"uuid" : "61fd85a3-fa33-7f44-8390-75038b69c983",
			"name" : "22080",
			"_clazz" : "TwkSegment",
			"brick" : "RIGHT",
			"from" : 1536,
			"face" : "right",
			"tags" : [
				"P16"
			],
			"type" : "panel",
			"to" : 1580,
			"number" : 22080
		},
		{
			"uuid" : "a3475ab3-76dc-174d-978a-81a3f6350a49",
			"name" : "22081",
			"_clazz" : "TwkSegment",
			"brick" : "FRONT",
			"from" : 1581,
			"face" : "front",
			"tags" : [
				"P16"
			],
			"type" : "panel",
			"to" : 1533,
			"number" : 22081
		},
		{
			"uuid" : "f5ebea0a-b3ab-7845-acd9-edc513e9f052",
			"name" : "22082",
			"_clazz" : "TwkSegment",
			"brick" : "FRONT",
			"from" : 1542,
			"face" : "front",
			"tags" : [
				"P16"
			],
			"type" : "panel",
			"to" : 1581,
			"number" : 22082
		},
		{
			"uuid" : "ec174b4a-bee6-3c4e-b4cc-676fcc35bc1a",
			"name" : "22083",
			"_clazz" : "TwkSegment",
			"brick" : "FRONT",
			"from" : 1581,
			"face" : "front",
			"tags" : [
				"P16"
			],
			"type" : "panel",
			"to" : 1534,
			"number" : 22083
		},
		{
			"uuid" : "8d6239e2-3678-f040-ba77-7cf6897611ea",
			"name" : "22084",
			"_clazz" : "TwkSegment",
			"brick" : "FRONT",
			"from" : 1541,
			"face" : "front",
			"tags" : [
				"P16"
			],
			"type" : "panel",
			"to" : 1581,
			"number" : 22084
		},
		{
			"uuid" : "8edf3de1-a644-a148-91b0-cede1cfcb1dc",
			"name" : "22085",
			"_clazz" : "TwkSegment",
			"brick" : "LEFT",
			"from" : 1582,
			"face" : "left",
			"tags" : [
				"P16"
			],
			"type" : "panel",
			"to" : 1534,
			"number" : 22085
		},
		{
			"uuid" : "2203f473-f77b-9246-97d5-41366eea2d3a",
			"name" : "22086",
			"_clazz" : "TwkSegment",
			"brick" : "LEFT",
			"from" : 1543,
			"face" : "left",
			"tags" : [
				"P16"
			],
			"type" : "panel",
			"to" : 1582,
			"number" : 22086
		},
		{
			"uuid" : "6091d92f-58d1-3d48-8da1-230e26fd822a",
			"name" : "22087",
			"_clazz" : "TwkSegment",
			"brick" : "LEFT",
			"from" : 1582,
			"face" : "left",
			"tags" : [
				"P16"
			],
			"type" : "panel",
			"to" : 1535,
			"number" : 22087
		},
		{
			"uuid" : "e5a992a6-869e-5944-a54e-dad3823f292f",
			"name" : "22088",
			"_clazz" : "TwkSegment",
			"brick" : "LEFT",
			"from" : 1542,
			"face" : "left",
			"tags" : [
				"P16"
			],
			"type" : "panel",
			"to" : 1582,
			"number" : 22088
		},
		{
			"uuid" : "455e92b6-cf76-5a4e-b5db-f28ff984365e",
			"name" : "22089",
			"_clazz" : "TwkSegment",
			"brick" : "BACK",
			"from" : 1583,
			"face" : "back",
			"tags" : [
				"P16"
			],
			"type" : "panel",
			"to" : 1535,
			"number" : 22089
		},
		{
			"uuid" : "9b96474a-2127-7c44-b43e-fd374ffa14f5",
			"name" : "22090",
			"_clazz" : "TwkSegment",
			"brick" : "BACK",
			"from" : 1544,
			"face" : "back",
			"tags" : [
				"P16"
			],
			"type" : "panel",
			"to" : 1583,
			"number" : 22090
		},
		{
			"uuid" : "8a773126-1ab6-f542-a453-5f57a57b63ac",
			"name" : "22091",
			"_clazz" : "TwkSegment",
			"brick" : "BACK",
			"from" : 1583,
			"face" : "back",
			"tags" : [
				"P16"
			],
			"type" : "panel",
			"to" : 1536,
			"number" : 22091
		},
		{
			"uuid" : "39feae8f-1929-e540-a53d-4b5e19f7689f",
			"name" : "22092",
			"_clazz" : "TwkSegment",
			"brick" : "BACK",
			"from" : 1543,
			"face" : "back",
			"tags" : [
				"P16"
			],
			"type" : "panel",
			"to" : 1583,
			"number" : 22092
		},
		{
			"uuid" : "61d4ada9-8287-324a-9f2a-cf4592898a05",
			"name" : "22093",
			"_clazz" : "TwkSegment",
			"brick" : "RIGHT",
			"from" : 1584,
			"face" : "right",
			"tags" : [
				"P16"
			],
			"type" : "panel",
			"to" : 1536,
			"number" : 22093
		},
		{
			"uuid" : "ffad0a50-df7a-7348-b1d5-800f82c3762b",
			"name" : "22094",
			"_clazz" : "TwkSegment",
			"brick" : "RIGHT",
			"from" : 1541,
			"face" : "right",
			"tags" : [
				"P16"
			],
			"type" : "panel",
			"to" : 1584,
			"number" : 22094
		},
		{
			"uuid" : "531617bd-19c3-814a-a56a-20188bc38d48",
			"name" : "22095",
			"_clazz" : "TwkSegment",
			"brick" : "RIGHT",
			"from" : 1584,
			"face" : "right",
			"tags" : [
				"P16"
			],
			"type" : "panel",
			"to" : 1533,
			"number" : 22095
		},
		{
			"uuid" : "2bd0abc4-a1bf-3a4e-ace3-232e2feef089",
			"name" : "22096",
			"_clazz" : "TwkSegment",
			"brick" : "RIGHT",
			"from" : 1544,
			"face" : "right",
			"tags" : [
				"P16"
			],
			"type" : "panel",
			"to" : 1584,
			"number" : 22096
		},
		{
			"uuid" : "c8757690-1e19-0445-9fe0-55178c3c03da",
			"name" : "22097",
			"_clazz" : "TwkSegment",
			"brick" : "FRONT",
			"from" : 1585,
			"face" : "front",
			"tags" : [
				"P16"
			],
			"type" : "panel",
			"to" : 1541,
			"number" : 22097
		},
		{
			"uuid" : "f99e112c-59d8-b340-908b-2c4a7130018d",
			"name" : "22098",
			"_clazz" : "TwkSegment",
			"brick" : "FRONT",
			"from" : 1550,
			"face" : "front",
			"tags" : [
				"P16"
			],
			"type" : "panel",
			"to" : 1585,
			"number" : 22098
		},
		{
			"uuid" : "ad5c0c0c-e6ac-1e45-8327-f60cd0177720",
			"name" : "22099",
			"_clazz" : "TwkSegment",
			"brick" : "FRONT",
			"from" : 1585,
			"face" : "front",
			"tags" : [
				"P16"
			],
			"type" : "panel",
			"to" : 1542,
			"number" : 22099
		},
		{
			"uuid" : "2c5483cc-400b-f647-a808-a177c09214db",
			"name" : "22100",
			"_clazz" : "TwkSegment",
			"brick" : "FRONT",
			"from" : 1549,
			"face" : "front",
			"tags" : [
				"P16"
			],
			"type" : "panel",
			"to" : 1585,
			"number" : 22100
		},
		{
			"uuid" : "52ec3b5b-a021-bd41-bf18-31b37cd7c8fd",
			"name" : "22101",
			"_clazz" : "TwkSegment",
			"brick" : "LEFT",
			"from" : 1586,
			"face" : "left",
			"tags" : [
				"P16"
			],
			"type" : "panel",
			"to" : 1542,
			"number" : 22101
		},
		{
			"uuid" : "25022c37-c3ea-094c-99f4-c9626dfd12e9",
			"name" : "22102",
			"_clazz" : "TwkSegment",
			"brick" : "LEFT",
			"from" : 1551,
			"face" : "left",
			"tags" : [
				"P16"
			],
			"type" : "panel",
			"to" : 1586,
			"number" : 22102
		},
		{
			"uuid" : "af1c5891-be81-f04f-9493-f9fbcd78de36",
			"name" : "22103",
			"_clazz" : "TwkSegment",
			"brick" : "LEFT",
			"from" : 1586,
			"face" : "left",
			"tags" : [
				"P16"
			],
			"type" : "panel",
			"to" : 1543,
			"number" : 22103
		},
		{
			"uuid" : "f4313531-58f9-a141-9275-fdfb4a6375a6",
			"name" : "22104",
			"_clazz" : "TwkSegment",
			"brick" : "LEFT",
			"from" : 1550,
			"face" : "left",
			"tags" : [
				"P16"
			],
			"type" : "panel",
			"to" : 1586,
			"number" : 22104
		},
		{
			"uuid" : "37b00665-d1e9-2443-8194-415e9c05352c",
			"name" : "22105",
			"_clazz" : "TwkSegment",
			"brick" : "BACK",
			"from" : 1587,
			"face" : "back",
			"tags" : [
				"P16"
			],
			"type" : "panel",
			"to" : 1543,
			"number" : 22105
		},
		{
			"uuid" : "779d6a0e-c0a7-3c43-a36b-7fd47e94dceb",
			"name" : "22106",
			"_clazz" : "TwkSegment",
			"brick" : "BACK",
			"from" : 1552,
			"face" : "back",
			"tags" : [
				"P16"
			],
			"type" : "panel",
			"to" : 1587,
			"number" : 22106
		},
		{
			"uuid" : "85b084f9-6b0c-7141-acbc-8b3bd44d1da7",
			"name" : "22107",
			"_clazz" : "TwkSegment",
			"brick" : "BACK",
			"from" : 1587,
			"face" : "back",
			"tags" : [
				"P16"
			],
			"type" : "panel",
			"to" : 1544,
			"number" : 22107
		},
		{
			"uuid" : "b4857ee0-8e3f-bf45-9346-3830e79e6588",
			"name" : "22108",
			"_clazz" : "TwkSegment",
			"brick" : "BACK",
			"from" : 1551,
			"face" : "back",
			"tags" : [
				"P16"
			],
			"type" : "panel",
			"to" : 1587,
			"number" : 22108
		},
		{
			"uuid" : "2c1cb498-5028-3d4b-b7d4-1223b7732d45",
			"name" : "22109",
			"_clazz" : "TwkSegment",
			"brick" : "RIGHT",
			"from" : 1588,
			"face" : "right",
			"tags" : [
				"P16"
			],
			"type" : "panel",
			"to" : 1544,
			"number" : 22109
		},
		{
			"uuid" : "7002e3ff-56f6-9543-9d5e-16ff11936dff",
			"name" : "22110",
			"_clazz" : "TwkSegment",
			"brick" : "RIGHT",
			"from" : 1549,
			"face" : "right",
			"tags" : [
				"P16"
			],
			"type" : "panel",
			"to" : 1588,
			"number" : 22110
		},
		{
			"uuid" : "092beb68-2466-ff48-be84-a1438c0230e6",
			"name" : "22111",
			"_clazz" : "TwkSegment",
			"brick" : "RIGHT",
			"from" : 1588,
			"face" : "right",
			"tags" : [
				"P16"
			],
			"type" : "panel",
			"to" : 1541,
			"number" : 22111
		},
		{
			"uuid" : "da098e4d-e0fe-ed4f-9290-b991b1164241",
			"name" : "22112",
			"_clazz" : "TwkSegment",
			"brick" : "RIGHT",
			"from" : 1552,
			"face" : "right",
			"tags" : [
				"P16"
			],
			"type" : "panel",
			"to" : 1588,
			"number" : 22112
		},
		{
			"uuid" : "6e54b773-8a1a-0c48-9118-011c1f77a10a",
			"name" : "22113",
			"_clazz" : "TwkSegment",
			"brick" : "FRONT",
			"from" : 1589,
			"face" : "front",
			"tags" : [
				"P16"
			],
			"type" : "panel",
			"to" : 1549,
			"number" : 22113
		},
		{
			"uuid" : "0da60584-5714-ad41-af1b-d4c7d546abed",
			"name" : "22114",
			"_clazz" : "TwkSegment",
			"brick" : "FRONT",
			"from" : 1558,
			"face" : "front",
			"tags" : [
				"P16"
			],
			"type" : "panel",
			"to" : 1589,
			"number" : 22114
		},
		{
			"uuid" : "a0b9a31e-dca7-9f4f-b482-56d5b09341a6",
			"name" : "22115",
			"_clazz" : "TwkSegment",
			"brick" : "FRONT",
			"from" : 1589,
			"face" : "front",
			"tags" : [
				"P16"
			],
			"type" : "panel",
			"to" : 1550,
			"number" : 22115
		},
		{
			"uuid" : "fb5cefd2-c049-ea41-a4cb-478af1e49ff1",
			"name" : "22116",
			"_clazz" : "TwkSegment",
			"brick" : "FRONT",
			"from" : 1557,
			"face" : "front",
			"tags" : [
				"P16"
			],
			"type" : "panel",
			"to" : 1589,
			"number" : 22116
		},
		{
			"uuid" : "a4da006e-7906-4949-b998-030b210b6cc6",
			"name" : "22117",
			"_clazz" : "TwkSegment",
			"brick" : "LEFT",
			"from" : 1590,
			"face" : "left",
			"tags" : [
				"P16"
			],
			"type" : "panel",
			"to" : 1550,
			"number" : 22117
		},
		{
			"uuid" : "71173512-2978-a244-b40e-47222fda6c76",
			"name" : "22118",
			"_clazz" : "TwkSegment",
			"brick" : "LEFT",
			"from" : 1559,
			"face" : "left",
			"tags" : [
				"P16"
			],
			"type" : "panel",
			"to" : 1590,
			"number" : 22118
		},
		{
			"uuid" : "6a24b4c5-ab66-7341-8481-1a80e71c160f",
			"name" : "22119",
			"_clazz" : "TwkSegment",
			"brick" : "LEFT",
			"from" : 1590,
			"face" : "left",
			"tags" : [
				"P16"
			],
			"type" : "panel",
			"to" : 1551,
			"number" : 22119
		},
		{
			"uuid" : "2e898c66-5a6a-9a45-8487-27874ced7c37",
			"name" : "22120",
			"_clazz" : "TwkSegment",
			"brick" : "LEFT",
			"from" : 1558,
			"face" : "left",
			"tags" : [
				"P16"
			],
			"type" : "panel",
			"to" : 1590,
			"number" : 22120
		},
		{
			"uuid" : "f9e449d2-dbc7-a147-adcb-744795132522",
			"name" : "22121",
			"_clazz" : "TwkSegment",
			"brick" : "BACK",
			"from" : 1591,
			"face" : "back",
			"tags" : [
				"P16"
			],
			"type" : "panel",
			"to" : 1551,
			"number" : 22121
		},
		{
			"uuid" : "2f55ec3a-b295-834f-be23-6c86bc03d185",
			"name" : "22122",
			"_clazz" : "TwkSegment",
			"brick" : "BACK",
			"from" : 1560,
			"face" : "back",
			"tags" : [
				"P16"
			],
			"type" : "panel",
			"to" : 1591,
			"number" : 22122
		},
		{
			"uuid" : "b5dcb978-4477-8a49-8047-3e42c21b44bc",
			"name" : "22123",
			"_clazz" : "TwkSegment",
			"brick" : "BACK",
			"from" : 1591,
			"face" : "back",
			"tags" : [
				"P16"
			],
			"type" : "panel",
			"to" : 1552,
			"number" : 22123
		},
		{
			"uuid" : "ce79f2e7-bd2d-774a-abcd-dbac55e027c4",
			"name" : "22124",
			"_clazz" : "TwkSegment",
			"brick" : "BACK",
			"from" : 1559,
			"face" : "back",
			"tags" : [
				"P16"
			],
			"type" : "panel",
			"to" : 1591,
			"number" : 22124
		},
		{
			"uuid" : "a875986a-6c19-4c4d-8911-f7b1bdd45ff6",
			"name" : "22125",
			"_clazz" : "TwkSegment",
			"brick" : "RIGHT",
			"from" : 1592,
			"face" : "right",
			"tags" : [
				"P16"
			],
			"type" : "panel",
			"to" : 1552,
			"number" : 22125
		},
		{
			"uuid" : "35f25806-fd28-5e4a-a7f8-28ab8a965c50",
			"name" : "22126",
			"_clazz" : "TwkSegment",
			"brick" : "RIGHT",
			"from" : 1557,
			"face" : "right",
			"tags" : [
				"P16"
			],
			"type" : "panel",
			"to" : 1592,
			"number" : 22126
		},
		{
			"uuid" : "70b821a7-1982-fe49-b8b1-be0e7b404391",
			"name" : "22127",
			"_clazz" : "TwkSegment",
			"brick" : "RIGHT",
			"from" : 1592,
			"face" : "right",
			"tags" : [
				"P16"
			],
			"type" : "panel",
			"to" : 1549,
			"number" : 22127
		},
		{
			"uuid" : "ffcaa2d2-3f7d-8641-a529-18bc40e02300",
			"name" : "22128",
			"_clazz" : "TwkSegment",
			"brick" : "RIGHT",
			"from" : 1560,
			"face" : "right",
			"tags" : [
				"P16"
			],
			"type" : "panel",
			"to" : 1592,
			"number" : 22128
		},
		{
			"number" : 14001,
			"tags" : [
				"P17"
			],
			"type" : "slope",
			"to" : 1601,
			"from" : 1600,
			"brick" : "P17",
			"name" : "14001",
			"uuid" : "4fe2b347-844c-c040-afed-ff6bda530a3a",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 14002,
			"tags" : [
				"P17"
			],
			"type" : "slope",
			"to" : 1602,
			"from" : 1600,
			"brick" : "P17",
			"name" : "14002",
			"uuid" : "df041a8e-fb42-6345-ba40-3f0ad4952144",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 14003,
			"tags" : [
				"P17"
			],
			"type" : "slope",
			"to" : 1603,
			"from" : 1600,
			"brick" : "P17",
			"name" : "14003",
			"uuid" : "1da7013c-5b91-0341-a715-2fc52c573a7b",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 14004,
			"tags" : [
				"P17"
			],
			"type" : "slope",
			"to" : 1604,
			"from" : 1600,
			"brick" : "P17",
			"name" : "14004",
			"uuid" : "5c45d1a3-b468-0241-b1a3-8b2f5a1b72e9",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 14005,
			"tags" : [
				"P17"
			],
			"type" : "slope",
			"to" : 1605,
			"from" : 1601,
			"brick" : "P17",
			"name" : "14005",
			"uuid" : "ab4ef6a8-0015-4b4d-866c-546efe867253",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 14006,
			"tags" : [
				"P17"
			],
			"type" : "slope",
			"to" : 1606,
			"from" : 1602,
			"brick" : "P17",
			"name" : "14006",
			"uuid" : "70c58bc1-95bf-514c-920d-086f357ffed5",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 14007,
			"tags" : [
				"P17"
			],
			"type" : "slope",
			"to" : 1607,
			"from" : 1603,
			"brick" : "P17",
			"name" : "14007",
			"uuid" : "adb2039d-228c-6042-98fc-db1ab6921b54",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 14008,
			"tags" : [
				"P17"
			],
			"type" : "slope",
			"to" : 1608,
			"from" : 1604,
			"brick" : "P17",
			"name" : "14008",
			"uuid" : "834ea9de-d0a9-2d45-a932-a8646e5fe256",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 14009,
			"tags" : [
				"P17"
			],
			"type" : "slope",
			"to" : 1609,
			"from" : 1605,
			"brick" : "P17",
			"name" : "14009",
			"uuid" : "052f348d-0afb-b64c-ba25-34c9596e3857",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 14010,
			"tags" : [
				"P17"
			],
			"type" : "slope",
			"to" : 1610,
			"from" : 1606,
			"brick" : "P17",
			"name" : "14010",
			"uuid" : "adf442cf-3e0a-c545-8749-481a305126df",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 14011,
			"tags" : [
				"P17"
			],
			"type" : "slope",
			"to" : 1611,
			"from" : 1607,
			"brick" : "P17",
			"name" : "14011",
			"uuid" : "6602ac19-e8f6-7e4e-b03f-a9f8d62abe43",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 14012,
			"tags" : [
				"P17"
			],
			"type" : "slope",
			"to" : 1612,
			"from" : 1608,
			"brick" : "P17",
			"name" : "14012",
			"uuid" : "811880c3-12fd-3a46-8e1e-ab49012fdea2",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 14013,
			"tags" : [
				"P17"
			],
			"type" : "slope",
			"to" : 1613,
			"from" : 1609,
			"brick" : "P17",
			"name" : "14013",
			"uuid" : "9588c7df-5426-df48-8525-09e16908f7c9",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 14014,
			"tags" : [
				"P17"
			],
			"type" : "slope",
			"to" : 1614,
			"from" : 1610,
			"brick" : "P17",
			"name" : "14014",
			"uuid" : "80838571-f598-3345-aa51-f81d4f39ddec",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 14015,
			"tags" : [
				"P17"
			],
			"type" : "slope",
			"to" : 1615,
			"from" : 1611,
			"brick" : "P17",
			"name" : "14015",
			"uuid" : "d1080b3c-9a4b-3147-9851-4c00bab51cbf",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 14016,
			"tags" : [
				"P17"
			],
			"type" : "slope",
			"to" : 1616,
			"from" : 1612,
			"brick" : "P17",
			"name" : "14016",
			"uuid" : "078651dd-22cd-404b-acb3-5c4732f8ecc7",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 14017,
			"tags" : [
				"P17"
			],
			"type" : "slope",
			"to" : 1617,
			"from" : 1613,
			"brick" : "P17",
			"name" : "14017",
			"uuid" : "f8de8105-932d-5440-88b5-3d313d2b41fa",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 14018,
			"tags" : [
				"P17"
			],
			"type" : "slope",
			"to" : 1618,
			"from" : 1614,
			"brick" : "P17",
			"name" : "14018",
			"uuid" : "cb8494d7-9069-c84c-bd43-7599bdbc7978",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 14019,
			"tags" : [
				"P17"
			],
			"type" : "slope",
			"to" : 1619,
			"from" : 1615,
			"brick" : "P17",
			"name" : "14019",
			"uuid" : "8b3b9fa3-b4ab-4e42-90bb-ab9f343d3f4b",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 14020,
			"tags" : [
				"P17"
			],
			"type" : "slope",
			"to" : 1620,
			"from" : 1616,
			"brick" : "P17",
			"name" : "14020",
			"uuid" : "d515818b-1c44-dc45-8956-1762b66f2a37",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 14021,
			"tags" : [
				"P17"
			],
			"type" : "slope",
			"to" : 1621,
			"from" : 1617,
			"brick" : "P17",
			"name" : "14021",
			"uuid" : "6cb66e3e-1f9c-3f4a-bd36-375282321a2b",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 14022,
			"tags" : [
				"P17"
			],
			"type" : "slope",
			"to" : 1622,
			"from" : 1618,
			"brick" : "P17",
			"name" : "14022",
			"uuid" : "f6532144-a99e-0a4b-97b3-a3cdb42bc70a",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 14023,
			"tags" : [
				"P17"
			],
			"type" : "slope",
			"to" : 1623,
			"from" : 1619,
			"brick" : "P17",
			"name" : "14023",
			"uuid" : "eff6f278-3933-1546-aa22-b96e8cd94964",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 14024,
			"tags" : [
				"P17"
			],
			"type" : "slope",
			"to" : 1624,
			"from" : 1620,
			"brick" : "P17",
			"name" : "14024",
			"uuid" : "69e6e63e-242a-e341-ab06-7e9ab2afbcbc",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 14025,
			"tags" : [
				"P17"
			],
			"type" : "slope",
			"to" : 1625,
			"from" : 1621,
			"brick" : "P17",
			"name" : "14025",
			"uuid" : "bf3cb246-5054-9442-a020-86fb1c757a1a",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 14026,
			"tags" : [
				"P17"
			],
			"type" : "slope",
			"to" : 1626,
			"from" : 1622,
			"brick" : "P17",
			"name" : "14026",
			"uuid" : "20a61b7d-d32f-7444-80f7-1a5cff59b061",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 14027,
			"tags" : [
				"P17"
			],
			"type" : "slope",
			"to" : 1627,
			"from" : 1623,
			"brick" : "P17",
			"name" : "14027",
			"uuid" : "c225182e-0e5e-2645-a876-c38719c534d1",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 14028,
			"tags" : [
				"P17"
			],
			"type" : "slope",
			"to" : 1628,
			"from" : 1624,
			"brick" : "P17",
			"name" : "14028",
			"uuid" : "97f35a71-e44a-6345-aace-e84fec38b90e",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 14029,
			"tags" : [
				"P17"
			],
			"type" : "slope",
			"to" : 1629,
			"from" : 1625,
			"brick" : "P17",
			"name" : "14029",
			"uuid" : "43bb7c8f-0514-a04e-89bb-bfd84a502146",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 14030,
			"tags" : [
				"P17"
			],
			"type" : "slope",
			"to" : 1630,
			"from" : 1626,
			"brick" : "P17",
			"name" : "14030",
			"uuid" : "eb468ac9-63d3-8b40-8031-d1023156ca09",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 14031,
			"tags" : [
				"P17"
			],
			"type" : "slope",
			"to" : 1631,
			"from" : 1627,
			"brick" : "P17",
			"name" : "14031",
			"uuid" : "e7ea9cd9-6096-7e4b-bcac-b39413d2707d",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 14032,
			"tags" : [
				"P17"
			],
			"type" : "slope",
			"to" : 1632,
			"from" : 1628,
			"brick" : "P17",
			"name" : "14032",
			"uuid" : "95147c22-e93c-7048-b4c6-aa3a69a3d699",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 14033,
			"tags" : [
				"P17"
			],
			"type" : "slope",
			"to" : 1633,
			"from" : 1629,
			"brick" : "P17",
			"name" : "14033",
			"uuid" : "0ae4b49b-df42-504f-85d2-75db17439d1f",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 14034,
			"tags" : [
				"P17"
			],
			"type" : "slope",
			"to" : 1634,
			"from" : 1630,
			"brick" : "P17",
			"name" : "14034",
			"uuid" : "abae6447-788f-df43-be08-b9fb7680716e",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 14035,
			"tags" : [
				"P17"
			],
			"type" : "slope",
			"to" : 1635,
			"from" : 1631,
			"brick" : "P17",
			"name" : "14035",
			"uuid" : "11881e2d-f658-034c-afd2-d7ac4446ba55",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 14036,
			"tags" : [
				"P17"
			],
			"type" : "slope",
			"to" : 1636,
			"from" : 1632,
			"brick" : "P17",
			"name" : "14036",
			"uuid" : "5a36884d-8ed4-7548-b6be-bd05a28402a6",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 14037,
			"tags" : [
				"P17"
			],
			"type" : "slope",
			"to" : 1637,
			"from" : 1633,
			"brick" : "P17",
			"name" : "14037",
			"uuid" : "7ab03c50-da63-9f4c-8701-fb3dd753c580",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 14038,
			"tags" : [
				"P17"
			],
			"type" : "slope",
			"to" : 1638,
			"from" : 1634,
			"brick" : "P17",
			"name" : "14038",
			"uuid" : "e701ca50-907d-6c4e-8ca2-6bfa105ada36",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 14039,
			"tags" : [
				"P17"
			],
			"type" : "slope",
			"to" : 1639,
			"from" : 1635,
			"brick" : "P17",
			"name" : "14039",
			"uuid" : "50c642d9-57b6-d542-b7ec-ad990e2570a1",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 14040,
			"tags" : [
				"P17"
			],
			"type" : "slope",
			"to" : 1640,
			"from" : 1636,
			"brick" : "P17",
			"name" : "14040",
			"uuid" : "2b1c8b71-9bce-2944-a2dd-35a66905f2a6",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 14041,
			"tags" : [
				"P17"
			],
			"type" : "slope",
			"to" : 1641,
			"from" : 1637,
			"brick" : "P17",
			"name" : "14041",
			"uuid" : "6293b785-5345-9942-91c6-3560a5fdd065",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 14042,
			"tags" : [
				"P17"
			],
			"type" : "slope",
			"to" : 1642,
			"from" : 1638,
			"brick" : "P17",
			"name" : "14042",
			"uuid" : "5f43f860-e12a-7c41-b80e-79e814a0172d",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 14043,
			"tags" : [
				"P17"
			],
			"type" : "slope",
			"to" : 1643,
			"from" : 1639,
			"brick" : "P17",
			"name" : "14043",
			"uuid" : "855b096e-c487-fd46-bc6f-7d8115931db2",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 14044,
			"tags" : [
				"P17"
			],
			"type" : "slope",
			"to" : 1644,
			"from" : 1640,
			"brick" : "P17",
			"name" : "14044",
			"uuid" : "59137cc0-a283-d042-b783-c895022dafef",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 14045,
			"tags" : [
				"P17"
			],
			"type" : "slope",
			"to" : 1645,
			"from" : 1641,
			"brick" : "P17",
			"name" : "14045",
			"uuid" : "5321de05-edbc-af4b-ab6c-405215210fa8",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 14046,
			"tags" : [
				"P17"
			],
			"type" : "slope",
			"to" : 1646,
			"from" : 1642,
			"brick" : "P17",
			"name" : "14046",
			"uuid" : "7899b0e6-7b23-4842-8ac9-9bb766671064",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 14047,
			"tags" : [
				"P17"
			],
			"type" : "slope",
			"to" : 1647,
			"from" : 1643,
			"brick" : "P17",
			"name" : "14047",
			"uuid" : "111120a7-ed44-3548-8662-3b02cd2f56b7",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 14048,
			"tags" : [
				"P17"
			],
			"type" : "slope",
			"to" : 1648,
			"from" : 1644,
			"brick" : "P17",
			"name" : "14048",
			"uuid" : "05f9f306-d45b-a740-8f71-6c2cd2738404",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 14049,
			"tags" : [
				"P17"
			],
			"type" : "slope",
			"to" : 1649,
			"from" : 1645,
			"brick" : "P17",
			"name" : "14049",
			"uuid" : "83f435aa-c357-834b-94c1-147340e35b61",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 14050,
			"tags" : [
				"P17"
			],
			"type" : "slope",
			"to" : 1650,
			"from" : 1646,
			"brick" : "P17",
			"name" : "14050",
			"uuid" : "ecdd3d4d-255c-694b-8f7a-1e10e101dd6c",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 14051,
			"tags" : [
				"P17"
			],
			"type" : "slope",
			"to" : 1651,
			"from" : 1647,
			"brick" : "P17",
			"name" : "14051",
			"uuid" : "e69cea49-3515-3142-a125-641c70565f2c",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 14052,
			"tags" : [
				"P17"
			],
			"type" : "slope",
			"to" : 1652,
			"from" : 1648,
			"brick" : "P17",
			"name" : "14052",
			"uuid" : "50312e03-c7d2-4f44-a6f0-54266ae4ea72",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 14053,
			"tags" : [
				"P17"
			],
			"type" : "slope",
			"to" : 1653,
			"from" : 1649,
			"brick" : "P17",
			"name" : "14053",
			"uuid" : "a2efb1f1-3e34-4c4d-a81e-644d5f3ab46a",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 14054,
			"tags" : [
				"P17"
			],
			"type" : "slope",
			"to" : 1654,
			"from" : 1650,
			"brick" : "P17",
			"name" : "14054",
			"uuid" : "f43dbdbb-8d91-7d4e-b066-0530a71f9efb",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 14055,
			"tags" : [
				"P17"
			],
			"type" : "slope",
			"to" : 1655,
			"from" : 1651,
			"brick" : "P17",
			"name" : "14055",
			"uuid" : "4ec99792-53a9-be40-b020-f5d657111fa8",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 14056,
			"tags" : [
				"P17"
			],
			"type" : "slope",
			"to" : 1656,
			"from" : 1652,
			"brick" : "P17",
			"name" : "14056",
			"uuid" : "006ff1eb-d9c1-7d45-a145-8ecff923fbc8",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 14057,
			"tags" : [
				"P17"
			],
			"type" : "slope",
			"to" : 1657,
			"from" : 1653,
			"brick" : "P17",
			"name" : "14057",
			"uuid" : "da6c3a39-0685-b046-9b6f-a0d2d3d3fe0a",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 14058,
			"tags" : [
				"P17"
			],
			"type" : "slope",
			"to" : 1658,
			"from" : 1654,
			"brick" : "P17",
			"name" : "14058",
			"uuid" : "3a2fad5d-5290-614f-b409-8cbd97b97c98",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 14059,
			"tags" : [
				"P17"
			],
			"type" : "slope",
			"to" : 1659,
			"from" : 1655,
			"brick" : "P17",
			"name" : "14059",
			"uuid" : "ea2f105f-a3c4-374b-89f1-66f8a2a2d966",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 14060,
			"tags" : [
				"P17"
			],
			"type" : "slope",
			"to" : 1660,
			"from" : 1656,
			"brick" : "P17",
			"name" : "14060",
			"uuid" : "375771e1-dd1e-e44c-a1db-449bf1ff81cc",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 14061,
			"tags" : [
				"P17"
			],
			"type" : "slope",
			"to" : 1661,
			"from" : 1657,
			"brick" : "P17",
			"name" : "14061",
			"uuid" : "6e7de2b9-16ca-c04b-a2cf-fc2c8b460448",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 14062,
			"tags" : [
				"P17"
			],
			"type" : "slope",
			"to" : 1662,
			"from" : 1658,
			"brick" : "P17",
			"name" : "14062",
			"uuid" : "261a68ac-91cb-104f-a4f8-978c02128daf",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 14063,
			"tags" : [
				"P17"
			],
			"type" : "slope",
			"to" : 1663,
			"from" : 1659,
			"brick" : "P17",
			"name" : "14063",
			"uuid" : "045cfef8-86d8-584d-8e5d-f37df1b89a18",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 14064,
			"tags" : [
				"P17"
			],
			"type" : "slope",
			"to" : 1664,
			"from" : 1660,
			"brick" : "P17",
			"name" : "14064",
			"uuid" : "72b0fc86-6355-4a4b-85bd-d7d26c3cb6c5",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 14065,
			"tags" : [
				"P17"
			],
			"type" : "slope",
			"to" : 1665,
			"from" : 1661,
			"brick" : "P17",
			"name" : "14065",
			"uuid" : "53dedb22-34a0-4140-ae17-faa4362ba516",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 14066,
			"tags" : [
				"P17"
			],
			"type" : "slope",
			"to" : 1666,
			"from" : 1662,
			"brick" : "P17",
			"name" : "14066",
			"uuid" : "28a417ba-a811-fa4f-b43c-a90ba4aca04a",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 14067,
			"tags" : [
				"P17"
			],
			"type" : "slope",
			"to" : 1667,
			"from" : 1663,
			"brick" : "P17",
			"name" : "14067",
			"uuid" : "87eee9f4-7986-0c46-b207-bc8123beb3ec",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 14068,
			"tags" : [
				"P17"
			],
			"type" : "slope",
			"to" : 1668,
			"from" : 1664,
			"brick" : "P17",
			"name" : "14068",
			"uuid" : "ee57a7f5-9531-7943-91ea-7aa7d36a88e2",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 14069,
			"tags" : [
				"P17"
			],
			"type" : "slope",
			"to" : 1669,
			"from" : 1665,
			"brick" : "P17",
			"name" : "14069",
			"uuid" : "bdbec2ad-3bfa-d742-82e0-b390d70fe530",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 14070,
			"tags" : [
				"P17"
			],
			"type" : "slope",
			"to" : 1670,
			"from" : 1666,
			"brick" : "P17",
			"name" : "14070",
			"uuid" : "6c1173b9-d470-ef45-9845-f442ff515213",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 14071,
			"tags" : [
				"P17"
			],
			"type" : "slope",
			"to" : 1671,
			"from" : 1667,
			"brick" : "P17",
			"name" : "14071",
			"uuid" : "1d02a337-3d6c-694d-9114-3af1d90b5c4d",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 14072,
			"tags" : [
				"P17"
			],
			"type" : "slope",
			"to" : 1672,
			"from" : 1668,
			"brick" : "P17",
			"name" : "14072",
			"uuid" : "bfb614bc-6d35-c442-9880-9115ac7414c8",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 14073,
			"tags" : [
				"P17"
			],
			"type" : "slope",
			"to" : 1673,
			"from" : 1669,
			"brick" : "P17",
			"name" : "14073",
			"uuid" : "86ef8739-2918-ca49-a3ba-5b536b2630a1",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 14074,
			"tags" : [
				"P17"
			],
			"type" : "slope",
			"to" : 1674,
			"from" : 1670,
			"brick" : "P17",
			"name" : "14074",
			"uuid" : "715b844f-62d9-6345-bf0f-3495f2415ff5",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 14075,
			"tags" : [
				"P17"
			],
			"type" : "slope",
			"to" : 1675,
			"from" : 1671,
			"brick" : "P17",
			"name" : "14075",
			"uuid" : "6a81907a-f58d-2f43-995e-16cda5a0694f",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 14076,
			"tags" : [
				"P17"
			],
			"type" : "slope",
			"to" : 1676,
			"from" : 1672,
			"brick" : "P17",
			"name" : "14076",
			"uuid" : "d1b8d8ac-e6e8-984e-90cf-03558f542579",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 32001,
			"tags" : [
				"P17"
			],
			"type" : "sectionRound",
			"to" : 1602,
			"from" : 1601,
			"brick" : "P17",
			"name" : "32001",
			"uuid" : "032905d4-6ed1-394e-bf64-deb20e522dab",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 32002,
			"tags" : [
				"P17"
			],
			"type" : "sectionRound",
			"to" : 1603,
			"from" : 1602,
			"brick" : "P17",
			"name" : "32002",
			"uuid" : "ea80ea61-df56-4f41-9648-7d427f7beb20",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 32003,
			"tags" : [
				"P17"
			],
			"type" : "sectionRound",
			"to" : 1604,
			"from" : 1603,
			"brick" : "P17",
			"name" : "32003",
			"uuid" : "110d1e7c-1c88-5f40-bb88-36ebea4bb7a8",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 32004,
			"tags" : [
				"P17"
			],
			"type" : "sectionRound",
			"to" : 1601,
			"from" : 1604,
			"brick" : "P17",
			"name" : "32004",
			"uuid" : "a181bf8f-811e-f245-94ce-29738f459dd4",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 32005,
			"tags" : [
				"P17"
			],
			"type" : "sectionRound",
			"to" : 1606,
			"from" : 1605,
			"brick" : "P17",
			"name" : "32005",
			"uuid" : "4c7a8a56-982c-7a47-90fc-6cd2513ae3b6",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 32006,
			"tags" : [
				"P17"
			],
			"type" : "sectionRound",
			"to" : 1607,
			"from" : 1606,
			"brick" : "P17",
			"name" : "32006",
			"uuid" : "38c55dcd-f322-8e45-8760-5e34d3f99efb",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 32007,
			"tags" : [
				"P17"
			],
			"type" : "sectionRound",
			"to" : 1608,
			"from" : 1607,
			"brick" : "P17",
			"name" : "32007",
			"uuid" : "30936dd2-35ae-e24a-9e1f-ddf93e28c342",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 32008,
			"tags" : [
				"P17"
			],
			"type" : "sectionRound",
			"to" : 1605,
			"from" : 1608,
			"brick" : "P17",
			"name" : "32008",
			"uuid" : "c81cd447-59d1-2848-8e45-55f7c17be3c8",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 32009,
			"tags" : [
				"P17"
			],
			"type" : "sectionRound",
			"to" : 1610,
			"from" : 1609,
			"brick" : "P17",
			"name" : "32009",
			"uuid" : "260fdcf5-271e-0844-a2f1-96c967a1eff7",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 32010,
			"tags" : [
				"P17"
			],
			"type" : "sectionRound",
			"to" : 1611,
			"from" : 1610,
			"brick" : "P17",
			"name" : "32010",
			"uuid" : "b83e0d75-d444-b04d-99d3-99bea5f84851",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 32011,
			"tags" : [
				"P17"
			],
			"type" : "sectionRound",
			"to" : 1612,
			"from" : 1611,
			"brick" : "P17",
			"name" : "32011",
			"uuid" : "98abeff5-96a0-664f-ad4e-10b6bde59892",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 32012,
			"tags" : [
				"P17"
			],
			"type" : "sectionRound",
			"to" : 1609,
			"from" : 1612,
			"brick" : "P17",
			"name" : "32012",
			"uuid" : "1aa5a4d7-6341-e64d-9e2f-12f6d39bdf47",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 32013,
			"tags" : [
				"P17"
			],
			"type" : "sectionRound",
			"to" : 1614,
			"from" : 1613,
			"brick" : "P17",
			"name" : "32013",
			"uuid" : "080824ed-2c2d-0e4b-ba2e-8449e6837f8a",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 32014,
			"tags" : [
				"P17"
			],
			"type" : "sectionRound",
			"to" : 1615,
			"from" : 1614,
			"brick" : "P17",
			"name" : "32014",
			"uuid" : "fafbdf07-0d57-214b-81d7-f63602680752",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 32015,
			"tags" : [
				"P17"
			],
			"type" : "sectionRound",
			"to" : 1616,
			"from" : 1615,
			"brick" : "P17",
			"name" : "32015",
			"uuid" : "4c780d32-8d77-964b-98ca-45fe28aa81d6",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 32016,
			"tags" : [
				"P17"
			],
			"type" : "sectionRound",
			"to" : 1613,
			"from" : 1616,
			"brick" : "P17",
			"name" : "32016",
			"uuid" : "bc3fe118-e51e-4948-b919-39a8de5f5da2",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 32017,
			"tags" : [
				"P17"
			],
			"type" : "sectionRound",
			"to" : 1618,
			"from" : 1617,
			"brick" : "P17",
			"name" : "32017",
			"uuid" : "a2175904-3aa9-a842-98c3-eda8adbbd5c2",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 32018,
			"tags" : [
				"P17"
			],
			"type" : "sectionRound",
			"to" : 1619,
			"from" : 1618,
			"brick" : "P17",
			"name" : "32018",
			"uuid" : "ddd1f18b-2813-f44b-b5ac-004acfbab98d",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 32019,
			"tags" : [
				"P17"
			],
			"type" : "sectionRound",
			"to" : 1620,
			"from" : 1619,
			"brick" : "P17",
			"name" : "32019",
			"uuid" : "74e502ab-bee2-f449-a9a3-0196ff5c46f9",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 32020,
			"tags" : [
				"P17"
			],
			"type" : "sectionRound",
			"to" : 1617,
			"from" : 1620,
			"brick" : "P17",
			"name" : "32020",
			"uuid" : "8239f274-07b0-864d-9512-c7256c54d900",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 32021,
			"tags" : [
				"P17"
			],
			"type" : "sectionRound",
			"to" : 1622,
			"from" : 1621,
			"brick" : "P17",
			"name" : "32021",
			"uuid" : "8a4d6303-bb8f-4743-b487-3cb0d25acb4c",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 32022,
			"tags" : [
				"P17"
			],
			"type" : "sectionRound",
			"to" : 1623,
			"from" : 1622,
			"brick" : "P17",
			"name" : "32022",
			"uuid" : "84c15737-77ae-9f4f-8643-dae3b34a5505",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 32023,
			"tags" : [
				"P17"
			],
			"type" : "sectionRound",
			"to" : 1624,
			"from" : 1623,
			"brick" : "P17",
			"name" : "32023",
			"uuid" : "c6c2a407-334a-9844-94f4-b767e6620e39",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 32024,
			"tags" : [
				"P17"
			],
			"type" : "sectionRound",
			"to" : 1621,
			"from" : 1624,
			"brick" : "P17",
			"name" : "32024",
			"uuid" : "c5e1171c-4aa7-ae4a-bfeb-7d84bc1ebbfe",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 32025,
			"tags" : [
				"P17"
			],
			"type" : "sectionRound",
			"to" : 1685,
			"from" : 1629,
			"brick" : "P17",
			"name" : "32025",
			"uuid" : "4963833d-a326-cc4a-81ec-47b879a9ea20",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 32026,
			"tags" : [
				"P17"
			],
			"type" : "sectionRound",
			"to" : 1630,
			"from" : 1685,
			"brick" : "P17",
			"name" : "32026",
			"uuid" : "687313d9-df62-9d4b-986b-0760a3216fdd",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 32027,
			"tags" : [
				"P17"
			],
			"type" : "sectionRound",
			"to" : 1686,
			"from" : 1630,
			"brick" : "P17",
			"name" : "32027",
			"uuid" : "f68a158f-3833-124f-a890-f302db314146",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 32028,
			"tags" : [
				"P17"
			],
			"type" : "sectionRound",
			"to" : 1631,
			"from" : 1686,
			"brick" : "P17",
			"name" : "32028",
			"uuid" : "13214593-43d1-e748-97a9-9cd77c0954b3",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 32029,
			"tags" : [
				"P17"
			],
			"type" : "sectionRound",
			"to" : 1687,
			"from" : 1631,
			"brick" : "P17",
			"name" : "32029",
			"uuid" : "49a11ef5-f788-c24e-a214-65d7295cc9e8",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 32030,
			"tags" : [
				"P17"
			],
			"type" : "sectionRound",
			"to" : 1632,
			"from" : 1687,
			"brick" : "P17",
			"name" : "32030",
			"uuid" : "1a255128-1c60-1744-acd3-548bbb80f606",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 32031,
			"tags" : [
				"P17"
			],
			"type" : "sectionRound",
			"to" : 1688,
			"from" : 1632,
			"brick" : "P17",
			"name" : "32031",
			"uuid" : "a99844d9-8399-8348-bc90-289614b1fd47",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 32032,
			"tags" : [
				"P17"
			],
			"type" : "sectionRound",
			"to" : 1629,
			"from" : 1688,
			"brick" : "P17",
			"name" : "32032",
			"uuid" : "f3091ef1-dc9a-ed41-b7eb-0f6f7527f467",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 32033,
			"tags" : [
				"P17"
			],
			"type" : "sectionRound",
			"to" : 1689,
			"from" : 1637,
			"brick" : "P17",
			"name" : "32033",
			"uuid" : "bc9b5367-55f7-0842-9601-6730e0e00cc0",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 32034,
			"tags" : [
				"P17"
			],
			"type" : "sectionRound",
			"to" : 1638,
			"from" : 1689,
			"brick" : "P17",
			"name" : "32034",
			"uuid" : "d4ecc189-2dcb-b64d-923e-fa7304cacf33",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 32035,
			"tags" : [
				"P17"
			],
			"type" : "sectionRound",
			"to" : 1690,
			"from" : 1638,
			"brick" : "P17",
			"name" : "32035",
			"uuid" : "2ebb0461-b867-7048-8ed8-c23cefcf4a2d",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 32036,
			"tags" : [
				"P17"
			],
			"type" : "sectionRound",
			"to" : 1639,
			"from" : 1690,
			"brick" : "P17",
			"name" : "32036",
			"uuid" : "5f295eb2-b87d-9341-b34a-2f139f4420c7",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 32037,
			"tags" : [
				"P17"
			],
			"type" : "sectionRound",
			"to" : 1691,
			"from" : 1639,
			"brick" : "P17",
			"name" : "32037",
			"uuid" : "61e09513-bb7f-0744-81f1-41393db10699",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 32038,
			"tags" : [
				"P17"
			],
			"type" : "sectionRound",
			"to" : 1640,
			"from" : 1691,
			"brick" : "P17",
			"name" : "32038",
			"uuid" : "1cd35068-d93f-2542-a408-60575a318a8c",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 32039,
			"tags" : [
				"P17"
			],
			"type" : "sectionRound",
			"to" : 1692,
			"from" : 1640,
			"brick" : "P17",
			"name" : "32039",
			"uuid" : "e2e6e06d-31d5-ef47-850c-03d30568e768",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 32040,
			"tags" : [
				"P17"
			],
			"type" : "sectionRound",
			"to" : 1637,
			"from" : 1692,
			"brick" : "P17",
			"name" : "32040",
			"uuid" : "c63ff81c-17d0-4e4e-afe6-25be9531c54a",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 32041,
			"tags" : [
				"P17"
			],
			"type" : "sectionRound",
			"to" : 1693,
			"from" : 1645,
			"brick" : "P17",
			"name" : "32041",
			"uuid" : "fc98fa6a-9974-b84f-bdfb-5cf0101bb19c",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 32042,
			"tags" : [
				"P17"
			],
			"type" : "sectionRound",
			"to" : 1646,
			"from" : 1693,
			"brick" : "P17",
			"name" : "32042",
			"uuid" : "7e5a8415-00cb-7f4f-8fba-375abc587ee8",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 32043,
			"tags" : [
				"P17"
			],
			"type" : "sectionRound",
			"to" : 1694,
			"from" : 1646,
			"brick" : "P17",
			"name" : "32043",
			"uuid" : "1aebbf71-20b4-a44b-a0d8-07fb24ffdade",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 32044,
			"tags" : [
				"P17"
			],
			"type" : "sectionRound",
			"to" : 1647,
			"from" : 1694,
			"brick" : "P17",
			"name" : "32044",
			"uuid" : "3d16a4a2-0c7c-be49-9c21-933fbddc4021",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 32045,
			"tags" : [
				"P17"
			],
			"type" : "sectionRound",
			"to" : 1695,
			"from" : 1647,
			"brick" : "P17",
			"name" : "32045",
			"uuid" : "f418b15c-5a54-8648-8e70-b810a8c3ccdd",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 32046,
			"tags" : [
				"P17"
			],
			"type" : "sectionRound",
			"to" : 1648,
			"from" : 1695,
			"brick" : "P17",
			"name" : "32046",
			"uuid" : "03efac1e-cebb-4444-97fe-2f7f17aa92a7",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 32047,
			"tags" : [
				"P17"
			],
			"type" : "sectionRound",
			"to" : 1696,
			"from" : 1648,
			"brick" : "P17",
			"name" : "32047",
			"uuid" : "3a53a8ef-bea3-4549-a48d-309fa9817fdc",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 32048,
			"tags" : [
				"P17"
			],
			"type" : "sectionRound",
			"to" : 1645,
			"from" : 1696,
			"brick" : "P17",
			"name" : "32048",
			"uuid" : "9d887a92-144d-3847-a05b-7ec22d231899",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 32049,
			"tags" : [
				"P17"
			],
			"type" : "sectionRound",
			"to" : 1650,
			"from" : 1649,
			"brick" : "P17",
			"name" : "32049",
			"uuid" : "37ecc411-04e8-ed4f-b951-5d8df991e223",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 32050,
			"tags" : [
				"P17"
			],
			"type" : "sectionRound",
			"to" : 1651,
			"from" : 1650,
			"brick" : "P17",
			"name" : "32050",
			"uuid" : "9e7b63cb-fe79-9d47-80fd-bcdd62a1e3e2",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 32051,
			"tags" : [
				"P17"
			],
			"type" : "sectionRound",
			"to" : 1652,
			"from" : 1651,
			"brick" : "P17",
			"name" : "32051",
			"uuid" : "cf51229c-2eb9-a246-8fcb-c92d6b19869c",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 32052,
			"tags" : [
				"P17"
			],
			"type" : "sectionRound",
			"to" : 1649,
			"from" : 1652,
			"brick" : "P17",
			"name" : "32052",
			"uuid" : "6542a396-f7dd-ce43-96fb-4637d461ca32",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 32053,
			"tags" : [
				"P17"
			],
			"type" : "sectionRound",
			"to" : 1697,
			"from" : 1653,
			"brick" : "P17",
			"name" : "32053",
			"uuid" : "cac2bf64-c8cd-a74e-bf41-65e34ea61d3f",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 32054,
			"tags" : [
				"P17"
			],
			"type" : "sectionRound",
			"to" : 1654,
			"from" : 1697,
			"brick" : "P17",
			"name" : "32054",
			"uuid" : "15f99702-d6c3-ab40-a591-ded52afdcd0c",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 32055,
			"tags" : [
				"P17"
			],
			"type" : "sectionRound",
			"to" : 1698,
			"from" : 1654,
			"brick" : "P17",
			"name" : "32055",
			"uuid" : "f99a1b5e-bd68-e94f-aa82-fbf2337ac489",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 32056,
			"tags" : [
				"P17"
			],
			"type" : "sectionRound",
			"to" : 1655,
			"from" : 1698,
			"brick" : "P17",
			"name" : "32056",
			"uuid" : "0e505b67-b939-c049-9fd8-f7c89eae27f4",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 32057,
			"tags" : [
				"P17"
			],
			"type" : "sectionRound",
			"to" : 1699,
			"from" : 1655,
			"brick" : "P17",
			"name" : "32057",
			"uuid" : "a3ca9920-e4da-8541-931c-68913eee782e",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 32058,
			"tags" : [
				"P17"
			],
			"type" : "sectionRound",
			"to" : 1656,
			"from" : 1699,
			"brick" : "P17",
			"name" : "32058",
			"uuid" : "1208b0ea-dc63-f745-88e6-efc8b6dcc411",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 32059,
			"tags" : [
				"P17"
			],
			"type" : "sectionRound",
			"to" : 1700,
			"from" : 1656,
			"brick" : "P17",
			"name" : "32059",
			"uuid" : "0ad15784-3ed1-5b4b-9c8f-58d2da49cf5c",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 32060,
			"tags" : [
				"P17"
			],
			"type" : "sectionRound",
			"to" : 1653,
			"from" : 1700,
			"brick" : "P17",
			"name" : "32060",
			"uuid" : "4f9f723d-86e3-404f-ac02-394707b7e4c1",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 32061,
			"tags" : [
				"P17"
			],
			"type" : "sectionRound",
			"to" : 1701,
			"from" : 1661,
			"brick" : "P17",
			"name" : "32061",
			"uuid" : "0f9b82a4-cace-954c-ab9d-0959e1c4d709",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 32062,
			"tags" : [
				"P17"
			],
			"type" : "sectionRound",
			"to" : 1662,
			"from" : 1701,
			"brick" : "P17",
			"name" : "32062",
			"uuid" : "6f83f256-7faa-a246-87e4-40f819a024d1",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 32063,
			"tags" : [
				"P17"
			],
			"type" : "sectionRound",
			"to" : 1702,
			"from" : 1662,
			"brick" : "P17",
			"name" : "32063",
			"uuid" : "6d93051d-2cb3-6e49-8961-5501a146a3bb",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 32064,
			"tags" : [
				"P17"
			],
			"type" : "sectionRound",
			"to" : 1663,
			"from" : 1702,
			"brick" : "P17",
			"name" : "32064",
			"uuid" : "3450bf91-af97-c646-ac0d-486ee9710b86",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 32065,
			"tags" : [
				"P17"
			],
			"type" : "sectionRound",
			"to" : 1703,
			"from" : 1663,
			"brick" : "P17",
			"name" : "32065",
			"uuid" : "b4cc48c7-f532-9b40-94cd-d6f798820efc",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 32066,
			"tags" : [
				"P17"
			],
			"type" : "sectionRound",
			"to" : 1664,
			"from" : 1703,
			"brick" : "P17",
			"name" : "32066",
			"uuid" : "2cbda1a4-e80c-1f4f-ac1e-a3e4d1f3a263",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 32067,
			"tags" : [
				"P17"
			],
			"type" : "sectionRound",
			"to" : 1704,
			"from" : 1664,
			"brick" : "P17",
			"name" : "32067",
			"uuid" : "a0049989-27b9-c441-8308-83efd74372ac",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 32068,
			"tags" : [
				"P17"
			],
			"type" : "sectionRound",
			"to" : 1661,
			"from" : 1704,
			"brick" : "P17",
			"name" : "32068",
			"uuid" : "384eef9a-2cd1-a74e-b16e-a7ce84e62098",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 32069,
			"tags" : [
				"P17"
			],
			"type" : "sectionRound",
			"to" : 1705,
			"from" : 1669,
			"brick" : "P17",
			"name" : "32069",
			"uuid" : "562dc5c7-f6fb-274f-a866-d39e4380ff7b",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 32070,
			"tags" : [
				"P17"
			],
			"type" : "sectionRound",
			"to" : 1670,
			"from" : 1705,
			"brick" : "P17",
			"name" : "32070",
			"uuid" : "63602689-dc78-2d44-b420-756d22c273a2",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 32071,
			"tags" : [
				"P17"
			],
			"type" : "sectionRound",
			"to" : 1706,
			"from" : 1670,
			"brick" : "P17",
			"name" : "32071",
			"uuid" : "1b77537e-5468-9a44-877c-30cc445159d0",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 32072,
			"tags" : [
				"P17"
			],
			"type" : "sectionRound",
			"to" : 1671,
			"from" : 1706,
			"brick" : "P17",
			"name" : "32072",
			"uuid" : "0acc31ff-72e2-664e-b650-5a96c0fdb303",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 32073,
			"tags" : [
				"P17"
			],
			"type" : "sectionRound",
			"to" : 1707,
			"from" : 1671,
			"brick" : "P17",
			"name" : "32073",
			"uuid" : "075d7065-d08c-b547-b1a3-d8dd4dfd05ed",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 32074,
			"tags" : [
				"P17"
			],
			"type" : "sectionRound",
			"to" : 1672,
			"from" : 1707,
			"brick" : "P17",
			"name" : "32074",
			"uuid" : "9d99fd9f-c0ae-8b4a-823f-3137614eec2b",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 32075,
			"tags" : [
				"P17"
			],
			"type" : "sectionRound",
			"to" : 1708,
			"from" : 1672,
			"brick" : "P17",
			"name" : "32075",
			"uuid" : "44731454-7beb-df4b-8c57-9ec0bde865d5",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 32076,
			"tags" : [
				"P17"
			],
			"type" : "sectionRound",
			"to" : 1669,
			"from" : 1708,
			"brick" : "P17",
			"name" : "32076",
			"uuid" : "f5fd5823-5b97-5147-8235-efde6208bbb2",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 32101,
			"tags" : [
				"P17"
			],
			"type" : "sectionSlant",
			"to" : 1604,
			"from" : 1602,
			"brick" : "P17",
			"name" : "32101",
			"uuid" : "8fa224ec-a14c-2a46-8b1e-0e55b224b5ac",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 32102,
			"tags" : [
				"P17"
			],
			"type" : "sectionSlant",
			"to" : 1607,
			"from" : 1605,
			"brick" : "P17",
			"name" : "32102",
			"uuid" : "a6539369-5e8f-1f48-9553-cbe80f1b02a4",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 32103,
			"tags" : [
				"P17"
			],
			"type" : "sectionSlant",
			"to" : 1612,
			"from" : 1610,
			"brick" : "P17",
			"name" : "32103",
			"uuid" : "ae1d1e32-601e-ba4a-8a86-26710f9f8b9e",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 32104,
			"tags" : [
				"P17"
			],
			"type" : "sectionSlant",
			"to" : 1615,
			"from" : 1613,
			"brick" : "P17",
			"name" : "32104",
			"uuid" : "eb4f0c2d-0ea0-9941-8e83-778a351382de",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 32105,
			"tags" : [
				"P17"
			],
			"type" : "sectionSlant",
			"to" : 1620,
			"from" : 2601,
			"brick" : "P17",
			"name" : "32105",
			"uuid" : "082497b1-e87d-3e4e-9d89-06272b2e39e8",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 32106,
			"tags" : [
				"P17"
			],
			"type" : "sectionSlant",
			"to" : 2601,
			"from" : 1618,
			"brick" : "P17",
			"name" : "32106",
			"uuid" : "182bdc19-0b44-7d4c-adde-cc98502ec0df",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 32107,
			"tags" : [
				"P17"
			],
			"type" : "sectionSlant",
			"to" : 1619,
			"from" : 2601,
			"brick" : "P17",
			"name" : "32107",
			"uuid" : "6155c1c0-282a-2e46-9a18-c3f32197eda6",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 32108,
			"tags" : [
				"P17"
			],
			"type" : "sectionSlant",
			"to" : 2601,
			"from" : 1617,
			"brick" : "P17",
			"name" : "32108",
			"uuid" : "40e316eb-d497-f142-9113-5810c8b94988",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 32109,
			"tags" : [
				"P17"
			],
			"type" : "sectionSlant",
			"to" : 1624,
			"from" : 2602,
			"brick" : "P17",
			"name" : "32109",
			"uuid" : "75837174-e04b-8c46-a9ff-8d2d3becf8d5",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 32110,
			"tags" : [
				"P17"
			],
			"type" : "sectionSlant",
			"to" : 2602,
			"from" : 1622,
			"brick" : "P17",
			"name" : "32110",
			"uuid" : "1b8be344-b46d-8b40-bc88-e54e7aed1e99",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 32111,
			"tags" : [
				"P17"
			],
			"type" : "sectionSlant",
			"to" : 1623,
			"from" : 2602,
			"brick" : "P17",
			"name" : "32111",
			"uuid" : "4be8bdbe-c5a3-d44d-9700-a50c31245a0e",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 32112,
			"tags" : [
				"P17"
			],
			"type" : "sectionSlant",
			"to" : 2602,
			"from" : 1621,
			"brick" : "P17",
			"name" : "32112",
			"uuid" : "22a586bb-2b26-c349-ac8f-bf91ef212b31",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 32113,
			"tags" : [
				"P17"
			],
			"type" : "sectionSlant",
			"to" : 1685,
			"from" : 1688,
			"brick" : "P17",
			"name" : "32113",
			"uuid" : "ff3a48cc-79c6-484a-b3d4-a295b08b0687",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 32114,
			"tags" : [
				"P17"
			],
			"type" : "sectionSlant",
			"to" : 1686,
			"from" : 1685,
			"brick" : "P17",
			"name" : "32114",
			"uuid" : "a892d8c0-5e7b-a244-be0a-95931d551fb4",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 32115,
			"tags" : [
				"P17"
			],
			"type" : "sectionSlant",
			"to" : 1687,
			"from" : 1686,
			"brick" : "P17",
			"name" : "32115",
			"uuid" : "296e1586-e93d-7647-985b-48fd8b11ef27",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 32116,
			"tags" : [
				"P17"
			],
			"type" : "sectionSlant",
			"to" : 1688,
			"from" : 1687,
			"brick" : "P17",
			"name" : "32116",
			"uuid" : "4790068d-7c03-734b-b102-f63fb50d2dbc",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 32117,
			"tags" : [
				"P17"
			],
			"type" : "sectionSlant",
			"to" : 1689,
			"from" : 1692,
			"brick" : "P17",
			"name" : "32117",
			"uuid" : "393e0398-f8f5-6944-bd77-c61b5b7b5a48",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 32118,
			"tags" : [
				"P17"
			],
			"type" : "sectionSlant",
			"to" : 1690,
			"from" : 1689,
			"brick" : "P17",
			"name" : "32118",
			"uuid" : "2a21f1bd-3eb6-6e4c-94e7-8e18cf744270",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 32119,
			"tags" : [
				"P17"
			],
			"type" : "sectionSlant",
			"to" : 1691,
			"from" : 1690,
			"brick" : "P17",
			"name" : "32119",
			"uuid" : "ef907a64-9bb7-0246-8c3c-62300edc3314",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 32120,
			"tags" : [
				"P17"
			],
			"type" : "sectionSlant",
			"to" : 1692,
			"from" : 1691,
			"brick" : "P17",
			"name" : "32120",
			"uuid" : "e179c57b-10fb-644e-b5b3-2c89763404db",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 32121,
			"tags" : [
				"P17"
			],
			"type" : "sectionSlant",
			"to" : 1693,
			"from" : 1696,
			"brick" : "P17",
			"name" : "32121",
			"uuid" : "726a0a71-eea0-c644-9717-0a811635e5bd",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 32122,
			"tags" : [
				"P17"
			],
			"type" : "sectionSlant",
			"to" : 1694,
			"from" : 1693,
			"brick" : "P17",
			"name" : "32122",
			"uuid" : "27f1a2fb-bb8a-9442-b4b2-3dcd18c8594c",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 32123,
			"tags" : [
				"P17"
			],
			"type" : "sectionSlant",
			"to" : 1695,
			"from" : 1694,
			"brick" : "P17",
			"name" : "32123",
			"uuid" : "8507f0ae-5439-6b43-a1e8-81770737d851",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 32124,
			"tags" : [
				"P17"
			],
			"type" : "sectionSlant",
			"to" : 1696,
			"from" : 1695,
			"brick" : "P17",
			"name" : "32124",
			"uuid" : "eb9a79d3-a144-064c-8344-550f8223508e",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 32125,
			"tags" : [
				"P17"
			],
			"type" : "sectionSlant",
			"to" : 1697,
			"from" : 1700,
			"brick" : "P17",
			"name" : "32125",
			"uuid" : "5b2291fd-62af-d74e-8411-fdde01446c47",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 32126,
			"tags" : [
				"P17"
			],
			"type" : "sectionSlant",
			"to" : 1698,
			"from" : 1697,
			"brick" : "P17",
			"name" : "32126",
			"uuid" : "4f48d443-8de0-e643-89e0-44b2c03388c9",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 32127,
			"tags" : [
				"P17"
			],
			"type" : "sectionSlant",
			"to" : 1699,
			"from" : 1698,
			"brick" : "P17",
			"name" : "32127",
			"uuid" : "d6114b86-6e84-3040-a1a6-26e60dae416e",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 32128,
			"tags" : [
				"P17"
			],
			"type" : "sectionSlant",
			"to" : 1700,
			"from" : 1699,
			"brick" : "P17",
			"name" : "32128",
			"uuid" : "e1983dae-814b-fa4c-99f2-f41078ca3a1e",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 32129,
			"tags" : [
				"P17"
			],
			"type" : "sectionSlant",
			"to" : 1701,
			"from" : 1704,
			"brick" : "P17",
			"name" : "32129",
			"uuid" : "2588e4c5-d641-1b46-9342-084b22333e0f",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 32130,
			"tags" : [
				"P17"
			],
			"type" : "sectionSlant",
			"to" : 1702,
			"from" : 1701,
			"brick" : "P17",
			"name" : "32130",
			"uuid" : "93b242fe-51f6-314d-b0f2-0ee52b9553eb",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 32131,
			"tags" : [
				"P17"
			],
			"type" : "sectionSlant",
			"to" : 1703,
			"from" : 1702,
			"brick" : "P17",
			"name" : "32131",
			"uuid" : "f034fc20-ecf4-ae43-8a36-704ced81908a",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 32132,
			"tags" : [
				"P17"
			],
			"type" : "sectionSlant",
			"to" : 1704,
			"from" : 1703,
			"brick" : "P17",
			"name" : "32132",
			"uuid" : "5624948c-3980-a84c-8f40-85c28bc50428",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 32133,
			"tags" : [
				"P17"
			],
			"type" : "sectionSlant",
			"to" : 1705,
			"from" : 1708,
			"brick" : "P17",
			"name" : "32133",
			"uuid" : "dbf70294-3248-604e-b810-f5fe74feb2c0",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 32134,
			"tags" : [
				"P17"
			],
			"type" : "sectionSlant",
			"to" : 1706,
			"from" : 1705,
			"brick" : "P17",
			"name" : "32134",
			"uuid" : "bcc36d11-a6ed-5b45-a931-59c7574934fb",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 32135,
			"tags" : [
				"P17"
			],
			"type" : "sectionSlant",
			"to" : 1707,
			"from" : 1706,
			"brick" : "P17",
			"name" : "32135",
			"uuid" : "c1f13d8c-427d-fd4a-828f-bfd320dbcae9",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 32136,
			"tags" : [
				"P17"
			],
			"type" : "sectionSlant",
			"to" : 1708,
			"from" : 1707,
			"brick" : "P17",
			"name" : "32136",
			"uuid" : "db5e1b97-701f-7041-8244-2bfd9fe3b0b2",
			"_clazz" : "TwkSegment"
		},
		{
			"uuid" : "9aa74a1b-176f-1a41-8efc-6439a98dc72f",
			"name" : "23001",
			"_clazz" : "TwkSegment",
			"brick" : "FRONT",
			"from" : 1606,
			"face" : "front",
			"tags" : [
				"P17"
			],
			"type" : "panel",
			"to" : 1601,
			"number" : 23001
		},
		{
			"uuid" : "97340a39-63f6-de4e-91f8-47690b0893c9",
			"name" : "23002",
			"_clazz" : "TwkSegment",
			"brick" : "LEFT",
			"from" : 1607,
			"face" : "left",
			"tags" : [
				"P17"
			],
			"type" : "panel",
			"to" : 1602,
			"number" : 23002
		},
		{
			"uuid" : "b97e35d6-e4a6-204a-abca-b9eba26b99b8",
			"name" : "23003",
			"_clazz" : "TwkSegment",
			"brick" : "BACK",
			"from" : 1608,
			"face" : "back",
			"tags" : [
				"P17"
			],
			"type" : "panel",
			"to" : 1603,
			"number" : 23003
		},
		{
			"uuid" : "1c3c6988-07ad-8246-8aa9-dcc0fecf25aa",
			"name" : "23004",
			"_clazz" : "TwkSegment",
			"brick" : "RIGHT",
			"from" : 1605,
			"face" : "right",
			"tags" : [
				"P17"
			],
			"type" : "panel",
			"to" : 1604,
			"number" : 23004
		},
		{
			"uuid" : "74fbb280-a623-7647-b05e-58c59b5769c6",
			"name" : "23005",
			"_clazz" : "TwkSegment",
			"brick" : "FRONT",
			"from" : 1610,
			"face" : "front",
			"tags" : [
				"P17"
			],
			"type" : "panel",
			"to" : 1605,
			"number" : 23005
		},
		{
			"uuid" : "f59fcec8-ed32-b845-8881-cad78d343a6b",
			"name" : "23006",
			"_clazz" : "TwkSegment",
			"brick" : "LEFT",
			"from" : 1611,
			"face" : "left",
			"tags" : [
				"P17"
			],
			"type" : "panel",
			"to" : 1606,
			"number" : 23006
		},
		{
			"uuid" : "952ec832-123c-5144-9142-d28809749bb4",
			"name" : "23007",
			"_clazz" : "TwkSegment",
			"brick" : "BACK",
			"from" : 1612,
			"face" : "back",
			"tags" : [
				"P17"
			],
			"type" : "panel",
			"to" : 1607,
			"number" : 23007
		},
		{
			"uuid" : "496f2484-6a1a-cc4d-89e3-e8aed189150e",
			"name" : "23008",
			"_clazz" : "TwkSegment",
			"brick" : "RIGHT",
			"from" : 1609,
			"face" : "right",
			"tags" : [
				"P17"
			],
			"type" : "panel",
			"to" : 1608,
			"number" : 23008
		},
		{
			"uuid" : "128e8b84-e257-b149-8632-f707a171f45d",
			"name" : "23009",
			"_clazz" : "TwkSegment",
			"brick" : "FRONT",
			"from" : 1614,
			"face" : "front",
			"tags" : [
				"P17"
			],
			"type" : "panel",
			"to" : 1609,
			"number" : 23009
		},
		{
			"uuid" : "dfdc522c-638f-944c-afe6-cd6bdf1134e0",
			"name" : "23010",
			"_clazz" : "TwkSegment",
			"brick" : "LEFT",
			"from" : 1615,
			"face" : "left",
			"tags" : [
				"P17"
			],
			"type" : "panel",
			"to" : 1610,
			"number" : 23010
		},
		{
			"uuid" : "cb59ad6f-385c-2045-943c-757c97ffaa43",
			"name" : "23011",
			"_clazz" : "TwkSegment",
			"brick" : "BACK",
			"from" : 1616,
			"face" : "back",
			"tags" : [
				"P17"
			],
			"type" : "panel",
			"to" : 1611,
			"number" : 23011
		},
		{
			"uuid" : "af718f23-2a9e-7541-826f-64478fbb2d32",
			"name" : "23012",
			"_clazz" : "TwkSegment",
			"brick" : "RIGHT",
			"from" : 1613,
			"face" : "right",
			"tags" : [
				"P17"
			],
			"type" : "panel",
			"to" : 1612,
			"number" : 23012
		},
		{
			"uuid" : "a447632b-152d-d345-84dc-3ca04765584d",
			"name" : "23013",
			"_clazz" : "TwkSegment",
			"brick" : "FRONT",
			"from" : 1618,
			"face" : "front",
			"tags" : [
				"P17"
			],
			"type" : "panel",
			"to" : 1613,
			"number" : 23013
		},
		{
			"uuid" : "ddd9b533-ac4b-2c44-876e-245b4f1d0ebc",
			"name" : "23014",
			"_clazz" : "TwkSegment",
			"brick" : "LEFT",
			"from" : 1619,
			"face" : "left",
			"tags" : [
				"P17"
			],
			"type" : "panel",
			"to" : 1614,
			"number" : 23014
		},
		{
			"uuid" : "dc5a9ef3-d701-7244-9417-342038f94427",
			"name" : "23015",
			"_clazz" : "TwkSegment",
			"brick" : "BACK",
			"from" : 1620,
			"face" : "back",
			"tags" : [
				"P17"
			],
			"type" : "panel",
			"to" : 1615,
			"number" : 23015
		},
		{
			"uuid" : "8b0bb521-91fe-4446-841f-0a5417758489",
			"name" : "23016",
			"_clazz" : "TwkSegment",
			"brick" : "RIGHT",
			"from" : 1617,
			"face" : "right",
			"tags" : [
				"P17"
			],
			"type" : "panel",
			"to" : 1616,
			"number" : 23016
		},
		{
			"uuid" : "fb7a310c-c18c-9840-ac3a-d292b1748ef9",
			"name" : "23017",
			"_clazz" : "TwkSegment",
			"brick" : "FRONT",
			"from" : 1677,
			"face" : "front",
			"tags" : [
				"P17"
			],
			"type" : "panel",
			"to" : 1617,
			"number" : 23017
		},
		{
			"uuid" : "10ed50e9-5d03-f047-81b8-7c066fb7dbf5",
			"name" : "23018",
			"_clazz" : "TwkSegment",
			"brick" : "FRONT",
			"from" : 1622,
			"face" : "front",
			"tags" : [
				"P17"
			],
			"type" : "panel",
			"to" : 1677,
			"number" : 23018
		},
		{
			"uuid" : "c231d902-9e76-344a-b2c9-1a0e33fd02a9",
			"name" : "23019",
			"_clazz" : "TwkSegment",
			"brick" : "FRONT",
			"from" : 1677,
			"face" : "front",
			"tags" : [
				"P17"
			],
			"type" : "panel",
			"to" : 1618,
			"number" : 23019
		},
		{
			"uuid" : "17a6cfb2-c33b-154c-91c0-8b5a86469f24",
			"name" : "23020",
			"_clazz" : "TwkSegment",
			"brick" : "FRONT",
			"from" : 1621,
			"face" : "front",
			"tags" : [
				"P17"
			],
			"type" : "panel",
			"to" : 1677,
			"number" : 23020
		},
		{
			"uuid" : "0f98829b-6fc3-c841-83e2-05bbdd06e0e2",
			"name" : "23021",
			"_clazz" : "TwkSegment",
			"brick" : "LEFT",
			"from" : 1678,
			"face" : "left",
			"tags" : [
				"P17"
			],
			"type" : "panel",
			"to" : 1618,
			"number" : 23021
		},
		{
			"uuid" : "64c19eb2-0df6-ff42-82d8-1dc53d1e9f27",
			"name" : "23022",
			"_clazz" : "TwkSegment",
			"brick" : "LEFT",
			"from" : 1623,
			"face" : "left",
			"tags" : [
				"P17"
			],
			"type" : "panel",
			"to" : 1678,
			"number" : 23022
		},
		{
			"uuid" : "d17f136f-aac5-e940-83ac-e8a4d72966ac",
			"name" : "23023",
			"_clazz" : "TwkSegment",
			"brick" : "LEFT",
			"from" : 1678,
			"face" : "left",
			"tags" : [
				"P17"
			],
			"type" : "panel",
			"to" : 1619,
			"number" : 23023
		},
		{
			"uuid" : "329e2ca2-bbe8-1f4f-b11b-44d1c96817ad",
			"name" : "23024",
			"_clazz" : "TwkSegment",
			"brick" : "LEFT",
			"from" : 1622,
			"face" : "left",
			"tags" : [
				"P17"
			],
			"type" : "panel",
			"to" : 1678,
			"number" : 23024
		},
		{
			"uuid" : "975ddfc4-7ad1-3b44-baa5-3353b194a596",
			"name" : "23025",
			"_clazz" : "TwkSegment",
			"brick" : "BACK",
			"from" : 1679,
			"face" : "back",
			"tags" : [
				"P17"
			],
			"type" : "panel",
			"to" : 1619,
			"number" : 23025
		},
		{
			"uuid" : "e3f9e286-b53b-bb4e-b2b4-e4bae4d1ea0f",
			"name" : "23026",
			"_clazz" : "TwkSegment",
			"brick" : "BACK",
			"from" : 1624,
			"face" : "back",
			"tags" : [
				"P17"
			],
			"type" : "panel",
			"to" : 1679,
			"number" : 23026
		},
		{
			"uuid" : "f72d7e58-74db-0248-859a-57bc6c06ffb4",
			"name" : "23027",
			"_clazz" : "TwkSegment",
			"brick" : "BACK",
			"from" : 1679,
			"face" : "back",
			"tags" : [
				"P17"
			],
			"type" : "panel",
			"to" : 1620,
			"number" : 23027
		},
		{
			"uuid" : "6c2e2072-71b0-4a44-a587-32151b5d7d58",
			"name" : "23028",
			"_clazz" : "TwkSegment",
			"brick" : "BACK",
			"from" : 1623,
			"face" : "back",
			"tags" : [
				"P17"
			],
			"type" : "panel",
			"to" : 1679,
			"number" : 23028
		},
		{
			"uuid" : "7076bfa6-d3b6-2349-a244-95ad86e5070d",
			"name" : "23029",
			"_clazz" : "TwkSegment",
			"brick" : "RIGHT",
			"from" : 1680,
			"face" : "right",
			"tags" : [
				"P17"
			],
			"type" : "panel",
			"to" : 1620,
			"number" : 23029
		},
		{
			"uuid" : "69342522-3c54-2d4e-9b37-d4715029dd4c",
			"name" : "23030",
			"_clazz" : "TwkSegment",
			"brick" : "RIGHT",
			"from" : 1621,
			"face" : "right",
			"tags" : [
				"P17"
			],
			"type" : "panel",
			"to" : 1680,
			"number" : 23030
		},
		{
			"uuid" : "780fcf7b-f7d3-9241-a60d-708dac63b7f7",
			"name" : "23031",
			"_clazz" : "TwkSegment",
			"brick" : "RIGHT",
			"from" : 1680,
			"face" : "right",
			"tags" : [
				"P17"
			],
			"type" : "panel",
			"to" : 1617,
			"number" : 23031
		},
		{
			"uuid" : "e36508ab-6265-5f47-bfe9-77c43c4d38ad",
			"name" : "23032",
			"_clazz" : "TwkSegment",
			"brick" : "RIGHT",
			"from" : 1624,
			"face" : "right",
			"tags" : [
				"P17"
			],
			"type" : "panel",
			"to" : 1680,
			"number" : 23032
		},
		{
			"uuid" : "a00f90b5-c1bf-644a-8a04-64e0ff097937",
			"name" : "23033",
			"_clazz" : "TwkSegment",
			"brick" : "FRONT",
			"from" : 1681,
			"face" : "front",
			"tags" : [
				"P17"
			],
			"type" : "panel",
			"to" : 1621,
			"number" : 23033
		},
		{
			"uuid" : "67d09f22-07f7-8a49-9ecb-2533e6b02c94",
			"name" : "23034",
			"_clazz" : "TwkSegment",
			"brick" : "FRONT",
			"from" : 1626,
			"face" : "front",
			"tags" : [
				"P17"
			],
			"type" : "panel",
			"to" : 1681,
			"number" : 23034
		},
		{
			"uuid" : "c2d42638-0e9d-d840-8e6c-f48cd19db757",
			"name" : "23035",
			"_clazz" : "TwkSegment",
			"brick" : "FRONT",
			"from" : 1681,
			"face" : "front",
			"tags" : [
				"P17"
			],
			"type" : "panel",
			"to" : 1622,
			"number" : 23035
		},
		{
			"uuid" : "b33e626a-d693-7849-b7b2-098250739a53",
			"name" : "23036",
			"_clazz" : "TwkSegment",
			"brick" : "FRONT",
			"from" : 1625,
			"face" : "front",
			"tags" : [
				"P17"
			],
			"type" : "panel",
			"to" : 1681,
			"number" : 23036
		},
		{
			"uuid" : "54a702ce-0f36-834b-95f3-79c2a41f4033",
			"name" : "23037",
			"_clazz" : "TwkSegment",
			"brick" : "LEFT",
			"from" : 1682,
			"face" : "left",
			"tags" : [
				"P17"
			],
			"type" : "panel",
			"to" : 1622,
			"number" : 23037
		},
		{
			"uuid" : "4f825431-5940-5d4d-826a-a6f949fc1b40",
			"name" : "23038",
			"_clazz" : "TwkSegment",
			"brick" : "LEFT",
			"from" : 1627,
			"face" : "left",
			"tags" : [
				"P17"
			],
			"type" : "panel",
			"to" : 1682,
			"number" : 23038
		},
		{
			"uuid" : "69e617d3-f16f-934a-9d16-a2d9d82f6790",
			"name" : "23039",
			"_clazz" : "TwkSegment",
			"brick" : "LEFT",
			"from" : 1682,
			"face" : "left",
			"tags" : [
				"P17"
			],
			"type" : "panel",
			"to" : 1623,
			"number" : 23039
		},
		{
			"uuid" : "df1a22f6-7f23-2748-9387-cb4d988a1197",
			"name" : "23040",
			"_clazz" : "TwkSegment",
			"brick" : "LEFT",
			"from" : 1626,
			"face" : "left",
			"tags" : [
				"P17"
			],
			"type" : "panel",
			"to" : 1682,
			"number" : 23040
		},
		{
			"uuid" : "91a80284-9ed6-c140-b5a7-745f30ea7c1d",
			"name" : "23041",
			"_clazz" : "TwkSegment",
			"brick" : "BACK",
			"from" : 1683,
			"face" : "back",
			"tags" : [
				"P17"
			],
			"type" : "panel",
			"to" : 1623,
			"number" : 23041
		},
		{
			"uuid" : "c630d8a2-f062-4f44-969c-377702878e6e",
			"name" : "23042",
			"_clazz" : "TwkSegment",
			"brick" : "BACK",
			"from" : 1628,
			"face" : "back",
			"tags" : [
				"P17"
			],
			"type" : "panel",
			"to" : 1683,
			"number" : 23042
		},
		{
			"uuid" : "f2e4f44a-71cf-dc49-8c50-8053f8171d78",
			"name" : "23043",
			"_clazz" : "TwkSegment",
			"brick" : "BACK",
			"from" : 1683,
			"face" : "back",
			"tags" : [
				"P17"
			],
			"type" : "panel",
			"to" : 1624,
			"number" : 23043
		},
		{
			"uuid" : "611125e0-ac60-7c4f-8d90-afd5145fe948",
			"name" : "23044",
			"_clazz" : "TwkSegment",
			"brick" : "BACK",
			"from" : 1627,
			"face" : "back",
			"tags" : [
				"P17"
			],
			"type" : "panel",
			"to" : 1683,
			"number" : 23044
		},
		{
			"uuid" : "b08450d1-5264-6f41-b62d-9cebde6d944f",
			"name" : "23045",
			"_clazz" : "TwkSegment",
			"brick" : "RIGHT",
			"from" : 1684,
			"face" : "right",
			"tags" : [
				"P17"
			],
			"type" : "panel",
			"to" : 1624,
			"number" : 23045
		},
		{
			"uuid" : "138cb9d5-f5f3-a748-81a1-27291eda858c",
			"name" : "23046",
			"_clazz" : "TwkSegment",
			"brick" : "RIGHT",
			"from" : 1625,
			"face" : "right",
			"tags" : [
				"P17"
			],
			"type" : "panel",
			"to" : 1684,
			"number" : 23046
		},
		{
			"uuid" : "92437fc2-cfcf-4944-89ba-0ca721c7c6dc",
			"name" : "23047",
			"_clazz" : "TwkSegment",
			"brick" : "RIGHT",
			"from" : 1684,
			"face" : "right",
			"tags" : [
				"P17"
			],
			"type" : "panel",
			"to" : 1621,
			"number" : 23047
		},
		{
			"uuid" : "d72f6636-8d60-c14d-8952-40524fcce858",
			"name" : "23048",
			"_clazz" : "TwkSegment",
			"brick" : "RIGHT",
			"from" : 1628,
			"face" : "right",
			"tags" : [
				"P17"
			],
			"type" : "panel",
			"to" : 1684,
			"number" : 23048
		},
		{
			"uuid" : "71fc80e7-7ad8-4e40-82f1-0b009e4b86c5",
			"name" : "23049",
			"_clazz" : "TwkSegment",
			"brick" : "FRONT",
			"from" : 1685,
			"face" : "front",
			"tags" : [
				"P17"
			],
			"type" : "panel",
			"to" : 1625,
			"number" : 23049
		},
		{
			"uuid" : "2a5748ed-5dae-2f43-8ff6-57bcd1874af5",
			"name" : "23050",
			"_clazz" : "TwkSegment",
			"brick" : "FRONT",
			"from" : 1634,
			"face" : "front",
			"tags" : [
				"P17"
			],
			"type" : "panel",
			"to" : 1685,
			"number" : 23050
		},
		{
			"uuid" : "e44367c4-7382-8342-9b7f-3becb0ec0721",
			"name" : "23051",
			"_clazz" : "TwkSegment",
			"brick" : "FRONT",
			"from" : 1685,
			"face" : "front",
			"tags" : [
				"P17"
			],
			"type" : "panel",
			"to" : 1626,
			"number" : 23051
		},
		{
			"uuid" : "b0ec8b7d-f3fe-e843-9299-e7779cb2c08b",
			"name" : "23052",
			"_clazz" : "TwkSegment",
			"brick" : "FRONT",
			"from" : 1633,
			"face" : "front",
			"tags" : [
				"P17"
			],
			"type" : "panel",
			"to" : 1685,
			"number" : 23052
		},
		{
			"uuid" : "910b0a89-6f80-3442-ada7-d803707ce402",
			"name" : "23053",
			"_clazz" : "TwkSegment",
			"brick" : "LEFT",
			"from" : 1686,
			"face" : "left",
			"tags" : [
				"P17"
			],
			"type" : "panel",
			"to" : 1626,
			"number" : 23053
		},
		{
			"uuid" : "c2e9bf9b-2ee5-724d-9ebd-a14125646c87",
			"name" : "23054",
			"_clazz" : "TwkSegment",
			"brick" : "LEFT",
			"from" : 1635,
			"face" : "left",
			"tags" : [
				"P17"
			],
			"type" : "panel",
			"to" : 1686,
			"number" : 23054
		},
		{
			"uuid" : "c8c351bd-f937-9446-bec1-0f623a2aacfe",
			"name" : "23055",
			"_clazz" : "TwkSegment",
			"brick" : "LEFT",
			"from" : 1686,
			"face" : "left",
			"tags" : [
				"P17"
			],
			"type" : "panel",
			"to" : 1627,
			"number" : 23055
		},
		{
			"uuid" : "89068e29-9eb0-6a41-b300-de42e1d42fa9",
			"name" : "23056",
			"_clazz" : "TwkSegment",
			"brick" : "LEFT",
			"from" : 1634,
			"face" : "left",
			"tags" : [
				"P17"
			],
			"type" : "panel",
			"to" : 1686,
			"number" : 23056
		},
		{
			"uuid" : "3fc025d0-60fe-9744-8034-a50859222099",
			"name" : "23057",
			"_clazz" : "TwkSegment",
			"brick" : "BACK",
			"from" : 1687,
			"face" : "back",
			"tags" : [
				"P17"
			],
			"type" : "panel",
			"to" : 1627,
			"number" : 23057
		},
		{
			"uuid" : "4097955f-48ff-2a4f-a26f-20d4888d35d8",
			"name" : "23058",
			"_clazz" : "TwkSegment",
			"brick" : "BACK",
			"from" : 1636,
			"face" : "back",
			"tags" : [
				"P17"
			],
			"type" : "panel",
			"to" : 1687,
			"number" : 23058
		},
		{
			"uuid" : "834c6fe5-1275-1d44-95a6-0229e5f49633",
			"name" : "23059",
			"_clazz" : "TwkSegment",
			"brick" : "BACK",
			"from" : 1687,
			"face" : "back",
			"tags" : [
				"P17"
			],
			"type" : "panel",
			"to" : 1628,
			"number" : 23059
		},
		{
			"uuid" : "fe2762b4-5753-2340-ab9c-b6345a536104",
			"name" : "23060",
			"_clazz" : "TwkSegment",
			"brick" : "BACK",
			"from" : 1635,
			"face" : "back",
			"tags" : [
				"P17"
			],
			"type" : "panel",
			"to" : 1687,
			"number" : 23060
		},
		{
			"uuid" : "17cb5635-9cac-ea4a-b99b-aee302cc4bef",
			"name" : "23061",
			"_clazz" : "TwkSegment",
			"brick" : "RIGHT",
			"from" : 1688,
			"face" : "right",
			"tags" : [
				"P17"
			],
			"type" : "panel",
			"to" : 1628,
			"number" : 23061
		},
		{
			"uuid" : "e91ec247-55ad-ee44-99bc-07b53383991d",
			"name" : "23062",
			"_clazz" : "TwkSegment",
			"brick" : "RIGHT",
			"from" : 1633,
			"face" : "right",
			"tags" : [
				"P17"
			],
			"type" : "panel",
			"to" : 1688,
			"number" : 23062
		},
		{
			"uuid" : "1ef82c2a-b3f7-e447-a5e1-19e306ad4122",
			"name" : "23063",
			"_clazz" : "TwkSegment",
			"brick" : "RIGHT",
			"from" : 1688,
			"face" : "right",
			"tags" : [
				"P17"
			],
			"type" : "panel",
			"to" : 1625,
			"number" : 23063
		},
		{
			"uuid" : "988e9839-ac3c-1543-a44b-ecb7382ed915",
			"name" : "23064",
			"_clazz" : "TwkSegment",
			"brick" : "RIGHT",
			"from" : 1636,
			"face" : "right",
			"tags" : [
				"P17"
			],
			"type" : "panel",
			"to" : 1688,
			"number" : 23064
		},
		{
			"uuid" : "992dd824-ac63-8a46-9fbc-1bf733d36b6a",
			"name" : "23065",
			"_clazz" : "TwkSegment",
			"brick" : "FRONT",
			"from" : 1689,
			"face" : "front",
			"tags" : [
				"P17"
			],
			"type" : "panel",
			"to" : 1633,
			"number" : 23065
		},
		{
			"uuid" : "3c19ffaf-4f02-e04f-97e3-72ed9f904ec8",
			"name" : "23066",
			"_clazz" : "TwkSegment",
			"brick" : "FRONT",
			"from" : 1642,
			"face" : "front",
			"tags" : [
				"P17"
			],
			"type" : "panel",
			"to" : 1689,
			"number" : 23066
		},
		{
			"uuid" : "c1a67b57-41f2-af49-b6fd-0311cf844f6f",
			"name" : "23067",
			"_clazz" : "TwkSegment",
			"brick" : "FRONT",
			"from" : 1689,
			"face" : "front",
			"tags" : [
				"P17"
			],
			"type" : "panel",
			"to" : 1634,
			"number" : 23067
		},
		{
			"uuid" : "e4403faf-4025-8743-8c67-9df9623ba1d5",
			"name" : "23068",
			"_clazz" : "TwkSegment",
			"brick" : "FRONT",
			"from" : 1641,
			"face" : "front",
			"tags" : [
				"P17"
			],
			"type" : "panel",
			"to" : 1689,
			"number" : 23068
		},
		{
			"uuid" : "6774783b-674e-7940-952b-225ebca0a9e5",
			"name" : "23069",
			"_clazz" : "TwkSegment",
			"brick" : "LEFT",
			"from" : 1690,
			"face" : "left",
			"tags" : [
				"P17"
			],
			"type" : "panel",
			"to" : 1634,
			"number" : 23069
		},
		{
			"uuid" : "94a50f0a-dc30-974d-8516-c29963f6ccb4",
			"name" : "23070",
			"_clazz" : "TwkSegment",
			"brick" : "LEFT",
			"from" : 1643,
			"face" : "left",
			"tags" : [
				"P17"
			],
			"type" : "panel",
			"to" : 1690,
			"number" : 23070
		},
		{
			"uuid" : "48d6279b-6b12-9846-b53e-7746e983ce6a",
			"name" : "23071",
			"_clazz" : "TwkSegment",
			"brick" : "LEFT",
			"from" : 1690,
			"face" : "left",
			"tags" : [
				"P17"
			],
			"type" : "panel",
			"to" : 1635,
			"number" : 23071
		},
		{
			"uuid" : "9d628a59-e726-5644-b89c-93b5557c2170",
			"name" : "23072",
			"_clazz" : "TwkSegment",
			"brick" : "LEFT",
			"from" : 1642,
			"face" : "left",
			"tags" : [
				"P17"
			],
			"type" : "panel",
			"to" : 1690,
			"number" : 23072
		},
		{
			"uuid" : "3596f8f6-6a5a-6444-849f-a66ecdd00790",
			"name" : "23073",
			"_clazz" : "TwkSegment",
			"brick" : "BACK",
			"from" : 1691,
			"face" : "back",
			"tags" : [
				"P17"
			],
			"type" : "panel",
			"to" : 1635,
			"number" : 23073
		},
		{
			"uuid" : "43bfb8f9-80d7-e042-a4ae-e4faeb1f2f5b",
			"name" : "23074",
			"_clazz" : "TwkSegment",
			"brick" : "BACK",
			"from" : 1644,
			"face" : "back",
			"tags" : [
				"P17"
			],
			"type" : "panel",
			"to" : 1691,
			"number" : 23074
		},
		{
			"uuid" : "67006576-7ae6-7643-8aab-28e964e80ba7",
			"name" : "23075",
			"_clazz" : "TwkSegment",
			"brick" : "BACK",
			"from" : 1691,
			"face" : "back",
			"tags" : [
				"P17"
			],
			"type" : "panel",
			"to" : 1636,
			"number" : 23075
		},
		{
			"uuid" : "ebf10653-281f-ba4e-8f65-d0556818889a",
			"name" : "23076",
			"_clazz" : "TwkSegment",
			"brick" : "BACK",
			"from" : 1643,
			"face" : "back",
			"tags" : [
				"P17"
			],
			"type" : "panel",
			"to" : 1691,
			"number" : 23076
		},
		{
			"uuid" : "db4b5de0-1e22-5940-b2c1-c7a9d8398f5b",
			"name" : "23077",
			"_clazz" : "TwkSegment",
			"brick" : "RIGHT",
			"from" : 1692,
			"face" : "right",
			"tags" : [
				"P17"
			],
			"type" : "panel",
			"to" : 1636,
			"number" : 23077
		},
		{
			"uuid" : "3a61c9d5-e965-a947-896c-ad971e6da4cf",
			"name" : "23078",
			"_clazz" : "TwkSegment",
			"brick" : "RIGHT",
			"from" : 1641,
			"face" : "right",
			"tags" : [
				"P17"
			],
			"type" : "panel",
			"to" : 1692,
			"number" : 23078
		},
		{
			"uuid" : "658164d8-d304-0e41-8104-150610045606",
			"name" : "23079",
			"_clazz" : "TwkSegment",
			"brick" : "RIGHT",
			"from" : 1692,
			"face" : "right",
			"tags" : [
				"P17"
			],
			"type" : "panel",
			"to" : 1633,
			"number" : 23079
		},
		{
			"uuid" : "63f6adf7-c5c6-ec47-837b-08218ae05402",
			"name" : "23080",
			"_clazz" : "TwkSegment",
			"brick" : "RIGHT",
			"from" : 1644,
			"face" : "right",
			"tags" : [
				"P17"
			],
			"type" : "panel",
			"to" : 1692,
			"number" : 23080
		},
		{
			"uuid" : "2387cd59-4c32-2f48-aaf3-6c8548a01d2d",
			"name" : "23081",
			"_clazz" : "TwkSegment",
			"brick" : "FRONT",
			"from" : 1693,
			"face" : "front",
			"tags" : [
				"P17"
			],
			"type" : "panel",
			"to" : 1641,
			"number" : 23081
		},
		{
			"uuid" : "6e4d4bc2-16e0-3840-82ca-737901d47b8a",
			"name" : "23082",
			"_clazz" : "TwkSegment",
			"brick" : "FRONT",
			"from" : 1650,
			"face" : "front",
			"tags" : [
				"P17"
			],
			"type" : "panel",
			"to" : 1693,
			"number" : 23082
		},
		{
			"uuid" : "2bd50ad8-6a59-8443-8dc6-665c313a8fca",
			"name" : "23083",
			"_clazz" : "TwkSegment",
			"brick" : "FRONT",
			"from" : 1693,
			"face" : "front",
			"tags" : [
				"P17"
			],
			"type" : "panel",
			"to" : 1642,
			"number" : 23083
		},
		{
			"uuid" : "1e30b818-80ee-6442-b2ac-e2e3076b3400",
			"name" : "23084",
			"_clazz" : "TwkSegment",
			"brick" : "FRONT",
			"from" : 1649,
			"face" : "front",
			"tags" : [
				"P17"
			],
			"type" : "panel",
			"to" : 1693,
			"number" : 23084
		},
		{
			"uuid" : "2309adfc-b9b1-6040-84d0-0b49399669f7",
			"name" : "23085",
			"_clazz" : "TwkSegment",
			"brick" : "LEFT",
			"from" : 1694,
			"face" : "left",
			"tags" : [
				"P17"
			],
			"type" : "panel",
			"to" : 1642,
			"number" : 23085
		},
		{
			"uuid" : "79e420b6-4bca-8d49-aac2-9d244dbecb75",
			"name" : "23086",
			"_clazz" : "TwkSegment",
			"brick" : "LEFT",
			"from" : 1651,
			"face" : "left",
			"tags" : [
				"P17"
			],
			"type" : "panel",
			"to" : 1694,
			"number" : 23086
		},
		{
			"uuid" : "5fbf4f7c-3a07-0448-a8f6-19ea64f993c0",
			"name" : "23087",
			"_clazz" : "TwkSegment",
			"brick" : "LEFT",
			"from" : 1694,
			"face" : "left",
			"tags" : [
				"P17"
			],
			"type" : "panel",
			"to" : 1643,
			"number" : 23087
		},
		{
			"uuid" : "6133a020-c812-8f4f-b3f8-ade3cf6d1662",
			"name" : "23088",
			"_clazz" : "TwkSegment",
			"brick" : "LEFT",
			"from" : 1650,
			"face" : "left",
			"tags" : [
				"P17"
			],
			"type" : "panel",
			"to" : 1694,
			"number" : 23088
		},
		{
			"uuid" : "347ccfb4-ab18-cd46-af6d-3d07b53ca065",
			"name" : "23089",
			"_clazz" : "TwkSegment",
			"brick" : "BACK",
			"from" : 1695,
			"face" : "back",
			"tags" : [
				"P17"
			],
			"type" : "panel",
			"to" : 1643,
			"number" : 23089
		},
		{
			"uuid" : "48af758f-d04b-614c-b8d6-2524a4c4bc2a",
			"name" : "23090",
			"_clazz" : "TwkSegment",
			"brick" : "BACK",
			"from" : 1652,
			"face" : "back",
			"tags" : [
				"P17"
			],
			"type" : "panel",
			"to" : 1695,
			"number" : 23090
		},
		{
			"uuid" : "9507847c-b2e7-f340-86f7-acc0a56ed6d8",
			"name" : "23091",
			"_clazz" : "TwkSegment",
			"brick" : "BACK",
			"from" : 1695,
			"face" : "back",
			"tags" : [
				"P17"
			],
			"type" : "panel",
			"to" : 1644,
			"number" : 23091
		},
		{
			"uuid" : "1b41813c-dd05-fc45-8fe0-0af2b7513882",
			"name" : "23092",
			"_clazz" : "TwkSegment",
			"brick" : "BACK",
			"from" : 1651,
			"face" : "back",
			"tags" : [
				"P17"
			],
			"type" : "panel",
			"to" : 1695,
			"number" : 23092
		},
		{
			"uuid" : "1ef6298c-7e51-0546-bee3-ab93881988e5",
			"name" : "23093",
			"_clazz" : "TwkSegment",
			"brick" : "RIGHT",
			"from" : 1696,
			"face" : "right",
			"tags" : [
				"P17"
			],
			"type" : "panel",
			"to" : 1644,
			"number" : 23093
		},
		{
			"uuid" : "b55bd8a1-fc75-894b-9340-91428b547ded",
			"name" : "23094",
			"_clazz" : "TwkSegment",
			"brick" : "RIGHT",
			"from" : 1649,
			"face" : "right",
			"tags" : [
				"P17"
			],
			"type" : "panel",
			"to" : 1696,
			"number" : 23094
		},
		{
			"uuid" : "8ee305d9-fd25-7445-81fd-97a297183413",
			"name" : "23095",
			"_clazz" : "TwkSegment",
			"brick" : "RIGHT",
			"from" : 1696,
			"face" : "right",
			"tags" : [
				"P17"
			],
			"type" : "panel",
			"to" : 1641,
			"number" : 23095
		},
		{
			"uuid" : "963e71a9-e133-0740-81b0-e1739bb97a20",
			"name" : "23096",
			"_clazz" : "TwkSegment",
			"brick" : "RIGHT",
			"from" : 1652,
			"face" : "right",
			"tags" : [
				"P17"
			],
			"type" : "panel",
			"to" : 1696,
			"number" : 23096
		},
		{
			"uuid" : "1ba937dd-e3ed-494c-9965-2b6521c8d2e4",
			"name" : "23097",
			"_clazz" : "TwkSegment",
			"brick" : "FRONT",
			"from" : 1697,
			"face" : "front",
			"tags" : [
				"P17"
			],
			"type" : "panel",
			"to" : 1649,
			"number" : 23097
		},
		{
			"uuid" : "9b1abebe-2a71-f54b-9d9a-90f30a9d1b28",
			"name" : "23098",
			"_clazz" : "TwkSegment",
			"brick" : "FRONT",
			"from" : 1658,
			"face" : "front",
			"tags" : [
				"P17"
			],
			"type" : "panel",
			"to" : 1697,
			"number" : 23098
		},
		{
			"uuid" : "cf48ddfe-051e-be4f-9e6c-65b7bddff477",
			"name" : "23099",
			"_clazz" : "TwkSegment",
			"brick" : "FRONT",
			"from" : 1697,
			"face" : "front",
			"tags" : [
				"P17"
			],
			"type" : "panel",
			"to" : 1650,
			"number" : 23099
		},
		{
			"uuid" : "0acc44d7-1791-194f-9c96-6d613cd07a1a",
			"name" : "23100",
			"_clazz" : "TwkSegment",
			"brick" : "FRONT",
			"from" : 1657,
			"face" : "front",
			"tags" : [
				"P17"
			],
			"type" : "panel",
			"to" : 1697,
			"number" : 23100
		},
		{
			"uuid" : "ea58d8d8-1d12-084d-a4df-1c6338a4dfb8",
			"name" : "23101",
			"_clazz" : "TwkSegment",
			"brick" : "LEFT",
			"from" : 1698,
			"face" : "left",
			"tags" : [
				"P17"
			],
			"type" : "panel",
			"to" : 1650,
			"number" : 23101
		},
		{
			"uuid" : "5204a5fa-fcca-0d4b-8310-b32be5b413be",
			"name" : "23102",
			"_clazz" : "TwkSegment",
			"brick" : "LEFT",
			"from" : 1659,
			"face" : "left",
			"tags" : [
				"P17"
			],
			"type" : "panel",
			"to" : 1698,
			"number" : 23102
		},
		{
			"uuid" : "b3a8e39e-b18d-9546-aa3e-4c8dcf4106b6",
			"name" : "23103",
			"_clazz" : "TwkSegment",
			"brick" : "LEFT",
			"from" : 1698,
			"face" : "left",
			"tags" : [
				"P17"
			],
			"type" : "panel",
			"to" : 1651,
			"number" : 23103
		},
		{
			"uuid" : "65f36f27-0368-df49-9c02-a0168f44b920",
			"name" : "23104",
			"_clazz" : "TwkSegment",
			"brick" : "LEFT",
			"from" : 1658,
			"face" : "left",
			"tags" : [
				"P17"
			],
			"type" : "panel",
			"to" : 1698,
			"number" : 23104
		},
		{
			"uuid" : "984f89ba-ac71-9049-87d8-ecc88d2b5e37",
			"name" : "23105",
			"_clazz" : "TwkSegment",
			"brick" : "BACK",
			"from" : 1699,
			"face" : "back",
			"tags" : [
				"P17"
			],
			"type" : "panel",
			"to" : 1651,
			"number" : 23105
		},
		{
			"uuid" : "40f94d4f-7a85-8049-ba0e-146964798ef9",
			"name" : "23106",
			"_clazz" : "TwkSegment",
			"brick" : "BACK",
			"from" : 1660,
			"face" : "back",
			"tags" : [
				"P17"
			],
			"type" : "panel",
			"to" : 1699,
			"number" : 23106
		},
		{
			"uuid" : "d08c3fe3-0028-2b4b-86d6-ba5835e45de9",
			"name" : "23107",
			"_clazz" : "TwkSegment",
			"brick" : "BACK",
			"from" : 1699,
			"face" : "back",
			"tags" : [
				"P17"
			],
			"type" : "panel",
			"to" : 1652,
			"number" : 23107
		},
		{
			"uuid" : "096b4cd4-4aa9-f941-8b2a-f179faca2065",
			"name" : "23108",
			"_clazz" : "TwkSegment",
			"brick" : "BACK",
			"from" : 1659,
			"face" : "back",
			"tags" : [
				"P17"
			],
			"type" : "panel",
			"to" : 1699,
			"number" : 23108
		},
		{
			"uuid" : "8e2c6f6b-21dc-e14c-a4b6-768f8244579a",
			"name" : "23109",
			"_clazz" : "TwkSegment",
			"brick" : "RIGHT",
			"from" : 1700,
			"face" : "right",
			"tags" : [
				"P17"
			],
			"type" : "panel",
			"to" : 1652,
			"number" : 23109
		},
		{
			"uuid" : "7b8d6f05-48fb-2f4d-bd8f-5fa45d46ff75",
			"name" : "23110",
			"_clazz" : "TwkSegment",
			"brick" : "RIGHT",
			"from" : 1657,
			"face" : "right",
			"tags" : [
				"P17"
			],
			"type" : "panel",
			"to" : 1700,
			"number" : 23110
		},
		{
			"uuid" : "6016a408-6d6a-4343-af98-540453313a57",
			"name" : "23111",
			"_clazz" : "TwkSegment",
			"brick" : "RIGHT",
			"from" : 1700,
			"face" : "right",
			"tags" : [
				"P17"
			],
			"type" : "panel",
			"to" : 1649,
			"number" : 23111
		},
		{
			"uuid" : "6fc80010-c882-f541-bf91-105263f6392d",
			"name" : "23112",
			"_clazz" : "TwkSegment",
			"brick" : "RIGHT",
			"from" : 1660,
			"face" : "right",
			"tags" : [
				"P17"
			],
			"type" : "panel",
			"to" : 1700,
			"number" : 23112
		},
		{
			"uuid" : "a7dbb661-6889-f645-af22-7eb723fda0c5",
			"name" : "23113",
			"_clazz" : "TwkSegment",
			"brick" : "FRONT",
			"from" : 1701,
			"face" : "front",
			"tags" : [
				"P17"
			],
			"type" : "panel",
			"to" : 1657,
			"number" : 23113
		},
		{
			"uuid" : "3b110bbd-19c6-384e-8832-4453fa5ae326",
			"name" : "23114",
			"_clazz" : "TwkSegment",
			"brick" : "FRONT",
			"from" : 1666,
			"face" : "front",
			"tags" : [
				"P17"
			],
			"type" : "panel",
			"to" : 1701,
			"number" : 23114
		},
		{
			"uuid" : "8bf1fe1b-ce59-cd43-8325-221ceb8f0fe0",
			"name" : "23115",
			"_clazz" : "TwkSegment",
			"brick" : "FRONT",
			"from" : 1701,
			"face" : "front",
			"tags" : [
				"P17"
			],
			"type" : "panel",
			"to" : 1658,
			"number" : 23115
		},
		{
			"uuid" : "5827eaf0-6818-d645-af9a-b05b6c3d636c",
			"name" : "23116",
			"_clazz" : "TwkSegment",
			"brick" : "FRONT",
			"from" : 1665,
			"face" : "front",
			"tags" : [
				"P17"
			],
			"type" : "panel",
			"to" : 1701,
			"number" : 23116
		},
		{
			"uuid" : "d35e9000-723f-2f4d-beed-56fa7b2d0b1b",
			"name" : "23117",
			"_clazz" : "TwkSegment",
			"brick" : "LEFT",
			"from" : 1702,
			"face" : "left",
			"tags" : [
				"P17"
			],
			"type" : "panel",
			"to" : 1658,
			"number" : 23117
		},
		{
			"uuid" : "5e078b12-608b-9447-9982-ac4b5501b2bf",
			"name" : "23118",
			"_clazz" : "TwkSegment",
			"brick" : "LEFT",
			"from" : 1667,
			"face" : "left",
			"tags" : [
				"P17"
			],
			"type" : "panel",
			"to" : 1702,
			"number" : 23118
		},
		{
			"uuid" : "3d929333-15e7-db4b-aae2-e063107ca4ac",
			"name" : "23119",
			"_clazz" : "TwkSegment",
			"brick" : "LEFT",
			"from" : 1702,
			"face" : "left",
			"tags" : [
				"P17"
			],
			"type" : "panel",
			"to" : 1659,
			"number" : 23119
		},
		{
			"uuid" : "478b7010-6016-0c44-a9fa-e55b59bc5fbe",
			"name" : "23120",
			"_clazz" : "TwkSegment",
			"brick" : "LEFT",
			"from" : 1666,
			"face" : "left",
			"tags" : [
				"P17"
			],
			"type" : "panel",
			"to" : 1702,
			"number" : 23120
		},
		{
			"uuid" : "66af1042-ba7b-b345-8e5c-3788be894391",
			"name" : "23121",
			"_clazz" : "TwkSegment",
			"brick" : "BACK",
			"from" : 1703,
			"face" : "back",
			"tags" : [
				"P17"
			],
			"type" : "panel",
			"to" : 1659,
			"number" : 23121
		},
		{
			"uuid" : "3a4994f6-dfba-fc44-91a8-8445f2e28c52",
			"name" : "23122",
			"_clazz" : "TwkSegment",
			"brick" : "BACK",
			"from" : 1668,
			"face" : "back",
			"tags" : [
				"P17"
			],
			"type" : "panel",
			"to" : 1703,
			"number" : 23122
		},
		{
			"uuid" : "e1e51323-2e71-6343-91bd-ef24022cebfa",
			"name" : "23123",
			"_clazz" : "TwkSegment",
			"brick" : "BACK",
			"from" : 1703,
			"face" : "back",
			"tags" : [
				"P17"
			],
			"type" : "panel",
			"to" : 1660,
			"number" : 23123
		},
		{
			"uuid" : "f4eaefc6-965c-4441-b8c5-1ca2f47e8d34",
			"name" : "23124",
			"_clazz" : "TwkSegment",
			"brick" : "BACK",
			"from" : 1667,
			"face" : "back",
			"tags" : [
				"P17"
			],
			"type" : "panel",
			"to" : 1703,
			"number" : 23124
		},
		{
			"uuid" : "3959db3a-4b06-eb4f-9319-78e8e2f12381",
			"name" : "23125",
			"_clazz" : "TwkSegment",
			"brick" : "RIGHT",
			"from" : 1704,
			"face" : "right",
			"tags" : [
				"P17"
			],
			"type" : "panel",
			"to" : 1660,
			"number" : 23125
		},
		{
			"uuid" : "5fe357e4-9055-a54f-96ea-31c00414edc1",
			"name" : "23126",
			"_clazz" : "TwkSegment",
			"brick" : "RIGHT",
			"from" : 1665,
			"face" : "right",
			"tags" : [
				"P17"
			],
			"type" : "panel",
			"to" : 1704,
			"number" : 23126
		},
		{
			"uuid" : "8d5df526-dada-0d4c-8189-987c2813f442",
			"name" : "23127",
			"_clazz" : "TwkSegment",
			"brick" : "RIGHT",
			"from" : 1704,
			"face" : "right",
			"tags" : [
				"P17"
			],
			"type" : "panel",
			"to" : 1657,
			"number" : 23127
		},
		{
			"uuid" : "ee979d52-881a-9b47-bf9b-d9bfdbb67b6d",
			"name" : "23128",
			"_clazz" : "TwkSegment",
			"brick" : "RIGHT",
			"from" : 1668,
			"face" : "right",
			"tags" : [
				"P17"
			],
			"type" : "panel",
			"to" : 1704,
			"number" : 23128
		},
		{
			"uuid" : "ab27f61c-f878-ca46-8a45-4bb518c8d455",
			"name" : "23129",
			"_clazz" : "TwkSegment",
			"brick" : "FRONT",
			"from" : 1705,
			"face" : "front",
			"tags" : [
				"P17"
			],
			"type" : "panel",
			"to" : 1665,
			"number" : 23129
		},
		{
			"uuid" : "8637a843-3e27-f446-b457-0762c9d532ff",
			"name" : "23130",
			"_clazz" : "TwkSegment",
			"brick" : "FRONT",
			"from" : 1674,
			"face" : "front",
			"tags" : [
				"P17"
			],
			"type" : "panel",
			"to" : 1705,
			"number" : 23130
		},
		{
			"uuid" : "a15f4b3c-9f3c-2342-8ca9-6093e6b22afc",
			"name" : "23131",
			"_clazz" : "TwkSegment",
			"brick" : "FRONT",
			"from" : 1705,
			"face" : "front",
			"tags" : [
				"P17"
			],
			"type" : "panel",
			"to" : 1666,
			"number" : 23131
		},
		{
			"uuid" : "e525d83a-92c8-e740-b516-262ca2e20774",
			"name" : "23132",
			"_clazz" : "TwkSegment",
			"brick" : "FRONT",
			"from" : 1673,
			"face" : "front",
			"tags" : [
				"P17"
			],
			"type" : "panel",
			"to" : 1705,
			"number" : 23132
		},
		{
			"uuid" : "b66e864f-820f-9c44-b51b-66fdbd9de415",
			"name" : "23133",
			"_clazz" : "TwkSegment",
			"brick" : "LEFT",
			"from" : 1706,
			"face" : "left",
			"tags" : [
				"P17"
			],
			"type" : "panel",
			"to" : 1666,
			"number" : 23133
		},
		{
			"uuid" : "29f4738e-c310-a24e-9790-c2ec84a2cf0b",
			"name" : "23134",
			"_clazz" : "TwkSegment",
			"brick" : "LEFT",
			"from" : 1675,
			"face" : "left",
			"tags" : [
				"P17"
			],
			"type" : "panel",
			"to" : 1706,
			"number" : 23134
		},
		{
			"uuid" : "f0e29bee-9fd0-4b4f-b376-c80c9d1ee8f1",
			"name" : "23135",
			"_clazz" : "TwkSegment",
			"brick" : "LEFT",
			"from" : 1706,
			"face" : "left",
			"tags" : [
				"P17"
			],
			"type" : "panel",
			"to" : 1667,
			"number" : 23135
		},
		{
			"uuid" : "22f7bfc4-1010-fe43-9573-c7d5ff4579d7",
			"name" : "23136",
			"_clazz" : "TwkSegment",
			"brick" : "LEFT",
			"from" : 1674,
			"face" : "left",
			"tags" : [
				"P17"
			],
			"type" : "panel",
			"to" : 1706,
			"number" : 23136
		},
		{
			"uuid" : "052da6e7-98a0-6342-9289-52a1ee238edf",
			"name" : "23137",
			"_clazz" : "TwkSegment",
			"brick" : "BACK",
			"from" : 1707,
			"face" : "back",
			"tags" : [
				"P17"
			],
			"type" : "panel",
			"to" : 1667,
			"number" : 23137
		},
		{
			"uuid" : "bbe48bfb-fbc6-db48-95b8-af54097dcb42",
			"name" : "23138",
			"_clazz" : "TwkSegment",
			"brick" : "BACK",
			"from" : 1676,
			"face" : "back",
			"tags" : [
				"P17"
			],
			"type" : "panel",
			"to" : 1707,
			"number" : 23138
		},
		{
			"uuid" : "631cbe5a-6582-b047-bfdc-1084389a7d24",
			"name" : "23139",
			"_clazz" : "TwkSegment",
			"brick" : "BACK",
			"from" : 1707,
			"face" : "back",
			"tags" : [
				"P17"
			],
			"type" : "panel",
			"to" : 1668,
			"number" : 23139
		},
		{
			"uuid" : "a55b02fa-0646-c844-8937-e647163c5ea6",
			"name" : "23140",
			"_clazz" : "TwkSegment",
			"brick" : "BACK",
			"from" : 1675,
			"face" : "back",
			"tags" : [
				"P17"
			],
			"type" : "panel",
			"to" : 1707,
			"number" : 23140
		},
		{
			"uuid" : "3a2a5b8b-88a3-1f41-9bce-9e9ea0830881",
			"name" : "23141",
			"_clazz" : "TwkSegment",
			"brick" : "RIGHT",
			"from" : 1708,
			"face" : "right",
			"tags" : [
				"P17"
			],
			"type" : "panel",
			"to" : 1668,
			"number" : 23141
		},
		{
			"uuid" : "9ac6ef2c-45bb-cf42-a07a-a8bd29fdd70e",
			"name" : "23142",
			"_clazz" : "TwkSegment",
			"brick" : "RIGHT",
			"from" : 1673,
			"face" : "right",
			"tags" : [
				"P17"
			],
			"type" : "panel",
			"to" : 1708,
			"number" : 23142
		},
		{
			"uuid" : "838737a2-91e3-194a-b3dc-9ade676ace2e",
			"name" : "23143",
			"_clazz" : "TwkSegment",
			"brick" : "RIGHT",
			"from" : 1708,
			"face" : "right",
			"tags" : [
				"P17"
			],
			"type" : "panel",
			"to" : 1665,
			"number" : 23143
		},
		{
			"uuid" : "8ab646b8-1cd8-454b-9272-4435ee543949",
			"name" : "23144",
			"_clazz" : "TwkSegment",
			"brick" : "RIGHT",
			"from" : 1676,
			"face" : "right",
			"tags" : [
				"P17"
			],
			"type" : "panel",
			"to" : 1708,
			"number" : 23144
		},
		{
			"number" : 15001,
			"tags" : [
				"B13"
			],
			"type" : "slope",
			"to" : 1801,
			"from" : 1017,
			"brick" : "B13",
			"name" : "15001",
			"uuid" : "233377c2-90d3-b24c-813c-87bd1df19785",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 15002,
			"tags" : [
				"B13"
			],
			"type" : "slope",
			"to" : 1802,
			"from" : 1021,
			"brick" : "B13",
			"name" : "15002",
			"uuid" : "1b0e2c7f-0f7b-b54e-9aeb-c3c4b7049b34",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 15003,
			"tags" : [
				"B13"
			],
			"type" : "slope",
			"to" : 1803,
			"from" : 1024,
			"brick" : "B13",
			"name" : "15003",
			"uuid" : "772eb391-991d-4945-9d43-dc7c7278cbf9",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 15004,
			"tags" : [
				"B13"
			],
			"type" : "slope",
			"to" : 1804,
			"from" : 1020,
			"brick" : "B13",
			"name" : "15004",
			"uuid" : "d62f19e7-11b0-3f48-b672-67e0c86cbb5a",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 15005,
			"tags" : [
				"B13"
			],
			"type" : "slope",
			"to" : 1805,
			"from" : 1801,
			"brick" : "B13",
			"name" : "15005",
			"uuid" : "ac861a6f-ac21-4f43-bcd8-a7cbff2b46ba",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 15006,
			"tags" : [
				"B13"
			],
			"type" : "slope",
			"to" : 1806,
			"from" : 1802,
			"brick" : "B13",
			"name" : "15006",
			"uuid" : "f6234270-eccd-ee4a-9af0-d229293cb06c",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 15007,
			"tags" : [
				"B13"
			],
			"type" : "slope",
			"to" : 1807,
			"from" : 1803,
			"brick" : "B13",
			"name" : "15007",
			"uuid" : "5e65f12f-1b5e-fd49-8d8c-263dada54cbc",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 15008,
			"tags" : [
				"B13"
			],
			"type" : "slope",
			"to" : 1808,
			"from" : 1804,
			"brick" : "B13",
			"name" : "15008",
			"uuid" : "51416279-6c84-7d49-a638-abb2c4837ba6",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 15009,
			"tags" : [
				"B13"
			],
			"type" : "slope",
			"to" : 1809,
			"from" : 1805,
			"brick" : "B13",
			"name" : "15009",
			"uuid" : "3a738945-222a-b44b-bcd0-124f57c67680",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 15010,
			"tags" : [
				"B13"
			],
			"type" : "slope",
			"to" : 1810,
			"from" : 1806,
			"brick" : "B13",
			"name" : "15010",
			"uuid" : "38f6d5f1-b810-2241-bf0d-c95d9374fd51",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 15011,
			"tags" : [
				"B13"
			],
			"type" : "slope",
			"to" : 1811,
			"from" : 1807,
			"brick" : "B13",
			"name" : "15011",
			"uuid" : "5e023728-4552-7e4d-9cbd-fd15378d7a76",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 15012,
			"tags" : [
				"B13"
			],
			"type" : "slope",
			"to" : 1812,
			"from" : 1808,
			"brick" : "B13",
			"name" : "15012",
			"uuid" : "1fbbffa7-e69f-494b-b4c9-94cf170d3e68",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 15013,
			"tags" : [
				"B13"
			],
			"type" : "slope",
			"to" : 1813,
			"from" : 1809,
			"brick" : "B13",
			"name" : "15013",
			"uuid" : "0664bc50-ac26-d848-b61a-cc15581c63c7",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 15014,
			"tags" : [
				"B13"
			],
			"type" : "slope",
			"to" : 1814,
			"from" : 1810,
			"brick" : "B13",
			"name" : "15014",
			"uuid" : "97519271-2588-eb40-941b-e0f3bd4b1bef",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 15015,
			"tags" : [
				"B13"
			],
			"type" : "slope",
			"to" : 1815,
			"from" : 1811,
			"brick" : "B13",
			"name" : "15015",
			"uuid" : "75905ba4-8411-ca4b-bda4-80feef62ca61",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 15016,
			"tags" : [
				"B13"
			],
			"type" : "slope",
			"to" : 1816,
			"from" : 1812,
			"brick" : "B13",
			"name" : "15016",
			"uuid" : "03dc1dad-9420-0841-a534-d56e135e04ac",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 15017,
			"tags" : [
				"B13"
			],
			"type" : "slope",
			"to" : 1817,
			"from" : 1813,
			"brick" : "B13",
			"name" : "15017",
			"uuid" : "9c96f699-4885-dd4c-b10f-114be9ec1fd2",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 15018,
			"tags" : [
				"B13"
			],
			"type" : "slope",
			"to" : 1818,
			"from" : 1814,
			"brick" : "B13",
			"name" : "15018",
			"uuid" : "49a57617-83c9-2448-89e2-fca2473140ea",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 15019,
			"tags" : [
				"B13"
			],
			"type" : "slope",
			"to" : 1819,
			"from" : 1815,
			"brick" : "B13",
			"name" : "15019",
			"uuid" : "aaae2754-6676-694d-bf42-5b0b3727ad88",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 15020,
			"tags" : [
				"B13"
			],
			"type" : "slope",
			"to" : 1820,
			"from" : 1816,
			"brick" : "B13",
			"name" : "15020",
			"uuid" : "60f99abc-586b-fb40-928d-fee9f48b07dd",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 15021,
			"tags" : [
				"B13"
			],
			"type" : "slope",
			"to" : 1821,
			"from" : 1817,
			"brick" : "B13",
			"name" : "15021",
			"uuid" : "c3abca00-e387-664c-945f-9e60c2cc02e6",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 15022,
			"tags" : [
				"B13"
			],
			"type" : "slope",
			"to" : 1822,
			"from" : 1818,
			"brick" : "B13",
			"name" : "15022",
			"uuid" : "9d1eb1fd-340c-6444-a176-9d8b600739f5",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 15023,
			"tags" : [
				"B13"
			],
			"type" : "slope",
			"to" : 1823,
			"from" : 1819,
			"brick" : "B13",
			"name" : "15023",
			"uuid" : "ab95d69e-b3fa-6245-a107-a93a1ae5b215",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 15024,
			"tags" : [
				"B13"
			],
			"type" : "slope",
			"to" : 1824,
			"from" : 1820,
			"brick" : "B13",
			"name" : "15024",
			"uuid" : "63254410-667b-c440-8b20-a001cecfca10",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 15025,
			"tags" : [
				"B13"
			],
			"type" : "slope",
			"to" : 1825,
			"from" : 1821,
			"brick" : "B13",
			"name" : "15025",
			"uuid" : "478d5d23-ed76-a848-a1f4-94a82983861e",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 15026,
			"tags" : [
				"B13"
			],
			"type" : "slope",
			"to" : 1826,
			"from" : 1822,
			"brick" : "B13",
			"name" : "15026",
			"uuid" : "84baaf27-706e-7441-aff1-c93a9573cbff",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 15027,
			"tags" : [
				"B13"
			],
			"type" : "slope",
			"to" : 1827,
			"from" : 1823,
			"brick" : "B13",
			"name" : "15027",
			"uuid" : "af9c45a9-269f-604d-95b0-588fd0acefc1",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 15028,
			"tags" : [
				"B13"
			],
			"type" : "slope",
			"to" : 1828,
			"from" : 1824,
			"brick" : "B13",
			"name" : "15028",
			"uuid" : "1e736f5e-453e-094f-86af-6d772ad3f2a6",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 15029,
			"tags" : [
				"B13"
			],
			"type" : "slope",
			"to" : 1829,
			"from" : 1825,
			"brick" : "B13",
			"name" : "15029",
			"uuid" : "89c4b216-bda6-1445-9700-aec841edf67d",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 15030,
			"tags" : [
				"B13"
			],
			"type" : "slope",
			"to" : 1830,
			"from" : 1826,
			"brick" : "B13",
			"name" : "15030",
			"uuid" : "ff1d84ad-619a-f44f-8832-0fad12f3576b",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 15031,
			"tags" : [
				"B13"
			],
			"type" : "slope",
			"to" : 1831,
			"from" : 1827,
			"brick" : "B13",
			"name" : "15031",
			"uuid" : "38048e51-6fd5-684a-88b6-3aa5490f52fb",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 15032,
			"tags" : [
				"B13"
			],
			"type" : "slope",
			"to" : 1832,
			"from" : 1828,
			"brick" : "B13",
			"name" : "15032",
			"uuid" : "4543d94e-98cd-0e44-ae7a-6b1199ec9daf",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 15033,
			"tags" : [
				"B13"
			],
			"type" : "slope",
			"to" : 1833,
			"from" : 1829,
			"brick" : "B13",
			"name" : "15033",
			"uuid" : "25cc190d-97ee-6845-a88f-2f687de4b392",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 15034,
			"tags" : [
				"B13"
			],
			"type" : "slope",
			"to" : 1834,
			"from" : 1830,
			"brick" : "B13",
			"name" : "15034",
			"uuid" : "20343499-d14f-ca47-988c-4fdc30e4d9d3",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 15035,
			"tags" : [
				"B13"
			],
			"type" : "slope",
			"to" : 1835,
			"from" : 1831,
			"brick" : "B13",
			"name" : "15035",
			"uuid" : "a758ddd5-1f14-2547-842d-434d899dc988",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 15036,
			"tags" : [
				"B13"
			],
			"type" : "slope",
			"to" : 1836,
			"from" : 1832,
			"brick" : "B13",
			"name" : "15036",
			"uuid" : "8f637e8c-5410-2848-8e3b-b07490549b54",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 15037,
			"tags" : [
				"B13"
			],
			"type" : "slope",
			"to" : 1837,
			"from" : 1833,
			"brick" : "B13",
			"name" : "15037",
			"uuid" : "f1258c76-48de-6e49-b9f2-7044602859af",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 15038,
			"tags" : [
				"B13"
			],
			"type" : "slope",
			"to" : 1838,
			"from" : 1834,
			"brick" : "B13",
			"name" : "15038",
			"uuid" : "40072fc5-d541-d349-9239-25441e069ea9",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 15039,
			"tags" : [
				"B13"
			],
			"type" : "slope",
			"to" : 1839,
			"from" : 1835,
			"brick" : "B13",
			"name" : "15039",
			"uuid" : "3a4df568-d8f3-6f4e-bdb3-b2256e32af35",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 15040,
			"tags" : [
				"B13"
			],
			"type" : "slope",
			"to" : 1840,
			"from" : 1836,
			"brick" : "B13",
			"name" : "15040",
			"uuid" : "0da3bb11-2bb8-d742-914a-dd71dc372789",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 15041,
			"tags" : [
				"B13"
			],
			"type" : "slope",
			"to" : 1841,
			"from" : 1837,
			"brick" : "B13",
			"name" : "15041",
			"uuid" : "321bfad9-38fc-704c-a7b1-0416563f7d4a",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 15042,
			"tags" : [
				"B13"
			],
			"type" : "slope",
			"to" : 1842,
			"from" : 1838,
			"brick" : "B13",
			"name" : "15042",
			"uuid" : "adc76161-ec55-5a48-ba09-9fa1a70e456b",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 15043,
			"tags" : [
				"B13"
			],
			"type" : "slope",
			"to" : 1843,
			"from" : 1839,
			"brick" : "B13",
			"name" : "15043",
			"uuid" : "9ff9e1f6-c19e-f149-98db-415e427051bb",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 15044,
			"tags" : [
				"B13"
			],
			"type" : "slope",
			"to" : 1844,
			"from" : 1840,
			"brick" : "B13",
			"name" : "15044",
			"uuid" : "30c0f2df-8591-924f-9c5e-63905181a84f",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 15045,
			"tags" : [
				"B13"
			],
			"type" : "slope",
			"to" : 1845,
			"from" : 1841,
			"brick" : "B13",
			"name" : "15045",
			"uuid" : "ac6fffef-c1da-d64d-9712-f59d975dcca9",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 15046,
			"tags" : [
				"B13"
			],
			"type" : "slope",
			"to" : 1846,
			"from" : 1842,
			"brick" : "B13",
			"name" : "15046",
			"uuid" : "f0aa9fab-5718-344e-a33a-4671620f9e29",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 15047,
			"tags" : [
				"B13"
			],
			"type" : "slope",
			"to" : 1847,
			"from" : 1843,
			"brick" : "B13",
			"name" : "15047",
			"uuid" : "1ee719af-6d1e-3b49-b7a2-d0d7c79b25b4",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 15048,
			"tags" : [
				"B13"
			],
			"type" : "slope",
			"to" : 1848,
			"from" : 1844,
			"brick" : "B13",
			"name" : "15048",
			"uuid" : "c8006190-79d7-e049-8504-1c0ba3357744",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 15049,
			"tags" : [
				"B13"
			],
			"type" : "slope",
			"to" : 1849,
			"from" : 1845,
			"brick" : "B13",
			"name" : "15049",
			"uuid" : "e49372ca-4a7e-4a46-8f6e-a9e8f63c7353",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 15050,
			"tags" : [
				"B13"
			],
			"type" : "slope",
			"to" : 1850,
			"from" : 1846,
			"brick" : "B13",
			"name" : "15050",
			"uuid" : "26d3fa2a-99f2-eb42-90b8-bfdf1b6251f9",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 15051,
			"tags" : [
				"B13"
			],
			"type" : "slope",
			"to" : 1851,
			"from" : 1847,
			"brick" : "B13",
			"name" : "15051",
			"uuid" : "5da33db7-6610-6345-961d-ad75aa2f1ff4",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 15052,
			"tags" : [
				"B13"
			],
			"type" : "slope",
			"to" : 1852,
			"from" : 1848,
			"brick" : "B13",
			"name" : "15052",
			"uuid" : "d023822b-a93f-fb48-b4ea-609c64355be9",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 15053,
			"tags" : [
				"B13"
			],
			"type" : "slope",
			"to" : 1202,
			"from" : 1849,
			"brick" : "B13",
			"name" : "15053",
			"uuid" : "79b3c2b1-08fb-4e41-9122-f2e5be2b0625",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 15054,
			"tags" : [
				"B13"
			],
			"type" : "slope",
			"to" : 1206,
			"from" : 1850,
			"brick" : "B13",
			"name" : "15054",
			"uuid" : "3c356ba4-996b-764a-88da-0f7d9f3d7b5f",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 15055,
			"tags" : [
				"B13"
			],
			"type" : "slope",
			"to" : 1207,
			"from" : 1851,
			"brick" : "B13",
			"name" : "15055",
			"uuid" : "603e17ca-a038-e94b-9ecf-4354a8143bc1",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 15056,
			"tags" : [
				"B13"
			],
			"type" : "slope",
			"to" : 1203,
			"from" : 1852,
			"brick" : "B13",
			"name" : "15056",
			"uuid" : "7c366cee-24c8-774a-a196-a9d90c064ffb",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 33001,
			"tags" : [
				"B13"
			],
			"type" : "sectionRound",
			"to" : 1802,
			"from" : 1801,
			"brick" : "B13",
			"name" : "33001",
			"uuid" : "fa34e385-32ee-1a42-9824-1ff2c75b874b",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 33002,
			"tags" : [
				"B13"
			],
			"type" : "sectionRound",
			"to" : 1803,
			"from" : 1802,
			"brick" : "B13",
			"name" : "33002",
			"uuid" : "83ee25d0-902f-044a-bb6f-e72bd45a9dbe",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 33003,
			"tags" : [
				"B13"
			],
			"type" : "sectionRound",
			"to" : 1804,
			"from" : 1803,
			"brick" : "B13",
			"name" : "33003",
			"uuid" : "3b6122f1-a84a-4a47-838e-8062070262ed",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 33004,
			"tags" : [
				"B13"
			],
			"type" : "sectionRound",
			"to" : 1801,
			"from" : 1804,
			"brick" : "B13",
			"name" : "33004",
			"uuid" : "10dd0f8e-6a0f-364c-afd0-c2cf6d7d2755",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 33005,
			"tags" : [
				"B13"
			],
			"type" : "sectionRound",
			"to" : 1806,
			"from" : 1805,
			"brick" : "B13",
			"name" : "33005",
			"uuid" : "b76ff52d-2018-0a46-bf83-7a2369430625",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 33006,
			"tags" : [
				"B13"
			],
			"type" : "sectionRound",
			"to" : 1807,
			"from" : 1806,
			"brick" : "B13",
			"name" : "33006",
			"uuid" : "effd0cf2-e80b-6a40-b3f4-3f8912a8346e",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 33007,
			"tags" : [
				"B13"
			],
			"type" : "sectionRound",
			"to" : 1808,
			"from" : 1807,
			"brick" : "B13",
			"name" : "33007",
			"uuid" : "326e97d9-fb2e-cb47-97e1-617d3089bd8c",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 33008,
			"tags" : [
				"B13"
			],
			"type" : "sectionRound",
			"to" : 1805,
			"from" : 1808,
			"brick" : "B13",
			"name" : "33008",
			"uuid" : "30e3041f-e8d8-1243-baac-77ee19d7486a",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 33009,
			"tags" : [
				"B13"
			],
			"type" : "sectionRound",
			"to" : 1810,
			"from" : 1809,
			"brick" : "B13",
			"name" : "33009",
			"uuid" : "a1fa08af-474f-5c4e-89f2-8ee0c0d53201",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 33010,
			"tags" : [
				"B13"
			],
			"type" : "sectionRound",
			"to" : 1853,
			"from" : 1810,
			"brick" : "B13",
			"name" : "33010",
			"uuid" : "2e1a4be8-1ef7-a64f-a04c-d6111fa5e694",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 33011,
			"tags" : [
				"B13"
			],
			"type" : "sectionRound",
			"to" : 1811,
			"from" : 1853,
			"brick" : "B13",
			"name" : "33011",
			"uuid" : "c458bcd7-6141-3841-9c59-b7f317267277",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 33012,
			"tags" : [
				"B13"
			],
			"type" : "sectionRound",
			"to" : 1812,
			"from" : 1811,
			"brick" : "B13",
			"name" : "33012",
			"uuid" : "ddd0048f-54fb-bd4e-93a2-04de1807eb03",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 33013,
			"tags" : [
				"B13"
			],
			"type" : "sectionRound",
			"to" : 1854,
			"from" : 1812,
			"brick" : "B13",
			"name" : "33013",
			"uuid" : "0d492de6-7f0f-904c-92fe-23fb1518eae4",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 33014,
			"tags" : [
				"B13"
			],
			"type" : "sectionRound",
			"to" : 1809,
			"from" : 1854,
			"brick" : "B13",
			"name" : "33014",
			"uuid" : "ddfe15eb-1dcc-b44b-b99e-32f99d25217d",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 33015,
			"tags" : [
				"B13"
			],
			"type" : "sectionRound",
			"to" : 1814,
			"from" : 1813,
			"brick" : "B13",
			"name" : "33015",
			"uuid" : "41090887-5457-3c4a-907f-ceb51b4d13e7",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 33016,
			"tags" : [
				"B13"
			],
			"type" : "sectionRound",
			"to" : 1815,
			"from" : 1814,
			"brick" : "B13",
			"name" : "33016",
			"uuid" : "ab3aabda-6482-bf4d-bca7-301200d72cad",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 33017,
			"tags" : [
				"B13"
			],
			"type" : "sectionRound",
			"to" : 1816,
			"from" : 1815,
			"brick" : "B13",
			"name" : "33017",
			"uuid" : "35d0ab6d-1d0f-a14a-8cd4-0068c1165e78",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 33018,
			"tags" : [
				"B13"
			],
			"type" : "sectionRound",
			"to" : 1813,
			"from" : 1816,
			"brick" : "B13",
			"name" : "33018",
			"uuid" : "8d2033cd-865f-ef45-867a-e2237d5e0fb0",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 33019,
			"tags" : [
				"B13"
			],
			"type" : "sectionRound",
			"to" : 1818,
			"from" : 1817,
			"brick" : "B13",
			"name" : "33019",
			"uuid" : "07a7e0d2-ba79-ec42-ae97-64baf8e1bd29",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 33020,
			"tags" : [
				"B13"
			],
			"type" : "sectionRound",
			"to" : 1819,
			"from" : 1818,
			"brick" : "B13",
			"name" : "33020",
			"uuid" : "c9076051-e198-8442-950f-50a9e1f2176e",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 33021,
			"tags" : [
				"B13"
			],
			"type" : "sectionRound",
			"to" : 1820,
			"from" : 1819,
			"brick" : "B13",
			"name" : "33021",
			"uuid" : "8b80cf32-af32-4844-9f36-fdef7ebf3485",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 33022,
			"tags" : [
				"B13"
			],
			"type" : "sectionRound",
			"to" : 1817,
			"from" : 1820,
			"brick" : "B13",
			"name" : "33022",
			"uuid" : "96310b5b-b926-1d47-9f6f-b37aa9abebb0",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 33023,
			"tags" : [
				"B13"
			],
			"type" : "sectionRound",
			"to" : 1822,
			"from" : 1821,
			"brick" : "B13",
			"name" : "33023",
			"uuid" : "18d42d04-557c-8f42-917e-322d8949e79d",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 33024,
			"tags" : [
				"B13"
			],
			"type" : "sectionRound",
			"to" : 1823,
			"from" : 1822,
			"brick" : "B13",
			"name" : "33024",
			"uuid" : "3e379950-64ef-024d-b33a-3ea699b4148d",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 33025,
			"tags" : [
				"B13"
			],
			"type" : "sectionRound",
			"to" : 1824,
			"from" : 1823,
			"brick" : "B13",
			"name" : "33025",
			"uuid" : "137511eb-f421-b741-aa7c-1ff774646e64",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 33026,
			"tags" : [
				"B13"
			],
			"type" : "sectionRound",
			"to" : 1821,
			"from" : 1824,
			"brick" : "B13",
			"name" : "33026",
			"uuid" : "32e7e1c8-ab59-c04b-88e6-8d862bec0c45",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 33027,
			"tags" : [
				"B13"
			],
			"type" : "sectionRound",
			"to" : 1826,
			"from" : 1825,
			"brick" : "B13",
			"name" : "33027",
			"uuid" : "58caf7a0-9aff-f949-81e7-982a17d1ee56",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 33028,
			"tags" : [
				"B13"
			],
			"type" : "sectionRound",
			"to" : 1855,
			"from" : 1826,
			"brick" : "B13",
			"name" : "33028",
			"uuid" : "df1273b5-30fd-e249-97b2-8ec5d6fc4dfe",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 33029,
			"tags" : [
				"B13"
			],
			"type" : "sectionRound",
			"to" : 1827,
			"from" : 1855,
			"brick" : "B13",
			"name" : "33029",
			"uuid" : "9713d11e-d967-f443-b80f-c026e30fd9b0",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 33030,
			"tags" : [
				"B13"
			],
			"type" : "sectionRound",
			"to" : 1828,
			"from" : 1827,
			"brick" : "B13",
			"name" : "33030",
			"uuid" : "bb5306d5-2c0b-db43-a09b-a2fb1c2960bb",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 33031,
			"tags" : [
				"B13"
			],
			"type" : "sectionRound",
			"to" : 1856,
			"from" : 1828,
			"brick" : "B13",
			"name" : "33031",
			"uuid" : "5bbdf566-2076-fd42-b815-5ca8c262604d",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 33032,
			"tags" : [
				"B13"
			],
			"type" : "sectionRound",
			"to" : 1825,
			"from" : 1856,
			"brick" : "B13",
			"name" : "33032",
			"uuid" : "d3ae68cf-5ead-ec4a-a400-bdb0a76bceb3",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 33033,
			"tags" : [
				"B13"
			],
			"type" : "sectionRound",
			"to" : 1830,
			"from" : 1829,
			"brick" : "B13",
			"name" : "33033",
			"uuid" : "b3e3f633-3256-3d4c-95de-59189a06543e",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 33034,
			"tags" : [
				"B13"
			],
			"type" : "sectionRound",
			"to" : 1831,
			"from" : 1830,
			"brick" : "B13",
			"name" : "33034",
			"uuid" : "9ab0d8f0-7d94-594a-8ca2-df5fd956471b",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 33035,
			"tags" : [
				"B13"
			],
			"type" : "sectionRound",
			"to" : 1832,
			"from" : 1831,
			"brick" : "B13",
			"name" : "33035",
			"uuid" : "53abd1bb-8ec7-9b42-a398-86f82c179377",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 33036,
			"tags" : [
				"B13"
			],
			"type" : "sectionRound",
			"to" : 1829,
			"from" : 1832,
			"brick" : "B13",
			"name" : "33036",
			"uuid" : "8bcfa514-1de2-6b40-90f5-52b16744f955",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 33037,
			"tags" : [
				"B13"
			],
			"type" : "sectionRound",
			"to" : 1834,
			"from" : 1833,
			"brick" : "B13",
			"name" : "33037",
			"uuid" : "1262cedf-926c-634c-b1c7-1bb0512bc5ae",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 33038,
			"tags" : [
				"B13"
			],
			"type" : "sectionRound",
			"to" : 1835,
			"from" : 1834,
			"brick" : "B13",
			"name" : "33038",
			"uuid" : "16a26308-bc0f-a048-9581-e4a4831e625e",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 33039,
			"tags" : [
				"B13"
			],
			"type" : "sectionRound",
			"to" : 1836,
			"from" : 1835,
			"brick" : "B13",
			"name" : "33039",
			"uuid" : "db5c2301-4e6f-2249-b563-a593ec4e1f8c",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 33040,
			"tags" : [
				"B13"
			],
			"type" : "sectionRound",
			"to" : 1833,
			"from" : 1836,
			"brick" : "B13",
			"name" : "33040",
			"uuid" : "7ef05390-d5ab-3043-9a2d-ddbd08f078d8",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 33041,
			"tags" : [
				"B13"
			],
			"type" : "sectionRound",
			"to" : 1838,
			"from" : 1837,
			"brick" : "B13",
			"name" : "33041",
			"uuid" : "596a39a2-9d15-0a40-89e1-d1432f3bfcd5",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 33042,
			"tags" : [
				"B13"
			],
			"type" : "sectionRound",
			"to" : 1839,
			"from" : 1838,
			"brick" : "B13",
			"name" : "33042",
			"uuid" : "28dad46b-266b-3349-9681-dc1cb27b8ad0",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 33043,
			"tags" : [
				"B13"
			],
			"type" : "sectionRound",
			"to" : 1840,
			"from" : 1839,
			"brick" : "B13",
			"name" : "33043",
			"uuid" : "5dc14911-7746-e348-aeac-f8db2983cdec",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 33044,
			"tags" : [
				"B13"
			],
			"type" : "sectionRound",
			"to" : 1837,
			"from" : 1840,
			"brick" : "B13",
			"name" : "33044",
			"uuid" : "ca358963-72e7-c641-bb6e-122a3e1022cf",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 33045,
			"tags" : [
				"B13"
			],
			"type" : "sectionRound",
			"to" : 1842,
			"from" : 1841,
			"brick" : "B13",
			"name" : "33045",
			"uuid" : "f7e3870e-50c4-3048-a087-da10d432ec5a",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 33046,
			"tags" : [
				"B13"
			],
			"type" : "sectionRound",
			"to" : 1857,
			"from" : 1842,
			"brick" : "B13",
			"name" : "33046",
			"uuid" : "e2a31775-a472-6445-b826-c32ff7f7f75c",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 33047,
			"tags" : [
				"B13"
			],
			"type" : "sectionRound",
			"to" : 1843,
			"from" : 1857,
			"brick" : "B13",
			"name" : "33047",
			"uuid" : "9d15cefd-2fa8-db4a-b9d3-b5a4f835188f",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 33048,
			"tags" : [
				"B13"
			],
			"type" : "sectionRound",
			"to" : 1844,
			"from" : 1843,
			"brick" : "B13",
			"name" : "33048",
			"uuid" : "6c71867e-3617-ff48-b6f8-3fc9252c69f5",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 33049,
			"tags" : [
				"B13"
			],
			"type" : "sectionRound",
			"to" : 1858,
			"from" : 1844,
			"brick" : "B13",
			"name" : "33049",
			"uuid" : "ff7487f2-ce11-6b48-a7d2-0ac9b424d8b6",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 33050,
			"tags" : [
				"B13"
			],
			"type" : "sectionRound",
			"to" : 1841,
			"from" : 1858,
			"brick" : "B13",
			"name" : "33050",
			"uuid" : "9a7f08cb-cc98-4c47-8134-d4e399966bc5",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 33051,
			"tags" : [
				"B13"
			],
			"type" : "sectionRound",
			"to" : 1846,
			"from" : 1845,
			"brick" : "B13",
			"name" : "33051",
			"uuid" : "4216ec49-f22b-d241-9e00-731e8aa41f2a",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 33052,
			"tags" : [
				"B13"
			],
			"type" : "sectionRound",
			"to" : 1847,
			"from" : 1846,
			"brick" : "B13",
			"name" : "33052",
			"uuid" : "7ebd62fa-f420-0343-a1fe-ceceb4bebd47",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 33053,
			"tags" : [
				"B13"
			],
			"type" : "sectionRound",
			"to" : 1848,
			"from" : 1847,
			"brick" : "B13",
			"name" : "33053",
			"uuid" : "134ddcca-e7b6-2944-b841-d709427f038b",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 33054,
			"tags" : [
				"B13"
			],
			"type" : "sectionRound",
			"to" : 1845,
			"from" : 1848,
			"brick" : "B13",
			"name" : "33054",
			"uuid" : "078a70ce-8d1a-d644-a935-9cee19c47b36",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 33055,
			"tags" : [
				"B13"
			],
			"type" : "sectionRound",
			"to" : 1850,
			"from" : 1849,
			"brick" : "B13",
			"name" : "33055",
			"uuid" : "39466808-70e6-8642-9829-4c89cda58292",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 33056,
			"tags" : [
				"B13"
			],
			"type" : "sectionRound",
			"to" : 1851,
			"from" : 1850,
			"brick" : "B13",
			"name" : "33056",
			"uuid" : "5561d351-432f-514b-859b-8221cd7bba92",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 33057,
			"tags" : [
				"B13"
			],
			"type" : "sectionRound",
			"to" : 1852,
			"from" : 1851,
			"brick" : "B13",
			"name" : "33057",
			"uuid" : "1b89f9b9-f395-504e-8acc-5a23d5b1032a",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 33058,
			"tags" : [
				"B13"
			],
			"type" : "sectionRound",
			"to" : 1849,
			"from" : 1852,
			"brick" : "B13",
			"name" : "33058",
			"uuid" : "56a51531-f682-744d-bdaf-90c7d737a1fc",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 33101,
			"tags" : [
				"B13"
			],
			"type" : "sectionSlant",
			"to" : 1805,
			"from" : 2701,
			"brick" : "B13",
			"name" : "33101",
			"uuid" : "c8fab34a-85ea-2341-b035-476b73ba4b54",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 33102,
			"tags" : [
				"B13"
			],
			"type" : "sectionSlant",
			"to" : 2701,
			"from" : 1807,
			"brick" : "B13",
			"name" : "33102",
			"uuid" : "2e10241e-10bc-d141-ac34-7197712dd39e",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 33103,
			"tags" : [
				"B13"
			],
			"type" : "sectionSlant",
			"to" : 1808,
			"from" : 2701,
			"brick" : "B13",
			"name" : "33103",
			"uuid" : "66ee927d-0397-8e42-8af6-9f4c21fe2612",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 33104,
			"tags" : [
				"B13"
			],
			"type" : "sectionSlant",
			"to" : 2701,
			"from" : 1806,
			"brick" : "B13",
			"name" : "33104",
			"uuid" : "be6da351-d5c8-934a-bbe0-183fa24ed1c4",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 33105,
			"tags" : [
				"B13"
			],
			"type" : "sectionSlant",
			"to" : 1809,
			"from" : 2702,
			"brick" : "B13",
			"name" : "33105",
			"uuid" : "8060c767-70a5-6849-8bc6-c9a0da5a09ce",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 33106,
			"tags" : [
				"B13"
			],
			"type" : "sectionSlant",
			"to" : 2702,
			"from" : 1811,
			"brick" : "B13",
			"name" : "33106",
			"uuid" : "9e90a771-a44d-7e43-a5e7-864d1245047f",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 33107,
			"tags" : [
				"B13"
			],
			"type" : "sectionSlant",
			"to" : 1812,
			"from" : 2702,
			"brick" : "B13",
			"name" : "33107",
			"uuid" : "fc1eab5c-1f1d-a24c-9810-eb0a03c66747",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 33108,
			"tags" : [
				"B13"
			],
			"type" : "sectionSlant",
			"to" : 2702,
			"from" : 1810,
			"brick" : "B13",
			"name" : "33108",
			"uuid" : "5318e7cd-8b70-1f4c-a778-4f0e8bcb3dc3",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 33109,
			"tags" : [
				"B13"
			],
			"type" : "sectionSlant",
			"to" : 1825,
			"from" : 2703,
			"brick" : "B13",
			"name" : "33109",
			"uuid" : "4cce8a26-5fb1-6749-9e94-12d585e0eb5f",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 33110,
			"tags" : [
				"B13"
			],
			"type" : "sectionSlant",
			"to" : 2703,
			"from" : 1827,
			"brick" : "B13",
			"name" : "33110",
			"uuid" : "e71489cd-833c-d946-8251-32a98ba9e5c0",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 33111,
			"tags" : [
				"B13"
			],
			"type" : "sectionSlant",
			"to" : 1828,
			"from" : 2703,
			"brick" : "B13",
			"name" : "33111",
			"uuid" : "8a9c4678-3e82-8f4d-89f7-bd27397861aa",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 33112,
			"tags" : [
				"B13"
			],
			"type" : "sectionSlant",
			"to" : 2703,
			"from" : 1826,
			"brick" : "B13",
			"name" : "33112",
			"uuid" : "b3e29a40-a496-8447-994c-4f4c0b7b8b01",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 33113,
			"tags" : [
				"B13"
			],
			"type" : "sectionSlant",
			"to" : 1841,
			"from" : 2704,
			"brick" : "B13",
			"name" : "33113",
			"uuid" : "2f57192f-ec94-f644-b8cd-ed7cd63e0b3d",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 33114,
			"tags" : [
				"B13"
			],
			"type" : "sectionSlant",
			"to" : 2704,
			"from" : 1843,
			"brick" : "B13",
			"name" : "33114",
			"uuid" : "0c0d409e-92d7-2941-82e0-33e3ef44209e",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 33115,
			"tags" : [
				"B13"
			],
			"type" : "sectionSlant",
			"to" : 1844,
			"from" : 2704,
			"brick" : "B13",
			"name" : "33115",
			"uuid" : "568485d2-5ef9-9c44-81af-b6c90161bcad",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 33116,
			"tags" : [
				"B13"
			],
			"type" : "sectionSlant",
			"to" : 2704,
			"from" : 1842,
			"brick" : "B13",
			"name" : "33116",
			"uuid" : "19ad1f13-b526-674e-b2ce-ceb42cb95432",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 33117,
			"tags" : [
				"B13"
			],
			"type" : "sectionSlant",
			"to" : 1845,
			"from" : 2705,
			"brick" : "B13",
			"name" : "33117",
			"uuid" : "137a4c21-0c00-fd44-b83e-75fbdae351ed",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 33118,
			"tags" : [
				"B13"
			],
			"type" : "sectionSlant",
			"to" : 2705,
			"from" : 1847,
			"brick" : "B13",
			"name" : "33118",
			"uuid" : "ea34c425-433d-6a48-bfa7-b1b7dbbac83c",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 33119,
			"tags" : [
				"B13"
			],
			"type" : "sectionSlant",
			"to" : 1848,
			"from" : 2705,
			"brick" : "B13",
			"name" : "33119",
			"uuid" : "fc40aed2-37e7-fe48-9fb1-8f6350af67fe",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 33120,
			"tags" : [
				"B13"
			],
			"type" : "sectionSlant",
			"to" : 2705,
			"from" : 1846,
			"brick" : "B13",
			"name" : "33120",
			"uuid" : "cbda5a2c-55b8-b94f-8ec8-2889a04e1536",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 33121,
			"tags" : [
				"B13"
			],
			"type" : "sectionVertical",
			"to" : 1854,
			"from" : 2702,
			"brick" : "B13",
			"name" : "33121",
			"uuid" : "8a9beeb4-ee9c-bd44-baf3-0334a49c776f",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 33122,
			"tags" : [
				"B13"
			],
			"type" : "sectionVertical",
			"to" : 2702,
			"from" : 1853,
			"brick" : "B13",
			"name" : "33122",
			"uuid" : "b8510e41-1751-fc4c-9b1f-57ef8e0d672f",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 33123,
			"tags" : [
				"B13"
			],
			"type" : "sectionVertical",
			"to" : 1856,
			"from" : 2703,
			"brick" : "B13",
			"name" : "33123",
			"uuid" : "a71207b4-660c-b24d-9976-72a193ff4d6c",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 33124,
			"tags" : [
				"B13"
			],
			"type" : "sectionVertical",
			"to" : 2703,
			"from" : 1855,
			"brick" : "B13",
			"name" : "33124",
			"uuid" : "2293c38a-61ec-4c47-b831-4ad0f876c0a2",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 33125,
			"tags" : [
				"B13"
			],
			"type" : "sectionVertical",
			"to" : 1858,
			"from" : 2704,
			"brick" : "B13",
			"name" : "33125",
			"uuid" : "6f5a6744-616d-7741-9b52-2d8e42a60f5f",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 33126,
			"tags" : [
				"B13"
			],
			"type" : "sectionVertical",
			"to" : 2704,
			"from" : 1857,
			"brick" : "B13",
			"name" : "33126",
			"uuid" : "3d248768-0690-7440-a6fc-9abfe6241f0c",
			"_clazz" : "TwkSegment"
		},
		{
			"uuid" : "9003243a-375d-8b4e-b2b6-eaccac23f56b",
			"name" : "24001",
			"_clazz" : "TwkSegment",
			"brick" : "FRONT",
			"from" : 1017,
			"face" : "front",
			"tags" : [
				"B13"
			],
			"type" : "panel",
			"to" : 1802,
			"number" : 24001
		},
		{
			"uuid" : "fb07db89-65f8-1d48-8a3c-f484ab66c03c",
			"name" : "24002",
			"_clazz" : "TwkSegment",
			"brick" : "BOTTOM",
			"from" : 1024,
			"face" : "bottom",
			"tags" : [
				"B13"
			],
			"type" : "panel",
			"to" : 1802,
			"number" : 24002
		},
		{
			"uuid" : "8a9d2df6-3ec6-684f-9449-7b713f497544",
			"name" : "24003",
			"_clazz" : "TwkSegment",
			"brick" : "BACK",
			"from" : 1024,
			"face" : "back",
			"tags" : [
				"B13"
			],
			"type" : "panel",
			"to" : 1804,
			"number" : 24003
		},
		{
			"uuid" : "bde70765-fe23-8240-b2a3-7482528e4b9b",
			"name" : "24004",
			"_clazz" : "TwkSegment",
			"brick" : "TOP",
			"from" : 1017,
			"face" : "top",
			"tags" : [
				"B13"
			],
			"type" : "panel",
			"to" : 1804,
			"number" : 24004
		},
		{
			"uuid" : "2592f644-6f6d-4e42-afee-63b408258a1a",
			"name" : "24005",
			"_clazz" : "TwkSegment",
			"brick" : "FRONT",
			"from" : 1801,
			"face" : "front",
			"tags" : [
				"B13"
			],
			"type" : "panel",
			"to" : 1806,
			"number" : 24005
		},
		{
			"uuid" : "522909ef-b4f4-4445-9a8f-1517d6f40774",
			"name" : "24006",
			"_clazz" : "TwkSegment",
			"brick" : "BOTTOM",
			"from" : 1803,
			"face" : "bottom",
			"tags" : [
				"B13"
			],
			"type" : "panel",
			"to" : 1806,
			"number" : 24006
		},
		{
			"uuid" : "d617a9d5-71c7-6840-bdd6-a7796394adbf",
			"name" : "24007",
			"_clazz" : "TwkSegment",
			"brick" : "BACK",
			"from" : 1803,
			"face" : "back",
			"tags" : [
				"B13"
			],
			"type" : "panel",
			"to" : 1808,
			"number" : 24007
		},
		{
			"uuid" : "e626a985-f09e-7f4f-baed-eb70f9d8555c",
			"name" : "24008",
			"_clazz" : "TwkSegment",
			"brick" : "TOP",
			"from" : 1801,
			"face" : "top",
			"tags" : [
				"B13"
			],
			"type" : "panel",
			"to" : 1808,
			"number" : 24008
		},
		{
			"uuid" : "74b3bf0c-5494-784b-8abd-079078ace77f",
			"name" : "24009",
			"_clazz" : "TwkSegment",
			"brick" : "FRONT",
			"from" : 1805,
			"face" : "front",
			"tags" : [
				"B13"
			],
			"type" : "panel",
			"to" : 1810,
			"number" : 24009
		},
		{
			"uuid" : "f0176176-fdfa-734d-8c78-713923a59a6a",
			"name" : "24010",
			"_clazz" : "TwkSegment",
			"brick" : "BOTTOM",
			"from" : 1807,
			"face" : "bottom",
			"tags" : [
				"B13"
			],
			"type" : "panel",
			"to" : 1810,
			"number" : 24010
		},
		{
			"uuid" : "31eaa5cf-f008-da45-a240-ebae3496c4ab",
			"name" : "24011",
			"_clazz" : "TwkSegment",
			"brick" : "BACK",
			"from" : 1807,
			"face" : "back",
			"tags" : [
				"B13"
			],
			"type" : "panel",
			"to" : 1812,
			"number" : 24011
		},
		{
			"uuid" : "7455dbb0-961c-6e4f-947d-97b9db50ca03",
			"name" : "24012",
			"_clazz" : "TwkSegment",
			"brick" : "TOP",
			"from" : 1805,
			"face" : "top",
			"tags" : [
				"B13"
			],
			"type" : "panel",
			"to" : 1812,
			"number" : 24012
		},
		{
			"uuid" : "398a3921-4ab5-4747-86ea-4a8a1e569a83",
			"name" : "24013",
			"_clazz" : "TwkSegment",
			"brick" : "FRONT",
			"from" : 1809,
			"face" : "front",
			"tags" : [
				"B13"
			],
			"type" : "panel",
			"to" : 1814,
			"number" : 24013
		},
		{
			"uuid" : "5a20992c-f618-af46-b7ce-22717e20a6ca",
			"name" : "24014",
			"_clazz" : "TwkSegment",
			"brick" : "BOTTOM",
			"from" : 1811,
			"face" : "bottom",
			"tags" : [
				"B13"
			],
			"type" : "panel",
			"to" : 1814,
			"number" : 24014
		},
		{
			"uuid" : "b6c56095-f5a3-3346-a9e0-b6bc7460c2ee",
			"name" : "24015",
			"_clazz" : "TwkSegment",
			"brick" : "BACK",
			"from" : 1811,
			"face" : "back",
			"tags" : [
				"B13"
			],
			"type" : "panel",
			"to" : 1816,
			"number" : 24015
		},
		{
			"uuid" : "be9a8054-911b-3143-9a9d-4d3eb1815a67",
			"name" : "24016",
			"_clazz" : "TwkSegment",
			"brick" : "TOP",
			"from" : 1809,
			"face" : "top",
			"tags" : [
				"B13"
			],
			"type" : "panel",
			"to" : 1816,
			"number" : 24016
		},
		{
			"uuid" : "4dcb026b-92e6-9343-bb1e-c87aa3c492d3",
			"name" : "24017",
			"_clazz" : "TwkSegment",
			"brick" : "FRONT",
			"from" : 1813,
			"face" : "front",
			"tags" : [
				"B13"
			],
			"type" : "panel",
			"to" : 1818,
			"number" : 24017
		},
		{
			"uuid" : "4772642f-8f7e-6543-b803-7e4ccac2d658",
			"name" : "24018",
			"_clazz" : "TwkSegment",
			"brick" : "BOTTOM",
			"from" : 1815,
			"face" : "bottom",
			"tags" : [
				"B13"
			],
			"type" : "panel",
			"to" : 1818,
			"number" : 24018
		},
		{
			"uuid" : "9fe6454f-5cb8-554f-9a06-4daadc15b214",
			"name" : "24019",
			"_clazz" : "TwkSegment",
			"brick" : "BACK",
			"from" : 1815,
			"face" : "back",
			"tags" : [
				"B13"
			],
			"type" : "panel",
			"to" : 1820,
			"number" : 24019
		},
		{
			"uuid" : "ba8b9f12-6735-a14f-b568-93dd9d373ed4",
			"name" : "24020",
			"_clazz" : "TwkSegment",
			"brick" : "TOP",
			"from" : 1813,
			"face" : "top",
			"tags" : [
				"B13"
			],
			"type" : "panel",
			"to" : 1820,
			"number" : 24020
		},
		{
			"uuid" : "7ec4efa0-55e8-734e-952c-cefe04bd8531",
			"name" : "24021",
			"_clazz" : "TwkSegment",
			"brick" : "FRONT",
			"from" : 1817,
			"face" : "front",
			"tags" : [
				"B13"
			],
			"type" : "panel",
			"to" : 1822,
			"number" : 24021
		},
		{
			"uuid" : "e05aed67-c4f6-1f45-9ade-5fc795de136e",
			"name" : "24022",
			"_clazz" : "TwkSegment",
			"brick" : "BOTTOM",
			"from" : 1819,
			"face" : "bottom",
			"tags" : [
				"B13"
			],
			"type" : "panel",
			"to" : 1822,
			"number" : 24022
		},
		{
			"uuid" : "602fa5cb-bf0c-024d-8c6a-cebd5e9d7d6f",
			"name" : "24023",
			"_clazz" : "TwkSegment",
			"brick" : "BACK",
			"from" : 1819,
			"face" : "back",
			"tags" : [
				"B13"
			],
			"type" : "panel",
			"to" : 1824,
			"number" : 24023
		},
		{
			"uuid" : "2b80b068-b038-ec4b-8b5e-b6c3d2ad621e",
			"name" : "24024",
			"_clazz" : "TwkSegment",
			"brick" : "TOP",
			"from" : 1817,
			"face" : "top",
			"tags" : [
				"B13"
			],
			"type" : "panel",
			"to" : 1824,
			"number" : 24024
		},
		{
			"uuid" : "40d3be7d-d000-9e47-8286-f21db1aa43fd",
			"name" : "24025",
			"_clazz" : "TwkSegment",
			"brick" : "FRONT",
			"from" : 1821,
			"face" : "front",
			"tags" : [
				"B13"
			],
			"type" : "panel",
			"to" : 1826,
			"number" : 24025
		},
		{
			"uuid" : "347a3873-a2ab-8547-a29a-52882d2fd307",
			"name" : "24026",
			"_clazz" : "TwkSegment",
			"brick" : "BOTTOM",
			"from" : 1823,
			"face" : "bottom",
			"tags" : [
				"B13"
			],
			"type" : "panel",
			"to" : 1826,
			"number" : 24026
		},
		{
			"uuid" : "3fecec02-b690-7743-b9df-dd1540425e3b",
			"name" : "24027",
			"_clazz" : "TwkSegment",
			"brick" : "BACK",
			"from" : 1823,
			"face" : "back",
			"tags" : [
				"B13"
			],
			"type" : "panel",
			"to" : 1828,
			"number" : 24027
		},
		{
			"uuid" : "fc9eb6c4-50bd-e24c-a1e3-b1c5f3fd11cb",
			"name" : "24028",
			"_clazz" : "TwkSegment",
			"brick" : "TOP",
			"from" : 1821,
			"face" : "top",
			"tags" : [
				"B13"
			],
			"type" : "panel",
			"to" : 1828,
			"number" : 24028
		},
		{
			"uuid" : "fffbaf25-26eb-0b4b-8769-e4bc3bb3a24e",
			"name" : "24029",
			"_clazz" : "TwkSegment",
			"brick" : "FRONT",
			"from" : 1826,
			"face" : "front",
			"tags" : [
				"B13"
			],
			"type" : "panel",
			"to" : 1829,
			"number" : 24029
		},
		{
			"uuid" : "b0cc0eb4-887a-f34e-859d-fa529d29a9d5",
			"name" : "24030",
			"_clazz" : "TwkSegment",
			"brick" : "BOTTOM",
			"from" : 1826,
			"face" : "bottom",
			"tags" : [
				"B13"
			],
			"type" : "panel",
			"to" : 1831,
			"number" : 24030
		},
		{
			"uuid" : "ee7d7514-1ef7-f342-ad00-ed49ede84b71",
			"name" : "24031",
			"_clazz" : "TwkSegment",
			"brick" : "BACK",
			"from" : 1828,
			"face" : "back",
			"tags" : [
				"B13"
			],
			"type" : "panel",
			"to" : 1831,
			"number" : 24031
		},
		{
			"uuid" : "dd2e2fc8-ac93-c542-96b6-cfb659b7d3f1",
			"name" : "24032",
			"_clazz" : "TwkSegment",
			"brick" : "TOP",
			"from" : 1828,
			"face" : "top",
			"tags" : [
				"B13"
			],
			"type" : "panel",
			"to" : 1829,
			"number" : 24032
		},
		{
			"uuid" : "8db829a2-e4f0-d04e-84b4-0283679a4c3a",
			"name" : "24033",
			"_clazz" : "TwkSegment",
			"brick" : "FRONT",
			"from" : 1830,
			"face" : "front",
			"tags" : [
				"B13"
			],
			"type" : "panel",
			"to" : 1833,
			"number" : 24033
		},
		{
			"uuid" : "aeb02adb-0f95-3f4c-9258-180d9256d935",
			"name" : "24034",
			"_clazz" : "TwkSegment",
			"brick" : "BOTTOM",
			"from" : 1830,
			"face" : "bottom",
			"tags" : [
				"B13"
			],
			"type" : "panel",
			"to" : 1835,
			"number" : 24034
		},
		{
			"uuid" : "5042cc6e-2e67-5f45-ba4b-9a195efede5c",
			"name" : "24035",
			"_clazz" : "TwkSegment",
			"brick" : "BACK",
			"from" : 1832,
			"face" : "back",
			"tags" : [
				"B13"
			],
			"type" : "panel",
			"to" : 1835,
			"number" : 24035
		},
		{
			"uuid" : "3a34f161-0236-4a4e-981e-14cbe542748c",
			"name" : "24036",
			"_clazz" : "TwkSegment",
			"brick" : "TOP",
			"from" : 1832,
			"face" : "top",
			"tags" : [
				"B13"
			],
			"type" : "panel",
			"to" : 1833,
			"number" : 24036
		},
		{
			"uuid" : "3c225d81-d4c1-b248-888f-51d6115ade2b",
			"name" : "24037",
			"_clazz" : "TwkSegment",
			"brick" : "FRONT",
			"from" : 1834,
			"face" : "front",
			"tags" : [
				"B13"
			],
			"type" : "panel",
			"to" : 1837,
			"number" : 24037
		},
		{
			"uuid" : "1bd389ce-419b-a14a-9555-736fe5f6e032",
			"name" : "24038",
			"_clazz" : "TwkSegment",
			"brick" : "BOTTOM",
			"from" : 1834,
			"face" : "bottom",
			"tags" : [
				"B13"
			],
			"type" : "panel",
			"to" : 1839,
			"number" : 24038
		},
		{
			"uuid" : "b7b5d3d4-9979-b443-90b3-9958d90b7a6f",
			"name" : "24039",
			"_clazz" : "TwkSegment",
			"brick" : "BACK",
			"from" : 1836,
			"face" : "back",
			"tags" : [
				"B13"
			],
			"type" : "panel",
			"to" : 1839,
			"number" : 24039
		},
		{
			"uuid" : "e07b4674-d945-fb4e-bf46-01079da7ab9a",
			"name" : "24040",
			"_clazz" : "TwkSegment",
			"brick" : "TOP",
			"from" : 1836,
			"face" : "top",
			"tags" : [
				"B13"
			],
			"type" : "panel",
			"to" : 1837,
			"number" : 24040
		},
		{
			"uuid" : "942a0104-0bdd-1a47-98f8-76e8794d3aa2",
			"name" : "24041",
			"_clazz" : "TwkSegment",
			"brick" : "FRONT",
			"from" : 1838,
			"face" : "front",
			"tags" : [
				"B13"
			],
			"type" : "panel",
			"to" : 1841,
			"number" : 24041
		},
		{
			"uuid" : "05c8816d-ecd0-5c47-92c1-946da043987a",
			"name" : "24042",
			"_clazz" : "TwkSegment",
			"brick" : "BOTTOM",
			"from" : 1838,
			"face" : "bottom",
			"tags" : [
				"B13"
			],
			"type" : "panel",
			"to" : 1843,
			"number" : 24042
		},
		{
			"uuid" : "58b08231-2262-5949-8fd8-a06322468544",
			"name" : "24043",
			"_clazz" : "TwkSegment",
			"brick" : "BACK",
			"from" : 1840,
			"face" : "back",
			"tags" : [
				"B13"
			],
			"type" : "panel",
			"to" : 1843,
			"number" : 24043
		},
		{
			"uuid" : "f5c7e682-12f0-e441-be1e-9efe4651bf8c",
			"name" : "24044",
			"_clazz" : "TwkSegment",
			"brick" : "TOP",
			"from" : 1840,
			"face" : "top",
			"tags" : [
				"B13"
			],
			"type" : "panel",
			"to" : 1841,
			"number" : 24044
		},
		{
			"uuid" : "66ab72cb-a2fc-ff4c-8892-a390ef7ac13d",
			"name" : "24045",
			"_clazz" : "TwkSegment",
			"brick" : "FRONT",
			"from" : 1842,
			"face" : "front",
			"tags" : [
				"B13"
			],
			"type" : "panel",
			"to" : 1845,
			"number" : 24045
		},
		{
			"uuid" : "184e44cc-da1f-a247-838a-f954f6f34128",
			"name" : "24046",
			"_clazz" : "TwkSegment",
			"brick" : "BOTTOM",
			"from" : 1842,
			"face" : "bottom",
			"tags" : [
				"B13"
			],
			"type" : "panel",
			"to" : 1847,
			"number" : 24046
		},
		{
			"uuid" : "f94e7c2c-29da-7f43-8294-85e664c77265",
			"name" : "24047",
			"_clazz" : "TwkSegment",
			"brick" : "BACK",
			"from" : 1844,
			"face" : "back",
			"tags" : [
				"B13"
			],
			"type" : "panel",
			"to" : 1847,
			"number" : 24047
		},
		{
			"uuid" : "861f3a6c-ca73-e342-b587-a7379919451c",
			"name" : "24048",
			"_clazz" : "TwkSegment",
			"brick" : "TOP",
			"from" : 1844,
			"face" : "top",
			"tags" : [
				"B13"
			],
			"type" : "panel",
			"to" : 1845,
			"number" : 24048
		},
		{
			"uuid" : "980a0fc4-2749-6a4a-83fd-1fb228355193",
			"name" : "24049",
			"_clazz" : "TwkSegment",
			"brick" : "FRONT",
			"from" : 1846,
			"face" : "front",
			"tags" : [
				"B13"
			],
			"type" : "panel",
			"to" : 1849,
			"number" : 24049
		},
		{
			"uuid" : "8c7a81e5-c7af-e24e-96d9-c104bf593230",
			"name" : "24050",
			"_clazz" : "TwkSegment",
			"brick" : "BOTTOM",
			"from" : 1846,
			"face" : "bottom",
			"tags" : [
				"B13"
			],
			"type" : "panel",
			"to" : 1851,
			"number" : 24050
		},
		{
			"uuid" : "333c5763-86ed-c74f-be4b-c16db727d875",
			"name" : "24051",
			"_clazz" : "TwkSegment",
			"brick" : "BACK",
			"from" : 1848,
			"face" : "back",
			"tags" : [
				"B13"
			],
			"type" : "panel",
			"to" : 1851,
			"number" : 24051
		},
		{
			"uuid" : "9e1eb49a-6b1d-6944-b4df-3a7efcaf02f0",
			"name" : "24052",
			"_clazz" : "TwkSegment",
			"brick" : "TOP",
			"from" : 1848,
			"face" : "top",
			"tags" : [
				"B13"
			],
			"type" : "panel",
			"to" : 1849,
			"number" : 24052
		},
		{
			"uuid" : "9f1eaaa0-a5d1-034c-8550-e90dce58b7fa",
			"name" : "24053",
			"_clazz" : "TwkSegment",
			"brick" : "FRONT",
			"from" : 1850,
			"face" : "front",
			"tags" : [
				"B13"
			],
			"type" : "panel",
			"to" : 1202,
			"number" : 24053
		},
		{
			"uuid" : "91ab8229-349d-594c-9bf7-8fb4bfd0009e",
			"name" : "24054",
			"_clazz" : "TwkSegment",
			"brick" : "BOTTOM",
			"from" : 1850,
			"face" : "bottom",
			"tags" : [
				"B13"
			],
			"type" : "panel",
			"to" : 1207,
			"number" : 24054
		},
		{
			"uuid" : "fd7d4735-f645-b540-9e0f-5e1a937051be",
			"name" : "24055",
			"_clazz" : "TwkSegment",
			"brick" : "BACK",
			"from" : 1852,
			"face" : "back",
			"tags" : [
				"B13"
			],
			"type" : "panel",
			"to" : 1207,
			"number" : 24055
		},
		{
			"uuid" : "87e8c2f9-803c-174e-80e9-669c4f1e721b",
			"name" : "24056",
			"_clazz" : "TwkSegment",
			"brick" : "TOP",
			"from" : 1852,
			"face" : "top",
			"tags" : [
				"B13"
			],
			"type" : "panel",
			"to" : 1202,
			"number" : 24056
		},
		{
			"number" : 16001,
			"tags" : [
				"B14"
			],
			"type" : "slope",
			"to" : 1901,
			"from" : 1201,
			"brick" : "B14",
			"name" : "16001",
			"uuid" : "ff09bc84-898f-f444-8470-f8c6e307cc9d",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 16002,
			"tags" : [
				"B14"
			],
			"type" : "slope",
			"to" : 1902,
			"from" : 1205,
			"brick" : "B14",
			"name" : "16002",
			"uuid" : "a40e6923-245c-fe45-8747-931905c32977",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 16003,
			"tags" : [
				"B14"
			],
			"type" : "slope",
			"to" : 1903,
			"from" : 1208,
			"brick" : "B14",
			"name" : "16003",
			"uuid" : "097e60ba-c303-764b-aa71-e21f58903a0c",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 16004,
			"tags" : [
				"B14"
			],
			"type" : "slope",
			"to" : 1904,
			"from" : 1204,
			"brick" : "B14",
			"name" : "16004",
			"uuid" : "ef4e6320-d0a0-ac4e-876f-10670698cc7e",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 16005,
			"tags" : [
				"B14"
			],
			"type" : "slope",
			"to" : 1905,
			"from" : 1901,
			"brick" : "B14",
			"name" : "16005",
			"uuid" : "87630745-e791-2a4c-80c7-b00fb67bca28",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 16006,
			"tags" : [
				"B14"
			],
			"type" : "slope",
			"to" : 1906,
			"from" : 1902,
			"brick" : "B14",
			"name" : "16006",
			"uuid" : "c3aa89fc-3f3c-2a49-83fd-36f47abfdf03",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 16007,
			"tags" : [
				"B14"
			],
			"type" : "slope",
			"to" : 1907,
			"from" : 1903,
			"brick" : "B14",
			"name" : "16007",
			"uuid" : "8c89852d-da00-534b-9333-4669ab600cd2",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 16008,
			"tags" : [
				"B14"
			],
			"type" : "slope",
			"to" : 1908,
			"from" : 1904,
			"brick" : "B14",
			"name" : "16008",
			"uuid" : "209a5682-a23e-b948-82d8-817686e09b46",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 16009,
			"tags" : [
				"B14"
			],
			"type" : "slope",
			"to" : 1909,
			"from" : 1905,
			"brick" : "B14",
			"name" : "16009",
			"uuid" : "cb69580c-f7ee-e84b-ad95-4944af0519b8",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 16010,
			"tags" : [
				"B14"
			],
			"type" : "slope",
			"to" : 1910,
			"from" : 1906,
			"brick" : "B14",
			"name" : "16010",
			"uuid" : "3f1632aa-8390-6c45-965e-d1d599ade4a4",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 16011,
			"tags" : [
				"B14"
			],
			"type" : "slope",
			"to" : 1911,
			"from" : 1907,
			"brick" : "B14",
			"name" : "16011",
			"uuid" : "4f29c5d8-dc38-9b43-920f-8b4f8a774ee9",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 16012,
			"tags" : [
				"B14"
			],
			"type" : "slope",
			"to" : 1912,
			"from" : 1908,
			"brick" : "B14",
			"name" : "16012",
			"uuid" : "577ad27b-cf1a-c74d-ae13-9b340620d847",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 16013,
			"tags" : [
				"B14"
			],
			"type" : "slope",
			"to" : 1913,
			"from" : 1909,
			"brick" : "B14",
			"name" : "16013",
			"uuid" : "0ca4ad62-5bf9-2340-8f95-7c1b38361c92",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 16014,
			"tags" : [
				"B14"
			],
			"type" : "slope",
			"to" : 1914,
			"from" : 1910,
			"brick" : "B14",
			"name" : "16014",
			"uuid" : "dbb243ee-d009-6e49-8826-40a822b52c99",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 16015,
			"tags" : [
				"B14"
			],
			"type" : "slope",
			"to" : 1915,
			"from" : 1911,
			"brick" : "B14",
			"name" : "16015",
			"uuid" : "117c5d71-f48b-9a4a-bbe7-07f872f9e0e3",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 16016,
			"tags" : [
				"B14"
			],
			"type" : "slope",
			"to" : 1916,
			"from" : 1912,
			"brick" : "B14",
			"name" : "16016",
			"uuid" : "efb6367f-1fea-4a4a-a751-9e7df9bc3ee5",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 16017,
			"tags" : [
				"B14"
			],
			"type" : "slope",
			"to" : 1917,
			"from" : 1913,
			"brick" : "B14",
			"name" : "16017",
			"uuid" : "0c6658eb-d946-2643-8149-df40cbb96ca8",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 16018,
			"tags" : [
				"B14"
			],
			"type" : "slope",
			"to" : 1918,
			"from" : 1914,
			"brick" : "B14",
			"name" : "16018",
			"uuid" : "6ebf3f4e-cda4-744c-8c32-08615fa72d89",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 16019,
			"tags" : [
				"B14"
			],
			"type" : "slope",
			"to" : 1919,
			"from" : 1915,
			"brick" : "B14",
			"name" : "16019",
			"uuid" : "2d332572-8799-a547-a3c7-c4be338fde23",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 16020,
			"tags" : [
				"B14"
			],
			"type" : "slope",
			"to" : 1920,
			"from" : 1916,
			"brick" : "B14",
			"name" : "16020",
			"uuid" : "51ccff4d-1bc9-234a-b07e-85cf678a987d",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 16021,
			"tags" : [
				"B14"
			],
			"type" : "slope",
			"to" : 1921,
			"from" : 1917,
			"brick" : "B14",
			"name" : "16021",
			"uuid" : "f27d50a0-717b-6246-a0b5-02ca7c558544",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 16022,
			"tags" : [
				"B14"
			],
			"type" : "slope",
			"to" : 1922,
			"from" : 1918,
			"brick" : "B14",
			"name" : "16022",
			"uuid" : "f6ccf96b-3d44-2146-8d93-576cc6e29e30",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 16023,
			"tags" : [
				"B14"
			],
			"type" : "slope",
			"to" : 1923,
			"from" : 1919,
			"brick" : "B14",
			"name" : "16023",
			"uuid" : "b483a15e-9b61-7a4a-809a-6b5737089059",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 16024,
			"tags" : [
				"B14"
			],
			"type" : "slope",
			"to" : 1924,
			"from" : 1920,
			"brick" : "B14",
			"name" : "16024",
			"uuid" : "a6d08b99-be35-0f46-9e70-24d06cf2f3a4",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 16025,
			"tags" : [
				"B14"
			],
			"type" : "slope",
			"to" : 1925,
			"from" : 1921,
			"brick" : "B14",
			"name" : "16025",
			"uuid" : "628d7520-adb5-bd42-9730-a4c4d511ef52",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 16026,
			"tags" : [
				"B14"
			],
			"type" : "slope",
			"to" : 1926,
			"from" : 1922,
			"brick" : "B14",
			"name" : "16026",
			"uuid" : "666c6943-7cb6-4d44-85ec-b3d010bcabbf",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 16027,
			"tags" : [
				"B14"
			],
			"type" : "slope",
			"to" : 1927,
			"from" : 1923,
			"brick" : "B14",
			"name" : "16027",
			"uuid" : "1223f6a6-eb69-6f4e-9877-99d687f28540",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 16028,
			"tags" : [
				"B14"
			],
			"type" : "slope",
			"to" : 1928,
			"from" : 1924,
			"brick" : "B14",
			"name" : "16028",
			"uuid" : "1faea405-eabf-de4b-befa-05366b450751",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 16029,
			"tags" : [
				"B14"
			],
			"type" : "slope",
			"to" : 1929,
			"from" : 1925,
			"brick" : "B14",
			"name" : "16029",
			"uuid" : "3c70089d-b164-da43-83f5-f54e9da9567b",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 16030,
			"tags" : [
				"B14"
			],
			"type" : "slope",
			"to" : 1930,
			"from" : 1926,
			"brick" : "B14",
			"name" : "16030",
			"uuid" : "ea3175f2-07d0-1046-96bf-3f1b9f110e86",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 16031,
			"tags" : [
				"B14"
			],
			"type" : "slope",
			"to" : 1931,
			"from" : 1927,
			"brick" : "B14",
			"name" : "16031",
			"uuid" : "a80655d9-3a1d-b64b-ad7f-4970a2522c32",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 16032,
			"tags" : [
				"B14"
			],
			"type" : "slope",
			"to" : 1932,
			"from" : 1928,
			"brick" : "B14",
			"name" : "16032",
			"uuid" : "163fce7b-6048-6749-a13d-39997c02c259",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 16033,
			"tags" : [
				"B14"
			],
			"type" : "slope",
			"to" : 1933,
			"from" : 1929,
			"brick" : "B14",
			"name" : "16033",
			"uuid" : "a5f69c6b-2afe-b342-a0cb-85db822ce6d7",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 16034,
			"tags" : [
				"B14"
			],
			"type" : "slope",
			"to" : 1934,
			"from" : 1930,
			"brick" : "B14",
			"name" : "16034",
			"uuid" : "f76931f7-3d15-164c-b248-e2de3ae7031f",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 16035,
			"tags" : [
				"B14"
			],
			"type" : "slope",
			"to" : 1935,
			"from" : 1931,
			"brick" : "B14",
			"name" : "16035",
			"uuid" : "be58d7e5-645c-ab48-a3a1-5291e0a3b87c",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 16036,
			"tags" : [
				"B14"
			],
			"type" : "slope",
			"to" : 1936,
			"from" : 1932,
			"brick" : "B14",
			"name" : "16036",
			"uuid" : "ebd01ed5-a3f7-5741-9c91-15d937264aa1",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 16037,
			"tags" : [
				"B14"
			],
			"type" : "slope",
			"to" : 1937,
			"from" : 1933,
			"brick" : "B14",
			"name" : "16037",
			"uuid" : "e7c60fdd-3c8c-2c45-87ea-0f65b7725f57",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 16038,
			"tags" : [
				"B14"
			],
			"type" : "slope",
			"to" : 1938,
			"from" : 1934,
			"brick" : "B14",
			"name" : "16038",
			"uuid" : "0b2dd1ab-8477-104e-8ba8-44030d884369",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 16039,
			"tags" : [
				"B14"
			],
			"type" : "slope",
			"to" : 1939,
			"from" : 1935,
			"brick" : "B14",
			"name" : "16039",
			"uuid" : "02da7e0b-cc3d-0145-9571-4edd1a395ce7",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 16040,
			"tags" : [
				"B14"
			],
			"type" : "slope",
			"to" : 1940,
			"from" : 1936,
			"brick" : "B14",
			"name" : "16040",
			"uuid" : "cdf64343-cff7-fa4e-bbb0-e1d67d319fa1",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 16041,
			"tags" : [
				"B14"
			],
			"type" : "slope",
			"to" : 1941,
			"from" : 1937,
			"brick" : "B14",
			"name" : "16041",
			"uuid" : "dc071f7e-6fe2-1443-a854-40f8fc11f321",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 16042,
			"tags" : [
				"B14"
			],
			"type" : "slope",
			"to" : 1942,
			"from" : 1938,
			"brick" : "B14",
			"name" : "16042",
			"uuid" : "7d10b7af-4dda-a044-b8dd-a7f184eeca76",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 16043,
			"tags" : [
				"B14"
			],
			"type" : "slope",
			"to" : 1943,
			"from" : 1939,
			"brick" : "B14",
			"name" : "16043",
			"uuid" : "63cf54be-f612-5a4a-84e7-fcea5b500943",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 16044,
			"tags" : [
				"B14"
			],
			"type" : "slope",
			"to" : 1944,
			"from" : 1940,
			"brick" : "B14",
			"name" : "16044",
			"uuid" : "150e5dad-2394-7643-9720-f2c8b9acbbb7",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 16045,
			"tags" : [
				"B14"
			],
			"type" : "slope",
			"to" : 1945,
			"from" : 1941,
			"brick" : "B14",
			"name" : "16045",
			"uuid" : "765e4bfd-3f82-8048-8376-16047eb8f33a",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 16046,
			"tags" : [
				"B14"
			],
			"type" : "slope",
			"to" : 1946,
			"from" : 1942,
			"brick" : "B14",
			"name" : "16046",
			"uuid" : "b12f620a-c8b2-324c-9f24-a18b8836d772",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 16047,
			"tags" : [
				"B14"
			],
			"type" : "slope",
			"to" : 1947,
			"from" : 1943,
			"brick" : "B14",
			"name" : "16047",
			"uuid" : "50cf75f5-b2f4-b14b-be4d-0dc62da0e551",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 16048,
			"tags" : [
				"B14"
			],
			"type" : "slope",
			"to" : 1948,
			"from" : 1944,
			"brick" : "B14",
			"name" : "16048",
			"uuid" : "a1d22a2b-9805-1a43-8a9a-ee01d34a88a6",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 16049,
			"tags" : [
				"B14"
			],
			"type" : "slope",
			"to" : 1949,
			"from" : 1945,
			"brick" : "B14",
			"name" : "16049",
			"uuid" : "90f52ba2-3a78-f74a-a2e9-96a94924c423",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 16050,
			"tags" : [
				"B14"
			],
			"type" : "slope",
			"to" : 1950,
			"from" : 1946,
			"brick" : "B14",
			"name" : "16050",
			"uuid" : "af647141-49f8-364f-bbe9-6d680fb4873f",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 16051,
			"tags" : [
				"B14"
			],
			"type" : "slope",
			"to" : 1951,
			"from" : 1947,
			"brick" : "B14",
			"name" : "16051",
			"uuid" : "e97e2f8a-0123-bf4c-a0e3-888e7efd4800",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 16052,
			"tags" : [
				"B14"
			],
			"type" : "slope",
			"to" : 1952,
			"from" : 1948,
			"brick" : "B14",
			"name" : "16052",
			"uuid" : "500de776-f6d9-a141-9fa0-832b2070aba2",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 16053,
			"tags" : [
				"B14"
			],
			"type" : "slope",
			"to" : 1318,
			"from" : 1949,
			"brick" : "B14",
			"name" : "16053",
			"uuid" : "60408e29-364a-bc40-b7ae-419df4ea0c0f",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 16054,
			"tags" : [
				"B14"
			],
			"type" : "slope",
			"to" : 1322,
			"from" : 1950,
			"brick" : "B14",
			"name" : "16054",
			"uuid" : "3472f370-b2e9-6646-926c-8206a1a70007",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 16055,
			"tags" : [
				"B14"
			],
			"type" : "slope",
			"to" : 1323,
			"from" : 1951,
			"brick" : "B14",
			"name" : "16055",
			"uuid" : "79d11daf-d07e-5d4a-96c2-f03c7d9aa73c",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 16056,
			"tags" : [
				"B14"
			],
			"type" : "slope",
			"to" : 1319,
			"from" : 1952,
			"brick" : "B14",
			"name" : "16056",
			"uuid" : "0639e727-70c0-dc4c-908f-e153f41a1fc6",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 34001,
			"tags" : [
				"B14"
			],
			"type" : "sectionRound",
			"to" : 1902,
			"from" : 1901,
			"brick" : "B14",
			"name" : "34001",
			"uuid" : "331228e8-e800-4740-adb1-c0c5330fd120",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 34002,
			"tags" : [
				"B14"
			],
			"type" : "sectionRound",
			"to" : 1903,
			"from" : 1902,
			"brick" : "B14",
			"name" : "34002",
			"uuid" : "e4ea2ecc-691a-8345-9a1c-3713f5bafe44",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 34003,
			"tags" : [
				"B14"
			],
			"type" : "sectionRound",
			"to" : 1904,
			"from" : 1903,
			"brick" : "B14",
			"name" : "34003",
			"uuid" : "a761fd9f-aada-7e46-b18e-16b91154a81c",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 34004,
			"tags" : [
				"B14"
			],
			"type" : "sectionRound",
			"to" : 1901,
			"from" : 1904,
			"brick" : "B14",
			"name" : "34004",
			"uuid" : "bb9d779a-791d-6947-9236-c2cebe777441",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 34005,
			"tags" : [
				"B14"
			],
			"type" : "sectionRound",
			"to" : 1906,
			"from" : 1905,
			"brick" : "B14",
			"name" : "34005",
			"uuid" : "6af95bbd-78f1-f544-961b-c69ae833ed11",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 34006,
			"tags" : [
				"B14"
			],
			"type" : "sectionRound",
			"to" : 1907,
			"from" : 1906,
			"brick" : "B14",
			"name" : "34006",
			"uuid" : "a9742156-97d5-af4e-ad17-fe73282afe24",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 34007,
			"tags" : [
				"B14"
			],
			"type" : "sectionRound",
			"to" : 1908,
			"from" : 1907,
			"brick" : "B14",
			"name" : "34007",
			"uuid" : "aa2d7db1-6dfe-f64f-bd2a-dd853892b4b2",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 34008,
			"tags" : [
				"B14"
			],
			"type" : "sectionRound",
			"to" : 1905,
			"from" : 1908,
			"brick" : "B14",
			"name" : "34008",
			"uuid" : "5cdf8060-334c-8940-91be-3c86df38fe55",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 34009,
			"tags" : [
				"B14"
			],
			"type" : "sectionRound",
			"to" : 1953,
			"from" : 1909,
			"brick" : "B14",
			"name" : "34009",
			"uuid" : "4970b474-b583-3c48-ac33-92a6b60a6188",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 34010,
			"tags" : [
				"B14"
			],
			"type" : "sectionRound",
			"to" : 1910,
			"from" : 1953,
			"brick" : "B14",
			"name" : "34010",
			"uuid" : "293c3df5-288a-d84b-a337-9e0eaa31ee83",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 34011,
			"tags" : [
				"B14"
			],
			"type" : "sectionRound",
			"to" : 1954,
			"from" : 1910,
			"brick" : "B14",
			"name" : "34011",
			"uuid" : "e73ec30c-c821-1040-aaa1-8f9561e757bc",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 34012,
			"tags" : [
				"B14"
			],
			"type" : "sectionRound",
			"to" : 1911,
			"from" : 1954,
			"brick" : "B14",
			"name" : "34012",
			"uuid" : "561a1e85-af60-ab40-9341-1b9940686f45",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 34013,
			"tags" : [
				"B14"
			],
			"type" : "sectionRound",
			"to" : 1955,
			"from" : 1911,
			"brick" : "B14",
			"name" : "34013",
			"uuid" : "51cf5081-3cee-a744-9b4e-cb1653afee8e",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 34014,
			"tags" : [
				"B14"
			],
			"type" : "sectionRound",
			"to" : 1912,
			"from" : 1955,
			"brick" : "B14",
			"name" : "34014",
			"uuid" : "fd37dfa4-ebee-3d43-a902-c4c411fcf689",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 34015,
			"tags" : [
				"B14"
			],
			"type" : "sectionRound",
			"to" : 1956,
			"from" : 1912,
			"brick" : "B14",
			"name" : "34015",
			"uuid" : "b56c95a4-c513-d548-be0a-388d71d7a637",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 34016,
			"tags" : [
				"B14"
			],
			"type" : "sectionRound",
			"to" : 1909,
			"from" : 1956,
			"brick" : "B14",
			"name" : "34016",
			"uuid" : "62a10ae7-ab7c-b942-b450-6d289624ac13",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 34017,
			"tags" : [
				"B14"
			],
			"type" : "sectionRound",
			"to" : 1914,
			"from" : 1913,
			"brick" : "B14",
			"name" : "34017",
			"uuid" : "507944fe-5ffb-1648-bcd5-ac8c597a4cba",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 34018,
			"tags" : [
				"B14"
			],
			"type" : "sectionRound",
			"to" : 1915,
			"from" : 1914,
			"brick" : "B14",
			"name" : "34018",
			"uuid" : "cc633e03-087c-904f-ad73-6a3627918311",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 34019,
			"tags" : [
				"B14"
			],
			"type" : "sectionRound",
			"to" : 1916,
			"from" : 1915,
			"brick" : "B14",
			"name" : "34019",
			"uuid" : "e5949219-a580-6e4f-bf92-79350217f26e",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 34020,
			"tags" : [
				"B14"
			],
			"type" : "sectionRound",
			"to" : 1913,
			"from" : 1916,
			"brick" : "B14",
			"name" : "34020",
			"uuid" : "eea79ef6-06f4-e149-b2b4-13d524a7269c",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 34021,
			"tags" : [
				"B14"
			],
			"type" : "sectionRound",
			"to" : 1918,
			"from" : 1917,
			"brick" : "B14",
			"name" : "34021",
			"uuid" : "bc164938-b936-d24d-8d24-3eeaeb37b3c6",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 34022,
			"tags" : [
				"B14"
			],
			"type" : "sectionRound",
			"to" : 1919,
			"from" : 1918,
			"brick" : "B14",
			"name" : "34022",
			"uuid" : "2925fc9a-ae39-8f42-9c2c-79e90e04fad7",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 34023,
			"tags" : [
				"B14"
			],
			"type" : "sectionRound",
			"to" : 1920,
			"from" : 1919,
			"brick" : "B14",
			"name" : "34023",
			"uuid" : "3aefa69f-3d75-2340-ad85-f7b0ef301b8a",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 34024,
			"tags" : [
				"B14"
			],
			"type" : "sectionRound",
			"to" : 1917,
			"from" : 1920,
			"brick" : "B14",
			"name" : "34024",
			"uuid" : "baa8b7f0-78d3-ef4d-b704-34f0129f430d",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 34025,
			"tags" : [
				"B14"
			],
			"type" : "sectionRound",
			"to" : 1922,
			"from" : 1921,
			"brick" : "B14",
			"name" : "34025",
			"uuid" : "62c378c8-17ec-1e4f-aa6e-b21d3ce574da",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 34026,
			"tags" : [
				"B14"
			],
			"type" : "sectionRound",
			"to" : 1923,
			"from" : 1922,
			"brick" : "B14",
			"name" : "34026",
			"uuid" : "5b173bfd-7882-4a48-84fc-01ad5965cbb9",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 34027,
			"tags" : [
				"B14"
			],
			"type" : "sectionRound",
			"to" : 1924,
			"from" : 1923,
			"brick" : "B14",
			"name" : "34027",
			"uuid" : "23c59cfc-e98e-b049-95fc-7b551194065e",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 34028,
			"tags" : [
				"B14"
			],
			"type" : "sectionRound",
			"to" : 1921,
			"from" : 1924,
			"brick" : "B14",
			"name" : "34028",
			"uuid" : "0d966875-dc5c-c948-802c-973cfbaf4158",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 34029,
			"tags" : [
				"B14"
			],
			"type" : "sectionRound",
			"to" : 1957,
			"from" : 1925,
			"brick" : "B14",
			"name" : "34029",
			"uuid" : "aee56d31-323c-f44a-97dc-6fd3a06ff277",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 34030,
			"tags" : [
				"B14"
			],
			"type" : "sectionRound",
			"to" : 1926,
			"from" : 1957,
			"brick" : "B14",
			"name" : "34030",
			"uuid" : "fe684e3d-3314-f646-8a68-60477e082a9a",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 34031,
			"tags" : [
				"B14"
			],
			"type" : "sectionRound",
			"to" : 1958,
			"from" : 1926,
			"brick" : "B14",
			"name" : "34031",
			"uuid" : "df34b869-1b81-0743-b09e-881c5ea5dff4",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 34032,
			"tags" : [
				"B14"
			],
			"type" : "sectionRound",
			"to" : 1927,
			"from" : 1958,
			"brick" : "B14",
			"name" : "34032",
			"uuid" : "698aa726-46c9-b04a-ba63-e0c18420c354",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 34033,
			"tags" : [
				"B14"
			],
			"type" : "sectionRound",
			"to" : 1959,
			"from" : 1927,
			"brick" : "B14",
			"name" : "34033",
			"uuid" : "69339e2c-dab2-f74f-927e-98a4e6ecc71e",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 34034,
			"tags" : [
				"B14"
			],
			"type" : "sectionRound",
			"to" : 1928,
			"from" : 1959,
			"brick" : "B14",
			"name" : "34034",
			"uuid" : "7c58595a-cde7-f143-ac8e-8b1855df93a0",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 34035,
			"tags" : [
				"B14"
			],
			"type" : "sectionRound",
			"to" : 1960,
			"from" : 1928,
			"brick" : "B14",
			"name" : "34035",
			"uuid" : "de1bb112-b3d3-5248-88af-fae77c6977fd",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 34036,
			"tags" : [
				"B14"
			],
			"type" : "sectionRound",
			"to" : 1925,
			"from" : 1960,
			"brick" : "B14",
			"name" : "34036",
			"uuid" : "c92f21de-b2f1-a740-94fe-f569f4b25ca5",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 34037,
			"tags" : [
				"B14"
			],
			"type" : "sectionRound",
			"to" : 1930,
			"from" : 1929,
			"brick" : "B14",
			"name" : "34037",
			"uuid" : "ec6eb124-95dd-8348-b206-f1b80317066a",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 34038,
			"tags" : [
				"B14"
			],
			"type" : "sectionRound",
			"to" : 1931,
			"from" : 1930,
			"brick" : "B14",
			"name" : "34038",
			"uuid" : "e8fd74a7-9512-d742-b6a0-0be3742889e1",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 34039,
			"tags" : [
				"B14"
			],
			"type" : "sectionRound",
			"to" : 1932,
			"from" : 1931,
			"brick" : "B14",
			"name" : "34039",
			"uuid" : "9eaa3882-003a-5341-88e9-149052f66666",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 34040,
			"tags" : [
				"B14"
			],
			"type" : "sectionRound",
			"to" : 1929,
			"from" : 1932,
			"brick" : "B14",
			"name" : "34040",
			"uuid" : "8b5216e8-8c7c-7b45-904c-af05575c4afc",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 34041,
			"tags" : [
				"B14"
			],
			"type" : "sectionRound",
			"to" : 1934,
			"from" : 1933,
			"brick" : "B14",
			"name" : "34041",
			"uuid" : "08170f04-5a72-6d4b-84b0-c4339b1ff963",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 34042,
			"tags" : [
				"B14"
			],
			"type" : "sectionRound",
			"to" : 1935,
			"from" : 1934,
			"brick" : "B14",
			"name" : "34042",
			"uuid" : "a378ce8a-44e5-774d-90a5-f64fe4ccddeb",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 34043,
			"tags" : [
				"B14"
			],
			"type" : "sectionRound",
			"to" : 1936,
			"from" : 1935,
			"brick" : "B14",
			"name" : "34043",
			"uuid" : "857fc3be-2571-5d4a-9601-4ddbb4ba169c",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 34044,
			"tags" : [
				"B14"
			],
			"type" : "sectionRound",
			"to" : 1933,
			"from" : 1936,
			"brick" : "B14",
			"name" : "34044",
			"uuid" : "1dc17c76-f95c-4c42-9384-cf9ce2734d7a",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 34045,
			"tags" : [
				"B14"
			],
			"type" : "sectionRound",
			"to" : 1938,
			"from" : 1937,
			"brick" : "B14",
			"name" : "34045",
			"uuid" : "6c2a768d-87c3-cb4a-a1ef-bae678b3c411",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 34046,
			"tags" : [
				"B14"
			],
			"type" : "sectionRound",
			"to" : 1939,
			"from" : 1938,
			"brick" : "B14",
			"name" : "34046",
			"uuid" : "061a212e-b905-274d-9739-744946f18948",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 34047,
			"tags" : [
				"B14"
			],
			"type" : "sectionRound",
			"to" : 1940,
			"from" : 1939,
			"brick" : "B14",
			"name" : "34047",
			"uuid" : "390c050f-6ca8-8046-8c15-10f4bf65d9c2",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 34048,
			"tags" : [
				"B14"
			],
			"type" : "sectionRound",
			"to" : 1937,
			"from" : 1940,
			"brick" : "B14",
			"name" : "34048",
			"uuid" : "c8b2a02d-1bcc-5c40-a945-62d49be78a75",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 34049,
			"tags" : [
				"B14"
			],
			"type" : "sectionRound",
			"to" : 1961,
			"from" : 1941,
			"brick" : "B14",
			"name" : "34049",
			"uuid" : "823625de-5b4c-6a47-8c8e-804c15f7fb00",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 34050,
			"tags" : [
				"B14"
			],
			"type" : "sectionRound",
			"to" : 1942,
			"from" : 1961,
			"brick" : "B14",
			"name" : "34050",
			"uuid" : "fe0127f8-1014-a04f-bf30-90f6cc2340ff",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 34051,
			"tags" : [
				"B14"
			],
			"type" : "sectionRound",
			"to" : 1962,
			"from" : 1942,
			"brick" : "B14",
			"name" : "34051",
			"uuid" : "3199d464-4e45-6042-8d9e-28f5c9065fa6",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 34052,
			"tags" : [
				"B14"
			],
			"type" : "sectionRound",
			"to" : 1943,
			"from" : 1962,
			"brick" : "B14",
			"name" : "34052",
			"uuid" : "5842b7ef-33c5-724d-8875-6cb04f47ed22",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 34053,
			"tags" : [
				"B14"
			],
			"type" : "sectionRound",
			"to" : 1963,
			"from" : 1943,
			"brick" : "B14",
			"name" : "34053",
			"uuid" : "574d7382-d1e5-c94b-8c88-8b044a5531d9",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 34054,
			"tags" : [
				"B14"
			],
			"type" : "sectionRound",
			"to" : 1944,
			"from" : 1963,
			"brick" : "B14",
			"name" : "34054",
			"uuid" : "f74b61b9-ce85-e741-b3a6-da4e25ce5b42",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 34055,
			"tags" : [
				"B14"
			],
			"type" : "sectionRound",
			"to" : 1964,
			"from" : 1944,
			"brick" : "B14",
			"name" : "34055",
			"uuid" : "cc40b30f-e579-f94e-b71b-aab4ab748bf3",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 34056,
			"tags" : [
				"B14"
			],
			"type" : "sectionRound",
			"to" : 1941,
			"from" : 1964,
			"brick" : "B14",
			"name" : "34056",
			"uuid" : "358984a7-b2dc-6f46-a3ac-a67eb9efbf6d",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 34057,
			"tags" : [
				"B14"
			],
			"type" : "sectionRound",
			"to" : 1946,
			"from" : 1945,
			"brick" : "B14",
			"name" : "34057",
			"uuid" : "5b6eeaef-45be-c949-838c-fa011c7a1acf",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 34058,
			"tags" : [
				"B14"
			],
			"type" : "sectionRound",
			"to" : 1947,
			"from" : 1946,
			"brick" : "B14",
			"name" : "34058",
			"uuid" : "df882cfe-1efb-0b40-8382-197c9f9fa9c2",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 34059,
			"tags" : [
				"B14"
			],
			"type" : "sectionRound",
			"to" : 1948,
			"from" : 1947,
			"brick" : "B14",
			"name" : "34059",
			"uuid" : "b51614fc-bdae-ca40-b168-3a6ecce5a84a",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 34060,
			"tags" : [
				"B14"
			],
			"type" : "sectionRound",
			"to" : 1945,
			"from" : 1948,
			"brick" : "B14",
			"name" : "34060",
			"uuid" : "02990afe-7d51-3e40-9476-127e7006d377",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 34061,
			"tags" : [
				"B14"
			],
			"type" : "sectionRound",
			"to" : 1950,
			"from" : 1949,
			"brick" : "B14",
			"name" : "34061",
			"uuid" : "446149db-457f-814b-883c-2852d4ffc80a",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 34062,
			"tags" : [
				"B14"
			],
			"type" : "sectionRound",
			"to" : 1951,
			"from" : 1950,
			"brick" : "B14",
			"name" : "34062",
			"uuid" : "5d27123b-24a9-db4e-b217-4fac7b2aa555",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 34063,
			"tags" : [
				"B14"
			],
			"type" : "sectionRound",
			"to" : 1952,
			"from" : 1951,
			"brick" : "B14",
			"name" : "34063",
			"uuid" : "cc040919-ec90-b040-a18f-bb198f5aec35",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 34064,
			"tags" : [
				"B14"
			],
			"type" : "sectionRound",
			"to" : 1949,
			"from" : 1952,
			"brick" : "B14",
			"name" : "34064",
			"uuid" : "6d3592c7-faf5-6b49-97f9-8b9dc3d77b95",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 34101,
			"tags" : [
				"B14"
			],
			"type" : "sectionSlant",
			"to" : 1905,
			"from" : 2801,
			"brick" : "B14",
			"name" : "34101",
			"uuid" : "2fd4aea0-8880-634c-ada9-67fd9471aeee",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 34102,
			"tags" : [
				"B14"
			],
			"type" : "sectionSlant",
			"to" : 2801,
			"from" : 1907,
			"brick" : "B14",
			"name" : "34102",
			"uuid" : "b8b60e96-3ec2-6440-9418-155b0d62741c",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 34103,
			"tags" : [
				"B14"
			],
			"type" : "sectionSlant",
			"to" : 1908,
			"from" : 2801,
			"brick" : "B14",
			"name" : "34103",
			"uuid" : "0f34e1a6-b7e2-a949-a0f4-e8d63c71927c",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 34104,
			"tags" : [
				"B14"
			],
			"type" : "sectionSlant",
			"to" : 2801,
			"from" : 1906,
			"brick" : "B14",
			"name" : "34104",
			"uuid" : "e51d7d4b-1013-c64d-b8fc-a9db55e57437",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 34105,
			"tags" : [
				"B14"
			],
			"type" : "sectionSlant",
			"to" : 1909,
			"from" : 2802,
			"brick" : "B14",
			"name" : "34105",
			"uuid" : "8e643414-e97a-4448-b76e-5b4aa7589c8f",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 34106,
			"tags" : [
				"B14"
			],
			"type" : "sectionSlant",
			"to" : 2802,
			"from" : 1911,
			"brick" : "B14",
			"name" : "34106",
			"uuid" : "30cb06a3-9e1f-be45-84df-9686e23af0d3",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 34107,
			"tags" : [
				"B14"
			],
			"type" : "sectionSlant",
			"to" : 1912,
			"from" : 2802,
			"brick" : "B14",
			"name" : "34107",
			"uuid" : "c4994af4-c6e8-864b-93df-c8cb5b1bc0a5",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 34108,
			"tags" : [
				"B14"
			],
			"type" : "sectionSlant",
			"to" : 2802,
			"from" : 1910,
			"brick" : "B14",
			"name" : "34108",
			"uuid" : "d88ea05f-2298-b146-becf-ae4cfcacd906",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 34109,
			"tags" : [
				"B14"
			],
			"type" : "sectionSlant",
			"to" : 1925,
			"from" : 2803,
			"brick" : "B14",
			"name" : "34109",
			"uuid" : "9370c9b4-ce1b-3b46-bc48-9b1926e88868",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 34110,
			"tags" : [
				"B14"
			],
			"type" : "sectionSlant",
			"to" : 2803,
			"from" : 1927,
			"brick" : "B14",
			"name" : "34110",
			"uuid" : "22f23b1b-aaa9-1644-b0d1-30bac39a4ce6",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 34111,
			"tags" : [
				"B14"
			],
			"type" : "sectionSlant",
			"to" : 1928,
			"from" : 2803,
			"brick" : "B14",
			"name" : "34111",
			"uuid" : "724f273d-3b0c-3042-9d5d-2ab9b56728ea",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 34112,
			"tags" : [
				"B14"
			],
			"type" : "sectionSlant",
			"to" : 2803,
			"from" : 1926,
			"brick" : "B14",
			"name" : "34112",
			"uuid" : "6a191cdb-7db2-ed42-9594-861e42c9007d",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 34113,
			"tags" : [
				"B14"
			],
			"type" : "sectionSlant",
			"to" : 1941,
			"from" : 2804,
			"brick" : "B14",
			"name" : "34113",
			"uuid" : "8ee82781-acf3-7a40-8418-34cc5aa6e4dd",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 34114,
			"tags" : [
				"B14"
			],
			"type" : "sectionSlant",
			"to" : 2804,
			"from" : 1943,
			"brick" : "B14",
			"name" : "34114",
			"uuid" : "44fc643f-0fec-2145-bb0a-a5fc6440410b",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 34115,
			"tags" : [
				"B14"
			],
			"type" : "sectionSlant",
			"to" : 1944,
			"from" : 2804,
			"brick" : "B14",
			"name" : "34115",
			"uuid" : "01781ab1-3f4b-7446-aef8-7145eb5b292a",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 34116,
			"tags" : [
				"B14"
			],
			"type" : "sectionSlant",
			"to" : 2804,
			"from" : 1942,
			"brick" : "B14",
			"name" : "34116",
			"uuid" : "eafdb6b4-429e-3c42-932c-9443f1ea2a58",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 34117,
			"tags" : [
				"B14"
			],
			"type" : "sectionSlant",
			"to" : 1945,
			"from" : 2805,
			"brick" : "B14",
			"name" : "34117",
			"uuid" : "3439bd1d-3c6e-3448-82a3-273316c9de44",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 34118,
			"tags" : [
				"B14"
			],
			"type" : "sectionSlant",
			"to" : 2805,
			"from" : 1947,
			"brick" : "B14",
			"name" : "34118",
			"uuid" : "66c71c63-f8a9-4e40-927b-a67ef1348e8b",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 34119,
			"tags" : [
				"B14"
			],
			"type" : "sectionSlant",
			"to" : 1948,
			"from" : 2805,
			"brick" : "B14",
			"name" : "34119",
			"uuid" : "4cf241de-416b-8640-b7ca-331205991bf5",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 34120,
			"tags" : [
				"B14"
			],
			"type" : "sectionSlant",
			"to" : 2805,
			"from" : 1946,
			"brick" : "B14",
			"name" : "34120",
			"uuid" : "75f91b93-3b46-c740-b819-9b1cfc665c55",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 34121,
			"tags" : [
				"B14"
			],
			"type" : "sectionVertical",
			"to" : 1956,
			"from" : 2802,
			"brick" : "B14",
			"name" : "34121",
			"uuid" : "d02cf230-c683-0146-a99e-0b8eed629599",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 34122,
			"tags" : [
				"B14"
			],
			"type" : "sectionVertical",
			"to" : 2802,
			"from" : 1954,
			"brick" : "B14",
			"name" : "34122",
			"uuid" : "d387e325-ce97-1343-8128-79525357ee36",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 34123,
			"tags" : [
				"B14"
			],
			"type" : "sectionVertical",
			"to" : 1960,
			"from" : 2803,
			"brick" : "B14",
			"name" : "34123",
			"uuid" : "6d6e89c2-ec4c-e44c-a757-4c024760c457",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 34124,
			"tags" : [
				"B14"
			],
			"type" : "sectionVertical",
			"to" : 2803,
			"from" : 1958,
			"brick" : "B14",
			"name" : "34124",
			"uuid" : "eb0bdac9-df4f-864c-b48b-e32377cf6ee5",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 34125,
			"tags" : [
				"B14"
			],
			"type" : "sectionVertical",
			"to" : 1964,
			"from" : 2804,
			"brick" : "B14",
			"name" : "34125",
			"uuid" : "8daab3df-14f7-fe4b-b6dc-16e211a9845a",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 34126,
			"tags" : [
				"B14"
			],
			"type" : "sectionVertical",
			"to" : 2804,
			"from" : 1962,
			"brick" : "B14",
			"name" : "34126",
			"uuid" : "1c4f4874-ccfe-ab4b-b914-ba0827030c73",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 34127,
			"tags" : [
				"B14"
			],
			"type" : "sectionHorizontal",
			"to" : 2802,
			"from" : 1955,
			"brick" : "B14",
			"name" : "34127",
			"uuid" : "ce22003f-ffb0-fa48-b264-60994efb41e1",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 34128,
			"tags" : [
				"B14"
			],
			"type" : "sectionHorizontal",
			"to" : 1953,
			"from" : 2802,
			"brick" : "B14",
			"name" : "34128",
			"uuid" : "12d9868b-44f3-ce44-b869-1317ac9f7a3e",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 34129,
			"tags" : [
				"B14"
			],
			"type" : "sectionHorizontal",
			"to" : 2803,
			"from" : 1959,
			"brick" : "B14",
			"name" : "34129",
			"uuid" : "7b7932c9-dac6-a248-ba6f-f461147b2847",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 34130,
			"tags" : [
				"B14"
			],
			"type" : "sectionHorizontal",
			"to" : 1957,
			"from" : 2803,
			"brick" : "B14",
			"name" : "34130",
			"uuid" : "9524a536-b6bf-d649-8513-8ee2b8d7a1b8",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 34131,
			"tags" : [
				"B14"
			],
			"type" : "sectionHorizontal",
			"to" : 2804,
			"from" : 1963,
			"brick" : "B14",
			"name" : "34131",
			"uuid" : "e2b6a8e0-7c97-164b-8e18-d8b6170dc924",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 34132,
			"tags" : [
				"B14"
			],
			"type" : "sectionHorizontal",
			"to" : 1961,
			"from" : 2804,
			"brick" : "B14",
			"name" : "34132",
			"uuid" : "bacc8b59-3058-7740-9272-4ef901b3c54e",
			"_clazz" : "TwkSegment"
		},
		{
			"uuid" : "6261922f-2422-6449-8cb2-594e9b23eae2",
			"name" : "25001",
			"_clazz" : "TwkSegment",
			"brick" : "FRONT",
			"from" : 1201,
			"face" : "front",
			"tags" : [
				"B14"
			],
			"type" : "panel",
			"to" : 1902,
			"number" : 25001
		},
		{
			"uuid" : "65ff1402-399d-154b-859b-0cf2348369c8",
			"name" : "25002",
			"_clazz" : "TwkSegment",
			"brick" : "BOTTOM",
			"from" : 1208,
			"face" : "bottom",
			"tags" : [
				"B14"
			],
			"type" : "panel",
			"to" : 1902,
			"number" : 25002
		},
		{
			"uuid" : "58eb414e-1517-1c42-affd-ef70c3285797",
			"name" : "25003",
			"_clazz" : "TwkSegment",
			"brick" : "BACK",
			"from" : 1208,
			"face" : "back",
			"tags" : [
				"B14"
			],
			"type" : "panel",
			"to" : 1904,
			"number" : 25003
		},
		{
			"uuid" : "b3141fa3-d4f4-f54c-84cc-62a8e2dfb9cd",
			"name" : "25004",
			"_clazz" : "TwkSegment",
			"brick" : "TOP",
			"from" : 1201,
			"face" : "top",
			"tags" : [
				"B14"
			],
			"type" : "panel",
			"to" : 1904,
			"number" : 25004
		},
		{
			"uuid" : "a6e7aa22-4d32-2649-8295-b4c711443dca",
			"name" : "25005",
			"_clazz" : "TwkSegment",
			"brick" : "FRONT",
			"from" : 1901,
			"face" : "front",
			"tags" : [
				"B14"
			],
			"type" : "panel",
			"to" : 1906,
			"number" : 25005
		},
		{
			"uuid" : "027cdbdd-46fa-7240-8768-f804ff4ed5b6",
			"name" : "25006",
			"_clazz" : "TwkSegment",
			"brick" : "BOTTOM",
			"from" : 1903,
			"face" : "bottom",
			"tags" : [
				"B14"
			],
			"type" : "panel",
			"to" : 1906,
			"number" : 25006
		},
		{
			"uuid" : "b13ad24f-a9a2-4d4d-9af2-3bcdc4a081d9",
			"name" : "25007",
			"_clazz" : "TwkSegment",
			"brick" : "BACK",
			"from" : 1903,
			"face" : "back",
			"tags" : [
				"B14"
			],
			"type" : "panel",
			"to" : 1908,
			"number" : 25007
		},
		{
			"uuid" : "84eb91fe-8cb6-1b40-81ab-1494eb4948dc",
			"name" : "25008",
			"_clazz" : "TwkSegment",
			"brick" : "TOP",
			"from" : 1901,
			"face" : "top",
			"tags" : [
				"B14"
			],
			"type" : "panel",
			"to" : 1908,
			"number" : 25008
		},
		{
			"uuid" : "7b024a3c-c17f-9f42-9f99-94542b7b56cb",
			"name" : "25009",
			"_clazz" : "TwkSegment",
			"brick" : "FRONT",
			"from" : 1905,
			"face" : "front",
			"tags" : [
				"B14"
			],
			"type" : "panel",
			"to" : 1910,
			"number" : 25009
		},
		{
			"uuid" : "8e82c47d-ddff-9748-85e2-3bb349ce5f2a",
			"name" : "25010",
			"_clazz" : "TwkSegment",
			"brick" : "BOTTOM",
			"from" : 1907,
			"face" : "bottom",
			"tags" : [
				"B14"
			],
			"type" : "panel",
			"to" : 1910,
			"number" : 25010
		},
		{
			"uuid" : "cc812b08-ea28-2e43-b244-8f3f4e0033b2",
			"name" : "25011",
			"_clazz" : "TwkSegment",
			"brick" : "BACK",
			"from" : 1907,
			"face" : "back",
			"tags" : [
				"B14"
			],
			"type" : "panel",
			"to" : 1912,
			"number" : 25011
		},
		{
			"uuid" : "463c5e64-a6b0-2b4f-9b29-d0872cf81190",
			"name" : "25012",
			"_clazz" : "TwkSegment",
			"brick" : "TOP",
			"from" : 1905,
			"face" : "top",
			"tags" : [
				"B14"
			],
			"type" : "panel",
			"to" : 1912,
			"number" : 25012
		},
		{
			"uuid" : "4b96153e-a09d-f04d-9848-e6876592faa0",
			"name" : "25013",
			"_clazz" : "TwkSegment",
			"brick" : "FRONT",
			"from" : 1909,
			"face" : "front",
			"tags" : [
				"B14"
			],
			"type" : "panel",
			"to" : 1914,
			"number" : 25013
		},
		{
			"uuid" : "381a79d3-d384-2046-8f28-3212c6b8fb16",
			"name" : "25014",
			"_clazz" : "TwkSegment",
			"brick" : "BOTTOM",
			"from" : 1911,
			"face" : "bottom",
			"tags" : [
				"B14"
			],
			"type" : "panel",
			"to" : 1914,
			"number" : 25014
		},
		{
			"uuid" : "59d41fcf-f94f-dd45-9010-24ad5ad5d806",
			"name" : "25015",
			"_clazz" : "TwkSegment",
			"brick" : "BACK",
			"from" : 1911,
			"face" : "back",
			"tags" : [
				"B14"
			],
			"type" : "panel",
			"to" : 1916,
			"number" : 25015
		},
		{
			"uuid" : "0f36dbd7-29ad-5a42-817c-cb1d62662b75",
			"name" : "25016",
			"_clazz" : "TwkSegment",
			"brick" : "TOP",
			"from" : 1909,
			"face" : "top",
			"tags" : [
				"B14"
			],
			"type" : "panel",
			"to" : 1916,
			"number" : 25016
		},
		{
			"uuid" : "82569bec-eec2-5243-ad00-948814f3a3d8",
			"name" : "25017",
			"_clazz" : "TwkSegment",
			"brick" : "FRONT",
			"from" : 1913,
			"face" : "front",
			"tags" : [
				"B14"
			],
			"type" : "panel",
			"to" : 1918,
			"number" : 25017
		},
		{
			"uuid" : "dedba0c9-1c62-d94b-bc46-1811f70bc4b8",
			"name" : "25018",
			"_clazz" : "TwkSegment",
			"brick" : "BOTTOM",
			"from" : 1915,
			"face" : "bottom",
			"tags" : [
				"B14"
			],
			"type" : "panel",
			"to" : 1918,
			"number" : 25018
		},
		{
			"uuid" : "c1e4a117-baf2-7f49-9783-c5cd650eb366",
			"name" : "25019",
			"_clazz" : "TwkSegment",
			"brick" : "BACK",
			"from" : 1915,
			"face" : "back",
			"tags" : [
				"B14"
			],
			"type" : "panel",
			"to" : 1920,
			"number" : 25019
		},
		{
			"uuid" : "f6cf41b6-d5d4-a842-961c-2d0e8160e32c",
			"name" : "25020",
			"_clazz" : "TwkSegment",
			"brick" : "TOP",
			"from" : 1913,
			"face" : "top",
			"tags" : [
				"B14"
			],
			"type" : "panel",
			"to" : 1920,
			"number" : 25020
		},
		{
			"uuid" : "536334e3-00c6-b344-9d80-9addb91c5f33",
			"name" : "25021",
			"_clazz" : "TwkSegment",
			"brick" : "FRONT",
			"from" : 1917,
			"face" : "front",
			"tags" : [
				"B14"
			],
			"type" : "panel",
			"to" : 1922,
			"number" : 25021
		},
		{
			"uuid" : "c70176bb-dd61-774e-b385-d0ff80488667",
			"name" : "25022",
			"_clazz" : "TwkSegment",
			"brick" : "BOTTOM",
			"from" : 1919,
			"face" : "bottom",
			"tags" : [
				"B14"
			],
			"type" : "panel",
			"to" : 1922,
			"number" : 25022
		},
		{
			"uuid" : "098ea84a-fd2e-db49-b209-1d48ca69e3a3",
			"name" : "25023",
			"_clazz" : "TwkSegment",
			"brick" : "BACK",
			"from" : 1919,
			"face" : "back",
			"tags" : [
				"B14"
			],
			"type" : "panel",
			"to" : 1924,
			"number" : 25023
		},
		{
			"uuid" : "be9fa79a-817e-304c-9afc-99f982264b96",
			"name" : "25024",
			"_clazz" : "TwkSegment",
			"brick" : "TOP",
			"from" : 1917,
			"face" : "top",
			"tags" : [
				"B14"
			],
			"type" : "panel",
			"to" : 1924,
			"number" : 25024
		},
		{
			"uuid" : "d7404c3d-4a70-8244-b97e-2ea75c3a3adf",
			"name" : "25025",
			"_clazz" : "TwkSegment",
			"brick" : "FRONT",
			"from" : 1921,
			"face" : "front",
			"tags" : [
				"B14"
			],
			"type" : "panel",
			"to" : 1926,
			"number" : 25025
		},
		{
			"uuid" : "435fd1f7-9c12-d74f-b699-b5e23f33c617",
			"name" : "25026",
			"_clazz" : "TwkSegment",
			"brick" : "BOTTOM",
			"from" : 1923,
			"face" : "bottom",
			"tags" : [
				"B14"
			],
			"type" : "panel",
			"to" : 1926,
			"number" : 25026
		},
		{
			"uuid" : "421220a6-200b-6f4d-aa92-488fdae532fb",
			"name" : "25027",
			"_clazz" : "TwkSegment",
			"brick" : "BACK",
			"from" : 1923,
			"face" : "back",
			"tags" : [
				"B14"
			],
			"type" : "panel",
			"to" : 1928,
			"number" : 25027
		},
		{
			"uuid" : "4db9508e-e3da-7249-b1f8-0151d2206b5e",
			"name" : "25028",
			"_clazz" : "TwkSegment",
			"brick" : "TOP",
			"from" : 1921,
			"face" : "top",
			"tags" : [
				"B14"
			],
			"type" : "panel",
			"to" : 1928,
			"number" : 25028
		},
		{
			"uuid" : "aafdf899-672a-e04d-8d96-f4518265ac3a",
			"name" : "25029",
			"_clazz" : "TwkSegment",
			"brick" : "FRONT",
			"from" : 1926,
			"face" : "front",
			"tags" : [
				"B14"
			],
			"type" : "panel",
			"to" : 1929,
			"number" : 25029
		},
		{
			"uuid" : "d9a860af-bca5-0448-94be-4b1b0b8c6c6e",
			"name" : "25030",
			"_clazz" : "TwkSegment",
			"brick" : "BOTTOM",
			"from" : 1926,
			"face" : "bottom",
			"tags" : [
				"B14"
			],
			"type" : "panel",
			"to" : 1931,
			"number" : 25030
		},
		{
			"uuid" : "672dd687-3fed-ad4f-99ab-940a5848e60c",
			"name" : "25031",
			"_clazz" : "TwkSegment",
			"brick" : "BACK",
			"from" : 1928,
			"face" : "back",
			"tags" : [
				"B14"
			],
			"type" : "panel",
			"to" : 1931,
			"number" : 25031
		},
		{
			"uuid" : "cb490bcb-334d-c940-8e7c-b1b92e591667",
			"name" : "25032",
			"_clazz" : "TwkSegment",
			"brick" : "TOP",
			"from" : 1928,
			"face" : "top",
			"tags" : [
				"B14"
			],
			"type" : "panel",
			"to" : 1929,
			"number" : 25032
		},
		{
			"uuid" : "6b3e90cd-4411-614f-93d2-94323059fe18",
			"name" : "25033",
			"_clazz" : "TwkSegment",
			"brick" : "FRONT",
			"from" : 1930,
			"face" : "front",
			"tags" : [
				"B14"
			],
			"type" : "panel",
			"to" : 1933,
			"number" : 25033
		},
		{
			"uuid" : "f739b6a6-8a29-664d-9c8b-acda1c6e1ec9",
			"name" : "25034",
			"_clazz" : "TwkSegment",
			"brick" : "BOTTOM",
			"from" : 1930,
			"face" : "bottom",
			"tags" : [
				"B14"
			],
			"type" : "panel",
			"to" : 1935,
			"number" : 25034
		},
		{
			"uuid" : "8d93f2df-ef20-b146-ac87-6c0bcc937add",
			"name" : "25035",
			"_clazz" : "TwkSegment",
			"brick" : "BACK",
			"from" : 1932,
			"face" : "back",
			"tags" : [
				"B14"
			],
			"type" : "panel",
			"to" : 1935,
			"number" : 25035
		},
		{
			"uuid" : "30aa045a-42b7-f442-9996-16fc5d667472",
			"name" : "25036",
			"_clazz" : "TwkSegment",
			"brick" : "TOP",
			"from" : 1932,
			"face" : "top",
			"tags" : [
				"B14"
			],
			"type" : "panel",
			"to" : 1933,
			"number" : 25036
		},
		{
			"uuid" : "6767ca1d-b7c5-9f44-bf11-df985906af4c",
			"name" : "25037",
			"_clazz" : "TwkSegment",
			"brick" : "FRONT",
			"from" : 1934,
			"face" : "front",
			"tags" : [
				"B14"
			],
			"type" : "panel",
			"to" : 1937,
			"number" : 25037
		},
		{
			"uuid" : "6fcc6110-6053-cc4b-81e9-a2938d64a265",
			"name" : "25038",
			"_clazz" : "TwkSegment",
			"brick" : "BOTTOM",
			"from" : 1934,
			"face" : "bottom",
			"tags" : [
				"B14"
			],
			"type" : "panel",
			"to" : 1939,
			"number" : 25038
		},
		{
			"uuid" : "36386623-76ba-4447-a301-a93331c28bc2",
			"name" : "25039",
			"_clazz" : "TwkSegment",
			"brick" : "BACK",
			"from" : 1936,
			"face" : "back",
			"tags" : [
				"B14"
			],
			"type" : "panel",
			"to" : 1939,
			"number" : 25039
		},
		{
			"uuid" : "fc01f7de-ffc4-e247-9df9-5f86615d5760",
			"name" : "25040",
			"_clazz" : "TwkSegment",
			"brick" : "TOP",
			"from" : 1936,
			"face" : "top",
			"tags" : [
				"B14"
			],
			"type" : "panel",
			"to" : 1937,
			"number" : 25040
		},
		{
			"uuid" : "1065ff13-8b1e-5943-9e9c-4c59ace71b61",
			"name" : "25041",
			"_clazz" : "TwkSegment",
			"brick" : "FRONT",
			"from" : 1938,
			"face" : "front",
			"tags" : [
				"B14"
			],
			"type" : "panel",
			"to" : 1941,
			"number" : 25041
		},
		{
			"uuid" : "d8a84289-94a1-2047-9661-e42d641092d0",
			"name" : "25042",
			"_clazz" : "TwkSegment",
			"brick" : "BOTTOM",
			"from" : 1938,
			"face" : "bottom",
			"tags" : [
				"B14"
			],
			"type" : "panel",
			"to" : 1943,
			"number" : 25042
		},
		{
			"uuid" : "5239bb16-0f95-e147-823b-5b0495c2be1d",
			"name" : "25043",
			"_clazz" : "TwkSegment",
			"brick" : "BACK",
			"from" : 1940,
			"face" : "back",
			"tags" : [
				"B14"
			],
			"type" : "panel",
			"to" : 1943,
			"number" : 25043
		},
		{
			"uuid" : "4550ad35-e1fe-1d49-8aa8-3935b260f7e4",
			"name" : "25044",
			"_clazz" : "TwkSegment",
			"brick" : "TOP",
			"from" : 1940,
			"face" : "top",
			"tags" : [
				"B14"
			],
			"type" : "panel",
			"to" : 1941,
			"number" : 25044
		},
		{
			"uuid" : "f0cf2625-62e9-1547-9711-e51a8cd8cd3c",
			"name" : "25045",
			"_clazz" : "TwkSegment",
			"brick" : "FRONT",
			"from" : 1942,
			"face" : "front",
			"tags" : [
				"B14"
			],
			"type" : "panel",
			"to" : 1945,
			"number" : 25045
		},
		{
			"uuid" : "bb36bc70-30f4-a54c-8c71-4858a173b0f1",
			"name" : "25046",
			"_clazz" : "TwkSegment",
			"brick" : "BOTTOM",
			"from" : 1942,
			"face" : "bottom",
			"tags" : [
				"B14"
			],
			"type" : "panel",
			"to" : 1947,
			"number" : 25046
		},
		{
			"uuid" : "cd461cb7-0e86-8246-a60f-be7e440fbb7d",
			"name" : "25047",
			"_clazz" : "TwkSegment",
			"brick" : "BACK",
			"from" : 1944,
			"face" : "back",
			"tags" : [
				"B14"
			],
			"type" : "panel",
			"to" : 1947,
			"number" : 25047
		},
		{
			"uuid" : "8143b559-16ae-2a45-b1be-4657c1ab5700",
			"name" : "25048",
			"_clazz" : "TwkSegment",
			"brick" : "TOP",
			"from" : 1944,
			"face" : "top",
			"tags" : [
				"B14"
			],
			"type" : "panel",
			"to" : 1945,
			"number" : 25048
		},
		{
			"uuid" : "b450d4df-3bff-bd48-af0d-8dfbdae7e5dc",
			"name" : "25049",
			"_clazz" : "TwkSegment",
			"brick" : "FRONT",
			"from" : 1946,
			"face" : "front",
			"tags" : [
				"B14"
			],
			"type" : "panel",
			"to" : 1949,
			"number" : 25049
		},
		{
			"uuid" : "d49e1fd7-1bd4-624d-8e71-d10128270db5",
			"name" : "25050",
			"_clazz" : "TwkSegment",
			"brick" : "BOTTOM",
			"from" : 1946,
			"face" : "bottom",
			"tags" : [
				"B14"
			],
			"type" : "panel",
			"to" : 1951,
			"number" : 25050
		},
		{
			"uuid" : "f4071cca-1c85-5d4b-a052-920feeb21a91",
			"name" : "25051",
			"_clazz" : "TwkSegment",
			"brick" : "BACK",
			"from" : 1948,
			"face" : "back",
			"tags" : [
				"B14"
			],
			"type" : "panel",
			"to" : 1951,
			"number" : 25051
		},
		{
			"uuid" : "46e817d5-66dd-db4d-b7e7-b1cad939c26c",
			"name" : "25052",
			"_clazz" : "TwkSegment",
			"brick" : "TOP",
			"from" : 1948,
			"face" : "top",
			"tags" : [
				"B14"
			],
			"type" : "panel",
			"to" : 1949,
			"number" : 25052
		},
		{
			"uuid" : "f24e2f53-bb0f-2f49-9517-e4ef1ceee613",
			"name" : "25053",
			"_clazz" : "TwkSegment",
			"brick" : "FRONT",
			"from" : 1950,
			"face" : "front",
			"tags" : [
				"B14"
			],
			"type" : "panel",
			"to" : 1318,
			"number" : 25053
		},
		{
			"uuid" : "6b03cd9c-8265-6048-a459-11a137efb3df",
			"name" : "25054",
			"_clazz" : "TwkSegment",
			"brick" : "BOTTOM",
			"from" : 1950,
			"face" : "bottom",
			"tags" : [
				"B14"
			],
			"type" : "panel",
			"to" : 1323,
			"number" : 25054
		},
		{
			"uuid" : "b13d0b73-d495-3140-ac98-ad5a1b2afefb",
			"name" : "25055",
			"_clazz" : "TwkSegment",
			"brick" : "BACK",
			"from" : 1952,
			"face" : "back",
			"tags" : [
				"B14"
			],
			"type" : "panel",
			"to" : 1323,
			"number" : 25055
		},
		{
			"uuid" : "feaa1f08-d2f6-6b4e-8698-186d466344c0",
			"name" : "25056",
			"_clazz" : "TwkSegment",
			"brick" : "TOP",
			"from" : 1952,
			"face" : "top",
			"tags" : [
				"B14"
			],
			"type" : "panel",
			"to" : 1318,
			"number" : 25056
		},
		{
			"number" : 17001,
			"tags" : [
				"B15"
			],
			"type" : "slope",
			"to" : 2001,
			"from" : 1317,
			"brick" : "B15",
			"name" : "17001",
			"uuid" : "010d2918-3bd2-2e41-9828-392cb81cd1cf",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 17002,
			"tags" : [
				"B15"
			],
			"type" : "slope",
			"to" : 2002,
			"from" : 1321,
			"brick" : "B15",
			"name" : "17002",
			"uuid" : "525c8744-9e96-6842-b65b-d867d01b6844",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 17003,
			"tags" : [
				"B15"
			],
			"type" : "slope",
			"to" : 2003,
			"from" : 1324,
			"brick" : "B15",
			"name" : "17003",
			"uuid" : "7ec4ca08-8e83-974f-b068-ec9b884f0c35",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 17004,
			"tags" : [
				"B15"
			],
			"type" : "slope",
			"to" : 2004,
			"from" : 1320,
			"brick" : "B15",
			"name" : "17004",
			"uuid" : "1b8aeb52-63e4-0443-8a6f-1cc6f3fd6915",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 17005,
			"tags" : [
				"B15"
			],
			"type" : "slope",
			"to" : 2005,
			"from" : 2001,
			"brick" : "B15",
			"name" : "17005",
			"uuid" : "a9780a6a-f4c0-1142-9f55-ed7e1b0f53f5",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 17006,
			"tags" : [
				"B15"
			],
			"type" : "slope",
			"to" : 2006,
			"from" : 2002,
			"brick" : "B15",
			"name" : "17006",
			"uuid" : "a125a262-b2e1-854a-8ef7-1a75267071d1",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 17007,
			"tags" : [
				"B15"
			],
			"type" : "slope",
			"to" : 2007,
			"from" : 2003,
			"brick" : "B15",
			"name" : "17007",
			"uuid" : "d884d4b5-637f-4743-b9a7-e4403d78ffb0",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 17008,
			"tags" : [
				"B15"
			],
			"type" : "slope",
			"to" : 2008,
			"from" : 2004,
			"brick" : "B15",
			"name" : "17008",
			"uuid" : "27f434fe-3e92-a14a-be27-9565436c4024",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 17009,
			"tags" : [
				"B15"
			],
			"type" : "slope",
			"to" : 2009,
			"from" : 2005,
			"brick" : "B15",
			"name" : "17009",
			"uuid" : "a05f1722-6d02-1b41-a594-3868334f188f",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 17010,
			"tags" : [
				"B15"
			],
			"type" : "slope",
			"to" : 2010,
			"from" : 2006,
			"brick" : "B15",
			"name" : "17010",
			"uuid" : "d5ccf538-68e1-154a-9ddf-c95a899d90f8",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 17011,
			"tags" : [
				"B15"
			],
			"type" : "slope",
			"to" : 2011,
			"from" : 2007,
			"brick" : "B15",
			"name" : "17011",
			"uuid" : "b1ff3831-86e7-6041-a712-170a232a56b7",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 17012,
			"tags" : [
				"B15"
			],
			"type" : "slope",
			"to" : 2012,
			"from" : 2008,
			"brick" : "B15",
			"name" : "17012",
			"uuid" : "dacbfb6f-b3b9-2d46-aeec-c91a7cbd6851",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 17013,
			"tags" : [
				"B15"
			],
			"type" : "slope",
			"to" : 2013,
			"from" : 2009,
			"brick" : "B15",
			"name" : "17013",
			"uuid" : "dde78a9d-1bf3-9245-b5ac-ca13b037fbb8",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 17014,
			"tags" : [
				"B15"
			],
			"type" : "slope",
			"to" : 2014,
			"from" : 2010,
			"brick" : "B15",
			"name" : "17014",
			"uuid" : "efa06439-cd1f-7442-b31d-1ae7c79999e1",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 17015,
			"tags" : [
				"B15"
			],
			"type" : "slope",
			"to" : 2015,
			"from" : 2011,
			"brick" : "B15",
			"name" : "17015",
			"uuid" : "2cc9bcf5-0224-0645-8e48-686c43b0a75c",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 17016,
			"tags" : [
				"B15"
			],
			"type" : "slope",
			"to" : 2016,
			"from" : 2012,
			"brick" : "B15",
			"name" : "17016",
			"uuid" : "5655333b-82b4-0144-9773-0214f3b85cd6",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 17017,
			"tags" : [
				"B15"
			],
			"type" : "slope",
			"to" : 2017,
			"from" : 2013,
			"brick" : "B15",
			"name" : "17017",
			"uuid" : "85e6fdfd-382d-f545-ab54-c5776e927781",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 17018,
			"tags" : [
				"B15"
			],
			"type" : "slope",
			"to" : 2018,
			"from" : 2014,
			"brick" : "B15",
			"name" : "17018",
			"uuid" : "20c96d57-d2a3-cb40-a0ef-ba5d005ccad5",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 17019,
			"tags" : [
				"B15"
			],
			"type" : "slope",
			"to" : 2019,
			"from" : 2015,
			"brick" : "B15",
			"name" : "17019",
			"uuid" : "3645f19b-0cb0-124b-9831-a3049effac38",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 17020,
			"tags" : [
				"B15"
			],
			"type" : "slope",
			"to" : 2020,
			"from" : 2016,
			"brick" : "B15",
			"name" : "17020",
			"uuid" : "479835e1-a81d-0947-910b-f243154531dc",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 17021,
			"tags" : [
				"B15"
			],
			"type" : "slope",
			"to" : 2021,
			"from" : 2017,
			"brick" : "B15",
			"name" : "17021",
			"uuid" : "a3c6bd21-74e0-b542-903d-880207c70a40",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 17022,
			"tags" : [
				"B15"
			],
			"type" : "slope",
			"to" : 2022,
			"from" : 2018,
			"brick" : "B15",
			"name" : "17022",
			"uuid" : "2869fdb2-4ed7-0c42-ba3e-d03d6750e87b",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 17023,
			"tags" : [
				"B15"
			],
			"type" : "slope",
			"to" : 2023,
			"from" : 2019,
			"brick" : "B15",
			"name" : "17023",
			"uuid" : "59cfb4a4-4284-d04d-b5f5-41252acb8604",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 17024,
			"tags" : [
				"B15"
			],
			"type" : "slope",
			"to" : 2024,
			"from" : 2020,
			"brick" : "B15",
			"name" : "17024",
			"uuid" : "906addde-9d42-724c-b2ce-e9b0bf2504b6",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 17025,
			"tags" : [
				"B15"
			],
			"type" : "slope",
			"to" : 2025,
			"from" : 2021,
			"brick" : "B15",
			"name" : "17025",
			"uuid" : "efc9ec27-5ac8-c441-991f-242697242e10",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 17026,
			"tags" : [
				"B15"
			],
			"type" : "slope",
			"to" : 2026,
			"from" : 2022,
			"brick" : "B15",
			"name" : "17026",
			"uuid" : "6c29c33f-5209-164b-8d86-a26ae093334f",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 17027,
			"tags" : [
				"B15"
			],
			"type" : "slope",
			"to" : 2027,
			"from" : 2023,
			"brick" : "B15",
			"name" : "17027",
			"uuid" : "6f0ee5de-0e88-9349-8190-47ee2c69d349",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 17028,
			"tags" : [
				"B15"
			],
			"type" : "slope",
			"to" : 2028,
			"from" : 2024,
			"brick" : "B15",
			"name" : "17028",
			"uuid" : "064eeaff-7dee-1345-886a-2918b622e47a",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 17029,
			"tags" : [
				"B15"
			],
			"type" : "slope",
			"to" : 2029,
			"from" : 2025,
			"brick" : "B15",
			"name" : "17029",
			"uuid" : "f250ce26-80c5-1644-9932-1cf13d73d2e4",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 17030,
			"tags" : [
				"B15"
			],
			"type" : "slope",
			"to" : 2030,
			"from" : 2026,
			"brick" : "B15",
			"name" : "17030",
			"uuid" : "a852df66-039f-af48-be3e-71ba51df3bdf",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 17031,
			"tags" : [
				"B15"
			],
			"type" : "slope",
			"to" : 2031,
			"from" : 2027,
			"brick" : "B15",
			"name" : "17031",
			"uuid" : "7dd4f998-83be-0946-870d-346870fb2b47",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 17032,
			"tags" : [
				"B15"
			],
			"type" : "slope",
			"to" : 2032,
			"from" : 2028,
			"brick" : "B15",
			"name" : "17032",
			"uuid" : "d9911c16-5ba9-b048-9f53-12335a3b658e",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 17033,
			"tags" : [
				"B15"
			],
			"type" : "slope",
			"to" : 2033,
			"from" : 2029,
			"brick" : "B15",
			"name" : "17033",
			"uuid" : "074767db-8455-fc4b-800c-1ac27d778eac",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 17034,
			"tags" : [
				"B15"
			],
			"type" : "slope",
			"to" : 2034,
			"from" : 2030,
			"brick" : "B15",
			"name" : "17034",
			"uuid" : "85100d77-651b-2d45-adfc-074c99a3c976",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 17035,
			"tags" : [
				"B15"
			],
			"type" : "slope",
			"to" : 2035,
			"from" : 2031,
			"brick" : "B15",
			"name" : "17035",
			"uuid" : "4a599147-77f1-2f49-88e0-a2b0518a7f0d",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 17036,
			"tags" : [
				"B15"
			],
			"type" : "slope",
			"to" : 2036,
			"from" : 2032,
			"brick" : "B15",
			"name" : "17036",
			"uuid" : "a39d0c02-cba9-9749-bcd4-7e6350fad5d9",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 17037,
			"tags" : [
				"B15"
			],
			"type" : "slope",
			"to" : 2037,
			"from" : 2033,
			"brick" : "B15",
			"name" : "17037",
			"uuid" : "3e8c686d-8db0-fb49-a031-da1bce76a3ea",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 17038,
			"tags" : [
				"B15"
			],
			"type" : "slope",
			"to" : 2038,
			"from" : 2034,
			"brick" : "B15",
			"name" : "17038",
			"uuid" : "3c194e19-bfc3-4e44-8d17-21103f35bd75",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 17039,
			"tags" : [
				"B15"
			],
			"type" : "slope",
			"to" : 2039,
			"from" : 2035,
			"brick" : "B15",
			"name" : "17039",
			"uuid" : "10c99e9d-a016-654c-a069-4134595c3cf4",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 17040,
			"tags" : [
				"B15"
			],
			"type" : "slope",
			"to" : 2040,
			"from" : 2036,
			"brick" : "B15",
			"name" : "17040",
			"uuid" : "13c0e579-9ce0-1747-8a9a-8b911ea6a140",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 17041,
			"tags" : [
				"B15"
			],
			"type" : "slope",
			"to" : 2041,
			"from" : 2037,
			"brick" : "B15",
			"name" : "17041",
			"uuid" : "4f236799-8344-0645-871d-45cd5ee37852",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 17042,
			"tags" : [
				"B15"
			],
			"type" : "slope",
			"to" : 2042,
			"from" : 2038,
			"brick" : "B15",
			"name" : "17042",
			"uuid" : "0a9bcf07-b881-e540-9a78-cbe90fbe5205",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 17043,
			"tags" : [
				"B15"
			],
			"type" : "slope",
			"to" : 2043,
			"from" : 2039,
			"brick" : "B15",
			"name" : "17043",
			"uuid" : "0022589d-82bc-5f49-85a2-50f336ad41c1",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 17044,
			"tags" : [
				"B15"
			],
			"type" : "slope",
			"to" : 2044,
			"from" : 2040,
			"brick" : "B15",
			"name" : "17044",
			"uuid" : "73fec468-5726-f74b-adc4-8af4cd9463cb",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 17045,
			"tags" : [
				"B15"
			],
			"type" : "slope",
			"to" : 2045,
			"from" : 2041,
			"brick" : "B15",
			"name" : "17045",
			"uuid" : "e163d3b6-7aef-f74a-85b7-f3a523055eb0",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 17046,
			"tags" : [
				"B15"
			],
			"type" : "slope",
			"to" : 2046,
			"from" : 2042,
			"brick" : "B15",
			"name" : "17046",
			"uuid" : "2e42d13b-d6ad-684d-8663-6ec5f84ff45a",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 17047,
			"tags" : [
				"B15"
			],
			"type" : "slope",
			"to" : 2047,
			"from" : 2043,
			"brick" : "B15",
			"name" : "17047",
			"uuid" : "a7e6cbb9-ae9a-e443-8ea7-1a7db73a7a5f",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 17048,
			"tags" : [
				"B15"
			],
			"type" : "slope",
			"to" : 2048,
			"from" : 2044,
			"brick" : "B15",
			"name" : "17048",
			"uuid" : "c45983da-e1eb-0149-8a0a-290c7017e9b7",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 17049,
			"tags" : [
				"B15"
			],
			"type" : "slope",
			"to" : 2049,
			"from" : 2045,
			"brick" : "B15",
			"name" : "17049",
			"uuid" : "6467e9f6-bd8b-ae49-a8c9-6745741fe35d",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 17050,
			"tags" : [
				"B15"
			],
			"type" : "slope",
			"to" : 2050,
			"from" : 2046,
			"brick" : "B15",
			"name" : "17050",
			"uuid" : "44860bf9-1c78-aa4d-835f-a130d4901ec6",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 17051,
			"tags" : [
				"B15"
			],
			"type" : "slope",
			"to" : 2051,
			"from" : 2047,
			"brick" : "B15",
			"name" : "17051",
			"uuid" : "400d1075-9f0e-e644-bb69-9580683c4914",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 17052,
			"tags" : [
				"B15"
			],
			"type" : "slope",
			"to" : 2052,
			"from" : 2048,
			"brick" : "B15",
			"name" : "17052",
			"uuid" : "e3e50410-0b3b-474e-b1ed-3f5882deb8b7",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 17053,
			"tags" : [
				"B15"
			],
			"type" : "slope",
			"to" : 1502,
			"from" : 2049,
			"brick" : "B15",
			"name" : "17053",
			"uuid" : "a596f818-dc85-324b-a2c9-b75394b4b378",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 17054,
			"tags" : [
				"B15"
			],
			"type" : "slope",
			"to" : 1506,
			"from" : 2050,
			"brick" : "B15",
			"name" : "17054",
			"uuid" : "ce19b8ac-5d87-e94e-a4af-5a0e877b35e5",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 17055,
			"tags" : [
				"B15"
			],
			"type" : "slope",
			"to" : 1507,
			"from" : 2051,
			"brick" : "B15",
			"name" : "17055",
			"uuid" : "4677b020-1d85-8447-adbb-aaf9b711d794",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 17056,
			"tags" : [
				"B15"
			],
			"type" : "slope",
			"to" : 1503,
			"from" : 2052,
			"brick" : "B15",
			"name" : "17056",
			"uuid" : "a594ebf8-292c-2d41-a55b-1c5e7d2acad3",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 35001,
			"tags" : [
				"B15"
			],
			"type" : "sectionRound",
			"to" : 2002,
			"from" : 2001,
			"brick" : "B15",
			"name" : "35001",
			"uuid" : "37a9ef49-cee7-934b-b6d6-516bd7bd7b17",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 35002,
			"tags" : [
				"B15"
			],
			"type" : "sectionRound",
			"to" : 2003,
			"from" : 2002,
			"brick" : "B15",
			"name" : "35002",
			"uuid" : "c23eb379-9375-2b4e-bbf7-11cf13be8e3d",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 35003,
			"tags" : [
				"B15"
			],
			"type" : "sectionRound",
			"to" : 2004,
			"from" : 2003,
			"brick" : "B15",
			"name" : "35003",
			"uuid" : "55bab91c-2689-5d4e-abdf-396be8f108b0",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 35004,
			"tags" : [
				"B15"
			],
			"type" : "sectionRound",
			"to" : 2001,
			"from" : 2004,
			"brick" : "B15",
			"name" : "35004",
			"uuid" : "fee04048-66b0-7342-9495-817cc2f90782",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 35005,
			"tags" : [
				"B15"
			],
			"type" : "sectionRound",
			"to" : 2053,
			"from" : 2005,
			"brick" : "B15",
			"name" : "35005",
			"uuid" : "092f9de9-738b-b94c-b083-3a96bb8ff95a",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 35006,
			"tags" : [
				"B15"
			],
			"type" : "sectionRound",
			"to" : 2006,
			"from" : 2053,
			"brick" : "B15",
			"name" : "35006",
			"uuid" : "6f62779d-e105-f449-ad68-43094c4b3f59",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 35007,
			"tags" : [
				"B15"
			],
			"type" : "sectionRound",
			"to" : 2007,
			"from" : 2006,
			"brick" : "B15",
			"name" : "35007",
			"uuid" : "3047d1b6-e4ae-9f41-a8b1-def973a9458f",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 35008,
			"tags" : [
				"B15"
			],
			"type" : "sectionRound",
			"to" : 2054,
			"from" : 2007,
			"brick" : "B15",
			"name" : "35008",
			"uuid" : "6e5dd643-3782-8642-a5b0-9b48c3ade8e1",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 35009,
			"tags" : [
				"B15"
			],
			"type" : "sectionRound",
			"to" : 2008,
			"from" : 2054,
			"brick" : "B15",
			"name" : "35009",
			"uuid" : "415cd609-271b-6448-8deb-dd2fcdd1b680",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 35010,
			"tags" : [
				"B15"
			],
			"type" : "sectionRound",
			"to" : 2005,
			"from" : 2008,
			"brick" : "B15",
			"name" : "35010",
			"uuid" : "5e358b84-5761-a54b-803e-a22e6e6a50e9",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 35011,
			"tags" : [
				"B15"
			],
			"type" : "sectionRound",
			"to" : 2010,
			"from" : 2009,
			"brick" : "B15",
			"name" : "35011",
			"uuid" : "d23d04db-d94f-9247-b591-63eb9ca03bce",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 35012,
			"tags" : [
				"B15"
			],
			"type" : "sectionRound",
			"to" : 2055,
			"from" : 2010,
			"brick" : "B15",
			"name" : "35012",
			"uuid" : "5e103fa0-ed4a-804b-8bc8-9a7d0f01f816",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 35013,
			"tags" : [
				"B15"
			],
			"type" : "sectionRound",
			"to" : 2011,
			"from" : 2055,
			"brick" : "B15",
			"name" : "35013",
			"uuid" : "bbcda6c0-cef4-9e41-acb0-006014bd8c15",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 35014,
			"tags" : [
				"B15"
			],
			"type" : "sectionRound",
			"to" : 2012,
			"from" : 2011,
			"brick" : "B15",
			"name" : "35014",
			"uuid" : "ff453975-405f-d340-af17-9d7bf1a6305e",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 35015,
			"tags" : [
				"B15"
			],
			"type" : "sectionRound",
			"to" : 2056,
			"from" : 2012,
			"brick" : "B15",
			"name" : "35015",
			"uuid" : "1926b49e-2fe4-f949-b86b-58db8de7bcdb",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 35016,
			"tags" : [
				"B15"
			],
			"type" : "sectionRound",
			"to" : 2009,
			"from" : 2056,
			"brick" : "B15",
			"name" : "35016",
			"uuid" : "a1093188-029c-4d42-b0d0-38ee437b03e6",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 35017,
			"tags" : [
				"B15"
			],
			"type" : "sectionRound",
			"to" : 2014,
			"from" : 2013,
			"brick" : "B15",
			"name" : "35017",
			"uuid" : "562fa632-3738-754f-a643-a4c1608d76c3",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 35018,
			"tags" : [
				"B15"
			],
			"type" : "sectionRound",
			"to" : 2015,
			"from" : 2014,
			"brick" : "B15",
			"name" : "35018",
			"uuid" : "8bace7f2-bf97-094d-a25e-1151e1f5e21b",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 35019,
			"tags" : [
				"B15"
			],
			"type" : "sectionRound",
			"to" : 2016,
			"from" : 2015,
			"brick" : "B15",
			"name" : "35019",
			"uuid" : "3dfa5be2-6af6-8746-8282-8951d6c92de8",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 35020,
			"tags" : [
				"B15"
			],
			"type" : "sectionRound",
			"to" : 2013,
			"from" : 2016,
			"brick" : "B15",
			"name" : "35020",
			"uuid" : "fd4706ca-3bde-4d46-95b9-0632c82b9da5",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 35021,
			"tags" : [
				"B15"
			],
			"type" : "sectionRound",
			"to" : 2018,
			"from" : 2017,
			"brick" : "B15",
			"name" : "35021",
			"uuid" : "fada7e0c-69f1-d041-8512-9068d4f64e2f",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 35022,
			"tags" : [
				"B15"
			],
			"type" : "sectionRound",
			"to" : 2019,
			"from" : 2018,
			"brick" : "B15",
			"name" : "35022",
			"uuid" : "b2e53064-fcfb-134d-89f6-3bdbeb07ace0",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 35023,
			"tags" : [
				"B15"
			],
			"type" : "sectionRound",
			"to" : 2020,
			"from" : 2019,
			"brick" : "B15",
			"name" : "35023",
			"uuid" : "8d909cda-60af-e242-91b6-f0a71d91f2a7",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 35024,
			"tags" : [
				"B15"
			],
			"type" : "sectionRound",
			"to" : 2017,
			"from" : 2020,
			"brick" : "B15",
			"name" : "35024",
			"uuid" : "eb375dfa-4062-9c48-85d7-7116c05afae2",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 35025,
			"tags" : [
				"B15"
			],
			"type" : "sectionRound",
			"to" : 2022,
			"from" : 2021,
			"brick" : "B15",
			"name" : "35025",
			"uuid" : "65695062-4fe6-e440-ae04-a6fc0f14705f",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 35026,
			"tags" : [
				"B15"
			],
			"type" : "sectionRound",
			"to" : 2023,
			"from" : 2022,
			"brick" : "B15",
			"name" : "35026",
			"uuid" : "497a743c-16da-304a-8f9e-d134dc464de9",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 35027,
			"tags" : [
				"B15"
			],
			"type" : "sectionRound",
			"to" : 2024,
			"from" : 2023,
			"brick" : "B15",
			"name" : "35027",
			"uuid" : "6572e4ab-d800-2944-80dc-ad4fba0cb322",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 35028,
			"tags" : [
				"B15"
			],
			"type" : "sectionRound",
			"to" : 2021,
			"from" : 2024,
			"brick" : "B15",
			"name" : "35028",
			"uuid" : "001a1dae-40cc-6c4b-a1bf-4a28df139454",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 35029,
			"tags" : [
				"B15"
			],
			"type" : "sectionRound",
			"to" : 2057,
			"from" : 2025,
			"brick" : "B15",
			"name" : "35029",
			"uuid" : "508386cd-336c-7f43-ac70-a56f09624272",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 35030,
			"tags" : [
				"B15"
			],
			"type" : "sectionRound",
			"to" : 2026,
			"from" : 2057,
			"brick" : "B15",
			"name" : "35030",
			"uuid" : "a677264f-9997-544e-828d-5a0a62238dc2",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 35031,
			"tags" : [
				"B15"
			],
			"type" : "sectionRound",
			"to" : 2058,
			"from" : 2026,
			"brick" : "B15",
			"name" : "35031",
			"uuid" : "2de1acaf-5f74-cf4e-88a6-43bd0ed9c2c8",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 35032,
			"tags" : [
				"B15"
			],
			"type" : "sectionRound",
			"to" : 2027,
			"from" : 2058,
			"brick" : "B15",
			"name" : "35032",
			"uuid" : "4db3bb98-d6e2-c742-8830-4fcc9e6c6f28",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 35033,
			"tags" : [
				"B15"
			],
			"type" : "sectionRound",
			"to" : 2059,
			"from" : 2027,
			"brick" : "B15",
			"name" : "35033",
			"uuid" : "1125aa57-b530-fa4a-a194-88e067ba8db2",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 35034,
			"tags" : [
				"B15"
			],
			"type" : "sectionRound",
			"to" : 2028,
			"from" : 2059,
			"brick" : "B15",
			"name" : "35034",
			"uuid" : "9a35bd91-695e-0e46-a038-c5ffb36570bb",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 35035,
			"tags" : [
				"B15"
			],
			"type" : "sectionRound",
			"to" : 2060,
			"from" : 2028,
			"brick" : "B15",
			"name" : "35035",
			"uuid" : "46e96c3a-d1e3-fe49-8719-35fef917e210",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 35036,
			"tags" : [
				"B15"
			],
			"type" : "sectionRound",
			"to" : 2025,
			"from" : 2060,
			"brick" : "B15",
			"name" : "35036",
			"uuid" : "8bdc439c-4a22-5245-bbb2-f4ce93aedb6a",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 35037,
			"tags" : [
				"B15"
			],
			"type" : "sectionRound",
			"to" : 2030,
			"from" : 2029,
			"brick" : "B15",
			"name" : "35037",
			"uuid" : "84f07fe2-c608-8f4e-9b6a-119e86f7bcfe",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 35038,
			"tags" : [
				"B15"
			],
			"type" : "sectionRound",
			"to" : 2031,
			"from" : 2030,
			"brick" : "B15",
			"name" : "35038",
			"uuid" : "043cd7e2-9684-af49-a333-e7b2e0e3fddb",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 35039,
			"tags" : [
				"B15"
			],
			"type" : "sectionRound",
			"to" : 2032,
			"from" : 2031,
			"brick" : "B15",
			"name" : "35039",
			"uuid" : "a7a6c2b1-9edb-4b4a-95ac-0ca1b50e7fcd",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 35040,
			"tags" : [
				"B15"
			],
			"type" : "sectionRound",
			"to" : 2029,
			"from" : 2032,
			"brick" : "B15",
			"name" : "35040",
			"uuid" : "09895a44-9f2d-454c-b6a6-466902ae3dd8",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 35041,
			"tags" : [
				"B15"
			],
			"type" : "sectionRound",
			"to" : 2034,
			"from" : 2033,
			"brick" : "B15",
			"name" : "35041",
			"uuid" : "eae2dbbd-27cc-fd4e-8f3d-d98b16ee5c6a",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 35042,
			"tags" : [
				"B15"
			],
			"type" : "sectionRound",
			"to" : 2035,
			"from" : 2034,
			"brick" : "B15",
			"name" : "35042",
			"uuid" : "b1d60593-18f1-6447-a031-2df2aac9e464",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 35043,
			"tags" : [
				"B15"
			],
			"type" : "sectionRound",
			"to" : 2036,
			"from" : 2035,
			"brick" : "B15",
			"name" : "35043",
			"uuid" : "088e6cc0-87ba-cc48-a836-6a391e261f7e",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 35044,
			"tags" : [
				"B15"
			],
			"type" : "sectionRound",
			"to" : 2033,
			"from" : 2036,
			"brick" : "B15",
			"name" : "35044",
			"uuid" : "0b429c08-ee55-6d45-b888-5e494b21f65f",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 35045,
			"tags" : [
				"B15"
			],
			"type" : "sectionRound",
			"to" : 2038,
			"from" : 2037,
			"brick" : "B15",
			"name" : "35045",
			"uuid" : "16692a68-124b-7044-bff1-07c761fd725b",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 35046,
			"tags" : [
				"B15"
			],
			"type" : "sectionRound",
			"to" : 2039,
			"from" : 2038,
			"brick" : "B15",
			"name" : "35046",
			"uuid" : "35bb2583-e9af-c944-be53-b007111b11a9",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 35047,
			"tags" : [
				"B15"
			],
			"type" : "sectionRound",
			"to" : 2040,
			"from" : 2039,
			"brick" : "B15",
			"name" : "35047",
			"uuid" : "e3d88f4f-ef86-564d-819c-4c3ee266a473",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 35048,
			"tags" : [
				"B15"
			],
			"type" : "sectionRound",
			"to" : 2037,
			"from" : 2040,
			"brick" : "B15",
			"name" : "35048",
			"uuid" : "e66ee977-7185-1645-a3df-20ea10808a43",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 35049,
			"tags" : [
				"B15"
			],
			"type" : "sectionRound",
			"to" : 2042,
			"from" : 2041,
			"brick" : "B15",
			"name" : "35049",
			"uuid" : "efe98af0-36e7-cc47-a0a8-c1b71a588cc7",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 35050,
			"tags" : [
				"B15"
			],
			"type" : "sectionRound",
			"to" : 2061,
			"from" : 2042,
			"brick" : "B15",
			"name" : "35050",
			"uuid" : "2a6ffb07-f2c6-0041-b02c-4ca5debe03cd",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 35051,
			"tags" : [
				"B15"
			],
			"type" : "sectionRound",
			"to" : 2043,
			"from" : 2061,
			"brick" : "B15",
			"name" : "35051",
			"uuid" : "2b580f73-4b1e-f944-8fab-bee5e893b472",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 35052,
			"tags" : [
				"B15"
			],
			"type" : "sectionRound",
			"to" : 2044,
			"from" : 2043,
			"brick" : "B15",
			"name" : "35052",
			"uuid" : "2b51c477-c212-fc4b-81b5-a8c0a96022f7",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 35053,
			"tags" : [
				"B15"
			],
			"type" : "sectionRound",
			"to" : 2062,
			"from" : 2044,
			"brick" : "B15",
			"name" : "35053",
			"uuid" : "a7638cdf-1a7c-d941-91cb-1f32485fa96c",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 35054,
			"tags" : [
				"B15"
			],
			"type" : "sectionRound",
			"to" : 2041,
			"from" : 2062,
			"brick" : "B15",
			"name" : "35054",
			"uuid" : "68746084-f3e3-6a4b-b3e7-5c5f82f59805",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 35055,
			"tags" : [
				"B15"
			],
			"type" : "sectionRound",
			"to" : 2063,
			"from" : 2045,
			"brick" : "B15",
			"name" : "35055",
			"uuid" : "1a9e171f-8750-0746-9c07-a59370898cb3",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 35056,
			"tags" : [
				"B15"
			],
			"type" : "sectionRound",
			"to" : 2046,
			"from" : 2063,
			"brick" : "B15",
			"name" : "35056",
			"uuid" : "21e07fc6-152c-b046-81d2-e7cdab617a91",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 35057,
			"tags" : [
				"B15"
			],
			"type" : "sectionRound",
			"to" : 2047,
			"from" : 2046,
			"brick" : "B15",
			"name" : "35057",
			"uuid" : "ba6fa070-7126-d945-afff-5d2840b46a65",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 35058,
			"tags" : [
				"B15"
			],
			"type" : "sectionRound",
			"to" : 2064,
			"from" : 2047,
			"brick" : "B15",
			"name" : "35058",
			"uuid" : "bb1a7119-eb41-3445-8028-f1415c5850d8",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 35059,
			"tags" : [
				"B15"
			],
			"type" : "sectionRound",
			"to" : 2048,
			"from" : 2064,
			"brick" : "B15",
			"name" : "35059",
			"uuid" : "58d86ba7-5006-0246-9ec5-1a4fcc7eb585",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 35060,
			"tags" : [
				"B15"
			],
			"type" : "sectionRound",
			"to" : 2045,
			"from" : 2048,
			"brick" : "B15",
			"name" : "35060",
			"uuid" : "10be906f-afca-f14c-95de-9d092e759a6a",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 35061,
			"tags" : [
				"B15"
			],
			"type" : "sectionRound",
			"to" : 2050,
			"from" : 2049,
			"brick" : "B15",
			"name" : "35061",
			"uuid" : "6a96d905-4a1f-1d44-b4a1-9020aa641a4b",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 35062,
			"tags" : [
				"B15"
			],
			"type" : "sectionRound",
			"to" : 2051,
			"from" : 2050,
			"brick" : "B15",
			"name" : "35062",
			"uuid" : "8ee8f646-0bf3-7048-b263-381d88ab8840",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 35063,
			"tags" : [
				"B15"
			],
			"type" : "sectionRound",
			"to" : 2052,
			"from" : 2051,
			"brick" : "B15",
			"name" : "35063",
			"uuid" : "c05397f0-5681-404f-835f-9cc19a6d1175",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 35064,
			"tags" : [
				"B15"
			],
			"type" : "sectionRound",
			"to" : 2049,
			"from" : 2052,
			"brick" : "B15",
			"name" : "35064",
			"uuid" : "100d5fc2-d6d9-c14b-9ae2-e4da20f63b44",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 35101,
			"tags" : [
				"B15"
			],
			"type" : "sectionSlant",
			"to" : 2005,
			"from" : 2901,
			"brick" : "B15",
			"name" : "35101",
			"uuid" : "9af05a69-6142-f541-a7a2-d9d66b47e7bd",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 35102,
			"tags" : [
				"B15"
			],
			"type" : "sectionSlant",
			"to" : 2901,
			"from" : 2007,
			"brick" : "B15",
			"name" : "35102",
			"uuid" : "2afefc5c-18e2-b54f-a255-f4af3f54e11b",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 35103,
			"tags" : [
				"B15"
			],
			"type" : "sectionSlant",
			"to" : 2008,
			"from" : 2901,
			"brick" : "B15",
			"name" : "35103",
			"uuid" : "72ce19f0-86ca-c84e-a114-dce4819a1ad0",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 35104,
			"tags" : [
				"B15"
			],
			"type" : "sectionSlant",
			"to" : 2901,
			"from" : 2006,
			"brick" : "B15",
			"name" : "35104",
			"uuid" : "e60fa31d-75dd-2b4f-8ef5-2e9a293f8b1b",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 35105,
			"tags" : [
				"B15"
			],
			"type" : "sectionSlant",
			"to" : 2009,
			"from" : 2902,
			"brick" : "B15",
			"name" : "35105",
			"uuid" : "08c2bfa5-839c-ad4c-b93f-51e06d696db1",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 35106,
			"tags" : [
				"B15"
			],
			"type" : "sectionSlant",
			"to" : 2902,
			"from" : 2011,
			"brick" : "B15",
			"name" : "35106",
			"uuid" : "b88011ba-edd0-0843-ab43-1e82c1dbfc40",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 35107,
			"tags" : [
				"B15"
			],
			"type" : "sectionSlant",
			"to" : 2012,
			"from" : 2902,
			"brick" : "B15",
			"name" : "35107",
			"uuid" : "32508be5-917c-b84a-ac14-2181564a6118",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 35108,
			"tags" : [
				"B15"
			],
			"type" : "sectionSlant",
			"to" : 2902,
			"from" : 2010,
			"brick" : "B15",
			"name" : "35108",
			"uuid" : "4eb82faf-ae6b-2e44-b01d-d8ed40f2ed79",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 35109,
			"tags" : [
				"B15"
			],
			"type" : "sectionSlant",
			"to" : 2025,
			"from" : 2903,
			"brick" : "B15",
			"name" : "35109",
			"uuid" : "a04ea625-608b-2e43-8659-7027ce7ab040",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 35110,
			"tags" : [
				"B15"
			],
			"type" : "sectionSlant",
			"to" : 2903,
			"from" : 2027,
			"brick" : "B15",
			"name" : "35110",
			"uuid" : "f246832e-fd2f-d440-97a6-7faea27b1ae4",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 35111,
			"tags" : [
				"B15"
			],
			"type" : "sectionSlant",
			"to" : 2028,
			"from" : 2903,
			"brick" : "B15",
			"name" : "35111",
			"uuid" : "4c8a8ce5-40d8-ab4d-9495-523f30276712",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 35112,
			"tags" : [
				"B15"
			],
			"type" : "sectionSlant",
			"to" : 2903,
			"from" : 2026,
			"brick" : "B15",
			"name" : "35112",
			"uuid" : "36c0cf3b-526f-9e48-b3d9-b1aea1036bb4",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 35113,
			"tags" : [
				"B15"
			],
			"type" : "sectionSlant",
			"to" : 2041,
			"from" : 2904,
			"brick" : "B15",
			"name" : "35113",
			"uuid" : "51a84776-5d34-674b-9ea1-174e2464acfb",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 35114,
			"tags" : [
				"B15"
			],
			"type" : "sectionSlant",
			"to" : 2904,
			"from" : 2043,
			"brick" : "B15",
			"name" : "35114",
			"uuid" : "c65a1e79-1ca5-9f4a-b5f9-125a5101622b",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 35115,
			"tags" : [
				"B15"
			],
			"type" : "sectionSlant",
			"to" : 2044,
			"from" : 2904,
			"brick" : "B15",
			"name" : "35115",
			"uuid" : "3af0de47-b666-f44d-a591-bbb6f9529a5e",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 35116,
			"tags" : [
				"B15"
			],
			"type" : "sectionSlant",
			"to" : 2904,
			"from" : 2042,
			"brick" : "B15",
			"name" : "35116",
			"uuid" : "daf24969-2c00-d645-a5f7-8b4eedb888ea",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 35117,
			"tags" : [
				"B15"
			],
			"type" : "sectionSlant",
			"to" : 2045,
			"from" : 2905,
			"brick" : "B15",
			"name" : "35117",
			"uuid" : "0d61db95-300a-f142-ac09-c8085ba85ba4",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 35118,
			"tags" : [
				"B15"
			],
			"type" : "sectionSlant",
			"to" : 2905,
			"from" : 2047,
			"brick" : "B15",
			"name" : "35118",
			"uuid" : "5c20327b-921d-6a4f-b78a-e274a3e18d9d",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 35119,
			"tags" : [
				"B15"
			],
			"type" : "sectionSlant",
			"to" : 2048,
			"from" : 2905,
			"brick" : "B15",
			"name" : "35119",
			"uuid" : "26d76c93-a8bd-da45-a21a-aba1b9ae9704",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 35120,
			"tags" : [
				"B15"
			],
			"type" : "sectionSlant",
			"to" : 2905,
			"from" : 2046,
			"brick" : "B15",
			"name" : "35120",
			"uuid" : "c3ff7e95-2403-ad48-9635-1cb1c9b82cd2",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 35121,
			"tags" : [
				"B15"
			],
			"type" : "sectionVertical",
			"to" : 2056,
			"from" : 2902,
			"brick" : "B15",
			"name" : "35121",
			"uuid" : "5d9cd90a-25d8-ec4a-92ee-6c7e922e91b4",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 35122,
			"tags" : [
				"B15"
			],
			"type" : "sectionVertical",
			"to" : 2902,
			"from" : 2055,
			"brick" : "B15",
			"name" : "35122",
			"uuid" : "50f3654c-9090-ab43-afbc-b8e6d0ab2f56",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 35123,
			"tags" : [
				"B15"
			],
			"type" : "sectionVertical",
			"to" : 2060,
			"from" : 2903,
			"brick" : "B15",
			"name" : "35123",
			"uuid" : "f9aad71e-fe5c-894d-9cdb-2dcbcd2037ba",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 35124,
			"tags" : [
				"B15"
			],
			"type" : "sectionVertical",
			"to" : 2903,
			"from" : 2058,
			"brick" : "B15",
			"name" : "35124",
			"uuid" : "aa4019a3-db0d-3c45-af93-cc736ec44015",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 35125,
			"tags" : [
				"B15"
			],
			"type" : "sectionVertical",
			"to" : 2062,
			"from" : 2904,
			"brick" : "B15",
			"name" : "35125",
			"uuid" : "6450e4ea-a9f9-254a-b082-9f3fc485efe7",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 35126,
			"tags" : [
				"B15"
			],
			"type" : "sectionVertical",
			"to" : 2904,
			"from" : 2061,
			"brick" : "B15",
			"name" : "35126",
			"uuid" : "e7034b3b-dd47-854b-a479-af2996b0b46e",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 35127,
			"tags" : [
				"B15"
			],
			"type" : "sectionHorizontal",
			"to" : 2901,
			"from" : 2054,
			"brick" : "B15",
			"name" : "35127",
			"uuid" : "70814f97-7b24-8c40-aa94-e7038f859547",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 35128,
			"tags" : [
				"B15"
			],
			"type" : "sectionHorizontal",
			"to" : 2053,
			"from" : 2901,
			"brick" : "B15",
			"name" : "35128",
			"uuid" : "4b1d0b41-acf2-9e45-b4a8-516f42c36f0f",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 35129,
			"tags" : [
				"B15"
			],
			"type" : "sectionHorizontal",
			"to" : 2903,
			"from" : 2059,
			"brick" : "B15",
			"name" : "35129",
			"uuid" : "6b3d89a0-6ad9-b648-adfe-37eb3158a216",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 35130,
			"tags" : [
				"B15"
			],
			"type" : "sectionHorizontal",
			"to" : 2057,
			"from" : 2903,
			"brick" : "B15",
			"name" : "35130",
			"uuid" : "45c812f2-47e3-e247-a388-c796e2888c47",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 35131,
			"tags" : [
				"B15"
			],
			"type" : "sectionHorizontal",
			"to" : 2905,
			"from" : 2064,
			"brick" : "B15",
			"name" : "35131",
			"uuid" : "c6fdba25-e745-4d44-8329-38cad285b9e0",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 35132,
			"tags" : [
				"B15"
			],
			"type" : "sectionHorizontal",
			"to" : 2063,
			"from" : 2905,
			"brick" : "B15",
			"name" : "35132",
			"uuid" : "84b4668c-a9af-eb4d-b0d1-e50ff0b00182",
			"_clazz" : "TwkSegment"
		},
		{
			"uuid" : "d53af3f2-c322-dc40-b686-83b4a8873332",
			"name" : "26001",
			"_clazz" : "TwkSegment",
			"brick" : "FRONT",
			"from" : 1317,
			"face" : "front",
			"tags" : [
				"B15"
			],
			"type" : "panel",
			"to" : 2002,
			"number" : 26001
		},
		{
			"uuid" : "09ddbb28-8009-494d-a9f5-51475f0c4961",
			"name" : "26002",
			"_clazz" : "TwkSegment",
			"brick" : "BOTTOM",
			"from" : 1324,
			"face" : "bottom",
			"tags" : [
				"B15"
			],
			"type" : "panel",
			"to" : 2002,
			"number" : 26002
		},
		{
			"uuid" : "f955afa4-4540-ae4b-b871-63680dc4db08",
			"name" : "26003",
			"_clazz" : "TwkSegment",
			"brick" : "BACK",
			"from" : 1324,
			"face" : "back",
			"tags" : [
				"B15"
			],
			"type" : "panel",
			"to" : 2004,
			"number" : 26003
		},
		{
			"uuid" : "69a9341f-7ad8-ab49-ae65-cb71cf27f01d",
			"name" : "26004",
			"_clazz" : "TwkSegment",
			"brick" : "TOP",
			"from" : 1317,
			"face" : "top",
			"tags" : [
				"B15"
			],
			"type" : "panel",
			"to" : 2004,
			"number" : 26004
		},
		{
			"uuid" : "c84d8343-cc99-0e4e-9ee5-e03ef305bbc8",
			"name" : "26005",
			"_clazz" : "TwkSegment",
			"brick" : "FRONT",
			"from" : 2001,
			"face" : "front",
			"tags" : [
				"B15"
			],
			"type" : "panel",
			"to" : 2006,
			"number" : 26005
		},
		{
			"uuid" : "402609bf-ed7a-a242-b7d5-7d38aae902b1",
			"name" : "26006",
			"_clazz" : "TwkSegment",
			"brick" : "BOTTOM",
			"from" : 2003,
			"face" : "bottom",
			"tags" : [
				"B15"
			],
			"type" : "panel",
			"to" : 2006,
			"number" : 26006
		},
		{
			"uuid" : "1e260dbf-34be-0c47-bd7b-509dd1968477",
			"name" : "26007",
			"_clazz" : "TwkSegment",
			"brick" : "BACK",
			"from" : 2003,
			"face" : "back",
			"tags" : [
				"B15"
			],
			"type" : "panel",
			"to" : 2008,
			"number" : 26007
		},
		{
			"uuid" : "ccddbadc-7e47-5943-addd-dda5b7b7cf62",
			"name" : "26008",
			"_clazz" : "TwkSegment",
			"brick" : "TOP",
			"from" : 2001,
			"face" : "top",
			"tags" : [
				"B15"
			],
			"type" : "panel",
			"to" : 2008,
			"number" : 26008
		},
		{
			"uuid" : "6778ef7b-d318-8c4a-8575-76a4937f361e",
			"name" : "26009",
			"_clazz" : "TwkSegment",
			"brick" : "FRONT",
			"from" : 2005,
			"face" : "front",
			"tags" : [
				"B15"
			],
			"type" : "panel",
			"to" : 2010,
			"number" : 26009
		},
		{
			"uuid" : "352ed266-7ef9-f648-b7b6-9e7becf50eb6",
			"name" : "26010",
			"_clazz" : "TwkSegment",
			"brick" : "BOTTOM",
			"from" : 2007,
			"face" : "bottom",
			"tags" : [
				"B15"
			],
			"type" : "panel",
			"to" : 2010,
			"number" : 26010
		},
		{
			"uuid" : "628649a0-bedf-5d4a-ba74-c50cd8e9e008",
			"name" : "26011",
			"_clazz" : "TwkSegment",
			"brick" : "BACK",
			"from" : 2007,
			"face" : "back",
			"tags" : [
				"B15"
			],
			"type" : "panel",
			"to" : 2012,
			"number" : 26011
		},
		{
			"uuid" : "02d49d07-5794-1448-9d5d-ff21875870be",
			"name" : "26012",
			"_clazz" : "TwkSegment",
			"brick" : "TOP",
			"from" : 2005,
			"face" : "top",
			"tags" : [
				"B15"
			],
			"type" : "panel",
			"to" : 2012,
			"number" : 26012
		},
		{
			"uuid" : "c99b5df4-9087-374b-b58c-41b0f91fa2a5",
			"name" : "26013",
			"_clazz" : "TwkSegment",
			"brick" : "FRONT",
			"from" : 2009,
			"face" : "front",
			"tags" : [
				"B15"
			],
			"type" : "panel",
			"to" : 2014,
			"number" : 26013
		},
		{
			"uuid" : "f10a86bc-0426-0840-81cf-8730ac0bdcb7",
			"name" : "26014",
			"_clazz" : "TwkSegment",
			"brick" : "BOTTOM",
			"from" : 2011,
			"face" : "bottom",
			"tags" : [
				"B15"
			],
			"type" : "panel",
			"to" : 2014,
			"number" : 26014
		},
		{
			"uuid" : "0b600a9e-12c9-8d4a-91cb-53c84635414e",
			"name" : "26015",
			"_clazz" : "TwkSegment",
			"brick" : "BACK",
			"from" : 2011,
			"face" : "back",
			"tags" : [
				"B15"
			],
			"type" : "panel",
			"to" : 2016,
			"number" : 26015
		},
		{
			"uuid" : "bef4d74f-3690-6240-9fb9-290395006b81",
			"name" : "26016",
			"_clazz" : "TwkSegment",
			"brick" : "TOP",
			"from" : 2009,
			"face" : "top",
			"tags" : [
				"B15"
			],
			"type" : "panel",
			"to" : 2016,
			"number" : 26016
		},
		{
			"uuid" : "54a94f48-34ea-6743-b537-e648e613f49e",
			"name" : "26017",
			"_clazz" : "TwkSegment",
			"brick" : "FRONT",
			"from" : 2013,
			"face" : "front",
			"tags" : [
				"B15"
			],
			"type" : "panel",
			"to" : 2018,
			"number" : 26017
		},
		{
			"uuid" : "56b7d010-5ea4-8a4c-ae61-eac5280da74b",
			"name" : "26018",
			"_clazz" : "TwkSegment",
			"brick" : "BOTTOM",
			"from" : 2015,
			"face" : "bottom",
			"tags" : [
				"B15"
			],
			"type" : "panel",
			"to" : 2018,
			"number" : 26018
		},
		{
			"uuid" : "7da55116-ca56-bb4c-a1dc-06620fd30d83",
			"name" : "26019",
			"_clazz" : "TwkSegment",
			"brick" : "BACK",
			"from" : 2015,
			"face" : "back",
			"tags" : [
				"B15"
			],
			"type" : "panel",
			"to" : 2020,
			"number" : 26019
		},
		{
			"uuid" : "9b1d7bdb-b2e5-3648-a5aa-351bee83d6ab",
			"name" : "26020",
			"_clazz" : "TwkSegment",
			"brick" : "TOP",
			"from" : 2013,
			"face" : "top",
			"tags" : [
				"B15"
			],
			"type" : "panel",
			"to" : 2020,
			"number" : 26020
		},
		{
			"uuid" : "75aff08d-4a2c-5b4f-9ae3-afdf5e05ec6d",
			"name" : "26021",
			"_clazz" : "TwkSegment",
			"brick" : "FRONT",
			"from" : 2017,
			"face" : "front",
			"tags" : [
				"B15"
			],
			"type" : "panel",
			"to" : 2022,
			"number" : 26021
		},
		{
			"uuid" : "0d9da3b9-689d-bf42-a4cd-a195bab7ddb7",
			"name" : "26022",
			"_clazz" : "TwkSegment",
			"brick" : "BOTTOM",
			"from" : 2019,
			"face" : "bottom",
			"tags" : [
				"B15"
			],
			"type" : "panel",
			"to" : 2022,
			"number" : 26022
		},
		{
			"uuid" : "199795fb-dd2f-f046-aa83-0091c987e1ec",
			"name" : "26023",
			"_clazz" : "TwkSegment",
			"brick" : "BACK",
			"from" : 2019,
			"face" : "back",
			"tags" : [
				"B15"
			],
			"type" : "panel",
			"to" : 2024,
			"number" : 26023
		},
		{
			"uuid" : "8afeed61-1936-264b-be22-af49186a644a",
			"name" : "26024",
			"_clazz" : "TwkSegment",
			"brick" : "TOP",
			"from" : 2017,
			"face" : "top",
			"tags" : [
				"B15"
			],
			"type" : "panel",
			"to" : 2024,
			"number" : 26024
		},
		{
			"uuid" : "5be819ac-9b7f-9340-8d3d-bba7e45f2d02",
			"name" : "26025",
			"_clazz" : "TwkSegment",
			"brick" : "FRONT",
			"from" : 2021,
			"face" : "front",
			"tags" : [
				"B15"
			],
			"type" : "panel",
			"to" : 2026,
			"number" : 26025
		},
		{
			"uuid" : "23f17e4b-860f-4341-9919-3e317ec570be",
			"name" : "26026",
			"_clazz" : "TwkSegment",
			"brick" : "BOTTOM",
			"from" : 2023,
			"face" : "bottom",
			"tags" : [
				"B15"
			],
			"type" : "panel",
			"to" : 2026,
			"number" : 26026
		},
		{
			"uuid" : "397c3d2e-fdf0-714f-ad77-a4861442399c",
			"name" : "26027",
			"_clazz" : "TwkSegment",
			"brick" : "BACK",
			"from" : 2023,
			"face" : "back",
			"tags" : [
				"B15"
			],
			"type" : "panel",
			"to" : 2028,
			"number" : 26027
		},
		{
			"uuid" : "f5493f23-4811-8b48-a945-7428baf87b85",
			"name" : "26028",
			"_clazz" : "TwkSegment",
			"brick" : "TOP",
			"from" : 2021,
			"face" : "top",
			"tags" : [
				"B15"
			],
			"type" : "panel",
			"to" : 2028,
			"number" : 26028
		},
		{
			"uuid" : "81abb411-b0f9-0d44-be1c-1cf796c0040c",
			"name" : "26029",
			"_clazz" : "TwkSegment",
			"brick" : "FRONT",
			"from" : 2026,
			"face" : "front",
			"tags" : [
				"B15"
			],
			"type" : "panel",
			"to" : 2029,
			"number" : 26029
		},
		{
			"uuid" : "f0c28d9b-470d-0345-84e6-3685c90d2214",
			"name" : "26030",
			"_clazz" : "TwkSegment",
			"brick" : "BOTTOM",
			"from" : 2026,
			"face" : "bottom",
			"tags" : [
				"B15"
			],
			"type" : "panel",
			"to" : 2031,
			"number" : 26030
		},
		{
			"uuid" : "f827c149-f030-2248-8dff-5c9dad71ccbb",
			"name" : "26031",
			"_clazz" : "TwkSegment",
			"brick" : "BACK",
			"from" : 2028,
			"face" : "back",
			"tags" : [
				"B15"
			],
			"type" : "panel",
			"to" : 2031,
			"number" : 26031
		},
		{
			"uuid" : "4dc2fbfa-6f7e-4349-8a45-2afb2c87682d",
			"name" : "26032",
			"_clazz" : "TwkSegment",
			"brick" : "TOP",
			"from" : 2028,
			"face" : "top",
			"tags" : [
				"B15"
			],
			"type" : "panel",
			"to" : 2029,
			"number" : 26032
		},
		{
			"uuid" : "c2edbbb5-1806-8640-b9c6-5a10f5738385",
			"name" : "26033",
			"_clazz" : "TwkSegment",
			"brick" : "FRONT",
			"from" : 2030,
			"face" : "front",
			"tags" : [
				"B15"
			],
			"type" : "panel",
			"to" : 2033,
			"number" : 26033
		},
		{
			"uuid" : "f79835f3-9772-744b-9c9e-e401ab8bdcfc",
			"name" : "26034",
			"_clazz" : "TwkSegment",
			"brick" : "BOTTOM",
			"from" : 2030,
			"face" : "bottom",
			"tags" : [
				"B15"
			],
			"type" : "panel",
			"to" : 2035,
			"number" : 26034
		},
		{
			"uuid" : "58a03298-328e-8d45-a214-066453931f39",
			"name" : "26035",
			"_clazz" : "TwkSegment",
			"brick" : "BACK",
			"from" : 2032,
			"face" : "back",
			"tags" : [
				"B15"
			],
			"type" : "panel",
			"to" : 2035,
			"number" : 26035
		},
		{
			"uuid" : "ae728800-0492-844c-bbbe-051348ab2daa",
			"name" : "26036",
			"_clazz" : "TwkSegment",
			"brick" : "TOP",
			"from" : 2032,
			"face" : "top",
			"tags" : [
				"B15"
			],
			"type" : "panel",
			"to" : 2033,
			"number" : 26036
		},
		{
			"uuid" : "72e135df-0534-8949-9951-e5256eb9522d",
			"name" : "26037",
			"_clazz" : "TwkSegment",
			"brick" : "FRONT",
			"from" : 2034,
			"face" : "front",
			"tags" : [
				"B15"
			],
			"type" : "panel",
			"to" : 2037,
			"number" : 26037
		},
		{
			"uuid" : "e794655d-a2e4-8142-b21e-a23f218a15a8",
			"name" : "26038",
			"_clazz" : "TwkSegment",
			"brick" : "BOTTOM",
			"from" : 2034,
			"face" : "bottom",
			"tags" : [
				"B15"
			],
			"type" : "panel",
			"to" : 2039,
			"number" : 26038
		},
		{
			"uuid" : "1bbbeefb-3f75-8c48-830c-fce96e3092ea",
			"name" : "26039",
			"_clazz" : "TwkSegment",
			"brick" : "BACK",
			"from" : 2036,
			"face" : "back",
			"tags" : [
				"B15"
			],
			"type" : "panel",
			"to" : 2039,
			"number" : 26039
		},
		{
			"uuid" : "cab8126e-60f8-ed48-928d-e2fbbc2e1f69",
			"name" : "26040",
			"_clazz" : "TwkSegment",
			"brick" : "TOP",
			"from" : 2036,
			"face" : "top",
			"tags" : [
				"B15"
			],
			"type" : "panel",
			"to" : 2037,
			"number" : 26040
		},
		{
			"uuid" : "8bffc2bb-20c8-9148-9e1b-2db95494bf93",
			"name" : "26041",
			"_clazz" : "TwkSegment",
			"brick" : "FRONT",
			"from" : 2038,
			"face" : "front",
			"tags" : [
				"B15"
			],
			"type" : "panel",
			"to" : 2041,
			"number" : 26041
		},
		{
			"uuid" : "49ff1dac-9c04-ba46-bf1d-70ced431815f",
			"name" : "26042",
			"_clazz" : "TwkSegment",
			"brick" : "BOTTOM",
			"from" : 2038,
			"face" : "bottom",
			"tags" : [
				"B15"
			],
			"type" : "panel",
			"to" : 2043,
			"number" : 26042
		},
		{
			"uuid" : "ce07e567-9342-2f47-9d92-938fd8f27390",
			"name" : "26043",
			"_clazz" : "TwkSegment",
			"brick" : "BACK",
			"from" : 2040,
			"face" : "back",
			"tags" : [
				"B15"
			],
			"type" : "panel",
			"to" : 2043,
			"number" : 26043
		},
		{
			"uuid" : "23920168-5024-8648-8732-7417aca634fa",
			"name" : "26044",
			"_clazz" : "TwkSegment",
			"brick" : "TOP",
			"from" : 2040,
			"face" : "top",
			"tags" : [
				"B15"
			],
			"type" : "panel",
			"to" : 2041,
			"number" : 26044
		},
		{
			"uuid" : "8010475a-255b-264e-9c34-610937994dee",
			"name" : "26045",
			"_clazz" : "TwkSegment",
			"brick" : "FRONT",
			"from" : 2042,
			"face" : "front",
			"tags" : [
				"B15"
			],
			"type" : "panel",
			"to" : 2045,
			"number" : 26045
		},
		{
			"uuid" : "4e535c98-499a-2a44-9e47-39a85307577d",
			"name" : "26046",
			"_clazz" : "TwkSegment",
			"brick" : "BOTTOM",
			"from" : 2042,
			"face" : "bottom",
			"tags" : [
				"B15"
			],
			"type" : "panel",
			"to" : 2047,
			"number" : 26046
		},
		{
			"uuid" : "e44613ac-ce0b-a948-8b1e-257113b09023",
			"name" : "26047",
			"_clazz" : "TwkSegment",
			"brick" : "BACK",
			"from" : 2044,
			"face" : "back",
			"tags" : [
				"B15"
			],
			"type" : "panel",
			"to" : 2047,
			"number" : 26047
		},
		{
			"uuid" : "f3537dff-f53f-f24d-ad5a-1a15ce75798b",
			"name" : "26048",
			"_clazz" : "TwkSegment",
			"brick" : "TOP",
			"from" : 2044,
			"face" : "top",
			"tags" : [
				"B15"
			],
			"type" : "panel",
			"to" : 2045,
			"number" : 26048
		},
		{
			"uuid" : "9e4168a5-69f9-5c43-b6df-75f644932324",
			"name" : "26049",
			"_clazz" : "TwkSegment",
			"brick" : "FRONT",
			"from" : 2046,
			"face" : "front",
			"tags" : [
				"B15"
			],
			"type" : "panel",
			"to" : 2049,
			"number" : 26049
		},
		{
			"uuid" : "7d115a13-4b8b-0147-93bb-85ff61ce1bb8",
			"name" : "26050",
			"_clazz" : "TwkSegment",
			"brick" : "BOTTOM",
			"from" : 2046,
			"face" : "bottom",
			"tags" : [
				"B15"
			],
			"type" : "panel",
			"to" : 2051,
			"number" : 26050
		},
		{
			"uuid" : "e2ffc2f6-2995-454d-ad0e-dc665997d9cb",
			"name" : "26051",
			"_clazz" : "TwkSegment",
			"brick" : "BACK",
			"from" : 2048,
			"face" : "back",
			"tags" : [
				"B15"
			],
			"type" : "panel",
			"to" : 2051,
			"number" : 26051
		},
		{
			"uuid" : "d5a18b33-e2d0-bd43-a1bd-8edeb3ba4ff6",
			"name" : "26052",
			"_clazz" : "TwkSegment",
			"brick" : "TOP",
			"from" : 2048,
			"face" : "top",
			"tags" : [
				"B15"
			],
			"type" : "panel",
			"to" : 2049,
			"number" : 26052
		},
		{
			"uuid" : "ba85fb5d-2c20-274f-85ae-c79843d27ca4",
			"name" : "26053",
			"_clazz" : "TwkSegment",
			"brick" : "FRONT",
			"from" : 2050,
			"face" : "front",
			"tags" : [
				"B15"
			],
			"type" : "panel",
			"to" : 1502,
			"number" : 26053
		},
		{
			"uuid" : "2e421cd5-4ded-1d47-8957-e561edb313c3",
			"name" : "26054",
			"_clazz" : "TwkSegment",
			"brick" : "BOTTOM",
			"from" : 2050,
			"face" : "bottom",
			"tags" : [
				"B15"
			],
			"type" : "panel",
			"to" : 1507,
			"number" : 26054
		},
		{
			"uuid" : "80aaf44a-8195-714e-8852-679a7d0fb5cc",
			"name" : "26055",
			"_clazz" : "TwkSegment",
			"brick" : "BACK",
			"from" : 2052,
			"face" : "back",
			"tags" : [
				"B15"
			],
			"type" : "panel",
			"to" : 1507,
			"number" : 26055
		},
		{
			"uuid" : "1661bcac-e63f-6243-ad69-af43ed23c59e",
			"name" : "26056",
			"_clazz" : "TwkSegment",
			"brick" : "TOP",
			"from" : 2052,
			"face" : "top",
			"tags" : [
				"B15"
			],
			"type" : "panel",
			"to" : 1502,
			"number" : 26056
		},
		{
			"number" : 18001,
			"tags" : [
				"B16"
			],
			"type" : "slope",
			"to" : 2101,
			"from" : 1501,
			"brick" : "B16",
			"name" : "18001",
			"uuid" : "4b9ee3b2-7488-744a-b59d-0f7316c2c49a",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 18002,
			"tags" : [
				"B16"
			],
			"type" : "slope",
			"to" : 2102,
			"from" : 1505,
			"brick" : "B16",
			"name" : "18002",
			"uuid" : "159c994f-8db9-7c4e-a385-f6e57e5b2066",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 18003,
			"tags" : [
				"B16"
			],
			"type" : "slope",
			"to" : 2103,
			"from" : 1508,
			"brick" : "B16",
			"name" : "18003",
			"uuid" : "39a5ee5b-85a2-264f-b5e6-f9ad2efde86c",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 18004,
			"tags" : [
				"B16"
			],
			"type" : "slope",
			"to" : 2104,
			"from" : 1504,
			"brick" : "B16",
			"name" : "18004",
			"uuid" : "dc95c55a-5a2b-1b44-add2-4fe1a87f84d2",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 18005,
			"tags" : [
				"B16"
			],
			"type" : "slope",
			"to" : 2105,
			"from" : 2101,
			"brick" : "B16",
			"name" : "18005",
			"uuid" : "30b64dff-b44b-8c43-8ea4-7538a4bb011f",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 18006,
			"tags" : [
				"B16"
			],
			"type" : "slope",
			"to" : 2106,
			"from" : 2102,
			"brick" : "B16",
			"name" : "18006",
			"uuid" : "85d564f4-0b06-6a41-a2e1-1028eb7cbd46",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 18007,
			"tags" : [
				"B16"
			],
			"type" : "slope",
			"to" : 2107,
			"from" : 2103,
			"brick" : "B16",
			"name" : "18007",
			"uuid" : "0a4401df-3c79-1d45-baab-e33ef494a299",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 18008,
			"tags" : [
				"B16"
			],
			"type" : "slope",
			"to" : 2108,
			"from" : 2104,
			"brick" : "B16",
			"name" : "18008",
			"uuid" : "48f8844c-99e8-a846-ab19-c7a4258537f1",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 18009,
			"tags" : [
				"B16"
			],
			"type" : "slope",
			"to" : 2109,
			"from" : 2105,
			"brick" : "B16",
			"name" : "18009",
			"uuid" : "6ea597cc-a06a-0c41-865a-331dc28304c6",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 18010,
			"tags" : [
				"B16"
			],
			"type" : "slope",
			"to" : 2110,
			"from" : 2106,
			"brick" : "B16",
			"name" : "18010",
			"uuid" : "02af1f56-271e-d143-b626-2db19d85a120",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 18011,
			"tags" : [
				"B16"
			],
			"type" : "slope",
			"to" : 2111,
			"from" : 2107,
			"brick" : "B16",
			"name" : "18011",
			"uuid" : "db798fbe-a8a2-bd4f-a853-bcf0ab4a14e0",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 18012,
			"tags" : [
				"B16"
			],
			"type" : "slope",
			"to" : 2112,
			"from" : 2108,
			"brick" : "B16",
			"name" : "18012",
			"uuid" : "1c707539-4fd2-6946-89e2-7109ace7a83b",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 18013,
			"tags" : [
				"B16"
			],
			"type" : "slope",
			"to" : 2113,
			"from" : 2109,
			"brick" : "B16",
			"name" : "18013",
			"uuid" : "fb5e7848-51a2-694e-aa7e-2f52631b96fc",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 18014,
			"tags" : [
				"B16"
			],
			"type" : "slope",
			"to" : 2114,
			"from" : 2110,
			"brick" : "B16",
			"name" : "18014",
			"uuid" : "267f0d1a-be84-3343-80d7-f9f24c1ac243",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 18015,
			"tags" : [
				"B16"
			],
			"type" : "slope",
			"to" : 2115,
			"from" : 2111,
			"brick" : "B16",
			"name" : "18015",
			"uuid" : "1fd00e30-997c-e34a-bd61-c7dcf7340d24",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 18016,
			"tags" : [
				"B16"
			],
			"type" : "slope",
			"to" : 2116,
			"from" : 2112,
			"brick" : "B16",
			"name" : "18016",
			"uuid" : "4719b2ad-4b6b-034b-b2ef-4dab2016991f",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 18017,
			"tags" : [
				"B16"
			],
			"type" : "slope",
			"to" : 2117,
			"from" : 2113,
			"brick" : "B16",
			"name" : "18017",
			"uuid" : "0daf1415-6a6a-9d48-86e4-e92ce9d4c0d4",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 18018,
			"tags" : [
				"B16"
			],
			"type" : "slope",
			"to" : 2118,
			"from" : 2114,
			"brick" : "B16",
			"name" : "18018",
			"uuid" : "ef65a228-7991-5749-bfc2-bfdc959ae612",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 18019,
			"tags" : [
				"B16"
			],
			"type" : "slope",
			"to" : 2119,
			"from" : 2115,
			"brick" : "B16",
			"name" : "18019",
			"uuid" : "f7802c29-c993-8943-8947-b86b03ed3d4f",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 18020,
			"tags" : [
				"B16"
			],
			"type" : "slope",
			"to" : 2120,
			"from" : 2116,
			"brick" : "B16",
			"name" : "18020",
			"uuid" : "a97536f8-9395-3242-915c-1c053cea9111",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 18021,
			"tags" : [
				"B16"
			],
			"type" : "slope",
			"to" : 2121,
			"from" : 2117,
			"brick" : "B16",
			"name" : "18021",
			"uuid" : "c753cc7b-51d9-ca43-b341-b2f19e1cede5",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 18022,
			"tags" : [
				"B16"
			],
			"type" : "slope",
			"to" : 2122,
			"from" : 2118,
			"brick" : "B16",
			"name" : "18022",
			"uuid" : "7fadc607-7730-7444-a841-6aaf92400376",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 18023,
			"tags" : [
				"B16"
			],
			"type" : "slope",
			"to" : 2123,
			"from" : 2119,
			"brick" : "B16",
			"name" : "18023",
			"uuid" : "3c068514-c254-264a-a2c6-053e6b4803f2",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 18024,
			"tags" : [
				"B16"
			],
			"type" : "slope",
			"to" : 2124,
			"from" : 2120,
			"brick" : "B16",
			"name" : "18024",
			"uuid" : "a76083f9-13ec-9c4d-a4ec-a5999271fb5c",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 18025,
			"tags" : [
				"B16"
			],
			"type" : "slope",
			"to" : 2125,
			"from" : 2121,
			"brick" : "B16",
			"name" : "18025",
			"uuid" : "0db01038-f930-3f4b-a63d-e3c48ea5e186",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 18026,
			"tags" : [
				"B16"
			],
			"type" : "slope",
			"to" : 2126,
			"from" : 2122,
			"brick" : "B16",
			"name" : "18026",
			"uuid" : "04693958-4f47-5648-b759-08269941b9fa",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 18027,
			"tags" : [
				"B16"
			],
			"type" : "slope",
			"to" : 2127,
			"from" : 2123,
			"brick" : "B16",
			"name" : "18027",
			"uuid" : "a99ca635-2f8a-0541-8f19-be19136dc868",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 18028,
			"tags" : [
				"B16"
			],
			"type" : "slope",
			"to" : 2128,
			"from" : 2124,
			"brick" : "B16",
			"name" : "18028",
			"uuid" : "6d368f12-cd80-114a-9e6e-19927453712b",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 18029,
			"tags" : [
				"B16"
			],
			"type" : "slope",
			"to" : 2129,
			"from" : 2125,
			"brick" : "B16",
			"name" : "18029",
			"uuid" : "7c899407-8c2c-a546-8845-209106662f76",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 18030,
			"tags" : [
				"B16"
			],
			"type" : "slope",
			"to" : 2130,
			"from" : 2126,
			"brick" : "B16",
			"name" : "18030",
			"uuid" : "ca097b47-c00d-3b40-a5d8-88132d9b199c",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 18031,
			"tags" : [
				"B16"
			],
			"type" : "slope",
			"to" : 2131,
			"from" : 2127,
			"brick" : "B16",
			"name" : "18031",
			"uuid" : "e466b0f5-ddb3-9445-80d2-596309f64f19",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 18032,
			"tags" : [
				"B16"
			],
			"type" : "slope",
			"to" : 2132,
			"from" : 2128,
			"brick" : "B16",
			"name" : "18032",
			"uuid" : "441d2d3d-e5b0-8a4a-a06c-12f607a45da1",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 18033,
			"tags" : [
				"B16"
			],
			"type" : "slope",
			"to" : 2133,
			"from" : 2129,
			"brick" : "B16",
			"name" : "18033",
			"uuid" : "92421c07-c7fd-0243-9553-8217bf79c762",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 18034,
			"tags" : [
				"B16"
			],
			"type" : "slope",
			"to" : 2134,
			"from" : 2130,
			"brick" : "B16",
			"name" : "18034",
			"uuid" : "f9257c01-604d-9d46-a29f-d85f5b4ca272",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 18035,
			"tags" : [
				"B16"
			],
			"type" : "slope",
			"to" : 2135,
			"from" : 2131,
			"brick" : "B16",
			"name" : "18035",
			"uuid" : "5ee9e0b0-90cf-e945-bca8-5e3b46fa0e81",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 18036,
			"tags" : [
				"B16"
			],
			"type" : "slope",
			"to" : 2136,
			"from" : 2132,
			"brick" : "B16",
			"name" : "18036",
			"uuid" : "d52b0c36-88d6-8a4a-b514-cfd55634a8f5",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 18037,
			"tags" : [
				"B16"
			],
			"type" : "slope",
			"to" : 2137,
			"from" : 2133,
			"brick" : "B16",
			"name" : "18037",
			"uuid" : "7ff50cda-bbdc-044c-9a0d-80566eda4638",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 18038,
			"tags" : [
				"B16"
			],
			"type" : "slope",
			"to" : 2138,
			"from" : 2134,
			"brick" : "B16",
			"name" : "18038",
			"uuid" : "95eb33fb-927a-cb4c-88df-4cb278364be7",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 18039,
			"tags" : [
				"B16"
			],
			"type" : "slope",
			"to" : 2139,
			"from" : 2135,
			"brick" : "B16",
			"name" : "18039",
			"uuid" : "c33fdbf2-5a3b-134c-a23c-f2f6e78bf123",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 18040,
			"tags" : [
				"B16"
			],
			"type" : "slope",
			"to" : 2140,
			"from" : 2136,
			"brick" : "B16",
			"name" : "18040",
			"uuid" : "e9bd5c75-bf2d-fd45-a3e1-ed4a2cf03e03",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 18041,
			"tags" : [
				"B16"
			],
			"type" : "slope",
			"to" : 2141,
			"from" : 2137,
			"brick" : "B16",
			"name" : "18041",
			"uuid" : "b0c938ca-d3a0-ff46-b093-4fd19a74356e",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 18042,
			"tags" : [
				"B16"
			],
			"type" : "slope",
			"to" : 2142,
			"from" : 2138,
			"brick" : "B16",
			"name" : "18042",
			"uuid" : "055294f8-7495-5f49-94ea-395fc2f5ee23",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 18043,
			"tags" : [
				"B16"
			],
			"type" : "slope",
			"to" : 2143,
			"from" : 2139,
			"brick" : "B16",
			"name" : "18043",
			"uuid" : "c425117a-e78d-724f-ad58-4e6704471ffa",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 18044,
			"tags" : [
				"B16"
			],
			"type" : "slope",
			"to" : 2144,
			"from" : 2140,
			"brick" : "B16",
			"name" : "18044",
			"uuid" : "96bea7f7-03b8-fc44-99ea-20f8d975c95b",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 18045,
			"tags" : [
				"B16"
			],
			"type" : "slope",
			"to" : 2145,
			"from" : 2141,
			"brick" : "B16",
			"name" : "18045",
			"uuid" : "a6ef2596-9e9c-364e-a755-04437f7296b0",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 18046,
			"tags" : [
				"B16"
			],
			"type" : "slope",
			"to" : 2146,
			"from" : 2142,
			"brick" : "B16",
			"name" : "18046",
			"uuid" : "237cc374-7a5f-8345-8d45-e96b46a50e21",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 18047,
			"tags" : [
				"B16"
			],
			"type" : "slope",
			"to" : 2147,
			"from" : 2143,
			"brick" : "B16",
			"name" : "18047",
			"uuid" : "3339515b-2e23-0f42-8fc7-691650d8a25e",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 18048,
			"tags" : [
				"B16"
			],
			"type" : "slope",
			"to" : 2148,
			"from" : 2144,
			"brick" : "B16",
			"name" : "18048",
			"uuid" : "ae8fc2e0-c136-a744-b749-32ae7b5fcfd7",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 18049,
			"tags" : [
				"B16"
			],
			"type" : "slope",
			"to" : 2149,
			"from" : 2145,
			"brick" : "B16",
			"name" : "18049",
			"uuid" : "406e89b0-157a-2648-89e4-f9f20ffe22d1",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 18050,
			"tags" : [
				"B16"
			],
			"type" : "slope",
			"to" : 2150,
			"from" : 2146,
			"brick" : "B16",
			"name" : "18050",
			"uuid" : "535bc214-3012-ba46-8d23-624b32253952",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 18051,
			"tags" : [
				"B16"
			],
			"type" : "slope",
			"to" : 2151,
			"from" : 2147,
			"brick" : "B16",
			"name" : "18051",
			"uuid" : "a06d4cb6-5a86-af41-ad79-223b8b473c77",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 18052,
			"tags" : [
				"B16"
			],
			"type" : "slope",
			"to" : 2152,
			"from" : 2148,
			"brick" : "B16",
			"name" : "18052",
			"uuid" : "f658d344-2890-0a47-aaad-0995e0e98145",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 18053,
			"tags" : [
				"B16"
			],
			"type" : "slope",
			"to" : 1618,
			"from" : 2149,
			"brick" : "B16",
			"name" : "18053",
			"uuid" : "7bda5300-aa98-0c4d-9f1d-e2c9ceec9432",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 18054,
			"tags" : [
				"B16"
			],
			"type" : "slope",
			"to" : 1622,
			"from" : 2150,
			"brick" : "B16",
			"name" : "18054",
			"uuid" : "1b693f64-4165-a741-ae86-1bda0b2649b9",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 18055,
			"tags" : [
				"B16"
			],
			"type" : "slope",
			"to" : 1623,
			"from" : 2151,
			"brick" : "B16",
			"name" : "18055",
			"uuid" : "2bcb1abc-94d3-7545-b2fb-a9f36822e4b9",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 18056,
			"tags" : [
				"B16"
			],
			"type" : "slope",
			"to" : 1619,
			"from" : 2152,
			"brick" : "B16",
			"name" : "18056",
			"uuid" : "dcf645bd-217d-6544-91c7-33672d7b264d",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 36001,
			"tags" : [
				"B16"
			],
			"type" : "sectionRound",
			"to" : 2102,
			"from" : 2101,
			"brick" : "B16",
			"name" : "36001",
			"uuid" : "4317d7b7-612b-5f4b-b1f0-aae561f9f4f5",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 36002,
			"tags" : [
				"B16"
			],
			"type" : "sectionRound",
			"to" : 2103,
			"from" : 2102,
			"brick" : "B16",
			"name" : "36002",
			"uuid" : "14d5a5e8-b6b6-0e44-bbdb-5801a12b4f5a",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 36003,
			"tags" : [
				"B16"
			],
			"type" : "sectionRound",
			"to" : 2104,
			"from" : 2103,
			"brick" : "B16",
			"name" : "36003",
			"uuid" : "f03a459e-9de1-b544-bbfa-f89ab7a46f2a",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 36004,
			"tags" : [
				"B16"
			],
			"type" : "sectionRound",
			"to" : 2101,
			"from" : 2104,
			"brick" : "B16",
			"name" : "36004",
			"uuid" : "2ff306f5-fac9-3e40-a24b-05e8b7aa97ce",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 36005,
			"tags" : [
				"B16"
			],
			"type" : "sectionRound",
			"to" : 2153,
			"from" : 2105,
			"brick" : "B16",
			"name" : "36005",
			"uuid" : "0c67f350-8e7e-0b4a-bfd8-56d3a3413abb",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 36006,
			"tags" : [
				"B16"
			],
			"type" : "sectionRound",
			"to" : 2106,
			"from" : 2153,
			"brick" : "B16",
			"name" : "36006",
			"uuid" : "949ee66d-df4c-d14e-b3f6-dde6e2a5a256",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 36007,
			"tags" : [
				"B16"
			],
			"type" : "sectionRound",
			"to" : 2107,
			"from" : 2106,
			"brick" : "B16",
			"name" : "36007",
			"uuid" : "f3ef0935-5af3-1747-8521-a6a689a31832",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 36008,
			"tags" : [
				"B16"
			],
			"type" : "sectionRound",
			"to" : 2154,
			"from" : 2107,
			"brick" : "B16",
			"name" : "36008",
			"uuid" : "979aefca-91f6-2a4d-bf19-c9bfd0c27b28",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 36009,
			"tags" : [
				"B16"
			],
			"type" : "sectionRound",
			"to" : 2108,
			"from" : 2154,
			"brick" : "B16",
			"name" : "36009",
			"uuid" : "c56fb5ff-b979-2844-a0ee-09367d11f10b",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 36010,
			"tags" : [
				"B16"
			],
			"type" : "sectionRound",
			"to" : 2105,
			"from" : 2108,
			"brick" : "B16",
			"name" : "36010",
			"uuid" : "cc7d63cc-1343-3749-af4e-e4046a587dcc",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 36011,
			"tags" : [
				"B16"
			],
			"type" : "sectionRound",
			"to" : 2110,
			"from" : 2109,
			"brick" : "B16",
			"name" : "36011",
			"uuid" : "374c5af1-95f3-ee43-a736-70c332e33462",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 36012,
			"tags" : [
				"B16"
			],
			"type" : "sectionRound",
			"to" : 2155,
			"from" : 2110,
			"brick" : "B16",
			"name" : "36012",
			"uuid" : "14812836-7cfd-f646-a23c-dbe9796ca1a8",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 36013,
			"tags" : [
				"B16"
			],
			"type" : "sectionRound",
			"to" : 2111,
			"from" : 2155,
			"brick" : "B16",
			"name" : "36013",
			"uuid" : "7015b8e0-b4a8-9445-8f02-9df5ff186970",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 36014,
			"tags" : [
				"B16"
			],
			"type" : "sectionRound",
			"to" : 2112,
			"from" : 2111,
			"brick" : "B16",
			"name" : "36014",
			"uuid" : "c34f6254-1ef0-9b43-8bba-8cbdb5fc70cd",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 36015,
			"tags" : [
				"B16"
			],
			"type" : "sectionRound",
			"to" : 2156,
			"from" : 2112,
			"brick" : "B16",
			"name" : "36015",
			"uuid" : "2df6d86c-50cf-9342-bb94-603fb29e527b",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 36016,
			"tags" : [
				"B16"
			],
			"type" : "sectionRound",
			"to" : 2109,
			"from" : 2156,
			"brick" : "B16",
			"name" : "36016",
			"uuid" : "fd9d56db-c80b-1846-a6c4-d1b3a1c4c778",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 36017,
			"tags" : [
				"B16"
			],
			"type" : "sectionRound",
			"to" : 2114,
			"from" : 2113,
			"brick" : "B16",
			"name" : "36017",
			"uuid" : "a9d4adf6-bdf0-0245-9f97-76ea41c758b9",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 36018,
			"tags" : [
				"B16"
			],
			"type" : "sectionRound",
			"to" : 2115,
			"from" : 2114,
			"brick" : "B16",
			"name" : "36018",
			"uuid" : "27dc77e6-1094-4d4e-93ba-3075f9d85e0a",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 36019,
			"tags" : [
				"B16"
			],
			"type" : "sectionRound",
			"to" : 2116,
			"from" : 2115,
			"brick" : "B16",
			"name" : "36019",
			"uuid" : "b6618cfb-1590-804b-a516-52af53e13043",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 36020,
			"tags" : [
				"B16"
			],
			"type" : "sectionRound",
			"to" : 2113,
			"from" : 2116,
			"brick" : "B16",
			"name" : "36020",
			"uuid" : "cde9b5fa-753d-024c-b17b-48be2c3eeff9",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 36021,
			"tags" : [
				"B16"
			],
			"type" : "sectionRound",
			"to" : 2118,
			"from" : 2117,
			"brick" : "B16",
			"name" : "36021",
			"uuid" : "eebf0050-edee-aa47-a4ef-ff0e8bccf342",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 36022,
			"tags" : [
				"B16"
			],
			"type" : "sectionRound",
			"to" : 2119,
			"from" : 2118,
			"brick" : "B16",
			"name" : "36022",
			"uuid" : "a65f3e44-26ce-c44f-8cce-346d6337f7b9",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 36023,
			"tags" : [
				"B16"
			],
			"type" : "sectionRound",
			"to" : 2120,
			"from" : 2119,
			"brick" : "B16",
			"name" : "36023",
			"uuid" : "74a16820-77a6-8142-8b38-acaba456535c",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 36024,
			"tags" : [
				"B16"
			],
			"type" : "sectionRound",
			"to" : 2117,
			"from" : 2120,
			"brick" : "B16",
			"name" : "36024",
			"uuid" : "81883bc6-caf9-cb4b-b6de-524bd4ed8135",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 36025,
			"tags" : [
				"B16"
			],
			"type" : "sectionRound",
			"to" : 2122,
			"from" : 2121,
			"brick" : "B16",
			"name" : "36025",
			"uuid" : "0fac833b-4391-2a46-81b3-f4a9775926e4",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 36026,
			"tags" : [
				"B16"
			],
			"type" : "sectionRound",
			"to" : 2123,
			"from" : 2122,
			"brick" : "B16",
			"name" : "36026",
			"uuid" : "a84ffe52-043f-cf4a-b97f-f365657dcc83",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 36027,
			"tags" : [
				"B16"
			],
			"type" : "sectionRound",
			"to" : 2124,
			"from" : 2123,
			"brick" : "B16",
			"name" : "36027",
			"uuid" : "fbdc7a64-c778-324a-b376-0b650d151f33",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 36028,
			"tags" : [
				"B16"
			],
			"type" : "sectionRound",
			"to" : 2121,
			"from" : 2124,
			"brick" : "B16",
			"name" : "36028",
			"uuid" : "91960fbf-ee2d-ba4b-8efc-2b996bc34c16",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 36029,
			"tags" : [
				"B16"
			],
			"type" : "sectionRound",
			"to" : 2157,
			"from" : 2125,
			"brick" : "B16",
			"name" : "36029",
			"uuid" : "f007f709-14e0-e04d-b2da-57e185d1c719",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 36030,
			"tags" : [
				"B16"
			],
			"type" : "sectionRound",
			"to" : 2126,
			"from" : 2157,
			"brick" : "B16",
			"name" : "36030",
			"uuid" : "2d672394-2973-e54a-afd0-8c2c5ff8a645",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 36031,
			"tags" : [
				"B16"
			],
			"type" : "sectionRound",
			"to" : 2158,
			"from" : 2126,
			"brick" : "B16",
			"name" : "36031",
			"uuid" : "c5040d37-a174-994d-825c-2a5d83d4176e",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 36032,
			"tags" : [
				"B16"
			],
			"type" : "sectionRound",
			"to" : 2127,
			"from" : 2158,
			"brick" : "B16",
			"name" : "36032",
			"uuid" : "c08fbb52-4288-6944-9dc9-8646d1d297f2",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 36033,
			"tags" : [
				"B16"
			],
			"type" : "sectionRound",
			"to" : 2159,
			"from" : 2127,
			"brick" : "B16",
			"name" : "36033",
			"uuid" : "bae7138c-0d64-4a4e-8c38-6f59843ddc9a",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 36034,
			"tags" : [
				"B16"
			],
			"type" : "sectionRound",
			"to" : 2128,
			"from" : 2159,
			"brick" : "B16",
			"name" : "36034",
			"uuid" : "d67a7437-4fae-3b49-b741-22051610302d",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 36035,
			"tags" : [
				"B16"
			],
			"type" : "sectionRound",
			"to" : 2160,
			"from" : 2128,
			"brick" : "B16",
			"name" : "36035",
			"uuid" : "dbf9be9c-bc9f-2c4a-b809-3a5da0e3b5b5",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 36036,
			"tags" : [
				"B16"
			],
			"type" : "sectionRound",
			"to" : 2125,
			"from" : 2160,
			"brick" : "B16",
			"name" : "36036",
			"uuid" : "cc5552b1-c0f4-b34f-bea8-10f233ac697f",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 36037,
			"tags" : [
				"B16"
			],
			"type" : "sectionRound",
			"to" : 2130,
			"from" : 2129,
			"brick" : "B16",
			"name" : "36037",
			"uuid" : "6b3246b0-5029-f445-97f3-1ca0782ecb5e",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 36038,
			"tags" : [
				"B16"
			],
			"type" : "sectionRound",
			"to" : 2131,
			"from" : 2130,
			"brick" : "B16",
			"name" : "36038",
			"uuid" : "9831c5bd-e261-b242-9d60-4d301f8da50e",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 36039,
			"tags" : [
				"B16"
			],
			"type" : "sectionRound",
			"to" : 2132,
			"from" : 2131,
			"brick" : "B16",
			"name" : "36039",
			"uuid" : "dcbd5270-49bf-7345-9039-e0c4b5f523b3",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 36040,
			"tags" : [
				"B16"
			],
			"type" : "sectionRound",
			"to" : 2129,
			"from" : 2132,
			"brick" : "B16",
			"name" : "36040",
			"uuid" : "4de6c482-f475-aa46-bc82-e059decd2b4a",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 36041,
			"tags" : [
				"B16"
			],
			"type" : "sectionRound",
			"to" : 2134,
			"from" : 2133,
			"brick" : "B16",
			"name" : "36041",
			"uuid" : "bfb3b4c5-4ff8-2948-a8fb-fef13452f7d7",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 36042,
			"tags" : [
				"B16"
			],
			"type" : "sectionRound",
			"to" : 2135,
			"from" : 2134,
			"brick" : "B16",
			"name" : "36042",
			"uuid" : "f5c72a4c-43da-ef4b-938e-2627b5352fa0",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 36043,
			"tags" : [
				"B16"
			],
			"type" : "sectionRound",
			"to" : 2136,
			"from" : 2135,
			"brick" : "B16",
			"name" : "36043",
			"uuid" : "27a7eba7-c1bd-2d41-80af-f6dc40199b4d",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 36044,
			"tags" : [
				"B16"
			],
			"type" : "sectionRound",
			"to" : 2133,
			"from" : 2136,
			"brick" : "B16",
			"name" : "36044",
			"uuid" : "2d8ecf12-6e0d-444d-b383-528475abd143",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 36045,
			"tags" : [
				"B16"
			],
			"type" : "sectionRound",
			"to" : 2138,
			"from" : 2137,
			"brick" : "B16",
			"name" : "36045",
			"uuid" : "27fab09a-d843-6544-8079-d73d80a894a0",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 36046,
			"tags" : [
				"B16"
			],
			"type" : "sectionRound",
			"to" : 2139,
			"from" : 2138,
			"brick" : "B16",
			"name" : "36046",
			"uuid" : "23214ded-2f6b-8c43-997f-249d04c22bf6",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 36047,
			"tags" : [
				"B16"
			],
			"type" : "sectionRound",
			"to" : 2140,
			"from" : 2139,
			"brick" : "B16",
			"name" : "36047",
			"uuid" : "7d2e9cbe-c249-cd4c-bec5-e46ecc79de4e",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 36048,
			"tags" : [
				"B16"
			],
			"type" : "sectionRound",
			"to" : 2137,
			"from" : 2140,
			"brick" : "B16",
			"name" : "36048",
			"uuid" : "c4acf6dc-1af3-ed41-80a2-5db96736e13f",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 36049,
			"tags" : [
				"B16"
			],
			"type" : "sectionRound",
			"to" : 2142,
			"from" : 2141,
			"brick" : "B16",
			"name" : "36049",
			"uuid" : "683f6345-4ddd-f54f-b6b7-4e592f39c50d",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 36050,
			"tags" : [
				"B16"
			],
			"type" : "sectionRound",
			"to" : 2161,
			"from" : 2142,
			"brick" : "B16",
			"name" : "36050",
			"uuid" : "e4f5041a-42ef-5744-ae84-a4a7f8453aec",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 36051,
			"tags" : [
				"B16"
			],
			"type" : "sectionRound",
			"to" : 2143,
			"from" : 2161,
			"brick" : "B16",
			"name" : "36051",
			"uuid" : "2e101567-93c6-b24b-8d76-d80d41546685",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 36052,
			"tags" : [
				"B16"
			],
			"type" : "sectionRound",
			"to" : 2144,
			"from" : 2143,
			"brick" : "B16",
			"name" : "36052",
			"uuid" : "4b3ccb61-3605-5746-b6bb-69a2a7a11145",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 36053,
			"tags" : [
				"B16"
			],
			"type" : "sectionRound",
			"to" : 2162,
			"from" : 2144,
			"brick" : "B16",
			"name" : "36053",
			"uuid" : "74160282-f968-e841-9055-9be1a20cfb72",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 36054,
			"tags" : [
				"B16"
			],
			"type" : "sectionRound",
			"to" : 2141,
			"from" : 2162,
			"brick" : "B16",
			"name" : "36054",
			"uuid" : "16cb4bc3-fec3-5c4a-b4d5-a8b58acd93e7",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 36055,
			"tags" : [
				"B16"
			],
			"type" : "sectionRound",
			"to" : 2163,
			"from" : 2145,
			"brick" : "B16",
			"name" : "36055",
			"uuid" : "6e93b158-cd96-e741-9591-a74c61cc7121",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 36056,
			"tags" : [
				"B16"
			],
			"type" : "sectionRound",
			"to" : 2146,
			"from" : 2163,
			"brick" : "B16",
			"name" : "36056",
			"uuid" : "235c038b-9624-654d-819d-394881bc6f25",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 36057,
			"tags" : [
				"B16"
			],
			"type" : "sectionRound",
			"to" : 2147,
			"from" : 2146,
			"brick" : "B16",
			"name" : "36057",
			"uuid" : "0e42b29c-277f-fc40-8ec9-28a46a59c45a",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 36058,
			"tags" : [
				"B16"
			],
			"type" : "sectionRound",
			"to" : 2164,
			"from" : 2147,
			"brick" : "B16",
			"name" : "36058",
			"uuid" : "7e65028c-94f6-0145-a2ba-eb06e495db3d",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 36059,
			"tags" : [
				"B16"
			],
			"type" : "sectionRound",
			"to" : 2148,
			"from" : 2164,
			"brick" : "B16",
			"name" : "36059",
			"uuid" : "6965a6aa-6d69-5648-842e-ebd2f5555488",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 36060,
			"tags" : [
				"B16"
			],
			"type" : "sectionRound",
			"to" : 2145,
			"from" : 2148,
			"brick" : "B16",
			"name" : "36060",
			"uuid" : "5d435459-f572-764d-a4f3-a5031a9e9b26",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 36061,
			"tags" : [
				"B16"
			],
			"type" : "sectionRound",
			"to" : 2150,
			"from" : 2149,
			"brick" : "B16",
			"name" : "36061",
			"uuid" : "846b37b0-628f-0044-a4fc-2c87c6ff1559",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 36062,
			"tags" : [
				"B16"
			],
			"type" : "sectionRound",
			"to" : 2151,
			"from" : 2150,
			"brick" : "B16",
			"name" : "36062",
			"uuid" : "92682d7a-ca67-d946-98ef-b94f2b135d8f",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 36063,
			"tags" : [
				"B16"
			],
			"type" : "sectionRound",
			"to" : 2152,
			"from" : 2151,
			"brick" : "B16",
			"name" : "36063",
			"uuid" : "4d5cfd73-db94-5b47-b277-cb863094cd39",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 36064,
			"tags" : [
				"B16"
			],
			"type" : "sectionRound",
			"to" : 2149,
			"from" : 2152,
			"brick" : "B16",
			"name" : "36064",
			"uuid" : "a627cc84-f6eb-f043-a965-96f3b6e3a5a8",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 36101,
			"tags" : [
				"B16"
			],
			"type" : "sectionSlant",
			"to" : 2105,
			"from" : 3001,
			"brick" : "B16",
			"name" : "36101",
			"uuid" : "41540cf6-e33b-e745-82ca-7953f996a6c5",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 36102,
			"tags" : [
				"B16"
			],
			"type" : "sectionSlant",
			"to" : 3001,
			"from" : 2107,
			"brick" : "B16",
			"name" : "36102",
			"uuid" : "56c3ec84-246d-ca41-9a66-51b703eff373",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 36103,
			"tags" : [
				"B16"
			],
			"type" : "sectionSlant",
			"to" : 2108,
			"from" : 3001,
			"brick" : "B16",
			"name" : "36103",
			"uuid" : "174005f8-28cf-764b-b45f-f2de80f82161",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 36104,
			"tags" : [
				"B16"
			],
			"type" : "sectionSlant",
			"to" : 3001,
			"from" : 2106,
			"brick" : "B16",
			"name" : "36104",
			"uuid" : "6efa8838-acec-8a47-b28b-08458814f7e9",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 36105,
			"tags" : [
				"B16"
			],
			"type" : "sectionSlant",
			"to" : 2109,
			"from" : 3002,
			"brick" : "B16",
			"name" : "36105",
			"uuid" : "64e985a2-a62a-384c-8acc-3218cca8fd06",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 36106,
			"tags" : [
				"B16"
			],
			"type" : "sectionSlant",
			"to" : 3002,
			"from" : 2111,
			"brick" : "B16",
			"name" : "36106",
			"uuid" : "9162f5ea-8d25-5145-ad9a-99a5d49ad242",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 36107,
			"tags" : [
				"B16"
			],
			"type" : "sectionSlant",
			"to" : 2112,
			"from" : 3002,
			"brick" : "B16",
			"name" : "36107",
			"uuid" : "d423924e-279a-634f-9c0d-08803a51ea11",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 36108,
			"tags" : [
				"B16"
			],
			"type" : "sectionSlant",
			"to" : 3002,
			"from" : 2110,
			"brick" : "B16",
			"name" : "36108",
			"uuid" : "ea3ba5b0-1d2f-994e-80de-e82ddf464247",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 36109,
			"tags" : [
				"B16"
			],
			"type" : "sectionSlant",
			"to" : 2125,
			"from" : 3003,
			"brick" : "B16",
			"name" : "36109",
			"uuid" : "5c7680f2-007c-4f4d-b507-906ed27825ea",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 36110,
			"tags" : [
				"B16"
			],
			"type" : "sectionSlant",
			"to" : 3003,
			"from" : 2127,
			"brick" : "B16",
			"name" : "36110",
			"uuid" : "b416deee-989d-f541-9c76-66dfde17a4fa",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 36111,
			"tags" : [
				"B16"
			],
			"type" : "sectionSlant",
			"to" : 2128,
			"from" : 3003,
			"brick" : "B16",
			"name" : "36111",
			"uuid" : "93887bb2-a3df-6e47-9656-1443056c6d6c",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 36112,
			"tags" : [
				"B16"
			],
			"type" : "sectionSlant",
			"to" : 3003,
			"from" : 2126,
			"brick" : "B16",
			"name" : "36112",
			"uuid" : "5e208852-e952-1b47-977b-15bea6860cb4",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 36113,
			"tags" : [
				"B16"
			],
			"type" : "sectionSlant",
			"to" : 2141,
			"from" : 3004,
			"brick" : "B16",
			"name" : "36113",
			"uuid" : "11a65a9f-b58e-5040-9683-b04e43275971",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 36114,
			"tags" : [
				"B16"
			],
			"type" : "sectionSlant",
			"to" : 3004,
			"from" : 2143,
			"brick" : "B16",
			"name" : "36114",
			"uuid" : "55157729-26c9-a440-9009-957485760cee",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 36115,
			"tags" : [
				"B16"
			],
			"type" : "sectionSlant",
			"to" : 2144,
			"from" : 3004,
			"brick" : "B16",
			"name" : "36115",
			"uuid" : "2e363f1a-5aba-d84d-b973-1fcea9bb679a",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 36116,
			"tags" : [
				"B16"
			],
			"type" : "sectionSlant",
			"to" : 3004,
			"from" : 2142,
			"brick" : "B16",
			"name" : "36116",
			"uuid" : "3f56e553-8a35-474a-85eb-18908b500455",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 36117,
			"tags" : [
				"B16"
			],
			"type" : "sectionSlant",
			"to" : 2145,
			"from" : 3005,
			"brick" : "B16",
			"name" : "36117",
			"uuid" : "d275b573-b1b1-bc49-b293-31397cd0c5d0",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 36118,
			"tags" : [
				"B16"
			],
			"type" : "sectionSlant",
			"to" : 3005,
			"from" : 2147,
			"brick" : "B16",
			"name" : "36118",
			"uuid" : "deea201b-751a-3f48-a335-64bd5eea8861",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 36119,
			"tags" : [
				"B16"
			],
			"type" : "sectionSlant",
			"to" : 2148,
			"from" : 3005,
			"brick" : "B16",
			"name" : "36119",
			"uuid" : "ec8dcf42-5de1-7047-a62e-2bcd7609c840",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 36120,
			"tags" : [
				"B16"
			],
			"type" : "sectionSlant",
			"to" : 3005,
			"from" : 2146,
			"brick" : "B16",
			"name" : "36120",
			"uuid" : "9cccc008-f84a-1e4b-b32b-25ac749f0598",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 36121,
			"tags" : [
				"B16"
			],
			"type" : "sectionVertical",
			"to" : 2156,
			"from" : 3002,
			"brick" : "B16",
			"name" : "36121",
			"uuid" : "62b84919-a3df-dd45-a882-e0755e882d85",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 36122,
			"tags" : [
				"B16"
			],
			"type" : "sectionVertical",
			"to" : 3002,
			"from" : 2155,
			"brick" : "B16",
			"name" : "36122",
			"uuid" : "c79a7e75-02b8-1844-b68e-3135ef48e4e3",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 36123,
			"tags" : [
				"B16"
			],
			"type" : "sectionVertical",
			"to" : 2160,
			"from" : 3003,
			"brick" : "B16",
			"name" : "36123",
			"uuid" : "01931902-1c97-474a-9d7c-0bfe7986cefe",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 36124,
			"tags" : [
				"B16"
			],
			"type" : "sectionVertical",
			"to" : 3003,
			"from" : 2158,
			"brick" : "B16",
			"name" : "36124",
			"uuid" : "b1a215c2-7572-5b45-8721-831132d65449",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 36125,
			"tags" : [
				"B16"
			],
			"type" : "sectionVertical",
			"to" : 2162,
			"from" : 3004,
			"brick" : "B16",
			"name" : "36125",
			"uuid" : "1063fbea-9b6b-3e4b-b08a-09cd18ac4193",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 36126,
			"tags" : [
				"B16"
			],
			"type" : "sectionVertical",
			"to" : 3004,
			"from" : 2161,
			"brick" : "B16",
			"name" : "36126",
			"uuid" : "85efef65-908c-c44d-a829-77622d278b26",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 36127,
			"tags" : [
				"B16"
			],
			"type" : "sectionHorizontal",
			"to" : 3001,
			"from" : 2154,
			"brick" : "B16",
			"name" : "36127",
			"uuid" : "28e567d1-cb3b-e848-b0de-64a55cfc5760",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 36128,
			"tags" : [
				"B16"
			],
			"type" : "sectionHorizontal",
			"to" : 2153,
			"from" : 3001,
			"brick" : "B16",
			"name" : "36128",
			"uuid" : "62e8a2d2-81df-ec46-ac0b-c94e5c97fa56",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 36129,
			"tags" : [
				"B16"
			],
			"type" : "sectionHorizontal",
			"to" : 3003,
			"from" : 2159,
			"brick" : "B16",
			"name" : "36129",
			"uuid" : "b6ad7a6f-9096-d746-abe9-7e3c66d22d5c",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 36130,
			"tags" : [
				"B16"
			],
			"type" : "sectionHorizontal",
			"to" : 2157,
			"from" : 3003,
			"brick" : "B16",
			"name" : "36130",
			"uuid" : "493c6fae-089d-ea45-9234-2288961015ca",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 36131,
			"tags" : [
				"B16"
			],
			"type" : "sectionHorizontal",
			"to" : 3005,
			"from" : 2164,
			"brick" : "B16",
			"name" : "36131",
			"uuid" : "a636157d-bca5-f145-abbd-cc52221deca0",
			"_clazz" : "TwkSegment"
		},
		{
			"number" : 36132,
			"tags" : [
				"B16"
			],
			"type" : "sectionHorizontal",
			"to" : 2163,
			"from" : 3005,
			"brick" : "B16",
			"name" : "36132",
			"uuid" : "d6977d75-dcaf-f34c-a0da-9c3eb336a68a",
			"_clazz" : "TwkSegment"
		},
		{
			"uuid" : "398a9943-18a8-fc4a-aaeb-ba2eec5bd74f",
			"name" : "27001",
			"_clazz" : "TwkSegment",
			"brick" : "FRONT",
			"from" : 1501,
			"face" : "front",
			"tags" : [
				"B16"
			],
			"type" : "panel",
			"to" : 2102,
			"number" : 27001
		},
		{
			"uuid" : "bd44aa55-39b1-f041-a5bb-2fb6b2d4c90e",
			"name" : "27002",
			"_clazz" : "TwkSegment",
			"brick" : "BOTTOM",
			"from" : 1508,
			"face" : "bottom",
			"tags" : [
				"B16"
			],
			"type" : "panel",
			"to" : 2102,
			"number" : 27002
		},
		{
			"uuid" : "ad37cbfc-e0bc-8a45-a005-8b742b09bfec",
			"name" : "27003",
			"_clazz" : "TwkSegment",
			"brick" : "BACK",
			"from" : 1508,
			"face" : "back",
			"tags" : [
				"B16"
			],
			"type" : "panel",
			"to" : 2104,
			"number" : 27003
		},
		{
			"uuid" : "31bd958d-5803-754c-97ff-efde2a8c5f19",
			"name" : "27004",
			"_clazz" : "TwkSegment",
			"brick" : "TOP",
			"from" : 1501,
			"face" : "top",
			"tags" : [
				"B16"
			],
			"type" : "panel",
			"to" : 2104,
			"number" : 27004
		},
		{
			"uuid" : "50b0d6d2-dd7a-fb47-a5d2-43fed00709cb",
			"name" : "27005",
			"_clazz" : "TwkSegment",
			"brick" : "FRONT",
			"from" : 2101,
			"face" : "front",
			"tags" : [
				"B16"
			],
			"type" : "panel",
			"to" : 2106,
			"number" : 27005
		},
		{
			"uuid" : "57362d17-f9b7-6f46-9d45-eb8fb4a87dfe",
			"name" : "27006",
			"_clazz" : "TwkSegment",
			"brick" : "BOTTOM",
			"from" : 2103,
			"face" : "bottom",
			"tags" : [
				"B16"
			],
			"type" : "panel",
			"to" : 2106,
			"number" : 27006
		},
		{
			"uuid" : "7297f36c-3457-0445-bb7c-45f3e725f2a8",
			"name" : "27007",
			"_clazz" : "TwkSegment",
			"brick" : "BACK",
			"from" : 2103,
			"face" : "back",
			"tags" : [
				"B16"
			],
			"type" : "panel",
			"to" : 2108,
			"number" : 27007
		},
		{
			"uuid" : "4b2418f0-a3a2-cf48-b43e-f6dddbd985de",
			"name" : "27008",
			"_clazz" : "TwkSegment",
			"brick" : "TOP",
			"from" : 2101,
			"face" : "top",
			"tags" : [
				"B16"
			],
			"type" : "panel",
			"to" : 2108,
			"number" : 27008
		},
		{
			"uuid" : "824e4f2d-1fcc-c245-b349-1b3201afcd93",
			"name" : "27009",
			"_clazz" : "TwkSegment",
			"brick" : "FRONT",
			"from" : 2105,
			"face" : "front",
			"tags" : [
				"B16"
			],
			"type" : "panel",
			"to" : 2110,
			"number" : 27009
		},
		{
			"uuid" : "39c05154-4a39-664a-bce2-3db66552e90d",
			"name" : "27010",
			"_clazz" : "TwkSegment",
			"brick" : "BOTTOM",
			"from" : 2107,
			"face" : "bottom",
			"tags" : [
				"B16"
			],
			"type" : "panel",
			"to" : 2110,
			"number" : 27010
		},
		{
			"uuid" : "6fa426e9-e2ff-9642-b566-970ba08746e2",
			"name" : "27011",
			"_clazz" : "TwkSegment",
			"brick" : "BACK",
			"from" : 2107,
			"face" : "back",
			"tags" : [
				"B16"
			],
			"type" : "panel",
			"to" : 2112,
			"number" : 27011
		},
		{
			"uuid" : "708bfc19-1e9c-8f48-9800-8afa6515acda",
			"name" : "27012",
			"_clazz" : "TwkSegment",
			"brick" : "TOP",
			"from" : 2105,
			"face" : "top",
			"tags" : [
				"B16"
			],
			"type" : "panel",
			"to" : 2112,
			"number" : 27012
		},
		{
			"uuid" : "34801756-5692-dc4c-91c5-e974f841135f",
			"name" : "27013",
			"_clazz" : "TwkSegment",
			"brick" : "FRONT",
			"from" : 2109,
			"face" : "front",
			"tags" : [
				"B16"
			],
			"type" : "panel",
			"to" : 2114,
			"number" : 27013
		},
		{
			"uuid" : "be48f974-677e-1b44-a18e-942644797bca",
			"name" : "27014",
			"_clazz" : "TwkSegment",
			"brick" : "BOTTOM",
			"from" : 2111,
			"face" : "bottom",
			"tags" : [
				"B16"
			],
			"type" : "panel",
			"to" : 2114,
			"number" : 27014
		},
		{
			"uuid" : "81ea5856-5d70-b445-9f82-e39b3cb27674",
			"name" : "27015",
			"_clazz" : "TwkSegment",
			"brick" : "BACK",
			"from" : 2111,
			"face" : "back",
			"tags" : [
				"B16"
			],
			"type" : "panel",
			"to" : 2116,
			"number" : 27015
		},
		{
			"uuid" : "fa3ed74c-47ea-2141-afc0-0ca342405b22",
			"name" : "27016",
			"_clazz" : "TwkSegment",
			"brick" : "TOP",
			"from" : 2109,
			"face" : "top",
			"tags" : [
				"B16"
			],
			"type" : "panel",
			"to" : 2116,
			"number" : 27016
		},
		{
			"uuid" : "f1d55624-4031-2749-a31f-a5689523e011",
			"name" : "27017",
			"_clazz" : "TwkSegment",
			"brick" : "FRONT",
			"from" : 2113,
			"face" : "front",
			"tags" : [
				"B16"
			],
			"type" : "panel",
			"to" : 2118,
			"number" : 27017
		},
		{
			"uuid" : "cd3f7c64-1a6a-064d-8c2b-8cafe1d47577",
			"name" : "27018",
			"_clazz" : "TwkSegment",
			"brick" : "BOTTOM",
			"from" : 2115,
			"face" : "bottom",
			"tags" : [
				"B16"
			],
			"type" : "panel",
			"to" : 2118,
			"number" : 27018
		},
		{
			"uuid" : "c9328927-b133-0641-92e9-a9a6c9f41e31",
			"name" : "27019",
			"_clazz" : "TwkSegment",
			"brick" : "BACK",
			"from" : 2115,
			"face" : "back",
			"tags" : [
				"B16"
			],
			"type" : "panel",
			"to" : 2120,
			"number" : 27019
		},
		{
			"uuid" : "7cd7dbd7-e3b3-8749-89c6-ceb2a01afa78",
			"name" : "27020",
			"_clazz" : "TwkSegment",
			"brick" : "TOP",
			"from" : 2113,
			"face" : "top",
			"tags" : [
				"B16"
			],
			"type" : "panel",
			"to" : 2120,
			"number" : 27020
		},
		{
			"uuid" : "26671e1c-2758-ee4c-85ad-872a794bd580",
			"name" : "27021",
			"_clazz" : "TwkSegment",
			"brick" : "FRONT",
			"from" : 2117,
			"face" : "front",
			"tags" : [
				"B16"
			],
			"type" : "panel",
			"to" : 2122,
			"number" : 27021
		},
		{
			"uuid" : "293b1e45-3518-1f43-868e-107cd44be234",
			"name" : "27022",
			"_clazz" : "TwkSegment",
			"brick" : "BOTTOM",
			"from" : 2119,
			"face" : "bottom",
			"tags" : [
				"B16"
			],
			"type" : "panel",
			"to" : 2122,
			"number" : 27022
		},
		{
			"uuid" : "15cd8ba4-cec1-cc45-b231-67fca5a555dd",
			"name" : "27023",
			"_clazz" : "TwkSegment",
			"brick" : "BACK",
			"from" : 2119,
			"face" : "back",
			"tags" : [
				"B16"
			],
			"type" : "panel",
			"to" : 2124,
			"number" : 27023
		},
		{
			"uuid" : "6240202a-88bc-834a-bd30-dbb564bf8bab",
			"name" : "27024",
			"_clazz" : "TwkSegment",
			"brick" : "TOP",
			"from" : 2117,
			"face" : "top",
			"tags" : [
				"B16"
			],
			"type" : "panel",
			"to" : 2124,
			"number" : 27024
		},
		{
			"uuid" : "fd6ef683-ce28-c349-8366-fe06f1272343",
			"name" : "27025",
			"_clazz" : "TwkSegment",
			"brick" : "FRONT",
			"from" : 2121,
			"face" : "front",
			"tags" : [
				"B16"
			],
			"type" : "panel",
			"to" : 2126,
			"number" : 27025
		},
		{
			"uuid" : "d5d0041f-071d-3340-973c-b85df5ef486f",
			"name" : "27026",
			"_clazz" : "TwkSegment",
			"brick" : "BOTTOM",
			"from" : 2123,
			"face" : "bottom",
			"tags" : [
				"B16"
			],
			"type" : "panel",
			"to" : 2126,
			"number" : 27026
		},
		{
			"uuid" : "14b74161-77e4-9142-935c-1023057a784c",
			"name" : "27027",
			"_clazz" : "TwkSegment",
			"brick" : "BACK",
			"from" : 2123,
			"face" : "back",
			"tags" : [
				"B16"
			],
			"type" : "panel",
			"to" : 2128,
			"number" : 27027
		},
		{
			"uuid" : "50a6305e-75ea-4942-a360-130852c50ff9",
			"name" : "27028",
			"_clazz" : "TwkSegment",
			"brick" : "TOP",
			"from" : 2121,
			"face" : "top",
			"tags" : [
				"B16"
			],
			"type" : "panel",
			"to" : 2128,
			"number" : 27028
		},
		{
			"uuid" : "32a0afc4-8615-8240-bf20-4d0669dfbf02",
			"name" : "27029",
			"_clazz" : "TwkSegment",
			"brick" : "FRONT",
			"from" : 2126,
			"face" : "front",
			"tags" : [
				"B16"
			],
			"type" : "panel",
			"to" : 2129,
			"number" : 27029
		},
		{
			"uuid" : "2971462d-def5-4c48-b949-b945f4aba1ed",
			"name" : "27030",
			"_clazz" : "TwkSegment",
			"brick" : "BOTTOM",
			"from" : 2126,
			"face" : "bottom",
			"tags" : [
				"B16"
			],
			"type" : "panel",
			"to" : 2131,
			"number" : 27030
		},
		{
			"uuid" : "3039775b-58c7-1d41-8256-ad62dc7829ca",
			"name" : "27031",
			"_clazz" : "TwkSegment",
			"brick" : "BACK",
			"from" : 2128,
			"face" : "back",
			"tags" : [
				"B16"
			],
			"type" : "panel",
			"to" : 2131,
			"number" : 27031
		},
		{
			"uuid" : "a1575da5-34ec-b54d-8268-ba2892579626",
			"name" : "27032",
			"_clazz" : "TwkSegment",
			"brick" : "TOP",
			"from" : 2128,
			"face" : "top",
			"tags" : [
				"B16"
			],
			"type" : "panel",
			"to" : 2129,
			"number" : 27032
		},
		{
			"uuid" : "7fbc6dc5-a3a4-2541-beb7-34d917bb9f93",
			"name" : "27033",
			"_clazz" : "TwkSegment",
			"brick" : "FRONT",
			"from" : 2130,
			"face" : "front",
			"tags" : [
				"B16"
			],
			"type" : "panel",
			"to" : 2133,
			"number" : 27033
		},
		{
			"uuid" : "5d419f99-ca2c-344d-a6bb-ce5ec7ab24f0",
			"name" : "27034",
			"_clazz" : "TwkSegment",
			"brick" : "BOTTOM",
			"from" : 2130,
			"face" : "bottom",
			"tags" : [
				"B16"
			],
			"type" : "panel",
			"to" : 2135,
			"number" : 27034
		},
		{
			"uuid" : "fd64fafe-8630-1d4f-82bc-40408e8fd60d",
			"name" : "27035",
			"_clazz" : "TwkSegment",
			"brick" : "BACK",
			"from" : 2132,
			"face" : "back",
			"tags" : [
				"B16"
			],
			"type" : "panel",
			"to" : 2135,
			"number" : 27035
		},
		{
			"uuid" : "e71d4cc8-af2d-9c44-8405-0291d70b9f40",
			"name" : "27036",
			"_clazz" : "TwkSegment",
			"brick" : "TOP",
			"from" : 2132,
			"face" : "top",
			"tags" : [
				"B16"
			],
			"type" : "panel",
			"to" : 2133,
			"number" : 27036
		},
		{
			"uuid" : "d5e36bc5-1ee6-0943-9889-8840f9f30d30",
			"name" : "27037",
			"_clazz" : "TwkSegment",
			"brick" : "FRONT",
			"from" : 2134,
			"face" : "front",
			"tags" : [
				"B16"
			],
			"type" : "panel",
			"to" : 2137,
			"number" : 27037
		},
		{
			"uuid" : "89406bc0-b625-854f-9472-090c474fa5b8",
			"name" : "27038",
			"_clazz" : "TwkSegment",
			"brick" : "BOTTOM",
			"from" : 2134,
			"face" : "bottom",
			"tags" : [
				"B16"
			],
			"type" : "panel",
			"to" : 2139,
			"number" : 27038
		},
		{
			"uuid" : "49589b08-dde0-204b-b90d-813172c0cd83",
			"name" : "27039",
			"_clazz" : "TwkSegment",
			"brick" : "BACK",
			"from" : 2136,
			"face" : "back",
			"tags" : [
				"B16"
			],
			"type" : "panel",
			"to" : 2139,
			"number" : 27039
		},
		{
			"uuid" : "9a5f0be1-cf88-1d4c-82b8-b2aa7f3448c2",
			"name" : "27040",
			"_clazz" : "TwkSegment",
			"brick" : "TOP",
			"from" : 2136,
			"face" : "top",
			"tags" : [
				"B16"
			],
			"type" : "panel",
			"to" : 2137,
			"number" : 27040
		},
		{
			"uuid" : "1164ee8f-ac37-5048-8e15-615e30ad265a",
			"name" : "27041",
			"_clazz" : "TwkSegment",
			"brick" : "FRONT",
			"from" : 2138,
			"face" : "front",
			"tags" : [
				"B16"
			],
			"type" : "panel",
			"to" : 2141,
			"number" : 27041
		},
		{
			"uuid" : "987cc161-cd03-bb4b-8c16-7b1b3f5ea52f",
			"name" : "27042",
			"_clazz" : "TwkSegment",
			"brick" : "BOTTOM",
			"from" : 2138,
			"face" : "bottom",
			"tags" : [
				"B16"
			],
			"type" : "panel",
			"to" : 2143,
			"number" : 27042
		},
		{
			"uuid" : "f19d7818-490f-1f4a-867f-965ed9085fd2",
			"name" : "27043",
			"_clazz" : "TwkSegment",
			"brick" : "BACK",
			"from" : 2140,
			"face" : "back",
			"tags" : [
				"B16"
			],
			"type" : "panel",
			"to" : 2143,
			"number" : 27043
		},
		{
			"uuid" : "3f43bfb8-6fb2-2b45-8905-c885b63f3aec",
			"name" : "27044",
			"_clazz" : "TwkSegment",
			"brick" : "TOP",
			"from" : 2140,
			"face" : "top",
			"tags" : [
				"B16"
			],
			"type" : "panel",
			"to" : 2141,
			"number" : 27044
		},
		{
			"uuid" : "710e2a16-fbb9-d543-bbea-90c135136b36",
			"name" : "27045",
			"_clazz" : "TwkSegment",
			"brick" : "FRONT",
			"from" : 2142,
			"face" : "front",
			"tags" : [
				"B16"
			],
			"type" : "panel",
			"to" : 2145,
			"number" : 27045
		},
		{
			"uuid" : "3e8fb287-4089-a741-a2f4-f934c27ae935",
			"name" : "27046",
			"_clazz" : "TwkSegment",
			"brick" : "BOTTOM",
			"from" : 2142,
			"face" : "bottom",
			"tags" : [
				"B16"
			],
			"type" : "panel",
			"to" : 2147,
			"number" : 27046
		},
		{
			"uuid" : "9c891ae6-8c72-d34c-8d8e-0e59eb3a954c",
			"name" : "27047",
			"_clazz" : "TwkSegment",
			"brick" : "BACK",
			"from" : 2144,
			"face" : "back",
			"tags" : [
				"B16"
			],
			"type" : "panel",
			"to" : 2147,
			"number" : 27047
		},
		{
			"uuid" : "dd47e21c-c488-ed4d-aba8-be0f726f81ac",
			"name" : "27048",
			"_clazz" : "TwkSegment",
			"brick" : "TOP",
			"from" : 2144,
			"face" : "top",
			"tags" : [
				"B16"
			],
			"type" : "panel",
			"to" : 2145,
			"number" : 27048
		},
		{
			"uuid" : "64a31e44-c2d7-d04a-b856-3ca4cbee1728",
			"name" : "27049",
			"_clazz" : "TwkSegment",
			"brick" : "FRONT",
			"from" : 2146,
			"face" : "front",
			"tags" : [
				"B16"
			],
			"type" : "panel",
			"to" : 2149,
			"number" : 27049
		},
		{
			"uuid" : "02da89e6-0c46-a743-b570-9083f91e56b4",
			"name" : "27050",
			"_clazz" : "TwkSegment",
			"brick" : "BOTTOM",
			"from" : 2146,
			"face" : "bottom",
			"tags" : [
				"B16"
			],
			"type" : "panel",
			"to" : 2151,
			"number" : 27050
		},
		{
			"uuid" : "a6e9f6d2-ea4a-a847-ac4b-a2826187a2fb",
			"name" : "27051",
			"_clazz" : "TwkSegment",
			"brick" : "BACK",
			"from" : 2148,
			"face" : "back",
			"tags" : [
				"B16"
			],
			"type" : "panel",
			"to" : 2151,
			"number" : 27051
		},
		{
			"uuid" : "838bb0f3-22e1-2543-9af7-6bc40b2cc726",
			"name" : "27052",
			"_clazz" : "TwkSegment",
			"brick" : "TOP",
			"from" : 2148,
			"face" : "top",
			"tags" : [
				"B16"
			],
			"type" : "panel",
			"to" : 2149,
			"number" : 27052
		},
		{
			"uuid" : "b445a064-3089-a04f-bdb9-d33e23b3ab0b",
			"name" : "27053",
			"_clazz" : "TwkSegment",
			"brick" : "FRONT",
			"from" : 2150,
			"face" : "front",
			"tags" : [
				"B16"
			],
			"type" : "panel",
			"to" : 1618,
			"number" : 27053
		},
		{
			"uuid" : "0d227ace-2a6c-9641-b5a5-ca60e89b4aec",
			"name" : "27054",
			"_clazz" : "TwkSegment",
			"brick" : "BOTTOM",
			"from" : 2150,
			"face" : "bottom",
			"tags" : [
				"B16"
			],
			"type" : "panel",
			"to" : 1623,
			"number" : 27054
		},
		{
			"uuid" : "7231ff9e-c8ea-8b48-a1ad-b66bac4415e5",
			"name" : "27055",
			"_clazz" : "TwkSegment",
			"brick" : "BACK",
			"from" : 2152,
			"face" : "back",
			"tags" : [
				"B16"
			],
			"type" : "panel",
			"to" : 1623,
			"number" : 27055
		},
		{
			"uuid" : "a57844e7-3ef1-df4f-9cba-34a39964faf4",
			"name" : "27056",
			"_clazz" : "TwkSegment",
			"brick" : "TOP",
			"from" : 2152,
			"face" : "top",
			"tags" : [
				"B16"
			],
			"type" : "panel",
			"to" : 1618,
			"number" : 27056
		}
	]
};
}'
]
