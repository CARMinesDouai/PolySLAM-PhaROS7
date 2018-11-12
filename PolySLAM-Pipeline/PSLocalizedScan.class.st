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
PSLocalizedScan class >> from: rawScan [
	^self new from: rawScan 
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

{ #category : #converting }
PSLocalizedScan >> createPolygonWith: dist simplifierTh: th tf: aVMTf [
	polygon := VMPolygon new fromPointCloud: cloud tf: aVMTf  obstacleDist: dist.
	polygon := (VMVectorCollectionSimplifier compute: polygon  inlierThreshold: th) result.
	^polygon 
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
PSLocalizedScan >> from: rawScan [ 
	cloud := VMPointCloud2d new fromMsg: rawScan.
	"polygon := VMPolygon new fromPointCloud: pc tf: nil  obstacleDist: dist.
	polygon := (VMVectorCollectionSimplifier compute: polygon  inlierThreshold: th) result."
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
