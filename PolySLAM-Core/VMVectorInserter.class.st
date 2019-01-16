"
This class is responsible for modifying vectors of a polygon to integrate the provided vector.
The use case for this is, when a dominating vector type (sectors dominate of frontiers, obstacles dominate over any non-obstacle types) from an otherwise redundent polygon needs to be incorporated. The task of doing so may result in the number of vectors in the polygon to increase.



Public API and Key Messages

- insertVector: <VMLineSegment> intoPolygon: <VMPolygon>


Internal Representation and Key Implementation Points.

	Instance Variables
	endNormal: <VMLineSegment>
		a normal vector for 'vector', intersecting at the end point of 'vector'
	polygon: <VMPolygon>
		the polygon that we are working on
	startNormal: <VMLineSegment>
		same as endNormal, but intersecting 'vector' at its start point instead
	vector: <VMLineSegment>
		the vector that we want to incorporate


"
Class {
	#name : #VMVectorInserter,
	#superclass : #Object,
	#instVars : [
		'vector',
		'polygon',
		'startNormal',
		'endNormal'
	],
	#category : #'PolySLAM-Core-Data Structures: Polygons'
}

{ #category : #computing }
VMVectorInserter class >> insertVector: aVector intoPolygon: aPolygon [
	^ self new insertVector: aVector intoPolygon: aPolygon
]

{ #category : #private }
VMVectorInserter >> createChains [
	"returns a collection of chains. each chain contains vectors that are collinear with aVector"
	^ VMVectorChainCollection
		fromTypelessVectorCollection: (polygon select: [ :v |
			(v isCollinearWith: vector) and: [(v direction normalized + vector direction normalized) length > 1.0] ]).

]

{ #category : #computing }
VMVectorInserter >> insertVector: aVector intoPolygon: aPolygon [
	| chains |
	vector := aVector.
	polygon := aPolygon.
	chains := self createChains.
	
	startNormal := aVector pointA vectorTo: (aVector pointA + aVector normal).
	endNormal := aVector pointB vectorTo: (aVector pointB + aVector normal).
	
	chains do: [ :chain |
		self loopOverChain: chain ].


]

{ #category : #private }
VMVectorInserter >> loopOverChain: chain [
	chain do: [ :v |
		| intersectionA intersectionB tempPointA tempPointB |
		intersectionA := VMIntersection intersectLine: v withLine: startNormal.
		intersectionB := VMIntersection intersectLine: v withLine: endNormal.
		tempPointA := v pointA + (v direction * intersectionA factorT).
		tempPointB := v pointA + (v direction * intersectionB factorT).
		
		intersectionA factorT <= 0.0001
			ifTrue: [ "start point of v lies within aVector"
				intersectionB factorT >= 0.9999
					ifTrue: [ "v lies completely in 'aVector'"
						polygon replaceVector: v with: (v copy type: (vector type useDominantType: v type); yourself). ]
					ifFalse: [ "v starts inside of 'aVector', but the end sticks out"
						polygon replaceVector: v withCollection: {
							v pointA vectorTo: tempPointB type: (vector type useDominantType: v type).
							tempPointB vectorTo: v pointB type: v type.
							}. ]. ]
			ifFalse: [ "start point of v is outside of aVector"
				intersectionA factorT < 0.9999 ifTrue: [ "v and aVector do intersect"
					intersectionB factorT >= 0.9999
						ifTrue: [ "endPoint of v lies inside of aVector"
							polygon replaceVector: v withCollection: {
								v pointA vectorTo: tempPointA type: v type.
								tempPointA vectorTo: v pointB type: (vector type useDominantType: v type). }. ]
						ifFalse: [ "aVector lies inside of v"
							polygon replaceVector: v withCollection: {
								v pointA vectorTo: tempPointA type: v type.
								tempPointA vectorTo: tempPointB type: (vector type useDominantType: v type).
								tempPointB vectorTo: v pointB type: v type }. ]. ]. ]. ].

]
