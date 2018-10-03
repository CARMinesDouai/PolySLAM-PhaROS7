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
			"iceberg"
			
			package: 'PolySLAM-FixDep';
			package: 'PolySLAM-Core' with: [ spec requires: #('PolySLAM-FixDep' 'SciSmalltalk') ];
			package: 'PolySLAM-Tests' with: [ spec requires: #('PolySLAM-Core') ];
			package: 'PolySLAM-Extra' with: [ spec requires: #('PolySLAM-Core') ];
			"groups"
			group: 'core' with: #('PolySLAM-Core')
			"group: 'minimal' with: #(
				'Iceberg'
				'Iceberg-Libgit' 
				'Iceberg-Libgit-Tonel'
				'Iceberg-Libgit-Filetree');
			group: 'allTests' with: #(
				'Iceberg-Tests' 
				'Iceberg-Tests-MetacelloIntegration'
				'LibGit-Tests' 
				'Iceberg-UI-Tests'
				'Iceberg-Plugin-Migration-Tests' );
			group: 'development' with: #(default allTests)" ].
]
