Class {
	#name : #VMVectorICP,
	#superclass : #VMICP,
	#instVars : [
		'outlierStartThreshold',
		'outlierThresholdFalloff'
	],
	#category : #'PolySLAM-Core-SLAM - ICP'
}

{ #category : #'pair matching & outlier detection' }
VMVectorICP >> computeOutlierThreshold [
	^self computeOutlierThreshold: collectionHistory size

]

{ #category : #'as yet unclassified' }
VMVectorICP >> computeOutlierThreshold: iterationCount [
	| rejectionDistance |
	
	rejectionDistance := outlierStartThreshold * (outlierThresholdFalloff + 1 / (outlierThresholdFalloff + iterationCount)).
	
	^ rejectionDistance

]

{ #category : #'as yet unclassified' }
VMVectorICP >> initialize [
	super initialize.
	
	outlierStartThreshold := 1.2.
	outlierThresholdFalloff := 0.5.
	

]

{ #category : #'as yet unclassified' }
VMVectorICP >> outlierStartThreshold [
	^ outlierStartThreshold
]

{ #category : #'as yet unclassified' }
VMVectorICP >> outlierStartThreshold: aNumber [
	outlierStartThreshold := aNumber.
]

{ #category : #'as yet unclassified' }
VMVectorICP >> outlierThresholdFalloff [
	^ outlierThresholdFalloff
]

{ #category : #'as yet unclassified' }
VMVectorICP >> outlierThresholdFalloff: aNumber [
	outlierThresholdFalloff := aNumber.
]
