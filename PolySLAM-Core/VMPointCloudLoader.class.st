"
This class is for convenience, and allows to load multiple VMPointCloud2d files (stored via FUEL) at once.
"
Class {
	#name : #VMPointCloudLoader,
	#superclass : #Object,
	#instVars : [
		'pcCollection'
	],
	#category : #'PolySLAM-Core-temp'
}

{ #category : #'as yet unclassified' }
VMPointCloudLoader class >> load: prefix from: startIndex to: stopIndex [
	^(self new)
		load: prefix from: startIndex to: stopIndex;
		yourself
]

{ #category : #'as yet unclassified' }
VMPointCloudLoader >> load: prefix from: startIndex to: stopIndex [
	| path timeSpent |
	pcCollection := OrderedCollection new.
	
	path := '/opt/shared/developer/data/vector_maps/'.
	
	timeSpent := [ startIndex to: stopIndex do: [ :index |
		| pc |
		pc := (FLMaterializer materializeFromFileNamed: path, prefix, (index printPaddedWith: $0 to: 4) ,'.VMPointCloud2d.fuel' ).
		pcCollection add: pc.
	]] timeToRun seconds.
	
	Transcript
		show: 'spent ';
		show: timeSpent printString;
		show: 's loading ';
		show: (stopIndex - startIndex + 1) printString;
		show: ' files';
		cr.

]

{ #category : #'as yet unclassified' }
VMPointCloudLoader >> load: prefix from: startIndex to: stopIndex fixTransform: fixTransform [
	| path timeSpent |
	pcCollection := OrderedCollection new.
	
	path := '/opt/shared/developer/data/vector_maps/'. "gazebo_office/2018-06-13/'."
	
	timeSpent := [ startIndex to: stopIndex do: [ :index |
		| pc |
		pc := (VMSTONBuilder load: (index printPaddedWith: $0 to: 4) ,'.VMLocalMap.ston' path: path, prefix).
		fixTransform ifTrue: [
			pc := pc transform: pc tf inverse.
		].
		pcCollection add: pc.
	]] timeToRun seconds.
	
	Transcript
		show: 'spent ';
		show: timeSpent printString;
		show: 's loading ';
		show: (stopIndex - startIndex + 1) printString;
		show: ' files';
		cr.

]

{ #category : #accessing }
VMPointCloudLoader >> pcCollection [
	^pcCollection
]
