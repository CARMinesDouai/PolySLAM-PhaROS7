Class {
	#name : #VMICPBaseThreshold,
	#superclass : #Object,
	#instVars : [
		'icp'
	],
	#category : #'PolySLAM-Core-SLAM - ICP'
}

{ #category : #'as yet unclassified' }
VMICPBaseThreshold >> computeOutlierThreshold: iterationCount [
	^ self subclassResponsibility
]

{ #category : #accessing }
VMICPBaseThreshold >> icp [
	^ icp
]

{ #category : #accessing }
VMICPBaseThreshold >> icp: aVMICP [
	icp := aVMICP.
]
