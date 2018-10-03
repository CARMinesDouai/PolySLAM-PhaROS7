"
This is a small helper function for easier testing in playgrounds.

The class loads VMLocalMap instances from STON files. The local maps are stored in the ordered collection 'maps'. Additionally the ordered collection 'polygons' contains the local maps converted to VMPolygon instances, with the odometry correction applied to them.
"
Class {
	#name : #VMMapLoader,
	#superclass : #Object,
	#instVars : [
		'maps',
		'polygons',
		'odom',
		'odomDelta',
		'odomDelta2'
	],
	#category : #'PolySLAM-Core-temp'
}

{ #category : #'as yet unclassified' }
VMMapLoader class >> load: prefix from: startIndex to: stopIndex [
	^(self new)
		load: prefix from: startIndex to: stopIndex;
		yourself
]

{ #category : #'as yet unclassified' }
VMMapLoader class >> load: prefix from: startIndex to: stopIndex fixTransform: fixTransform [
	^(self new)
		load: prefix from: startIndex to: stopIndex fixTransform: fixTransform;
		yourself
]

{ #category : #loading }
VMMapLoader >> load: prefix from: startIndex to: stopIndex [
	| path timeSpent |
	maps := OrderedCollection new.
	polygons := OrderedCollection new.
	
	path := '/opt/shared/developer/data/vector_maps/'. "gazebo_office/2018-06-13/'."
	
	timeSpent := [ startIndex to: stopIndex do: [ :index |
		| map |
		map := (VMSTONBuilder load: (index printPaddedWith: $0 to: 4) ,'.VMLocalMap.ston' path: path, prefix).
		maps add: map.
		polygons add: ((VMPolygon fromVectors: map lineSegments) "applyTransform: map tf inverse" "applyTransform: map tf").
	]] timeToRun seconds.
	
	Transcript
		show: 'spent ';
		show: timeSpent printString;
		show: 's loading ';
		show: (stopIndex - startIndex + 1) printString;
		show: ' files';
		cr.

]

{ #category : #loading }
VMMapLoader >> load: prefix from: startIndex to: stopIndex fixTransform: fixTransform [
	| path timeSpent lastOdom |
	maps := OrderedCollection new.
	polygons := OrderedCollection new.
	odom := OrderedCollection new.
	odomDelta := OrderedCollection new.
	odomDelta2 := OrderedCollection new.
	lastOdom := VMTFMatrix identity.
	
	path := '/opt/shared/developer/data/vector_maps/'. "gazebo_office/2018-06-13/'."
	
	timeSpent := [ startIndex to: stopIndex do: [ :index |
		| map |
		map := (VMSTONBuilder load: (index printPaddedWith: $0 to: 4) ,'.VMLocalMap.ston' path: path, prefix).
		odom add: map tf asVMTFMatrix.
		odomDelta add: (map tf * lastOdom inverse).
		odomDelta2 add: (lastOdom inverse * map tf).
		lastOdom := map tf asVMTFMatrix.
		fixTransform ifTrue: [
			map := map transform: map tf inverse.
		].
		maps add: map.
		polygons add: ((VMPolygon fromVectors: map lineSegments) "applyTransform: map tf inverse" "applyTransform: map tf").
	]. ] timeToRun seconds.
	
	Transcript
		show: 'spent ';
		show: timeSpent printString;
		show: 's loading ';
		show: (stopIndex - startIndex + 1) printString;
		show: ' files';
		cr.

]

{ #category : #accessing }
VMMapLoader >> maps [
	^maps
]

{ #category : #accessing }
VMMapLoader >> odom [
	^odom
]

{ #category : #accessing }
VMMapLoader >> odomDelta [
	^odomDelta
]

{ #category : #accessing }
VMMapLoader >> odomDelta2 [
	^odomDelta2
]

{ #category : #accessing }
VMMapLoader >> polygons [
	^ polygons
]
