Class {
	#name : #JavascriptMandara,
	#superclass : #MandaraComponent,
	#category : #'KFSeaside-Demos'
}

{ #category : #'as yet unclassified' }
JavascriptMandara class >> initialize [
	"self initialize."

	| application |
	application := WAAdmin register: self asApplicationAt: 'kf/mandara2'.
	application
		preferenceAt: #scriptGeneratorClass
		put: JQScriptGenerator.
	application
		addLibrary: JQBaseTheme;
		addLibrary: JQDeploymentLibrary;
		addLibrary: JQUiDeploymentLibrary
]

{ #category : #rendering }
JavascriptMandara >> jsMandara [
	^ '
function entryPoint(sliderId) {
    var canvas = document.getElementById("mandaraView");
    var ctx = canvas.getContext("2d");

//    var sides = $(sliderId).slider( "option", "value" );
    var sides = 10;

    var i = 0;
    var j = 1;
    var r = Math.min(canvas.width, canvas.height) / 2;
    var color = "rgb(255,0,0)";
    var random = function(max) {
      return Math.floor(Math.random() * max);
    };

    var PI_2 = Math.PI * 2;
    var PI_H = Math.PI / 2;

    (function drawLine() {
//      var newSides = $(sliderId).slider( "option", "value" );
      var newSides = 10;
      if (sides != newSides) {
        i = 0;
        j = 1;
        ctx.clearRect(0, 0, canvas.width, canvas.height)
      }
      sides = newSides;
      ctx.beginPath();
      var inter1 = i / sides * PI_2 + PI_H;
      var x1 = Math.cos(inter1) * r + r;
      var y1 = -Math.sin(inter1) * r + r;
      ctx.moveTo(x1, y1);
      var inter2 = j / sides * PI_2 + PI_H;
      var x2 = Math.cos(inter2) * r + r;
      var y2 = -Math.sin(inter2) * r + r;
      ctx.lineTo(x2, y2);
	ctx.lineWidth = 0.5;
      ctx.strokeStyle = color;
      ctx.closePath();
      ctx.stroke();
      j++;
      if(j >= sides) {
        i++;
        if(i >= sides - 1) {
          color = "rgb(" + random(256) + "," + random(256)
          + "," + random(256) + ")";
          i = 0;
        }
        j = i + 1;
      }
      setTimeout(drawLine, 20);
    })();
}
'
]

{ #category : #rendering }
JavascriptMandara >> renderContentOn: html [
	html heading: 'Mandara (Canvas)'.
	html script: self jsMandara.
	html canvas
		id: 'mandaraView';
		width: 600;
		height: 600.
	slider := html jQuery new slider.
	slider min: 5.
	slider max: 20.
	html div
		script:
			(slider
				value: model sides;
				onStop:
					(html jQuery ajax
						callback: [ :value | model sides: value asNumber ]
						value: html jQuery this slider getValue)).
	html script: 'entryPoint(' , slider owner asJavascript , ')'
]
