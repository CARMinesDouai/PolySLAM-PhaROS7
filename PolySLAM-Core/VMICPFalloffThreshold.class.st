Class {
	#name : #VMICPFalloffThreshold,
	#superclass : #VMICPBaseThreshold,
	#instVars : [
		'outlierStartThreshold',
		'outlierThresholdFalloff'
	],
	#category : #'PolySLAM-Core-SLAM - ICP'
}

{ #category : #'pair matching & outlier detection' }
VMICPFalloffThreshold >> computeOutlierThreshold [
	^ self computeOutlierThreshold: icp iterationCount

]

{ #category : #'as yet unclassified' }
VMICPFalloffThreshold >> computeOutlierThreshold: iterationCount [
	| rejectionDistance |
	
	rejectionDistance := outlierStartThreshold * (outlierThresholdFalloff + 1 / (outlierThresholdFalloff + iterationCount)).
	
	^ rejectionDistance

]

{ #category : #initialization }
VMICPFalloffThreshold >> initialize [
	super initialize.
	
	outlierStartThreshold := 0.02 squared.
	outlierThresholdFalloff := 1.0.
]
