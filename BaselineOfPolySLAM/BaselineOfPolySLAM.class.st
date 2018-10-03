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
					className: #ConfigurationOfSciSmalltalk;
					versionString: #'stable';
					repository: 'http://smalltalkhub.com/mc/Pharo/MetaRepoForPharo50/main/' ].
		
		spec
			package: 'PolySLAM-FixDep' with: [ spec requires: #('SciSmalltalk') ];
			package: 'PolySLAM-Core' with: [ spec requires: #('PolySLAM-FixDep') ];
			package: 'PolySLAM-Tests';
			package: 'PolySLAM-Extra';
			"groups"
			group: 'core' with: #('PolySLAM-Core');
			group: 'extra' with: #('PolySLAM-Core' 'PolySLAM-Extra');
			group: 'test' with: #('PolySLAM-Core' 'PolySLAM-Tests');
			group: 'full' with: #('PolySLAM-Core' 'PolySLAM-Extra' 'PolySLAM-Tests')
		]
]
