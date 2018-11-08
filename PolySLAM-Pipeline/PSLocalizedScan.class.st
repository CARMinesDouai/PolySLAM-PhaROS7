Class {
	#name : #PSLocalizedScan,
	#superclass : #Object,
	#instVars : [
		'odomPose',
		'correctPose',
		'tf',
		'device',
		'cloud',
		'score'
	],
	#category : #'PolySLAM-Pipeline-Core'
}

{ #category : #'instance creation' }
PSLocalizedScan class >> from: rawScan [
	^self new from: rawScan 
]

{ #category : #initialization }
PSLocalizedScan >> asPolygon [
	"polygon := VMPolygon new fromPointCloud: pc tf: nil  obstacleDist: dist.
	polygon := (VMVectorCollectionSimplifier compute: polygon  inlierThreshold: th) result."
]

{ #category : #initialization }
PSLocalizedScan >> asPolygonWith: dist simplifierTh: th [
	|polygon|
	polygon := VMPolygon new fromPointCloud: cloud tf: nil  obstacleDist: dist.
	polygon := (VMVectorCollectionSimplifier compute: polygon  inlierThreshold: th) result.
	^polygon 
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
