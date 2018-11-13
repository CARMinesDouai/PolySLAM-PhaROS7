Class {
	#name : #PSLocalizedScan,
	#superclass : #Object,
	#instVars : [
		'odomPose',
		'correctPose',
		'tf',
		'device',
		'cloud',
		'score',
		'polygon'
	],
	#category : #'PolySLAM-Pipeline-Core'
}

{ #category : #'instance creation' }
PSLocalizedScan class >> from: rawScan  obstacleDist: dist [
	^self new from: rawScan  obstacleDist: dist
]

{ #category : #accessing }
PSLocalizedScan >> cloud [
	^cloud
]

{ #category : #accessing }
PSLocalizedScan >> correctPose [
	^ correctPose
]

{ #category : #accessing }
PSLocalizedScan >> correctPose: anObject [
	correctPose := anObject
]

{ #category : #accessing }
PSLocalizedScan >> device [
	^ device
]

{ #category : #accessing }
PSLocalizedScan >> device: anObject [
	device := anObject
]

{ #category : #initialization }
PSLocalizedScan >> from: rawScan  obstacleDist: dist [
	|rot|
	rot := VMTFMatrix angle: Float pi translation: 0@0.
	cloud := VMPointCloud2d new fromMsg: rawScan.
	polygon := VMPolygon new fromPointCloud: cloud tf: rot  obstacleDist: dist.
	"polygon := (VMVectorCollectionSimplifier compute: polygon  inlierThreshold: th) result."
	^self

]

{ #category : #accessing }
PSLocalizedScan >> odomPose [
	^ odomPose
]

{ #category : #accessing }
PSLocalizedScan >> odomPose: anObject [
	odomPose := anObject
]

{ #category : #accessing }
PSLocalizedScan >> polygon [
	^ polygon
]

{ #category : #accessing }
PSLocalizedScan >> polygon: anObject [
	polygon := anObject
]

{ #category : #accessing }
PSLocalizedScan >> score [
	^ score
]

{ #category : #accessing }
PSLocalizedScan >> score: anObject [
	score := anObject
]

{ #category : #accessing }
PSLocalizedScan >> tf [
	^ tf
]

{ #category : #accessing }
PSLocalizedScan >> tf: anObject [
	tf := anObject
]
