Class {
	#name : #VMAlignmentScore,
	#superclass : #Object,
	#category : #'PolySLAM-Core-SLAM - ICP'
}

{ #category : #'utility methods' }
VMAlignmentScore class >> computeScoreIcp: icp [
	| matches |
	matches := icp matchHistory last deepCopy.
	
	^{ 0.05.  0.1.  0.2.  0.4 } collect: [ :threshold |
		(icp markOutliersMatches: matches threshold: threshold squared) squaredError
	] as: OrderedCollection.

]
