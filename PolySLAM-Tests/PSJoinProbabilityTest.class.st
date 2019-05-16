Class {
	#name : #PSJoinProbabilityTest,
	#superclass : #VMTests,
	#category : #'PolySLAM-Tests'
}

{ #category : #tests }
PSJoinProbabilityTest >> testPointColinearity [
	|line point helper value|
	line := PSLinkedEdge from: 2@3 to: 8@ 5 type: 3.
	 point := 5@2.
	helper := PSJoinProbability new.
	value := helper colinearityOf: point with: line.
	value inspect
]

{ #category : #tests }
PSJoinProbabilityTest >> testProbability [
	|line|
	
]
