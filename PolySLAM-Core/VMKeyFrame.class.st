"
This class represents a keyframe, which consists of an estimate of the current location of the robot and a collection of sensor data (e.g. VMScanData2d).



Public API and Key Messages

- addData: <ScanData>
		adds data to the object. currently only VMSensorData2d is supported.
- data
		returns a collection of all added scan data objects.
- location: <VMLocation>
		sets the location estimate of this keyframe. this is the location of the robot, not the location of its sensor(s)
- location
		returns the location estimate, as set by the method above



Instance Variables
	dataCollection:		<OrderedCollection of VMScanData2d>
	location:		<VMLocation>

"
Class {
	#name : #VMKeyFrame,
	#superclass : #Object,
	#instVars : [
		'location',
		'dataCollection',
		'tf'
	],
	#category : #'PolySLAM-Core-SLAM - Data Structures'
}

{ #category : #'rendering support' }
VMKeyFrame class >> rendererClass [
	^VMKeyFrameRenderer.
]

{ #category : #'as yet unclassified' }
VMKeyFrame class >> robot: aRobot [
	"this method is meant for development and testing only, since it only considers the first sensor of the robot."
	^(self new)
		location: ((VMLocation new)
			frame: (aRobot tf frame)
			timestamp: (VMTimestamp new));
		addData: (aRobot sensors first localFrameData);
		yourself.
]

{ #category : #adding }
VMKeyFrame >> addData: scanData [
	dataCollection add: scanData.
]

{ #category : #adding }
VMKeyFrame >> addPointCloud: pc tf: transform [
	dataCollection addAll: pc points.
	tf := transform.
	"dataCollection add: scanData."
]

{ #category : #'as yet unclassified' }
VMKeyFrame >> asRenderableElement [
	^ self class rendererClass new model: self
]

{ #category : #accessing }
VMKeyFrame >> data [
	^dataCollection.
]

{ #category : #initialization }
VMKeyFrame >> initialize [
	dataCollection := OrderedCollection new.
	tf := VMTransform zero.
]

{ #category : #accessing }
VMKeyFrame >> location [
	^location.
]

{ #category : #accessing }
VMKeyFrame >> location: aLocation [
	location := aLocation.
]

{ #category : #accessing }
VMKeyFrame >> tf [
	^tf.
]

{ #category : #accessing }
VMKeyFrame >> tf: aTransform [
	tf := aTransform.
]
