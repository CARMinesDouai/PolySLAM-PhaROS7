"
This node is  meant for visualization and debugging. It shows the laser scan from the sensor's local frame in a viewer.
"
Class {
	#name : #VMLaserScanViewerNode,
	#superclass : #VMBaseNode,
	#instVars : [
		'viewer',
		'rScan'
	],
	#category : #'PolySLAM-PhaROS-Examples-Nodes'
}

{ #category : #initialization }
VMLaserScanViewerNode >> initialize [
	super initialize.
	
	self reset.
	

	

]

{ #category : #'topic handler' }
VMLaserScanViewerNode >> processLaserScan: msg [

	rScan fromMsg: msg.
	
]

{ #category : #initialization }
VMLaserScanViewerNode >> reset [

	rScan := VMROSLaserScanRenderer new.
	
	viewer := (VMMapViewer openOn: { rScan } extent: 600@600)
		zoomFactor: 30 at: 0@0;
		panTo: 300@300.
	

]

{ #category : #initialization }
VMLaserScanViewerNode >> subscribeToTopics [
	self logCr: self class name, ': subscribing to topics'.
	
	self assert: node isNotNil.
	
	(node buildConnectionFor: '/robot0/laser_0')
		typedAs: 'sensor_msgs/LaserScan';
		for: [ :msg |
			self processLaserScan: msg.
		];
		connect.
	

]
