Class {
	#name : #'VM_SLAM_package',
	#superclass : #PhaROSPackage,
	#instVars : [
		'nodes',
		'viewer',
		'renderCollection'
	],
	#category : #'PolySLAM-PhaROS-Examples-Package'
}

{ #category : #'as yet unclassified' }
VM_SLAM_package class >> msgTypeFoobar [
	^PhaROSROSType message
		named: #VMFoobar
		"package: #VectorMaps_PhaROS"
		defined: {
			PhaROSROSType definedBy: 'std_msgs/Header' named: #header.
			PhaROSStringType named: #text.
			PhaROSUInt8Type named: #bla .
		}
]

{ #category : #'as yet unclassified' }
VM_SLAM_package class >> types [
	^{ 
		"self msgTypeFoobar."
	}.
	

]

{ #category : #initialization }
VM_SLAM_package >> initialize [
	super initialize.
	
	self logCr: self class name, ' - initialize'.
	
	nodes := OrderedCollection new.
	

]

{ #category : #accessing }
VM_SLAM_package >> nodes [
	^nodes.
]

{ #category : #printing }
VM_SLAM_package >> printString [
	| string seperator |
	
	string := super printString, ' (nodes='.
	seperator := ''.
	
	nodes ifEmpty: [ string := string, 'empty collection'. ].
	
	nodes do: [ :obj |
		string := string, seperator, obj printString.
		seperator := ', '.
	].
	
	string := string, ')'.
	
	^string.

]

{ #category : #scripts }
VM_SLAM_package >> scriptKeyframeNode [
	| node |
	
	node := VMKeyframeNode node: self controller node.
	
	nodes add: node.
	
	node subscribeToTopics.
	
	^node.
	

]

{ #category : #scripts }
VM_SLAM_package >> scriptLaserScanViewerNode [
	| node |
	
	node := VMLaserScanViewerNode node: self controller node.
	node subscribeToTopics.
	nodes add: node.
	
	^node.
	

]

{ #category : #scripts }
VM_SLAM_package >> scriptMapMergerNode [
	"todo:
		- subscribe to keyframe data (local map, created from scan-matched laser scan)
		- merge local map with the robots global map
		- publish updated global map (for use at the localization node)
	"
	| node |
	
	node := VMMapMergerNode node: self controller node.
	nodes add: node.
	
	node subscribeToTopics.
	^node

]

{ #category : #scripts }
VM_SLAM_package >> scriptMapViewer [
	| node |
	
	node := VMMapViewerNode node: self controller node.
	nodes add: node.
	
	node subscribeToTopics.
	
	^node.
	
]

{ #category : #scripts }
VM_SLAM_package >> scriptSimpleMapping [
	
]

{ #category : #scripts }
VM_SLAM_package >> scriptTopicPublishingExample [
"	
	How to use:
	  1) in PhaROS, execute: 	self new scriptTopicPublishingExample.
	  2) in a terminal, execute:   rostopic echo /example 
"
	| publisher |

	"For publishing into a topic,you just need a publisher object. 
	You can obtain it asking to the related node like in the following code".
	
	publisher := self controller node 
						topicPublisher: 'example'
						typedAs: #VMFoobar.

	"When data is actually sent you''l see a sequence of ping and pong. Otherwise you'' see pong alone"						
	
		publisher send:[ : o | 
			o inspect
		].
		
	

]

{ #category : #scripts }
VM_SLAM_package >> scriptTopicSubscribingExample [
"
	This example shows how to subscribe to a ROS topic.
	
	How to use:
	  1) in PhaROS, execute: 	self new scriptTopicSubscribingExample
	  2) in a terminal, execute:   rostopic pub -r 10 /example std_msgs/String ''hello there''
	
	
	You just need a subscriber object (created using buildConnectionFor: aTopicID) and configure it with a callback (block).
	Then, when you send it the #connect message it will make the proper connections. 

	cf. PhaROSExamplePackage for more scripts example
"
	
	(self controller node buildConnectionFor: 'example' ) 
		typedAs: 'std_msgs/String'; 
		for: [ :string |  "this is a callback" 
			self log: string data
		];
		connect .
														

]
