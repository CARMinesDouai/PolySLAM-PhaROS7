Class {
	#name : #VMMapMergerNode,
	#superclass : #VMBaseNode,
	#instVars : [
		'globalMap',
		'publisher',
		'merger'
	],
	#category : #'PolySLAM-PhaROS-Examples-Nodes'
}

{ #category : #initialization }
VMMapMergerNode >> initialize [
	merger := VMMapMerger new.
]

{ #category : #'topic handler' }
VMMapMergerNode >> mapMsgHandler: aVMMapMsg [
	| map |
	
	globalMap ifNil: [
		globalMap := VMLocalMap new fromVMMapMsg: aVMMapMsg.
		self publish: globalMap.
		^self.
	].
	
	map := VMLocalMap new fromVMMapMsg: aVMMapMsg.
	merger mergeMap: map withMap: globalMap.
	
	globalMap := merger globalMap.
	self publish: globalMap.

]

{ #category : #'topic handler' }
VMMapMergerNode >> publish: aMap [

	self logCr: 'publishing map'.
	
	publisher send: [ :obj |
		self convertMap: aMap toMsg: obj.
	].

]

{ #category : #initialization }
VMMapMergerNode >> setupPublisher [

	publisher := node 
						topicPublisher: '/robot0/map' 
						typedAs: 'vector_maps/vm_map'.
	
	"note: vm_vertex is part of vm_map. both are required to publish."
	self assert: (Smalltalk hasClassNamed: 'Vector_mapsvm_vertex').
	self assert: (Smalltalk hasClassNamed: 'Vector_mapsvm_map').
	
]

{ #category : #initialization }
VMMapMergerNode >> subscribeToTopics [
	"	- subscribe to local vector map (the one that is created by the scan data from a single keyframe)
		- subscribe to sensor topic(s)
		
		todo:
		- support custom topic names
		- support multiple sensors
	"
	
	self assert: node isNotNil.
	
	(node buildConnectionFor: '/robot0/scanMap')
		typedAs: 'vector_maps/vm_map';
		for: [ :msg |
			self mapMsgHandler: msg.
			"self processLaserScan: msg."
		];
		connect.
	
	
	self setupPublisher.

]
