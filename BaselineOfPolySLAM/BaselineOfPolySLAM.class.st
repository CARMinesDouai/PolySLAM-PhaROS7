Class {
	#name : #BaselineOfPolySLAM,
	#superclass : #BaselineOf,
	#category : #BaselineOfPolySLAM
}

{ #category : #baselines }
BaselineOfPolySLAM >> baseline: spec [
	<baseline>
	spec
		for: #common
<<<<<<< HEAD
		do: [
			spec baseline: 'PolyMath' with: [ spec repository: 'github://PolyMathOrg/PolyMath:master/src' ].
			spec
=======
		do: [ spec preLoadDoIt: #preload.
			"spec
				project: 'SciSmalltalk'
				with: [ spec
						className: #ConfigurationOfSciSmalltalk;
						versionString: #stable;
						repository: 'http://smalltalkhub.com/mc/Pharo/MetaRepoForPharo50/main/' ]."
			"spec
>>>>>>> 10f3b68cfd8b5e067958f61668979f6d6b7ccb90
				project: 'PhaROS'
				with: [ spec
						className: #ConfigurationOfPhaROS;
						versionString: #stable;
<<<<<<< HEAD
						repository: 'http://smalltalkhub.com/mc/CAR/PhaROS/main' ].
			spec baseline: 'SystemProcess' with: [ spec repository: 'github://lxsang/SystemProcess' ].
			spec
				"package: 'PolySLAM-FixDep';"
				package: 'PolySLAM-Core' with: [ spec requires: #('PolyMath') ];
=======
						repository: 'http://smalltalkhub.com/mc/CAR/PhaROS/main' ]."
			spec
				baseline: 'SystemProcess'
				with: [ spec repository: 'github://lxsang/SystemProcess' ].
			spec
				package: 'PolySLAM-FixDep';
				package: 'PolySLAM-Core' with: [ spec requires: #('PolySLAM-FixDep' "'SciSmalltalk'") ];
>>>>>>> 10f3b68cfd8b5e067958f61668979f6d6b7ccb90
				package: 'PolySLAM-Tests';
				package: 'PolySLAM-Extra' with: [ spec requires: #('SystemProcess') ];
				package: 'PolySLAM-Papers';
				package: 'PolySLAM-Pipeline';
				package: 'PolySLAM-Viz';
				package: 'PolySLAM-PhaROS-Examples';
				"groups"
					group: 'core' with: #('PolySLAM-Core');
				group: 'extra' with: #('PolySLAM-Core' 'PolySLAM-Extra');
				group: 'test' with: #('PolySLAM-Core' 'PolySLAM-Tests');
<<<<<<< HEAD
				group: 'full' with: #('PolySLAM-Core' 'PolySLAM-Extra' 'PolySLAM-Tests' 'PolySLAM-Pipeline');
				group: 'papers' with: #('PolySLAM-Core' 'PolySLAM-Extra' 'PolySLAM-Tests' 'PolySLAM-Pipeline' 'PolySLAM-Papers');
				group: 'pipeline' with: #('PolySLAM-Core' 'PolySLAM-Extra' 'PolySLAM-Tests' 'PolySLAM-Pipeline');
				group: 'pharos' with: #('core' 'PhaROS');
				group: 'pharosfull' with: #('pharos' 'PolySLAM-PhaROS-Examples');
				group: 'pharospapers' with: #('pharosfull' 'PolySLAM-Papers');
=======
				group: 'full' with: #('PolySLAM-Core' 'PolySLAM-Extra' 'PolySLAM-Tests');
				"group: 'pharos' with: #('core' 'PhaROS');
				group: 'pharosfull' with: #('pharos' 'PolySLAM-PhaROS-Examples');"
>>>>>>> 10f3b68cfd8b5e067958f61668979f6d6b7ccb90
				group: 'default' with: #('full') ]
]
