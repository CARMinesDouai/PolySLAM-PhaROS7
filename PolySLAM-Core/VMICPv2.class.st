Class {
	#name : #VMICPv2,
	#superclass : #'VMICP_old',
	#instVars : [
		'startThreshold',
		'endThreshold'
	],
	#category : #'PolySLAM-Core-SLAM - ICP'
}

{ #category : #'as yet unclassified' }
VMICPv2 >> computeOutlierThreshold [
	| t threshold |
	iterationCounter < 3
		ifTrue: [ ^ startThreshold ].
	
	t :=  (iterationCounter - 2) / (maxIterations - 2). "range: (0, 1]"
	threshold := startThreshold + ((endThreshold - startThreshold) * t).
	
	^threshold.
]

{ #category : #'as yet unclassified' }
VMICPv2 >> initialize [
	super initialize.
	startThreshold := 0.3.
	endThreshold := 0.005.

]
