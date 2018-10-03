"
This is an intermediate data storage class, lieing between a laser scan message and a local map. we use this class for storage when performing ICP.
"
Class {
	#name : #VMPointCloud2d,
	#superclass : #Object,
	#instVars : [
		'points',
		'sensorCenter'
	],
	#category : #'PolySLAM-Core-SLAM - Data Structures'
}

{ #category : #'as yet unclassified' }
VMPointCloud2d class >> fromVMLocalMap: aMap [
	^(self new)
		fromVMLocalMap: aMap;
		yourself.
]

{ #category : #'as yet unclassified' }
VMPointCloud2d >> applyTransform: aVMTFMatrix [
	| tf |
	
	tf := aVMTFMatrix asVMTFMatrix.
	
	points := points collect: [ :aPoint |
		aPoint applyTransform: tf
	].
	
	

]

{ #category : #converting }
VMPointCloud2d >> asRenderableElement [
	^ VMPointCloud2dRenderer model: self
]

{ #category : #accessing }
VMPointCloud2d >> bounds [
	| rect |
	rect := points first bounds.
	points allButFirstDo: [ :aPoint |
		rect := rect merge: aPoint bounds.
	].
	
	sensorCenter ifNotNil: [ rect := rect merge: sensorCenter bounds ].
	
	^ rect
]

{ #category : #converting }
VMPointCloud2d >> fromMsg: aMsg [
	"note: this method ignores the transformation and creates the pointcloud in the local frame of the sensor.
	note (2): a sensor-center point is NOT added to the point cloud at the moment. this may change in the future."
	| angle angleInc ranges dataCount minDist |
	
	angle := aMsg angle_min.
	angleInc := aMsg angle_increment.
	ranges := aMsg ranges.
	dataCount := aMsg ranges size.
	minDist := 0.1.
	
	angleInc := aMsg angle_min - aMsg angle_max / (dataCount - 1).
	self logCr: self class name, ':: ', 'inc (msg)=', aMsg angle_increment printString, ', inc (calc)=', angleInc printString.
	"Transcript show: 'angle_min='; show: aMsg angle_min printString; show: ', angle_max='; show: aMsg angle_max printString; cr."
	
	1 to: dataCount do: [ :i |
		| dist point |
		dist := ranges at: i.
		
		dist isNaN ifTrue: [ dist := minDist ].
		((dist < minDist) or: [dist = Float infinity]) ifTrue: [ dist := minDist ].
		
		"note: isFinite also checks if the number is NaN, isInfinite does not"
		dist isFinite ifTrue: [
			dist > minDist ifTrue: [
				point := VMPoint x: (((angle) cos negated) * dist) y: (((angle) sin) * dist) type: VMPointTypeObstacle new.
				points add: point negated.
			] ifFalse: [
				point := VMPoint x: (((angle) cos negated) * minDist) y: (((angle) sin) * minDist) type: VMPointTypeFrontier new.
				points add: point negated.
			].
		].
		
		angle := angle + angleInc.
	].

]

{ #category : #converting }
VMPointCloud2d >> fromVMLocalMap: aMap [
	aMap lineSegments allButLastDo: [ :lineSeg |
		points add: lineSeg pointA.
	].
	
	sensorCenter := aMap lineSegments last pointA.
]

{ #category : #'GT Inspector' }
VMPointCloud2d >> gtInspectorRenderedIn: composite [
	<gtInspectorPresentationOrder: 50>
	
	(composite morph)
		title: 'Viewer';
		morph: [
			(VMViewer openWindowlessOn: { self asRenderableElement })
				autozoom.
		].
]

{ #category : #initialization }
VMPointCloud2d >> initialize [
	points := OrderedCollection new.
	sensorCenter := 0@0.
]

{ #category : #accessing }
VMPointCloud2d >> points [
	^points.
]

{ #category : #accessing }
VMPointCloud2d >> points: aCollection [
	points := aCollection.
]

{ #category : #printing }
VMPointCloud2d >> printString [
	| string |
	
	string := super printString,
		' (points size=',
		(points
			ifNil: [ 'nil' ]
			ifNotNil: [ points size printString ]),
		')'.
	
	^string.

]

{ #category : #accessing }
VMPointCloud2d >> sensorCenter [
	^sensorCenter.
]

{ #category : #accessing }
VMPointCloud2d >> sensorCenter: aPoint [
	sensorCenter := aPoint.
]
