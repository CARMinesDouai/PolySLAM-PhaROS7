Class {
	#name : #BaselineOfPolySLAM,
	#superclass : #BaselineOf,
	#category : #BaselineOfPolySLAM
}

{ #category : #baselines }
BaselineOfPolySLAM >> baseline: spec [
	<baseline>
	
	spec for: #common do: [ 
		spec preLoadDoIt: #preload.
		spec project: 'SciSmalltalk' with: [
				spec
					className: #ConfigurationOfSciSmalltalk;
					versionString: #'stable';
					repository: 'http://smalltalkhub.com/mc/Pharo/MetaRepoForPharo50/main/' ].
		
		spec project: 'PhaROS' with: [ 
			 spec
				className: #ConfigurationOfPhaROS;
				versionString: #'stable';
				repository: 'http://smalltalkhub.com/mc/CAR/PhaROS/main'
		].
		spec
			baseline: 'SystemProcess' 
			with: [ spec repository: 'github://lxsang/SystemProcess' ].
		
		spec
			package: 'PolySLAM-FixDep';
			package: 'PolySLAM-Core' with: [ spec requires: #('PolySLAM-FixDep' 'SciSmalltalk') ];
			package: 'PolySLAM-Tests';
			package: 'PolySLAM-Extra' with: [spec requires: #( 'SystemProcess' )];
			package: 'PolySLAM-PhaROS-Examples';
			"groups"
			group: 'core'  with: #('PolySLAM-Core');
			group: 'extra' with: #('PolySLAM-Core' 'PolySLAM-Extra');
			group: 'test'  with: #('PolySLAM-Core' 'PolySLAM-Tests');
			group: 'full'  with: #('PolySLAM-Core' 'PolySLAM-Extra' 'PolySLAM-Tests');
			group: 'pharos' with: #('core' 'PhaROS');
			group: 'pharosfull' with: #('pharos' 'PolySLAM-PhaROS-Examples');
			group: 'default' with: #('full')
		]
]

{ #category : #preload }
BaselineOfPolySLAM >> preload [

	(Object lookupSelector: #ifNotNilDo:) ifNotNil: [ ^self ].
	Object compile: 'ifNotNilDo: ablock
	^ self ifNotNil: ablock'.
]
