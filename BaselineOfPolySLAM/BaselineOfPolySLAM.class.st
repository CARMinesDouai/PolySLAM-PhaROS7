Class {
	#name : #BaselineOfPolySLAM,
	#superclass : #BaselineOf,
	#category : #BaselineOfPolySLAM
}

{ #category : #baselines }
BaselineOfPolySLAM >> baseline: spec [
	<baseline>
	
	spec for: #common do: [ 
		spec project: 'SciSmalltalk' with: [
				spec
					requires: #('PolySLAM-FixDep');
					className: #ConfigurationOfSciSmalltalk;
					versionString: #'stable';
					repository: 'http://smalltalkhub.com/mc/Pharo/MetaRepoForPharo50/main/' ].
		
		spec
			
			package: 'PolySLAM-FixDep';
			package: 'PolySLAM-Core' with: [ spec requires: #('SciSmalltalk') ];
			package: 'PolySLAM-Tests' with: [ spec requires: #('PolySLAM-Core') ];
			package: 'PolySLAM-Extra' with: [ spec requires: #('PolySLAM-Core') ];
			"groups"
			group: 'core' with: #('PolySLAM-Core');
			group: 'extra' with: #('core' 'PolySLAM-Extra');
			group: 'test' with: #('core' 'PolySLAM-Tests');
			group: 'full' with: #('core' 'PolySLAM-Extra' 'PolySLAM-Tests')
		]
]
