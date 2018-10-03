"
This class represents a part of the VectorMaps_PhaROS package. It is responsible for visualization of the global map. Since the Athens package in Pharo 5 is not as stable as we would like and sometimes causes the image to freeze, we recommend to run this as a seperate image. That way it shouldn't intervere with other concurrently running pharo images.


Instance Variables
	mapRenderer: <VMLocalMapRenderer>
		this object handels all rendering-related tasks for the global map
	renderCollection: <VMCollectionRenderer>
		this collection contains all elements that should be rendered. by default, it only contains 'mapRenderer'
	viewer: <VMMapViewer>
		the viewer renders all objects in 'renderCollection'

"
Class {
	#name : #VMMapViewerNode,
	#superclass : #VMBaseNode,
	#instVars : [
		'viewer',
		'renderCollection',
		'mapRenderer'
	],
	#category : #'PolySLAM-PhaROS-Examples-Nodes'
}

{ #category : #initialization }
VMMapViewerNode >> createViewer [

	viewer := (VMMapViewer
		openOn: { renderCollection }
		extent: 800@800)
			zoomFactor: 50 at: 0@0;
			panTo: 300@350.
			
		
	

]

{ #category : #initialization }
VMMapViewerNode >> initialize [
	super initialize.
	
	"using a VMCollectionRenderer allows us to add/remove new objects easily at any time"
	renderCollection := VMCollectionRenderer new.
	
	mapRenderer := VMLocalMapRenderer new.
	renderCollection collection add: mapRenderer.
	
	self createViewer.
			
		
	

]

{ #category : #'topic handler' }
VMMapViewerNode >> mapMsgHandler: msg [
	| map |
	
	map := VMLocalMap new fromVMMapMsg: msg.
	
	mapRenderer model: map.

]

{ #category : #accessing }
VMMapViewerNode >> renderCollection [
	^renderCollection.
]

{ #category : #initialization }
VMMapViewerNode >> subscribeToTopics [
	self assert: node isNotNil.
	
	(node buildConnectionFor: '/robot0/scanMap')
	"(node buildConnectionFor: '/robot0/map')"
		typedAs: 'vector_maps/vm_map';
		for: [ :msg |
			self mapMsgHandler: msg.
			"self processLaserScan: msg."
		];
		connect.

]

{ #category : #accessing }
VMMapViewerNode >> viewer [
	^viewer.
]
