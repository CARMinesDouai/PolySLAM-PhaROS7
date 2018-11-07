Class {
	#name : #PSLocalizedScanPolygon,
	#superclass : #Object,
	#instVars : [
		'odomPose',
		'correctPose',
		'tf',
		'device',
		'polygon'
	],
	#category : #'PolySLAM-Pipeline-Core'
}

{ #category : #'instance creation' }
PSLocalizedScanPolygon class >> from: rawScan obstacleDist: dist simplifierTh:th [
	^self new from: rawScan obstacleDist: dist simplifierTh:th; yourself
]

{ #category : #accessing }
PSLocalizedScanPolygon >> correctPose [
	^ correctPose
]

{ #category : #accessing }
PSLocalizedScanPolygon >> correctPose: anObject [
	correctPose := anObject
]

{ #category : #accessing }
PSLocalizedScanPolygon >> device [
	^ device
]

{ #category : #accessing }
PSLocalizedScanPolygon >> device: anObject [
	device := anObject
]

{ #category : #initialization }
PSLocalizedScanPolygon >> from: rawScan obstacleDist: dist simplifierTh:th [
	|pc|
	pc := VMPointCloud2d new fromMsg: rawScan.
	polygon := VMPolygon new fromPointCloud: pc tf: nil  obstacleDist: dist.
	polygon := (VMVectorCollectionSimplifier compute: polygon  inlierThreshold: th) result.
	^self

]

{ #category : #accessing }
PSLocalizedScanPolygon >> odomPose [
	^ odomPose
]

{ #category : #accessing }
PSLocalizedScanPolygon >> odomPose: anObject [
	odomPose := anObject
]

{ #category : #accessing }
PSLocalizedScanPolygon >> tf [
	^ tf
]

{ #category : #accessing }
PSLocalizedScanPolygon >> tf: anObject [
	tf := anObject
]
