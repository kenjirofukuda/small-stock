Class {
	#name : #BaselineOfGdsFeel,
	#superclass : #BaselineOf,
	#category : #BaselineOfGdsFeel
}

{ #category : #baseline }
BaselineOfGdsFeel >> baseline: spec [
	<baseline>
	spec
		for: #common
		do: [ spec
				baseline: 'NeoJSON'
				with: [ spec repository: 'github://svenvc/NeoJSON/repository' ].
			spec
				baseline: 'NeoCSV'
				with: [ spec repository: 'github://svenvc/NeoCSV/repository' ].
			spec
				baseline: 'INIFile'
				with: [ spec repository: 'github://astares/Pharo-INIFile/src' ].
			spec
				package: 'GdsFeel-Foundation'
				with: [ spec requires: #('NeoJSON' 'NeoCSV' 'INIFile') ].
			spec package: 'GdsFeel-Foundation-Property'.
			spec package: 'GdsFeel-Foundation-Notification'.
			spec package: 'GdsFeel-Foundation-Core'.
			spec package: 'GdsFeel-Foundation-Tests'.
			spec package: 'GdsFeel-CLI-Glamour'.
			spec package: 'GdsFeel-Model-Basic'.
			spec package: 'GdsFeel-Model-Container'.
			spec package: 'GdsFeel-Model-EditSpace'.
			spec package: 'GdsFeel-Model-Element'.
			spec package: 'GdsFeel-Model-ElementAddtion'.
			spec package: 'GdsFeel-Model-Sandbox'.
			spec package: 'GdsFeel-Model-Private'.
			spec package: 'GdsFeel-Model-Viewing'.
			spec package: 'GdsFeel-Model-Tests'.
			spec
				package: 'GdsFeel-Model-Basic'
				with: [ spec
						requires:
							#('GdsFeel-Foundation' 'GdsFeel-Foundation-Core' 'GdsFeel-Foundation-Property' 'GdsFeel-Foundation-Notification' 'GdsFeel-Foundation-Tests') ].
			spec
				baseline: 'KFImaging'
				with: [ spec repository: 'github://kenjirofukuda/imaging-pharo' ].
			spec
				package: 'GdsFeel-UI'
				with: [ spec requires: #('KFImaging' 'NeoCSV' 'Model')
					"'CSV'" ].
			spec
				package: 'GdsFeel-Developer'
				with: [ spec requires: #('GdsFeel-UI') ].
			spec
				package: 'GdsFeel-UI-Athens'
				with: [ spec requires: #('GdsFeel-UI') ].
			spec
				baseline: 'CommandShell'
				with: [ spec
						repository: 'github://dtlewis290/CommandShell-Tonel/src';
						loads: #('CommandShell') ].
			spec package: 'KFConsole'.
			spec
				package: 'GdsFeel-CLI'
				with: [ spec requires: #('GdsFeel-Developer')	"'OSProcess'" ].
			spec
				package: 'GdsFeel-CLI-Commands'
				with: [ spec requires: #('GdsFeel-CLI') ].
			spec
				package: 'GdsFeel-CLI-Console'
				with: [ spec requires: #('GdsFeel-CLI-Commands' 'KFConsole') ].
			spec
				baseline: 'GlamourCore'
				with: [ spec repository: 'github://moosetechnology/glamour/src' ].
			spec
				baseline: 'Magritte'
				with: [ spec
						repository: 'github://magritte-metamodel/magritte:v3.5.4';
						loads: #(Core) ].
			spec
				package: 'GdsFeel-CLI-Glamour'
				with: [ spec requires: #('GdsFeel-CLI' 'GlamourCore') ].
			spec
				package: 'GdsFeel-UI-Spec'
				with: [ spec requires: #('GdsFeel-UI') ].
			spec
				package: 'GdsFeel-Magritte'
				with: [ spec requires: #('GdsFeel-UI') ].
			spec
				group: 'Foundation'
					with:
					#('GdsFeel-Foundation' 'GdsFeel-Foundation-Core' 'GdsFeel-Foundation-Notification' 'GdsFeel-Foundation-Property');
				group: 'Model'
					with:
					#('GdsFeel-Model-Basic' 'GdsFeel-Model-Container' 'GdsFeel-Model-EditSpace' 'GdsFeel-Model-Element' 'GdsFeel-Model-Private' 'GdsFeel-Model-Sandbox' 'GdsFeel-Model-Tests' 'GdsFeel-Model-Viewing');
				group: 'UI'
					with: #('GdsFeel-UI' 'GdsFeel-UI-Spec' 'GdsFeel-Magritte');
				group: 'Developer' with: #('GdsFeel-Developer');
				group: 'CLI' with: #('GdsFeel-CLI-Console').
			spec group: 'UI' with: #('GdsFeel-UI' 'GdsFeel-UI-Athens').
			spec group: 'default' with: #('Model' 'UI' 'CLI') ]
]
