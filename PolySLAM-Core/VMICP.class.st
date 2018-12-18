Class {
	#name : #VMICP,
	#superclass : #VMICPBaseAlgotithm,
	#category : #'PolySLAM-Core-SLAM - ICP'
}

{ #category : #transformation }
VMICP >> computeCentroidForCollection: collection [
	"computes the center of mass (average position over all points)"
	| point count |
	
	point := 0@0.
	count := 0.
	
	collection do: [ :obj |
		point := point + obj.
		count := count + 1.
	].
	
	(count = 0) ifTrue: [ ^point ].
	
	^ ((point x) / count) @ ((point y) / count).

]

{ #category : #transformation }
VMICP >> computeCentroids [
	| centA centB |
	
	centA := self computeCentroidForCollection: (matchHistory last select: [ :pair | pair outlier not ] thenCollect: [ :pair | pair first ] ).
	centB := self computeCentroidForCollection: (matchHistory last select: [ :pair | pair outlier not ] thenCollect: [ :pair | pair last ] ).
	
	^{ centA. centB }

]

{ #category : #transformation }
VMICP >> computeMatH: centroids [
	"computes matrix H, which is required for SVD in #computeTransformation"
	| a b c d matH |
	
	a := 0.0.
	b := 0.0.
	c := 0.0.
	d := 0.0.
	
	matchHistory last do: [ :obj |
		| vA vB |
		obj outlier ifFalse: [
			vA := obj first - centroids first.
			vB := obj last - centroids second.
			
			a := a + ( vA x * (vB x) ).
			b := b + ( vA x * (vB y) ).
			c := c + ( vA y * (vB x) ).
			d := d + ( vA y * (vB y) ).
		].
	].
	
	matH := PMMatrix rows: { { a. b. }. { c. d. } }.
	^ matH

]

{ #category : #'pair matching & outlier detection' }
VMICP >> computeOutlierThreshold [
	| indexedDistCollection medianDist rejectionDistance iterationCount |
	
	iterationCount := collectionHistory size.
	
	"create a collection that contains the index of the VMMatchPair in 'matchHistory last' and the squareDistance value"
	indexedDistCollection := matchHistory last collectWithIndex: [ :pair :index | {index. pair squaredDistance} ].
	
	"sort the newly created collection by square distance"
	indexedDistCollection := indexedDistCollection sorted: [ :pairA :pairB | (pairA second) < (pairB second) ].
	
	"select the middle element in the list, providing us with the median square distance and the index in the orignal collection"
	medianDist := indexedDistCollection middle second.
	
	"compute the rejection distance based on the median (square) distance"
	rejectionDistance := medianDist * 400.
	
	rejectionDistance := 0.85 * (5 / (4 + iterationCount)).
	
	^ rejectionDistance

]

{ #category : #transformation }
VMICP >> computeTransformation [
	"computes the transformation step for ICP based on inliers in 'matchCollection last'.
	the resulting transform is add to tfHistory."
	| matH svd matR vecT centroids vecA vecB deltaTF |
	
	centroids := self computeCentroids.
	matH := self computeMatH: centroids.
	
	svd := VMSVD2d matrix: (matH).
	matR := (svd v) * ((svd u) transpose).
	
	((matR at: 1 at: 1) sign ~= (matR at: 2 at: 2) sign) ifTrue: [
		Transcript show: 'negated'; cr.
		matR at: 2 at: 1 put: ((matR at: 2 at: 1) negated).
		matR at: 2 at: 2 put: ((matR at: 2 at: 2) negated).
	].
	
	vecA := centroids first asDhbVector.
	vecB := centroids second asDhbVector.
	"vecA := DhbVector new: 2.
	vecB := DhbVector new: 2.
	
	vecA at: 1 put: (centroids first x).
	vecA at: 2 put: (centroids first y).
	vecB at: 1 put: (centroids last x).
	vecB at: 2 put: (centroids last y).
	"
	vecT := -1 * (matR * vecA) + vecB.
	deltaTF := VMTFMatrix r: matR t: vecT.
	
	tfHistory add: deltaTF * tfHistory last.
	
	^ deltaTF.

]

{ #category : #'pair matching & outlier detection' }
VMICP >> createMatchPairs [
	| matchCollection |
	matchCollection := VMMatchCollection new.
	
	matchCollection := collectionHistory last
		collect: [ :point | VMMatchPair pointA: point pointB: (self findCorrespondingPoint: point) ]
		as: VMMatchCollection.
	
	matchHistory add: matchCollection.
	
	^matchCollection.

]

{ #category : #'pair matching & outlier detection' }
VMICP >> findCorrespondingPoint: aPoint [
	
	(useSensorPoint not or: [sensorPointHistory isEmpty or: [sensorPointHistory last isNil]])
		ifTrue: [
			^(nnCollection findNearest: aPoint) result
		] ifFalse: [
			^(nnCollection findNearest: aPoint sensorPoint: sensorPointHistory last) result
		]
]

{ #category : #'pair matching & outlier detection' }
VMICP >> markOutliers [
	
	^self markOutliers: self computeOutlierThreshold

]

{ #category : #'pair matching & outlier detection' }
VMICP >> markOutliers: rejectionDistance [

	^ self markOutliersMatches: matchHistory last threshold: rejectionDistance
	

]

{ #category : #'pair matching & outlier detection' }
VMICP >> markOutliersMatches: matches threshold: rejectionDistance [
	"computes which pairs are considered outliers, based on the provided threshold."
	| numInliers numOutliers |
	
	numInliers := 0.
	numOutliers := 0.
	
	matches do: [ :matchPair |
		((matchPair first isNil or: [matchPair second isNil]) or:
		[matchPair squaredDistance >= rejectionDistance]) ifTrue: [
			matchPair outlier: true.
			numOutliers := numOutliers + 1.
		] ifFalse: [
			matchPair outlier: false.
			numInliers := numInliers + 1.
		].
	].
	^matches
	
	"Transcript
		show: '    computeOutliers rejectionDistance=';
		show: (rejectionDistance printShowingDecimalPlaces: 3);
		show: ', i/o=';
		show: numInliers printString;
		show: '/';
		show: numOutliers printString;
		cr."

]
