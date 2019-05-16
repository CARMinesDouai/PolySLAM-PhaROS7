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
		do: [
			spec baseline: 'PolyMath' with: [ spec repository: 'github://PolyMathOrg/PolyMath:master/src' ].
			spec
				project: 'PhaROS'
				with: [ spec
						className: #ConfigurationOfPhaROS;
						versionString: #stable;
						repository: 'http://smalltalkhub.com/mc/CAR/PhaROS/main' ].
			spec baseline: 'SystemProcess' with: [ spec repository: 'github://lxsang/SystemProcess' ].
			spec
				"package: 'PolySLAM-FixDep';"
				package: 'PolySLAM-Core' with: [ spec requires: #('PolyMath') ];
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
				group: 'full' with: #('PolySLAM-Core' 'PolySLAM-Extra' 'PolySLAM-Tests' 'PolySLAM-Pipeline');
				group: 'papers' with: #('PolySLAM-Core' 'PolySLAM-Extra' 'PolySLAM-Tests' 'PolySLAM-Pipeline' 'PolySLAM-Papers');
				group: 'pipeline' with: #('PolySLAM-Core' 'PolySLAM-Extra' 'PolySLAM-Tests' 'PolySLAM-Pipeline');
				group: 'pharos' with: #('core' 'PhaROS');
				group: 'pharosfull' with: #('pharos' 'PolySLAM-PhaROS-Examples');
				group: 'pharospapers' with: #('pharosfull' 'PolySLAM-Papers');
				group: 'default' with: #('full') ]
]
