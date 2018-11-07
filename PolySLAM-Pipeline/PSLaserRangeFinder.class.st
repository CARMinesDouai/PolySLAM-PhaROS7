Class {
	#name : #PSLaserRangeFinder,
	#superclass : #Object,
	#instVars : [
		'devName',
		'offset',
		'maxRange',
		'minRange',
		'minAngle',
		'maxAngle',
		'angularResolution'
	],
	#category : #'PolySLAM-Pipeline-Core'
}

{ #category : #'instance creation' }
PSLaserRangeFinder class >> from: rawScan [
	^self new from: rawScan; yourself
]

{ #category : #accessing }
PSLaserRangeFinder >> angularResolution [
	^ angularResolution
]

{ #category : #accessing }
PSLaserRangeFinder >> angularResolution: anObject [
	angularResolution := anObject
]

{ #category : #accessing }
PSLaserRangeFinder >> devName [
	^ devName
]

{ #category : #accessing }
PSLaserRangeFinder >> devName: anObject [
	devName := anObject
]

{ #category : #accessing }
PSLaserRangeFinder >> from: aRawScan [
	self minRange: aRawScan range_min.
	self maxRange: aRawScan range_max.
	self minAngle: aRawScan angle_min.
	self maxAngle: aRawScan angle_max.
	self angularResolution: aRawScan angle_increment.
	self devName: aRawScan header frame_id.
	"TODO add the offset from the TF"
	^self
]

{ #category : #accessing }
PSLaserRangeFinder >> maxAngle [
	^ maxAngle
]

{ #category : #accessing }
PSLaserRangeFinder >> maxAngle: anObject [
	maxAngle := anObject
]

{ #category : #accessing }
PSLaserRangeFinder >> maxRange [
	^ maxRange
]

{ #category : #accessing }
PSLaserRangeFinder >> maxRange: anObject [
	maxRange := anObject
]

{ #category : #accessing }
PSLaserRangeFinder >> minAngle [
	^ minAngle
]

{ #category : #accessing }
PSLaserRangeFinder >> minAngle: anObject [
	minAngle := anObject
]

{ #category : #accessing }
PSLaserRangeFinder >> minRange [
	^ minRange
]

{ #category : #accessing }
PSLaserRangeFinder >> minRange: anObject [
	minRange := anObject
]

{ #category : #accessing }
PSLaserRangeFinder >> offset [
	^ offset
]

{ #category : #accessing }
PSLaserRangeFinder >> offset: anObject [
	offset := anObject
]
